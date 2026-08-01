import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/ui/widgets/artist_image.dart';
import 'package:looper_player/ui/widgets/app_bottom_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/playlists/presentation/playlist_view.dart';
import 'package:looper_player/core/db_service.dart';
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

    // Reactively watch the playlist object if it is passed, so the title updates when renamed
    final reactivePlaylist = playlist != null
        ? ref.watch(playlistProvider.select((list) => list.firstWhere((p) => p.id == playlist!.id, orElse: () => playlist!)))
        : null;

    final titleToRender = reactivePlaylist != null ? reactivePlaylist.name : title;

    // Reactively watch songs of this playlist using playlistSongsProvider
    final playlistSongsAsync = playlist != null
        ? ref.watch(playlistSongsProvider(playlist!.id))
        : null;

    final songsToRender = playlistSongsAsync != null
        ? (playlistSongsAsync.value ?? <Song>[])
        : songs;

    final sortOptionIndex = ref.watch(settingsProvider.select((s) => s.collectionSortOptionIndex));
    final isAscending = ref.watch(settingsProvider.select((s) => s.collectionSortAscending));
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 450;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isNarrow)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                          child: PremiumSection(
                            useExpanded: false,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              bottomLeft: Radius.circular(32),
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            width: 44,
                            height: 44,
                            onTap: () => ref.read(appNavigationProvider.notifier).goBack(),
                            child: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 20),
                          ),
                        ),
                      // Header - Now always a Row for cover and name
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: isNarrow
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(child: _buildArt(context, true)),
                                  const SizedBox(height: 20),
                                  _buildInfo(context, ref, true, activeSong?.artPath, reactivePlaylist, titleToRender, sortedSongs),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildArt(context, true),
                                  const SizedBox(width: 20),
                                  Expanded(child: _buildInfo(context, ref, true, activeSong?.artPath, reactivePlaylist, titleToRender, sortedSongs)),
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
                        );
                      },
                      childCount: sortedSongs.length,
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 200), // Added padding to fix navbar overlap
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildArt(BuildContext context, bool isNarrow) {
    final double size = 140; // Unified size for a cleaner Row look
    return ArtistImage(
      images: images,
      imagePath: artPath,
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

  Widget _buildInfo(BuildContext context, WidgetRef ref, bool isNarrow, String? activeArtworkPath, Playlist? reactivePlaylist, String titleToRender, List<Song> songsToRender) {
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
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
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
                ref.read(playbackProvider.notifier).setPlaylist(songsToRender);
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
                    .playShuffled(songsToRender);
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
            if (reactivePlaylist != null) ...[
              const SizedBox(width: 8),
              PremiumSection(
                borderRadius: BorderRadius.circular(12),
                width: 44,
                height: 44,
                useExpanded: false,
                onTap: () => _showPlaylistOptions(context, ref, reactivePlaylist),
                child: const Icon(LucideIcons.moreHorizontal, size: 18, color: Colors.white),
              ),
            ],
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
        final sortIdx = settings.collectionSortOptionIndex;
        final isAscending = settings.collectionSortAscending;
        final bool isArtistCollection = (subtitle != null && (subtitle!.toLowerCase() == 'artist' || subtitle == l10n.artist)) ||
            (songs.isNotEmpty && songs.every((s) => s.artist?.toLowerCase() == title.toLowerCase()));
        final bool isAlbumCollection = !isArtistCollection;

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
                      ref.read(settingsProvider.notifier).updateCollectionSortAscending(!isAscending);
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
                              ref.read(settingsProvider.notifier).updateCollectionSortOptionIndex(CollectionSortOption.trackNumber.index);
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
                              ref.read(settingsProvider.notifier).updateCollectionSortOptionIndex(CollectionSortOption.title.index);
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
                                ref.read(settingsProvider.notifier).updateCollectionSortOptionIndex(CollectionSortOption.artist.index);
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
                                ref.read(settingsProvider.notifier).updateCollectionSortOptionIndex(CollectionSortOption.album.index);
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
                              ref.read(settingsProvider.notifier).updateCollectionSortOptionIndex(CollectionSortOption.playCount.index);
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
                              ref.read(settingsProvider.notifier).updateCollectionSortOptionIndex(CollectionSortOption.duration.index);
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
                              ref.read(settingsProvider.notifier).updateCollectionSortOptionIndex(CollectionSortOption.year.index);
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

  void _showPlaylistOptions(BuildContext context, WidgetRef ref, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (context) {
        final settings = ref.watch(settingsProvider);
        final useBlur = settings.enableDynamicTheming && !settings.disableBlur;
        final isPureBlack = settings.darkTheme;

        final sheetBg = isPureBlack 
            ? Colors.black 
            : (useBlur ? Colors.black.withValues(alpha: 0.6) : const Color(0xFF1E1E1E));

        Widget sheetContent = Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isPureBlack ? Colors.white10 : Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.listMusic, size: 24, color: Colors.orangeAccent),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          playlist.name,
                          style: AppFonts.jostStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 8),
                PremiumSection(
                  borderRadius: BorderRadius.circular(20),
                  padding: EdgeInsets.zero,
                  useExpanded: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showRenameDialog(context, ref, playlist);
                        },
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.edit2, size: 22, color: Colors.greenAccent),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Rename Playlist',
                                  style: AppFonts.jostStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Icon(
                                LucideIcons.chevronRight,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.8,
                        color: Colors.white.withValues(alpha: 0.04),
                        indent: 20,
                        endIndent: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteDialog(context, ref, playlist);
                        },
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.trash2, size: 22, color: Colors.redAccent),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Delete Playlist',
                                  style: AppFonts.jostStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Icon(
                                LucideIcons.chevronRight,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );

        if (useBlur && !isPureBlack) {
          return RepaintBoundary(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: sheetContent,
              ),
            ),
          );
        }

        return sheetContent;
      },
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, Playlist playlist) {
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          title: Text(l10n.renamePlaylist),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: l10n.newPlaylist),
            autofocus: true,
            style: AppFonts.jostStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty && controller.text != playlist.name) {
                  await DbService.isar.writeTxn(() async {
                    playlist.name = controller.text;
                    playlist.dateModified = DateTime.now();
                    await DbService.isar.playlists.put(playlist);
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.rename),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          title: Text(l10n.deletePlaylist),
          content: Text(l10n.deletePlaylistConfirm(playlist.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                await DbService.isar.writeTxn(() => DbService.isar.playlists.delete(playlist.id));
                Navigator.pop(context); // Close dialog
                ref.read(appNavigationProvider.notifier).goBack(); // Go back using appNavigationProvider to stay in sync
              },
              child: Text(l10n.delete, style: AppFonts.jostStyle(color: Colors.redAccent)),
            ),
          ],
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
