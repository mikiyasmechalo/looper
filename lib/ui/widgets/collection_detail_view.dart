import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/ui/widgets/artist_image.dart';
import 'package:looper_player/ui/widgets/playlist_artwork.dart';
import 'package:looper_player/ui/widgets/app_bottom_sheet.dart';
import 'package:looper_player/ui/widgets/collection_options_bottom_sheet.dart';
import 'package:looper_player/ui/widgets/playlist_options_bottom_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/playlists/presentation/playlist_view.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/core/app_fonts.dart';

// Persistent collection sorting is stored in settings.collectionSortOptionIndex

enum CollectionSortOption {
  trackNumber,
  title,
  artist,
  album,
  playCount,
  duration,
  year,
}

class CollectionDetailView extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final String? artPath;
  final String? imageUrl;
  final List<String> images;
  final List<Song> songs;
  final Playlist? playlist;

  const CollectionDetailView({
    super.key,
    required this.title,
    this.subtitle,
    this.artPath,
    this.imageUrl,
    this.images = const [],
    required this.songs,
    this.playlist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSong = ref.watch(playbackProvider.select((s) => s.currentSong));
    final l10n = AppLocalizations.of(context)!;

    final nav = ref.watch(appNavigationProvider);

    final bool isArtistCollection = playlist == null &&
        (nav.highlightItem == NavItem.artists ||
            subtitle == l10n.artist ||
            subtitle?.toLowerCase() == 'artist' ||
            subtitle == l10n.artists);

    final bool isPlaylistCollection = playlist != null ||
        nav.highlightItem == NavItem.playlists ||
        subtitle == 'Playlist';

    final bool isAlbumCollection = playlist == null &&
        !isArtistCollection &&
        !isPlaylistCollection &&
        subtitle != l10n.genre &&
        subtitle?.toLowerCase() != 'genre';

    // Reactively watch the playlist object if it is passed, so the title updates when renamed
    final reactivePlaylist = playlist != null
        ? ref.watch(playlistProvider.select((list) => list.firstWhere((p) => p.id == playlist!.id, orElse: () => playlist!)))
        : null;

    final effectiveTitle = reactivePlaylist != null
        ? reactivePlaylist.name
        : (nav.activeItem == NavItem.collectionDetail && nav.collectionTitle != null
            ? nav.collectionTitle!
            : title);

    final effectiveSubtitle = reactivePlaylist != null
        ? subtitle
        : (nav.activeItem == NavItem.collectionDetail
            ? nav.collectionSubtitle
            : subtitle);

    final effectiveArtPath = reactivePlaylist != null
        ? artPath
        : (nav.activeItem == NavItem.collectionDetail
            ? nav.collectionArt
            : artPath);

    final titleToRender = effectiveTitle;

    // Reactively watch songs of this playlist using playlistSongsProvider
    final playlistSongsAsync = playlist != null
        ? ref.watch(playlistSongsProvider(playlist!.id))
        : null;

    final songsToRender = playlistSongsAsync != null
        ? (playlistSongsAsync.value ?? <Song>[])
        : (nav.activeItem == NavItem.collectionDetail && nav.collectionSongs.isNotEmpty
            ? nav.collectionSongs
            : songs);

    final int sortOptionIndex;
    final bool isAscending;

    if (isAlbumCollection) {
      sortOptionIndex = ref.watch(settingsProvider.select((s) => s.albumDetailSortOptionIndex));
      isAscending = ref.watch(settingsProvider.select((s) => s.albumDetailSortAscending));
    } else if (isArtistCollection) {
      sortOptionIndex = ref.watch(settingsProvider.select((s) => s.artistDetailSortOptionIndex));
      isAscending = ref.watch(settingsProvider.select((s) => s.artistDetailSortAscending));
    } else if (isPlaylistCollection) {
      sortOptionIndex = ref.watch(settingsProvider.select((s) => s.playlistDetailSortOptionIndex));
      isAscending = ref.watch(settingsProvider.select((s) => s.playlistDetailSortAscending));
    } else {
      sortOptionIndex = ref.watch(settingsProvider.select((s) => s.collectionSortOptionIndex));
      isAscending = ref.watch(settingsProvider.select((s) => s.collectionSortAscending));
    }
    final sortOption = CollectionSortOption.values[sortOptionIndex.clamp(0, CollectionSortOption.values.length - 1)];
    final sortedSongs = List<Song>.from(songsToRender);
    switch (sortOption) {
      case CollectionSortOption.trackNumber:
        sortedSongs.sort((a, b) => isAscending
            ? (a.trackNumber ?? 0).compareTo(b.trackNumber ?? 0)
            : (b.trackNumber ?? 0).compareTo(a.trackNumber ?? 0));
        break;
      case CollectionSortOption.title:
        sortedSongs.sort((a, b) => isAscending
            ? a.title.toLowerCase().compareTo(b.title.toLowerCase())
            : b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case CollectionSortOption.artist:
        sortedSongs.sort((a, b) => isAscending
            ? (a.artist ?? '').toLowerCase().compareTo((b.artist ?? '').toLowerCase())
            : (b.artist ?? '').toLowerCase().compareTo((a.artist ?? '').toLowerCase()));
        break;
      case CollectionSortOption.album:
        sortedSongs.sort((a, b) => isAscending
            ? (a.album ?? '').toLowerCase().compareTo((b.album ?? '').toLowerCase())
            : (b.album ?? '').toLowerCase().compareTo((a.album ?? '').toLowerCase()));
        break;
      case CollectionSortOption.playCount:
        sortedSongs.sort((a, b) => isAscending
            ? (a.playCount).compareTo(b.playCount)
            : (b.playCount).compareTo(a.playCount));
        break;
      case CollectionSortOption.duration:
        sortedSongs.sort((a, b) => isAscending
            ? (a.duration ?? 0).compareTo(b.duration ?? 0)
            : (b.duration ?? 0).compareTo(a.duration ?? 0));
        break;
      case CollectionSortOption.year:
        sortedSongs.sort((a, b) => isAscending
            ? (a.year ?? 0).compareTo(b.year ?? 0)
            : (b.year ?? 0).compareTo(a.year ?? 0));
        break;
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(appNavigationProvider.notifier).goBack();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Desktop Top Spacer to prevent header overlay issues
                      if (!Platform.isAndroid && !Platform.isIOS)
                        const SizedBox(height: 16),
                      // Header - Now always a Row for cover and name
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: isNarrow
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: _buildArt(
                                      context,
                                      playlist != null ? songsToRender : null,
                                      customArtPath: effectiveArtPath,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInfo(
                                    context,
                                    ref,
                                    true,
                                    activeSong?.artPath,
                                    reactivePlaylist,
                                    titleToRender,
                                    effectiveSubtitle,
                                    effectiveArtPath,
                                    sortedSongs,
                                  ),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildArt(
                                    context,
                                    playlist != null ? songsToRender : null,
                                    customArtPath: effectiveArtPath,
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildInfo(
                                      context,
                                      ref,
                                      true,
                                      activeSong?.artPath,
                                      reactivePlaylist,
                                      titleToRender,
                                      effectiveSubtitle,
                                      effectiveArtPath,
                                      sortedSongs,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
                if (sortedSongs.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = sortedSongs[index];
                        final l10n = AppLocalizations.of(context)!;
                        return SongTile(
                          song: song,
                          l10n: l10n,
                          songs: sortedSongs,
                          playlist: reactivePlaylist,
                          showAlbum: !isAlbumCollection,
                          queueName: titleToRender,
                        );
                      },
                      childCount: sortedSongs.length,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    // On mobile the bottom navigation bar overlaps the list,
                    // so keep generous padding. Desktop has no overlay.
                    height: (Platform.isAndroid || Platform.isIOS) ? 200 : 32,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Subtitle line for the detail header. For album collections it includes the
  /// artist name and number of songs (e.g. "Artist Name · 12 Songs"). For artist
  /// collections it shows just the number of songs (e.g. "12 Songs"). Playlist
  /// and genre collections keep their plain type label.
  String _subtitleWithCount(BuildContext context, WidgetRef ref, String? effectiveSubtitle, List<Song> collectionSongs) {
    final l10n = AppLocalizations.of(context)!;
    final nav = ref.read(appNavigationProvider);
    final isArtistCollection = nav.highlightItem == NavItem.artists ||
        effectiveSubtitle == l10n.artists ||
        effectiveSubtitle == l10n.artist ||
        effectiveSubtitle?.toLowerCase() == 'artist' ||
        effectiveSubtitle?.toLowerCase() == 'artists';

    if (isArtistCollection) {
      return '${collectionSongs.length} ${l10n.songs}';
    }

    final isTypeLabel = playlist != null ||
        effectiveSubtitle == 'Playlist' ||
        effectiveSubtitle == l10n.genre ||
        effectiveSubtitle?.toLowerCase() == 'genre';
    if (isTypeLabel || effectiveSubtitle == null) return effectiveSubtitle ?? '';
    // Artist detail: the subtitle is just the word "Artists", so show only the
    // song count instead of "Artists · N Songs".
    if (effectiveSubtitle == l10n.artists) {
      return '${collectionSongs.length} ${l10n.songs}';
    }
    return '$effectiveSubtitle · ${collectionSongs.length} ${l10n.songs}';
  }

  Widget _buildArt(BuildContext context, List<Song>? playlistSongs, {String? customArtPath}) {
    final double size = 140; // Unified size for a cleaner Row look

    if (playlistSongs != null) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: PlaylistArtwork(
            songs: playlistSongs,
            fallbackBackground: Theme.of(context).colorScheme.primaryContainer
                .withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return ArtistImage(
      images: images,
      imagePath: customArtPath ?? artPath,
      imageUrl: imageUrl,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(16),
      placeholder: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          LucideIcons.music,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildInfo(
    BuildContext context,
    WidgetRef ref,
    bool isNarrow,
    String? activeArtworkPath,
    Playlist? reactivePlaylist,
    String titleToRender,
    String? subtitleToRender,
    String? artPathToRender,
    List<Song> songsToRender,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final nav = ref.watch(appNavigationProvider);
    final isArtistCollection = nav.highlightItem == NavItem.artists ||
        subtitleToRender == l10n.artists ||
        subtitleToRender == l10n.artist ||
        subtitleToRender?.toLowerCase() == 'artist' ||
        subtitleToRender?.toLowerCase() == 'artists';
    final bool isAlbumCollection = playlist == null &&
        !isArtistCollection &&
        subtitleToRender != l10n.genre &&
        subtitleToRender?.toLowerCase() != 'genre';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleToRender,
          style: AppFonts.jostStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitleToRender != null || isArtistCollection) ...[
          const SizedBox(height: 4),
          Text(
            _subtitleWithCount(context, ref, subtitleToRender, songsToRender),
            style: AppFonts.jostStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            PremiumSection(
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 44,
              useExpanded: false,
              onTap: () {
                HapticFeedback.mediumImpact();
                ref.read(playbackProvider.notifier).setPlaylist(songsToRender, queueName: title);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.playAll,
                    style: AppFonts.jostStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PremiumSection(
              borderRadius: BorderRadius.circular(12),
              width: 44,
              height: 44,
              useExpanded: false,
              onTap: () {
                HapticFeedback.lightImpact();
                ref
                    .read(playbackProvider.notifier)
                    .playShuffled(songsToRender, queueName: titleToRender);
              },
              child: const Icon(LucideIcons.shuffle, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            PremiumSection(
              borderRadius: BorderRadius.circular(12),
              width: 44,
              height: 44,
              useExpanded: false,
              onTap: () {
                HapticFeedback.lightImpact();
                _showSortBottomSheet(context, ref);
              },
              child: const Icon(LucideIcons.arrowUpDown, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            PremiumSection(
              borderRadius: BorderRadius.circular(12),
              width: 44,
              height: 44,
              useExpanded: false,
              onTap: () {
                HapticFeedback.lightImpact();
                if (reactivePlaylist != null) {
                  showPlaylistOptionsBottomSheet(
                    context: context,
                    ref: ref,
                    playlist: reactivePlaylist,
                    songs: songsToRender,
                  );
                } else if (isAlbumCollection) {
                  final album = Album()
                    ..name = titleToRender
                    ..artist = subtitleToRender
                    ..artPath = artPathToRender ?? activeArtworkPath
                    ..dateAdded = DateTime.now();
                  showAlbumOptionsBottomSheet(
                    context: context,
                    ref: ref,
                    album: album,
                  );
                } else if (isArtistCollection) {
                  final artist = Artist()
                    ..name = titleToRender
                    ..artPath = artPathToRender ?? activeArtworkPath
                    ..artistImageUrl = imageUrl
                    ..artistImages = images;
                  showArtistOptionsBottomSheet(
                    context: context,
                    ref: ref,
                    artist: artist,
                  );
                } else {
                  showCollectionOptionsBottomSheet(
                    context: context,
                    ref: ref,
                    title: titleToRender,
                    subtitle: subtitleToRender,
                    artPath: artPathToRender,
                    imageUrl: imageUrl,
                    images: images,
                    songs: songsToRender,
                  );
                }
              },
              child: const Icon(
                LucideIcons.moreHorizontal,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSortBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final settings = ref.watch(settingsProvider);
        final accentColor = Color(settings.accentColor);

        final nav = ref.read(appNavigationProvider);

        final bool isArtistCollection = playlist == null &&
            (nav.highlightItem == NavItem.artists ||
                subtitle == l10n.artist ||
                subtitle?.toLowerCase() == 'artist' ||
                subtitle == l10n.artists);

        final bool isPlaylistCollection = playlist != null ||
            nav.highlightItem == NavItem.playlists ||
            subtitle == 'Playlist';

        final bool isAlbumCollection = playlist == null &&
            !isArtistCollection &&
            !isPlaylistCollection &&
            subtitle != l10n.genre &&
            subtitle?.toLowerCase() != 'genre';

        final int sortIdx;
        final bool isAscending;

        if (isAlbumCollection) {
          sortIdx = settings.albumDetailSortOptionIndex;
          isAscending = settings.albumDetailSortAscending;
        } else if (isArtistCollection) {
          sortIdx = settings.artistDetailSortOptionIndex;
          isAscending = settings.artistDetailSortAscending;
        } else if (isPlaylistCollection) {
          sortIdx = settings.playlistDetailSortOptionIndex;
          isAscending = settings.playlistDetailSortAscending;
        } else {
          sortIdx = settings.collectionSortOptionIndex;
          isAscending = settings.collectionSortAscending;
        }

        void updateSortIndex(int index) {
          final notifier = ref.read(settingsProvider.notifier);
          if (isAlbumCollection) {
            notifier.updateAlbumDetailSortOptionIndex(index);
          } else if (isArtistCollection) {
            notifier.updateArtistDetailSortOptionIndex(index);
          } else if (isPlaylistCollection) {
            notifier.updatePlaylistDetailSortOptionIndex(index);
          } else {
            notifier.updateCollectionSortOptionIndex(index);
          }
        }

        void updateSortAsc(bool asc) {
          final notifier = ref.read(settingsProvider.notifier);
          if (isAlbumCollection) {
            notifier.updateAlbumDetailSortAscending(asc);
          } else if (isArtistCollection) {
            notifier.updateArtistDetailSortAscending(asc);
          } else if (isPlaylistCollection) {
            notifier.updatePlaylistDetailSortAscending(asc);
          } else {
            notifier.updateCollectionSortAscending(asc);
          }
        }

        return AppBottomSheetContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      l10n.sortOrder,
                      style: AppFonts.jostStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      updateSortAsc(!isAscending);
                    },
                    icon: Icon(
                      isAscending ? LucideIcons.arrowUpAZ : LucideIcons.arrowDownAZ,
                      size: 18,
                    ),
                    label: Text(
                      isAscending ? l10n.ascending : l10n.descending,
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 24),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: PremiumSection(
                      borderRadius: BorderRadius.circular(20),
                      padding: EdgeInsets.zero,
                      useExpanded: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SortOption(
                            label: 'Track #',
                            icon: LucideIcons.list,
                            isSelected: sortIdx == CollectionSortOption.trackNumber.index,
                            accentColor: accentColor,
                            isLast: false,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              updateSortIndex(CollectionSortOption.trackNumber.index);
                              Navigator.pop(context);
                            },
                          ),
                          const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                          _SortOption(
                            label: l10n.title,
                            icon: LucideIcons.type,
                            isSelected: sortIdx == CollectionSortOption.title.index,
                            accentColor: accentColor,
                            isLast: false,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              updateSortIndex(CollectionSortOption.title.index);
                              Navigator.pop(context);
                            },
                          ),
                          if (!isArtistCollection) ...[
                            const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                            _SortOption(
                              label: l10n.artist,
                              icon: LucideIcons.mic2,
                              isSelected: sortIdx == CollectionSortOption.artist.index,
                              accentColor: accentColor,
                              isLast: false,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                updateSortIndex(CollectionSortOption.artist.index);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                          if (!isAlbumCollection) ...[
                            const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                            _SortOption(
                              label: l10n.album,
                              icon: LucideIcons.disc,
                              isSelected: sortIdx == CollectionSortOption.album.index,
                              accentColor: accentColor,
                              isLast: false,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                updateSortIndex(CollectionSortOption.album.index);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                          const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                          _SortOption(
                            label: l10n.mostPlayed,
                            icon: LucideIcons.trendingUp,
                            isSelected: sortIdx == CollectionSortOption.playCount.index,
                            accentColor: accentColor,
                            isLast: false,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              updateSortIndex(CollectionSortOption.playCount.index);
                              Navigator.pop(context);
                            },
                          ),
                          const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                          _SortOption(
                            label: l10n.duration,
                            icon: LucideIcons.clock,
                            isSelected: sortIdx == CollectionSortOption.duration.index,
                            accentColor: accentColor,
                            isLast: false,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              updateSortIndex(CollectionSortOption.duration.index);
                              Navigator.pop(context);
                            },
                          ),
                          const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                          _SortOption(
                            label: l10n.year,
                            icon: LucideIcons.calendarDays,
                            isSelected: sortIdx == CollectionSortOption.year.index,
                            accentColor: accentColor,
                            isLast: true,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              updateSortIndex(CollectionSortOption.year.index);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final bool isLast;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? accentColor
                      : Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: AppFonts.jostStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
      ],
    );
  }
}
