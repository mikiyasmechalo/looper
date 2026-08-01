import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:looper_player/ui/widgets/app_bottom_sheet.dart';
import 'package:looper_player/ui/widgets/app_loading_indicator.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/ui/widgets/global_playing_indicator.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/ui/screens/android/tabs/views/library_categories_views.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/ui/widgets/collection_options_bottom_sheet.dart';

// Providers for Albums and Artists
final albumsProvider = StreamProvider<List<Album>>((ref) {
  return DbService.isar.albums.where().sortByDateAddedDesc().watch(
    fireImmediately: true,
  );
});

final artistsProvider = StreamProvider<List<Artist>>((ref) {
  return DbService.isar.artists.where().sortByName().watch(
    fireImmediately: true,
  );
});

final genresProvider = Provider<List<String>>((ref) {
  final songs = ref.watch(libraryProvider).songs;
  final genreSet = <String>{};
  for (final song in songs) {
    final genre = song.genre;
    if (genre != null && genre.isNotEmpty) {
      genreSet.add(genre);
    }
  }
  return genreSet.toList()..sort();
});

final Map<String, double> _gridScrollOffsets = {};

class AlbumsGrid extends ConsumerStatefulWidget {
  const AlbumsGrid({super.key});

  @override
  ConsumerState<AlbumsGrid> createState() => _AlbumsGridState();
}

