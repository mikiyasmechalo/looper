import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import '../data/lyrics_fetcher.dart';
import '../domain/lyric_models.dart';

class LyricsState {
  final String? rawLrc;
  final bool isLoading;
  final int? songId;
  final List<LyricLine> parsedLines;
  final String? source;

  /// False for lyrics without timestamps: [parsedLines] then carry no
  /// times, and nothing may follow the song with them.
  final bool isSynced;

  /// The shown song's timing offset: its own, or the app default (see
  /// [lyricsShiftMs]).
  final int songOffsetMs;

  LyricsState({
    this.rawLrc,
    this.isLoading = false,
    this.songId,
    this.parsedLines = const [],
    this.source,
    this.isSynced = true,
    this.songOffsetMs = AppSettings.defaultLyricsOffsetMs,
  });

  LyricsState copyWith({
    String? rawLrc,
    bool? isLoading,
    int? songId,
    List<LyricLine>? parsedLines,
    String? source,
  }) {
    return LyricsState(
      rawLrc: rawLrc ?? this.rawLrc,
      isLoading: isLoading ?? this.isLoading,
      songId: songId ?? this.songId,
      parsedLines: parsedLines ?? this.parsedLines,
      source: source ?? this.source,
      isSynced: isSynced,
      songOffsetMs: songOffsetMs,
    );
  }
}

class LyricsNotifier extends StateNotifier<LyricsState> {
  final Ref ref;

  /// What [_applyLrcToState] last showed, so a lyrics offset change can
  /// re-time it in place.
  Song? _shownSong;
  String? _shownLrc;

  int _prefetchGeneration = 0;

  LyricsNotifier(this.ref) : super(LyricsState());

  void fetchForSong(Song song, {bool force = false}) {
    _prefetchGeneration++;
    _fetchLyrics(song, force: force);
  }

  /// Prefetches and caches lyrics for the next in-line song in the background.
  /// Uses a generation counter to cap concurrency strictly to 1 task and ensure
  /// rapid skipping cancels obsolete prefetch operations without stalling the active track.
  Future<void> prefetchNext(Song nextSong) async {
    if (state.songId == nextSong.id) return;
    final generation = ++_prefetchGeneration;

    try {
      final lrc = await LyricsFetcher.fetchLyrics(nextSong);
      if (generation != _prefetchGeneration) return;
      if (lrc != null && LyricsFetcher.canUpgrade(lrc)) {
        await LyricsFetcher.upgrade(nextSong, lrc);
      }
    } catch (_) {}
  }

  Future<void> _fetchLyrics(Song song, {bool force = false}) async {
    if (!force && state.songId == song.id && state.rawLrc != null) return;

    state = LyricsState(
      isLoading: true,
      songId: song.id,
      rawLrc: null,
      parsedLines: [],
      source: null,
    );

    final lrc = await LyricsFetcher.fetchLyrics(song);

    if (state.songId == song.id) {
      _applyLrcToState(song, lrc);
    }

    // Plain or line-synced lyrics are shown right away (above), then
    // swapped for a better level - line, word or letter timing - if a
    // service has one. Each service is asked about a song once; after
    // that this reads its saved answers and costs no request.
    if (lrc != null && LyricsFetcher.canUpgrade(lrc)) {
      final upgraded = await LyricsFetcher.upgrade(song, lrc);
      if (upgraded != null && state.songId == song.id) {
        _applyLrcToState(song, upgraded);
      }
    }
  }

  /// "Find word-synced lyrics" in the lyrics menu: the best word-timed
  /// lyrics the switched-on services have. Keeps the current lyrics (and
  /// returns false) when none has word timing for this song.
  Future<bool> findWordSynced(Song song) async {
    state = state.copyWith(isLoading: true);
    final lrc = await LyricsFetcher.findWordSynced(song);
    if (lrc != null) {
      _applyLrcToState(song, lrc);
      return true;
    }
    state = state.copyWith(isLoading: false);
    return false;
  }

  /// "Find synced lyrics" in the lyrics menu, for lyrics without
  /// timestamps: asks the switched-on services for synced ones. Keeps the
  /// current lyrics (and returns false) when none has them.
  Future<bool> findSynced(Song song) async {
    state = state.copyWith(isLoading: true);
    final lrc = await LyricsFetcher.findSynced(song);
    if (lrc != null) {
      _applyLrcToState(song, lrc);
      return true;
    }
    state = state.copyWith(isLoading: false);
    return false;
  }

