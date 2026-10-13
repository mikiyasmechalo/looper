import 'package:flutter/material.dart';
import 'package:looper_player/features/library/domain/models/models.dart';

/// A single listening event, recorded whenever a song is played.
class PlayEvent {
  final int? songId;
  final String songPath;
  final String songTitle;
  final String? artist;
  final String? album;
  final String? genre;
  final int? durationMs;
  final int listenedMs;
  final DateTime playedAt;

  const PlayEvent({
    this.songId,
    required this.songPath,
    required this.songTitle,
    this.artist,
    this.album,
    this.genre,
    this.durationMs,
    this.listenedMs = 0,
    required this.playedAt,
  });
}

/// A coarse bucket of the day, used to group [PlayEvent]s for the "when do
/// you listen most" activity heatmap.
enum DayPart {
  morning, // 05:00 - 11:59
  afternoon, // 12:00 - 16:59
  evening, // 17:00 - 20:59
  night; // 21:00 - 04:59

  static DayPart fromHour(int hour) {
    if (hour >= 5 && hour < 12) return DayPart.morning;
    if (hour >= 12 && hour < 17) return DayPart.afternoon;
    if (hour >= 17 && hour < 21) return DayPart.evening;
    return DayPart.night;
  }

  String get label => switch (this) {
    DayPart.morning => 'Morning',
    DayPart.afternoon => 'Afternoon',
    DayPart.evening => 'Evening',
    DayPart.night => 'Night',
  };
}

/// A single ranked song entry in the "Top Songs" report.
class SongStat {
  final int rank;
  final Song song;
  final int playCount;

  /// Real time actually spent listening to this song ([Song.totalListenedMs]).
  final int listenedMs;

  /// How much the song was really listened to, measured in full plays - the
  /// ranking key (see [AnalyzeSnapshot.listenScore]).
  final double score;

  /// [score] relative to the #1 song, in [0, 1] — drives proportional bar
  /// widths in the ranked list.
  final double share;

  const SongStat({
    required this.rank,
    required this.song,
    required this.playCount,
    required this.share,
    this.listenedMs = 0,
    this.score = 0,
  });
}

/// A ranked artist entry, aggregated across every song credited to them.
class ArtistStat {
  final int rank;
  final String name;
  final int totalPlays;
  final int songCount;
  final String? imagePath;
  final String? imageUrl;
  final double share;

  const ArtistStat({
    required this.rank,
    required this.name,
    required this.totalPlays,
    required this.songCount,
    required this.share,
    this.imagePath,
    this.imageUrl,
  });
}

/// A ranked album entry, aggregated across its tracks.
class AlbumStat {
  final int rank;
  final String name;
  final String? artist;
  final int totalPlays;
  final int songCount;
  final String? artPath;
  final double share;

  const AlbumStat({
    required this.rank,
    required this.name,
    required this.totalPlays,
    required this.songCount,
    required this.share,
    this.artist,
    this.artPath,
  });
}

/// A genre slice for the donut breakdown, aggregated across its tracks.
class GenreStat {
  final String name;
  final int totalPlays;
  final int songCount;
  final double fraction; // share of listening across all genres, [0, 1]
  final Color color;

  const GenreStat({
    required this.name,
    required this.totalPlays,
    required this.songCount,
    required this.fraction,
    required this.color,
  });

  /// Slice colors by rank. A name hash (the old approach) often landed
  /// neighbouring slices on near-identical hues, which made the donut
  /// unreadable; a fixed, well-spread palette keeps every slice distinct.
  static const palette = [
    Color(0xFF7AA2FF), // blue
    Color(0xFFFF7A9C), // pink
    Color(0xFF5FD4A0), // green
    Color(0xFFFFC857), // amber
    Color(0xFFB18CFF), // violet
    Color(0xFF4FC9E0), // cyan
  ];

  static Color colorAt(int rank) => palette[rank % palette.length];
}

