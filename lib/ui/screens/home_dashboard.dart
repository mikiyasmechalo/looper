import 'package:flutter/material.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:looper_player/ui/widgets/global_playing_indicator.dart';
import 'package:looper_player/features/library/presentation/library_grids.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/color_maper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:isar/isar.dart';

class DashboardGenresData {
  final List<String> sortedGenres;
  final Map<String, List<Song>> genresMap;
  DashboardGenresData({required this.sortedGenres, required this.genresMap});
}

final dashboardGenresDataProvider = Provider.autoDispose<DashboardGenresData>((
  ref,
) {
  final songs = ref.watch(libraryProvider.select((l) => l.songs));
  final genresMap = <String, List<Song>>{};
  for (var song in songs) {
    final genre = song.genre ?? 'Unknown';
    genresMap.putIfAbsent(genre, () => []).add(song);
  }
  final genres = genresMap.keys.toList()..sort();
  return DashboardGenresData(sortedGenres: genres, genresMap: genresMap);
});

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final bool isDynamic = settings.enableDynamicTheming;
    final library = ref.watch(libraryProvider);
    final l10n = AppLocalizations.of(context)!;

    final genresData = ref.watch(dashboardGenresDataProvider);
    final genres = genresData.sortedGenres;
    final genresMap = genresData.genresMap;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 600;
        final bool isMedium = constraints.maxWidth < 1000;
        final bool showLogo = MediaQuery.of(context).size.width < 800;

        final orderedChildren = <Widget>[];

        if (showLogo) {
          orderedChildren.add(
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50.s,
                  child: SvgPicture.asset(
                    'assets/main_logo_transparent.svg',
                    fit: BoxFit.contain,
                    colorMapper: AccentColorMapper(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }

        // Support desktop-specific helper rows at the very top
        orderedChildren.add(
          _buildRecentlyPlayed(context, ref, isNarrow, isDynamic),
        );
        orderedChildren.add(const SizedBox(height: 16));
        orderedChildren.add(
          _buildAlbumsIfSmall(context, ref, isNarrow, isDynamic),
        );
        orderedChildren.add(const SizedBox(height: 16));

        // Render sections dynamically in user's customized order
        for (final section in settings.homeSectionOrder) {
          if (section == 'quick_picks') {
            orderedChildren.add(
              _buildQuickPicks(context, ref, isNarrow, isMedium, isDynamic),
            );
            orderedChildren.add(const SizedBox(height: 16));
          } else if (section == 'songs') {
            orderedChildren.add(_buildTopArtists(context, ref, isNarrow));
            orderedChildren.add(const SizedBox(height: 16));
            orderedChildren.add(
              _buildFeaturedAlbums(ref, isNarrow, isDynamic, context),
            );
            orderedChildren.add(const SizedBox(height: 16));
          } else if (section == 'albums') {
            if (settings.showHomeAlbums && library.albums.isNotEmpty) {
              orderedChildren.add(
                _buildDesktopHorizontalSection(
                  context,
                  title: 'Albums',
                  onViewAll: () => ref
                      .read(appNavigationProvider.notifier)
                      .setItem(NavItem.albums),
                  itemCount: library.albums.length,
                  isNarrow: isNarrow,
                  itemBuilder: (context, index) {
                    return _buildDesktopAlbumItem(
                      ref,
                      library.albums[index],
                      l10n,
                    );
                  },
                ),
              );
              orderedChildren.add(const SizedBox(height: 16));
            }
          } else if (section == 'genres') {
            if (settings.showHomeGenres && genres.isNotEmpty) {
              orderedChildren.add(
                _buildDesktopHorizontalSection(
                  context,
                  title: 'Genres',
                  onViewAll: () => ref
                      .read(appNavigationProvider.notifier)
                      .setItem(NavItem.genres),
                  itemCount: genres.length,
                  isNarrow: isNarrow,
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    return _buildDesktopGenreItem(
                      ref,
                      genre,
                      genresMap[genre]!,
                      l10n,
                    );
                  },
                ),
              );
              orderedChildren.add(const SizedBox(height: 16));
            }
          }
        }

        orderedChildren.add(const SizedBox(height: 120));

        return ListView(
          padding: EdgeInsets.only(
            top: (isNarrow ? 4 : 8).s,
            left: (isNarrow ? 16 : 32).s,
            right: (isNarrow ? 16 : 32).s,
          ),
          children: orderedChildren,
        );
      },
    );
  }

  Widget _buildAlbumsIfSmall(
    BuildContext context,
    WidgetRef ref,
    bool isNarrow,
    bool isDynamic,
  ) {
    final albums = ref.watch(albumsProvider).value ?? [];
    if (albums.length >= 6 || albums.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, title: 'My Albums', isNarrow: isNarrow),
        const SizedBox(height: 16),
        SizedBox(
          height: isNarrow ? 174 : 196,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
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
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: isNarrow ? 120 : 140,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OptimizedImage(
                          imagePath: album.artPath,
                          height: isNarrow ? 104 : 124,
                          width: isNarrow ? 104 : 124,
                          borderRadius: BorderRadius.circular(12),
                          placeholder: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(
                                alpha: isDynamic ? 0.8 : 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(child: Icon(LucideIcons.disc)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          album.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          album.artist ?? 'Unknown',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyPlayed(
    BuildContext context,
    WidgetRef ref,
    bool isNarrow,
    bool isDynamic,
  ) {
    final recentSongs = ref.watch(recentlyPlayedProvider).value ?? [];

    if (recentSongs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: 'Recently Played',
          isNarrow: isNarrow,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: isNarrow ? 172 : 192,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentSongs.length.clamp(0, 10),
            itemBuilder: (context, index) {
              final song = recentSongs[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () => ref.read(playbackProvider.notifier).play(song),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: isNarrow ? 120 : 140,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OptimizedImage(
                          imagePath: song.artPath,
                          height: isNarrow ? 104 : 124,
                          width: isNarrow ? 104 : 124,
                          borderRadius: BorderRadius.circular(12),
                          placeholder: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(
                                alpha: isDynamic ? 0.8 : 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(child: Icon(LucideIcons.music)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song.artist ?? 'Unknown',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPicks(
    BuildContext context,
    WidgetRef ref,
    bool isNarrow,
    bool isMedium,
    bool isDynamic,
  ) {
    final topSongsAsync = ref.watch(topSongsProvider);

    return topSongsAsync.when(
      data: (songs) {
        if (songs.isEmpty) return const SizedBox.shrink();

        int crossAxisCount = 4;
        if (isNarrow) {
          crossAxisCount = 2;
        } else if (isMedium) {
          crossAxisCount = 3;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              title: 'Quick Picks',
              isNarrow: isNarrow,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisExtent: 70,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                final isCurrent = ref.watch(
                  playbackProvider.select(
                    (s) => s.currentSong?.path == song.path,
                  ),
                );
                final isPlaying = ref.watch(
                  playbackProvider.select((s) => s.isPlaying),
                );

                return InkWell(
                  onTap: () => ref.read(playbackProvider.notifier).play(song),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        PlayingOverlay(
                          isPlaying: isCurrent && isPlaying,
                          borderRadius: 4,
                          child: OptimizedImage(
                            imagePath: song.artPath,
                            width: 54,
                            height: 54,
                            borderRadius: BorderRadius.circular(4),
                            placeholder: const Icon(
                              LucideIcons.music,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                song.artist ?? 'Unknown',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white38,
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
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildTopArtists(BuildContext context, WidgetRef ref, bool isNarrow) {
    final artistsAsync = ref.watch(artistsProvider);
    final allSongs = ref.watch(libraryProvider.select((s) => s.songs));

    return artistsAsync.when(
      data: (artists) {
        if (artists.isEmpty) return const SizedBox.shrink();

        final playCounts = <String, int>{};
        for (final song in allSongs) {
          final names = <String>{};
          if (song.artist != null) names.add(song.artist!);
          if (song.albumArtist != null) names.add(song.albumArtist!);
          for (final name in names) {
            playCounts[name] = (playCounts[name] ?? 0) + song.playCount;
          }
        }

        final sorted = List<Artist>.from(artists)
          ..sort((a, b) => (playCounts[b.name] ?? 0).compareTo(playCounts[a.name] ?? 0));
        final featuredArtists = sorted.take(10).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              title: 'Artists',
              isNarrow: isNarrow,
              onViewAll: () => ref
                  .read(appNavigationProvider.notifier)
                  .setItem(NavItem.artists),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: isNarrow ? 140 : 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredArtists.length,
                itemBuilder: (context, index) {
                  final artist = featuredArtists[index];
                  return Container(
                    width: isNarrow ? 120 : 140,
                    margin: const EdgeInsets.only(right: 16),
                    child: InkWell(
                      onTap: () async {
                        final songs = await DbService.isar.songs
                            .filter()
                            .artistEqualTo(artist.name)
                            .or()
                            .albumArtistEqualTo(artist.name)
                            .findAll();
                        ref
                            .read(appNavigationProvider.notifier)
                            .showCollection(
                              title: artist.name,
                              subtitle: 'Artist',
                              art: artist.artPath,
                              imageUrl: artist.artistImageUrl,
                              songs: songs,
                              highlightItem: NavItem.artists,
                            );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: isNarrow ? 100 : 120,
                            height: isNarrow ? 100 : 120,
                            child: ClipOval(
                              child: OptimizedImage(
                                imageUrl: artist.artistImageUrl,
                                imagePath: artist.artPath,
                                fit: BoxFit.cover,
                                placeholder: Container(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  child: const Center(
                                    child: Icon(
                                      LucideIcons.user,
                                      size: 32,
                                      color: Colors.white38,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              artist.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildFeaturedAlbums(
    WidgetRef ref,
    bool isNarrow,
    bool isDynamic,
    BuildContext context,
  ) {
    final albumsAsync = ref.watch(albumsProvider);
    final l10n = AppLocalizations.of(context)!;

    return albumsAsync.when(
      data: (albums) {
        if (albums.isEmpty) return const SizedBox.shrink();

        final featuredAlbums = albums.take(10).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              title: l10n.albums,
              isNarrow: isNarrow,
              onViewAll: () => ref
                  .read(appNavigationProvider.notifier)
                  .setItem(NavItem.albums),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: isNarrow ? 150 : 170,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredAlbums.length,
                itemBuilder: (context, index) {
                  final album = featuredAlbums[index];
                  return Container(
                    width: isNarrow ? 120 : 140,
                    margin: const EdgeInsets.only(right: 16),
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
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: OptimizedImage(
                              imagePath: album.artPath,
                              height: isNarrow ? 104 : 124,
                              width: isNarrow ? 104 : 124,
                              fit: BoxFit.cover,
                              placeholder: Container(
                                color: Colors.white.withValues(alpha: 0.05),
                                child: const Center(
                                  child: Icon(
                                    LucideIcons.disc,
                                    size: 32,
                                    color: Colors.white38,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              album.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              album.artist ?? 'Unknown',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required bool isNarrow,
    VoidCallback? onViewAll,
  }) {
    final accentColor = Theme.of(context).colorScheme.primary;
    final header = Text(
      title,
      style: TextStyle(
        fontSize: (isNarrow ? 18 : 24).ts,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
    if (onViewAll == null) return header;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        header,
        TextButton(
          onPressed: onViewAll,
          child: Row(
            children: [
              Text(
                'View All',
                style: TextStyle(color: accentColor, fontSize: 13),
              ),
              const SizedBox(width: 4),
              Icon(LucideIcons.chevronRight, size: 16, color: accentColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHorizontalSection(
    BuildContext context, {
    required String title,
    required VoidCallback onViewAll,
    required int itemCount,
    required bool isNarrow,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    if (itemCount == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: title,
          isNarrow: isNarrow,
          onViewAll: onViewAll,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopAlbumItem(
    WidgetRef ref,
    Album album,
    AppLocalizations l10n,
  ) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 16),
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
                subtitle: album.artist ?? l10n.unknownArtist,
                art: album.artPath,
                songs: songs,
                highlightItem: NavItem.albums,
              );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: OptimizedImage(
                  imagePath: album.artPath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              album.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              album.artist ?? l10n.unknownArtist,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopGenreItem(
    WidgetRef ref,
    String genre,
    List<Song> genreSongs,
    AppLocalizations l10n,
  ) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {
          ref
              .read(appNavigationProvider.notifier)
              .showCollection(
                title: genre,
                subtitle: l10n.genre,
                songs: genreSongs,
              );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.music, color: Colors.blueAccent, size: 28),
              const SizedBox(height: 10),
              Text(
                genre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${genreSongs.length} ${l10n.songs}',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
