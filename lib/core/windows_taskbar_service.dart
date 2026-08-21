import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';

final windowsTaskbarServiceProvider = Provider<WindowsTaskbarService>((ref) {
  return WindowsTaskbarService(ref);
});

class WindowsTaskbarService {
  final Ref _ref;
  static const MethodChannel _channel = MethodChannel('com.looper.player/taskbar');
  bool _isInitialized = false;
  String? _lastArtworkPath;
  Map<String, dynamic>? _cachedArt;
  Timer? _positionThrottleTimer;

  WindowsTaskbarService(this._ref);

  void init() {
    if (kIsWeb || !Platform.isWindows || _isInitialized) return;
    _isInitialized = true;

    _channel.setMethodCallHandler(_handleMethodCall);

    _ref.listen<PlaybackState>(playbackProvider, (prev, next) {
      final songChanged = prev?.currentSong?.id != next.currentSong?.id;
      final playChanged = prev?.isPlaying != next.isPlaying;
      final queueChanged = prev?.queue.length != next.queue.length;

      if (songChanged || playChanged || queueChanged) {
        syncState(next);
      } else {
        // Throttle position updates during playback
        _throttlePositionSync(next);
      }
    });

    _ref.listen<bool>(
      settingsProvider.select((s) => s.enableTaskbarControls),
      (prev, next) {
        if (next) {
          syncState(_ref.read(playbackProvider));
        } else {
          _channel.invokeMethod('updateTaskbarControls', {
            'isPlaying': false,
            'canSkipPrev': false,
            'canSkipNext': false,
          });
        }
      },
    );

    // Initial sync
    syncState(_ref.read(playbackProvider));
  }

  void _throttlePositionSync(PlaybackState state) {
    if (_positionThrottleTimer?.isActive ?? false) return;
    _positionThrottleTimer = Timer(const Duration(seconds: 1), () {
      if (_isInitialized) {
        syncState(_ref.read(playbackProvider));
      }
    });
  }

  Future<void> syncState(PlaybackState playbackState) async {
    if (kIsWeb || !Platform.isWindows) return;

    final settings = _ref.read(settingsProvider);
    if (!settings.enableTaskbarControls) return;

    final song = playbackState.currentSong;
    final isPlaying = playbackState.isPlaying;
    final canSkipPrev = playbackState.queue.isNotEmpty;
    final canSkipNext = playbackState.queue.isNotEmpty;

    final pos = playbackState.position;
    final durMs = song?.duration;
    final dur = (durMs != null && durMs > 0)
        ? Duration(milliseconds: durMs)
        : playbackState.duration;

    final posStr = _formatDuration(pos);
    final durStr = _formatDuration(dur);
    final timeText = (dur > Duration.zero) ? '$posStr / $durStr' : posStr;

    final progress = (dur.inMilliseconds > 0)
        ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    // Load artwork bytes if changed
    if (song?.artPath != _lastArtworkPath) {
      _lastArtworkPath = song?.artPath;
      _cachedArt = await _loadArtworkRgba(_lastArtworkPath);
    }

    try {
      await _channel.invokeMethod('updateTaskbarControls', {
        'isPlaying': isPlaying,
        'canSkipPrev': canSkipPrev,
        'canSkipNext': canSkipNext,
        'title': song?.title ?? 'No Track Playing',
        'artist': song?.artist ?? 'Looper Player',
        'album': song?.album ?? '',
        'timeText': timeText,
        'progress': progress,
        'accentColor': settings.accentColor,
        'artBytes': _cachedArt?['bytes'],
        'artWidth': _cachedArt?['width'] ?? 0,
        'artHeight': _cachedArt?['height'] ?? 0,
      });
    } catch (e) {
      debugPrint('[WindowsTaskbarService] Error updating taskbar controls: $e');
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<Map<String, dynamic>?> _loadArtworkRgba(String? path) async {
    if (path == null || path.isEmpty || !File(path).existsSync()) return null;
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 80, targetHeight: 80);
      final frame = await codec.getNextFrame();
      final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData != null) {
        return {
          'bytes': byteData.buffer.asUint8List(),
          'width': frame.image.width,
          'height': frame.image.height,
        };
      }
    } catch (e) {
      debugPrint('[WindowsTaskbarService] Error loading artwork: $e');
    }
    return null;
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    debugPrint('[WindowsTaskbarService] Received method: ${call.method}');
    final playback = _ref.read(playbackProvider.notifier);

    switch (call.method) {
      case 'onPrevious':
        playback.skipPrevious();
        break;
      case 'onPlayPause':
        playback.togglePlay();
        break;
      case 'onNext':
        playback.skipNext();
        break;
    }
  }
}
