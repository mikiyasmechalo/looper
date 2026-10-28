import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import 'logger_helper.dart';
import 'db_service.dart';
import 'window_state_service.dart';
import '../features/library/domain/models/models.dart';

/// Manages the desktop system tray icon and the "minimize to tray" behavior.
class SystemTrayService {
  SystemTrayService._();

  static final SystemTrayService instance = SystemTrayService._();

  final SystemTray _systemTray = SystemTray();
  bool _initialized = false;
  bool _trayActive = false;
  bool _quitInProgress = false;
  bool _isMinimizedToTray = false;

  bool get isMinimizedToTray => _isMinimizedToTray;

  bool get isSupported =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  Future<void> init() async {
    if (_initialized || !isSupported) return;
    _initialized = true;

    try {
      await windowManager.setPreventClose(true);
      windowManager.addListener(_TrayWindowListener(this));

      final settings = await DbService.isar.appSettings.get(0);
      final showOnlyWhenMinimized = settings?.showTrayOnlyWhenMinimized ?? true;
      final isVisible = await windowManager.isVisible();

      if (!showOnlyWhenMinimized || !isVisible) {
        await _createTray();
      }
    } catch (e, s) {
      _initialized = false;
      LoggerHelper.write('Failed to initialize SystemTray service', e, s);
    }
  }

  Future<void> _createTray() async {
    if (_trayActive || !isSupported) return;

    try {
      await _systemTray.initSystemTray(
        iconPath: Platform.isWindows
            ? 'assets/tray_icon.ico'
            : 'assets/launcher_logo.png',
        title: 'Looper',
        toolTip: 'Looper',
      );

      _systemTray.registerSystemTrayEventHandler((eventName) {
        if (eventName == kSystemTrayEventClick) {
          if (Platform.isWindows) {
            restoreFromTray();
          } else {
            _systemTray.popUpContextMenu();
          }
        } else if (eventName == kSystemTrayEventRightClick) {
          if (Platform.isWindows) {
            _systemTray.popUpContextMenu();
          } else {
            restoreFromTray();
          }
        }
      });

      final Menu menu = Menu();
      await menu.buildFrom([
        MenuItemLabel(
          label: 'Show Looper',
          onClicked: (_) => restoreFromTray(),
        ),
        MenuSeparator(),
        MenuItemLabel(
          label: 'Quit',
          onClicked: (_) => _quit(),
        ),
      ]);
      await _systemTray.setContextMenu(menu);
      _trayActive = true;
    } catch (e, s) {
      _trayActive = false;
      LoggerHelper.write('Failed to create SystemTray icon', e, s);
    }
  }

  Future<void> _destroyTray() async {
    if (!_trayActive) return;
    try {
      await _systemTray.destroy();
      _trayActive = false;
    } catch (e, s) {
      LoggerHelper.write('Failed to destroy SystemTray', e, s);
    }
  }

  Future<void> minimizeToTray() async {
    if (!isSupported) return;
    try {
      _isMinimizedToTray = true;
      WindowStateService.instance.setMinimized(true);
      await _createTray();
      await windowManager.hide();
    } catch (e, s) {
      LoggerHelper.write('Failed to minimize to tray', e, s);
    }
  }

  Future<void> restoreFromTray() async {
    if (!isSupported) return;
    try {
      _isMinimizedToTray = false;
      WindowStateService.instance.setMinimized(false);
      await windowManager.show();
      await windowManager.focus();
      final settings = await DbService.isar.appSettings.get(0);
      final showOnlyWhenMinimized = settings?.showTrayOnlyWhenMinimized ?? true;
      if (showOnlyWhenMinimized) {
        await _destroyTray();
      }
    } catch (e, s) {
      LoggerHelper.write('Failed to restore from tray', e, s);
    }
  }

