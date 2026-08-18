import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/library/domain/models/models.dart';

enum StatsTimeRange {
  today,
  thisWeek,
  thisMonth,
  allTime,
}

class ArtistStat {
  final String name;
  final int playCount;
  final Duration listeningTime;
  final String? artPath;
  final String? artistImageUrl;
  final List<String> artistImages;

  ArtistStat({
    required this.name,
    required this.playCount,
    required this.listeningTime,
    this.artPath,
    this.artistImageUrl,
    this.artistImages = const [],
  });
}

class AlbumStat {
  final String name;
  final String? artist;
  final int playCount;
  final String? artPath;

  AlbumStat({
    required this.name,
    this.artist,
    required this.playCount,
    this.artPath,
  });
}

class SongStat {
  final String title;
  final String? artist;
  final int playCount;
  final int durationMs;
  final String? artPath;

  SongStat({
    required this.title,
    this.artist,
    required this.playCount,
    required this.durationMs,
    this.artPath,
  });
}

class GenreStat {
  final String name;
  final int playCount;
  final double percentage;

  GenreStat({
    required this.name,
    required this.playCount,
    required this.percentage,
  });
}

class DailyActivityPoint {
  final DateTime date;
  final String label; // "Mon", "Tue", etc.
  final double minutes;

  DailyActivityPoint({
    required this.date,
    required this.label,
    required this.minutes,
  });
}

class StatsState {
  final StatsTimeRange timeRange;
  final Duration totalListeningTime;
  final int totalPlays;
  final int uniqueTracksCount;
  final List<ArtistStat> topArtists;
  final List<AlbumStat> topAlbums;
  final List<SongStat> topSongs;
  final List<GenreStat> topGenres;
  final List<DailyActivityPoint> dailyActivity;
  final Map<String, int> timeOfDayCounts;
  final bool isLoading;

  const StatsState({
    this.timeRange = StatsTimeRange.thisWeek,
    this.totalListeningTime = Duration.zero,
    this.totalPlays = 0,
    this.uniqueTracksCount = 0,
    this.topArtists = const [],
    this.topAlbums = const [],
    this.topSongs = const [],
    this.topGenres = const [],
    this.dailyActivity = const [],
    this.timeOfDayCounts = const {
      'Morning': 0,
      'Afternoon': 0,
      'Evening': 0,
      'Night': 0,
    },
    this.isLoading = true,
  });

  StatsState copyWith({
    StatsTimeRange? timeRange,
    Duration? totalListeningTime,
    int? totalPlays,
    int? uniqueTracksCount,
    List<ArtistStat>? topArtists,
    List<AlbumStat>? topAlbums,
    List<SongStat>? topSongs,
    List<GenreStat>? topGenres,
    List<DailyActivityPoint>? dailyActivity,
    Map<String, int>? timeOfDayCounts,
    bool? isLoading,
  }) {
    return StatsState(
      timeRange: timeRange ?? this.timeRange,
      totalListeningTime: totalListeningTime ?? this.totalListeningTime,
      totalPlays: totalPlays ?? this.totalPlays,
      uniqueTracksCount: uniqueTracksCount ?? this.uniqueTracksCount,
      topArtists: topArtists ?? this.topArtists,
      topAlbums: topAlbums ?? this.topAlbums,
      topSongs: topSongs ?? this.topSongs,
      topGenres: topGenres ?? this.topGenres,
      dailyActivity: dailyActivity ?? this.dailyActivity,
      timeOfDayCounts: timeOfDayCounts ?? this.timeOfDayCounts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  return StatsNotifier();
});

class StatsNotifier extends StateNotifier<StatsState> {
  StatsNotifier() : super(const StatsState()) {
    loadStats(StatsTimeRange.thisWeek);
  }

  Future<void> refresh() async {
    await loadStats(state.timeRange);
  }

  Future<void> setTimeRange(StatsTimeRange range) async {
    state = state.copyWith(timeRange: range);
    await loadStats(range);
  }

