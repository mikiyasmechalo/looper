import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:looper_player/core/providers.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/core/window_state_service.dart';

// ─── Simple JSON persistence for mini player settings ──────────────────────

class MiniPlayerSettingsState {
  final double padding;
  final double cornerX;
  final double cornerY;
  final double miniPlayerX;
  final double miniPlayerY;
  final bool lyricsEnabled;
  final bool expressiveSlider;
  final bool visualizerEnabled;
  final bool alwaysOnTop;

  const MiniPlayerSettingsState({
    this.padding = 12.0,
    this.cornerX = -1,
    this.cornerY = -1,
    this.miniPlayerX = -1,
    this.miniPlayerY = -1,
    this.lyricsEnabled = false,
    this.expressiveSlider = false,
    this.visualizerEnabled = false,
    this.alwaysOnTop = true,
  });

  MiniPlayerSettingsState copyWith({
    double? padding,
    double? cornerX,
    double? cornerY,
    double? miniPlayerX,
    double? miniPlayerY,
    bool? lyricsEnabled,
    bool? expressiveSlider,
    bool? visualizerEnabled,
    bool? alwaysOnTop,
  }) {
    return MiniPlayerSettingsState(
      padding: padding ?? this.padding,
      cornerX: cornerX ?? this.cornerX,
      cornerY: cornerY ?? this.cornerY,
      miniPlayerX: miniPlayerX ?? this.miniPlayerX,
      miniPlayerY: miniPlayerY ?? this.miniPlayerY,
      lyricsEnabled: lyricsEnabled ?? this.lyricsEnabled,
      expressiveSlider: expressiveSlider ?? this.expressiveSlider,
      visualizerEnabled: visualizerEnabled ?? this.visualizerEnabled,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
    );
  }

  Map<String, dynamic> toJson() => {
    'padding': padding,
    'cornerX': cornerX,
    'cornerY': cornerY,
    'miniPlayerX': miniPlayerX,
    'miniPlayerY': miniPlayerY,
    'lyricsEnabled': lyricsEnabled,
    'expressiveSlider': expressiveSlider,
    'visualizerEnabled': visualizerEnabled,
    'alwaysOnTop': alwaysOnTop,
  };

  factory MiniPlayerSettingsState.fromJson(Map<String, dynamic> json) {
    return MiniPlayerSettingsState(
      padding: (json['padding'] as num?)?.toDouble() ?? 12.0,
      cornerX: (json['cornerX'] as num?)?.toDouble() ?? (json['x'] as num?)?.toDouble() ?? -1,
      cornerY: (json['cornerY'] as num?)?.toDouble() ?? (json['y'] as num?)?.toDouble() ?? -1,
      miniPlayerX: (json['miniPlayerX'] as num?)?.toDouble() ?? (json['x'] as num?)?.toDouble() ?? -1,
      miniPlayerY: (json['miniPlayerY'] as num?)?.toDouble() ?? (json['y'] as num?)?.toDouble() ?? -1,
      lyricsEnabled: json['lyricsEnabled'] as bool? ?? false,
      expressiveSlider: json['expressiveSlider'] as bool? ?? false,
      visualizerEnabled: json['visualizerEnabled'] as bool? ?? false,
      alwaysOnTop: json['alwaysOnTop'] as bool? ?? true,
    );
  }
}

class MiniPlayerSettingsNotifier extends StateNotifier<MiniPlayerSettingsState> {
  MiniPlayerSettingsNotifier() : super(const MiniPlayerSettingsState()) {
    _load();
  }

  Future<File> get _file async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/mini_player_settings.json');
  }

  Future<void> _load() async {
    try {
      final file = await _file;
      if (await file.exists()) {
        final content = await file.readAsString();
        state = MiniPlayerSettingsState.fromJson(jsonDecode(content));
      }
    } catch (_) {}
  }

  Future<void> _save(MiniPlayerSettingsState newState) async {
    state = newState;
    try {
      final file = await _file;
      await file.writeAsString(jsonEncode(newState.toJson()));
    } catch (_) {}
  }

  void setPadding(double val) => _save(state.copyWith(padding: val));
  void setCornerPosition(double x, double y) => _save(state.copyWith(cornerX: x, cornerY: y));
  void setMiniPlayerPosition(double x, double y) => _save(state.copyWith(miniPlayerX: x, miniPlayerY: y));
  void setLyrics(bool val) => _save(state.copyWith(lyricsEnabled: val));
  void setExpressiveSlider(bool val) => _save(state.copyWith(expressiveSlider: val));
  void setVisualizer(bool val) => _save(state.copyWith(visualizerEnabled: val));
  void setAlwaysOnTop(bool val) => _save(state.copyWith(alwaysOnTop: val));
}

final miniPlayerSettingsProvider = StateNotifierProvider<MiniPlayerSettingsNotifier, MiniPlayerSettingsState>((ref) {
  return MiniPlayerSettingsNotifier();
});

// ─── Overlay Service ───────────────────────────────────────────────────────

final miniPlayerOverlayServiceProvider = Provider<MiniPlayerOverlayService>(
  (ref) => MiniPlayerOverlayService(ref),
);

/// Manages OS-window transitions in and out of mini-player modes.
class MiniPlayerOverlayService {
  final Ref ref;
  Rect? _previousBounds;
  bool _wasMaximized = false;
  bool _wasFullScreen = false;
  bool isTransitioning = false;

  MiniPlayerOverlayService(this.ref);

