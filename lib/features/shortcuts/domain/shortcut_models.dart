import 'dart:io';
import 'package:flutter/services.dart';

enum ShortcutCategory {
  playback('Playback Controls'),
  seekingAndVolume('Seeking & Volume'),
  navigation('Navigation & Pages'),
  displayAndUi('Display & Overlays');

  final String label;
  const ShortcutCategory(this.label);
}

class AppKeyCombo {
  final LogicalKeyboardKey key;
  final bool isCtrl;
  final bool isAlt;
  final bool isShift;
  final bool isMeta;

  const AppKeyCombo({
    required this.key,
    this.isCtrl = false,
    this.isAlt = false,
    this.isShift = false,
    this.isMeta = false,
  });

  /// True if this combo requires modifier keys.
  bool get hasModifiers => isCtrl || isAlt || isShift || isMeta;

  /// Human-friendly representation of the key name.
  static String getKeyLabel(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.space) return 'Space';
    if (key == LogicalKeyboardKey.arrowUp) return '↑';
    if (key == LogicalKeyboardKey.arrowDown) return '↓';
    if (key == LogicalKeyboardKey.arrowLeft) return '←';
    if (key == LogicalKeyboardKey.arrowRight) return '→';
    if (key == LogicalKeyboardKey.escape) return 'Esc';
    if (key == LogicalKeyboardKey.slash) return '/';
    if (key == LogicalKeyboardKey.comma) return ',';
    if (key == LogicalKeyboardKey.period) return '.';
    if (key == LogicalKeyboardKey.enter) return 'Enter';
    if (key == LogicalKeyboardKey.tab) return 'Tab';
    if (key == LogicalKeyboardKey.backspace) return 'Backspace';
    if (key == LogicalKeyboardKey.delete) return 'Delete';
    if (key == LogicalKeyboardKey.home) return 'Home';
    if (key == LogicalKeyboardKey.end) return 'End';
    if (key == LogicalKeyboardKey.pageUp) return 'Page Up';
    if (key == LogicalKeyboardKey.pageDown) return 'Page Down';
    if (key == LogicalKeyboardKey.mediaPlayPause) return 'Media Play/Pause';
    if (key == LogicalKeyboardKey.mediaTrackNext) return 'Media Next';
    if (key == LogicalKeyboardKey.mediaTrackPrevious) return 'Media Previous';
    if (key == LogicalKeyboardKey.mediaStop) return 'Media Stop';
    if (key == LogicalKeyboardKey.audioVolumeUp) return 'Volume Up';
    if (key == LogicalKeyboardKey.audioVolumeDown) return 'Volume Down';
    if (key == LogicalKeyboardKey.audioVolumeMute) return 'Mute';

    final label = key.keyLabel;
    if (label.isNotEmpty && label.trim().isNotEmpty) {
      return label.toUpperCase();
    }
    return key.debugName ?? 'Key(${key.keyId})';
  }

  /// Formats the combo for display, e.g. "Ctrl + Shift + F" or "Space".
  String get displayString {
    final parts = <String>[];
    final isMac = Platform.isMacOS;

    if (isCtrl) parts.add(isMac ? '⌃' : 'Ctrl');
    if (isAlt) parts.add(isMac ? '⌥' : 'Alt');
    if (isShift) parts.add(isMac ? '⇧' : 'Shift');
    if (isMeta) parts.add(isMac ? '⌘' : 'Win');

    parts.add(getKeyLabel(key));
    return parts.join(' + ');
  }

  /// List of badge chips for beautiful UI rendering.
  List<String> get badgeChips {
    final parts = <String>[];
    final isMac = Platform.isMacOS;

    if (isCtrl) parts.add(isMac ? '⌃ Control' : 'Ctrl');
    if (isAlt) parts.add(isMac ? '⌥ Option' : 'Alt');
    if (isShift) parts.add(isMac ? '⇧ Shift' : 'Shift');
    if (isMeta) parts.add(isMac ? '⌘ Cmd' : 'Win');

    parts.add(getKeyLabel(key));
    return parts;
  }

  /// Serializes into a compact stable string: "ctrl|alt|shift|meta|keyId"
  String serialize() {
    return '${isCtrl ? 1 : 0}|${isAlt ? 1 : 0}|${isShift ? 1 : 0}|${isMeta ? 1 : 0}|${key.keyId}';
  }

  /// Deserializes a string produced by [serialize].
  static AppKeyCombo? deserialize(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('|');
    if (parts.length != 5) return null;

    final isCtrl = parts[0] == '1';
    final isAlt = parts[1] == '1';
    final isShift = parts[2] == '1';
    final isMeta = parts[3] == '1';
    final keyId = int.tryParse(parts[4]);
    if (keyId == null) return null;

    final key = LogicalKeyboardKey.findKeyByKeyId(keyId) ?? LogicalKeyboardKey(keyId);
    return AppKeyCombo(
      key: key,
      isCtrl: isCtrl,
      isAlt: isAlt,
      isShift: isShift,
      isMeta: isMeta,
    );
  }

  /// Checks if a hardware KeyEvent matches this combination.
  bool matches(KeyEvent event) {
    if (event.logicalKey.keyId != key.keyId) {
      return false;
    }

    final ctrlPressed = HardwareKeyboard.instance.isControlPressed;
    final altPressed = HardwareKeyboard.instance.isAltPressed;
    final shiftPressed = HardwareKeyboard.instance.isShiftPressed;
    final metaPressed = HardwareKeyboard.instance.isMetaPressed;

    if (isCtrl != ctrlPressed) return false;
    if (isAlt != altPressed) return false;
    if (isShift != shiftPressed) return false;
    if (isMeta != metaPressed) return false;

    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppKeyCombo &&
        other.key.keyId == key.keyId &&
        other.isCtrl == isCtrl &&
        other.isAlt == isAlt &&
        other.isShift == isShift &&
        other.isMeta == isMeta;
  }

  @override
  int get hashCode => Object.hash(key.keyId, isCtrl, isAlt, isShift, isMeta);
}

