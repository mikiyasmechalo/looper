import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';

import 'logger_helper.dart';

/// Service responsible for reclaiming committed native memory and trimming
/// unused working set pages on desktop platforms.
class MemoryService {
  /// Flushes transient startup pages and unreferenced memory from the active
  /// Windows working set back to the OS standby list.
  ///
  /// This dramatically lowers the physical RAM consumption reported by
  /// Task Manager without impacting running performance or active playback.
  static void trimWorkingSet() {
    if (!Platform.isWindows) return;

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
}
