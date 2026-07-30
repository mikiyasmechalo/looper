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

class AlbumsGrid extends ConsumerWidget {
  const AlbumsGrid({super.key});

  List<Album> _sort(List<Album> albums, AlbumSortOption opt) {
    final list = List<Album>.from(albums);
    switch (opt) {
      case AlbumSortOption.nameAsc:
        list.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      case AlbumSortOption.nameDesc:
        list.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
      case AlbumSortOption.dateAddedNewest:
        list.sort(
          (a, b) => (b.dateAdded ?? DateTime(0)).compareTo(
            a.dateAdded ?? DateTime(0),
          ),
        );
      case AlbumSortOption.dateAddedOldest:
        list.sort(
          (a, b) => (a.dateAdded ?? DateTime(0)).compareTo(
            b.dateAdded ?? DateTime(0),
          ),
        );
      case AlbumSortOption.yearNewest:
        list.sort((a, b) => (b.year ?? 0).compareTo(a.year ?? 0));
      case AlbumSortOption.yearOldest:
        list.sort((a, b) => (a.year ?? 0).compareTo(b.year ?? 0));
    }
    return list;
  }

  String _sortLabel(AlbumSortOption opt, AppLocalizations l10n) =>
      switch (opt) {
        AlbumSortOption.nameAsc => l10n.sortAlphabeticalAZ,
        AlbumSortOption.nameDesc => l10n.sortAlphabeticalZA,
        AlbumSortOption.dateAddedNewest => l10n.sortRecentlyAdded,
        AlbumSortOption.dateAddedOldest => l10n.sortOldestAdded,
        AlbumSortOption.yearNewest => l10n.sortYearNewest,
        AlbumSortOption.yearOldest => l10n.sortYearOldest,
      };

  void _showSortMenu(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppBottomSheetContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.sortBy,
              style: AppFonts.jostStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            for (final opt in AlbumSortOption.values)
              _SortItem(
                label: _sortLabel(opt, l10n),
                value: opt,
                provider: albumSortProvider,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(albumsProvider);
    final sortOpt = ref.watch(albumSortProvider);
    final l10n = AppLocalizations.of(context)!;

    return albumsAsync.when(
      data: (raw) {
        final albums = _sort(raw, sortOpt);
        return Column(
          children: [
            // Sort toolbar
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
                    onPressed: () => _showSortMenu(context, ref, l10n),
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

    return InkWell(
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
    );
  }
}

class ArtistsGrid extends ConsumerWidget {
  const ArtistsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDynamic = ref.watch(settingsProvider).enableDynamicTheming;
    final artistsAsync = ref.watch(artistsProvider);

    return artistsAsync.when(
      data: (artists) => GridView.builder(
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

    return InkWell(
      onTap: () async {
        final songs = await DbService.isar.songs
            .filter()
            .artistEqualTo(artist.name)
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
