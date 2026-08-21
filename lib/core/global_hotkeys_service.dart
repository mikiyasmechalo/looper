import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:looper_player/core/providers.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/features/shortcuts/domain/shortcut_models.dart';
import 'package:looper_player/features/shortcuts/presentation/shortcuts_provider.dart';

final globalHotkeysServiceProvider = Provider<GlobalHotkeysService>((ref) {
  return GlobalHotkeysService(ref);
});

class GlobalHotkeysService {
  final Ref _ref;
  bool _isRegistered = false;
  final Map<String, HotKey> _registeredHotKeys = {};

  GlobalHotkeysService(this._ref);

  /// Initializes system-wide global hotkeys.
  Future<void> init() async {
    if (kIsWeb || !(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      return;
    }

    try {
      await hotKeyManager.unregisterAll();
    } catch (e) {
      debugPrint('[GlobalHotkeys] Error unregistering prior hotkeys: $e');
    }

    // Listen to changes in settings & custom shortcuts
    _ref.listen<bool>(
      settingsProvider.select((s) => s.enableGlobalHotkeys),
      (prev, next) {
        if (next) {
          syncHotKeys();
        } else {
          unregisterAll();
        }
      },
    );

    _ref.listen(shortcutsProvider, (prev, next) {
      if (_ref.read(settingsProvider).enableGlobalHotkeys) {
        syncHotKeys();
      }
    });

    final enabled = _ref.read(settingsProvider).enableGlobalHotkeys;
    if (enabled) {
      await syncHotKeys();
    }
  }

  /// Synchronizes all enabled global hotkeys.
  Future<void> syncHotKeys() async {
    if (kIsWeb || !(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      return;
    }

    final enabled = _ref.read(settingsProvider).enableGlobalHotkeys;
    if (!enabled) {
      await unregisterAll();
      return;
    }

    await unregisterAll();

    final globalActions = AppShortcutAction.all
        .where((a) => a.category == ShortcutCategory.global)
        .toList();

    for (final action in globalActions) {
      final binding = _ref.read(shortcutsProvider.notifier).getBinding(action);
      if (binding == null) continue;

      final hotKey = _convertToHotKey(binding);
      if (hotKey != null) {
        try {
          await hotKeyManager.register(
            hotKey,
            keyDownHandler: (k) => _handleAction(action.id),
          );
          _registeredHotKeys[action.id] = hotKey;
          debugPrint('[GlobalHotkeys] Registered ${action.id} -> ${binding.displayString}');
        } catch (e) {
          debugPrint('[GlobalHotkeys] Failed to register ${action.id} (${binding.displayString}): $e');
        }
      }
    }

    _isRegistered = true;
  }

  Future<void> unregisterAll() async {
    if (kIsWeb || !(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      return;
    }
    try {
      await hotKeyManager.unregisterAll();
      _registeredHotKeys.clear();
      _isRegistered = false;
    } catch (e) {
      debugPrint('[GlobalHotkeys] Error during unregisterAll: $e');
    }
  }

  void _handleAction(String actionId) {
    debugPrint('[GlobalHotkeys] Triggered global action: $actionId');
    final playback = _ref.read(playbackProvider.notifier);

    switch (actionId) {
      case 'global_play_pause':
        playback.togglePlay();
        break;
      case 'global_next_track':
        playback.skipNext();
        break;
      case 'global_previous_track':
        playback.skipPrevious();
        break;
      case 'global_toggle_favorite':
        playback.toggleFavorite();
        break;
      case 'global_copy_song_info':
        final currentSong = _ref.read(playbackProvider).currentSong;
        if (currentSong != null) {
          final text = '${currentSong.title} - ${currentSong.artist ?? 'Unknown Artist'}';
          Clipboard.setData(ClipboardData(text: text));
        }
        break;
      case 'global_volume_up':
        playback.adjustVolume(0.05);
        break;
      case 'global_volume_down':
        playback.adjustVolume(-0.05);
        break;
      case 'global_toggle_mute':
        playback.toggleMute();
        break;
    }
  }

  HotKey? _convertToHotKey(AppKeyCombo combo) {
    final physicalKey = _mapToPhysical(combo.key);
    if (physicalKey == null) return null;

    final modifiers = <HotKeyModifier>[];
    if (combo.isCtrl) modifiers.add(HotKeyModifier.control);
    if (combo.isAlt) modifiers.add(HotKeyModifier.alt);
    if (combo.isShift) modifiers.add(HotKeyModifier.shift);
    if (combo.isMeta) modifiers.add(HotKeyModifier.meta);

    // If bare key with no modifiers (and not a media key), add default Ctrl+Alt to prevent blocking system typing
    if (modifiers.isEmpty && !_isSelfContainedGlobalKey(combo.key)) {
      modifiers.add(HotKeyModifier.control);
      modifiers.add(HotKeyModifier.alt);
    }

    return HotKey(
      key: physicalKey,
      modifiers: modifiers.isEmpty ? null : modifiers,
      scope: HotKeyScope.system,
    );
  }

  bool _isSelfContainedGlobalKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.mediaPlayPause ||
        key == LogicalKeyboardKey.mediaTrackNext ||
        key == LogicalKeyboardKey.mediaTrackPrevious ||
        key == LogicalKeyboardKey.mediaStop ||
        key == LogicalKeyboardKey.audioVolumeUp ||
        key == LogicalKeyboardKey.audioVolumeDown ||
        key == LogicalKeyboardKey.audioVolumeMute ||
        (key.keyId >= LogicalKeyboardKey.f1.keyId && key.keyId <= LogicalKeyboardKey.f24.keyId);
  }

  PhysicalKeyboardKey? _mapToPhysical(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.space) return PhysicalKeyboardKey.space;
    if (key == LogicalKeyboardKey.arrowLeft) return PhysicalKeyboardKey.arrowLeft;
    if (key == LogicalKeyboardKey.arrowRight) return PhysicalKeyboardKey.arrowRight;
    if (key == LogicalKeyboardKey.arrowUp) return PhysicalKeyboardKey.arrowUp;
    if (key == LogicalKeyboardKey.arrowDown) return PhysicalKeyboardKey.arrowDown;
    if (key == LogicalKeyboardKey.keyA) return PhysicalKeyboardKey.keyA;
    if (key == LogicalKeyboardKey.keyB) return PhysicalKeyboardKey.keyB;
    if (key == LogicalKeyboardKey.keyC) return PhysicalKeyboardKey.keyC;
    if (key == LogicalKeyboardKey.keyD) return PhysicalKeyboardKey.keyD;
    if (key == LogicalKeyboardKey.keyE) return PhysicalKeyboardKey.keyE;
    if (key == LogicalKeyboardKey.keyF) return PhysicalKeyboardKey.keyF;
    if (key == LogicalKeyboardKey.keyG) return PhysicalKeyboardKey.keyG;
    if (key == LogicalKeyboardKey.keyH) return PhysicalKeyboardKey.keyH;
    if (key == LogicalKeyboardKey.keyI) return PhysicalKeyboardKey.keyI;
    if (key == LogicalKeyboardKey.keyJ) return PhysicalKeyboardKey.keyJ;
    if (key == LogicalKeyboardKey.keyK) return PhysicalKeyboardKey.keyK;
    if (key == LogicalKeyboardKey.keyL) return PhysicalKeyboardKey.keyL;
    if (key == LogicalKeyboardKey.keyM) return PhysicalKeyboardKey.keyM;
    if (key == LogicalKeyboardKey.keyN) return PhysicalKeyboardKey.keyN;
    if (key == LogicalKeyboardKey.keyO) return PhysicalKeyboardKey.keyO;
    if (key == LogicalKeyboardKey.keyP) return PhysicalKeyboardKey.keyP;
    if (key == LogicalKeyboardKey.keyQ) return PhysicalKeyboardKey.keyQ;
    if (key == LogicalKeyboardKey.keyR) return PhysicalKeyboardKey.keyR;
    if (key == LogicalKeyboardKey.keyS) return PhysicalKeyboardKey.keyS;
    if (key == LogicalKeyboardKey.keyT) return PhysicalKeyboardKey.keyT;
    if (key == LogicalKeyboardKey.keyU) return PhysicalKeyboardKey.keyU;
    if (key == LogicalKeyboardKey.keyV) return PhysicalKeyboardKey.keyV;
    if (key == LogicalKeyboardKey.keyW) return PhysicalKeyboardKey.keyW;
    if (key == LogicalKeyboardKey.keyX) return PhysicalKeyboardKey.keyX;
    if (key == LogicalKeyboardKey.keyY) return PhysicalKeyboardKey.keyY;
    if (key == LogicalKeyboardKey.keyZ) return PhysicalKeyboardKey.keyZ;
    if (key == LogicalKeyboardKey.digit0) return PhysicalKeyboardKey.digit0;
    if (key == LogicalKeyboardKey.digit1) return PhysicalKeyboardKey.digit1;
    if (key == LogicalKeyboardKey.digit2) return PhysicalKeyboardKey.digit2;
    if (key == LogicalKeyboardKey.digit3) return PhysicalKeyboardKey.digit3;
    if (key == LogicalKeyboardKey.digit4) return PhysicalKeyboardKey.digit4;
    if (key == LogicalKeyboardKey.digit5) return PhysicalKeyboardKey.digit5;
    if (key == LogicalKeyboardKey.digit6) return PhysicalKeyboardKey.digit6;
    if (key == LogicalKeyboardKey.digit7) return PhysicalKeyboardKey.digit7;
    if (key == LogicalKeyboardKey.digit8) return PhysicalKeyboardKey.digit8;
    if (key == LogicalKeyboardKey.digit9) return PhysicalKeyboardKey.digit9;
    if (key == LogicalKeyboardKey.comma) return PhysicalKeyboardKey.comma;
    if (key == LogicalKeyboardKey.period) return PhysicalKeyboardKey.period;
    if (key == LogicalKeyboardKey.slash) return PhysicalKeyboardKey.slash;
    if (key == LogicalKeyboardKey.semicolon) return PhysicalKeyboardKey.semicolon;
    if (key == LogicalKeyboardKey.quote) return PhysicalKeyboardKey.quote;
    if (key == LogicalKeyboardKey.bracketLeft) return PhysicalKeyboardKey.bracketLeft;
    if (key == LogicalKeyboardKey.bracketRight) return PhysicalKeyboardKey.bracketRight;
    if (key == LogicalKeyboardKey.backslash) return PhysicalKeyboardKey.backslash;
    if (key == LogicalKeyboardKey.minus) return PhysicalKeyboardKey.minus;
    if (key == LogicalKeyboardKey.equal) return PhysicalKeyboardKey.equal;
    if (key == LogicalKeyboardKey.mediaPlayPause) return PhysicalKeyboardKey.mediaPlayPause;
    if (key == LogicalKeyboardKey.mediaTrackNext) return PhysicalKeyboardKey.mediaTrackNext;
    if (key == LogicalKeyboardKey.mediaTrackPrevious) return PhysicalKeyboardKey.mediaTrackPrevious;
    if (key == LogicalKeyboardKey.mediaStop) return PhysicalKeyboardKey.mediaStop;
    if (key == LogicalKeyboardKey.f1) return PhysicalKeyboardKey.f1;
    if (key == LogicalKeyboardKey.f2) return PhysicalKeyboardKey.f2;
    if (key == LogicalKeyboardKey.f3) return PhysicalKeyboardKey.f3;
    if (key == LogicalKeyboardKey.f4) return PhysicalKeyboardKey.f4;
    if (key == LogicalKeyboardKey.f5) return PhysicalKeyboardKey.f5;
    if (key == LogicalKeyboardKey.f6) return PhysicalKeyboardKey.f6;
    if (key == LogicalKeyboardKey.f7) return PhysicalKeyboardKey.f7;
    if (key == LogicalKeyboardKey.f8) return PhysicalKeyboardKey.f8;
    if (key == LogicalKeyboardKey.f9) return PhysicalKeyboardKey.f9;
    if (key == LogicalKeyboardKey.f10) return PhysicalKeyboardKey.f10;
    if (key == LogicalKeyboardKey.f11) return PhysicalKeyboardKey.f11;
    if (key == LogicalKeyboardKey.f12) return PhysicalKeyboardKey.f12;
    return null;
  }
}
