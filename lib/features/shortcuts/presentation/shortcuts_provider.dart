import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/core/providers.dart';
import 'package:looper_player/features/playback/presentation/mini_player_overlay_service.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/search/presentation/search_view.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/features/shortcuts/domain/shortcut_models.dart';
import 'package:looper_player/features/shortcuts/presentation/widgets/shortcuts_cheatsheet_dialog.dart';
import 'package:looper_player/features/stats/presentation/stats_dialog.dart';
import 'package:looper_player/features/stats/presentation/stats_provider.dart';
import 'package:looper_player/ui/widgets/sleep_timer_sheet_content.dart';

final shortcutsProvider =
    StateNotifierProvider<ShortcutsNotifier, Map<String, String>>((ref) {
  return ShortcutsNotifier(ref);
});

class ShortcutsNotifier extends StateNotifier<Map<String, String>> {
  final Ref _ref;

  ShortcutsNotifier(this._ref) : super({}) {
    _loadFromSettings();
  }

  void _loadFromSettings() {
    final rawJson = _ref.read(settingsProvider).customShortcutsJson;
    state = _parseMap(rawJson);
  }

  static Map<String, String> _parseMap(String rawJson) {
    if (rawJson.isEmpty || rawJson == '{}') return {};
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (_) {}
    return {};
  }

  /// Gets the active key combination for an action.
  /// Returns null if the user explicitly unbound/cleared the shortcut.
  AppKeyCombo? getBinding(AppShortcutAction action) {
    // If customized in state
    if (state.containsKey(action.id)) {
      final raw = state[action.id];
      if (raw == 'none' || raw == null || raw.isEmpty) return null;
      return AppKeyCombo.deserialize(raw);
    }
    return action.defaultPrimary;
  }

  /// Whether this action has been customized by the user.
  bool isCustomized(AppShortcutAction action) {
    return state.containsKey(action.id);
  }

  /// Sets or clears a custom shortcut for an action.
  Future<void> setShortcut(AppShortcutAction action, AppKeyCombo? combo) async {
    final updated = Map<String, String>.from(state);
    if (combo == null) {
      updated[action.id] = 'none';
    } else {
      updated[action.id] = combo.serialize();
    }
    state = updated;
    await _ref
        .read(settingsProvider.notifier)
        .updateCustomShortcutsJson(jsonEncode(updated));
  }

  /// Resets a single action back to its default binding.
  Future<void> resetShortcut(AppShortcutAction action) async {
    final updated = Map<String, String>.from(state);
    updated.remove(action.id);
    state = updated;
    await _ref
        .read(settingsProvider.notifier)
        .updateCustomShortcutsJson(jsonEncode(updated));
  }

  /// Resets all shortcuts to system defaults.
  Future<void> resetAllShortcuts() async {
    state = {};
    await _ref
        .read(settingsProvider.notifier)
        .updateCustomShortcutsJson('{}');
  }

  /// Checks if another action is currently using [combo].
  AppShortcutAction? checkConflict(AppShortcutAction currentAction, AppKeyCombo combo) {
    for (final action in AppShortcutAction.all) {
      if (action.id == currentAction.id) continue;
      final active = getBinding(action);
      if (active != null && active == combo) {
        return action;
      }
    }
    return null;
  }

  /// Dispatches incoming key events to the matching action.
  bool handleKeyEvent(KeyEvent event, WidgetRef ref) {
    if (event is! KeyDownEvent) return false;

    // Check custom and primary bindings, prioritizing modified keys (Ctrl/Alt/Shift) first
    final actionsWithCombo = <MapEntry<AppShortcutAction, AppKeyCombo>>[];
    final secondaryCombos = <MapEntry<AppShortcutAction, AppKeyCombo>>[];

    for (final action in AppShortcutAction.all) {
      final active = getBinding(action);
      if (active != null) {
        actionsWithCombo.add(MapEntry(action, active));
      }
      // If not customized, also support secondary defaults (e.g. Media keys)
      if (!isCustomized(action) && action.defaultSecondary != null) {
        secondaryCombos.add(MapEntry(action, action.defaultSecondary!));
      }
    }

    // Sort: actions requiring modifiers tested first
    actionsWithCombo.sort((a, b) {
      final aMod = a.value.hasModifiers ? 1 : 0;
      final bMod = b.value.hasModifiers ? 1 : 0;
      return bMod.compareTo(aMod);
    });

    for (final entry in actionsWithCombo) {
      if (entry.value.matches(event)) {
        return _executeAction(entry.key, ref);
      }
    }

    for (final entry in secondaryCombos) {
      if (entry.value.matches(event)) {
        return _executeAction(entry.key, ref);
      }
    }

    return false;
  }

