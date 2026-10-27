import 'dart:math';
import 'package:looper_player/features/library/domain/models/models.dart';

class RecommendationsService {
  static final int quickPicksSessionSeed = Random().nextInt(0x7fffffff);
  static List<Song>? _cachedQuickPicks;
  static int _quickPicksFingerprint = -1;
  static const int quickPicksCount = 12;

  static List<Song>? get cachedQuickPicks => _cachedQuickPicks;

  static void clearQuickPicksCache() {
    _cachedQuickPicks = null;
    _quickPicksFingerprint = -1;
  }

  static List<Song> getDashboardQuickPicks(List<Song> allSongs) {
    if (allSongs.isEmpty) {
      clearQuickPicksCache();
      return const [];
    }

    var fingerprint = allSongs.length;
    for (final s in allSongs) {
      fingerprint = (fingerprint * 31 + s.path.hashCode) & 0x7fffffff;
    }

    final uniqueSongCount = allSongs.map((s) => s.path).toSet().length;
    final targetCount = min(quickPicksCount, uniqueSongCount);

    if (_cachedQuickPicks == null ||
        _cachedQuickPicks!.length != targetCount ||
        fingerprint != _quickPicksFingerprint ||
        !_cachedQuickPicks!.every((s) => allSongs.any((dbSong) => dbSong.path == s.path))) {
      _quickPicksFingerprint = fingerprint;
      final queue = buildQuickPicksQueue(
        allSongs,
        count: quickPicksCount,
        random: Random(quickPicksSessionSeed),
      );
      _cachedQuickPicks = queue.length > quickPicksCount
          ? queue.sublist(0, quickPicksCount)
          : queue;
    }
    return _cachedQuickPicks!;
  }

  /// Calculates recommendation score for local library tracks
  double calculateTrackScore(Song song) {
    final playCountScore = min(song.playCount / 50.0, 1.0) * 0.35;

    final daysSincePlayed = song.lastPlayed != null
        ? DateTime.now().difference(song.lastPlayed!).inDays
        : 30;
    final recencyScore = (1.0 / (daysSincePlayed + 1)) * 0.30;

    final favoriteScore = (song.isFavorite ? 1.0 : 0.0) * 0.20;

    return playCountScore + recencyScore + favoriteScore;
  }

  /// Ranks local tracks by recommendation score
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
            if (result.length >= count) {
              break;
            }
          }
        }
      }
      depth++;
    }
    if (result.length > count) {
      return result.sublist(0, count);
    }
    return result;
  }
}
