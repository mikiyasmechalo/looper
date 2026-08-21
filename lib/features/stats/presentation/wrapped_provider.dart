import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/stats/presentation/stats_provider.dart';

class WrappedYearData {
  final int year;
  final int totalMinutes;
  final int totalPlays;
  final int uniqueArtistsCount;
  final int uniqueSongsCount;
  final List<SongStat> topSongs;
  final List<ArtistStat> topArtists;
  final ArtistStat? artistOfTheYear;
  final SongStat? songOfTheYear;
  final List<GenreStat> topGenres;
  final int peakListeningHour; // 0-23
  final String listeningPersona;
  final String personaDescription;
  final IconData personaIcon;
  final int longestStreakDays;
  final Map<String, int> timeOfDayDistribution;

  const WrappedYearData({
    required this.year,
    required this.totalMinutes,
    required this.totalPlays,
    required this.uniqueArtistsCount,
    required this.uniqueSongsCount,
    required this.topSongs,
    required this.topArtists,
    this.artistOfTheYear,
    this.songOfTheYear,
    required this.topGenres,
    required this.peakListeningHour,
    required this.listeningPersona,
    required this.personaDescription,
    required this.personaIcon,
    required this.longestStreakDays,
    required this.timeOfDayDistribution,
  });
}

class WrappedState {
  final int selectedYear;
  final List<int> availableYears;
  final WrappedYearData? data;
  final bool isLoading;

  const WrappedState({
    required this.selectedYear,
    this.availableYears = const [],
    this.data,
    this.isLoading = true,
  });