class AppShortcutAction {
  final String id;
  final String title;
  final String description;
  final ShortcutCategory category;
  final AppKeyCombo defaultPrimary;
  final AppKeyCombo? defaultSecondary;

  const AppShortcutAction({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.defaultPrimary,
    this.defaultSecondary,
  });

  /// All registered shortcut actions with their rich defaults.
  static final List<AppShortcutAction> all = [
    // ─── Playback Controls ──────────────────────────────────────────────────
    const AppShortcutAction(
      id: 'play_pause',
      title: 'Play / Pause',
      description: 'Toggle audio playback on and off',
      category: ShortcutCategory.playback,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.space),
      defaultSecondary: AppKeyCombo(key: LogicalKeyboardKey.mediaPlayPause),
    ),
    const AppShortcutAction(
      id: 'next_track',
      title: 'Next Track',
      description: 'Skip to the next song in the queue',
      category: ShortcutCategory.playback,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.arrowRight, isAlt: true),
      defaultSecondary: AppKeyCombo(key: LogicalKeyboardKey.mediaTrackNext),
    ),
    const AppShortcutAction(
      id: 'previous_track',
      title: 'Previous Track',
      description: 'Skip to the previous song in the queue',
      category: ShortcutCategory.playback,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.arrowLeft, isAlt: true),
      defaultSecondary: AppKeyCombo(key: LogicalKeyboardKey.mediaTrackPrevious),
    ),
    const AppShortcutAction(
      id: 'stop_playback',
      title: 'Stop Playback',
      description: 'Stop audio playback completely',
      category: ShortcutCategory.playback,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.keyX),
      defaultSecondary: AppKeyCombo(key: LogicalKeyboardKey.mediaStop),
    ),
    const AppShortcutAction(
      id: 'toggle_shuffle',
      title: 'Toggle Shuffle',
      description: 'Toggle queue shuffle mode on or off',
      category: ShortcutCategory.playback,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.keyS),
    ),
    const AppShortcutAction(
      id: 'cycle_repeat',
      title: 'Cycle Repeat Mode',
      description: 'Cycle repeat mode (Off → Repeat All → Repeat One)',
      category: ShortcutCategory.playback,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.keyR),
    ),
    const AppShortcutAction(
      id: 'toggle_favorite',
      title: 'Toggle Favorite / Like',
      description: 'Add or remove the current song from Favorites',
      category: ShortcutCategory.playback,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.keyF),
    ),
    const AppShortcutAction(
      id: 'set_loop_a',
      title: 'Set Loop Marker A',
      description: 'Set loop start point A at current position',
      category: ShortcutCategory.playback,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.bracketLeft, isCtrl: true),
    ),
    const AppShortcutAction(
      id: 'set_loop_b',
      title: 'Set Loop Marker B',
      description: 'Set loop end point B at current position',
      category: ShortcutCategory.playback,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.bracketRight, isCtrl: true),
    ),
    const AppShortcutAction(
      id: 'toggle_ab_loop',
      title: 'Toggle A-B Section Loop',
      description: 'Toggle A-B looping on or off',
      category: ShortcutCategory.playback,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.backslash, isCtrl: true),
    ),
    const AppShortcutAction(
      id: 'clear_ab_loop',
      title: 'Clear A-B Section Loop',
      description: 'Clear loop markers A & B and disable looping',
      category: ShortcutCategory.playback,
      defaultPrimary: AppKeyCombo(
        key: LogicalKeyboardKey.backslash,
        isCtrl: true,
        isShift: true,
      ),
    ),
    const AppShortcutAction(
      id: 'toggle_sleep_timer',
      title: 'Sleep Timer / Dialog',
      description: 'Open sleep timer dialog or stop active timer',
      category: ShortcutCategory.playback,
      defaultPrimary: AppKeyCombo(
        key: LogicalKeyboardKey.keyS,
        isCtrl: true,
        isShift: true,
      ),
    ),

    // ─── Seeking & Volume ───────────────────────────────────────────────────
    const AppShortcutAction(
      id: 'seek_forward_5',
      title: 'Seek Forward 5s',
      description: 'Fast-forward playback by 5 seconds',
      category: ShortcutCategory.seekingAndVolume,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.arrowRight),
    ),
    const AppShortcutAction(
      id: 'seek_backward_5',
      title: 'Seek Backward 5s',
      description: 'Rewind playback by 5 seconds',
      category: ShortcutCategory.seekingAndVolume,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.arrowLeft),
    ),
    const AppShortcutAction(
      id: 'seek_forward_10',
      title: 'Seek Forward 10s',
      description: 'Fast-forward playback by 10 seconds',
      category: ShortcutCategory.seekingAndVolume,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.arrowRight, isShift: true),
    ),
    const AppShortcutAction(
      id: 'seek_backward_10',
      title: 'Seek Backward 10s',
      description: 'Rewind playback by 10 seconds',
      category: ShortcutCategory.seekingAndVolume,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.arrowLeft, isShift: true),
    ),
    const AppShortcutAction(
      id: 'seek_forward_30',
      title: 'Seek Forward 30s',
      description: 'Fast-forward playback by 30 seconds',
      category: ShortcutCategory.seekingAndVolume,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.arrowRight, isCtrl: true),
    ),
    const AppShortcutAction(
      id: 'seek_backward_30',
      title: 'Seek Backward 30s',
      description: 'Rewind playback by 30 seconds',
      category: ShortcutCategory.seekingAndVolume,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.arrowLeft, isCtrl: true),
    ),
    const AppShortcutAction(
      id: 'seek_to_start',
      title: 'Jump to Start of Song',
      description: 'Restart the currently playing song from the beginning',
      category: ShortcutCategory.seekingAndVolume,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.home),
    ),
    const AppShortcutAction(
      id: 'volume_up',
      title: 'Volume Up (+5%)',
      description: 'Increase volume by 5 percent',
      category: ShortcutCategory.seekingAndVolume,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.arrowUp),
      defaultSecondary: AppKeyCombo(key: LogicalKeyboardKey.audioVolumeUp),
    ),
    const AppShortcutAction(
      id: 'volume_down',
      title: 'Volume Down (-5%)',
      description: 'Decrease volume by 5 percent',
      category: ShortcutCategory.seekingAndVolume,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.arrowDown),
      defaultSecondary: AppKeyCombo(key: LogicalKeyboardKey.audioVolumeDown),
    ),
    const AppShortcutAction(
      id: 'volume_up_large',
      title: 'Volume Up (+10%)',
      description: 'Increase volume by 10 percent',
      category: ShortcutCategory.seekingAndVolume,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.arrowUp, isShift: true),
    ),
    const AppShortcutAction(
      id: 'volume_down_large',
      title: 'Volume Down (-10%)',
      description: 'Decrease volume by 10 percent',
      category: ShortcutCategory.seekingAndVolume,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.arrowDown, isShift: true),
    ),
    const AppShortcutAction(
      id: 'toggle_mute',
      title: 'Mute / Unmute',
      description: 'Toggle audio output mute state',
      category: ShortcutCategory.seekingAndVolume,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.keyM),
      defaultSecondary: AppKeyCombo(key: LogicalKeyboardKey.audioVolumeMute),
    ),

    // ─── Navigation & Pages ─────────────────────────────────────────────────
    const AppShortcutAction(
      id: 'open_search',
      title: 'Open / Focus Search',
      description: 'Focus the search bar or open Search view',
      category: ShortcutCategory.navigation,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.slash),
      defaultSecondary: AppKeyCombo(key: LogicalKeyboardKey.keyF, isCtrl: true),
    ),
    const AppShortcutAction(
      id: 'go_home',
      title: 'Go to Home',
      description: 'Navigate to the Home screen',
      category: ShortcutCategory.navigation,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.digit1, isCtrl: true),
      defaultSecondary: AppKeyCombo(key: LogicalKeyboardKey.digit1, isAlt: true),
    ),
    const AppShortcutAction(
      id: 'go_songs',
      title: 'Go to Songs',
      description: 'Navigate to the Songs library view',
      category: ShortcutCategory.navigation,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.digit2, isCtrl: true),
      defaultSecondary: AppKeyCombo(key: LogicalKeyboardKey.digit2, isAlt: true),
    ),
    const AppShortcutAction(
      id: 'go_albums',
      title: 'Go to Albums',
      description: 'Navigate to the Albums library view',
      category: ShortcutCategory.navigation,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.digit3, isCtrl: true),
      defaultSecondary: AppKeyCombo(key: LogicalKeyboardKey.digit3, isAlt: true),
    ),
    const AppShortcutAction(
      id: 'go_artists',
      title: 'Go to Artists',
      description: 'Navigate to the Artists library view',
      category: ShortcutCategory.navigation,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.digit4, isCtrl: true),
      defaultSecondary: AppKeyCombo(key: LogicalKeyboardKey.digit4, isAlt: true),
    ),
    const AppShortcutAction(
      id: 'go_playlists',
      title: 'Go to Playlists',
      description: 'Navigate to the Playlists view',
      category: ShortcutCategory.navigation,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.digit5, isCtrl: true),
      defaultSecondary: AppKeyCombo(key: LogicalKeyboardKey.digit5, isAlt: true),
    ),
    const AppShortcutAction(
      id: 'go_genres',
      title: 'Go to Genres',
      description: 'Navigate to the Genres view',
      category: ShortcutCategory.navigation,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.digit6, isCtrl: true),
      defaultSecondary: AppKeyCombo(key: LogicalKeyboardKey.digit6, isAlt: true),
    ),
    const AppShortcutAction(
      id: 'go_settings',
      title: 'Go to Settings',
      description: 'Navigate to the Settings view',
      category: ShortcutCategory.navigation,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.comma, isCtrl: true),
    ),
    const AppShortcutAction(
      id: 'toggle_lyrics',
      title: 'Toggle Lyrics View',
      description: 'Open or close the Lyrics tab',
      category: ShortcutCategory.navigation,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.keyL),
    ),
    const AppShortcutAction(
      id: 'toggle_queue',
      title: 'Toggle Queue View',
      description: 'Open or close the Play Queue tab',
      category: ShortcutCategory.navigation,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.keyQ),
    ),

    // ─── Display & Overlays ─────────────────────────────────────────────────
    const AppShortcutAction(
      id: 'toggle_fullscreen_player',
      title: 'Toggle Expanded / Fullscreen Player',
      description: 'Expand or collapse the now playing screen',
      category: ShortcutCategory.displayAndUi,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.f11),
    ),
    const AppShortcutAction(
      id: 'toggle_mini_player',
      title: 'Toggle Mini Player Overlay',
      description: 'Switch between main window and compact floating mini-player',
      category: ShortcutCategory.displayAndUi,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.keyM, isCtrl: true),
    ),
    const AppShortcutAction(
      id: 'show_cheatsheet',
      title: 'Shortcuts Cheatsheet',
      description: 'Open keyboard shortcuts help & reference dialog',
      category: ShortcutCategory.displayAndUi,
      defaultPrimary: AppKeyCombo(key: LogicalKeyboardKey.slash, isShift: true),
    ),
  ];

  /// Find an action by its ID.
  static AppShortcutAction? findById(String id) {
    for (final action in all) {
      if (action.id == id) return action;
    }
    return null;
  }
}
