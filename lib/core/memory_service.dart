import 'dart:async';
import 'dart:io';
import 'package:flutter/painting.dart';
import 'package:win32/win32.dart';

import 'logger_helper.dart';

/// Service responsible for reclaiming committed native memory and trimming
/// unused working set pages on desktop platforms.
class MemoryService {
  static Timer? _periodicTimer;
  static DateTime _lastTrimTime = DateTime.fromMillisecondsSinceEpoch(0);

  /// Flushes transient startup pages, dead live images, and unreferenced memory
  /// from the active Windows working set back to the OS standby list.
  ///
  /// This dramatically lowers the physical RAM consumption reported by
  /// Task Manager without impacting running performance or active playback.
  static void trimWorkingSet({bool clearImageCache = false}) {
    if (!Platform.isWindows) return;

    final now = DateTime.now();
    // Debounce to at most once every 2 seconds to avoid OS churn
    if (now.difference(_lastTrimTime).inMilliseconds < 2000) {
      return;
    }
    _lastTrimTime = now;

    if (clearImageCache) {
      try {
        PaintingBinding.instance.imageCache.clearLiveImages();
      } catch (_) {}
    }

    try {
      final handle = GetCurrentProcess();
      final result = SetProcessWorkingSetSize(handle, -1, -1);
      if (result != 0) {
        LoggerHelper.write('MemoryService: Successfully trimmed process working set.');
      } else {
        LoggerHelper.write('MemoryService: SetProcessWorkingSetSize returned 0 (failed).');
      }
    } catch (e, stack) {
      LoggerHelper.write('MemoryService: Failed to trim working set.', e, stack);
    }
  }

  /// Starts a periodic background timer that sweeps the process working set,
  /// keeping the memory footprint consistently low during continuous playback.
  static void startPeriodicTrimming([Duration interval = const Duration(seconds: 60)]) {
    if (!Platform.isWindows) return;
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(interval, (_) {
      trimWorkingSet();
    });
    LoggerHelper.write('MemoryService: Started periodic working set trimming (every ${interval.inSeconds}s).');
  }

  /// Cancels the periodic trimming timer.
  static void stopPeriodicTrimming() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }
}
