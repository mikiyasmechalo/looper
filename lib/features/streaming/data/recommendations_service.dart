import 'dart:math';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/streaming/data/youtube_stream_service.dart';
import 'package:looper_player/features/streaming/domain/models/online_track.dart';

class RecommendationsService {
  final YouTubeStreamService _streamService = YouTubeStreamService();

  /// Calculates SpatialFlow Track Score for local library tracks
  double calculateTrackScore(Song song) {
    final playCountScore = min(song.playCount / 50.0, 1.0) * 0.35;
    
    final daysSincePlayed = song.lastPlayed != null
        ? DateTime.now().difference(song.lastPlayed!).inDays
        : 30;
    final recencyScore = (1.0 / (daysSincePlayed + 1)) * 0.30;
    
    final favoriteScore = (song.isFavorite ? 1.0 : 0.0) * 0.20;
    
    return playCountScore + recencyScore + favoriteScore;
  }

  /// Ranks local tracks by SpatialFlow recommendation score
  List<Song> getQuickPicks(List<Song> allSongs, {int limit = 15}) {
    if (allSongs.isEmpty) return [];

    final sorted = List<Song>.from(allSongs)
      ..sort((a, b) => calculateTrackScore(b).compareTo(calculateTrackScore(a)));

    return sorted.take(limit).toList();
  }

  /// Builds a balanced mix of songs drawn from the quick-pick sources — most
  /// played, recently added, favorites, and a random selection — interleaved
  /// round-robin and deduplicated by path, up to [count] songs.
  ///
  /// Pass a [random] source to make the random slice reproducible (e.g. a
  /// Random seeded once per app run) so the mix stays stable across rebuilds.
  static List<Song> buildQuickPicksQueue(
    List<Song> allSongs, {
    int count = 100,
    Random? random,
  }) {
    if (allSongs.isEmpty) return [];

    final mostPlayed = List<Song>.from(allSongs)
      ..sort((a, b) => b.playCount.compareTo(a.playCount));
    final recentlyAdded = List<Song>.from(allSongs)
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    final favorites = allSongs.where((s) => s.isFavorite).toList();
    final randomPool = List<Song>.from(allSongs)..shuffle(random);

    final seen = <String>{};
    final result = <Song>[];
    final sources = [mostPlayed, recentlyAdded, favorites, randomPool];
    var depth = 0;
    var exhausted = false;
    while (result.length < count && !exhausted) {
      exhausted = true;
      for (final source in sources) {
        if (depth < source.length) {
          exhausted = false;
          final song = source[depth];
          if (seen.add(song.path)) {
            result.add(song);
          }
        }
      }
      depth++;
    }
    return result;
  }

  /// Fetches related online tracks for currently playing song
  Future<List<OnlineTrack>> getRelatedTracks(Song currentSong) async {
    final query = '${currentSong.title} ${currentSong.artist ?? ""} related audio';
    return await _streamService.searchTracks(query, limit: 12);
  }
}