  Future<void> loadStats(StatsTimeRange range) async {
    try {
      final now = DateTime.now();
      DateTime? startDate;

      switch (range) {
        case StatsTimeRange.today:
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case StatsTimeRange.thisWeek:
          startDate = now.subtract(const Duration(days: 7));
          break;
        case StatsTimeRange.thisMonth:
          startDate = now.subtract(const Duration(days: 30));
          break;
        case StatsTimeRange.allTime:
          startDate = null;
          break;
      }

      // Query PlaybackHistoryEntry records from Isar
      List<PlaybackHistoryEntry> entries;
      if (startDate != null) {
        entries = await DbService.isar.playbackHistoryEntrys
            .filter()
            .timestampGreaterThan(startDate)
            .sortByTimestampDesc()
            .findAll();
      } else {
        entries = await DbService.isar.playbackHistoryEntrys
            .where()
            .sortByTimestampDesc()
            .findAll();
      }

      // Fallback/Seed from Song library if history is empty (e.g. initial launch)
      final allSongs = await DbService.isar.songs.where().findAll();

      int totalDurationMs = 0;
      int totalPlays = 0;
      final Set<String> uniqueTracks = {};
      final Map<String, _ArtistAggregator> artistMap = {};
      final Map<String, _AlbumAggregator> albumMap = {};
      final Map<String, _SongAggregator> songMap = {};
      final Map<String, int> genreMap = {};
      final Map<String, int> timeOfDay = {
        'Morning': 0,
        'Afternoon': 0,
        'Evening': 0,
        'Night': 0,
      };

      if (entries.isNotEmpty) {
        for (final e in entries) {
          totalPlays++;
          totalDurationMs += (e.listenedMs > 0 ? e.listenedMs : (e.durationMs > 0 ? e.durationMs : 180000));
          uniqueTracks.add(e.songPath);

          // Artist Aggregation
          final artistName = (e.artist != null && e.artist!.trim().isNotEmpty) ? e.artist!.trim() : 'Unknown Artist';
          final artistAgg = artistMap.putIfAbsent(artistName, () => _ArtistAggregator(name: artistName, artPath: e.artPath));
          artistAgg.playCount++;
          artistAgg.durationMs += e.durationMs;
          if (artistAgg.artPath == null && e.artPath != null) artistAgg.artPath = e.artPath;

          // Album Aggregation
          if (e.album != null && e.album!.trim().isNotEmpty) {
            final albumName = e.album!.trim();
            final albumAgg = albumMap.putIfAbsent(albumName, () => _AlbumAggregator(name: albumName, artist: e.artist, artPath: e.artPath));
            albumAgg.playCount++;
            if (albumAgg.artPath == null && e.artPath != null) albumAgg.artPath = e.artPath;
          }

          // Song Aggregation
          final songAgg = songMap.putIfAbsent(e.songPath, () => _SongAggregator(
            title: e.title,
            artist: e.artist,
            durationMs: e.durationMs,
            artPath: e.artPath,
          ));
          songAgg.playCount++;

          // Genre
          if (e.genre != null && e.genre!.trim().isNotEmpty) {
            final g = e.genre!.trim();
            genreMap[g] = (genreMap[g] ?? 0) + 1;
          }

          // Time of Day
          final hour = e.timestamp.hour;
          if (hour >= 6 && hour < 12) {
            timeOfDay['Morning'] = (timeOfDay['Morning'] ?? 0) + 1;
          } else if (hour >= 12 && hour < 18) {
            timeOfDay['Afternoon'] = (timeOfDay['Afternoon'] ?? 0) + 1;
          } else if (hour >= 18 && hour < 24) {
            timeOfDay['Evening'] = (timeOfDay['Evening'] ?? 0) + 1;
          } else {
            timeOfDay['Night'] = (timeOfDay['Night'] ?? 0) + 1;
          }
        }
      } else {
        // Synthesize from allSongs playCounts for All-Time view when freshly started
        for (final song in allSongs) {
          if (song.playCount > 0) {
            totalPlays += song.playCount;
            totalDurationMs += (song.duration ?? 180000) * song.playCount;
            uniqueTracks.add(song.path);

            final artistName = (song.artist != null && song.artist!.trim().isNotEmpty) ? song.artist!.trim() : 'Unknown Artist';
            final artistAgg = artistMap.putIfAbsent(artistName, () => _ArtistAggregator(name: artistName, artPath: song.artPath));
            artistAgg.playCount += song.playCount;
            artistAgg.durationMs += (song.duration ?? 180000) * song.playCount;

            if (song.album != null && song.album!.trim().isNotEmpty) {
              final albumName = song.album!.trim();
              final albumAgg = albumMap.putIfAbsent(albumName, () => _AlbumAggregator(name: albumName, artist: song.artist, artPath: song.artPath));
              albumAgg.playCount += song.playCount;
            }

            final songAgg = songMap.putIfAbsent(song.path, () => _SongAggregator(
              title: song.title,
              artist: song.artist,
              durationMs: song.duration ?? 0,
              artPath: song.artPath,
            ));
            songAgg.playCount += song.playCount;

            if (song.genre != null && song.genre!.trim().isNotEmpty) {
              final g = song.genre!.trim();
              genreMap[g] = (genreMap[g] ?? 0) + song.playCount;
            }
          }
        }
      }

      // Compute Top Lists
      final topArtists = artistMap.values.toList()
        ..sort((a, b) => b.playCount.compareTo(a.playCount));
      final topAlbums = albumMap.values.toList()
        ..sort((a, b) => b.playCount.compareTo(a.playCount));
      final topSongs = songMap.values.toList()
        ..sort((a, b) => b.playCount.compareTo(a.playCount));

      // Compute Daily Activity Points (Past 7 Days)
      final List<DailyActivityPoint> dailyActivity = [];
      for (int i = 6; i >= 0; i--) {
        final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        final nextDay = day.add(const Duration(days: 1));
        final dayEntries = entries.where((e) => e.timestamp.isAfter(day) && e.timestamp.isBefore(nextDay));
        final dayMinutes = dayEntries.fold<double>(
          0.0,
          (sum, e) => sum + ((e.listenedMs > 0 ? e.listenedMs : (e.durationMs > 0 ? e.durationMs : 180000)) / 60000.0),
        );
        const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final dayLabel = dayNames[day.weekday - 1];
        dailyActivity.add(DailyActivityPoint(date: day, label: dayLabel, minutes: dayMinutes));
      }

      // Compute Genre Percentages
      final totalGenrePlays = genreMap.values.fold<int>(0, (sum, c) => sum + c);
      final topGenres = genreMap.entries.map((e) {
        return GenreStat(
          name: e.key,
          playCount: e.value,
          percentage: totalGenrePlays > 0 ? (e.value / totalGenrePlays) : 0.0,
        );
      }).toList()
        ..sort((a, b) => b.playCount.compareTo(a.playCount));

      // Lookup Artist records for real artist photos
      final allArtists = await DbService.isar.artists.where().findAll();
      final Map<String, Artist> artistDbMap = {
        for (final a in allArtists) a.name.toLowerCase().trim(): a,
      };

      state = state.copyWith(
        timeRange: range,
        totalListeningTime: Duration(milliseconds: totalDurationMs),
        totalPlays: totalPlays,
        uniqueTracksCount: uniqueTracks.length,
        topArtists: topArtists.take(10).map((a) {
          final dbArtist = artistDbMap[a.name.toLowerCase().trim()];
          return ArtistStat(
            name: a.name,
            playCount: a.playCount,
            listeningTime: Duration(milliseconds: a.durationMs),
            artPath: a.artPath,
            artistImageUrl: dbArtist?.artistImageUrl,
            artistImages: dbArtist?.artistImages ?? const [],
          );
        }).toList(),
        topAlbums: topAlbums.take(8).map((a) => AlbumStat(
          name: a.name,
          artist: a.artist,
          playCount: a.playCount,
          artPath: a.artPath,
        )).toList(),
        topSongs: topSongs.take(15).map((s) => SongStat(
          title: s.title,
          artist: s.artist,
          playCount: s.playCount,
          durationMs: s.durationMs,
          artPath: s.artPath,
        )).toList(),
        topGenres: topGenres.take(6).toList(),
        dailyActivity: dailyActivity,
        timeOfDayCounts: timeOfDay,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

class _ArtistAggregator {
  final String name;
  String? artPath;
  int playCount = 0;
  int durationMs = 0;

  _ArtistAggregator({required this.name, this.artPath});
}

class _AlbumAggregator {
  final String name;
  final String? artist;
  String? artPath;
  int playCount = 0;

  _AlbumAggregator({required this.name, this.artist, this.artPath});
}

class _SongAggregator {
  final String title;
  final String? artist;
  final int durationMs;
  final String? artPath;
  int playCount = 0;

  _SongAggregator({
    required this.title,
    this.artist,
    required this.durationMs,
    this.artPath,
  });
}
