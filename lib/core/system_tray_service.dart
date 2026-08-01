import 'dart:io';

import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import 'logger_helper.dart';
import 'db_service.dart';
import '../features/library/domain/models/models.dart';

/// Manages the desktop system tray icon and the "minimize to tray" behavior.
///
/// The tray icon is always shown on desktop platforms. When the window close
/// button is pressed the behavior depends on the [AppSettings.minimizeToTray]
/// setting: either the window hides to the tray and playback keeps running, or
/// the app fully quits. The tray menu offers "Show" and "Quit".
class SystemTrayService {
  SystemTrayService._();

  static final SystemTrayService instance = SystemTrayService._();

  final SystemTray _systemTray = SystemTray();
  bool _initialized = false;

  bool get isSupported =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  Future<void> init() async {
    if (_initialized || !isSupported) return;
    _initialized = true;

    try {
      await _systemTray.initSystemTray(
        iconPath: Platform.isWindows
            ? 'assets/tray_icon.ico'
            : 'assets/launcher_logo.png',
        title: 'Looper Player',
        toolTip: 'Looper Player',
      );

      _systemTray.registerSystemTrayEventHandler((eventName) {
        if (eventName == kSystemTrayEventClick) {
          if (Platform.isWindows) {
            _showWindow();
          } else {
            _systemTray.popUpContextMenu();
          }
        } else if (eventName == kSystemTrayEventRightClick) {
          if (Platform.isWindows) {
            _systemTray.popUpContextMenu();
          } else {
            _showWindow();
          }
        }
      });

      final Menu menu = Menu();
      await menu.buildFrom([
        MenuItemLabel(
          label: 'Show Looper Player',
          onClicked: (_) => _showWindow(),
        ),
        MenuSeparator(),
        MenuItemLabel(
          label: 'Quit',
          onClicked: (_) => _quit(),
        ),
      ]);
      await _systemTray.setContextMenu(menu);

      // Prevent the native close from destroying the window so we can decide
      // in [handleCloseRequest] whether to hide to the tray or quit.
      await windowManager.setPreventClose(true);
      windowManager.addListener(_TrayWindowListener(this));
    } catch (e, s) {
      _initialized = false;
      LoggerHelper.write('Failed to initialize SystemTray', e, s);
    }
  }

  Future<void> _showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _quit() async {
    try {
      await _systemTray.destroy();
    } catch (e, s) {
      LoggerHelper.write('Failed to destroy SystemTray', e, s);
    }
    await windowManager.destroy();
  }

  /// Called from the window close listener when the close button is pressed.
  Future<void> handleCloseRequest() async {
    if (!isSupported) {
      await windowManager.destroy();
      return;
    }

    bool minimizeToTray = false;
    try {
      final settings = await DbService.isar.appSettings.get(0);
      minimizeToTray = settings?.minimizeToTray ?? false;
    } catch (e, s) {
      LoggerHelper.write('Failed to read settings on window close', e, s);
    }

    if (minimizeToTray) {
      await windowManager.hide();
    } else {
      await windowManager.destroy();
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
}