/// Play count for a single calendar day, used by the listening-trend chart.
class DailyCount {
  final DateTime date; // normalized to midnight, local time
  final int plays;

  const DailyCount({required this.date, required this.plays});
}

/// Play count for one (weekday, day-part) cell of the activity heatmap.
/// [weekday] follows [DateTime.weekday] (1 = Monday .. 7 = Sunday).
class DayPartCount {
  final int weekday;
  final DayPart part;
  final int plays;

  const DayPartCount({
    required this.weekday,
    required this.part,
    required this.plays,
  });
}

/// Current and longest run of consecutive calendar days with at least one
/// play, computed from the [PlayEvent] log.
class StreakInfo {
  final int current;
  final int longest;

  const StreakInfo({required this.current, required this.longest});

  static const zero = StreakInfo(current: 0, longest: 0);
}

/// A fully computed snapshot of everything Looper Analyze shows, derived
/// once per rebuild from the current song library and play-event log. Pure
/// synchronous Dart — no Isar/async calls — so it's cheap to recompute
/// reactively and trivial to unit test.
class AnalyzeSnapshot {
  final int totalPlays;
  final int totalListenedMs;
  final int uniqueSongsPlayed;
  final int totalSongsInLibrary;
  final List<SongStat> topSongs; // capped at 20, rank order
  final List<ArtistStat> topArtists; // capped at 10
  final List<AlbumStat> topAlbums; // capped at 10
  final List<GenreStat> topGenres; // top 6 + rolled-up "Other"
  final List<DailyCount> dailyCounts; // last 30 days, oldest -> newest
  final List<DayPartCount> activityGrid; // 7 weekdays x 4 dayparts
  final StreakInfo streak;

  const AnalyzeSnapshot({
    required this.totalPlays,
    required this.totalListenedMs,
    required this.uniqueSongsPlayed,
    required this.totalSongsInLibrary,
    required this.topSongs,
    required this.topArtists,
    required this.topAlbums,
    required this.topGenres,
    required this.dailyCounts,
    required this.activityGrid,
    required this.streak,
  });

  bool get hasHistory => totalPlays > 0;

  String? get topGenreName =>
      topGenres.isEmpty || topGenres.first.name == 'Other'
      ? null
      : topGenres.first.name;

  /// Plays inside the trend window ([dailyCounts], the last 30 days).
  int get recentPlays => dailyCounts.fold<int>(0, (sum, d) => sum + d.plays);

  /// The day in the trend window with the most plays (the latest one on a
  /// tie), or null when the window has no plays.
  DailyCount? get busiestDay {
    DailyCount? best;
    for (final d in dailyCounts) {
      if (d.plays > 0 && (best == null || d.plays >= best.plays)) best = d;
    }
    return best;
  }

  /// The (weekday, day-part) cell with the most plays, or null when the
  /// activity grid is empty.
  DayPartCount? get peakSlot {
    DayPartCount? best;
    for (final c in activityGrid) {
      if (c.plays > 0 && (best == null || c.plays > best.plays)) best = c;
    }
    return best;
  }

  /// Share of the library played at least once, in [0, 1].
  double get libraryExplored => totalSongsInLibrary == 0
      ? 0
      : (uniqueSongsPlayed / totalSongsInLibrary).clamp(0.0, 1.0);

  static const empty = AnalyzeSnapshot(
    totalPlays: 0,
    totalListenedMs: 0,
    uniqueSongsPlayed: 0,
    totalSongsInLibrary: 0,
    topSongs: [],
    topArtists: [],
    topAlbums: [],
    topGenres: [],
    dailyCounts: [],
    activityGrid: [],
    streak: StreakInfo.zero,
  );

