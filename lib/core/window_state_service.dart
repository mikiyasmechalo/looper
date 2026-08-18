import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:looper_player/core/providers.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/core/logger_helper.dart';

class WindowState {
  final bool isMaximized;
  final double width;
  final double height;
  final double? x;
  final double? y;
  final String playerType; // 'normal', 'full', 'miniPlayer', 'cornerWidget'

  const WindowState({
    this.isMaximized = false,
    this.width = 1300.0,
    this.height = 700.0,
    this.x,
    this.y,
    this.playerType = 'normal',
  });

  WindowState copyWith({
    bool? isMaximized,
    double? width,
    double? height,
    double? x,
    double? y,
    String? playerType,
  }) {
    return WindowState(
      isMaximized: isMaximized ?? this.isMaximized,
      width: width ?? this.width,
      height: height ?? this.height,
      x: x ?? this.x,
      y: y ?? this.y,
      playerType: playerType ?? this.playerType,
    );
  }

  Map<String, dynamic> toJson() => {
        'isMaximized': isMaximized,
        'width': width,
        'height': height,
        'x': x,
        'y': y,
        'playerType': playerType,
      };

  factory WindowState.fromJson(Map<String, dynamic> json) {
    return WindowState(
      isMaximized: json['isMaximized'] as bool? ?? false,
      width: (json['width'] as num?)?.toDouble() ?? 1300.0,
      height: (json['height'] as num?)?.toDouble() ?? 700.0,
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
      playerType: json['playerType'] as String? ?? 'normal',
    );
  }
}

final initialWindowStateProvider = Provider<WindowState>((ref) => const WindowState());

class WindowStateService extends WindowListener {
  static final WindowStateService instance = WindowStateService._();
  WindowStateService._();

  WindowState _currentState = const WindowState();
  WindowState get currentState => _currentState;

  Timer? _saveDebounce;
  bool _isAttached = false;

  static Future<File> get _file async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/window_state.json');
  }

  static Future<WindowState> load() async {
    try {
      final file = await _file;
      if (await file.exists()) {
        final content = await file.readAsString();
        final state = WindowState.fromJson(jsonDecode(content));
        instance._currentState = state;
        return state;
      }
    } catch (e, s) {
      LoggerHelper.write('WindowStateService: Failed to load window_state.json', e, s);
    }
    return const WindowState();
  }

  static Future<Map<String, dynamic>> loadMiniSettings() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/mini_player_settings.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (_) {}
    return const {};
  }

  Future<void> save(WindowState state) async {
    _currentState = state;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 300), () async {
      await saveSync(_currentState);
    });
  }

  Future<void> saveSync(WindowState state) async {
    _currentState = state;
    _saveDebounce?.cancel();
    try {
      final file = await _file;
      await file.writeAsString(jsonEncode(_currentState.toJson()));
    } catch (e, s) {
      LoggerHelper.write('WindowStateService: Failed to save window_state.json', e, s);
    }
  }

  void attach(WidgetRef ref) {
    if (_isAttached) return;
    _isAttached = true;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.addListener(this);

      // Inspect initial state
      final currentMini = ref.read(miniPlayerModeProvider);
      if (currentMini == MiniPlayerMode.miniPlayer) {
        _currentState = _currentState.copyWith(playerType: 'miniPlayer');
      } else if (currentMini == MiniPlayerMode.cornerWidget) {
        _currentState = _currentState.copyWith(playerType: 'cornerWidget');
      } else {
        final isExpanded = ref.read(appNavigationProvider).isPlayerExpanded;
        _currentState = _currentState.copyWith(playerType: isExpanded ? 'full' : 'normal');
      }
      saveSync(_currentState);

      // Listen to mini-player mode changes
      ref.listen<MiniPlayerMode>(miniPlayerModeProvider, (previous, next) {
        if (next == MiniPlayerMode.miniPlayer) {
          _updatePlayerType('miniPlayer');
        } else if (next == MiniPlayerMode.cornerWidget) {
          _updatePlayerType('cornerWidget');
        } else {
          final isExpanded = ref.read(appNavigationProvider).isPlayerExpanded;
          _updatePlayerType(isExpanded ? 'full' : 'normal');
        }
      });

      // Listen to full player expansion changes
      ref.listen<bool>(
        appNavigationProvider.select((s) => s.isPlayerExpanded),
        (previous, isExpanded) {
          final miniMode = ref.read(miniPlayerModeProvider);
          if (miniMode == MiniPlayerMode.none) {
            _updatePlayerType(isExpanded ? 'full' : 'normal');
          }
        },
      );
    }
  }

  void _updatePlayerType(String type) {
    if (_currentState.playerType == type) return;
    saveSync(_currentState.copyWith(playerType: type));
  }

  @override
  void onWindowMaximize() {
    if (_currentState.playerType == 'miniPlayer' ||
        _currentState.playerType == 'cornerWidget') {
      return;
    }
    save(_currentState.copyWith(isMaximized: true));
  }

  @override
  void onWindowUnmaximize() {
    if (_currentState.playerType == 'miniPlayer' ||
        _currentState.playerType == 'cornerWidget') {
      return;
    }
    save(_currentState.copyWith(isMaximized: false));
  }

  @override
  void onWindowResized() async {
    if (_currentState.playerType == 'miniPlayer' ||
        _currentState.playerType == 'cornerWidget') {
      return;
    }
    try {
      final isMax = await windowManager.isMaximized();
      if (!isMax) {
        final size = await windowManager.getSize();
        if (size.width >= 500 && size.height >= 400) {
          save(_currentState.copyWith(
            width: size.width,
            height: size.height,
            isMaximized: false,
          ));
        }
      }
    } catch (_) {}
  }

  @override
  void onWindowMoved() async {
    if (_currentState.playerType == 'miniPlayer' ||
        _currentState.playerType == 'cornerWidget') {
      return;
    }
    try {
      final isMax = await windowManager.isMaximized();
      if (!isMax) {
        final pos = await windowManager.getPosition();
        if (pos.dx > -500 && pos.dy > -500) {
          save(_currentState.copyWith(
            x: pos.dx,
            y: pos.dy,
            isMaximized: false,
          ));
        }
      }
    } catch (_) {}
  }
}
