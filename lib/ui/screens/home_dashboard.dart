import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:looper_player/core/ui_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/ui/widgets/artist_image.dart';
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
import 'package:looper_player/ui/widgets/collection_options_bottom_sheet.dart';
import 'package:looper_player/ui/widgets/song_options_bottom_sheet.dart';
import 'package:looper_player/features/library/data/recommendations_service.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:isar/isar.dart';

import 'package:looper_player/features/playlists/presentation/smart_playlists_provider.dart';
import 'package:looper_player/features/playlists/data/smart_playlist_service.dart';

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
    final genre = song.genre?.trim();
    final effectiveGenre = (genre == null || genre.isEmpty) ? 'Unknown' : genre;
    genresMap.putIfAbsent(effectiveGenre, () => []).add(song);
  }
  final genres = genresMap.keys.toList()
    ..sort((a, b) {
      final aPlayCount = genresMap[a]!.fold<int>(0, (sum, s) => sum + s.playCount);
      final bPlayCount = genresMap[b]!.fold<int>(0, (sum, s) => sum + s.playCount);
      final cmp = bPlayCount.compareTo(aPlayCount);
      if (cmp != 0) return cmp;
      return genresMap[b]!.length.compareTo(genresMap[a]!.length);
    });
  return DashboardGenresData(
    sortedGenres: genres.take(10).toList(),
    genresMap: genresMap,
  );
});

/// Albums sorted by total play count (most played first) for the home screen's
/// "top albums" preview.
final topAlbumsProvider = Provider<List<Album>>((ref) {
  final songs = ref.watch(libraryProvider.select((l) => l.songs));
  final albums = ref.watch(libraryProvider.select((l) => l.albums));
  final counts = <String, int>{};
  for (final song in songs) {
    if (song.album != null && song.album!.isNotEmpty) {
      counts[song.album!] = (counts[song.album!] ?? 0) + song.playCount;
    }
  }
  final sorted = List<Album>.from(albums)
    ..sort((a, b) => (counts[b.name] ?? 0).compareTo(counts[a.name] ?? 0));
  return sorted;
});

