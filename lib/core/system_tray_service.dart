import 'dart:io';

import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import 'logger_helper.dart';
import 'db_service.dart';
import '../features/library/domain/models/models.dart';

/// Manages the desktop system tray icon and the "minimize to tray" behavior.
class SystemTrayService {
  SystemTrayService._();

  static final SystemTrayService instance = SystemTrayService._();

  final SystemTray _systemTray = SystemTray();
  bool _initialized = false;
  bool _trayActive = false;
  bool _quitInProgress = false;

  bool get isSupported =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  Future<void> init() async {
    if (_initialized || !isSupported) return;
    _initialized = true;

    try {
      await windowManager.setPreventClose(true);
      windowManager.addListener(_TrayWindowListener(this));

      // Always initialize tray first so Windows hooks are active
      await _createTray();

      final settings = await DbService.isar.appSettings.get(0);
      final showOnlyWhenMinimized = settings?.showTrayOnlyWhenMinimized ?? true;

      final isMinimized = await windowManager.isMinimized();
      if (showOnlyWhenMinimized && !isMinimized) {
        await _destroyTray();
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
      await _createTray();
      await windowManager.hide();
    } catch (e, s) {
      LoggerHelper.write('Failed to minimize to tray', e, s);
    }
  }

  Future<void> restoreFromTray() async {
    if (!isSupported) return;
    try {
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
      final showOnlyWhenMinimized = settings?.showTrayOnlyWhenMinimized ?? true;

      if (!showOnlyWhenMinimized) {
        await _createTray();
        return;
      }

      final isHidden = isMinimizedOrHidden ?? await windowManager.isMinimized();
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

    bool minimizeToTraySetting = false;
    try {
      final settings = await DbService.isar.appSettings.get(0);
      minimizeToTraySetting = settings?.minimizeToTray ?? false;
    } catch (e, s) {
      LoggerHelper.write('Failed to read settings on window close', e, s);
    }

    if (minimizeToTraySetting) {
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
  void onWindowMinimize() {
    _service.syncTrayVisibility(isMinimizedOrHidden: true);
  }

  @override
  void onWindowRestore() {
    _service.syncTrayVisibility(isMinimizedOrHidden: false);
  }
}