  Future<void> syncTrayVisibility({bool? isMinimizedOrHidden}) async {
    if (!isSupported) return;
    try {
      final settings = await DbService.isar.appSettings.get(0);
      if (_isMinimizedToTray) {
        await _createTray();
        return;
      }

      final showOnlyWhenMinimized = settings?.showTrayOnlyWhenMinimized ?? true;

      if (!showOnlyWhenMinimized) {
        await _createTray();
        return;
      }

      // When showOnlyWhenMinimized is true, we ONLY show the tray icon if the
      // window is actually closed to tray or minimized to tray (not visible).
      // If the window is open / visible on desktop, NEVER show the tray icon.
      final bool isHidden;
      if (isMinimizedOrHidden != null) {
        isHidden = isMinimizedOrHidden;
      } else {
        final isVis = await windowManager.isVisible();
        isHidden = !isVis;
      }

      if (isHidden) {
        await _createTray();
      } else {
        await _destroyTray();
      }
    } catch (e, s) {
      LoggerHelper.write('Error syncing tray visibility', e, s);
    }
  }

  Future<void> _quit() async {
    if (_quitInProgress) return;
    _quitInProgress = true;
    _isMinimizedToTray = false;

    // Save active mini player position before quitting
    final pType = WindowStateService.instance.currentState.playerType;
    if (pType == 'miniPlayer' || pType == 'cornerWidget') {
      try {
        final pos = await windowManager.getPosition();
        if (pos.dx > -20000 && pos.dy > -20000 && pos.dx < 40000 && pos.dy < 40000) {
          final miniMap = await WindowStateService.loadMiniSettings();
          final updated = Map<String, dynamic>.from(miniMap);
          if (pType == 'miniPlayer') {
            updated['miniPlayerX'] = pos.dx;
            updated['miniPlayerY'] = pos.dy;
          } else {
            updated['cornerX'] = pos.dx;
            updated['cornerY'] = pos.dy;
          }
          final dir = await getApplicationSupportDirectory();
          final file = File('\${dir.path}/mini_player_settings.json');
          await file.writeAsString(jsonEncode(updated));
        }
      } catch (_) {}
    }
    try {
      await _destroyTray();
    } catch (e, s) {
      LoggerHelper.write('Failed to destroy SystemTray on quit', e, s);
    }
    try {
      await windowManager.setPreventClose(false);
      await windowManager.close();
    } catch (e, s) {
      LoggerHelper.write('Failed to close window on quit', e, s);
    }
  }

  /// Called from the window close listener when the close button is pressed.
  Future<void> handleCloseRequest() async {
    if (!isSupported) {
      await _quit();
      return;
    }

    bool closeToTraySetting = false;
    try {
      final settings = await DbService.isar.appSettings.get(0);
      closeToTraySetting = settings?.closeToTray ?? false;
    } catch (e, s) {
      LoggerHelper.write('Failed to read settings on window close', e, s);
    }

    if (closeToTraySetting) {
      await minimizeToTray();
    } else {
      await _quit();
    }
  }
}

class _TrayWindowListener extends WindowListener {
  _TrayWindowListener(this._service);

  final SystemTrayService _service;

  @override
  Future<void> onWindowClose() async {
    await _service.handleCloseRequest();
  }

  @override
  Future<void> onWindowMinimize() async {
    bool minimizeToTraySetting = false;
    try {
      final settings = await DbService.isar.appSettings.get(0);
      minimizeToTraySetting = settings?.minimizeToTray ?? false;
    } catch (_) {}

    if (minimizeToTraySetting) {
      await _service.minimizeToTray();
    } else {
      // Normal minimize to taskbar: window is on taskbar, NOT minimized to tray.
      // So if showOnlyWhenMinimized is enabled, destroy/do not show the tray icon.
      await _service.syncTrayVisibility();
    }
  }

  @override
  void onWindowRestore() {
    _service._isMinimizedToTray = false;
    _service.syncTrayVisibility(isMinimizedOrHidden: false);
  }

  @override
  Future<void> onWindowFocus() async {
    if (_service._isMinimizedToTray) return;
    final isVis = await windowManager.isVisible();
    if (!isVis) return;
    _service.syncTrayVisibility(isMinimizedOrHidden: false);
  }

  @override
  void onWindowMaximize() {
    _service.syncTrayVisibility(isMinimizedOrHidden: false);
  }

  @override
  void onWindowUnmaximize() {
    _service.syncTrayVisibility(isMinimizedOrHidden: false);
  }
}
