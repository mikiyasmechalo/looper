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
import 'package:looper_player/features/streaming/data/recommendations_service.dart';
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
final int _quickPicksSessionSeed = math.Random().nextInt(0x7fffffff);

List<Song>? _cachedQuickPicks;
int _quickPicksFingerprint = -1;
const int _quickPicksCount = 12;

/// Mixed quick picks for the home dashboard: most played, recently added,
/// favorites, and a random selection, deduplicated. Computed once per app run
/// (or when the library song set changes) so it does not reshuffle on rebuilds.
final homeQuickPicksMixProvider = Provider<List<Song>>((ref) {
  final allSongs = ref.watch(libraryProvider.select((l) => l.songs));
  var fingerprint = allSongs.length;
  for (final s in allSongs) {
    fingerprint = (fingerprint * 31 + s.path.hashCode) & 0x7fffffff;
  }
  // Rebuild if the library changed OR the cached list no longer matches the
  // requested count (e.g. a stale cache left over from a hot-reloaded build).
  if (_cachedQuickPicks == null ||
      _cachedQuickPicks!.length != _quickPicksCount ||
      fingerprint != _quickPicksFingerprint) {
    _quickPicksFingerprint = fingerprint;
    _cachedQuickPicks = RecommendationsService.buildQuickPicksQueue(
      allSongs,
      count: _quickPicksCount,
      random: math.Random(_quickPicksSessionSeed),
    );
  }
  return _cachedQuickPicks!;
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
            final topAlbums = ref.watch(topAlbumsProvider);
            if (settings.showHomeAlbums && topAlbums.isNotEmpty) {
              orderedChildren.add(
                _buildDesktopHorizontalSection(
                  context,
                  title: 'Top Album',
                  onViewAll: () => ref
                      .read(appNavigationProvider.notifier)
                      .setItem(NavItem.albums),
                  itemCount: topAlbums.length,
                  isNarrow: isNarrow,
                  itemBuilder: (context, index) {
                    return _buildDesktopAlbumItem(
                      context,
                      ref,
                      topAlbums[index],
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
    bool isDynamic,
  ) {
    final songs = ref.watch(homeQuickPicksMixProvider);

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
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
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
                      random: math.Random(_quickPicksSessionSeed),
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
              title: 'Top Artist',
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
                    child: GestureDetector(
                      onSecondaryTap: () => showArtistOptionsBottomSheet(
                        context: context,
                        ref: ref,
                        artist: artist,
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
                                  images: artist.artistImages,
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
                                  child: ArtistImage(
                                    images: artist.artistImages,
                                    imageUrl: artist.artistImageUrl,
                                    imagePath: artist.artPath,
                                    fit: BoxFit.cover,
                                    placeholder: Container(
                                      color: Colors.white.withValues(
                                        alpha: 0.05,
                                      ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
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
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                const Icon(
                  LucideIcons.music,
                  color: Colors.blueAccent,
                  size: 28,
                ),
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
      ),
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
