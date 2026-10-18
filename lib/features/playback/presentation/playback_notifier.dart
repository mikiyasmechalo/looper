import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/logger_helper.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/core/providers.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/core/discord_rpc_service.dart';
import 'package:looper_player/core/scrobbler_service.dart';
import 'package:looper_player/core/memory_service.dart';
import 'package:looper_player/features/library/data/scanner.dart';
import 'package:window_manager/window_manager.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/features/playback/presentation/lyrics_notifier.dart';
import 'package:looper_player/features/playback/presentation/equalizer_notifier.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:isar/isar.dart';
import 'package:local_notifier/local_notifier.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:looper_player/core/tag_writer_service.dart';
import 'package:looper_player/features/playback/data/queue_repository.dart';
import 'package:looper_player/core/app_toast.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum RepeatMode { off, all, one }

enum FileActionResult { success, dbOnly, failure }

class PlaybackState {
  final Song? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isShuffle;
  final RepeatMode repeatMode;
  final double volume;

  final bool isScrubbing;
  final List<Song> queue;

  /// True when a song was loaded from saved state on startup but playback
  /// hasn't started yet (resumeOnStart = false). The player bar is hidden
  /// when this is true and isPlaying is false, preventing the stale
  /// "paused song" ghost bar from showing on every cold start.
  final bool isRestoredSession;

  final bool isSleepTimerActive;
  final Duration? sleepTimerDurationRemaining;
  final int? sleepTimerSongsRemaining;
  final Duration? sleepTimerDurationInitial;
  final int? sleepTimerSongsInitial;

  final Duration? loopStart;
  final Duration? loopEnd;
  final bool isABLooping;

  final bool isVocalReducerActive;
  final double vocalReducerStrength;

  PlaybackState({
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffle = false,
    this.repeatMode = RepeatMode.off,
    this.volume = 1.0,
    this.isScrubbing = false,
    this.queue = const [],
    this.isRestoredSession = false,
    this.isSleepTimerActive = false,
    this.sleepTimerDurationRemaining,
    this.sleepTimerSongsRemaining,
    this.sleepTimerDurationInitial,
    this.sleepTimerSongsInitial,
    this.loopStart,
    this.loopEnd,
    this.isABLooping = false,
    this.isVocalReducerActive = false,
    this.vocalReducerStrength = 1.0,
  });

  PlaybackState copyWith({
    Object? currentSong = _sentinel,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isShuffle,
    RepeatMode? repeatMode,
    double? volume,
    bool? isScrubbing,
    List<Song>? queue,
    bool? isRestoredSession,
    bool? isSleepTimerActive,
    Object? sleepTimerDurationRemaining = _sentinel,
    Object? sleepTimerSongsRemaining = _sentinel,
    Object? sleepTimerDurationInitial = _sentinel,
    Object? sleepTimerSongsInitial = _sentinel,
    Object? loopStart = _sentinel,
    Object? loopEnd = _sentinel,
    bool? isABLooping,
    bool? isVocalReducerActive,
    double? vocalReducerStrength,
  }) {
    return PlaybackState(
      currentSong: currentSong == _sentinel ? this.currentSong : currentSong as Song?,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isShuffle: isShuffle ?? this.isShuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      volume: volume ?? this.volume,
      isScrubbing: isScrubbing ?? this.isScrubbing,
      queue: queue ?? this.queue,
      isRestoredSession: isRestoredSession ?? this.isRestoredSession,
      isSleepTimerActive: isSleepTimerActive ?? this.isSleepTimerActive,
      sleepTimerDurationRemaining: sleepTimerDurationRemaining == _sentinel 
          ? this.sleepTimerDurationRemaining 
          : sleepTimerDurationRemaining as Duration?,
      sleepTimerSongsRemaining: sleepTimerSongsRemaining == _sentinel 
          ? this.sleepTimerSongsRemaining 
          : sleepTimerSongsRemaining as int?,
      sleepTimerDurationInitial: sleepTimerDurationInitial == _sentinel 
          ? this.sleepTimerDurationInitial 
          : sleepTimerDurationInitial as Duration?,
      sleepTimerSongsInitial: sleepTimerSongsInitial == _sentinel 
          ? this.sleepTimerSongsInitial 
          : sleepTimerSongsInitial as int?,
      loopStart: loopStart == _sentinel ? this.loopStart : loopStart as Duration?,
      loopEnd: loopEnd == _sentinel ? this.loopEnd : loopEnd as Duration?,
      isABLooping: isABLooping ?? this.isABLooping,
      isVocalReducerActive: isVocalReducerActive ?? this.isVocalReducerActive,
      vocalReducerStrength: vocalReducerStrength ?? this.vocalReducerStrength,
    );
  }
}

const _sentinel = Object();

class PlaybackNotifier extends StateNotifier<PlaybackState> {
  final Ref ref;
  late final Player player;
  List<Song> _playlist = [];
  List<Song> _originalPlaylist = [];
  int _currentIndex = -1;
  bool _isTransitioning = false;
  bool _autoCrossfadeTriggered = false;
  bool _isLastPlayManual = true;
  int _activeCrossfadeId = 0;
  int _activeSeekId = 0;
  final int _activePlayPauseId = 0;
  bool? _targetPlayingState;
  bool _isTogglePlaying = false;
  Timer? _silenceTimer;
  Timer? _songCompletionTimer;
  Timer? _playCountTimer;
  String? _playCountedPath;
  int _lastPositionPersistTime = 0;
  int _manualQueueCount = 0;
  DateTime _lastSeekTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastPlayTime = DateTime.fromMillisecondsSinceEpoch(0);
  bool _isDucked = false;
  final QueueRepository _queueRepo = QueueRepository();
  String _activeQueueName = '';

  PlaybackNotifier(this.ref) : super(PlaybackState()) {
    player = ref.read(audioServiceProvider).player;
    ref.read(audioServiceProvider).onNext = skipNext;
    ref.read(audioServiceProvider).onPrevious = skipPrevious;
    ref.read(audioServiceProvider).onSeek = (duration) => seek(duration);
    ref.read(audioServiceProvider).onFavoriteToggle = toggleFavorite;
    ref.read(audioServiceProvider).onShuffleToggle = toggleShuffle;
    ref.read(audioServiceProvider).onRepeatToggle = nextRepeatMode;
    ref.read(audioServiceProvider).onPlay = () {
      if (!state.isPlaying) togglePlay();
    };
    ref.read(audioServiceProvider).onPause = () {
      if (state.isPlaying) togglePlay();
    };
    ref.read(audioServiceProvider).onPlayPause = togglePlay;
    _init();
    ref.listen<AppSettings>(settingsProvider, (previous, next) {
      if (previous?.enableAudioCache != next.enableAudioCache ||
          previous?.audioCacheSizeMB != next.audioCacheSizeMB ||
          previous?.audioCacheSecs != next.audioCacheSecs ||
          previous?.audioBackCacheSizeMB != next.audioBackCacheSizeMB) {
        ref.read(audioServiceProvider).configureCache(
          enabled: next.enableAudioCache,
          maxBytes: next.audioCacheSizeMB * 1024 * 1024,
          cacheSecs: next.audioCacheSecs,
          backBytes: next.audioBackCacheSizeMB * 1024 * 1024,
        );
      }
      if (previous?.exclusiveHardwareMode != next.exclusiveHardwareMode) {
        ref.read(audioServiceProvider).configureHardwareExclusive(next.exclusiveHardwareMode);
      }
      if (previous?.gaplessPlayback != next.gaplessPlayback) {
        ref.read(audioServiceProvider).setGaplessAudio(next.gaplessPlayback);
      }
      if (previous?.autoTrimSilence != next.autoTrimSilence) {
        ref.read(equalizerProvider.notifier).setSilenceTrimEnabled(next.autoTrimSilence);
      }
    });
  }

