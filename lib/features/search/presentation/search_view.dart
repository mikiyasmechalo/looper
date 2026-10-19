import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/ui/widgets/app_loading_indicator.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/ui/widgets/artist_image.dart';
import 'package:looper_player/ui/widgets/song_options_bottom_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/playback/presentation/lyrics_search_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class SearchResults {
  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> artists;
  final List<Playlist> playlists;
  final List<String> genres;

  SearchResults({
    required this.songs,
    required this.albums,
    required this.artists,
    this.playlists = const [],
    this.genres = const [],
  });
}

final searchResultsProvider = StreamProvider<SearchResults>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) {
    return Stream.value(SearchResults(songs: [], albums: [], artists: []));
  }

  final lowerQuery = query.toLowerCase();

  return DbService.isar.songs
      .filter()
      .titleContains(query, caseSensitive: false)
      .or()
      .artistContains(query, caseSensitive: false)
      .or()
      .albumContains(query, caseSensitive: false)
      .or()
      .lyricsContains(query, caseSensitive: false)
      .or()
      .genreContains(query, caseSensitive: false)
      .watch(fireImmediately: true)
      .asyncMap((songs) async {
        final albums = await DbService.isar.albums
            .filter()
            .nameContains(query, caseSensitive: false)
            .findAll();
        final artists = await DbService.isar.artists
            .filter()
            .nameContains(query, caseSensitive: false)
            .findAll();
        final playlists = await DbService.isar.playlists
            .filter()
            .nameContains(query, caseSensitive: false)
            .findAll();

        final allLibrarySongs = await DbService.isar.songs.where().findAll();
        final genres = allLibrarySongs
            .map((s) => s.genre)
            .whereType<String>()
            .where((g) => g.toLowerCase().contains(lowerQuery))
            .toSet()
            .toList();

        // Sort songs
        final sortedSongs = List<Song>.from(songs);
        sortedSongs.sort((a, b) {
          int getSongScore(Song song) {
            final title = song.title.toLowerCase();
            final lyrics = (song.lyrics ?? '').toLowerCase();
            final artist = (song.artist ?? '').toLowerCase();
            final album = (song.album ?? '').toLowerCase();

            if (title == lowerQuery) return 100;
            if (title.startsWith(lowerQuery)) return 90;
            if (title.contains(lowerQuery)) return 80;
            if (lyrics.contains(lowerQuery)) return 50;
            if (artist.contains(lowerQuery) || album.contains(lowerQuery)) return 30;
            return 0;
          }

          final scoreA = getSongScore(a);
          final scoreB = getSongScore(b);
          if (scoreA != scoreB) return scoreB.compareTo(scoreA);
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });

        // Sort albums
        albums.sort((a, b) {
          final aName = a.name.toLowerCase();
          final bName = b.name.toLowerCase();
          if (aName == lowerQuery) return -1;
          if (bName == lowerQuery) return 1;
          if (aName.startsWith(lowerQuery) && !bName.startsWith(lowerQuery)) return -1;
          if (bName.startsWith(lowerQuery) && !aName.startsWith(lowerQuery)) return 1;
          return aName.compareTo(bName);
        });

        // Sort artists
        artists.sort((a, b) {
          final aName = a.name.toLowerCase();
          final bName = b.name.toLowerCase();
          if (aName == lowerQuery) return -1;
          if (bName == lowerQuery) return 1;
          if (aName.startsWith(lowerQuery) && !bName.startsWith(lowerQuery)) return -1;
          if (bName.startsWith(lowerQuery) && !aName.startsWith(lowerQuery)) return 1;
          return aName.compareTo(bName);
        });

        return SearchResults(
          songs: sortedSongs,
          albums: albums,
          artists: artists,
          playlists: playlists,
          genres: genres,
        );
      });
});

