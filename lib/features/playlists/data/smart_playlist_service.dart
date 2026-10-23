import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playlists/domain/smart_playlist.dart';

class SmartPlaylistService {
  static const int maxSongsPerPlaylist = 200;

  /// Computes the list of active smart playlists from the current library [allSongs].
  /// Returns only smart playlists whose criteria and minimum thresholds are met.
  static List<SmartPlaylist> computeSmartPlaylists(
    List<Song> allSongs, {
    DateTime? currentTime,
  }) {
    if (allSongs.isEmpty) return const [];

    final now = currentTime ?? DateTime.now();
    final List<SmartPlaylist> result = [];

    // 1. Top Most Played
    final topPlayed = computeTopPlayed(allSongs);
    if (topPlayed != null) result.add(topPlayed);

    // 2. Added in the Last 30 Days (or Recently Added)
    final recentlyAdded = computeRecentlyAdded(allSongs, now);
    if (recentlyAdded != null) result.add(recentlyAdded);

    // 3. Genre Mixes (top 2-3 genres with >= 10 songs)
    final genreMixes = _computeGenreMixes(allSongs);
    result.addAll(genreMixes);

    // 4. Decade Rewind (user's most prominent past decade with >= 10 songs)
    final decadeRewind = _computeDecadeRewind(allSongs, now);
    if (decadeRewind != null) result.add(decadeRewind);

    // 5. Deep Cuts (lesser-known tracks and b-sides from favorite artists)
    final deepCuts = _computeDeepCuts(allSongs);
    if (deepCuts != null) result.add(deepCuts);

    // 6. Forgotten Favorites
    final forgottenFavorites = _computeForgottenFavorites(allSongs, now);
    if (forgottenFavorites != null) result.add(forgottenFavorites);

    // 7. Long Time No Hear
    final longTimeNoHear = _computeLongTimeNoHear(allSongs, now);
    if (longTimeNoHear != null) result.add(longTimeNoHear);

    // 8. Never Played
    final neverPlayed = _computeNeverPlayed(allSongs);
    if (neverPlayed != null) result.add(neverPlayed);

    return result;
  }