  /// Lyrics menu provider pick ('Local' = the song's own files). With
  /// auto-fallback on, the rest of the lookup chain is tried after it.
  /// Returns the source the lyrics came from (e.g. 'lrclib', 'embedded'),
  /// or null when nothing was found - the current lyrics then stay.
  Future<String?> fetchWithProvider(Song song, String provider) async {
    state = state.copyWith(isLoading: true);
    final lrc = await LyricsFetcher.fetchWithProvider(song, provider);
    if (lrc == null) {
      state = state.copyWith(isLoading: false);
      return null;
    }
    _applyLrcToState(song, lrc);
    return state.source;
  }

  Future<void> applyCustomLyrics(Song song, String rawContent) async {
    state = state.copyWith(isLoading: true);
    await LyricsFetcher.store(
      song,
      (song.artist ?? 'Unknown Artist').trim(),
      song.title.trim(),
      '[source:custom_file]\n$rawContent',
    );
    _applyLrcToState(song, '[source:custom_file]\n$rawContent');
  }

  /// Sets [song]'s lyrics timing offset (positive = earlier). It only ever
  /// applies to that song; the default is stored as "none", so the song
  /// follows [AppSettings.defaultLyricsOffsetMs] again.
  Future<void> updateSongOffsetMs(Song song, int value) async {
    final int clamped = value.clamp(-5000, 5000);
    final int? offset = clamped == AppSettings.defaultLyricsOffsetMs
        ? null
        : clamped;

    song.lyricsOffsetMs = offset;
    ref.read(playbackProvider.notifier).updateSongLyricsOffset(song.id, offset);
    final shown = _shownSong;
    if (shown != null && shown.id == song.id && state.songId == song.id) {
      shown.lyricsOffsetMs = offset;
      _applyLrcToState(shown, _shownLrc);
    }

    await DbService.isar.writeTxn(() async {
      final dbSong = await DbService.isar.songs.get(song.id);
      if (dbSong != null) {
        dbSong.lyricsOffsetMs = offset;
        await DbService.isar.songs.put(dbSong);
      }
    });
  }

  void _applyLrcToState(Song song, String? lrc) {
    String? source;
    String? cleanLrc = lrc;
    if (lrc != null && lrc.startsWith('[source:')) {
      final sourceMatch = RegExp(r'^\[source:(.*)\]').firstMatch(lrc);
      if (sourceMatch != null) {
        source = sourceMatch.group(1);
        cleanLrc = lrc.replaceFirst(RegExp(r'^\[source:.*\]\n?'), '');
      }
    }

    _shownSong = song;
    _shownLrc = lrc;
    final lines = cleanLrc != null
        ? LrcParser.parse(
            cleanLrc,
            Duration(milliseconds: song.duration ?? 0),
            // The offset is positive = earlier; the parser's shift is
            // positive = later.
            shift: Duration(milliseconds: -lyricsShiftMs(song.lyricsOffsetMs)),
          )
        : <LyricLine>[];

    state = LyricsState(
      rawLrc: cleanLrc,
      isLoading: false,
      parsedLines: lines,
      source: source,
      isSynced: cleanLrc == null || LrcParser.isTimed(cleanLrc),
      songId: song.id,
      songOffsetMs: lyricsShiftMs(song.lyricsOffsetMs),
    );
  }
}

/// A song's lyrics timing offset: its own when the user re-timed it, else
/// the app default.
int lyricsShiftMs(int? songMs) => songMs ?? AppSettings.defaultLyricsOffsetMs;

final lyricsProvider = StateNotifierProvider<LyricsNotifier, LyricsState>((
  ref,
) {
  return LyricsNotifier(ref);
});

class LyricsManualScrollNotifier extends StateNotifier<bool> {
  LyricsManualScrollNotifier() : super(false);
  void set(bool value) => state = value;
}

final lyricsManualScrollProvider =
    StateNotifierProvider<LyricsManualScrollNotifier, bool>((ref) {
      return LyricsManualScrollNotifier();
    });

class LyricsFullscreenNotifier extends StateNotifier<bool> {
  LyricsFullscreenNotifier() : super(false);

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      try {
        await windowManager.setFullScreen(value);
      } catch (_) {}
    }
  }
}

final lyricsFullscreenProvider =
    StateNotifierProvider<LyricsFullscreenNotifier, bool>((ref) {
      return LyricsFullscreenNotifier();
    });

class LyricsActiveLineVisibleNotifier extends StateNotifier<bool> {
  LyricsActiveLineVisibleNotifier() : super(true);
  void set(bool value) => state = value;
}

final lyricsActiveLineVisibleProvider =
    StateNotifierProvider<LyricsActiveLineVisibleNotifier, bool>((ref) {
      return LyricsActiveLineVisibleNotifier();
    });
