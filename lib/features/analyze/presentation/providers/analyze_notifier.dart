import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/analyze/domain/analyze_models.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';

/// Recent play-event log, newest first, capped generously so the trend
/// chart, streaks, and activity heatmap have plenty of history to work with.
final playEventsProvider = StreamProvider<List<PlayEvent>>((ref) {
  return DbService.isar.playbackHistoryEntrys
      .where()
      .sortByTimestampDesc()
      .limit(5000)
      .watch(fireImmediately: true)
      .map((entries) => entries
          .map((e) => PlayEvent(
                songPath: e.songPath,
                songTitle: e.title,
                artist: e.artist,
                album: e.album,
                genre: e.genre,
                durationMs: e.durationMs,
                listenedMs: e.listenedMs,
                playedAt: e.timestamp,
              ))
          .toList());
});

/// The full computed Looper Analyze report, recomputed whenever the library
/// or play-event log changes. Reuses [libraryProvider] instead of watching
/// songs a second time.
final analyzeSnapshotProvider = Provider<AnalyzeSnapshot>((ref) {
  final library = ref.watch(libraryProvider);
  final events = ref.watch(playEventsProvider).value ?? [];

  if (!library.isInitialized) return AnalyzeSnapshot.empty;

  return AnalyzeSnapshot.compute(
    songs: library.songs,
    events: events,
    artists: library.artists,
  );
});

/// The Top Songs list toggle: 10 or 20 entries shown.
final analyzeTopSongsLimitProvider = StateProvider<int>((ref) => 10);