  static SmartPlaylist? computeTopPlayed(List<Song> allSongs) {
    final playedSongs = allSongs
        .where((s) => s.playCount > 0)
        .toList();
    if (playedSongs.isEmpty) return null;

    playedSongs.sort((a, b) {
      final cmp = b.playCount.compareTo(a.playCount);
      if (cmp != 0) return cmp;
      final aDate = a.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateCmp = bDate.compareTo(aDate);
      if (dateCmp != 0) return dateCmp;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    final count = playedSongs.length;
    int targetCount;
    String title;

    if (count >= 200) {
      targetCount = 200;
      title = 'Top 200 Most Played';
    } else if (count >= 100) {
      targetCount = 100;
      title = 'Top 100 Most Played';
    } else if (count >= 50) {
      targetCount = 50;
      title = 'Top 50 Most Played';
    } else if (count >= 25) {
      targetCount = 25;
      title = 'Top 25 Most Played';
    } else if (count >= 10) {
      targetCount = 10;
      title = 'Top 10 Most Played';
    } else {
      targetCount = count;
      title = 'Top Songs';
    }

    final songs = playedSongs.take(targetCount).toList();

    return SmartPlaylist(
      id: 'top_played',
      title: title,
      description: 'Your most listened tracks of all time',
      icon: LucideIcons.flame,
      gradientColors: const [
        Color(0xFFFF5722),
        Color(0xFFFF9800),
      ],
      songs: songs,
    );
  }

  static SmartPlaylist? computeRecentlyAdded(List<Song> allSongs, [DateTime? now]) {
    if (allSongs.isEmpty) return null;

    final sorted = List<Song>.from(allSongs)
      ..sort((a, b) {
        final cmp = b.dateAdded.compareTo(a.dateAdded);
        if (cmp != 0) return cmp;
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });

    final songs = sorted.take(maxSongsPerPlaylist).toList();

    return SmartPlaylist(
      id: 'recently_added',
      title: 'Recently Added',
      description: 'Fresh additions to your music library',
      icon: LucideIcons.clock,
      gradientColors: const [
        Color(0xFF7C4DFF),
        Color(0xFF536DFE),
      ],
      songs: songs,
    );
  }

  static List<SmartPlaylist> _computeGenreMixes(List<Song> allSongs) {
    String? canonicalGenre(String? raw) {
      if (raw == null) return null;
      final t = raw.trim();
      if (t.isEmpty) return null;
      final lower = t.toLowerCase();
      if (lower.contains('rap') || lower.contains('hip hop') || lower.contains('hip-hop')) {
        return 'Hip-Hop';
      }
      if (lower.contains('r&b') || lower.contains('soul') || lower.contains('funk')) {
        return 'R&B';
      }
      if (lower.contains('pop')) {
        return 'Pop';
      }
      if (lower.contains('rock') || lower.contains('metal') || lower.contains('punk')) {
        return 'Rock';
      }
      if (lower.contains('alt') || lower.contains('indie')) {
        return 'Alternative';
      }
      if (lower.contains('electronic') || lower.contains('dance') || lower.contains('electro') || lower.contains('edm') || lower.contains('house') || lower.contains('techno')) {
        return 'Electronic';
      }
      if (lower.contains('country') || lower.contains('folk') || lower.contains('bluegrass')) {
        return 'Country';
      }
      if (lower.contains('jazz') || lower.contains('blues')) {
        return 'Jazz';
      }
      if (lower.contains('classical') || lower.contains('score') || lower.contains('soundtrack')) {
        return 'Classical';
      }
      final clean = t.split(RegExp(r'[,/&]')).first.trim();
      return clean.isEmpty ? null : clean;
    }

    final buckets = <String, List<Song>>{};
    for (final s in allSongs) {
      final g = canonicalGenre(s.genre);
      if (g != null) {
        buckets.putIfAbsent(g, () => []).add(s);
      }
    }

    final sortedEntries = buckets.entries.where((e) => e.value.length >= 10).toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    final List<SmartPlaylist> mixes = [];
    for (final entry in sortedEntries.take(3)) {
      final name = entry.key;
      final songs = List<Song>.from(entry.value)
        ..sort((a, b) {
          final cmp = b.playCount.compareTo(a.playCount);
          if (cmp != 0) return cmp;
          final aDate = a.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0);
          final dateCmp = bDate.compareTo(aDate);
          if (dateCmp != 0) return dateCmp;
          return b.dateAdded.compareTo(a.dateAdded);
        });

      final styling = _getGenreStyling(name);
      final id = 'genre_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';

      mixes.add(
        SmartPlaylist(
          id: id,
          title: '$name Mix',
          description: 'The best $name tracks from your collection',
          icon: styling.icon,
          gradientColors: styling.colors,
          songs: songs.take(maxSongsPerPlaylist).toList(),
        ),
      );
    }

    return mixes;
  }

  static _GenreStyling _getGenreStyling(String canonicalName) {
    switch (canonicalName) {
      case 'Pop':
        return const _GenreStyling(
          LucideIcons.sparkles,
          [Color(0xFFE91E63), Color(0xFFFF4081)],
        );
      case 'Hip-Hop':
        return const _GenreStyling(
          LucideIcons.mic2,
          [Color(0xFFFF6F00), Color(0xFFFF9800)],
        );
      case 'Alternative':
        return const _GenreStyling(
          LucideIcons.compass,
          [Color(0xFF00897B), Color(0xFF26A69A)],
        );
      case 'Rock':
        return const _GenreStyling(
          LucideIcons.flame,
          [Color(0xFFD32F2F), Color(0xFFFF5722)],
        );
      case 'Electronic':
        return const _GenreStyling(
          LucideIcons.zap,
          [Color(0xFF00B0FF), Color(0xFF2979FF)],
        );
      case 'R&B':
        return const _GenreStyling(
          LucideIcons.heart,
          [Color(0xFF7B1FA2), Color(0xFFBA68C8)],
        );
      case 'Country':
        return const _GenreStyling(
          LucideIcons.sun,
          [Color(0xFF8D6E63), Color(0xFFA1887F)],
        );
      case 'Jazz':
        return const _GenreStyling(
          LucideIcons.music,
          [Color(0xFF3949AB), Color(0xFF5C6BC0)],
        );
      case 'Classical':
        return const _GenreStyling(
          LucideIcons.library,
          [Color(0xFF455A64), Color(0xFF78909C)],
        );
      default:
        return const _GenreStyling(
          LucideIcons.disc3,
          [Color(0xFF3F51B5), Color(0xFF2196F3)],
        );
    }
  }

  static SmartPlaylist? _computeDecadeRewind(List<Song> allSongs, DateTime now) {
    final currentDecade = (now.year ~/ 10) * 10;
    final decadeBuckets = <int, List<Song>>{};

    for (final s in allSongs) {
      if (s.year != null && s.year! >= 1950 && s.year! < currentDecade) {
        final d = (s.year! ~/ 10) * 10;
        decadeBuckets.putIfAbsent(d, () => []).add(s);
      }
    }

    if (decadeBuckets.isEmpty) return null;

    final sortedDecades = decadeBuckets.entries.where((e) => e.value.length >= 10).toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    if (sortedDecades.isEmpty) return null;

    final topDecade = sortedDecades.first;
    final decadeYear = topDecade.key;
    final songs = List<Song>.from(topDecade.value)
      ..sort((a, b) {
        final cmp = b.playCount.compareTo(a.playCount);
        if (cmp != 0) return cmp;
        final aDate = a.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateCmp = bDate.compareTo(aDate);
        if (dateCmp != 0) return dateCmp;
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });

    return SmartPlaylist(
      id: 'decade_${decadeYear}s',
      title: '${decadeYear}s Rewind',
      description: 'Nostalgic tracks and top favorites from the ${decadeYear}s',
      icon: LucideIcons.history,
      gradientColors: const [
        Color(0xFFE65100),
        Color(0xFFFB8C00),
      ],
      songs: songs.take(maxSongsPerPlaylist).toList(),
    );
  }

  static SmartPlaylist? _computeDeepCuts(List<Song> allSongs) {
    final artistPlays = <String, int>{};
    for (final s in allSongs) {
      final a = s.artist?.trim();
      if (a == null || a.isEmpty) continue;
      artistPlays[a] = (artistPlays[a] ?? 0) + s.playCount;
    }

    final topArtists = artistPlays.entries
        .where((e) => e.value >= 3)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (topArtists.isEmpty) return null;

    final topArtistNames = topArtists.take(15).map((e) => e.key).toSet();

    final cuts = allSongs.where((s) {
      final a = s.artist?.trim();
      if (a == null || !topArtistNames.contains(a)) return false;
      return s.playCount <= 1;
    }).toList();

    if (cuts.length < 5) return null;

    cuts.sort((a, b) {
      if (a.isFavorite != b.isFavorite) {
        return a.isFavorite ? -1 : 1;
      }
      return b.dateAdded.compareTo(a.dateAdded);
    });

    return SmartPlaylist(
      id: 'deep_cuts',
      title: 'Deep Cuts',
      description: 'Lesser-known tracks and b-sides from your favorite artists',
      icon: LucideIcons.gem,
      gradientColors: const [
        Color(0xFF00695C),
        Color(0xFF00897B),
      ],
      songs: cuts.take(maxSongsPerPlaylist).toList(),
    );
  }

  static SmartPlaylist? _computeForgottenFavorites(List<Song> allSongs, DateTime now) {
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final matching = allSongs.where((s) {
      if (!s.isFavorite) return false;
      return s.lastPlayed == null || s.lastPlayed!.isBefore(thirtyDaysAgo);
    }).toList();

    if (matching.length < 3) return null;

    matching.sort((a, b) {
      if (a.lastPlayed == null && b.lastPlayed == null) return 0;
      if (a.lastPlayed == null) return -1;
      if (b.lastPlayed == null) return 1;
      return a.lastPlayed!.compareTo(b.lastPlayed!);
    });

    final songs = matching.take(maxSongsPerPlaylist).toList();

    return SmartPlaylist(
      id: 'forgotten_favorites',
      title: 'Forgotten Favorites',
      description: 'Favorited tracks you haven\'t heard in over a month',
      icon: LucideIcons.heartCrack,
      gradientColors: const [
        Color(0xFFE91E63),
        Color(0xFFFF4081),
      ],
      songs: songs,
    );
  }

  static SmartPlaylist? _computeNeverPlayed(List<Song> allSongs) {
    final hasAnyPlays = allSongs.any((s) => s.playCount > 0);
    if (!hasAnyPlays) return null;

    final unplayed = allSongs
        .where((s) => s.playCount == 0 && s.lastPlayed == null)
        .toList();

    if (unplayed.isEmpty) return null;

    final songs = unplayed.take(maxSongsPerPlaylist).toList();

    return SmartPlaylist(
      id: 'never_played',
      title: 'Never Played',
      description: 'Untouched tracks waiting to be discovered',
      icon: LucideIcons.disc3,
      gradientColors: const [
        Color(0xFF00C853),
        Color(0xFF69F0AE),
      ],
      songs: songs,
    );
  }

  static SmartPlaylist? _computeLongTimeNoHear(List<Song> allSongs, DateTime now) {
    final sixtyDaysAgo = now.subtract(const Duration(days: 60));

    final matches = allSongs.where((s) {
      if (s.playCount <= 0 || s.lastPlayed == null) return false;
      return s.lastPlayed!.isBefore(sixtyDaysAgo);
    }).toList()
      ..sort((a, b) => a.lastPlayed!.compareTo(b.lastPlayed!));

    if (matches.length < 3) return null;

    final songs = matches.take(maxSongsPerPlaylist).toList();

    return SmartPlaylist(
      id: 'long_time_no_hear',
      title: 'Long Time No Hear',
      description: 'Songs you listened to in the past but not in months',
      icon: LucideIcons.hourglass,
      gradientColors: const [
        Color(0xFF8E24AA),
        Color(0xFFBA68C8),
      ],
      songs: songs,
    );
  }
}

class _GenreStyling {
  final IconData icon;
  final List<Color> colors;
  const _GenreStyling(this.icon, this.colors);
}