  WrappedState copyWith({
    int? selectedYear,
    List<int>? availableYears,
    WrappedYearData? data,
    bool? isLoading,
  }) {
    return WrappedState(
      selectedYear: selectedYear ?? this.selectedYear,
      availableYears: availableYears ?? this.availableYears,
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final wrappedProvider = StateNotifierProvider<WrappedNotifier, WrappedState>((ref) {
  return WrappedNotifier();
});

class WrappedNotifier extends StateNotifier<WrappedState> {
  WrappedNotifier() : super(WrappedState(selectedYear: DateTime.now().year)) {
    init();
  }

  Future<void> init() async {
    final now = DateTime.now();
    final currentYear = now.year;
    
    // Find all distinct years from history
    final history = await DbService.isar.playbackHistoryEntrys.where().findAll();
    final Set<int> yearSet = {currentYear};
    for (final h in history) {
      yearSet.add(h.timestamp.year);
    }
    
    final years = yearSet.toList()..sort((a, b) => b.compareTo(a));
    state = state.copyWith(availableYears: years);
    await loadYear(years.first);
  }

  Future<void> setYear(int year) async {
    state = state.copyWith(selectedYear: year);
    await loadYear(year);
  }

  Future<void> loadYear(int year) async {
    state = state.copyWith(isLoading: true, selectedYear: year);

    final startOfYear = DateTime(year, 1, 1);
    final endOfYear = DateTime(year + 1, 1, 1);

    final entries = await DbService.isar.playbackHistoryEntrys
        .filter()
        .timestampGreaterThan(startOfYear)
        .and()
        .timestampLessThan(endOfYear)
        .findAll();

    final allSongs = await DbService.isar.songs.where().findAll();
    final Map<String, Song> songPathMap = {for (final s in allSongs) s.path: s};
    final Map<int, Song> songIdMap = {for (final s in allSongs) s.id: s};

    int totalDurationMs = 0;
    int totalPlays = 0;
    final Map<String, int> songPlayCounts = {}; // Key by song title or path
    final Map<String, SongStat> songStatMap = {};
    final Map<String, int> artistPlayCounts = {};
    final Map<String, int> artistDurationMs = {};
    final Map<String, String?> artistArtPaths = {};
    final Map<String, int> genrePlayCounts = {};
    final Map<int, int> hourCounts = {};
    final Set<String> activeDates = {};

    if (entries.isNotEmpty) {
      for (final entry in entries) {
        totalPlays++;
        totalDurationMs += entry.durationMs;

        final matchedSong = songPathMap[entry.songPath];
        final songKey = entry.songPath.isNotEmpty ? entry.songPath : entry.title;
        songPlayCounts[songKey] = (songPlayCounts[songKey] ?? 0) + 1;

        songStatMap.putIfAbsent(
          songKey,
          () => SongStat(
            title: entry.title,
            artist: entry.artist ?? matchedSong?.artist ?? 'Unknown Artist',
            playCount: 0,
            durationMs: entry.durationMs > 0 ? entry.durationMs : (matchedSong?.duration ?? 0),
            artPath: entry.artPath ?? matchedSong?.artPath,
          ),
        );

        final artist = (entry.artist != null && entry.artist!.trim().isNotEmpty)
            ? entry.artist!.trim()
            : (matchedSong?.artist ?? 'Unknown Artist').trim();

        artistPlayCounts[artist] = (artistPlayCounts[artist] ?? 0) + 1;
        artistDurationMs[artist] = (artistDurationMs[artist] ?? 0) + entry.durationMs;
        if (entry.artPath != null) {
          artistArtPaths[artist] = entry.artPath;
        } else if (matchedSong?.artPath != null) {
          artistArtPaths[artist] = matchedSong!.artPath;
        }

        if (entry.genre != null && entry.genre!.trim().isNotEmpty) {
          final g = entry.genre!.trim();
          genrePlayCounts[g] = (genrePlayCounts[g] ?? 0) + 1;
        } else if (matchedSong?.genre != null && matchedSong!.genre!.trim().isNotEmpty) {
          final g = matchedSong.genre!.trim();
          genrePlayCounts[g] = (genrePlayCounts[g] ?? 0) + 1;
        }

        final h = entry.timestamp.hour;
        hourCounts[h] = (hourCounts[h] ?? 0) + 1;

        final dateKey = '${entry.timestamp.year}-${entry.timestamp.month}-${entry.timestamp.day}';
        activeDates.add(dateKey);
      }
    } else {
      // Seed from Song database if entries are empty
      for (final song in allSongs) {
        if (song.playCount > 0) {
          totalPlays += song.playCount;
          final dur = (song.duration ?? 200000) * song.playCount;
          totalDurationMs += dur;
          songPlayCounts[song.path] = song.playCount;

          songStatMap[song.path] = SongStat(
            title: song.title,
            artist: song.artist ?? 'Unknown Artist',
            playCount: song.playCount,
            durationMs: song.duration ?? 0,
            artPath: song.artPath,
          );

          final artist = (song.artist ?? 'Unknown Artist').trim();
          artistPlayCounts[artist] = (artistPlayCounts[artist] ?? 0) + song.playCount;
          artistDurationMs[artist] = (artistDurationMs[artist] ?? 0) + dur;
          if (song.artPath != null) artistArtPaths[artist] = song.artPath;

          if (song.genre != null && song.genre!.trim().isNotEmpty) {
            genrePlayCounts[song.genre!.trim()] = (genrePlayCounts[song.genre!.trim()] ?? 0) + song.playCount;
          }
        }
      }
    }

    // Top Songs
    final sortedSongKeys = songPlayCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topSongs = sortedSongKeys.take(5).map((e) {
      final stat = songStatMap[e.key];
      return SongStat(
        title: stat?.title ?? 'Unknown Track',
        artist: stat?.artist ?? 'Unknown Artist',
        playCount: e.value,
        durationMs: stat?.durationMs ?? 0,
        artPath: stat?.artPath,
      );
    }).toList();

    // Top Artists
    final sortedArtists = artistPlayCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topArtists = sortedArtists.take(5).map((e) {
      return ArtistStat(
        name: e.key,
        playCount: e.value,
        listeningTime: Duration(milliseconds: artistDurationMs[e.key] ?? 0),
        artPath: artistArtPaths[e.key],
      );
    }).toList();

    // Top Genres
    final totalGenrePlays = genrePlayCounts.values.fold(0, (sum, c) => sum + c);
    final sortedGenres = genrePlayCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topGenres = sortedGenres.take(5).map((e) {
      return GenreStat(
        name: e.key,
        playCount: e.value,
        percentage: totalGenrePlays > 0 ? e.value / totalGenrePlays : 0.0,
      );
    }).toList();

    // Peak Listening Hour
    int peakHour = 20;
    int maxHourCount = 0;
    for (final e in hourCounts.entries) {
      if (e.value > maxHourCount) {
        maxHourCount = e.value;
        peakHour = e.key;
      }
    }

    // Time of day distribution
    int morning = 0, afternoon = 0, evening = 0, night = 0;
    for (final e in hourCounts.entries) {
      if (e.key >= 6 && e.key < 12) {
        morning += e.value;
      } else if (e.key >= 12 && e.key < 18) {
        afternoon += e.value;
      } else if (e.key >= 18 && e.key < 24) {
        evening += e.value;
      } else {
        night += e.value;
      }
    }

    // Listening streak calculation
    int streak = _calculateMaxStreak(activeDates);

    // Persona derivation
    final (persona, desc, icon) = _derivePersona(peakHour, topGenres, totalPlays, topArtists);

    final wrappedData = WrappedYearData(
      year: year,
      totalMinutes: (totalDurationMs / 60000).round(),
      totalPlays: totalPlays,
      uniqueArtistsCount: artistPlayCounts.length,
      uniqueSongsCount: songPlayCounts.length,
      topSongs: topSongs,
      topArtists: topArtists,
      artistOfTheYear: topArtists.firstOrNull,
      songOfTheYear: topSongs.firstOrNull,
      topGenres: topGenres,
      peakListeningHour: peakHour,
      listeningPersona: persona,
      personaDescription: desc,
      personaIcon: icon,
      longestStreakDays: streak,
      timeOfDayDistribution: {
        'Morning (6am-12pm)': morning,
        'Afternoon (12pm-6pm)': afternoon,
        'Evening (6pm-12am)': evening,
        'Night (12am-6am)': night,
      },
    );

    state = state.copyWith(isLoading: false, data: wrappedData);
  }

  int _calculateMaxStreak(Set<String> activeDates) {
    if (activeDates.isEmpty) return 1;
    final List<DateTime> sortedDates = activeDates.map((d) {
      final parts = d.split('-').map(int.parse).toList();
      return DateTime(parts[0], parts[1], parts[2]);
    }).toList()..sort();

    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else if (diff > 1) {
        currentStreak = 1;
      }
    }
    return maxStreak;
  }

  (String, String, IconData) _derivePersona(
    int peakHour,
    List<GenreStat> topGenres,
    int totalPlays,
    List<ArtistStat> topArtists,
  ) {
    if (peakHour >= 0 && peakHour < 6) {
      return (
        'The Night Owl 🦉',
        'Your soundtrack lives after midnight. Deep focus and nighttime reverie guide your listening.',
        Icons.nights_stay_rounded,
      );
    }
    if (peakHour >= 6 && peakHour < 11) {
      return (
        'The Dawn Riser 🌅',
        'You start every morning with energy and rhythm, setting the tone for the entire day.',
        Icons.wb_sunny_rounded,
      );
    }
    if (totalPlays > 500 && (topArtists.firstOrNull?.playCount ?? 0) > (totalPlays * 0.4)) {
      return (
        'The Loyal Superfan 🌟',
        'When you love an artist, you dedicate your whole heart and queue to them on repeat.',
        Icons.favorite_rounded,
      );
    }
    if (topGenres.length >= 4) {
      return (
        'The Eclectic Explorer 🧭',
        'You refuse to be boxed into one genre. Your taste is a colorful, global tapestry.',
        Icons.explore_rounded,
      );
    }
    return (
      'The Audio Connoisseur 🎧',
      'Refined and focused listening habits with an ear for seamless album perfection.',
      Icons.headphones_rounded,
    );
  }
}