class SearchView extends ConsumerWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Column(
      children: [
        Expanded(
          child: query.isEmpty
              ? _buildRecentSearches(context)
              : resultsAsync.when(
                  data: (results) => _buildResults(results, ref, context),
                  loading: () => const AppLoadingIndicator(),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
        ),
      ],
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.search,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.searchLibraryHint,
            style: AppFonts.jostStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    SearchResults results,
    WidgetRef ref,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final nav = ref.watch(appNavigationProvider);
    final sourceTab = nav.searchSourceTab ?? nav.highlightItem ?? nav.activeItem;

    final filterPlaylists = (sourceTab == NavItem.playlists) ? results.playlists : <Playlist>[];
    final filterGenres = (sourceTab == NavItem.genres) ? results.genres : <String>[];

    if (results.songs.isEmpty &&
        results.albums.isEmpty &&
        results.artists.isEmpty &&
        filterPlaylists.isEmpty &&
        filterGenres.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(l10n.noResultsFound),
        ),
      );
    }

    final slivers = <Widget>[];

    Widget buildAlbumsSection(List<Album> albums) {
      if (albums.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.albums,
              style: AppFonts.jostStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: albums.length,
              itemBuilder: (context, index) => _AlbumResultCard(album: albums[index]),
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    Widget buildArtistsSection(List<Artist> artists) {
      if (artists.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.artists,
              style: AppFonts.jostStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: artists.length,
              itemBuilder: (context, index) => _ArtistResultCard(artist: artists[index]),
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    Widget buildPlaylistsSection(List<Playlist> playlists) {
      if (playlists.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.playlists,
              style: AppFonts.jostStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: playlists.length,
              itemBuilder: (context, index) => _PlaylistResultCard(playlist: playlists[index]),
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    Widget buildGenresSection(List<String> genres) {
      if (genres.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.genres,
              style: AppFonts.jostStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 145,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: genres.length,
              itemBuilder: (context, index) => _GenreResultCard(genreName: genres[index]),
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    Widget buildSongsHeader() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 16, 14, 8),
        child: Text(
          l10n.songs,
          style: AppFonts.jostStyle(fontSize: 18, fontWeight: FontWeight.normal),
        ),
      );
    }

    if (sourceTab == NavItem.albums && results.albums.isNotEmpty) {
      final topAlbum = results.albums.first;
      final remainingAlbums = results.albums.sublist(1);

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.topResult,
                  style: AppFonts.jostStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 12),
                _TopAlbumResultCard(album: topAlbum),
              ],
            ),
          ),
        ),
      );

      if (remainingAlbums.isNotEmpty) {
        slivers.add(SliverToBoxAdapter(child: buildAlbumsSection(remainingAlbums)));
      }
      if (results.artists.isNotEmpty) {
        slivers.add(SliverToBoxAdapter(child: buildArtistsSection(results.artists)));
      }
      if (results.songs.isNotEmpty) {
        slivers.add(SliverToBoxAdapter(child: buildSongsHeader()));
        slivers.add(
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => SongTile(
                song: results.songs[index],
                l10n: l10n,
                songs: results.songs,
                searchQuery: ref.read(searchQueryProvider),
                queueName: 'Search',
              ),
              childCount: results.songs.length,
            ),
          ),
        );
      }
    } else if (sourceTab == NavItem.artists && results.artists.isNotEmpty) {
      final topArtist = results.artists.first;
      final remainingArtists = results.artists.sublist(1);

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.topResult,
                  style: AppFonts.jostStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 12),
                _TopArtistResultCard(artist: topArtist),
              ],
            ),
          ),
        ),
      );

      if (remainingArtists.isNotEmpty) {
        slivers.add(SliverToBoxAdapter(child: buildArtistsSection(remainingArtists)));
      }
      if (results.albums.isNotEmpty) {
        slivers.add(SliverToBoxAdapter(child: buildAlbumsSection(results.albums)));
      }
      if (results.songs.isNotEmpty) {
        slivers.add(SliverToBoxAdapter(child: buildSongsHeader()));
        slivers.add(
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => SongTile(
                song: results.songs[index],
                l10n: l10n,
                songs: results.songs,
                searchQuery: ref.read(searchQueryProvider),
                queueName: 'Search',
              ),
              childCount: results.songs.length,
            ),
          ),
        );
      }
    } else if (sourceTab == NavItem.playlists && filterPlaylists.isNotEmpty) {
      final topPlaylist = filterPlaylists.first;
      final remainingPlaylists = filterPlaylists.sublist(1);

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.topResult,
                  style: AppFonts.jostStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 12),
                _TopPlaylistResultCard(playlist: topPlaylist),
              ],
            ),
          ),
        ),
      );

      if (remainingPlaylists.isNotEmpty) {
        slivers.add(SliverToBoxAdapter(child: buildPlaylistsSection(remainingPlaylists)));
      }
      if (results.songs.isNotEmpty) {
        slivers.add(SliverToBoxAdapter(child: buildSongsHeader()));
        slivers.add(
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => SongTile(
                song: results.songs[index],
                l10n: l10n,
                songs: results.songs,
                searchQuery: ref.read(searchQueryProvider),
                queueName: 'Search',
              ),
              childCount: results.songs.length,
            ),
          ),
        );
      }
    } else if (sourceTab == NavItem.genres && filterGenres.isNotEmpty) {
      final topGenre = filterGenres.first;
      final remainingGenres = filterGenres.sublist(1);

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.topResult,
                  style: AppFonts.jostStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 12),
                _TopGenreResultCard(genreName: topGenre),
              ],
            ),
          ),
        ),
      );

      if (remainingGenres.isNotEmpty) {
        slivers.add(SliverToBoxAdapter(child: buildGenresSection(remainingGenres)));
      }
      if (results.songs.isNotEmpty) {
        slivers.add(SliverToBoxAdapter(child: buildSongsHeader()));
        slivers.add(
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => SongTile(
                song: results.songs[index],
                l10n: l10n,
                songs: results.songs,
                searchQuery: ref.read(searchQueryProvider),
                queueName: 'Search',
              ),
              childCount: results.songs.length,
            ),
          ),
        );
      }
    } else {
      final songListToRender = results.songs.length > 1 ? results.songs.sublist(1) : <Song>[];

      if (results.songs.isNotEmpty) {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.topResult,
                    style: AppFonts.jostStyle(fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 12),
                  _SongResultCard(
                    song: results.songs.first,
                    songs: results.songs,
                    searchQuery: ref.read(searchQueryProvider),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      if (results.artists.isNotEmpty) {
        slivers.add(SliverToBoxAdapter(child: buildArtistsSection(results.artists)));
      }
      if (results.albums.isNotEmpty) {
        slivers.add(SliverToBoxAdapter(child: buildAlbumsSection(results.albums)));
      }
      if (songListToRender.isNotEmpty) {
        slivers.add(SliverToBoxAdapter(child: buildSongsHeader()));
        slivers.add(
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => SongTile(
                song: songListToRender[index],
                l10n: l10n,
                songs: results.songs,
                searchQuery: ref.read(searchQueryProvider),
                queueName: 'Search',
              ),
              childCount: songListToRender.length,
            ),
          ),
        );
      }
    }

    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 180)));

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: slivers,
    );
  }
}