/// Stable per-app-run seed so the random slice of the quick picks stays fixed
/// for the whole session. Without this, any provider recompute reshuffles the
/// random pool and the section visibly changes every time the library emits.
/// Mixed quick picks for the home dashboard: most played, recently added,
/// favorites, and a random selection, deduplicated.
final homeQuickPicksMixProvider = Provider<List<Song>>((ref) {
  final isScanning = ref.watch(libraryProvider.select((l) => l.isScanning));
  final allSongs = ref.watch(libraryProvider.select((l) => l.songs));

  if (allSongs.isEmpty) {
    RecommendationsService.clearQuickPicksCache();
    return const [];
  }

  final cached = RecommendationsService.cachedQuickPicks;
  if (isScanning && cached != null && cached.isNotEmpty) {
    final allSongPaths = allSongs.map((s) => s.path).toSet();
    if (cached.every((s) => allSongPaths.contains(s.path))) {
      return cached;
    }
  }

  if (isScanning && (cached == null || cached.isEmpty)) {
    return const [];
  }

  return RecommendationsService.getDashboardQuickPicks(allSongs);
});

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final bool isDynamic = settings.enableDynamicTheming;
    final l10n = AppLocalizations.of(context)!;

    final genresData = ref.watch(dashboardGenresDataProvider);
    final genres = genresData.sortedGenres;
    final genresMap = genresData.genresMap;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 600;
        final bool isMedium = constraints.maxWidth < 1000;
        final bool showLogo = MediaQuery.of(context).size.width < 560;

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

        // Render sections dynamically in user's customized order
        for (final section in settings.homeSectionOrder) {
          if (section == 'recently_played') {
            if (settings.showHomeRecentlyPlayed) {
              orderedChildren.add(
                _buildRecentlyPlayed(context, ref, isNarrow, isDynamic),
              );
              orderedChildren.add(const SizedBox(height: 16));
            }
          } else if (section == 'quick_picks') {
            if (settings.showHomeQuickPicks) {
              orderedChildren.add(
                _buildQuickPicks(context, ref, isNarrow, isMedium),
              );
              orderedChildren.add(const SizedBox(height: 16));
            }
          } else if (section == 'top_songs') {
            if (settings.showHomeTopSongs) {
              orderedChildren.add(
                _buildTopSongs(context, ref, isNarrow),
              );
              orderedChildren.add(const SizedBox(height: 16));
            }
          } else if (section == 'artists') {
            if (settings.showHomeArtists) {
              orderedChildren.add(_buildTopArtists(context, ref, isNarrow));
              orderedChildren.add(const SizedBox(height: 16));
            }
          } else if (section == 'albums') {
            if (settings.showHomeAlbums) {
              orderedChildren.add(
                _buildFeaturedAlbums(ref, isNarrow, isDynamic, context),
              );
              orderedChildren.add(const SizedBox(height: 16));
            }
          } else if (section == 'genres') {
            if (settings.showHomeGenres && genres.isNotEmpty) {
              orderedChildren.add(
                _buildDesktopHorizontalSection(
                  context,
                  title: 'Top Genres',
                  height: 140,
                  onViewAll: () => ref
                      .read(appNavigationProvider.notifier)
                      .setItem(NavItem.genres),
                  onShuffle: () {
                    final allGenreSongs = <Song>[];
                    for (final g in genres) {
                      final list = genresMap[g];
                      if (list != null) allGenreSongs.addAll(list);
                    }
                    if (allGenreSongs.isNotEmpty) {
                      ref
                          .read(playbackProvider.notifier)
                          .playShuffled(allGenreSongs, queueName: 'Top Genres');
                    }
                  },
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
          } else if (section == 'newly_added') {
            if (settings.showHomeNewlyAdded) {
              orderedChildren.add(
                _buildNewlyAdded(context, ref, isNarrow),
              );
              orderedChildren.add(const SizedBox(height: 16));
            }
          } else if (section == 'rediscover') {
            if (settings.showHomeRediscover) {
              orderedChildren.add(
                _buildRediscover(context, ref, isNarrow),
              );
              orderedChildren.add(const SizedBox(height: 16));
            }
          } else if (section == 'songs') {
            // Backwards compatibility fallback for older customized orders
            if (settings.showHomeArtists) {
              orderedChildren.add(_buildTopArtists(context, ref, isNarrow));
              orderedChildren.add(const SizedBox(height: 16));
            }
            if (settings.showHomeAlbums) {
              orderedChildren.add(
                _buildFeaturedAlbums(ref, isNarrow, isDynamic, context),
              );
              orderedChildren.add(const SizedBox(height: 16));
            }
          }
        }

        orderedChildren.add(const SizedBox(height: 24));

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
          onViewAll: () => ref
              .read(appNavigationProvider.notifier)
              .setItem(NavItem.recentlyPlayed),
          onShuffle: () {
            ref
                .read(playbackProvider.notifier)
                .playShuffled(recentSongs, queueName: 'Recently Played');
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: isNarrow ? 172 : 192,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentSongs.length.clamp(0, 30),
            itemBuilder: (context, index) {
              final song = recentSongs[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => ref.read(playbackProvider.notifier).setPlaylist(
                      recentSongs,
                      initialIndex: index,
                      queueName: 'Recently Played',
                    ),
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
                              child: const Center(
                                child: Icon(LucideIcons.music),
                              ),
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
                            song.album != null && song.album!.isNotEmpty
                                ? '${song.artist ?? 'Unknown'} · ${song.album}'
                                : (song.artist ?? 'Unknown'),
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
  ) {
    final songs = ref.watch(homeQuickPicksMixProvider);

    if (songs.isEmpty) return const SizedBox.shrink();

    final displaySongs = songs.length > RecommendationsService.quickPicksCount
        ? songs.sublist(0, RecommendationsService.quickPicksCount)
        : songs;

    int crossAxisCount = 4;
    if (isNarrow) {
      crossAxisCount = 2;
    } else if (isMedium) {
      crossAxisCount = 3;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeDashboard._buildSectionHeader(
          context,
          title: 'Quick Picks',
          isNarrow: isNarrow,
          onShuffle: () {
            final notifier = ref.read(playbackProvider.notifier);
            notifier.playShuffled(
              RecommendationsService.buildQuickPicksQueue(
                ref.read(libraryProvider.select((l) => l.songs)),
                count: 100,
              ),
              queueName: 'Quick Picks',
            );
          },
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
          itemCount: displaySongs.length,
          itemBuilder: (context, index) {
            final song = displaySongs[index];
            final isCurrent = ref.watch(
              playbackProvider.select((s) => s.currentSong?.path == song.path),
            );
            final isPlaying = ref.watch(
              playbackProvider.select((s) => s.isPlaying),
            );

            return GestureDetector(
              onSecondaryTap: () => showSongOptionsBottomSheet(
                context: context,
                ref: ref,
                song: song,
              ),
              child: Material(
                color: Colors.transparent,
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () {
                    final allSongs = ref.read(libraryProvider.select((l) => l.songs));
                    final fullQuickPicks = RecommendationsService.buildQuickPicksQueue(
                      allSongs,
                      count: 100,
                      random: math.Random(RecommendationsService.quickPicksSessionSeed),
                    );
                    final targetIndex = fullQuickPicks.indexWhere((s) => s.path == song.path);
                    ref.read(playbackProvider.notifier).setPlaylist(
                      fullQuickPicks,
                      initialIndex: targetIndex != -1 ? targetIndex : 0,
                      queueName: 'Quick Picks',
                    );
                  },
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
                                song.album != null && song.album!.isNotEmpty
                                    ? '${song.artist ?? 'Unknown'} · ${song.album}'
                                    : (song.artist ?? 'Unknown'),
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
                ),
              ),
            );
          },
        ),
      ],
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
          ..sort(
            (a, b) =>
                (playCounts[b.name] ?? 0).compareTo(playCounts[a.name] ?? 0),
          );
        final featuredArtists = sorted.take(10).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              title: 'Top Artists',
              isNarrow: isNarrow,
              onViewAll: () => ref
                  .read(appNavigationProvider.notifier)
                  .setItem(NavItem.artists),
              onShuffle: () {
                final artistNames = featuredArtists.map((a) => a.name).toSet();
                final songs = allSongs.where((s) =>
                  (s.artist != null && artistNames.contains(s.artist)) ||
                  (s.albumArtist != null && artistNames.contains(s.albumArtist))
                ).toList();
                if (songs.isNotEmpty) {
                  ref.read(playbackProvider.notifier).playShuffled(songs, queueName: 'Top Artists');
                }
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: isNarrow ? 165 : 195,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredArtists.length,
                itemBuilder: (context, index) {
                  return _HomeTopArtistCard(
                    artist: featuredArtists[index],
                    isNarrow: isNarrow,
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
    final topAlbums = ref.watch(topAlbumsProvider);
    final l10n = AppLocalizations.of(context)!;

    return albumsAsync.when(
      data: (albums) {
        if (albums.isEmpty) return const SizedBox.shrink();

        final featuredAlbums = topAlbums.take(10).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              title: "Top Albums",
              isNarrow: isNarrow,
              onViewAll: () => ref
                  .read(appNavigationProvider.notifier)
                  .setItem(NavItem.albums),
              onShuffle: () {
                final albumNames = featuredAlbums.map((a) => a.name).toSet();
                final allSongs = ref.read(libraryProvider.select((l) => l.songs));
                final songs = allSongs.where((s) => s.album != null && albumNames.contains(s.album)).toList();
                if (songs.isNotEmpty) {
                  ref.read(playbackProvider.notifier).playShuffled(songs, queueName: 'Top Albums');
                }
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: isNarrow ? 186 : 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredAlbums.length,
                itemBuilder: (context, index) {
                  return _HomeTopAlbumCard(
                    album: featuredAlbums[index],
                    isNarrow: isNarrow,
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

  static Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required bool isNarrow,
    VoidCallback? onViewAll,
    VoidCallback? onShuffle,
  }) {
    final accentColor = Theme.of(context).colorScheme.primary;
    final header = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: (isNarrow ? 18 : 24).ts,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (onShuffle != null) ...[
          const SizedBox(width: 8),
          _SectionShuffleButton(color: accentColor, onPressed: onShuffle),
        ],
      ],
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
    VoidCallback? onShuffle,
    double height = 180,
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
          onShuffle: onShuffle,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: height,
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
    BuildContext context,
    WidgetRef ref,
    Album album,
    AppLocalizations l10n,
  ) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onSecondaryTap: () => showAlbumOptionsBottomSheet(
          context: context,
          ref: ref,
          album: album,
        ),
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                      width: 140,
                      height: 140,
                      cacheWidth: 256,
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

    const double artSize = 85.0;

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
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
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          onTap: () {
            ref.read(appNavigationProvider.notifier).showCollection(
                  title: genre,
                  subtitle: l10n.genre,
                  art: firstSongWithArt.artPath,
                  songs: genreSongs,
                  highlightItem: NavItem.genres,
                );
          },
          borderRadius: BorderRadius.circular(24),
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
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: OptimizedImage(
                          imagePath: firstSongWithArt.artPath,
                          width: artSize,
                          height: artSize,
                          cacheWidth: 256,
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
                      child: const Icon(
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
                right: artSize + 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      genre,
                      style: AppFonts.jostStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${genreSongs.length} ${l10n.songs}',
                      style: AppFonts.jostStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
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

  Widget _buildTopSongs(BuildContext context, WidgetRef ref, bool isNarrow) {
    final topSongsAsync = ref.watch(topSongsProvider);

    return topSongsAsync.when(
      data: (songs) {
        if (songs.isEmpty) return const SizedBox.shrink();
        final displaySongs = songs.take(15).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              title: 'Top Songs',
              isNarrow: isNarrow,
              onViewAll: () {
                final smartPlaylists = ref.read(smartPlaylistsProvider).value ?? [];
                final topPlaylist = smartPlaylists.where((p) => p.id == 'top_played').firstOrNull;
                if (topPlaylist != null) {
                  ref.read(appNavigationProvider.notifier).showCollection(
                    title: topPlaylist.title,
                    subtitle: 'Smart Playlist',
                    songs: topPlaylist.songs,
                    highlightItem: NavItem.playlists,
                  );
                } else {
                  final allSongs = ref.read(libraryProvider.select((l) => l.songs));
                  final computed = SmartPlaylistService.computeTopPlayed(allSongs);
                  if (computed != null) {
                    ref.read(appNavigationProvider.notifier).showCollection(
                      title: computed.title,
                      subtitle: 'Smart Playlist',
                      songs: computed.songs,
                      highlightItem: NavItem.playlists,
                    );
                  }
                }
              },
              onShuffle: () {
                ref
                    .read(playbackProvider.notifier)
                    .playShuffled(displaySongs, queueName: 'Top Songs');
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: isNarrow ? 208 : 228,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: displaySongs.length,
                itemBuilder: (context, index) {
                  final song = displaySongs[index];
                  final isCurrent = ref.watch(
                    playbackProvider.select((s) => s.currentSong?.path == song.path),
                  );
                  final isPlaying = ref.watch(
                    playbackProvider.select((s) => s.isPlaying),
                  );

                  // Rank Badge styling
                  Color badgeBg;
                  Color badgeTextColor = Colors.white;
                  if (index == 0) {
                    badgeBg = const Color(0xFFE5A93C); // Gold
                    badgeTextColor = Colors.black87;
                  } else if (index == 1) {
                    badgeBg = const Color(0xFF9E9E9E); // Silver
                    badgeTextColor = Colors.black87;
                  } else if (index == 2) {
                    badgeBg = const Color(0xFFCD7F32); // Bronze
                    badgeTextColor = Colors.white;
                  } else {
                    badgeBg = Theme.of(context).colorScheme.primary.withValues(alpha: 0.85);
                  }

                  return Container(
                    width: isNarrow ? 140 : 160,
                    margin: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onSecondaryTap: () => showSongOptionsBottomSheet(
                        context: context,
                        ref: ref,
                        song: song,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        clipBehavior: Clip.hardEdge,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () {
                            ref.read(playbackProvider.notifier).setPlaylist(
                              displaySongs,
                              initialIndex: index,
                              queueName: 'Top Songs',
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: PlayingOverlay(
                                        isPlaying: isCurrent && isPlaying,
                                        borderRadius: 14,
                                        child: OptimizedImage(
                                          imagePath: song.artPath,
                                          height: isNarrow ? 124 : 144,
                                          width: isNarrow ? 124 : 144,
                                          fit: BoxFit.cover,
                                          placeholder: Container(
                                            color: Colors.white.withValues(alpha: 0.05),
                                            child: const Center(
                                              child: Icon(
                                                LucideIcons.music,
                                                size: 28,
                                                color: Colors.white38,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Rank Number Badge
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: badgeBg,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.4),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          '#${index + 1}',
                                          style: TextStyle(
                                            color: badgeTextColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  song.artist ?? 'Unknown',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.flame,
                                      size: 12,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${song.playCount} plays',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildNewlyAdded(BuildContext context, WidgetRef ref, bool isNarrow) {
    final newlyAddedAsync = ref.watch(newlyAddedSongsProvider);

    return newlyAddedAsync.when(
      data: (songs) {
        if (songs.isEmpty) return const SizedBox.shrink();
        final displaySongs = songs.take(15).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              title: 'Newly Added',
              isNarrow: isNarrow,
              onViewAll: () {
                final smartPlaylists = ref.read(smartPlaylistsProvider).value ?? [];
                final recentPlaylist = smartPlaylists.where((p) => p.id == 'recently_added').firstOrNull;
                if (recentPlaylist != null) {
                  ref.read(appNavigationProvider.notifier).showCollection(
                    title: recentPlaylist.title,
                    subtitle: 'Smart Playlist',
                    songs: recentPlaylist.songs,
                    highlightItem: NavItem.playlists,
                  );
                } else {
                  final allSongs = ref.read(libraryProvider.select((l) => l.songs));
                  final computed = SmartPlaylistService.computeRecentlyAdded(allSongs);
                  if (computed != null) {
                    ref.read(appNavigationProvider.notifier).showCollection(
                      title: computed.title,
                      subtitle: 'Smart Playlist',
                      songs: computed.songs,
                      highlightItem: NavItem.playlists,
                    );
                  }
                }
              },
              onShuffle: () {
                ref
                    .read(playbackProvider.notifier)
                    .playShuffled(displaySongs, queueName: 'Newly Added');
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: isNarrow ? 178 : 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: displaySongs.length,
                itemBuilder: (context, index) {
                  final song = displaySongs[index];
                  final isCurrent = ref.watch(
                    playbackProvider.select((s) => s.currentSong?.path == song.path),
                  );
                  final isPlaying = ref.watch(
                    playbackProvider.select((s) => s.isPlaying),
                  );

                  return Container(
                    width: isNarrow ? 132 : 152,
                    margin: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onSecondaryTap: () => showSongOptionsBottomSheet(
                        context: context,
                        ref: ref,
                        song: song,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        clipBehavior: Clip.hardEdge,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () {
                            ref.read(playbackProvider.notifier).setPlaylist(
                              displaySongs,
                              initialIndex: index,
                              queueName: 'Newly Added',
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: PlayingOverlay(
                                    isPlaying: isCurrent && isPlaying,
                                    borderRadius: 14,
                                    child: OptimizedImage(
                                      imagePath: song.artPath,
                                      height: isNarrow ? 116 : 136,
                                      width: isNarrow ? 116 : 136,
                                      fit: BoxFit.cover,
                                      placeholder: Container(
                                        color: Colors.white.withValues(alpha: 0.05),
                                        child: const Center(
                                          child: Icon(
                                            LucideIcons.music,
                                            size: 28,
                                            color: Colors.white38,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  song.artist ?? 'Unknown',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildRediscover(BuildContext context, WidgetRef ref, bool isNarrow) {
    final rediscoverAsync = ref.watch(rediscoverSongsProvider);

    return rediscoverAsync.when(
      data: (songs) {
        if (songs.isEmpty) return const SizedBox.shrink();
        final displaySongs = songs.take(15).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              title: 'Rediscover',
              isNarrow: isNarrow,
              onShuffle: () {
                ref
                    .read(playbackProvider.notifier)
                    .playShuffled(displaySongs, queueName: 'Rediscover');
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: isNarrow ? 178 : 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: displaySongs.length,
                itemBuilder: (context, index) {
                  final song = displaySongs[index];
                  final isCurrent = ref.watch(
                    playbackProvider.select((s) => s.currentSong?.path == song.path),
                  );
                  final isPlaying = ref.watch(
                    playbackProvider.select((s) => s.isPlaying),
                  );

                  return Container(
                    width: isNarrow ? 132 : 152,
                    margin: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onSecondaryTap: () => showSongOptionsBottomSheet(
                        context: context,
                        ref: ref,
                        song: song,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        clipBehavior: Clip.hardEdge,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () {
                            ref.read(playbackProvider.notifier).setPlaylist(
                              displaySongs,
                              initialIndex: index,
                              queueName: 'Rediscover',
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: PlayingOverlay(
                                    isPlaying: isCurrent && isPlaying,
                                    borderRadius: 14,
                                    child: OptimizedImage(
                                      imagePath: song.artPath,
                                      height: isNarrow ? 116 : 136,
                                      width: isNarrow ? 116 : 136,
                                      fit: BoxFit.cover,
                                      placeholder: Container(
                                        color: Colors.white.withValues(alpha: 0.05),
                                        child: const Center(
                                          child: Icon(
                                            LucideIcons.compass,
                                            size: 28,
                                            color: Colors.white38,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  song.artist ?? 'Unknown',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
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
}

class _SectionShuffleButton extends StatelessWidget {
  const _SectionShuffleButton({required this.color, required this.onPressed});

  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(LucideIcons.shuffle, size: 16, color: color),
        ),
      ),
    );
  }
}

class _HomeTopAlbumCard extends ConsumerStatefulWidget {
  final Album album;
  final bool isNarrow;

  const _HomeTopAlbumCard({required this.album, required this.isNarrow});

  @override
  ConsumerState<_HomeTopAlbumCard> createState() => _HomeTopAlbumCardState();
}

class _HomeTopAlbumCardState extends ConsumerState<_HomeTopAlbumCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final album = widget.album;
    final isNarrow = widget.isNarrow;
    final double artSize = isNarrow ? 124 : 148;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: isNarrow ? 140 : 164,
        margin: const EdgeInsets.only(right: 16),
        child: GestureDetector(
          onSecondaryTap: () => showAlbumOptionsBottomSheet(
            context: context,
            ref: ref,
            album: album,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.transparent,
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                mouseCursor: SystemMouseCursors.click,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                onTap: () async {
                  final songs = await DbService.isar.songs
                      .filter()
                      .albumEqualTo(album.name)
                      .findAll();
                  ref.read(appNavigationProvider.notifier).showCollection(
                        title: album.name,
                        subtitle: album.artist,
                        art: album.artPath,
                        songs: songs,
                        highlightItem: NavItem.albums,
                      );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: artSize,
                        height: artSize,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: OptimizedImage(
                                  imagePath: album.artPath,
                                  height: artSize,
                                  width: artSize,
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
                            ),
                            // Red heart badge (top right) - ditch black background, subtle shadow
                            if (album.isFavorite)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  Icons.favorite_rounded,
                                  size: isNarrow ? 16 : 18,
                                  color: Colors.redAccent,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 6,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            // Hover overlay with Play & Options
                            Positioned.fill(
                              child: AnimatedOpacity(
                                opacity: _isHovered ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 160),
                                curve: Curves.easeOutCubic,
                                child: IgnorePointer(
                                  ignoring: !_isHovered,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.35),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 8,
                                        bottom: 8,
                                        child: AnimatedSlide(
                                          offset: _isHovered ? Offset.zero : const Offset(0, 0.25),
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeOutCubic,
                                          child: AnimatedScale(
                                            scale: _isHovered ? 1.0 : 0.8,
                                            duration: const Duration(milliseconds: 200),
                                            curve: Curves.easeOutBack,
                                            child: Material(
                                              color: Colors.transparent,
                                              shape: const CircleBorder(),
                                              clipBehavior: Clip.antiAlias,
                                              child: InkWell(
                                                customBorder: const CircleBorder(),
                                                splashColor: Colors.white.withValues(alpha: 0.25),
                                                highlightColor: Colors.white.withValues(alpha: 0.15),
                                                onTap: () async {
                                                  final songs = await DbService.isar.songs
                                                      .filter()
                                                      .albumEqualTo(album.name)
                                                      .findAll();
                                                  if (songs.isNotEmpty) {
                                                    ref.read(playbackProvider.notifier).setPlaylist(
                                                          songs,
                                                          queueName: album.name,
                                                          disableShuffle: true,
                                                        );
                                                  }
                                                },
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha: 0.4),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Icon(
                                                    LucideIcons.play,
                                                    size: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 8,
                                        bottom: 8,
                                        child: Material(
                                          color: Colors.transparent,
                                          shape: const CircleBorder(),
                                          clipBehavior: Clip.antiAlias,
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            splashColor: Colors.white.withValues(alpha: 0.25),
                                            highlightColor: Colors.white.withValues(alpha: 0.15),
                                            onTap: () {
                                              showAlbumOptionsBottomSheet(
                                                context: context,
                                                ref: ref,
                                                album: album,
                                              );
                                            },
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.7),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white.withValues(alpha: 0.25),
                                                  width: 1,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.4),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                LucideIcons.moreHorizontal,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
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
                      const SizedBox(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTopArtistCard extends ConsumerStatefulWidget {
  final Artist artist;
  final bool isNarrow;

  const _HomeTopArtistCard({required this.artist, required this.isNarrow});

  @override
  ConsumerState<_HomeTopArtistCard> createState() => _HomeTopArtistCardState();
}

class _HomeTopArtistCardState extends ConsumerState<_HomeTopArtistCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final artist = widget.artist;
    final isNarrow = widget.isNarrow;
    final double artSize = isNarrow ? 120 : 145;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: isNarrow ? 140 : 165,
        margin: const EdgeInsets.only(right: 16),
        child: GestureDetector(
          onSecondaryTap: () => showArtistOptionsBottomSheet(
            context: context,
            ref: ref,
            artist: artist,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.transparent,
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                mouseCursor: SystemMouseCursors.click,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                onTap: () async {
                  final songs = await DbService.isar.songs
                      .filter()
                      .artistEqualTo(artist.name)
                      .or()
                      .albumArtistEqualTo(artist.name)
                      .findAll();
                  ref.read(appNavigationProvider.notifier).showCollection(
                        title: artist.name,
                        subtitle: 'Artist',
                        art: artist.artPath,
                        imageUrl: artist.artistImageUrl,
                        images: artist.artistImages,
                        songs: songs,
                        highlightItem: NavItem.artists,
                      );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: artSize,
                        height: artSize,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipOval(
                                child: ArtistImage(
                                  images: artist.artistImages,
                                  imageUrl: artist.artistImageUrl,
                                  imagePath: artist.artPath,
                                  width: artSize,
                                  height: artSize,
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
                            // Red heart badge (top right) - ditch black background, subtle shadow
                            if (artist.isFavorite)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Icon(
                                  Icons.favorite_rounded,
                                  size: isNarrow ? 16 : 18,
                                  color: Colors.redAccent,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 6,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            // Hover overlay with Play & Options
                            Positioned.fill(
                              child: AnimatedOpacity(
                                opacity: _isHovered ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 160),
                                curve: Curves.easeOutCubic,
                                child: IgnorePointer(
                                  ignoring: !_isHovered,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black38,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 8,
                                        bottom: 8,
                                        child: AnimatedSlide(
                                          offset: _isHovered ? Offset.zero : const Offset(0, 0.25),
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeOutCubic,
                                          child: AnimatedScale(
                                            scale: _isHovered ? 1.0 : 0.8,
                                            duration: const Duration(milliseconds: 200),
                                            curve: Curves.easeOutBack,
                                            child: Material(
                                              color: Colors.transparent,
                                              shape: const CircleBorder(),
                                              clipBehavior: Clip.antiAlias,
                                              child: InkWell(
                                                customBorder: const CircleBorder(),
                                                splashColor: Colors.white.withValues(alpha: 0.25),
                                                highlightColor: Colors.white.withValues(alpha: 0.15),
                                                onTap: () async {
                                                  final songs = await DbService.isar.songs
                                                      .filter()
                                                      .artistEqualTo(artist.name)
                                                      .or()
                                                      .albumArtistEqualTo(artist.name)
                                                      .findAll();
                                                  if (songs.isNotEmpty) {
                                                    ref.read(playbackProvider.notifier).setPlaylist(
                                                          songs,
                                                          queueName: artist.name,
                                                          disableShuffle: true,
                                                        );
                                                  }
                                                },
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha: 0.4),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Icon(
                                                    LucideIcons.play,
                                                    size: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                        right: 8,
                                        bottom: 8,
                                        child: Material(
                                          color: Colors.transparent,
                                          shape: const CircleBorder(),
                                          clipBehavior: Clip.antiAlias,
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            splashColor: Colors.white.withValues(alpha: 0.25),
                                            highlightColor: Colors.white.withValues(alpha: 0.15),
                                            onTap: () {
                                              showArtistOptionsBottomSheet(
                                                context: context,
                                                ref: ref,
                                                artist: artist,
                                              );
                                            },
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.7),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white.withValues(alpha: 0.25),
                                                  width: 1,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.4),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                LucideIcons.moreHorizontal,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
