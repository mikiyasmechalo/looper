import 'package:flutter/material.dart';
import 'package:looper_player/ui/widgets/app_loading_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/l10n/app_localizations.dart';

import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/ui/widgets/standard_play_shuffle_bar.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/ui/widgets/artist_image.dart';
import 'package:looper_player/ui/widgets/collection_options_bottom_sheet.dart';

final favoritesProvider = StreamProvider<List<Song>>((ref) {
  return DbService.isar.songs
      .filter()
      .isFavoriteEqualTo(true)
      .watch(fireImmediately: true);
});

final favoriteAlbumsProvider = StreamProvider<List<Album>>((ref) {
  return DbService.isar.albums
      .filter()
      .isFavoriteEqualTo(true)
      .watch(fireImmediately: true);
});

final favoriteArtistsProvider = StreamProvider<List<Artist>>((ref) {
  return DbService.isar.artists
      .filter()
      .isFavoriteEqualTo(true)
      .watch(fireImmediately: true);
});

final recentlyPlayedProvider = StreamProvider<List<Song>>((ref) {
  return DbService.isar.songs
      .where()
      .filter()
      .lastPlayedIsNotNull()
      .sortByLastPlayedDesc()
      .limit(50)
      .watch(fireImmediately: true);
});

class FavoritesView extends ConsumerWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesAsync = ref.watch(favoritesProvider);
    final favAlbumsAsync = ref.watch(favoriteAlbumsProvider);
    final favArtistsAsync = ref.watch(favoriteArtistsProvider);

    final songs = favoritesAsync.value ?? const <Song>[];
    final favAlbums = favAlbumsAsync.value ?? const <Album>[];
    final favArtists = favArtistsAsync.value ?? const <Artist>[];

    final bool isLoading = favoritesAsync.isLoading && favAlbumsAsync.isLoading && favArtistsAsync.isLoading;
    if (isLoading) return const AppLoadingIndicator();

    final bool isEmpty = songs.isEmpty && favAlbums.isEmpty && favArtists.isEmpty;
    if (isEmpty) {
      return _buildEmpty(context, LucideIcons.star, l10n.noFavoritesYet);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (favArtists.isNotEmpty || favAlbums.isNotEmpty)
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (favArtists.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    child: Text(
                      'Favorite Artists',
                      style: AppFonts.jostStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 190,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: favArtists.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, index) => _FavArtistCard(artist: favArtists[index]),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (favAlbums.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    child: Text(
                      'Favorite Albums',
                      style: AppFonts.jostStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 195,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: favAlbums.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, index) => _FavAlbumCard(album: favAlbums[index]),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        if (songs.isNotEmpty) ...[
          StandardPlayShuffleBar(
            onPlayAll: () => ref
                .read(playbackProvider.notifier)
                .setPlaylist(songs, queueName: l10n.favorites, disableShuffle: true),
            onShuffle: () => ref
                .read(playbackProvider.notifier)
                .playShuffled(songs, queueName: l10n.favorites),
          ),
          Expanded(child: SongsList(songs: songs)),
        ] else if (favArtists.isNotEmpty || favAlbums.isNotEmpty)
          const Spacer(),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context, IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(text),
        ],
      ),
    );
  }
}

class RecentlyPlayedView extends ConsumerWidget {
  const RecentlyPlayedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recentlyPlayedAsync = ref.watch(recentlyPlayedProvider);

    return recentlyPlayedAsync.when(
      data: (songs) => songs.isEmpty
          ? _buildEmpty(context, LucideIcons.clock, l10n.noHistoryYet)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StandardPlayShuffleBar(
                  onPlayAll: () => ref
                      .read(playbackProvider.notifier)
                      .setPlaylist(songs, queueName: l10n.recentlyPlayed, disableShuffle: true),
                  onShuffle: () => ref
                      .read(playbackProvider.notifier)
                      .playShuffled(songs, queueName: l10n.recentlyPlayed),
                ),
                Expanded(child: SongsList(songs: songs)),
              ],
            ),
      loading: () => const AppLoadingIndicator(),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildEmpty(BuildContext context, IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(text),
        ],
      ),
    );
  }
}