  factory AnalyzeSnapshot.compute({
    required List<Song> songs,
    required List<PlayEvent> events,
    List<Artist> artists = const [],
    String unknownLabel = 'Unknown',
    DateTime? now,
  }) {
    // Plays that have real listened time on record, per song. Anything in
    // playCount beyond this predates listen tracking (or never got past the
    // first checkpoint) and is credited by [_untrackedPlayCredit] instead.
    final trackedPlays = <String, int>{};
    final songListenedMs = <String, int>{};
    for (final e in events) {
      if (e.listenedMs > 0) {
        trackedPlays[e.songPath] = (trackedPlays[e.songPath] ?? 0) + 1;
        songListenedMs[e.songPath] =
            (songListenedMs[e.songPath] ?? 0) + e.listenedMs;
      }
    }
    final scores = <String, double>{
      for (final s in songs)
        if (s.playCount > 0 || (songListenedMs[s.path] ?? 0) > 0)
          s.path: listenScore(
            s,
            trackedPlays: trackedPlays[s.path] ?? 0,
            trackedListenedMs: songListenedMs[s.path] ?? 0,
          ),
    };
    double scoreOf(Song s) => scores[s.path] ?? 0;

    // Ranked by how much each song was actually listened to, not by how often
    // it was started: ten 5-second skips must not outrank three full listens.
    // Ties fall back to raw plays, then to the more recently played song.
    final playedSongs =
        songs
            .where((s) => s.playCount > 0 || (songListenedMs[s.path] ?? 0) > 0)
            .toList()
          ..sort((a, b) {
            final byScore = scoreOf(b).compareTo(scoreOf(a));
            if (byScore != 0) return byScore;
            final byPlays = b.playCount.compareTo(a.playCount);
            if (byPlays != 0) return byPlays;
            final aLast = a.lastPlayed ?? DateTime(0);
            final bLast = b.lastPlayed ?? DateTime(0);
            return bLast.compareTo(aLast);
          });

    final totalPlays = songs.fold<int>(0, (sum, s) => sum + s.playCount);
    final eventsTotalListened = events.fold<int>(
      0,
      (sum, e) => sum + e.listenedMs,
    );
    final totalListenedMs = eventsTotalListened > 0
        ? eventsTotalListened
        : songs.fold<int>(
            0,
            (sum, s) =>
                sum + (s.playCount * (s.duration ?? _fallbackDurationMs) ~/ 2),
          );

    final topScore = playedSongs.isNotEmpty ? scoreOf(playedSongs.first) : 0;
    final topSongs = <SongStat>[
      for (var i = 0; i < playedSongs.length && i < 20; i++)
        SongStat(
          rank: i + 1,
          song: playedSongs[i],
          playCount: playedSongs[i].playCount,
          listenedMs:
              songListenedMs[playedSongs[i].path] ??
              (playedSongs[i].playCount *
                  (playedSongs[i].duration ?? _fallbackDurationMs) ~/
                  2),
          score: scoreOf(playedSongs[i]),
          share: topScore == 0 ? 0 : scoreOf(playedSongs[i]) / topScore,
        ),
    ];

    final artistImages = <String, Artist>{for (final a in artists) a.name: a};
    final topArtists = _rankBy<ArtistStat>(
      playedSongs,
      scoreOf: scoreOf,
      keyOf: (s) => s.artist ?? 'Unknown Artist',
      cap: 10,
      build: (name, plays, count, share, rank, sample) => ArtistStat(
        rank: rank,
        name: name,
        totalPlays: plays,
        songCount: count,
        share: share,
        imagePath: sample.artPath,
        imageUrl: artistImages[name]?.artistImageUrl,
      ),
    );

    final topAlbums = _rankBy<AlbumStat>(
      playedSongs,
      scoreOf: scoreOf,
      keyOf: (s) => s.album ?? 'Unknown Album',
      cap: 10,
      build: (name, plays, count, share, rank, sample) => AlbumStat(
        rank: rank,
        name: name,
        artist: sample.artist,
        totalPlays: plays,
        songCount: count,
        share: share,
        artPath: sample.artPath,
      ),
    );

    final topGenres = _computeGenres(playedSongs, scoreOf, unknownLabel);

    final dailyCounts = _computeDailyCounts(events, now: now);
    final activityGrid = _computeActivityGrid(events);
    final streak = _computeStreak(events, now: now);

    return AnalyzeSnapshot(
      totalPlays: totalPlays,
      totalListenedMs: totalListenedMs,
      uniqueSongsPlayed: playedSongs.length,
      totalSongsInLibrary: songs.length,
      topSongs: topSongs,
      topArtists: topArtists,
      topAlbums: topAlbums,
      topGenres: topGenres,
      dailyCounts: dailyCounts,
      activityGrid: activityGrid,
      streak: streak,
    );
  }