class _AlbumsGridState extends ConsumerState<AlbumsGrid> {
  late final ScrollController _scrollController = ScrollController(
    initialScrollOffset: _gridScrollOffsets['albums'] ?? 0,
    keepScrollOffset: false,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      _gridScrollOffsets['albums'] = _scrollController.offset;
    }
  }

  @override
  void dispose() {
    if (_scrollController.hasClients) {
      _gridScrollOffsets['albums'] = _scrollController.offset;
    }
    _scrollController.dispose();
    super.dispose();
  }

  List<Album> _sort(List<Album> albums, AlbumSortOption opt, bool asc) {
    final list = List<Album>.from(albums);
    switch (opt) {
      case AlbumSortOption.name:
        list.sort((a, b) => asc
            ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
            : b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case AlbumSortOption.dateAdded:
        list.sort((a, b) => asc
            ? a.dateAdded.compareTo(b.dateAdded)
            : b.dateAdded.compareTo(a.dateAdded));
      case AlbumSortOption.year:
        list.sort((a, b) => asc
            ? (a.year ?? 0).compareTo(b.year ?? 0)
            : (b.year ?? 0).compareTo(a.year ?? 0));
      case AlbumSortOption.songCount:
        final counts = <String, int>{};
        for (final song in ref.read(libraryProvider).songs) {
          if (song.album != null) {
            counts[song.album!] = (counts[song.album!] ?? 0) + 1;
          }
        }
        list.sort((a, b) => asc
            ? (counts[a.name] ?? 0).compareTo(counts[b.name] ?? 0)
            : (counts[b.name] ?? 0).compareTo(counts[a.name] ?? 0));
      case AlbumSortOption.artistAlbumArtist:
        list.sort((a, b) => asc
            ? (a.artist ?? '').toLowerCase().compareTo((b.artist ?? '').toLowerCase())
            : (b.artist ?? '').toLowerCase().compareTo((a.artist ?? '').toLowerCase()));
    }
    return list;
  }

  String _sortLabel(AlbumSortOption opt, AppLocalizations l10n) =>
      switch (opt) {
        AlbumSortOption.name => l10n.sortAlphabeticalAZ,
        AlbumSortOption.dateAdded => l10n.sortRecentlyAdded,
        AlbumSortOption.year => l10n.sortYearNewest,
        AlbumSortOption.songCount => l10n.sortMostSongs,
        AlbumSortOption.artistAlbumArtist => l10n.artist,
      };

  void _showSortMenu(AppLocalizations l10n) {
    final accentColor = Color(ref.read(settingsProvider).accentColor);
    final currentSort = ref.read(albumSortProvider);
    final currentAsc = ref.read(albumSortAscendingProvider);
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppBottomSheetContainer(
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
                    ref.read(albumSortAscendingProvider.notifier).state = !currentAsc;
                  },
                  icon: Icon(
                    currentAsc ? LucideIcons.arrowUpAZ : LucideIcons.arrowDownAZ,
                    size: 18,
                  ),
                  label: Text(
                    currentAsc ? l10n.ascending : l10n.descending,
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
                        _GridSortOption(
                          label: l10n.sortAlphabeticalAZ,
                          icon: LucideIcons.type,
                          isSelected: currentSort == AlbumSortOption.name,
                          accentColor: accentColor,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(albumSortProvider.notifier).state = AlbumSortOption.name;
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                        _GridSortOption(
                          label: l10n.sortRecentlyAdded,
                          icon: LucideIcons.calendar,
                          isSelected: currentSort == AlbumSortOption.dateAdded,
                          accentColor: accentColor,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(albumSortProvider.notifier).state = AlbumSortOption.dateAdded;
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                        _GridSortOption(
                          label: l10n.sortYearNewest,
                          icon: LucideIcons.calendarDays,
                          isSelected: currentSort == AlbumSortOption.year,
                          accentColor: accentColor,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(albumSortProvider.notifier).state = AlbumSortOption.year;
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                        _GridSortOption(
                          label: l10n.sortMostSongs,
                          icon: LucideIcons.music,
                          isSelected: currentSort == AlbumSortOption.songCount,
                          accentColor: accentColor,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(albumSortProvider.notifier).state = AlbumSortOption.songCount;
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                        _GridSortOption(
                          label: l10n.artist,
                          icon: LucideIcons.mic2,
                          isSelected: currentSort == AlbumSortOption.artistAlbumArtist,
                          accentColor: accentColor,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(albumSortProvider.notifier).state = AlbumSortOption.artistAlbumArtist;
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final albumsAsync = ref.watch(albumsProvider);
    final sortOpt = ref.watch(albumSortProvider);
    final sortAsc = ref.watch(albumSortAscendingProvider);
    final l10n = AppLocalizations.of(context)!;

    return albumsAsync.when(
      data: (raw) {
        final albums = _sort(raw, sortOpt, sortAsc);
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.s, 16.s, 24.s, 0),
              child: Row(
                children: [
                  Text(
                    '${albums.length} ${l10n.albums}',
                    style: AppFonts.jostStyle(
                      color: Colors.white54,
                      fontSize: 13.ts,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showSortMenu(l10n),
                    icon: const Icon(LucideIcons.arrowUpDown, size: 14),
                    label: Text(
                      _sortLabel(sortOpt, l10n),
                      style: AppFonts.jostStyle(fontSize: 13.ts),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRect(
                child: GridView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(24.s),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200.s,
                    childAspectRatio: 0.80,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: albums.length,
                  itemBuilder: (context, index) =>
                      _AlbumCard(album: albums[index]),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const AppLoadingIndicator(),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _AlbumCard extends ConsumerWidget {
  final Album album;
  const _AlbumCard({required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDynamic = ref.watch(settingsProvider).enableDynamicTheming;
    final isCurrentAlbum = ref.watch(
      playbackProvider.select((s) => s.currentSong?.album == album.name),
    );
    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
    final nav = ref.watch(appNavigationProvider);
    final isSelected =
        nav.activeItem == NavItem.collectionDetail &&
        nav.collectionTitle == album.name;

    return GestureDetector(
      onSecondaryTap: () => showAlbumOptionsBottomSheet(
        context: context,
        ref: ref,
        album: album,
      ),
      child: InkWell(
        onTap: () async {
          final songs = await DbService.isar.songs
              .filter()
              .albumEqualTo(album.name)
              .findAll();
          ref
              .read(appNavigationProvider.notifier)
              .showCollection(
                title: album.name,
                subtitle: album.artist,
                art: album.artPath,
                songs: songs,
                highlightItem: NavItem.albums,
              );
        },
        borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isSelected
              ? const Color.fromARGB(
                  255,
                  53,
                  53,
                  53,
                ).withValues(alpha: isDynamic ? 0.3 : 0.1)
              : Colors.transparent,
          border: isSelected
              ? Border.all(
                  color: Colors.white10.withValues(alpha: 0.1),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child: PlayingOverlay(
                  isPlaying: isCurrentAlbum && isPlaying,
                  borderRadius: 16,
                  child: album.artPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: OptimizedImage(
                            imagePath: album.artPath,
                            fit: BoxFit.cover,
                            placeholder: const Center(
                              child: Icon(
                                LucideIcons.disc,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            LucideIcons.disc,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    style: AppFonts.jostStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14.ts,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    album.artist ?? 'Unknown Artist',
                    style: AppFonts.jostStyle(
                      color: Colors.grey[400],
                      fontSize: 12.ts,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class ArtistsGrid extends ConsumerStatefulWidget {
  const ArtistsGrid({super.key});

  @override
  ConsumerState<ArtistsGrid> createState() => _ArtistsGridState();
}

class _ArtistsGridState extends ConsumerState<ArtistsGrid> {
  late final ScrollController _scrollController = ScrollController(
    initialScrollOffset: _gridScrollOffsets['artists'] ?? 0,
    keepScrollOffset: false,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      _gridScrollOffsets['artists'] = _scrollController.offset;
    }
  }

  @override
  void dispose() {
    if (_scrollController.hasClients) {
      _gridScrollOffsets['artists'] = _scrollController.offset;
    }
    _scrollController.dispose();
    super.dispose();
  }

  List<Artist> _sort(List<Artist> artists, ArtistSortOption opt, List<Song> allSongs, bool asc) {
    final list = List<Artist>.from(artists);
    switch (opt) {
      case ArtistSortOption.name:
        list.sort((a, b) => asc
            ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
            : b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case ArtistSortOption.songCount:
        final songCounts = <String, int>{};
        for (final song in allSongs) {
          final names = <String>{};
          if (song.artist != null) names.add(song.artist!);
          if (song.albumArtist != null) names.add(song.albumArtist!);
          for (final name in names) {
            songCounts[name] = (songCounts[name] ?? 0) + 1;
          }
        }
        list.sort((a, b) {
          final diff = (songCounts[a.name] ?? 0).compareTo(songCounts[b.name] ?? 0);
          return asc ? diff : -diff;
        });
    }
    return list;
  }

  String _sortLabel(ArtistSortOption opt, AppLocalizations l10n) =>
      switch (opt) {
        ArtistSortOption.name => l10n.sortAlphabeticalAZ,
        ArtistSortOption.songCount => l10n.sortMostSongs,
      };

  void _showSortMenu(AppLocalizations l10n) {
    final accentColor = Color(ref.read(settingsProvider).accentColor);
    final currentSort = ref.read(artistSortProvider);
    final currentAsc = ref.read(artistSortAscendingProvider);
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppBottomSheetContainer(
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
                    ref.read(artistSortAscendingProvider.notifier).state = !currentAsc;
                  },
                  icon: Icon(
                    currentAsc ? LucideIcons.arrowUpAZ : LucideIcons.arrowDownAZ,
                    size: 18,
                  ),
                  label: Text(
                    currentAsc ? l10n.ascending : l10n.descending,
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
                        _GridSortOption(
                          label: l10n.sortAlphabeticalAZ,
                          icon: LucideIcons.type,
                          isSelected: currentSort == ArtistSortOption.name,
                          accentColor: accentColor,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(artistSortProvider.notifier).state = ArtistSortOption.name;
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                        _GridSortOption(
                          label: l10n.sortMostSongs,
                          icon: LucideIcons.music,
                          isSelected: currentSort == ArtistSortOption.songCount,
                          accentColor: accentColor,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(artistSortProvider.notifier).state = ArtistSortOption.songCount;
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final artistsAsync = ref.watch(artistsProvider);
    final sortOpt = ref.watch(artistSortProvider);
    final sortAsc = ref.watch(artistSortAscendingProvider);
    final allSongs = ref.watch(libraryProvider.select((s) => s.songs));
    final l10n = AppLocalizations.of(context)!;

    return artistsAsync.when(
      data: (raw) {
        final artists = _sort(raw, sortOpt, allSongs, sortAsc);
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.s, 16.s, 24.s, 0),
              child: Row(
                children: [
                  Text(
                    '${artists.length} ${l10n.artists}',
                    style: AppFonts.jostStyle(
                      color: Colors.white54,
                      fontSize: 13.ts,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showSortMenu(l10n),
                    icon: const Icon(LucideIcons.arrowUpDown, size: 14),
                    label: Text(
                      _sortLabel(sortOpt, l10n),
                      style: AppFonts.jostStyle(fontSize: 13.ts),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRect(
                child: GridView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(24.s),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180.s,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: artists.length,
                  itemBuilder: (context, index) => _ArtistCard(artist: artists[index]),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const AppLoadingIndicator(),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _ArtistCard extends ConsumerWidget {
  final Artist artist;
  const _ArtistCard({required this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDynamic = ref.watch(settingsProvider).enableDynamicTheming;
    final nav = ref.watch(appNavigationProvider);
    final isSelected =
        nav.activeItem == NavItem.collectionDetail &&
        nav.collectionTitle == artist.name;

    return GestureDetector(
      onSecondaryTap: () => showArtistOptionsBottomSheet(
        context: context,
        ref: ref,
        artist: artist,
      ),
      child: InkWell(
        onTap: () async {
          final songs = await DbService.isar.songs
              .filter()
              .artistEqualTo(artist.name)
              .or()
              .albumArtistEqualTo(artist.name)
              .findAll();
          final isLocalImage =
              artist.artistImageUrl != null &&
              !artist.artistImageUrl!.startsWith('http');
          final isNetworkImage =
              artist.artistImageUrl != null &&
              artist.artistImageUrl!.startsWith('http');

          ref
              .read(appNavigationProvider.notifier)
              .showCollection(
                title: artist.name,
                art: isLocalImage ? artist.artistImageUrl : artist.artPath,
                imageUrl: isNetworkImage ? artist.artistImageUrl : null,
                songs: songs,
                highlightItem: NavItem.artists,
              );
        },
        borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isSelected
              ? const Color.fromARGB(
                  255,
                  53,
                  53,
                  53,
                ).withValues(alpha: isDynamic ? 0.3 : 0.1)
              : Colors.transparent,
          border: isSelected
              ? Border.all(
                  color: Colors.white10.withValues(alpha: 0.1),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child: ClipOval(
                  child: OptimizedImage(
                    imageUrl: artist.artistImageUrl,
                    imagePath: artist.artPath,
                    fit: BoxFit.cover,
                    placeholder: const Center(
                      child: Icon(
                        LucideIcons.user,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              artist.name,
              style: AppFonts.jostStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14.ts,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Shared helper for context menu items.
Widget _menuItem(IconData icon, String label) => Row(
  children: [
    Icon(icon, size: 16, color: Colors.white70),
    const SizedBox(width: 12),
    Text(label, style: const TextStyle(color: Colors.white)),
  ],
);

/// Reusable sort option row used in the sort bottom sheet.
class _SortItem<T> extends ConsumerWidget {
  final String label;
  final T value;
  final StateProvider<T> provider;
  const _SortItem({
    required this.label,
    required this.value,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(provider);
    final isSelected = current == value;
    final accentColor = Color(ref.read(settingsProvider).accentColor);
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(provider.notifier).state = value;
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppFonts.jostStyle(
                color: isSelected ? accentColor : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.check, color: accentColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class GenresGrid extends ConsumerWidget {
  const GenresGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(libraryProvider).songs;
    final l10n = AppLocalizations.of(context)!;
    final genresMap = <String, List<Song>>{};
    for (var song in songs) {
      final genre = song.genre ?? l10n.unknown;
      genresMap.putIfAbsent(genre, () => []).add(song);
    }

    final genres = genresMap.keys.toList()..sort();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double minCardWidth = 280.0;
        final int crossAxisCount = (maxWidth / minCardWidth).floor().clamp(
          2,
          6,
        );
        final double totalPadding = 48.0;
        final double totalSpacing = (crossAxisCount - 1) * 20.0;
        final double cardWidth =
            (maxWidth - totalPadding - totalSpacing) / crossAxisCount;

        return ClipRect(
          child: GridView.builder(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: 200,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.35,
            ),
            itemCount: genres.length,
            itemBuilder: (context, index) {
              final genre = genres[index];
              final genreSongs = genresMap[genre]!;

              final int hash = genre.hashCode;
              final double hue = (hash.abs() % 360).toDouble();
              final Color startColor = HSLColor.fromAHSL(
                1.0,
                hue,
                0.70,
                0.35,
              ).toColor();
              final Color endColor = HSLColor.fromAHSL(
                1.0,
                (hue + 45) % 360,
                0.80,
                0.18,
              ).toColor();

              final firstSongWithArt = genreSongs.firstWhere(
                (s) => s.artPath != null,
                orElse: () => genreSongs.first,
              );

              final double artSize = (cardWidth * 0.40).clamp(90.0, 170.0);

              return InkWell(
                onTap: () {
                  final firstWithArt = genreSongs.firstWhere(
                    (s) => s.artPath != null,
                    orElse: () => genreSongs.first,
                  );
                  ref
                      .read(appNavigationProvider.notifier)
                      .showCollection(
                        title: genre,
                        subtitle: l10n.genre,
                        art: firstWithArt.artPath,
                        songs: genreSongs,
                      );
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [startColor, endColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      if (firstSongWithArt.artPath != null)
                        Positioned(
                          bottom: -artSize * 0.2,
                          right: -artSize * 0.2,
                          child: Transform.rotate(
                            angle: 0.25,
                            child: Container(
                              width: artSize,
                              height: artSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: OptimizedImage(
                                  imagePath: firstSongWithArt.artPath,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Positioned(
                          bottom: -artSize * 0.17,
                          right: -artSize * 0.17,
                          child: Transform.rotate(
                            angle: 0.25,
                            child: Container(
                              width: artSize,
                              height: artSize,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                LucideIcons.music,
                                size: artSize * 0.47,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 16,
                        top: 16,
                        bottom: 16,
                        right: artSize + 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              genre,
                              style: AppFonts.jostStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${genreSongs.length} ${l10n.songs}',
                              style: AppFonts.jostStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _GridSortOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _GridSortOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
    );
  }
}