  void _updateNotification() {
    final song = state.currentSong;
    if (song != null) {
      final audioSvc = ref.read(audioServiceProvider);
      audioSvc.updateMediaSessionMetadata(
        title: song.title,
        artist: song.artist ?? 'Unknown Artist',
        album: song.album ?? 'Unknown Album',
        artPath: song.artPath,
        duration: song.duration != null ? Duration(milliseconds: song.duration!) : null,
        isFavorite: song.isFavorite,
      );
      DiscordRpcService.instance.updatePresence(
        song: song,
        position: state.position,
        duration: state.duration,
        isPlaying: state.isPlaying,
      );
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        windowManager.setTitle('Looper - ${song.title} - ${song.artist ?? 'Unknown Artist'}');
      }
    } else {
      DiscordRpcService.instance.clearPresence();
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        windowManager.setTitle('Looper');
      }
    }
  }

  Future<void> _init() async {
    player.stream.error.listen((err) {
      LoggerHelper.write('Mpv Player Error: $err');
    });

    player.stream.playing.listen((playing) {
      if (_isTogglePlaying) {
        // Ignore native player updates while in the middle of play/pause transitions
        return;
      }
      if (!playing) {
        if (_isTransitioning || _autoCrossfadeTriggered || player.state.completed) {
          // Ignore temporary pause/stop events while transitioning/opening a new song
          return;
        }
        // If the song is near its end or has completed, ignore playing: false because it's completing
        final remaining = state.duration - state.position;
        if (state.duration > Duration.zero && remaining.inMilliseconds < 6000) {
          return;
        }
        final now = DateTime.now();
        if (now.difference(_lastPlayTime).inMilliseconds < 1500) {
          return;
        }
      }
      if (state.isScrubbing) {

        // Ignore playing state changes while the user is scrubbing the seek bar
        // to prevent the play/pause button from flickering
        return;
      }
      if (DateTime.now().difference(_lastSeekTime).inMilliseconds < 400) {

        // Ignore playing state changes immediately after a seek/scrub operation
        // to prevent play/pause button state flickering
        return;
      }

      state = state.copyWith(isPlaying: playing);
      _updateNotification();
      if (!playing) {
        if (ref.read(settingsProvider).persistQueue) {
          ref.read(settingsProvider.notifier).updateLastPosition(state.position.inMilliseconds);
        }
        Future.delayed(const Duration(milliseconds: 500), MemoryService.trimWorkingSet);
      }
    });

    player.stream.position.listen((position) {
      // Enforce A-B Section Loop
      if (state.isABLooping &&
          state.loopStart != null &&
          state.loopEnd != null &&
          state.loopEnd! > state.loopStart!) {
        if (!state.isScrubbing && position >= state.loopEnd!) {
          seek(state.loopStart!);
          return;
        }
      }

      if (!state.isScrubbing) {
        state = state.copyWith(position: position);
      }

      // Check and trigger automatic crossfade
      if (state.isPlaying &&
          !state.isScrubbing &&
          !_autoCrossfadeTriggered &&
          !_isTransitioning &&
          state.repeatMode != RepeatMode.one &&
          state.duration > const Duration(seconds: 4)) {
        final settings = ref.read(settingsProvider);
        final crossfadeSec = settings.crossfadeDuration;
        final isAutoAllowed = settings.crossfadeMode == 0 || settings.crossfadeMode == 1;
        if (crossfadeSec > 0 && isAutoAllowed) {
          final remaining = state.duration - position;
          if (remaining <= Duration(seconds: crossfadeSec) && remaining.inMilliseconds > 200) {
            _autoCrossfadeTriggered = true;
            _performAutoCrossfade(crossfadeSec);
          }
        }
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      if (state.isPlaying && now - _lastPositionPersistTime > 30000) {
        _lastPositionPersistTime = now;
        if (ref.read(settingsProvider).persistQueue) {
          ref.read(settingsProvider.notifier).updateLastPosition(position.inMilliseconds);
        }
      }
    });

    player.stream.duration.listen((duration) {
      if (duration != Duration.zero) {
        state = state.copyWith(duration: duration);
      }
    });

    DateTime? lastCompletedTime;
    player.stream.completed.listen((completed) {
      debugPrint("======== COMPLETED ========");
      debugPrint("completed = $completed");
      debugPrint("position  = ${player.state.position}");
      debugPrint("duration  = ${player.state.duration}");
      debugPrint("playlist completed = ${player.state.completed}");

      if (completed) {
        if (_isTransitioning) {

          return;
        }
        _isTransitioning = true;
        final now = DateTime.now();
        if (now.difference(_lastPlayTime).inMilliseconds < 1500) {
          _isTransitioning = false;
          return;
        }
        if (lastCompletedTime != null && now.difference(lastCompletedTime!).inMilliseconds < 1000) {
          _isTransitioning = false;
          return;
        }
        lastCompletedTime = now;

        _songCompletionTimer?.cancel();

        void onSongFinished() {
          if (state.isSleepTimerActive && state.sleepTimerSongsRemaining != null) {
            final remaining = state.sleepTimerSongsRemaining! - 1;
            if (remaining <= 0) {
              state = state.copyWith(
                isSleepTimerActive: false,
                sleepTimerSongsRemaining: null,
                sleepTimerSongsInitial: null,
                sleepTimerDurationRemaining: null,
                sleepTimerDurationInitial: null,
                isPlaying: false,
              );
              _isTransitioning = false;
              AppToast.show(
                title: 'Sleep Timer Finished',
                subtitle: 'Advanced to next track & paused',
                iconData: LucideIcons.moon,
              );
              skipNext(isManual: false, shouldPlay: false);
              return;
            } else {
              state = state.copyWith(sleepTimerSongsRemaining: remaining);
            }
          }

          _isLastPlayManual = false;

          if (state.repeatMode == RepeatMode.one) {
            _isTransitioning = false;
            player.seek(Duration.zero);
            ref.read(audioServiceProvider).resume();
          } else {
            _isTransitioning = true;
            skipNext(isManual: false);
          }
        }

        onSongFinished();
      }
    });

    player.stream.playlist.listen((playlist) async {
      if (playlist.index > 0 && playlist.items.length > 1) {
        // Native gapless transition occurred!
        debugPrint("======== NATIVE PLAYLIST ADVANCED ========");
        debugPrint("playlist.index = ${playlist.index}");
        
        if (!_isTransitioning) {
          _isTransitioning = true;
          _songCompletionTimer?.cancel();
          _isLastPlayManual = false;
          
          final songToPlay = getNextSong(updateIndex: true);
          final svc = ref.read(audioServiceProvider);
          
          if (songToPlay != null) {
            _autoCrossfadeTriggered = false;
            state = state.copyWith(
              currentSong: songToPlay,
              duration: songToPlay.duration != null ? Duration(milliseconds: songToPlay.duration!) : Duration.zero,
              position: Duration.zero,
              isRestoredSession: false,
            );
            ref.read(lyricsProvider.notifier).fetchForSong(songToPlay);
            _maybePrefetchNextLyrics();
            ref.read(equalizerProvider.notifier).onSongChanged(songToPlay);
            
            final settings = ref.read(settingsProvider);
            final equalizerState = ref.read(equalizerProvider);
            final gains = equalizerState.currentSongGains;
            svc.setEqualizerGains(
              gains, 
              settings.equalizerEnabled,
              customFilter: equalizerState.customFilterString,
            );
            
            _updateNotification();
            _armPlayCount(songToPlay);
            
            if (settings.persistQueue) {
              ref.read(settingsProvider.notifier).updateLastPlayedSong(songToPlay.id);
            }
            
            if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
              windowManager.setTitle('Looper - ${songToPlay.title} - ${songToPlay.artist ?? 'Unknown Artist'}');
            }
            
            // Remove the finished track from native playlist so index becomes 0 again
            await svc.player.remove(0);
            
            // Enqueue the next-next track
            if (settings.crossfadeDuration == 0) {
              final nextNext = getNextSong(updateIndex: false);
              if (nextNext != null) {
                await svc.enqueueNext(nextNext.path, metadata: {
                  'title': nextNext.title,
                  'artist': nextNext.artist ?? 'Unknown Artist',
                  'album': nextNext.album ?? 'Unknown Album',
                  if (nextNext.artPath != null) 'artPath': nextNext.artPath!,
                  if (nextNext.duration != null) 'duration': nextNext.duration!.toString(),
                });
              }
            }
          } else {
            // Queue ended, just stop
            await svc.pause();
            state = state.copyWith(isPlaying: false);
            await svc.player.remove(0);
          }
          
          _isTransitioning = false;
        }
      }
    });

    // Wait for settings to load
    await ref.read(settingsProvider.notifier).initialization;

    // Load last settings
    final settings = ref.read(settingsProvider);
    _activeQueueName = settings.activeQueueName;
    state = state.copyWith(
      volume: settings.volume,
      isShuffle: settings.shuffle,
      repeatMode: RepeatMode.values[settings.repeatMode],
    );
    player.setVolume(settings.volume * 100);

    // Apply cache and hardware configurations
    final audioSvc = ref.read(audioServiceProvider);
    audioSvc.applyAudioFocusPolicy(_getInterruptionPolicy());
    await audioSvc.configureCache(
      enabled: settings.enableAudioCache,
      maxBytes: settings.audioCacheSizeMB * 1024 * 1024,
      cacheSecs: settings.audioCacheSecs,
      backBytes: settings.audioBackCacheSizeMB * 1024 * 1024,
    );
    await audioSvc.configureHardwareExclusive(settings.exclusiveHardwareMode);

    final savedSongIds = settings.lastQueueSongIds;
    final savedIndex = settings.lastQueueIndex;
    
    // If a track is already playing/loaded from startup file arguments, do not overwrite it with the saved session
    if (state.currentSong != null && !state.isRestoredSession) {
      await _ensureDynamicQueue();
      return;
    }

    if (settings.persistQueue && savedSongIds.isNotEmpty) {
      final rawSongs = await DbService.isar.songs.getAll(savedSongIds);
      final List<Song> loadedSongs = rawSongs.whereType<Song>().toList();
      if (loadedSongs.isNotEmpty) {
        if (state.currentSong != null && !state.isRestoredSession) return;
        _playlist = loadedSongs;
        _originalPlaylist = List.from(loadedSongs);
        _currentIndex = (savedIndex >= 0 && savedIndex < loadedSongs.length) ? savedIndex : 0;
        final song = _playlist[_currentIndex];
        state = state.copyWith(
          queue: List.from(_playlist),
          currentSong: song,
          isRestoredSession: true,
          position: Duration(milliseconds: settings.lastPositionMs),
          duration: song.duration != null ? Duration(milliseconds: song.duration!) : Duration.zero,
        );
        ref.read(lyricsProvider.notifier).fetchForSong(song);
        ref.read(equalizerProvider.notifier).onSongChanged(song);
        
        final initialPos = Duration(milliseconds: settings.lastPositionMs);
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (state.currentSong != null && !state.isRestoredSession) return;
          await play(song, forceDisableCrossfade: true, play: settings.resumeOnStart, initialPosition: initialPos);
        });
      }
    } else if (settings.persistQueue && settings.lastPlayedSongId != null) {
      final song = await DbService.isar.songs.get(settings.lastPlayedSongId!);
      if (song != null) {
        if (state.currentSong != null && !state.isRestoredSession) return;
        state = state.copyWith(
          currentSong: song,
          isRestoredSession: true,
          position: Duration(milliseconds: settings.lastPositionMs),
          duration: song.duration != null ? Duration(milliseconds: song.duration!) : Duration.zero,
        );
        ref.read(lyricsProvider.notifier).fetchForSong(song);
        ref.read(equalizerProvider.notifier).onSongChanged(song);
        _playlist = [song];
        _currentIndex = 0;
        
        final initialPos = Duration(milliseconds: settings.lastPositionMs);
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (state.currentSong != null && !state.isRestoredSession) return;
          await play(song, forceDisableCrossfade: true, play: settings.resumeOnStart, initialPosition: initialPos);
        });
      }
    } else {
      await ref.read(settingsProvider.notifier).updateLastQueueState([], -1, null, positionMs: 0);
    }

    // Ensure dynamic queue is populated right after startup loading finishes
    await _ensureDynamicQueue();
  }

  Future<void> playAtIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      final endOfManual = _currentIndex + _manualQueueCount;
      _manualQueueCount = (index < endOfManual) ? endOfManual - index : 0;
      _currentIndex = index;
      await play(_playlist[_currentIndex]);
    }
  }

  void setPlaylist(
    List<Song> songs, {
    int initialIndex = 0,
    String? queueName,
    bool disableShuffle = false,
  }) {
    if (queueName != null && queueName != _activeQueueName) {
      if (_activeQueueName.isNotEmpty && _playlist.isNotEmpty) {
        _persistNamedQueue(
          _activeQueueName,
          songs: List.from(_playlist),
          currentIndex: _currentIndex,
          positionMs: state.position.inMilliseconds,
          isShuffle: state.isShuffle,
        );
      }
      _activeQueueName = queueName;
      ref.read(settingsProvider.notifier).updateActiveQueueName(queueName);
    }

    if (disableShuffle && state.isShuffle) {
      state = state.copyWith(isShuffle: false);
      ref.read(settingsProvider.notifier).updateShuffle(false);
    }

    // Extract manual queue songs before replacing the playlist
    final start = _currentIndex + 1;
    final end = (start + _manualQueueCount).clamp(0, _playlist.length);
    final manualSongs = (start < _playlist.length) ? _playlist.sublist(start, end) : <Song>[];

    _originalPlaylist = List.from(songs);

    if (state.isShuffle) {
      if (songs.isNotEmpty) {
        final currentSong = songs[initialIndex];
        final remaining = List<Song>.from(songs)..removeAt(initialIndex);
        remaining.shuffle();
        _playlist = [currentSong, ...remaining];
        _currentIndex = 0;
      } else {
        _playlist = [];
        _currentIndex = -1;
      }
    } else {
      _playlist = List.from(songs);
      _currentIndex = initialIndex;
    }

    // Re-insert manual queue songs after the new current song
    if (_currentIndex != -1 && manualSongs.isNotEmpty) {
      _playlist.insertAll(_currentIndex + 1, manualSongs);
      // Also insert into _originalPlaylist at corresponding position
      final origIdx = _originalPlaylist.indexWhere((s) => s.path == _playlist[_currentIndex].path);
      if (origIdx != -1) {
        _originalPlaylist.insertAll(origIdx + 1, manualSongs);
      } else {
        _originalPlaylist.addAll(manualSongs);
      }
      _manualQueueCount = manualSongs.length;
    } else {
      _manualQueueCount = 0;
    }

    state = state.copyWith(queue: List.from(_playlist));
    if (_playlist.isNotEmpty && _currentIndex != -1) {
      play(_playlist[_currentIndex]);
    }
    _saveQueueState();
  }

  Future<void> switchToSavedQueue(SavedQueue savedQueue) async {
    if (savedQueue.name == _activeQueueName) return;
    final wasPlaying = state.isPlaying;

    if (_activeQueueName.isNotEmpty && _playlist.isNotEmpty) {
      await _persistNamedQueue(
        _activeQueueName,
        songs: List.from(_playlist),
        currentIndex: _currentIndex,
        positionMs: state.position.inMilliseconds,
        isShuffle: state.isShuffle,
      );
    }

    final rawSongs = await DbService.isar.songs.getAll(savedQueue.songIds);
    final songs = rawSongs.whereType<Song>().toList();

    if (songs.isEmpty && savedQueue.name == QueueRepository.allSongsQueueName) {
      final all = await DbService.isar.songs.where().findAll();
      songs.addAll(all);
    }
    if (songs.isEmpty) return;

    _activeQueueName = savedQueue.name;
    _playlist = songs;
    _originalPlaylist = List.from(songs);
    _currentIndex = (savedQueue.currentIndex >= 0 && savedQueue.currentIndex < songs.length)
        ? savedQueue.currentIndex
        : 0;
    _manualQueueCount = 0;

    state = state.copyWith(
      queue: List.from(_playlist),
      isShuffle: savedQueue.isShuffle,
    );

    await ref.read(settingsProvider.notifier).updateActiveQueueName(savedQueue.name);

    final targetSong = _playlist[_currentIndex];
    final targetPos = Duration(milliseconds: savedQueue.positionMs);

    await play(
      targetSong,
      forceDisableCrossfade: true,
      play: wasPlaying,
      initialPosition: targetPos,
    );

    await _saveQueueState();
  }

  Future<void> deleteQueue(String name) async {
    await _queueRepo.delete(name);
  }

  /// Starts playback of [songs] in a fully shuffled order, including a
  /// random first song, and turns shuffle mode on.
  Future<void> playShuffled(List<Song> songs, {String? queueName}) async {
    if (songs.isEmpty) return;

    if (queueName != null && queueName != _activeQueueName) {
      if (_activeQueueName.isNotEmpty && _playlist.isNotEmpty) {
        await _persistNamedQueue(
          _activeQueueName,
          songs: List.from(_playlist),
          currentIndex: _currentIndex,
          positionMs: state.position.inMilliseconds,
          isShuffle: state.isShuffle,
        );
      }
      _activeQueueName = queueName;
      await ref.read(settingsProvider.notifier).updateActiveQueueName(queueName);
    }

    _originalPlaylist = List.from(songs);
    _playlist = List<Song>.from(songs)..shuffle();
    _currentIndex = 0;
    _manualQueueCount = 0;

    if (!state.isShuffle) {
      state = state.copyWith(isShuffle: true);
      await ref.read(settingsProvider.notifier).updateShuffle(true);
    }

    state = state.copyWith(queue: List.from(_playlist));
    play(_playlist[_currentIndex]);
    await _saveQueueState();
    _updateNotification();
  }

  /// Shuffles the album/artist order but keeps each group's songs together as a
  /// contiguous block, so e.g. "shuffle albums" plays whole albums at once.
  Future<void> playShuffledGrouped(List<List<Song>> groups, {String? queueName}) async {
    final nonEmpty = groups.where((g) => g.isNotEmpty).toList();
    if (nonEmpty.isEmpty) return;

    if (queueName != null && queueName != _activeQueueName) {
      if (_activeQueueName.isNotEmpty && _playlist.isNotEmpty) {
        await _persistNamedQueue(
          _activeQueueName,
          songs: List.from(_playlist),
          currentIndex: _currentIndex,
          positionMs: state.position.inMilliseconds,
          isShuffle: state.isShuffle,
        );
      }
      _activeQueueName = queueName;
      await ref.read(settingsProvider.notifier).updateActiveQueueName(queueName);
    }

    final shuffledGroups = List<List<Song>>.from(nonEmpty)..shuffle();
    final queue = <Song>[];
    final seen = <String>{};
    for (final group in shuffledGroups) {
      for (final s in group) {
        if (seen.add(s.path)) queue.add(s);
      }
    }
    if (queue.isEmpty) return;

    _originalPlaylist = List.from(queue);
    _playlist = List<Song>.from(queue);
    _currentIndex = 0;
    _manualQueueCount = 0;

    if (!state.isShuffle) {
      state = state.copyWith(isShuffle: true);
      await ref.read(settingsProvider.notifier).updateShuffle(true);
    }

    state = state.copyWith(queue: List.from(_playlist));
    play(_playlist[_currentIndex]);
    await _saveQueueState();
    _updateNotification();
  }

  Future<void> play(Song song, {bool forceDisableCrossfade = false, bool play = true, Duration? initialPosition}) async {
    _silenceTimer?.cancel();
    _songCompletionTimer?.cancel();
    _playCountTimer?.cancel();

    final file = File(song.path);
    if (!await file.exists()) {
      _showErrorSnackBar(
        'File not found or inaccessible: ${song.title}',
          (l10n) => 'File not found or inaccessible: ${song.title}',
        );
        return;
      }

    final crossfadeId = ++_activeCrossfadeId;
    _isTransitioning = true;
    _lastPlayTime = DateTime.now();


    try {
      player.setVolume(state.volume * 100);

      await _playDirect(song, crossfadeId, play: play, initialPosition: initialPosition);

    } catch (e) {

      if (crossfadeId == _activeCrossfadeId) {
        try {

          player.setVolume(state.volume * 100);
          await _playDirect(song, crossfadeId, play: play, initialPosition: initialPosition);

        } catch (retryError, stack) {
          LoggerHelper.write('Playback failed permanently for: ${song.path}', retryError, stack);
          _showErrorSnackBar(
            'Playback failed: Unable to load or play "${song.title}". Please verify the file is not corrupted.',
            (l10n) => 'Playback failed: Unable to load or play "${song.title}". Please verify the file is not corrupted.',
          );
          rethrow;
        }
      } else {

      }
    } finally {
      if (crossfadeId == _activeCrossfadeId) {
        int attempts = 0;

        while ((player.state.completed || (play && !state.isPlaying)) && attempts < 40) {
          await Future.delayed(const Duration(milliseconds: 25));
          attempts++;
        }

        _isTransitioning = false;
      }
    }
  }

  Future<void> _playDirect(Song song, int crossfadeId, {bool play = true, Duration? initialPosition}) async {
    _autoCrossfadeTriggered = false;
    state = state.copyWith(
      currentSong: song,
      duration: song.duration != null ? Duration(milliseconds: song.duration!) : Duration.zero,
      position: initialPosition ?? Duration.zero,
      isRestoredSession: initialPosition != null,
    );
    ref.read(lyricsProvider.notifier).fetchForSong(song);
    _maybePrefetchNextLyrics();
    ref.read(equalizerProvider.notifier).onSongChanged(song);
    
    // Apply equalizer settings for the song
    final settings = ref.read(settingsProvider);
    final gains = ref.read(equalizerProvider).currentSongGains;
    final customFilter = ref.read(equalizerProvider).customFilterString;

    final metadata = {
      'title': song.title,
      'artist': song.artist ?? 'Unknown Artist',
      'album': song.album ?? 'Unknown Album',
      if (song.artPath != null) 'artPath': song.artPath!,
      if (song.duration != null) 'duration': song.duration!,
    };
    final double targetVol = state.volume;
    bool targetPlay = play;
    final isManualCrossfade = _isLastPlayManual &&
        (settings.crossfadeMode == 0 || settings.crossfadeMode == 2) &&
        settings.crossfadeDuration > 0;
    final isAutoCrossfade = !_isLastPlayManual &&
        (settings.crossfadeMode == 0 || settings.crossfadeMode == 1) &&
        settings.crossfadeDuration > 0;
    final int fadeLength = (isManualCrossfade || isAutoCrossfade)
        ? math.min(settings.crossfadeDuration * 1000, 3000)
        : (_isLastPlayManual && settings.fadePlayPauseStop ? settings.playPauseStopFadeLength : 0);
    final bool shouldFade = fadeLength > 0 && targetPlay;
    if (shouldFade) {
      player.setVolume(0);
    } else {
      player.setVolume(state.volume * 100);
    }

    await ref.read(audioServiceProvider).play(
      song.path,
      metadata: metadata,
      play: targetPlay,
      equalizerGains: gains,
      equalizerEnabled: settings.equalizerEnabled,
      customFilter: customFilter,
      interruptionPolicy: _getInterruptionPolicy(),
    );

    if (targetPlay) {
      await ref.read(audioServiceProvider).resume();
    }

    if (shouldFade && crossfadeId == _activeCrossfadeId) {
      _fadeVolume(targetVol, Duration(milliseconds: fadeLength));
    }

    if (crossfadeId != _activeCrossfadeId) return;

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      await windowManager.setTitle(
        'Looper - ${song.title} - ${song.artist ?? 'Unknown Artist'}',
      );
    }

    if (Platform.isLinux) {
      final notification = LocalNotification(
        title: song.title,
        body: '${song.artist ?? 'Unknown Artist'}\n${song.album ?? 'Unknown Album'}',
      );
      await notification.show();
    }

    await DbService.isar.writeTxn(() async {
      final dbSong = await DbService.isar.songs
          .filter()
          .pathEqualTo(song.path)
          .findFirst();

      final songToUpdate = dbSong ?? song;

      if (dbSong != null) {
        song.id = dbSong.id;
        song.isFavorite = dbSong.isFavorite;
        song.playCount = dbSong.playCount;
        song.lastPlayed = dbSong.lastPlayed;
      } else {
        song.id = songToUpdate.id;
      }

      await DbService.isar.songs.put(songToUpdate);
    });

    if (play) {
      _armPlayCount(song);
    }

    if (settings.persistQueue) {
      await ref.read(settingsProvider.notifier).updateLastPlayedSong(song.id);
    }

    final idx = _playlist.indexWhere((s) => s.path == song.path);
    if (idx != -1) {
      final endOfManual = _currentIndex + _manualQueueCount;
      _manualQueueCount = (idx < endOfManual) ? endOfManual - idx : 0;
      _currentIndex = idx;
    } else {
      if (_currentIndex == -1) {
        _playlist = [song];
        _originalPlaylist = [song];
        _currentIndex = 0;
        _manualQueueCount = 0;
      } else {
        final currentSong = _playlist[_currentIndex];
        _playlist.insert(_currentIndex + 1, song);
        final origIdx = _originalPlaylist.indexWhere((s) => s.path == currentSong.path);
        if (origIdx != -1) {
          _originalPlaylist.insert(origIdx + 1, song);
        } else {
          _originalPlaylist.add(song);
        }
        _currentIndex++;
      }
      state = state.copyWith(queue: List.from(_playlist));
    }
    _updateNotification();
    await _ensureDynamicQueue();
    await _saveQueueState();

    if (initialPosition != null && initialPosition > Duration.zero) {
      int attempts = 0;
      while (player.state.duration == Duration.zero && attempts < 40) {
        await Future.delayed(const Duration(milliseconds: 50));
        attempts++;
      }
      await seek(initialPosition);
    }

    if (settings.crossfadeDuration == 0) {
      final nextNext = getNextSong(updateIndex: false);
      if (nextNext != null) {
        await ref.read(audioServiceProvider).enqueueNext(nextNext.path, metadata: {
          'title': nextNext.title,
          'artist': nextNext.artist ?? 'Unknown Artist',
          'album': nextNext.album ?? 'Unknown Album',
          if (nextNext.artPath != null) 'artPath': nextNext.artPath!,
          if (nextNext.duration != null) 'duration': nextNext.duration!.toString(),
        });
      }
    }

    // Sweep previous track memory (decoded cover bitmaps, old metadata, transient buffers)
    Future.delayed(const Duration(seconds: 2), MemoryService.trimWorkingSet);
  }

  void _maybePrefetchNextLyrics() {
    try {
      final next = getNextSong(updateIndex: false);
      if (next != null && next.id != state.currentSong?.id) {
        ref.read(lyricsProvider.notifier).prefetchNext(next);
      }
    } catch (_) {}
  }

  /// Schedules the lastPlayed/playCount stamp after a scrobble threshold percentage of the
  /// song has elapsed (capped between 10s and 240s), so quick skips don't churn Recently Played
  /// or inflate Most Played. Cancelled by pause/skip/stop/new play; only fires if the
  /// same song is still the current song and still playing.
  void _armPlayCount(Song song) {
    _playCountTimer?.cancel();
    _playCountedPath = null;

    final settings = ref.read(settingsProvider);
    if (settings.enableLastFmScrobbling || settings.enableListenBrainzScrobbling) {
      ScrobblerService.instance.updateNowPlaying(
        song: song,
        settings: settings,
      );
    }

    final durationMs = song.duration ?? 0;
    final thresholdPercent = (settings.scrobbleThresholdPercent).clamp(10, 100);
    final thresholdSeconds = durationMs > 0
        ? ((durationMs / 1000) * (thresholdPercent / 100)).clamp(10.0, 240.0).round()
        : 10;

    _playCountTimer = Timer(Duration(seconds: thresholdSeconds), () {
      _commitPlayCount(song);
    });
  }

  void _commitPlayCount(Song song) {
    final current = state.currentSong;
    if (current == null || !state.isPlaying) return;
    if (current.id != song.id && current.path != song.path) return;
    if (_playCountedPath == song.path) return;
    _playCountedPath = song.path;

    final settings = ref.read(settingsProvider);
    final now = DateTime.now();
    final listenedMs = state.position.inMilliseconds > 0
        ? state.position.inMilliseconds
        : 10000;

    // 1. External scrobbling (only if enabled)
    if (settings.enableLastFmScrobbling || settings.enableListenBrainzScrobbling) {
      ScrobblerService.instance.scrobble(
        song: song,
        settings: settings,
        playTimestamp: now,
        listenedMs: listenedMs,
      );
    }

    // 2. Local playback history entry & playCount increment
    try {
      final title = song.title.trim();
      final artist = song.artist?.trim() ?? 'Unknown Artist';
      final album = song.album?.trim();
      final genre = song.genre?.trim();
      final durationMs = song.duration ?? listenedMs;

      final entry = PlaybackHistoryEntry()
        ..timestamp = now
        ..songPath = song.path
        ..title = title
        ..artist = artist
        ..album = album
        ..genre = genre
        ..durationMs = durationMs
        ..listenedMs = listenedMs
        ..artPath = song.artPath;

      DbService.isar.writeTxn(() async {
        await DbService.isar.playbackHistoryEntrys.put(entry);
        final dbSong = await DbService.isar.songs
            .filter()
            .pathEqualTo(song.path)
            .findFirst();
        if (dbSong != null) {
          dbSong.lastPlayed = now;
          dbSong.playCount++;
          await DbService.isar.songs.put(dbSong);
        }
      });
      LoggerHelper.write('PlaybackHistory: Recorded local history entry for "$title" by $artist');
    } catch (e, s) {
      LoggerHelper.write('PlaybackHistory: Error recording history entry', e, s);
    }
  }

  /// Removes all existing occurrences of [songPath] from [_playlist] (except
  /// the currently playing song at [_currentIndex]) and [_originalPlaylist].
  /// Adjusts [_currentIndex] and [_manualQueueCount] accordingly so the queue
  /// never contains duplicate entries.
  void _removeExistingFromQueue(String songPath) {
    for (int i = _playlist.length - 1; i >= 0; i--) {
      if (i == _currentIndex) continue; // Keep the actively playing song
      if (_playlist[i].path == songPath) {
        _playlist.removeAt(i);
        if (i < _currentIndex) {
          _currentIndex--;
        } else if (i <= _currentIndex + _manualQueueCount) {
          if (_manualQueueCount > 0) _manualQueueCount--;
        }
      }
    }
    _originalPlaylist.removeWhere((s) => s.path == songPath);
  }

  void addToQueue(Song song) {
    // If the song is already the currently playing song, do not duplicate it
    if (_currentIndex >= 0 &&
        _currentIndex < _playlist.length &&
        _playlist[_currentIndex].path == song.path) {
      return;
    }

    _removeExistingFromQueue(song.path);

    if (_playlist.isEmpty || _currentIndex == -1) {
      _playlist = [song];
      _originalPlaylist = [song];
      _currentIndex = 0;
      _manualQueueCount = 0;
      state = state.copyWith(queue: List.from(_playlist), currentSong: song);
      play(song);
      _saveQueueState();
      return;
    }

    if (state.isShuffle) {
      // Insert randomly into the remaining queue
      final minIndex = _currentIndex + 1;
      final maxIndex = _playlist.length;
      final insertIndex = minIndex >= maxIndex 
          ? minIndex 
          : minIndex + math.Random().nextInt(maxIndex - minIndex + 1);
      
      if (insertIndex >= _playlist.length) {
        _playlist.add(song);
      } else {
        _playlist.insert(insertIndex, song);
      }
      _originalPlaylist.add(song);
    } else {
      final insertIndex = _currentIndex + 1 + _manualQueueCount;
      if (insertIndex >= _playlist.length) {
        _playlist.add(song);
      } else {
        _playlist.insert(insertIndex, song);
      }

      // Also insert into _originalPlaylist at corresponding position
      final refSongIdx = _currentIndex + _manualQueueCount;
      if (refSongIdx >= 0 && refSongIdx < _playlist.length) {
        final refSong = _playlist[refSongIdx];
        final origIdx = _originalPlaylist.indexWhere((s) => s.path == refSong.path);
        if (origIdx != -1) {
          _originalPlaylist.insert(origIdx + 1, song);
        } else {
          _originalPlaylist.add(song);
        }
      } else {
        _originalPlaylist.add(song);
      }
    }
    _manualQueueCount++;

    state = state.copyWith(queue: List.from(_playlist));
    _saveQueueState();
  }

  void addNext(Song song) {
    // If the song is already the currently playing song, do not duplicate it
    if (_currentIndex >= 0 &&
        _currentIndex < _playlist.length &&
        _playlist[_currentIndex].path == song.path) {
      return;
    }

    _removeExistingFromQueue(song.path);

    if (_playlist.isEmpty || _currentIndex == -1) {
      _playlist = [song];
      _originalPlaylist = [song];
      _currentIndex = 0;
      _manualQueueCount = 0;
      state = state.copyWith(queue: List.from(_playlist), currentSong: song);
      play(song);
      _saveQueueState();
      return;
    }

    final insertIndex = _currentIndex + 1;
    if (insertIndex >= _playlist.length) {
      _playlist.add(song);
    } else {
      _playlist.insert(insertIndex, song);
    }

    if (state.currentSong != null) {
      final origIdx = _originalPlaylist.indexWhere((s) => s.path == state.currentSong!.path);
      if (origIdx != -1) {
        _originalPlaylist.insert(origIdx + 1, song);
      } else {
        _originalPlaylist.add(song);
      }
    } else {
      _originalPlaylist.add(song);
    }
    _manualQueueCount++;

    state = state.copyWith(queue: List.from(_playlist));
    _saveQueueState();
  }

  /// Inserts [songs] right after the current song, in the given order.
  void addNextMany(List<Song> songs) {
    if (songs.isEmpty) return;

    final currentPath = state.currentSong?.path;
    // Discard any currently playing song to avoid duplicates
    final validSongs = songs.where((s) => s.path != currentPath).toList();
    if (validSongs.isEmpty) return;

    // Deduplicate songs amongst themselves (preserving order)
    final seen = <String>{};
    final uniqueSongs = <Song>[];
    for (final s in validSongs) {
      if (seen.add(s.path)) uniqueSongs.add(s);
    }

    // Remove existing instances of these songs from anywhere in the queue
    for (final song in uniqueSongs) {
      _removeExistingFromQueue(song.path);
    }

    if (_playlist.isEmpty || _currentIndex == -1) {
      _playlist = List.from(uniqueSongs);
      _originalPlaylist = List.from(uniqueSongs);
      _currentIndex = 0;
      _manualQueueCount = 0;
      state = state.copyWith(queue: List.from(_playlist), currentSong: uniqueSongs.first);
      play(uniqueSongs.first);
      _saveQueueState();
      return;
    }

    final insertIndex = _currentIndex + 1;
    if (insertIndex >= _playlist.length) {
      _playlist.addAll(uniqueSongs);
    } else {
      _playlist.insertAll(insertIndex, uniqueSongs);
    }

    if (state.currentSong != null) {
      final origIdx = _originalPlaylist
          .indexWhere((s) => s.path == state.currentSong!.path);
      if (origIdx != -1) {
        _originalPlaylist.insertAll(origIdx + 1, uniqueSongs);
      } else {
        _originalPlaylist.addAll(uniqueSongs);
      }
    } else {
      _originalPlaylist.addAll(uniqueSongs);
    }
    _manualQueueCount += uniqueSongs.length;

    state = state.copyWith(queue: List.from(_playlist));
    _saveQueueState();
  }

  /// Appends [songs] to the end of the upcoming queue.
  void addToQueueMany(List<Song> songs) {
    if (songs.isEmpty) return;

    final currentPath = state.currentSong?.path;
    // Discard any currently playing song to avoid duplicates
    final validSongs = songs.where((s) => s.path != currentPath).toList();
    if (validSongs.isEmpty) return;

    // Deduplicate songs amongst themselves (preserving order)
    final seen = <String>{};
    final uniqueSongs = <Song>[];
    for (final s in validSongs) {
      if (seen.add(s.path)) uniqueSongs.add(s);
    }

    // Remove existing instances of these songs from anywhere in the queue
    for (final song in uniqueSongs) {
      _removeExistingFromQueue(song.path);
    }

    if (_playlist.isEmpty || _currentIndex == -1) {
      _playlist = List.from(uniqueSongs);
      _originalPlaylist = List.from(uniqueSongs);
      _currentIndex = 0;
      _manualQueueCount = 0;
      state = state.copyWith(queue: List.from(_playlist), currentSong: uniqueSongs.first);
      play(uniqueSongs.first);
      _saveQueueState();
      return;
    }

    if (state.isShuffle) {
      // Insert randomly into the remaining queue
      for (final song in uniqueSongs) {
        final minIndex = _currentIndex + 1;
        final maxIndex = _playlist.length;
        final insertIndex = minIndex >= maxIndex
            ? minIndex
            : minIndex + math.Random().nextInt(maxIndex - minIndex + 1);

        if (insertIndex >= _playlist.length) {
          _playlist.add(song);
        } else {
          _playlist.insert(insertIndex, song);
        }
      }
      _originalPlaylist.addAll(uniqueSongs);
    } else {
      final insertIndex = _currentIndex + 1 + _manualQueueCount;
      if (insertIndex >= _playlist.length) {
        _playlist.addAll(uniqueSongs);
      } else {
        _playlist.insertAll(insertIndex, uniqueSongs);
      }

      // Also insert into _originalPlaylist at corresponding position
      final refSongIdx = _currentIndex + _manualQueueCount;
      if (refSongIdx >= 0 && refSongIdx < _playlist.length) {
        final refSong = _playlist[refSongIdx];
        final origIdx = _originalPlaylist
            .indexWhere((s) => s.path == refSong.path);
        if (origIdx != -1) {
          _originalPlaylist.insertAll(origIdx + 1, uniqueSongs);
        } else {
          _originalPlaylist.addAll(uniqueSongs);
        }
      } else {
        _originalPlaylist.addAll(uniqueSongs);
      }
    }
    _manualQueueCount += uniqueSongs.length;

    state = state.copyWith(queue: List.from(_playlist));
    _saveQueueState();
  }

  Future<Song> _getOrCreateSongForPath(String path) async {
    final songs = await DbService.isar.songs
        .filter()
        .pathEqualTo(path)
        .findAll();
    if (songs.isNotEmpty) return songs.first;

    String? artPath;
    String? title;
    String? artist;
    String? album;
    String? albumArtist;
    int? duration;
    int? trackNumber;
    int? trackTotal;
    int? discNumber;
    int? discTotal;
    int? year;
    String? genre;

    try {
      final metadata = await MetadataGod.readMetadata(file: path);
      title = metadata.title;
      artist = metadata.artist;
      album = metadata.album;
      albumArtist = metadata.albumArtist;
      duration = metadata.durationMs?.toInt();
      trackNumber = metadata.trackNumber;
      trackTotal = metadata.trackTotal;
      discNumber = metadata.discNumber;
      discTotal = metadata.discTotal;
      year = metadata.year;
      genre = metadata.genre;

      if (metadata.picture != null) {
        final scanner = LibraryScanner();
        artPath = await scanner.saveAlbumArt(
          metadata.album ?? 'unknown',
          metadata.picture!.data,
        );
      }
    } catch (_) {}

    final song = Song()
      ..path = path
      ..title = title ?? path.split(Platform.pathSeparator).last
      ..artist = artist ?? 'Unknown Artist'
      ..album = album ?? 'Unknown Album'
      ..albumArtist = albumArtist
      ..duration = duration
      ..trackNumber = trackNumber
      ..trackTotal = trackTotal
      ..discNumber = discNumber
      ..discTotal = discTotal
      ..year = year
      ..genre = genre
      ..artPath = artPath
      ..dateAdded = DateTime.now();

    // Persist song record to DB to guarantee valid Isar Id for queues and state
    try {
      await DbService.isar.writeTxn(() async {
        await DbService.isar.songs.put(song);
      });
    } catch (_) {}

    return song;
  }

  Future<void> playFromFile(String path) async {
    final song = await _getOrCreateSongForPath(path);

    // Switch to or create dedicated "External" queue
    if (_activeQueueName != 'External') {
      if (_activeQueueName.isNotEmpty && _playlist.isNotEmpty) {
        await _persistNamedQueue(_activeQueueName);
      }
      _activeQueueName = 'External';
      ref.read(settingsProvider.notifier).updateActiveQueueName('External');
    }

    _manualQueueCount = 0;
    _playlist = [song];
    _originalPlaylist = [song];
    _currentIndex = 0;
    state = state.copyWith(
      currentSong: song,
      queue: [song],
      isRestoredSession: false,
    );
    await play(song);
    await _saveQueueState();
  }

  Future<void> playFromFiles(List<String> paths) async {
    if (paths.isEmpty) return;
    final List<Song> newSongs = [];
    for (final path in paths) {
      final song = await _getOrCreateSongForPath(path);
      newSongs.add(song);
    }
    if (newSongs.isEmpty) return;

    // Switch to or create dedicated "External" queue
    if (_activeQueueName != 'External') {
      if (_activeQueueName.isNotEmpty && _playlist.isNotEmpty) {
        await _persistNamedQueue(_activeQueueName);
      }
      _activeQueueName = 'External';
      ref.read(settingsProvider.notifier).updateActiveQueueName('External');
    }

    _manualQueueCount = 0;
    _playlist = newSongs;
    _originalPlaylist = List.from(newSongs);
    _currentIndex = 0;
    state = state.copyWith(
      currentSong: newSongs.first,
      queue: List.from(_playlist),
      isRestoredSession: false,
    );
    await play(newSongs.first);
    await _saveQueueState();
  }

  Future<void> enqueueFromFile(String path) async {
    final song = await _getOrCreateSongForPath(path);
    addToQueue(song);
    await _saveQueueState();
  }

  Future<void> enqueueFromFiles(List<String> paths) async {
    final List<Song> newSongs = [];
    for (final path in paths) {
      final song = await _getOrCreateSongForPath(path);
      newSongs.add(song);
    }

    if (newSongs.isEmpty) return;

    if (_playlist.isEmpty) {
      if (_activeQueueName != 'External') {
        _activeQueueName = 'External';
        ref.read(settingsProvider.notifier).updateActiveQueueName('External');
      }
      final seen = <String>{};
      final uniqueSongs = newSongs.where((s) => seen.add(s.path)).toList();
      _playlist = uniqueSongs;
      _originalPlaylist = List.from(uniqueSongs);
      _currentIndex = 0;
      _manualQueueCount = 0;
      state = state.copyWith(
        queue: List.from(_playlist),
        currentSong: uniqueSongs.first,
        isRestoredSession: false,
      );
      await play(uniqueSongs.first);
    } else {
      addToQueueMany(newSongs);
    }
    await _saveQueueState();
  }

  Future<void> togglePlay() async {
    if (_isTogglePlaying) {
      final currentPlaying = _targetPlayingState ?? state.isPlaying;
      final targetPlaying = !currentPlaying;
      _targetPlayingState = targetPlaying;
      state = state.copyWith(isPlaying: targetPlaying);
      _updateNotification();
      return;
    }

    _isTogglePlaying = true;
    _silenceTimer?.cancel();
    final settings = ref.read(settingsProvider);

    try {
      while (true) {
        final currentPlaying = _targetPlayingState ?? state.isPlaying;
        final targetPlaying = !currentPlaying;
        _targetPlayingState = targetPlaying;

        // Update UI state immediately to be ultra-responsive
        state = state.copyWith(isPlaying: targetPlaying);
        _updateNotification();

        if (!targetPlaying) {
          _songCompletionTimer?.cancel();
          _playCountTimer?.cancel();
        }

        final audioSvc = ref.read(audioServiceProvider);

        if (!targetPlaying) {
          if (settings.fadePlayPauseStop && settings.playPauseStopFadeLength > 0) {
            await _fadeVolume(0.0, Duration(milliseconds: settings.playPauseStopFadeLength));
            if (_targetPlayingState != targetPlaying) {
              // Target state changed during fade, skip pause and process next loop iteration
              continue;
            }
          }
          await audioSvc.pause();
        } else {
          Song? songToPlay = state.currentSong;
          if (songToPlay == null) {
            if (_playlist.isNotEmpty) {
              if (_currentIndex >= 0 && _currentIndex < _playlist.length) {
                songToPlay = _playlist[_currentIndex];
              } else {
                songToPlay = _playlist.first;
                _currentIndex = 0;
              }
            } else {
              if (settings.lastPlayedSongId != null) {
                songToPlay = await DbService.isar.songs.get(settings.lastPlayedSongId!);
              }
              if (songToPlay == null) {
                final libSongs = await DbService.isar.songs.where().findAll();
                if (libSongs.isNotEmpty) {
                  songToPlay = libSongs.first;
                }
              }
            }
          }

          if (player.state.playlist.items.isEmpty || player.state.completed || state.duration == Duration.zero) {
            if (songToPlay != null) {
              await play(songToPlay);
            }
          } else {
            _lastPlayTime = DateTime.now(); // Record resumption time
            if (settings.fadePlayPauseStop && settings.playPauseStopFadeLength > 0) {
              player.setVolume(0);
              await audioSvc.resume();
              if (_targetPlayingState != targetPlaying) {
                // Target state changed during resume FFI call, skip fade and process next loop iteration
                continue;
              }
              await _fadeVolume(state.volume, Duration(milliseconds: settings.playPauseStopFadeLength));
            } else {
              player.setVolume(state.volume * 100);
              await audioSvc.resume();
            }
            final resumed = state.currentSong;
            if (resumed != null && _playCountedPath != resumed.path) {
              _armPlayCount(resumed);
            }
          }
        }

        // If the target state hasn't changed since we started this loop iteration, we are done!
        if (_targetPlayingState == targetPlaying) {
          break;
        }
      }
    } catch (e, stack) {
      LoggerHelper.write('Playback toggle action failed', e, stack);
      _showErrorSnackBar(
        'Playback action failed: An error occurred during audio controls operation.',
        (l10n) => 'Playback action failed: An error occurred during audio controls operation.',
      );
    } finally {
      // Small cooldown to let the audio hardware stabilize
      await Future.delayed(const Duration(milliseconds: 150));
      _isTogglePlaying = false;
      _targetPlayingState = null;
      // Sync the final FFI playing state to our state
      state = state.copyWith(isPlaying: player.state.playing);
      _updateNotification();
    }
  }

  Song? getNextSong({bool updateIndex = false}) {
    if (_playlist.isEmpty) return null;
    
    int nextIndex = _currentIndex + 1;
    if (nextIndex >= _playlist.length) {
      if (state.repeatMode != RepeatMode.all) {
        return null;
      }
    }
    
    int finalIndex = nextIndex;
    List<Song> finalPlaylist = _playlist;

    if (finalIndex >= finalPlaylist.length) {
      if (state.repeatMode == RepeatMode.all) {
        if (state.isShuffle) {
          final newPlaylist = List<Song>.from(_originalPlaylist)..shuffle();
          if (_playlist.isNotEmpty && newPlaylist.isNotEmpty && newPlaylist.first.path == _playlist.last.path && newPlaylist.length > 1) {
            final swapIdx = 1 + math.Random().nextInt(newPlaylist.length - 1);
            final temp = newPlaylist[0];
            newPlaylist[0] = newPlaylist[swapIdx];
            newPlaylist[swapIdx] = temp;
          }
          finalPlaylist = newPlaylist;
          finalIndex = 0;
        } else {
          finalIndex = 0;
        }
      } else {
        finalIndex = 0;
      }
    }

    if (updateIndex) {
      _playlist = finalPlaylist;
      _currentIndex = finalIndex;
      if (_manualQueueCount > 0) {
        _manualQueueCount--;
      }
      if (state.isShuffle && finalIndex == 0) {
        state = state.copyWith(queue: List.from(_playlist));
      }
      return _playlist[_currentIndex];
    }
    
    return finalPlaylist[finalIndex];
  }

  Future<void> skipNext({bool isManual = true, bool shouldPlay = true, bool skipPlayDirect = false}) async {
    if (_playlist.isEmpty) return;
    _isLastPlayManual = isManual;
    _playCountTimer?.cancel();

    final songToPlay = getNextSong(updateIndex: true);
    
    if (songToPlay == null) {
      await ref.read(audioServiceProvider).pause();
      state = state.copyWith(isPlaying: false);
      return;
    }

    if (!skipPlayDirect) {
      await play(songToPlay, play: shouldPlay);
    }
  }

  Future<void> skipPrevious({bool force = false}) async {
    if (_playlist.isEmpty) return;
    _isLastPlayManual = true;
    if (!force && state.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    _currentIndex--;
    if (_currentIndex < 0) {
      _currentIndex = state.repeatMode == RepeatMode.all ? _playlist.length - 1 : 0;
    }
    await play(_playlist[_currentIndex]);
  }

  Future<void> seekRelative(int seconds) async {
    Duration newPos = state.position + Duration(seconds: seconds);
    if (newPos < Duration.zero) newPos = Duration.zero;
    if (newPos > state.duration) newPos = state.duration;
    await seek(newPos);
  }

  void adjustVolume(double delta) {
    final newVolume = (state.volume + delta).clamp(0.0, 1.0);
    setVolume(newVolume);
  }

  Future<void> toggleShuffle() async {
    final newState = !state.isShuffle;
    state = state.copyWith(isShuffle: newState);
    await ref.read(settingsProvider.notifier).updateShuffle(newState);

    if (newState) {
      // Turn Shuffle ON:
      // Generate a single shuffled playback order while keeping the current song active.
      if (_playlist.isEmpty) {
        _playlist = [];
        _currentIndex = -1;
      } else {
        final currentSong = _playlist[_currentIndex];
        final playedSongs = _playlist.sublist(0, _currentIndex);

        // Filter unplayed songs from original queue
        final remainingSongs = List<Song>.from(_originalPlaylist);
        for (final song in playedSongs) {
          final idx = remainingSongs.indexWhere((s) => s.path == song.path);
          if (idx != -1) remainingSongs.removeAt(idx);
        }
        final curIdx = remainingSongs.indexWhere((s) => s.path == currentSong.path);
        if (curIdx != -1) remainingSongs.removeAt(curIdx);

        // Shuffle only the remaining unplayed songs
        remainingSongs.shuffle();

        _playlist = [...playedSongs, currentSong, ...remainingSongs];
        _currentIndex = playedSongs.length;
      }
    } else {
      // Turn Shuffle OFF:
      // Restore the original queue order after the current song
      if (_playlist.isEmpty) {
        _playlist = [];
        _currentIndex = -1;
      } else {
        final currentSong = _playlist[_currentIndex];
        int newIndex = _originalPlaylist.indexWhere((s) => s.path == currentSong.path);
        if (newIndex == -1) {
          newIndex = _currentIndex.clamp(0, _originalPlaylist.length);
        }
        _playlist = List.from(_originalPlaylist);
        _currentIndex = newIndex;
      }
    }

    state = state.copyWith(queue: List.from(_playlist));
    await _saveQueueState();
    _updateNotification();
  }

  int songId(Song s) => s.id;

  void nextRepeatMode() {
    final nextMode = RepeatMode
        .values[(state.repeatMode.index + 1) % RepeatMode.values.length];
    state = state.copyWith(repeatMode: nextMode);
    ref.read(settingsProvider.notifier).updateRepeatMode(nextMode.index);
  }

  void setVolume(double volume) {
    state = state.copyWith(volume: volume);
    if (_isDucked) {
      player.setVolume(volume * 25.0);
    } else {
      player.setVolume(volume * 100);
    }
    ref.read(settingsProvider.notifier).updateVolume(volume);
  }

  Future<void> seek(Duration position) async {
    _songCompletionTimer?.cancel();
    _activeSeekId++;
    _lastSeekTime = DateTime.now();

    try {
      await player.seek(position);
      state = state.copyWith(position: position);
      if (!state.isScrubbing) {
        if (_isDucked) {
          player.setVolume(state.volume * 25.0);
        } else {
          player.setVolume(state.volume * 100);
        }
      }
      if (ref.read(settingsProvider).persistQueue) {
        ref.read(settingsProvider.notifier).updateLastPosition(position.inMilliseconds);
      }
    } catch (e) {
      debugPrint('Seek failed: $e');
      state = state.copyWith(position: position);
    }
  }

  void startScrubbing() {
    _activeSeekId++;
    _lastSeekTime = DateTime.now();
    state = state.copyWith(isScrubbing: true);
    player.setVolume(0);
  }

  void stopScrubbing() {
    _activeSeekId++;
    _lastSeekTime = DateTime.now();
    state = state.copyWith(
      isScrubbing: false,
      position: player.state.position,
    );
    player.setVolume(state.volume * 100);
  }

  Future<void> reorderQueue(int oldIndex, int newIndex, {String? rotationSongPath}) async {
    if (_playlist.isEmpty) return;

    final targetSongPath = rotationSongPath ?? state.currentSong?.path;
    final rotationIdx = targetSongPath != null
        ? _playlist.indexWhere((s) => s.path == targetSongPath)
        : -1;

    if (rotationIdx == -1) {
      // Non-rotated standard reorder
      if (newIndex > oldIndex) newIndex -= 1;
      final song = _playlist.removeAt(oldIndex);
      _playlist.insert(newIndex, song);
    } else {
      // 1. Reconstruct the rotated list (displayed list)
      final List<Song> displayedQueue = [
        ..._playlist.sublist(rotationIdx),
        ..._playlist.sublist(0, rotationIdx),
      ];

      // 2. Perform the reorder on the rotated list
      if (newIndex > oldIndex) newIndex -= 1;
      final song = displayedQueue.removeAt(oldIndex);
      displayedQueue.insert(newIndex, song);

      // 3. Rotate it back to align rotationIdx with its original index
      final n = displayedQueue.length;
      final k = (n - rotationIdx) % n;

      _playlist = [
        ...displayedQueue.sublist(k),
        ...displayedQueue.sublist(0, k),
      ];
    }

    if (!state.isShuffle) {
      _originalPlaylist = List.from(_playlist);
    } else {
      final played = _playlist.sublist(0, _currentIndex);
      final current = _playlist[_currentIndex];
      final unplayed = _playlist.sublist(_currentIndex + 1);
      _originalPlaylist = [...played, current, ...unplayed];
    }

    // 4. Update state and save
    state = state.copyWith(queue: List.from(_playlist));
    if (state.currentSong != null) {
      _currentIndex = _playlist.indexWhere((s) => s.path == state.currentSong!.path);
    }
    await _saveQueueState();
  }

  /// Reorders directly using original playlist indices with no rotation involved.
  /// [oldOriginalIdx] and [newOriginalIdx] are indices into the raw playlist.
  /// The caller is responsible for resolving displayed indices → original indices.
  Future<void> reorderQueueDirect(int oldOriginalIdx, int newOriginalIdx) async {
    if (_playlist.isEmpty) return;
    if (oldOriginalIdx == newOriginalIdx) return;
    if (oldOriginalIdx < 0 || oldOriginalIdx >= _playlist.length) return;
    if (newOriginalIdx < 0 || newOriginalIdx >= _playlist.length) return;

    final wasManual = _manualQueueCount > 0 &&
        oldOriginalIdx > _currentIndex &&
        oldOriginalIdx <= _currentIndex + _manualQueueCount;

    final song = _playlist.removeAt(oldOriginalIdx);
    // After removal, if newOriginalIdx was after oldOriginalIdx it shifted down,
    // but we want to insert AT the slot the target song occupied visually —
    // no additional ±1 needed here; the caller already applied Flutter's adjustment.
    _playlist.insert(newOriginalIdx, song);

    if (state.currentSong != null) {
      _currentIndex = _playlist.indexWhere((s) => s.path == state.currentSong!.path);
    }

    if (wasManual && newOriginalIdx < _currentIndex) {
      if (_manualQueueCount > 0) _manualQueueCount--;
    }

    if (!state.isShuffle) {
      _originalPlaylist = List.from(_playlist);
    }
    state = state.copyWith(queue: List.from(_playlist));
    await _saveQueueState();
  }

  Future<void> removeFromQueue(int index) async {
    if (index >= 0 && index < _playlist.length) {
      final song = _playlist[index];
      if (index == _currentIndex) {
        await skipNext();
      }
      final endOfManual = _currentIndex + _manualQueueCount;
      if (index > _currentIndex && index <= endOfManual) {
        if (_manualQueueCount > 0) _manualQueueCount--;
      }
      _playlist.removeAt(index);
      final origIdx = _originalPlaylist.indexWhere((s) => s.path == song.path);
      if (origIdx != -1) {
        _originalPlaylist.removeAt(origIdx);
      }
      state = state.copyWith(queue: List.from(_playlist));
      if (state.currentSong != null) {
        _currentIndex = _playlist.indexWhere((s) => s.path == state.currentSong!.path);
      }
      await _ensureDynamicQueue();
    }
  }

  Future<void> clearQueue() async {
    final oldQueueName = _activeQueueName;
    if (oldQueueName.isNotEmpty && oldQueueName != QueueRepository.allSongsQueueName) {
      await _queueRepo.delete(oldQueueName);
      _activeQueueName = QueueRepository.allSongsQueueName;
      await ref.read(settingsProvider.notifier).updateActiveQueueName(QueueRepository.allSongsQueueName);
    }
    _playlist = [];
    _originalPlaylist = [];
    _currentIndex = -1;
    _playCountTimer?.cancel();
    _manualQueueCount = 0;
    state = PlaybackState(
      volume: state.volume,
      isShuffle: state.isShuffle,
      repeatMode: state.repeatMode,
    );
    await player.stop();
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      await windowManager.setTitle('Looper');
    }
    await _ensureDynamicQueue();
  }

  Future<void> toggleFavorite() async {
    final song = state.currentSong;
    if (song == null) return;

    // Toggle and persist
    final newFavoriteState = !song.isFavorite;
    await DbService.isar.writeTxn(() async {
      song.isFavorite = newFavoriteState;
      await DbService.isar.songs.put(song);
    });

    // Read a fresh instance back from DB to guarantee a new object reference
    // so Riverpod's select((s) => s.currentSong) detects the identity change
    // and rebuilds widgets (the like button, notification etc.)
    final freshSong = await DbService.isar.songs.get(song.id) ?? song;

    // Sync the in-memory playlist entry too
    final idx = _playlist.indexWhere((s) => s.id == freshSong.id);
    if (idx != -1) _playlist[idx] = freshSong;

    state = state.copyWith(
      currentSong: freshSong,
      queue: List.from(_playlist),
    );
    _updateNotification();
  }

  double _lastVolume = 0.8;

  void toggleMute() {
    if (state.volume > 0.001) {
      _lastVolume = state.volume;
      setVolume(0.0);
    } else {
      final target = _lastVolume > 0.001 ? _lastVolume : 0.8;
      setVolume(target);
    }
  }

  Future<void> toggleVocalReducer() async {
    final nextState = !state.isVocalReducerActive;
    await setVocalReducer(nextState, strength: state.vocalReducerStrength);
  }

  Future<void> setVocalReducer(bool enabled, {double strength = 1.0}) async {
    state = state.copyWith(
      isVocalReducerActive: enabled,
      vocalReducerStrength: strength,
    );
    await ref.read(audioServiceProvider).setLiveVocalReducer(enabled, strength: strength);
  }

  Future<FileActionResult> renameSong(Song song, String newTitle) async {
    final sanitizedTitle = newTitle.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    if (sanitizedTitle.isEmpty) {
      return FileActionResult.failure;
    }

    final isCurrent = state.currentSong?.id == song.id;
    final wasPlaying = state.isPlaying;
    final lastPosition = state.position;

    if (isCurrent) {
      // Completely stop player to release file handle locks
      await player.stop();
      // Wait for player to completely release the file handle
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final file = File(song.path);
    final dir = file.parent.path;
    final ext = p.extension(song.path);
    final newPath = p.join(dir, '$sanitizedTitle$ext');

    bool fileRenamed = false;
    if (newPath != song.path) {
      try {
        if (newPath.toLowerCase() != song.path.toLowerCase() && await File(newPath).exists()) {

          if (isCurrent) {
            // Restore playback of the original song
            await play(song, play: wasPlaying);
            await seek(lastPosition);
          }
          return FileActionResult.failure;
        }

        if (await file.exists()) {
          await file.rename(newPath);
          fileRenamed = true;
        }
      } catch (e) {

      }
    } else {
      fileRenamed = true;
    }

    bool dbSuccess = false;
    try {
      await DbService.isar.writeTxn(() async {
        song.title = sanitizedTitle;
        if (fileRenamed) {
          song.path = newPath;
        }
        await DbService.isar.songs.put(song);
      });
      dbSuccess = true;

      // Update in-memory queue
      final index = _playlist.indexWhere((s) => s.id == song.id);
      if (index != -1) {
        _playlist[index] = song;
      }

      // Update state if it's the current song
      if (isCurrent) {
        state = state.copyWith(
          currentSong: song,
          queue: List.from(_playlist),
        );
        // Resume playing track from the new path
        await play(song, play: wasPlaying);
        await seek(lastPosition);
      } else {
        state = state.copyWith(queue: List.from(_playlist));
      }
    } catch (e) {

      if (isCurrent) {
        // Fallback: restore player using original song/state
        await play(song, play: wasPlaying);
        await seek(lastPosition);
      }
    }

    if (!dbSuccess) {
      return FileActionResult.failure;
    }
    return (fileRenamed && newPath != song.path) ? FileActionResult.success : FileActionResult.dbOnly;
  }

  void updateSongEqualizer({required int songId, required bool hasCustom, List<double>? gains}) {
    // Update in playlist
    final idx = _playlist.indexWhere((s) => s.id == songId);
    if (idx != -1) {
      _playlist[idx].hasCustomEqualizer = hasCustom;
      _playlist[idx].equalizerGains = gains;
    }

    // Update in currentSong if it matches
    final song = state.currentSong;
    if (song != null && song.id == songId) {
      song.hasCustomEqualizer = hasCustom;
      song.equalizerGains = gains;
      state = state.copyWith(currentSong: song, queue: List.from(_playlist));
    } else {
      state = state.copyWith(queue: List.from(_playlist));
    }
  }

  void updateSongLyrics(int songId, String lyrics) {
    final idx = _playlist.indexWhere((s) => s.id == songId);
    if (idx != -1) {
      _playlist[idx].lyrics = lyrics;
    }

    final song = state.currentSong;
    if (song != null && song.id == songId) {
      song.lyrics = lyrics;
      state = state.copyWith(currentSong: song, queue: List.from(_playlist));
    } else {
      state = state.copyWith(queue: List.from(_playlist));
    }
  }

  void updateSongLyricsOffset(int songId, int? offsetMs) {
    final idx = _playlist.indexWhere((s) => s.id == songId);
    if (idx != -1) {
      _playlist[idx].lyricsOffsetMs = offsetMs;
    }

    final song = state.currentSong;
    if (song != null && song.id == songId) {
      song.lyricsOffsetMs = offsetMs;
    }
  }

  void clearAllSongsEqualizer() {
    for (int i = 0; i < _playlist.length; i++) {
      _playlist[i].hasCustomEqualizer = false;
      _playlist[i].equalizerGains = null;
    }
    final song = state.currentSong;
    if (song != null) {
      song.hasCustomEqualizer = false;
      song.equalizerGains = null;
      state = state.copyWith(currentSong: song, queue: List.from(_playlist));
    } else {
      state = state.copyWith(queue: List.from(_playlist));
    }
  }

  /// Edits song metadata directly in the physical audio file and synchronizes the database.
  /// Strictly preserves existing artwork and all unedited tags.
  Future<bool> editSongMetadata(Song song, {
    String? title,
    String? artist,
    String? albumArtist,
    String? album,
    int? trackNumber,
    int? trackTotal,
    int? discNumber,
    int? discTotal,
    int? year,
    String? genre,
    String? artPath,
    String? lyrics,
  }) async {
    final isCurrent = state.currentSong?.id == song.id;
    final wasPlaying = isCurrent && state.isPlaying;

    try {
      // 1. Temporarily pause playback if actively playing to release Win32 file lock
      if (wasPlaying) {
        await player.pause();
        await Future.delayed(const Duration(milliseconds: 150));
      }

      // 2. Write metadata and embed/preserve artwork directly to the file on disk
      await TagWriterService.writeToFile(
        filePath: song.path,
        title: title,
        artist: artist,
        albumArtist: albumArtist,
        album: album,
        trackNumber: trackNumber,
        trackTotal: trackTotal,
        discNumber: discNumber,
        discTotal: discTotal,
        year: year,
        genre: genre,
        lyrics: lyrics,
        newArtPath: artPath,
        fallbackArtPath: song.artPath,
      );

      // 3. Process artwork cache if a new art file was picked
      String? effectiveArtPath = song.artPath;
      if (artPath != null) {
        if (artPath.isEmpty) {
          effectiveArtPath = null;
        } else {
          try {
            final artFile = File(artPath);
            if (await artFile.exists()) {
              final bytes = await artFile.readAsBytes();
              final scanner = LibraryScanner();
              effectiveArtPath = await scanner.saveAlbumArt(
                album ?? song.album ?? 'unknown',
                bytes,
              );
            }
          } catch (_) {
            effectiveArtPath = artPath;
          }
        }
      }

      // 4. Update the database record
      await DbService.isar.writeTxn(() async {
        if (title != null && title.isNotEmpty) song.title = title.trim();
        if (artist != null) song.artist = artist.trim().isEmpty ? null : artist.trim();
        if (albumArtist != null) song.albumArtist = albumArtist.trim().isEmpty ? null : albumArtist.trim();
        if (album != null) song.album = album.trim().isEmpty ? null : album.trim();
        if (trackNumber != null) song.trackNumber = trackNumber <= 0 ? null : trackNumber;
        song.trackTotal = (trackTotal == null || trackTotal <= 0) ? null : trackTotal;
        if (discNumber != null) song.discNumber = discNumber <= 0 ? null : discNumber;
        song.discTotal = (discTotal == null || discTotal <= 0) ? null : discTotal;
        if (year != null) song.year = year == 0 ? null : year;
        if (genre != null) song.genre = genre.trim().isEmpty ? null : genre.trim();
        song.artPath = effectiveArtPath;
        song.lyrics = (lyrics == null || lyrics.trim().isEmpty) ? null : lyrics.trim();
        await DbService.isar.songs.put(song);
      });

      // 5. Update the in-memory playlist
      final idx = _playlist.indexWhere((s) => s.id == song.id);
      if (idx != -1) _playlist[idx] = song;

      // 6. Resume playback if was playing
      if (wasPlaying) {
        await player.play();
      }

      // 7. Reflect changes in live playback state if this is the current song
      if (state.currentSong?.id == song.id) {
        state = state.copyWith(currentSong: song, queue: List.from(_playlist));
        _updateNotification();
        ref.read(lyricsProvider.notifier).fetchForSong(song, force: true);
      } else {
        state = state.copyWith(queue: List.from(_playlist));
      }
      return true;
    } catch (e, s) {
      LoggerHelper.write('PlaybackNotifier: editSongMetadata error', e, s);
      if (wasPlaying) {
        try {
          await player.play();
        } catch (_) {}
      }
      return false;
    }
  }

  /// Mass edits all songs in an album and updates physical files on disk using FFmpeg.
  Future<bool> editAlbumMetadata(
    Album album, {
    String? newAlbumTitle,
    String? newAlbumArtist,
    String? newArtist,
    int? year,
    String? genre,
    int? trackTotal,
    int? discTotal,
    String? artPath,
    void Function(int current, int total)? onProgress,
  }) async {
    try {
      final songs = await DbService.isar.songs
          .filter()
          .albumEqualTo(album.name)
          .findAll();

      if (songs.isEmpty) return false;

      // Handle file lock if current playing song belongs to the album
      final currentSongInAlbum = songs.any((s) => s.id == state.currentSong?.id);
      final wasPlaying = currentSongInAlbum && state.isPlaying;
      if (wasPlaying) {
        await player.pause();
        await Future.delayed(const Duration(milliseconds: 150));
      }

      // Save/cache new album art if picked
      String? effectiveArtPath = album.artPath;
      if (artPath != null) {
        if (artPath.isEmpty) {
          effectiveArtPath = null;
        } else {
          try {
            final artFile = File(artPath);
            if (await artFile.exists()) {
              final bytes = await artFile.readAsBytes();
              final scanner = LibraryScanner();
              effectiveArtPath = await scanner.saveAlbumArt(
                newAlbumTitle ?? album.name,
                bytes,
              );
            }
          } catch (_) {
            effectiveArtPath = artPath;
          }
        }
      }

      for (int i = 0; i < songs.length; i++) {
        final song = songs[i];
        if (onProgress != null) {
          onProgress(i + 1, songs.length);
        }

        await TagWriterService.writeToFile(
          filePath: song.path,
          album: newAlbumTitle,
          albumArtist: newAlbumArtist,
          artist: newArtist,
          year: year,
          genre: genre,
          trackTotal: trackTotal,
          discTotal: discTotal,
          newArtPath: artPath,
          fallbackArtPath: song.artPath,
        );

        // Update in-memory song model
        if (newAlbumTitle != null && newAlbumTitle.trim().isNotEmpty) {
          song.album = newAlbumTitle.trim();
        }
        if (newAlbumArtist != null) {
          song.albumArtist = newAlbumArtist.trim().isEmpty ? null : newAlbumArtist.trim();
        }
        if (newArtist != null && newArtist.trim().isNotEmpty) {
          song.artist = newArtist.trim();
        }
        if (year != null) {
          song.year = year == 0 ? null : year;
        }
        if (genre != null) {
          song.genre = genre.trim().isEmpty ? null : genre.trim();
        }
        if (trackTotal != null) {
          song.trackTotal = trackTotal <= 0 ? null : trackTotal;
        }
        if (discTotal != null) {
          song.discTotal = discTotal <= 0 ? null : discTotal;
        }
        song.artPath = effectiveArtPath;
      }

      // Update songs in DB
      await DbService.isar.writeTxn(() async {
        await DbService.isar.songs.putAll(songs);

        // Update or re-create Album in DB
        await DbService.isar.albums.delete(album.id);
        final updatedAlbum = Album()
          ..name = newAlbumTitle?.trim().isNotEmpty == true ? newAlbumTitle!.trim() : album.name
          ..artist = newAlbumArtist?.trim().isNotEmpty == true
              ? newAlbumArtist!.trim()
              : (newArtist?.trim().isNotEmpty == true ? newArtist!.trim() : album.artist)
          ..artPath = effectiveArtPath
          ..year = year ?? album.year
          ..dateAdded = album.dateAdded;
        await DbService.isar.albums.put(updatedAlbum);
      });

      // Update in-memory playlist
      for (final song in songs) {
        final idx = _playlist.indexWhere((s) => s.id == song.id);
        if (idx != -1) _playlist[idx] = song;
      }

      // Resume playback if was playing
      if (wasPlaying) {
        await player.play();
      }

      // Update live playback state
      if (currentSongInAlbum && state.currentSong != null) {
        final updatedCurrent = songs.firstWhere((s) => s.id == state.currentSong!.id, orElse: () => state.currentSong!);
        state = state.copyWith(currentSong: updatedCurrent, queue: List.from(_playlist));
        _updateNotification();
      } else {
        state = state.copyWith(queue: List.from(_playlist));
      }

      // Update navigation state if currently looking at this album detail
      final finalAlbumName = newAlbumTitle?.trim().isNotEmpty == true ? newAlbumTitle!.trim() : album.name;
      final finalArtistName = newAlbumArtist?.trim().isNotEmpty == true
          ? newAlbumArtist!.trim()
          : (newArtist?.trim().isNotEmpty == true ? newArtist!.trim() : album.artist);

      ref.read(appNavigationProvider.notifier).updateActiveCollection(
        oldTitle: album.name,
        newTitle: finalAlbumName,
        newSubtitle: finalArtistName,
        newArt: effectiveArtPath,
        newSongs: songs,
      );

      await _cleanUpOrphanedArtistsAndAlbums();
      return true;
    } catch (e, s) {
      LoggerHelper.write('PlaybackNotifier: editAlbumMetadata error', e, s);
      return false;
    }
  }

  Future<FileActionResult> deleteAlbum(Album album, List<Song> songs, {required bool deleteFromStorage}) async {
    final currentInAlbum = songs.any((s) => s.id == state.currentSong?.id);
    final wasPlaying = state.isPlaying;

    if (currentInAlbum) {
      await player.stop();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    bool allDeleted = true;
    if (deleteFromStorage) {
      for (final song in songs) {
        try {
          final file = File(song.path);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {
          allDeleted = false;
        }
      }
    }

    final songIds = songs.map((s) => s.id).toList();
    try {
      await DbService.isar.writeTxn(() async {
        await DbService.isar.songs.deleteAll(songIds);
        await DbService.isar.albums.delete(album.id);
      });

      // Update in-memory playlist
      _playlist.removeWhere((s) => songIds.contains(s.id));

      if (currentInAlbum) {
        if (_playlist.isNotEmpty) {
          if (_currentIndex >= _playlist.length) {
            _currentIndex = 0;
          }
          final nextSong = _playlist[_currentIndex];
          state = state.copyWith(
            currentSong: nextSong,
            queue: List.from(_playlist),
          );
          await play(nextSong, play: wasPlaying);
        } else {
          _currentIndex = -1;
          state = PlaybackState(
            volume: state.volume,
            isShuffle: state.isShuffle,
            repeatMode: state.repeatMode,
            queue: [],
          );
          ref.read(equalizerProvider.notifier).onSongChanged(null);
          await ref.read(settingsProvider.notifier).updateLastPlayedSong(null);
        }
      } else {
        if (state.currentSong != null) {
          _currentIndex = _playlist.indexWhere((s) => s.id == state.currentSong!.id);
        }
        state = state.copyWith(queue: List.from(_playlist));
      }

      ref.read(appNavigationProvider.notifier).closeCollectionIfActive(album.name);
      await _cleanUpOrphanedArtistsAndAlbums();
      return deleteFromStorage ? (allDeleted ? FileActionResult.success : FileActionResult.dbOnly) : FileActionResult.success;
    } catch (e, s) {
      LoggerHelper.write('PlaybackNotifier: deleteAlbum error', e, s);
      return FileActionResult.failure;
    }
  }

  Future<FileActionResult> deleteArtist(Artist artist, List<Song> songs, {required bool deleteFromStorage}) async {
    final currentInArtist = songs.any((s) => s.id == state.currentSong?.id);
    final wasPlaying = state.isPlaying;

    if (currentInArtist) {
      await player.stop();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    bool allDeleted = true;
    if (deleteFromStorage) {
      for (final song in songs) {
        try {
          final file = File(song.path);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {
          allDeleted = false;
        }
      }
    }

    final songIds = songs.map((s) => s.id).toList();
    try {
      await DbService.isar.writeTxn(() async {
        await DbService.isar.songs.deleteAll(songIds);
        await DbService.isar.artists.delete(artist.id);
      });

      // Update in-memory playlist
      _playlist.removeWhere((s) => songIds.contains(s.id));

      if (currentInArtist) {
        if (_playlist.isNotEmpty) {
          if (_currentIndex >= _playlist.length) {
            _currentIndex = 0;
          }
          final nextSong = _playlist[_currentIndex];
          state = state.copyWith(
            currentSong: nextSong,
            queue: List.from(_playlist),
          );
          await play(nextSong, play: wasPlaying);
        } else {
          _currentIndex = -1;
          state = PlaybackState(
            volume: state.volume,
            isShuffle: state.isShuffle,
            repeatMode: state.repeatMode,
            queue: [],
          );
          ref.read(equalizerProvider.notifier).onSongChanged(null);
          await ref.read(settingsProvider.notifier).updateLastPlayedSong(null);
        }
      } else {
        if (state.currentSong != null) {
          _currentIndex = _playlist.indexWhere((s) => s.id == state.currentSong!.id);
        }
        state = state.copyWith(queue: List.from(_playlist));
      }

      ref.read(appNavigationProvider.notifier).closeCollectionIfActive(artist.name);
      await _cleanUpOrphanedArtistsAndAlbums();
      return deleteFromStorage ? (allDeleted ? FileActionResult.success : FileActionResult.dbOnly) : FileActionResult.success;
    } catch (e, s) {
      LoggerHelper.write('PlaybackNotifier: deleteArtist error', e, s);
      return FileActionResult.failure;
    }
  }

  Future<FileActionResult> deleteSong(Song song) async {
    final isCurrent = state.currentSong?.id == song.id;
    final wasPlaying = state.isPlaying;

    if (isCurrent) {
      // Completely stop player to release file handle locks
      await player.stop();
      // Wait for player to completely release the file handle
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final file = File(song.path);
    bool fileDeleted = false;
    try {
      if (await file.exists()) {
        await file.delete();
        fileDeleted = true;
      }
    } catch (e) {

    }

    bool dbSuccess = false;
    try {
      await DbService.isar.writeTxn(() async {
        await DbService.isar.songs.delete(song.id);
      });
      dbSuccess = true;

      // Update in-memory queue
      _playlist.removeWhere((s) => s.id == song.id);

      if (isCurrent) {
        if (_playlist.isNotEmpty) {
          if (_currentIndex >= _playlist.length) {
            _currentIndex = 0;
          }
          final nextSong = _playlist[_currentIndex];
          state = state.copyWith(
            currentSong: nextSong,
            queue: List.from(_playlist),
          );
          // Play or load the next song
          await play(nextSong, play: wasPlaying);
        } else {
          // Playlist is empty now
          _currentIndex = -1;
          state = PlaybackState(
            volume: state.volume,
            isShuffle: state.isShuffle,
            repeatMode: state.repeatMode,
            queue: [],
          );
          ref.read(equalizerProvider.notifier).onSongChanged(null);
          await ref.read(settingsProvider.notifier).updateLastPlayedSong(null);
        }
      } else {
        // Adjust _currentIndex if the deleted song was before the current one
        if (state.currentSong != null) {
          _currentIndex = _playlist.indexWhere((s) => s.id == state.currentSong!.id);
        }
        state = state.copyWith(queue: List.from(_playlist));
      }

      // Clean up orphaned artists and albums
      await _cleanUpOrphanedArtistsAndAlbums();
    } catch (e) {

    }

    if (!dbSuccess) {
      return FileActionResult.failure;
    }
    return fileDeleted ? FileActionResult.success : FileActionResult.dbOnly;
  }

  /// Synchronizes the active playback queue with the given available songs.
  /// Any song in the queue whose ID or file is missing will be automatically purged.
  Future<void> syncQueueWithAvailableSongs(List<Song> availableSongs) async {
    if (_playlist.isEmpty && state.queue.isEmpty) return;

    final availableIdSet = availableSongs.map((s) => s.id).toSet();
    final missingIds = <int>{};

    for (final s in _playlist) {
      if (!availableIdSet.contains(s.id)) {
        missingIds.add(s.id);
      }
    }

    if (missingIds.isNotEmpty) {
      await removeDeletedSongsFromQueue(missingIds);
    }
  }

  /// Removes deleted songs by ID from the active playlist, original playlist and state.queue.
  /// If the current song was among the deleted songs, it moves to the next valid song or stops.
  Future<void> removeDeletedSongsFromQueue(Iterable<int> deletedSongIds) async {
    if (deletedSongIds.isEmpty) return;
    final deletedSet = deletedSongIds.toSet();

    final wasCurrentDeleted = state.currentSong != null && deletedSet.contains(state.currentSong!.id);
    final wasPlaying = state.isPlaying;

    if (wasCurrentDeleted) {
      await player.stop();
    }

    _playlist.removeWhere((s) => deletedSet.contains(s.id));
    _originalPlaylist.removeWhere((s) => deletedSet.contains(s.id));

    if (wasCurrentDeleted) {
      if (_playlist.isNotEmpty) {
        if (_currentIndex >= _playlist.length) {
          _currentIndex = 0;
        }
        final nextSong = _playlist[_currentIndex];
        state = state.copyWith(
          currentSong: nextSong,
          queue: List.from(_playlist),
        );
        await play(nextSong, play: wasPlaying);
      } else {
        _currentIndex = -1;
        state = PlaybackState(
          volume: state.volume,
          isShuffle: state.isShuffle,
          repeatMode: state.repeatMode,
          queue: [],
        );
        ref.read(equalizerProvider.notifier).onSongChanged(null);
        await ref.read(settingsProvider.notifier).updateLastPlayedSong(null);
      }
    } else {
      if (state.currentSong != null) {
        _currentIndex = _playlist.indexWhere((s) => s.id == state.currentSong!.id);
      }
      state = state.copyWith(queue: List.from(_playlist));
    }

    if (_playlist.isEmpty) {
      final oldQueueName = _activeQueueName;
      if (oldQueueName.isNotEmpty && oldQueueName != QueueRepository.allSongsQueueName) {
        await _queueRepo.delete(oldQueueName);
        _activeQueueName = QueueRepository.allSongsQueueName;
        await ref.read(settingsProvider.notifier).updateActiveQueueName(QueueRepository.allSongsQueueName);
      }
    }

    // Also clean up any SavedQueues in database where songs were deleted
    try {
      await DbService.isar.writeTxn(() async {
        final allSavedQueues = await DbService.isar.savedQueues.where().findAll();
        for (final sq in allSavedQueues) {
          final remainingIds = sq.songIds.where((id) => !deletedSet.contains(id)).toList();
          if (remainingIds.isEmpty && !sq.isPermanent) {
            await DbService.isar.savedQueues.delete(sq.id);
          } else if (remainingIds.length != sq.songIds.length) {
            sq.songIds = remainingIds;
            if (sq.currentIndex >= remainingIds.length) {
              sq.currentIndex = math.max(0, remainingIds.length - 1);
            }
            await DbService.isar.savedQueues.put(sq);
          }
        }
      });
    } catch (_) {}
  }

  /// Verifies all songs in the current playback queue against the database/filesystem
  /// and purges any nonexistent or deleted songs.
  Future<void> validateAndCleanQueue() async {
    final existingDbSongs = await DbService.isar.songs.where().findAll();
    final existingIdSet = existingDbSongs.map((s) => s.id).toSet();

    final invalidIds = <int>{};
    for (final song in _playlist) {
      if (!existingIdSet.contains(song.id) || !File(song.path).existsSync()) {
        invalidIds.add(song.id);
      }
    }

    if (invalidIds.isNotEmpty) {
      await removeDeletedSongsFromQueue(invalidIds);
    }

    // Also purge all empty non-permanent saved queues from database
    try {
      await DbService.isar.writeTxn(() async {
        final allSavedQueues = await DbService.isar.savedQueues.where().findAll();
        for (final sq in allSavedQueues) {
          final validIds = sq.songIds.where((id) => existingIdSet.contains(id)).toList();
          if (validIds.isEmpty && !sq.isPermanent) {
            await DbService.isar.savedQueues.delete(sq.id);
          } else if (validIds.length != sq.songIds.length) {
            sq.songIds = validIds;
            if (sq.currentIndex >= validIds.length) {
              sq.currentIndex = math.max(0, validIds.length - 1);
            }
            await DbService.isar.savedQueues.put(sq);
          }
        }
      });
    } catch (_) {}
  }

  Future<void> _cleanUpOrphanedArtistsAndAlbums() async {
    try {
      await DbService.isar.writeTxn(() async {
        final remainingSongs = await DbService.isar.songs.where().findAll();
        final activeAlbumNames = remainingSongs.map((s) => s.album).toSet();
        final activeArtistNames = remainingSongs.map((s) => s.artist).toSet();

        final allAlbums = await DbService.isar.albums.where().findAll();
        final albumsToDelete = allAlbums.where((a) => !activeAlbumNames.contains(a.name)).map((a) => a.id).toList();
        if (albumsToDelete.isNotEmpty) {
          await DbService.isar.albums.deleteAll(albumsToDelete);
        }

        final allArtists = await DbService.isar.artists.where().findAll();
        final artistsToDelete = allArtists.where((art) => !activeArtistNames.contains(art.name)).map((art) => art.id).toList();
        if (artistsToDelete.isNotEmpty) {
          await DbService.isar.artists.deleteAll(artistsToDelete);
        }
      });
    } catch (e) {

    }
  }

  Future<void> shareSong(Song song) async {
    await Share.shareXFiles([XFile(song.path)], text: 'Check out this song: ${song.title}');
  }

  void _showErrorSnackBar(String defaultMessage, String Function(AppLocalizations) getLocalizedMessage) {
    final context = scaffoldMessengerKey.currentContext;
    String message = defaultMessage;
    if (context != null) {
      try {
        final l10n = AppLocalizations.of(context);
        if (l10n != null) {
          message = getLocalizedMessage(l10n);
        }
      } catch (e) {

      }
    }

    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.redAccent.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(
          bottom: 24,
          left: 24,
          right: 24,
        ),
      ),
    );
  }





  Timer? _sleepTimer;

  void startSleepTimer({Duration? duration, int? songCount}) {
    _sleepTimer?.cancel();
    _sleepTimer = null;

    if (duration != null) {
      state = state.copyWith(
        isSleepTimerActive: true,
        sleepTimerDurationRemaining: duration,
        sleepTimerDurationInitial: duration,
        sleepTimerSongsRemaining: null,
        sleepTimerSongsInitial: null,
      );

      final mins = duration.inMinutes;
      final secs = duration.inSeconds.remainder(60);
      final label = mins > 0 ? '$mins min${mins > 1 ? "s" : ""}' : '$secs seconds';
      AppToast.show(
        title: 'Sleep Timer Set',
        subtitle: 'Playback will stop in $label',
        iconData: LucideIcons.timer,
      );

      _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!state.isSleepTimerActive || state.sleepTimerDurationRemaining == null) {
          timer.cancel();
          _sleepTimer = null;
          return;
        }

        final remaining = state.sleepTimerDurationRemaining! - const Duration(seconds: 1);
        if (remaining <= Duration.zero) {
          timer.cancel();
          _sleepTimer = null;
          state = state.copyWith(
            isSleepTimerActive: false,
            sleepTimerDurationRemaining: null,
            sleepTimerSongsRemaining: null,
            sleepTimerDurationInitial: null,
            sleepTimerSongsInitial: null,
            isPlaying: false,
          );
          AppToast.show(
            title: 'Sleep Timer Finished',
            subtitle: 'Advanced to next track & paused',
            iconData: LucideIcons.moon,
          );
          // Fade out volume smoothly over 2 seconds before pausing on next track
          final savedVol = state.volume;
          _fadeVolume(0.0, const Duration(milliseconds: 2000)).then((_) async {
            await skipNext(isManual: false, shouldPlay: false);
            player.setVolume(savedVol * 100);
          });
        } else {
          state = state.copyWith(sleepTimerDurationRemaining: remaining);
        }
      });
    } else if (songCount != null) {
      state = state.copyWith(
        isSleepTimerActive: true,
        sleepTimerDurationRemaining: null,
        sleepTimerDurationInitial: null,
        sleepTimerSongsRemaining: songCount,
        sleepTimerSongsInitial: songCount,
      );
      AppToast.show(
        title: 'Sleep Timer Set',
        subtitle: 'Stopping after $songCount ${songCount == 1 ? "song" : "songs"}',
        iconData: LucideIcons.timer,
      );
    }
  }

  void stopSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    state = state.copyWith(
      isSleepTimerActive: false,
      sleepTimerDurationRemaining: null,
      sleepTimerSongsRemaining: null,
      sleepTimerDurationInitial: null,
      sleepTimerSongsInitial: null,
    );
    AppToast.show(
      title: 'Sleep Timer Cancelled',
      subtitle: 'Playback will continue normally',
      iconData: LucideIcons.timerOff,
    );
  }

  // ─── A-B Section Looper ───────────────────────────────────────────────────

  String _formatLoopTime(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final millis = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$minutes:$seconds.$millis';
  }

  /// Sets Marker A (loop start). Defaults to current playback position.
  void setLoopPointA([Duration? position]) {
    final pos = position ?? state.position;
    Duration? newEnd = state.loopEnd;
    if (newEnd != null && newEnd <= pos) {
      newEnd = null;
    }
    final shouldLoop = newEnd != null && newEnd > pos;
    state = state.copyWith(
      loopStart: pos,
      loopEnd: newEnd,
      isABLooping: shouldLoop,
    );
    AppToast.showLoopToast(
      title: 'Marker A Set',
      subtitle: '${_formatLoopTime(pos)}${shouldLoop ? "  •  Looping Active" : ""}',
    );
  }

  /// Sets Marker B (loop end). Defaults to current playback position.
  void setLoopPointB([Duration? position]) {
    final pos = position ?? state.position;
    final start = state.loopStart ?? Duration.zero;
    if (pos <= start) {
      state = state.copyWith(
        loopStart: Duration.zero,
        loopEnd: pos,
        isABLooping: pos > Duration.zero,
      );
      AppToast.showLoopToast(
        title: 'Marker B Set',
        subtitle: '${_formatLoopTime(pos)}  •  Looping from Start',
      );
      return;
    }
    state = state.copyWith(
      loopStart: start,
      loopEnd: pos,
      isABLooping: true,
    );
    AppToast.showLoopToast(
      title: 'Marker B Set',
      subtitle: '${_formatLoopTime(pos)}  •  Looping Active',
    );
  }

  /// Toggles A-B loop on/off without clearing markers (or sets points sequentially).
  void toggleABLoop() {
    if (state.isABLooping) {
      state = state.copyWith(isABLooping: false);
      AppToast.showLoopToast(
        title: 'A-B Loop Paused',
        subtitle: 'Normal playback resumed',
        iconData: LucideIcons.pause,
      );
    } else if (state.loopStart != null && state.loopEnd != null) {
      state = state.copyWith(isABLooping: true);
      if (state.position < state.loopStart! || state.position >= state.loopEnd!) {
        seek(state.loopStart!);
      }
      AppToast.showLoopToast(
        title: 'A-B Loop Active',
        subtitle: '${_formatLoopTime(state.loopStart!)} ➔ ${_formatLoopTime(state.loopEnd!)}',
      );
    } else if (state.loopStart == null) {
      setLoopPointA();
    } else {
      setLoopPointB();
    }
  }

  /// Clears A-B loop markers and disables looping.
  void clearABLoop() {
    state = state.copyWith(
      loopStart: null,
      loopEnd: null,
      isABLooping: false,
    );
    AppToast.showLoopToast(
      title: 'A-B Loop Cleared',
      subtitle: 'Markers reset',
      iconData: LucideIcons.trash2,
    );
  }

  /// Adjusts loop start point A by delta (e.g. +/- 500ms).
  void adjustLoopPointA(Duration delta) {
    if (state.loopStart == null) return;
    final maxA = state.loopEnd != null
        ? state.loopEnd! - const Duration(milliseconds: 100)
        : state.duration;
    final rawMs = (state.loopStart! + delta).inMilliseconds;
    final clampedMs = rawMs.clamp(0, maxA.inMilliseconds);
    final newA = Duration(milliseconds: clampedMs);
    state = state.copyWith(loopStart: newA);
    if (state.position < newA) {
      seek(newA);
    }
    AppToast.showLoopToast(
      title: 'Marker A Adjusted',
      subtitle: _formatLoopTime(newA),
    );
  }

  /// Adjusts loop end point B by delta (e.g. +/- 500ms).
  void adjustLoopPointB(Duration delta) {
    if (state.loopEnd == null) return;
    final minB = (state.loopStart ?? Duration.zero) + const Duration(milliseconds: 100);
    final maxB = state.duration;
    final rawMs = (state.loopEnd! + delta).inMilliseconds;
    final clampedMs = rawMs.clamp(minB.inMilliseconds, maxB.inMilliseconds);
    final newB = Duration(milliseconds: clampedMs);
    state = state.copyWith(loopEnd: newB);
    AppToast.showLoopToast(
      title: 'Marker B Adjusted',
      subtitle: _formatLoopTime(newB),
    );
  }

  /// Sets custom loop range directly.
  void setLoopRange(Duration start, Duration end) {
    if (end <= start) return;
    state = state.copyWith(
      loopStart: start,
      loopEnd: end,
      isABLooping: true,
    );
    if (state.position < start || state.position >= end) {
      seek(start);
    }
    final len = end - start;
    final lenSecs = (len.inMilliseconds / 1000).toStringAsFixed(1);
    AppToast.showLoopToast(
      title: 'A-B Loop Active (${lenSecs}s)',
      subtitle: '${_formatLoopTime(start)} ➔ ${_formatLoopTime(end)}',
    );
  }

  Future<void> _saveQueueState() async {
    final settings = ref.read(settingsProvider);
    if (!settings.persistQueue) return;
    final songIds = _playlist.map((s) => s.id).toList();
    await ref.read(settingsProvider.notifier).updateLastQueueState(
      songIds,
      _currentIndex,
      state.currentSong?.id,
      positionMs: state.position.inMilliseconds,
      activeQueueName: _activeQueueName,
    );
    if (_activeQueueName.isNotEmpty) {
      await _persistNamedQueue(_activeQueueName);
    }
  }

  Future<void> _persistNamedQueue(
    String name, {
    List<Song>? songs,
    int? currentIndex,
    int? positionMs,
    bool? isShuffle,
  }) async {
    final targetSongs = songs ?? _playlist;
    if (targetSongs.isEmpty) {
      if (name != QueueRepository.allSongsQueueName) {
        await _queueRepo.delete(name);
      }
      return;
    }
    final q = SavedQueue()
      ..name = name
      ..songIds = targetSongs.map((s) => s.id).toList()
      ..currentIndex = currentIndex ?? _currentIndex
      ..positionMs = positionMs ?? state.position.inMilliseconds
      ..isShuffle = isShuffle ?? state.isShuffle
      ..lastPlayed = DateTime.now()
      ..isPermanent = (name == QueueRepository.allSongsQueueName);
    await _queueRepo.save(q);
  }

  Future<void> _ensureDynamicQueue() async {
    // Only auto-fill random songs for the "All Songs" queue or an un-named fallback queue.
    // Specific playlists, albums, artists, Quick Picks, Recently Played, etc., preserve their exact song lists.
    final bool isAllSongsQueue =
        _activeQueueName.isEmpty || _activeQueueName == QueueRepository.allSongsQueueName;
    if (!isAllSongsQueue) return;

    final allSongs = await DbService.isar.songs.where().findAll();
    if (allSongs.isEmpty) return;

    bool playlistChanged = false;

    // 1. If playlist is empty, populate it with a random song
    if (_playlist.isEmpty) {
      final randomSong = allSongs[math.Random().nextInt(allSongs.length)];
      _playlist = [randomSong];
      _originalPlaylist = [randomSong];
      _currentIndex = 0;
      _manualQueueCount = 0;
      playlistChanged = true;
    }

    // 2. Ensure we have at least 5 songs ahead of the current index (dynamic queue auto-fill)
    const int bufferSize = 5;
    final existingPaths = _playlist.map((s) => s.path).toSet();
    while (_playlist.length - 1 - _currentIndex < bufferSize) {
      final lastSong = _playlist.isNotEmpty ? _playlist.last : null;
      var candidates = allSongs.where((s) => !existingPaths.contains(s.path)).toList();
      if (candidates.isEmpty) {
        if (lastSong != null) {
          candidates = allSongs.where((s) => s.path != lastSong.path).toList();
        }
        if (candidates.isEmpty) {
          candidates = allSongs;
        }
      }
      if (candidates.isEmpty) break;
      final nextSong = candidates[math.Random().nextInt(candidates.length)];
      _playlist.add(nextSong);
      _originalPlaylist.add(nextSong);
      existingPaths.add(nextSong.path);
      playlistChanged = true;
    }

    if (playlistChanged) {
      state = state.copyWith(queue: List.from(_playlist));
      await _saveQueueState();
    }
  }

  InterruptionPolicy _getInterruptionPolicy() {
    return InterruptionPolicy.pauseAndResume;
  }

  Timer? _fadeVolumeTimer;

  Future<void> _fadeVolume(double targetVolume, Duration duration) {
    final completer = Completer<void>();
    _fadeVolumeTimer?.cancel();
    if (duration.inMilliseconds <= 0) {
      player.setVolume(targetVolume * 100);
      return Future.value();
    }

    final double startVolume = player.state.volume / 100.0;
    final int steps = 15;
    final int stepMs = (duration.inMilliseconds / steps).round().clamp(10, 100);
    final double volumeStep = (targetVolume - startVolume) / steps;
    int currentStep = 0;

    _fadeVolumeTimer = Timer.periodic(Duration(milliseconds: stepMs), (timer) {
      currentStep++;
      final double nextVolume = (startVolume + (volumeStep * currentStep)).clamp(0.0, 1.5);
      player.setVolume(nextVolume * 100);

      if (currentStep >= steps) {
        timer.cancel();
        player.setVolume(targetVolume * 100);
        completer.complete();
      }
    });
    return completer.future;
  }

  Future<void> _performAutoCrossfade(int crossfadeSec) async {
    final fadeDuration = Duration(seconds: crossfadeSec);
    await _fadeVolume(0.0, fadeDuration);
    if (_autoCrossfadeTriggered && state.isPlaying) {
      await skipNext(isManual: false);
    }
  }

  void pauseForInterruption({required bool permanent}) {
    if (!state.isPlaying) return;

    _silenceTimer?.cancel();
    _songCompletionTimer?.cancel();
    _playCountTimer?.cancel();
    ref.read(audioServiceProvider).pause();
    state = state.copyWith(isPlaying: false);
    _updateNotification();
  }

  void resumeAfterInterruption() {
    if (state.isPlaying) return;

    _lastPlayTime = DateTime.now();
    ref.read(audioServiceProvider).resume();
    state = state.copyWith(isPlaying: true);
    final resumed = state.currentSong;
    if (resumed != null && _playCountedPath != resumed.path) {
      _armPlayCount(resumed);
    }
    _updateNotification();
  }

  void duckVolume() {
    _isDucked = true;
    player.setVolume(state.volume * 25.0); // Duck to 25% of current volume
  }

  void restoreVolume() {
    _isDucked = false;
    player.setVolume(state.volume * 100.0); // Restore normal volume
  }

  void pauseForNoisy() {
    if (!state.isPlaying) return;

    _silenceTimer?.cancel();
    _songCompletionTimer?.cancel();
    _playCountTimer?.cancel();
    ref.read(audioServiceProvider).pause();
    state = state.copyWith(isPlaying: false);
    _updateNotification();
  }

  void resumeOnBluetoothConnect() {
    final settings = ref.read(settingsProvider);
    if (state.isPlaying) return;

    if (settings.resumeOnBluetoothConnect) {
      _lastPlayTime = DateTime.now();
      ref.read(audioServiceProvider).resume();
      state = state.copyWith(isPlaying: true);
      final resumed = state.currentSong;
      if (resumed != null && _playCountedPath != resumed.path) {
        _armPlayCount(resumed);
      }
      _updateNotification();
    }
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _playCountTimer?.cancel();
    _sleepTimer?.cancel();
    _fadeVolumeTimer?.cancel();
    super.dispose();
  }
}

final playbackProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>(
  (ref) {
    return PlaybackNotifier(ref);
  },
);
