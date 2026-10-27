import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

typedef FileActionCallback = void Function(String action, List<String> files);

class SingleInstanceService {
  static const int _ipcPort = 47892;
  static ServerSocket? _serverSocket;
  static FileActionCallback? _actionCallback;
  static final List<Map<String, dynamic>> _pendingActions = [];

  /// Parses CLI arguments into an action ('play' or 'enqueue') and a list of files.
  static Map<String, dynamic> parseArgs(List<String> args) {
    if (args.isEmpty) {
      return {'action': 'focus', 'files': <String>[]};
    }

    bool isEnqueue = false;
    final List<String> files = [];

    for (final arg in args) {
      final clean = arg.trim();
      if (clean == '--enqueue' || clean == '-e' || clean == '/enqueue') {
        isEnqueue = true;
      } else if (clean.startsWith('-') || clean.startsWith('/')) {
        // Other flags
      } else if (clean.isNotEmpty) {
        if (clean.contains('"')) {
          final regex = RegExp(r'"([^"]+)"');
          final matches = regex.allMatches(clean);
          if (matches.isNotEmpty) {
            for (final m in matches) {
              final p = m.group(1)?.trim();
              if (p != null && p.isNotEmpty) files.add(p);
            }
            continue;
          }
        }
        files.add(clean.replaceAll('"', ''));
      }
    }

    final action = isEnqueue ? 'enqueue' : (files.isNotEmpty ? 'play' : 'focus');
    return {'action': action, 'files': files};
  }

  /// Ensures only a single instance of the application runs on desktop platforms.
  ///
  /// Returns `true` if this is the PRIMARY instance that should continue launching.
  /// Returns `false` if another instance is already running and the payload was forwarded.
  static Future<bool> ensureSingleInstance(List<String> args) async {
    if (kIsWeb || (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS)) {
      return true;
    }

    final payload = parseArgs(args);

    try {
      // Attempt to connect to an existing running instance
      final socket = await Socket.connect(
        InternetAddress.loopbackIPv4,
        _ipcPort,
        timeout: const Duration(milliseconds: 800),
      );

      // Connected successfully — forward args and wait for confirmation ACK before exiting
      final message = jsonEncode(payload);
      socket.write('$message\n');
      await socket.flush();

      // Wait for primary instance to acknowledge reception
      await socket
          .cast<List<int>>()
          .transform(utf8.decoder)
          .first
          .timeout(const Duration(seconds: 2))
          .catchError((_) => '');

      await socket.close();
      return false;
    } catch (_) {
      // Connection failed: No other instance is running. Start listening as primary.
    }

    try {
      _serverSocket = await ServerSocket.bind(
        InternetAddress.loopbackIPv4,
        _ipcPort,
      );

      _serverSocket!.listen((socket) {
        socket
            .cast<List<int>>()
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen((line) async {
              if (line.trim().isEmpty) return;
              try {
                final data = jsonDecode(line) as Map<String, dynamic>;
                final action = data['action'] as String? ?? 'focus';
                final files = (data['files'] as List<dynamic>?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    <String>[];

                // Send ACK back so secondary process knows data was received
                try {
                  socket.write('ACK\n');
                  await socket.flush();
                } catch (_) {}

                _handleIncomingAction(action, files);
              } catch (_) {}
            });
      });
    } catch (_) {
      // In case another instance just bound the port during concurrent launch, try connecting
      try {
        final socket = await Socket.connect(
          InternetAddress.loopbackIPv4,
          _ipcPort,
          timeout: const Duration(milliseconds: 1000),
        );
        final message = jsonEncode(payload);
        socket.write('$message\n');
        await socket.flush();
        await socket
            .cast<List<int>>()
            .transform(utf8.decoder)
            .first
            .timeout(const Duration(seconds: 2))
            .catchError((_) => '');
        await socket.close();
        return false;
      } catch (_) {}
    }

    return true;
  }

  /// Sets the listener for incoming actions forwarded from secondary instances.
  static void setListener(FileActionCallback callback) {
    _actionCallback = callback;
    // Process any actions received before listener was registered
    if (_pendingActions.isNotEmpty) {
      for (final pending in List.from(_pendingActions)) {
        callback(
          pending['action'] as String,
          List<String>.from(pending['files'] as List),
        );
      }
      _pendingActions.clear();
    }
  }

  static Timer? _burstTimer;
  static String? _burstAction;
  static final List<String> _burstFiles = [];

  static void _handleIncomingAction(String action, List<String> files) {
    // Bring window to foreground
    try {
      windowManager.show();
      windowManager.focus();
      windowManager.restore();
    } catch (_) {}

    if (files.isEmpty) {
      if (_actionCallback != null) {
        _actionCallback!(action, files);
      } else {
        _pendingActions.add({'action': action, 'files': files});
      }
      return;
    }

    // When multiple files are selected in Windows Explorer, Explorer may launch
    // multiple secondary processes in rapid succession (one per file).
    // Aggregate files within a short burst window so they are dispatched together.
    _burstAction ??= action;
    _burstFiles.addAll(files);

    _burstTimer?.cancel();
    _burstTimer = Timer(const Duration(milliseconds: 200), () {
      final act = _burstAction ?? 'play';
      final aggregated = List<String>.from(_burstFiles);
      _burstAction = null;
      _burstFiles.clear();

      if (_actionCallback != null) {
        _actionCallback!(act, aggregated);
      } else {
        _pendingActions.add({'action': act, 'files': aggregated});
      }
    });
  }

  /// Stops IPC server on shutdown.
  static Future<void> dispose() async {
    _burstTimer?.cancel();
    await _serverSocket?.close();
    _serverSocket = null;
  }
}