  static const Size _miniPlayerSize = Size(300, 420);
  static const Size _cornerWidgetSize = Size(330, 110);

  Future<void> enterMiniPlayerMode() async {
    await _enterMode(MiniPlayerMode.miniPlayer, _miniPlayerSize);
  }

  Future<void> enterCornerWidgetMode() async {
    await _enterMode(MiniPlayerMode.cornerWidget, _cornerWidgetSize);
  }

  Future<void> exit() async {
    if (isTransitioning) return;
    isTransitioning = true;

    try {
      // 1. Save current position if in valid windowed mini mode
      final isMax = await windowManager.isMaximized();
      final isFs = await windowManager.isFullScreen();
      if (!isMax && !isFs) {
        final pos = await windowManager.getPosition();
        if (pos.dx > 10 && pos.dy > 10) {
          final currentMode = ref.read(miniPlayerModeProvider);
          if (currentMode == MiniPlayerMode.miniPlayer) {
            ref.read(miniPlayerSettingsProvider.notifier).setMiniPlayerPosition(pos.dx, pos.dy);
          } else if (currentMode == MiniPlayerMode.cornerWidget) {
            ref.read(miniPlayerSettingsProvider.notifier).setCornerPosition(pos.dx, pos.dy);
          }
        }
      }

      // 2. Restore window styling
      await windowManager.setAlwaysOnTop(false);
      await windowManager.setMaximizable(true);
      await windowManager.setHasShadow(true);
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

      // 3. Expand the window FIRST to full size
      if (_wasMaximized) {
        await windowManager.maximize();
      } else if (_wasFullScreen) {
        await windowManager.setFullScreen(true);
      } else if (_previousBounds != null) {
        await windowManager.setBounds(_previousBounds);
      } else {
        await windowManager.setSize(const Size(1300, 700));
        await windowManager.center();
      }

      // 4. Give the OS window manager a moment to expand the window frame
      // before switching UI back to HomeScreen so HomeScreen never renders inside 300x420
      await Future.delayed(const Duration(milliseconds: 100));

      // 5. Switch UI back to full player (now that the window has full dimensions)
      ref.read(miniPlayerModeProvider.notifier).state = MiniPlayerMode.none;
      final isExp = ref.read(appNavigationProvider).isPlayerExpanded;
      WindowStateService.instance.saveSync(
        WindowStateService.instance.currentState.copyWith(playerType: isExp ? 'full' : 'normal'),
      );

      // 6. Restore minimum size once the window is back to full size
      await windowManager.setMinimumSize(const Size(800, 800));

      _wasMaximized = false;
      _wasFullScreen = false;
      _previousBounds = null;
    } finally {
      await Future.delayed(const Duration(milliseconds: 200));
      isTransitioning = false;
    }
  }

  Future<void> resizeMiniPlayer(double height) async {
    await windowManager.setSize(Size(_miniPlayerSize.width, height));
  }

  Future<void> resizeCornerWidget(Size size) async {
    await windowManager.setSize(size);
  }

  Future<void> _enterMode(MiniPlayerMode mode, Size size) async {
    if (isTransitioning) return;
    isTransitioning = true;

    try {
      _wasFullScreen = await windowManager.isFullScreen();
      _wasMaximized = await windowManager.isMaximized();
      if (!_wasMaximized && !_wasFullScreen) {
        _previousBounds = await windowManager.getBounds();
      }

      if (_wasFullScreen) {
        await windowManager.setFullScreen(false);
      }
      if (_wasMaximized) {
        await windowManager.unmaximize();
      }

      // 1. Switch UI immediately so full layout never tries to render inside 300x420
      ref.read(miniPlayerModeProvider.notifier).state = mode;
      final pType = mode == MiniPlayerMode.miniPlayer ? 'miniPlayer' : 'cornerWidget';
      WindowStateService.instance.saveSync(
        WindowStateService.instance.currentState.copyWith(playerType: pType),
      );

      // 2. Prepare frameless window styling
      await windowManager.setAlwaysOnTop(false);
      await windowManager.setMinimumSize(const Size(0, 0));
      await windowManager.setAsFrameless();
      await windowManager.setMaximizable(false);
      await windowManager.setHasShadow(false);

      // 3. Set mini player size and restore saved location
      await windowManager.setSize(size);

      final settings = ref.read(miniPlayerSettingsProvider);
      final savedX = mode == MiniPlayerMode.miniPlayer ? settings.miniPlayerX : settings.cornerX;
      final savedY = mode == MiniPlayerMode.miniPlayer ? settings.miniPlayerY : settings.cornerY;

      if (savedX > 10 && savedY > 10) {
        await windowManager.setPosition(Offset(savedX, savedY));
      } else {
        await windowManager.setAlignment(Alignment.bottomRight);
        await Future.delayed(const Duration(milliseconds: 50));
        final pos = await windowManager.getPosition();
        final padding = settings.padding;
        final finalX = pos.dx - padding;
        final finalY = pos.dy - padding;
        await windowManager.setPosition(Offset(finalX, finalY));
        if (mode == MiniPlayerMode.miniPlayer) {
          ref.read(miniPlayerSettingsProvider.notifier).setMiniPlayerPosition(finalX, finalY);
        } else {
          ref.read(miniPlayerSettingsProvider.notifier).setCornerPosition(finalX, finalY);
        }
      }

      await windowManager.setAlwaysOnTop(settings.alwaysOnTop);
    } finally {
      await Future.delayed(const Duration(milliseconds: 250));
      isTransitioning = false;
    }
  }
}