  /// Credit given to a play with no listened time on record - plays from
  /// before listen tracking existed. Roughly an average partial listen, so a
  /// long pre-tracking history still counts without beating real full plays.
  static const _untrackedPlayCredit = 0.5;

  /// Assumed track length when a song's duration is unknown.
  static const _fallbackDurationMs = 210000;

  /// How much [song] was really listened to, in full plays: real listened
  /// time divided by the track length, plus [_untrackedPlayCredit] for each
  /// play without tracked time ([trackedPlays] = plays that have some).
  ///
  /// Like scrobbling on Last.fm or a stream counting on Spotify, a play only
  /// matters as far as it was actually heard: a skip after 5s of a 3-minute
  /// song is worth ~0.03, a full listen 1.0. Dividing by the track length
  /// keeps long songs from winning on minutes alone, and repeat-one loops
  /// (which never start a new play) still count every time through.
  static double listenScore(
    Song song, {
    required int trackedPlays,
    int trackedListenedMs = 0,
  }) {
    final durationMs = (song.duration ?? 0) > 0
        ? song.duration!
        : _fallbackDurationMs;
    final listened = trackedListenedMs > 0
        ? trackedListenedMs
        : (song.playCount * durationMs ~/ 2);
    final fullListens = listened / durationMs;
    final untrackedPlays = song.playCount - trackedPlays;
    return fullListens +
        (untrackedPlays > 0 ? untrackedPlays * _untrackedPlayCredit : 0);
  }

  /// Groups [songs] by a string key, sums their play counts and listen
  /// scores, sorts by score descending, and hands each group (plus a
  /// representative "sample" song for art/metadata) to [build]. Shared by the
  /// artist/album rankings.
  static List<T> _rankBy<T>(
    List<Song> songs, {
    required double Function(Song) scoreOf,
    required String Function(Song) keyOf,
    required int cap,
    required T Function(
      String name,
      int totalPlays,
      int songCount,
      double share,
      int rank,
      Song sample,
    )
    build,
  }) {
    final plays = <String, int>{};
    final scores = <String, double>{};
    final counts = <String, int>{};
    final samples = <String, Song>{};
    for (final song in songs) {
      final key = keyOf(song);
      plays[key] = (plays[key] ?? 0) + song.playCount;
      scores[key] = (scores[key] ?? 0) + scoreOf(song);
      counts[key] = (counts[key] ?? 0) + 1;
      // Prefer a sample that has artwork, for a nicer thumbnail.
      final existing = samples[key];
      if (existing == null ||
          (existing.artPath == null && song.artPath != null)) {
        samples[key] = song;
      }
    }

    final keys = plays.keys.toList()..sort(_byScoreThenPlays(scores, plays));
    final topScore = keys.isNotEmpty ? scores[keys.first]! : 0;

    return [
      for (var i = 0; i < keys.length && i < cap; i++)
        build(
          keys[i],
          plays[keys[i]]!,
          counts[keys[i]]!,
          topScore == 0 ? 0 : scores[keys[i]]! / topScore,
          i + 1,
          samples[keys[i]]!,
        ),
    ];
  }

  /// Orders group keys by listen score, then by raw plays.
  static int Function(String, String) _byScoreThenPlays(
    Map<String, double> scores,
    Map<String, int> plays,
  ) {
    return (a, b) {
      final byScore = scores[b]!.compareTo(scores[a]!);
      return byScore != 0 ? byScore : plays[b]!.compareTo(plays[a]!);
    };
  }

