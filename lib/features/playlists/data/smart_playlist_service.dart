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

    // 3. Forgotten Favorites
    final forgottenFavorites = _computeForgottenFavorites(allSongs, now);
    if (forgottenFavorites != null) result.add(forgottenFavorites);

    // 4. Heavy Rotation
    final heavyRotation = _computeHeavyRotation(allSongs, now);
    if (heavyRotation != null) result.add(heavyRotation);

    // 5. Never Played
    final neverPlayed = _computeNeverPlayed(allSongs);
    if (neverPlayed != null) result.add(neverPlayed);

    // 6. Long Time No Hear
    final longTimeNoHear = _computeLongTimeNoHear(allSongs, now);
    if (longTimeNoHear != null) result.add(longTimeNoHear);

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

  static SmartPlaylist? _computeForgottenFavorites(List<Song> allSongs, DateTime now) {
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final matching = allSongs.where((s) {
      if (!s.isFavorite) return false;
      return s.lastPlayed == null || s.lastPlayed!.isBefore(thirtyDaysAgo);
    }).toList();

    if (matching.length < 3) return null;

    // Sort: oldest lastPlayed first, songs never played at the very top
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

  static SmartPlaylist? _computeHeavyRotation(List<Song> allSongs, DateTime now) {
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    final active = allSongs.where((s) {
      if (s.lastPlayed == null) return false;
      if (s.lastPlayed!.isBefore(fourteenDaysAgo)) return false;
      return s.playCount >= 2;
    }).toList()
      ..sort((a, b) => b.lastPlayed!.compareTo(a.lastPlayed!));

    if (active.length < 3) return null;

    final songs = active.take(maxSongsPerPlaylist).toList();

    return SmartPlaylist(
      id: 'heavy_rotation',
      title: 'Heavy Rotation',
      description: 'Your most active tracks over the past 2 weeks',
      icon: LucideIcons.rotateCw,
      gradientColors: const [
        Color(0xFF00B0FF),
        Color(0xFF00E5FF),
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