class _FavAlbumCard extends ConsumerStatefulWidget {
  final Album album;
  const _FavAlbumCard({required this.album});

  @override
  ConsumerState<_FavAlbumCard> createState() => _FavAlbumCardState();
}

class _FavAlbumCardState extends ConsumerState<_FavAlbumCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final album = widget.album;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onSecondaryTap: () => showAlbumOptionsBottomSheet(
          context: context,
          ref: ref,
          album: album,
        ),
        child: SizedBox(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: OptimizedImage(
                          imagePath: album.artPath,
                          fit: BoxFit.cover,
                          placeholder: Container(
                            color: Colors.white10,
                            child: const Center(
                              child: Icon(LucideIcons.disc, color: Colors.white38, size: 36),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Red heart badge (top right) - ditch black background
                    Positioned(
                      top: 6,
                      right: 6,
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 16,
                        color: Colors.redAccent,
                        shadows: [
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
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 6,
                              bottom: 6,
                              child: AnimatedSlide(
                                offset: _isHovered ? Offset.zero : const Offset(0, 0.25),
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                child: AnimatedScale(
                                  scale: _isHovered ? 1.0 : 0.8,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOutBack,
                                  child: GestureDetector(
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
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.4),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(LucideIcons.play, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 6,
                              bottom: 6,
                              child: GestureDetector(
                                onTap: () => showAlbumOptionsBottomSheet(
                                  context: context,
                                  ref: ref,
                                  album: album,
                                ),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white24, width: 1),
                                  ),
                                  child: const Icon(LucideIcons.moreHorizontal, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                album.name,
                style: AppFonts.jostStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Text(
                album.artist ?? 'Unknown',
                style: AppFonts.jostStyle(fontSize: 11, color: Colors.white60),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavArtistCard extends ConsumerStatefulWidget {
  final Artist artist;
  const _FavArtistCard({required this.artist});

  @override
  ConsumerState<_FavArtistCard> createState() => _FavArtistCardState();
}

class _FavArtistCardState extends ConsumerState<_FavArtistCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final artist = widget.artist;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onSecondaryTap: () => showArtistOptionsBottomSheet(
          context: context,
          ref: ref,
          artist: artist,
        ),
        child: SizedBox(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipOval(
                        child: ArtistImage(
                          images: artist.artistImages,
                          imageUrl: artist.artistImageUrl != null &&
                                  (artist.artistImageUrl!.startsWith('http://') ||
                                      artist.artistImageUrl!.startsWith('https://'))
                              ? artist.artistImageUrl
                              : null,
                          imagePath: artist.artistImageUrl != null &&
                                  !(artist.artistImageUrl!.startsWith('http://') ||
                                      artist.artistImageUrl!.startsWith('https://'))
                              ? artist.artistImageUrl
                              : artist.artPath,
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          placeholder: const Center(
                            child: Icon(
                              LucideIcons.user,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Red heart badge (top right) - ditch black background
                    Positioned(
                      top: 6,
                      right: 6,
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 16,
                        color: Colors.redAccent,
                        shadows: [
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
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 6,
                              bottom: 6,
                              child: AnimatedSlide(
                                offset: _isHovered ? Offset.zero : const Offset(0, 0.25),
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                child: AnimatedScale(
                                  scale: _isHovered ? 1.0 : 0.8,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOutBack,
                                  child: GestureDetector(
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
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(LucideIcons.play, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                              right: 6,
                              bottom: 6,
                              child: GestureDetector(
                                onTap: () => showArtistOptionsBottomSheet(
                                  context: context,
                                  ref: ref,
                                  artist: artist,
                                ),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white24, width: 1),
                                  ),
                                  child: const Icon(LucideIcons.moreHorizontal, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
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
                                  subtitle: 'Artists',
                                  art: artist.artPath,
                                  imageUrl: artist.artistImageUrl,
                                  images: artist.artistImages,
                                  songs: songs,
                                  highlightItem: NavItem.artists,
                                );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                artist.name,
                style: AppFonts.jostStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