  static List<GenreStat> _computeGenres(
    List<Song> songs,
    double Function(Song) scoreOf,
    String unknownLabel,
  ) {
    final plays = <String, int>{};
    final scores = <String, double>{};
    final counts = <String, int>{};
    for (final song in songs) {
      final key = (song.genre == null || song.genre!.trim().isEmpty)
          ? unknownLabel
          : song.genre!;
      plays[key] = (plays[key] ?? 0) + song.playCount;
      scores[key] = (scores[key] ?? 0) + scoreOf(song);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    if (plays.isEmpty) return [];

    // Slices are sized by share of real listening, not by raw plays.
    final keys = plays.keys.toList()..sort(_byScoreThenPlays(scores, plays));
    final totalScore = scores.values.fold<double>(0, (a, b) => a + b);

    const maxSlices = 6;
    final result = <GenreStat>[];
    var otherPlays = 0;
    var otherScore = 0.0;
    var otherSongs = 0;
    for (var i = 0; i < keys.length; i++) {
      final key = keys[i];
      if (i < maxSlices || keys.length == maxSlices + 1) {
        result.add(
          GenreStat(
            name: key,
            totalPlays: plays[key]!,
            songCount: counts[key]!,
            fraction: totalScore == 0 ? 0 : scores[key]! / totalScore,
            color: GenreStat.colorAt(result.length),
          ),
        );
      } else {
        otherPlays += plays[key]!;
        otherScore += scores[key]!;
        otherSongs += counts[key]!;
      }
    }
    if (otherPlays > 0) {
      result.add(
        GenreStat(
          name: 'Other',
          totalPlays: otherPlays,
          songCount: otherSongs,
          fraction: totalScore == 0 ? 0 : otherScore / totalScore,
          color: Colors.white.withValues(alpha: 0.25),
        ),
      );
    }
    return result;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static List<DailyCount> _computeDailyCounts(
    List<PlayEvent> events, {
    DateTime? now,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    final counts = <DateTime, int>{};
    for (final e in events) {
      final day = _dateOnly(e.playedAt);
      counts[day] = (counts[day] ?? 0) + 1;
    }

    return [
      for (var i = 29; i >= 0; i--)
        DailyCount(
          date: today.subtract(Duration(days: i)),
          plays: counts[today.subtract(Duration(days: i))] ?? 0,
        ),
    ];
  }

  static List<DayPartCount> _computeActivityGrid(List<PlayEvent> events) {
    final grid = <int, int>{}; // key = weekday * 10 + dayPartIndex
    for (final e in events) {
      final part = DayPart.fromHour(e.playedAt.hour);
      final key = e.playedAt.weekday * 10 + part.index;
      grid[key] = (grid[key] ?? 0) + 1;
    }

    return [
      for (var weekday = 1; weekday <= 7; weekday++)
        for (final part in DayPart.values)
          DayPartCount(
            weekday: weekday,
            part: part,
            plays: grid[weekday * 10 + part.index] ?? 0,
          ),
    ];
  }

  static StreakInfo _computeStreak(List<PlayEvent> events, {DateTime? now}) {
    if (events.isEmpty) return StreakInfo.zero;

    final days = events.map((e) => _dateOnly(e.playedAt)).toSet().toList()
      ..sort();

    var longest = 1;
    var run = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        run++;
        if (run > longest) longest = run;
      } else {
        run = 1;
      }
    }

    final today = _dateOnly(now ?? DateTime.now());
    final daySet = days.toSet();
    var current = 0;
    var cursor = today;
    // A streak is still "current" if today OR yesterday has a play (so it
    // doesn't reset to 0 the moment midnight passes before today's first
    // listen), then walks backward while consecutive days have a play.
    if (!daySet.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    while (daySet.contains(cursor)) {
      current++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return StreakInfo(current: current, longest: longest);
  }
}

