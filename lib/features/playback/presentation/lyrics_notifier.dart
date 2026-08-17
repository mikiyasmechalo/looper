import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import '../data/lyrics_fetcher.dart';
import '../domain/lyric_models.dart';

class LyricsState {
  final String? rawLrc;
  final bool isLoading;
  final int? songId;
  final List<LyricLine> parsedLines;
  final String? source;
  final int syncOffsetMs;

  LyricsState({
    this.rawLrc,
    this.isLoading = false,
    this.songId,
    this.parsedLines = const [],
    this.source,
    this.syncOffsetMs = 0,
  });

  LyricsState copyWith({
    String? rawLrc,
    bool? isLoading,
    int? songId,
    List<LyricLine>? parsedLines,
    String? source,
    int? syncOffsetMs,
  }) {
    return LyricsState(
      rawLrc: rawLrc ?? this.rawLrc,
      isLoading: isLoading ?? this.isLoading,
      songId: songId ?? this.songId,
      parsedLines: parsedLines ?? this.parsedLines,
      source: source ?? this.source,
      syncOffsetMs: syncOffsetMs ?? this.syncOffsetMs,
    );
  }
}

class LyricsNotifier extends StateNotifier<LyricsState> {
  final Ref ref;

  LyricsNotifier(this.ref) : super(LyricsState());

  void fetchForSong(Song song, {bool force = false}) {
    _fetchLyrics(song, force: force);
  }

  Future<void> _fetchLyrics(Song song, {bool force = false}) async {
    if (!force && state.songId == song.id && state.rawLrc != null) return;

    final songOffset = song.lyricsOffsetMs ?? 0;

    state = LyricsState(
      isLoading: true,
      songId: song.id,
      rawLrc: null,
      parsedLines: [],
      source: null,
      syncOffsetMs: songOffset,
    );

    final lrc = await LyricsFetcher.fetchLyrics(song);

    if (state.songId == song.id) {
      String? source;
      String cleanLrc = lrc ?? '';
      if (lrc != null && lrc.startsWith('[source:')) {
        final sourceMatch = RegExp(r'^\[source:(.*)\]').firstMatch(lrc);
        if (sourceMatch != null) {
          source = sourceMatch.group(1);
          cleanLrc = lrc.replaceFirst(RegExp(r'^\[source:.*\]\n?'), '');
        }
      }

      final lines = lrc != null
          ? LrcParser.parse(
              cleanLrc,
              Duration(milliseconds: song.duration ?? 0),
              manualOffsetMs: songOffset,
            )
          : <LyricLine>[];
      state = state.copyWith(
        rawLrc: cleanLrc,
        isLoading: false,
        parsedLines: lines,
        source: source,
        syncOffsetMs: songOffset,
      );
    }
  }

  Future<void> adjustOffset(Song song, int deltaMs) async {
    final raw = state.rawLrc;
    if (raw == null) return;

    final newOffset = state.syncOffsetMs + deltaMs;
    final lines = LrcParser.parse(
      raw,
      Duration(milliseconds: song.duration ?? 0),
      manualOffsetMs: newOffset,
    );

    state = state.copyWith(
      syncOffsetMs: newOffset,
      parsedLines: lines,
    );

    song.lyricsOffsetMs = newOffset == 0 ? null : newOffset;
    try {
      await DbService.isar.writeTxn(() async {
        final dbSong = await DbService.isar.songs.get(song.id);
        if (dbSong != null) {
          dbSong.lyricsOffsetMs = song.lyricsOffsetMs;
          await DbService.isar.songs.put(dbSong);
        }
      });
    } catch (_) {}
  }

  Future<void> resetOffset(Song song) async {
    final raw = state.rawLrc;
    if (raw == null) return;

    final lines = LrcParser.parse(
      raw,
      Duration(milliseconds: song.duration ?? 0),
      manualOffsetMs: 0,
    );

    state = state.copyWith(
      syncOffsetMs: 0,
      parsedLines: lines,
    );

    song.lyricsOffsetMs = null;
    try {
      await DbService.isar.writeTxn(() async {
        final dbSong = await DbService.isar.songs.get(song.id);
        if (dbSong != null) {
          dbSong.lyricsOffsetMs = null;
          await DbService.isar.songs.put(dbSong);
        }
      });
    } catch (_) {}
  }
}

final lyricsProvider = StateNotifierProvider<LyricsNotifier, LyricsState>((
  ref,
) {
  return LyricsNotifier(ref);
});

final lyricsManualScrollProvider = StateProvider<bool>((ref) => false);