class _SongResultCard extends ConsumerWidget {
  final Song song;
  final List<Song>? songs;
  final String? searchQuery;
  const _SongResultCard({required this.song, this.songs, this.searchQuery});

  void _playSong(WidgetRef ref) {
    if (searchQuery != null) {
      ref.read(lyricsSearchQueryProvider.notifier).state = searchQuery!;
    }
    final playlist = (songs != null && songs!.isNotEmpty) ? songs! : [song];
    final index = playlist.indexWhere((s) => s.path == song.path);
    ref.read(playbackProvider.notifier).setPlaylist(
      playlist,
      initialIndex: index != -1 ? index : 0,
      queueName: 'Search',
    );
  }

  Widget _buildHighlightedText({
    required BuildContext context,
    required String text,
    required String query,
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
  }) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(text, style: baseStyle);
    }

    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfMatch;

    while ((indexOfMatch = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (indexOfMatch > start) {
        spans.add(TextSpan(
          text: text.substring(start, indexOfMatch),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(indexOfMatch, indexOfMatch + query.length),
        style: highlightStyle,
      ));
      start = indexOfMatch + query.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCurrent = ref.watch(playbackProvider.select((s) => s.currentSong?.path == song.path));
    final l10n = AppLocalizations.of(context)!;

    String? lyricSnippet;
    if (searchQuery != null && searchQuery!.isNotEmpty && song.lyrics != null) {
      lyricSnippet = _getLyricSnippet(song.lyrics!, searchQuery!);
    }

    final cardContent = isCurrent
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: OptimizedImage(
                        imagePath: song.artPath,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: AppFonts.jostStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist ?? l10n.unknownArtist,
                            style: AppFonts.jostStyle(fontSize: 14, color: Colors.grey),
                          ),
                          if (lyricSnippet == null) ...[
                            const SizedBox(height: 2),
                            Text(
                              song.album ?? l10n.unknownAlbum,
                              style: AppFonts.jostStyle(
                                fontSize: 12,
                                color: Colors.grey.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.ellipsisVertical, color: Colors.white70, size: 20),
                      onPressed: () => showSongOptionsBottomSheet(context: context, ref: ref, song: song),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _playSong(ref),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                if (lyricSnippet != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.quote,
                              size: 11,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.matchingLyrics,
                              style: AppFonts.jostStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildHighlightedText(
                          context: context,
                          text: lyricSnippet,
                          query: searchQuery ?? '',
                          baseStyle: AppFonts.jostStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontStyle: FontStyle.italic,
                          ),
                          highlightStyle: AppFonts.jostStyle(
                            fontSize: 13,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          )
        : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white10.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: OptimizedImage(
                        imagePath: song.artPath,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: AppFonts.jostStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist ?? l10n.unknownArtist,
                            style: AppFonts.jostStyle(fontSize: 14, color: Colors.grey),
                          ),
                          if (lyricSnippet == null) ...[
                            const SizedBox(height: 2),
                            Text(
                              song.album ?? l10n.unknownAlbum,
                              style: AppFonts.jostStyle(
                                fontSize: 12,
                                color: Colors.grey.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.ellipsisVertical, color: Colors.white70, size: 20),
                      onPressed: () => showSongOptionsBottomSheet(context: context, ref: ref, song: song),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _playSong(ref),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                if (lyricSnippet != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.quote,
                              size: 11,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.matchingLyrics,
                              style: AppFonts.jostStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildHighlightedText(
                          context: context,
                          text: lyricSnippet,
                          query: searchQuery ?? '',
                          baseStyle: AppFonts.jostStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontStyle: FontStyle.italic,
                          ),
                          highlightStyle: AppFonts.jostStyle(
                            fontSize: 13,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );

    return GestureDetector(
      onSecondaryTap: () => showSongOptionsBottomSheet(context: context, ref: ref, song: song),
      child: InkWell(
        onTap: () => _playSong(ref),
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      ),
    );
  }

  String? _getLyricSnippet(String lyrics, String query) {
    final lowerLyrics = lyrics.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerLyrics.indexOf(lowerQuery);
    if (index == -1) return null;

    int start = index;
    bool truncatedStart = false;
    while (start > 0 && lyrics[start - 1] != '\n') {
      start--;
      if (index - start > 40) {
        truncatedStart = true;
        break;
      }
    }

    int end = index + query.length;
    bool truncatedEnd = false;
    while (end < lyrics.length && lyrics[end] != '\n') {
      end++;
      if (end - index > 60) {
        truncatedEnd = true;
        break;
      }
    }

    String snippet = lyrics.substring(start, end).trim();
    if (truncatedStart) snippet = '...$snippet';
    if (truncatedEnd) snippet = '$snippet...';
    return snippet;
  }
}

class _ArtistResultCard extends ConsumerWidget {
  final Artist artist;
  const _ArtistResultCard({required this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 14),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          hoverColor: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          onTap: () async {

            final songs = await DbService.isar.songs
                .filter()
                .artistEqualTo(artist.name)
                .findAll();
            ref.read(appNavigationProvider.notifier).showCollection(
                  title: artist.name,
                  subtitle: l10n.artist,
                  songs: songs,
                  art: artist.artPath,
                  imageUrl: artist.artistImageUrl,
                  images: artist.artistImages,
                  highlightItem: NavItem.artists,
                );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ArtistImage(
                  imagePath: artist.artPath,
                  imageUrl: artist.artistImageUrl,
                  images: artist.artistImages,
                  width: 92,
                  height: 92,
                  shape: BoxShape.circle,
                ),
                const SizedBox(height: 10),
                Text(
                  artist.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.jostStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.artist,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: AppFonts.jostStyle(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlbumResultCard extends ConsumerWidget {
  final Album album;
  const _AlbumResultCard({required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 14),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          hoverColor: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          onTap: () async {

            final songs = await DbService.isar.songs
                .filter()
                .albumEqualTo(album.name)
                .findAll();
            ref.read(appNavigationProvider.notifier).showCollection(
                  title: album.name,
                  subtitle: album.artist ?? l10n.unknownArtist,
                  songs: songs,
                  art: album.artPath,
                  highlightItem: NavItem.albums,
                );
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: OptimizedImage(
                      imagePath: album.artPath,
                      width: 120,
                      height: 120,
                      cacheWidth: 256,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        color: Colors.white10,
                        child: const Center(child: Icon(LucideIcons.disc, color: Colors.white54)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  album.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.jostStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  album.artist ?? l10n.unknownArtist,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.jostStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaylistResultCard extends ConsumerWidget {
  final Playlist playlist;
  const _PlaylistResultCard({required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 14),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          hoverColor: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          onTap: () async {

            final songs = await DbService.isar.songs
                .filter()
                .anyOf(playlist.songPaths, (q, String path) => q.pathEqualTo(path))
                .findAll();
            ref.read(appNavigationProvider.notifier).showCollection(
                  title: playlist.name,
                  subtitle: 'Playlist',
                  songs: songs,
                  playlist: playlist,
                  highlightItem: NavItem.playlists,
                );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Icon(LucideIcons.listMusic, size: 36, color: Colors.white70)),
                ),
                const SizedBox(height: 10),
                Text(
                  playlist.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.jostStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${playlist.songPaths.length} songs',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: AppFonts.jostStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GenreResultCard extends ConsumerWidget {
  final String genreName;
  const _GenreResultCard({required this.genreName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 14),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          hoverColor: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          onTap: () async {

            final songs = await DbService.isar.songs
                .filter()
                .genreEqualTo(genreName)
                .findAll();
            ref.read(appNavigationProvider.notifier).showCollection(
                  title: genreName,
                  subtitle: 'Genre',
                  songs: songs,
                  highlightItem: NavItem.genres,
                );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(child: Icon(LucideIcons.radio, size: 28, color: Colors.white70)),
                ),
                const SizedBox(height: 10),
                Text(
                  genreName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.jostStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Genre',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: AppFonts.jostStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopAlbumResultCard extends ConsumerWidget {
  final Album album;
  const _TopAlbumResultCard({required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        hoverColor: Colors.white.withValues(alpha: 0.08),
        onTap: () async {

          final songs = await DbService.isar.songs
              .filter()
              .albumEqualTo(album.name)
              .findAll();
          ref.read(appNavigationProvider.notifier).showCollection(
                title: album.name,
                subtitle: album.artist ?? l10n.unknownArtist,
                songs: songs,
                art: album.artPath,
                highlightItem: NavItem.albums,
              );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: OptimizedImage(
                  imagePath: album.artPath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      album.name,
                      style: AppFonts.jostStyle(fontSize: 20, fontWeight: FontWeight.normal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      album.artist ?? l10n.unknownArtist,
                      style: AppFonts.jostStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.album,
                      style: AppFonts.jostStyle(fontSize: 12, color: Colors.grey.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopArtistResultCard extends ConsumerWidget {
  final Artist artist;
  const _TopArtistResultCard({required this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        hoverColor: Colors.white.withValues(alpha: 0.08),
        onTap: () async {

          final songs = await DbService.isar.songs
              .filter()
              .artistEqualTo(artist.name)
              .findAll();
          ref.read(appNavigationProvider.notifier).showCollection(
                title: artist.name,
                subtitle: l10n.artist,
                songs: songs,
                art: artist.artPath,
                imageUrl: artist.artistImageUrl,
                images: artist.artistImages,
                highlightItem: NavItem.artists,
              );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ArtistImage(
                imagePath: artist.artPath,
                imageUrl: artist.artistImageUrl,
                images: artist.artistImages,
                width: 80,
                height: 80,
                shape: BoxShape.circle,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.name,
                      style: AppFonts.jostStyle(fontSize: 20, fontWeight: FontWeight.normal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.artist,
                      style: AppFonts.jostStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopPlaylistResultCard extends ConsumerWidget {
  final Playlist playlist;
  const _TopPlaylistResultCard({required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        hoverColor: Colors.white.withValues(alpha: 0.08),
        onTap: () async {

          final songs = await DbService.isar.songs
              .filter()
              .anyOf(playlist.songPaths, (q, String path) => q.pathEqualTo(path))
              .findAll();
          ref.read(appNavigationProvider.notifier).showCollection(
                title: playlist.name,
                subtitle: 'Playlist',
                songs: songs,
                playlist: playlist,
                highlightItem: NavItem.playlists,
              );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Icon(LucideIcons.listMusic, size: 36, color: Colors.white70)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      style: AppFonts.jostStyle(fontSize: 20, fontWeight: FontWeight.normal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${playlist.songPaths.length} songs',
                      style: AppFonts.jostStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Playlist',
                      style: AppFonts.jostStyle(fontSize: 12, color: Colors.grey.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopGenreResultCard extends ConsumerWidget {
  final String genreName;
  const _TopGenreResultCard({required this.genreName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        hoverColor: Colors.white.withValues(alpha: 0.08),
        onTap: () async {

          final songs = await DbService.isar.songs
              .filter()
              .genreEqualTo(genreName)
              .findAll();
          ref.read(appNavigationProvider.notifier).showCollection(
                title: genreName,
                subtitle: 'Genre',
                songs: songs,
                highlightItem: NavItem.genres,
              );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Center(child: Icon(LucideIcons.radio, size: 36, color: Colors.white70)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      genreName,
                      style: AppFonts.jostStyle(fontSize: 20, fontWeight: FontWeight.normal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Genre',
                      style: AppFonts.jostStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