  bool _executeAction(AppShortcutAction action, WidgetRef ref) {
    final playback = ref.read(playbackProvider.notifier);
    final nav = ref.read(appNavigationProvider.notifier);

    switch (action.id) {
      case 'play_pause':
        playback.togglePlay();
        return true;
      case 'next_track':
        playback.skipNext();
        return true;
      case 'previous_track':
        playback.skipPrevious();
        return true;
      case 'stop_playback':
        final isPlaying = ref.read(playbackProvider).isPlaying;
        if (isPlaying) playback.togglePlay();
        playback.seek(Duration.zero);
        return true;
      case 'toggle_shuffle':
        playback.toggleShuffle();
        return true;
      case 'cycle_repeat':
        playback.nextRepeatMode();
        return true;
      case 'toggle_favorite':
        playback.toggleFavorite();
        return true;
      case 'set_loop_a':
        playback.setLoopPointA();
        return true;
      case 'set_loop_b':
        playback.setLoopPointB();
        return true;
      case 'toggle_ab_loop':
        playback.toggleABLoop();
        return true;
      case 'clear_ab_loop':
        playback.clearABLoop();
        return true;
      case 'toggle_sleep_timer':
        final isSleepActive = ref.read(playbackProvider).isSleepTimerActive;
        if (isSleepActive) {
          playback.stopSleepTimer();
        } else {
          final context = rootNavigatorKey.currentContext;
          if (context != null) {
            showSleepTimer(context, ref);
          }
        }
        return true;

      // Seeking & Volume
      case 'seek_forward_5':
        playback.seekRelative(5);
        return true;
      case 'seek_backward_5':
        playback.seekRelative(-5);
        return true;
      case 'seek_forward_10':
        playback.seekRelative(10);
        return true;
      case 'seek_backward_10':
        playback.seekRelative(-10);
        return true;
      case 'seek_forward_30':
        playback.seekRelative(30);
        return true;
      case 'seek_backward_30':
        playback.seekRelative(-30);
        return true;
      case 'seek_to_start':
        playback.seek(Duration.zero);
        return true;
      case 'volume_up':
        playback.adjustVolume(0.05);
        return true;
      case 'volume_down':
        playback.adjustVolume(-0.05);
        return true;
      case 'volume_up_large':
        playback.adjustVolume(0.10);
        return true;
      case 'volume_down_large':
        playback.adjustVolume(-0.10);
        return true;
      case 'toggle_mute':
        playback.toggleMute();
        return true;

      // Navigation & Pages
      case 'open_search':
        ref.read(searchFocusNodeProvider).requestFocus();
        nav.setItem(NavItem.search);
        return true;
      case 'go_home':
        nav.setItem(NavItem.home);
        return true;
      case 'go_songs':
        nav.setItem(NavItem.songs);
        return true;
      case 'go_albums':
        nav.setItem(NavItem.albums);
        return true;
      case 'go_artists':
        nav.setItem(NavItem.artists);
        return true;
      case 'go_playlists':
        nav.setItem(NavItem.playlists);
        return true;
      case 'go_genres':
        nav.setItem(NavItem.genres);
        return true;
      case 'go_settings':
        nav.setItem(NavItem.settings);
        return true;
      case 'toggle_lyrics':
        nav.toggleItem(NavItem.lyrics);
        return true;
      case 'toggle_queue':
        nav.toggleItem(NavItem.queue);
        return true;

      // Display & Overlays
      case 'toggle_fullscreen_player':
        nav.togglePlayerExpansion();
        return true;
      case 'toggle_mini_player':
        final mode = ref.read(miniPlayerModeProvider);
        final service = ref.read(miniPlayerOverlayServiceProvider);
        if (mode == MiniPlayerMode.none) {
          final defaultType = ref.read(settingsProvider).defaultMiniPlayerType;
          if (defaultType == 1) {
            service.enterCornerWidgetMode();
          } else {
            service.enterMiniPlayerMode();
          }
        } else {
          service.exit();
        }
        return true;
      case 'show_cheatsheet':
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          showShortcutsCheatsheetDialog(context);
        }
        return true;
      case 'show_stats':
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          ref.read(statsProvider.notifier).refresh();
          showStatsDialog(context);
        }
        return true;
      default:
        return false;
    }
  }
}
