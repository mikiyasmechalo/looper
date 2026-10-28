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

  /// Builds a balanced mix of songs drawn from the quick-pick sources:
  /// - Top played songs (randomized across a broad top-pool so songs beyond 5th rank appear)
  /// - Random discovery songs outside of the top songs (higher weighting / more randomization)
  /// - Recently added tracks
  /// - Favorites (shuffled)
  ///
  /// Interleaved round-robin and deduplicated by path, up to [count] songs.
  static List<Song> buildQuickPicksQueue(
    List<Song> allSongs, {
    int count = 100,
    Random? random,
  }) {
    if (allSongs.isEmpty) return [];

    final rnd = random ?? Random();

    // 1. Top played songs pool:
    // Gather songs that have been played (playCount > 0), sorted by playCount descending.
    final playedSongs = allSongs.where((s) => s.playCount > 0).toList()
      ..sort((a, b) => b.playCount.compareTo(a.playCount));

    // To prevent ranks 1-6 from repeating predictably every time, we take a wide pool of
    // top songs (up to 50 songs) and randomize/shuffle them. This ensures songs beyond the
    // 5th rank (e.g. ranks 6-40) are regularly mixed into the top slots alongside top songs.
    final List<Song> topPool;
    final Set<String> topSongPaths;
    if (playedSongs.length > 5) {
      final candidateCount = min(playedSongs.length, 50);
      final candidateList = playedSongs.sublist(0, candidateCount);
      topSongPaths = candidateList.map((s) => s.path).toSet();
      topPool = List<Song>.from(candidateList)..shuffle(rnd);
    } else if (playedSongs.isNotEmpty) {
      topSongPaths = playedSongs.map((s) => s.path).toSet();
      topPool = List<Song>.from(playedSongs)..shuffle(rnd);
    } else {
      topSongPaths = allSongs.take(min(allSongs.length, 10)).map((s) => s.path).toSet();
      topPool = List<Song>.from(allSongs)..shuffle(rnd);
    }

    // 2. Random discovery pool outside of top songs:
    final outsideTop = allSongs.where((s) => !topSongPaths.contains(s.path)).toList()
      ..shuffle(rnd);
    final randomPool = outsideTop.isNotEmpty
        ? outsideTop
        : (List<Song>.from(allSongs)..shuffle(rnd));

    // 3. Recently added pool (sorted by dateAdded descending)
    final recentlyAdded = List<Song>.from(allSongs)
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

    // 4. Favorites pool (shuffled so different favorites rotate in)
    final favorites = allSongs.where((s) => s.isFavorite).toList()
      ..shuffle(rnd);

    // Round-robin selection pattern with strong weight on discovery/random outside top songs:
    // [Top, RandomOutside, Recent, RandomOutside, Favorite, RandomOutside]
    // Each 6-song cycle draws 1 top song, 1 recent, 1 favorite, and 3 random songs outside top songs (50% random).
    final seen = <String>{};
    final result = <Song>[];

    int topIdx = 0;
    int randomIdx = 0;
    int recentIdx = 0;
    int favIdx = 0;

    Song? pickNext(List<Song> pool, {required bool Function() hasMore, required Song Function() next}) {
      while (hasMore()) {
        final song = next();
        if (seen.add(song.path)) {
          return song;
        }
      }
      return null;
    }

    // Pattern for each 6-slot cycle: top, random, recent, random, favorite, random
    final pattern = ['top', 'random', 'recent', 'random', 'fav', 'random'];
    int patternIdx = 0;
    var consecutiveMisses = 0;
    const maxMisses = 6;

    while (result.length < count && consecutiveMisses < maxMisses) {
      final slotType = pattern[patternIdx % pattern.length];
      patternIdx++;

      Song? picked;
      switch (slotType) {
        case 'top':
          picked = pickNext(topPool, hasMore: () => topIdx < topPool.length, next: () => topPool[topIdx++]);
          break;
        case 'random':
          picked = pickNext(randomPool, hasMore: () => randomIdx < randomPool.length, next: () => randomPool[randomIdx++]);
          break;
        case 'recent':
          picked = pickNext(recentlyAdded, hasMore: () => recentIdx < recentlyAdded.length, next: () => recentlyAdded[recentIdx++]);
          break;
        case 'fav':
          picked = pickNext(favorites, hasMore: () => favIdx < favorites.length, next: () => favorites[favIdx++]);
          break;
      }

      if (picked != null) {
        result.add(picked);
        consecutiveMisses = 0;
      } else {
        consecutiveMisses++;
      }
    }

    // If still under count (e.g. pools ran dry because of overlap) and allSongs has unpicked items:
    if (result.length < count) {
      final remaining = List<Song>.from(allSongs)..shuffle(rnd);
      for (final s in remaining) {
        if (result.length >= count) break;
        if (seen.add(s.path)) {
          result.add(s);
        }
      }
    }

    return result.length > count ? result.sublist(0, count) : result;
  }
}
