import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:looper_player/core/logger_helper.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:win32/win32.dart';

/// Discord Rich Presence (RPC) IPC Service.
/// Communicates directly with the local Discord Desktop client via named pipes
/// on Windows and Unix Domain Sockets on Linux/macOS with zero external C-dependencies.
class DiscordRpcService {
  DiscordRpcService._();
  static final DiscordRpcService instance = DiscordRpcService._();

  // Default Looper Player Discord Application ID
  static const String defaultApplicationId = '1217897258358476830';

  bool _isEnabled = false;
  bool _isConnected = false;
  int _winPipeHandle = 0;
  Socket? _unixSocket;
  String _currentApplicationId = defaultApplicationId;
  Timer? _debounceTimer;

  // Track last payload to avoid redundant updates
  String? _lastPresenceFingerprint;

  bool get isConnected => _isConnected;
  bool get isEnabled => _isEnabled;

  /// Initialize and connect if enabled.
  Future<void> initialize({bool enabled = false, String? applicationId}) async {
    _isEnabled = enabled;
    if (applicationId != null && applicationId.isNotEmpty) {
      _currentApplicationId = applicationId;
    }
    if (_isEnabled && !_isConnected) {
      await _connect();
    }
  }

  /// Toggle Discord RPC on or off dynamically.
  Future<void> setEnabled(bool enabled) async {
    if (_isEnabled == enabled) return;
    _isEnabled = enabled;
    if (_isEnabled) {
      await _connect();
    } else {
      await clearPresence();
      await _disconnect();
    }
  }

  /// Connect to the local Discord client IPC socket.
  Future<bool> _connect() async {
    if (Platform.isAndroid || Platform.isIOS) return false;
    if (_isConnected) return true;

    try {
      if (Platform.isWindows) {
        for (int i = 0; i < 10; i++) {
          final pipeName = r'\\.\pipe\discord-ipc-' + i.toString();
          final pipePtr = pipeName.toNativeUtf16();
          final handle = CreateFile(
            pipePtr,
            GENERIC_READ | GENERIC_WRITE,
            0,
            nullptr,
            OPEN_EXISTING,
            0,
            NULL,
          );
          calloc.free(pipePtr);

          if (handle != INVALID_HANDLE_VALUE && handle != 0) {
            _winPipeHandle = handle;
            _isConnected = true;
            _sendHandshake();
            LoggerHelper.write('Discord RPC connected on pipe $pipeName');
            return true;
          }
        }
      } else if (Platform.isLinux || Platform.isMacOS) {
        final xdg = Platform.environment['XDG_RUNTIME_DIR'];
        final tmp = Platform.environment['TMPDIR'] ??
            Platform.environment['TMP'] ??
            Platform.environment['TEMP'] ??
            '/tmp';
        final prefixes = [
          if (xdg != null && xdg.isNotEmpty) xdg,
          tmp,
          '/tmp',
          '/var/tmp',
        ];

        for (final dir in prefixes) {
          for (int i = 0; i < 10; i++) {
            final pipePath = '$dir/discord-ipc-$i';
            try {
              final socket = await Socket.connect(
                InternetAddress(pipePath, type: InternetAddressType.unix),
                0,
                timeout: const Duration(milliseconds: 300),
              );
              _unixSocket = socket;
              _isConnected = true;
              _sendHandshake();
              LoggerHelper.write('Discord RPC connected on socket $pipePath');
              return true;
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      LoggerHelper.write('Failed to connect to Discord RPC: $e');
    }

    _isConnected = false;
    return false;
  }

  void _sendHandshake() {
    final payload = jsonEncode({
      'v': 1,
      'client_id': _currentApplicationId,
    });
    _sendPacket(0, payload); // Opcode 0 = Handshake
  }

  void _sendPacket(int opcode, String payload) {
    if (!_isConnected) return;
    try {
      final payloadBytes = utf8.encode(payload);
      final header = ByteData(8);
      header.setUint32(0, opcode, Endian.little);
      header.setUint32(4, payloadBytes.length, Endian.little);

      final packet = Uint8List(8 + payloadBytes.length);
      packet.setRange(0, 8, header.buffer.asUint8List());
      packet.setRange(8, packet.length, payloadBytes);

      if (Platform.isWindows && _winPipeHandle != 0) {
        using((arena) {
          final buffer = arena<Uint8>(packet.length);
          for (int i = 0; i < packet.length; i++) {
            buffer[i] = packet[i];
          }
          final written = arena<DWORD>();
          final res = WriteFile(
            _winPipeHandle,
            buffer,
            packet.length,
            written,
            nullptr,
          );
          if (res == 0) {
            // Pipe disconnected or closed by Discord
            _disconnect();
          }
        });
      } else if (_unixSocket != null) {
        _unixSocket!.add(packet);
        _unixSocket!.flush();
      }
    } catch (e) {
      LoggerHelper.write('Error writing to Discord RPC: $e');
      _disconnect();
    }
  }

  /// Broadcast presence for the current song & playback state.
  void updatePresence({
    required Song? song,
    required Duration position,
    required Duration duration,
    required bool isPlaying,
  }) {
    if (!_isEnabled) return;

    // Debounce rapid position / seek updates (300ms)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!_isEnabled) return;
      if (!_isConnected) {
        final ok = await _connect();
        if (!ok) return;
      }

      if (song == null) {
        clearPresence();
        return;
      }

      final title = song.title.trim().isNotEmpty ? song.title.trim() : 'Unknown Track';
      final artist = song.artist?.trim().isNotEmpty == true ? song.artist!.trim() : 'Unknown Artist';
      final album = song.album?.trim().isNotEmpty == true ? song.album!.trim() : null;

      final stateText = album != null && album.isNotEmpty
          ? 'by $artist • $album'
          : 'by $artist';

      final now = DateTime.now().millisecondsSinceEpoch;
      final startTimestamp = isPlaying
          ? (now - position.inMilliseconds)
          : null;
      final endTimestamp = (isPlaying && duration > Duration.zero)
          ? (startTimestamp! + duration.inMilliseconds)
          : null;

      // Online image or fallback Discord asset key
      final isOnlineStream = song.isOnlineStream && song.artPath != null && song.artPath!.startsWith('http');
      final largeImageKey = isOnlineStream ? song.artPath! : 'looper_logo';

      final fingerprint = '$title|$stateText|$isPlaying|${position.inSeconds}|${duration.inSeconds}';
      if (_lastPresenceFingerprint == fingerprint) return;
      _lastPresenceFingerprint = fingerprint;

      final activity = <String, dynamic>{
        'details': title,
        'state': stateText,
        'type': 2, // Listening activity type
        'assets': {
          'large_image': largeImageKey,
          'large_text': album ?? 'Looper Player',
          'small_image': isPlaying ? 'play' : 'pause',
          'small_text': isPlaying ? 'Playing' : 'Paused',
        },
      };

      if (startTimestamp != null) {
        activity['timestamps'] = {
          'start': (startTimestamp / 1000).round(),
          if (endTimestamp != null) 'end': (endTimestamp / 1000).round(),
        };
      }

      final payload = jsonEncode({
        'cmd': 'SET_ACTIVITY',
        'args': {
          'pid': pid,
          'activity': activity,
        },
        'nonce': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      _sendPacket(1, payload); // Opcode 1 = Frame
    });
  }

  /// Clears the active Discord Rich Presence.
  Future<void> clearPresence() async {
    _debounceTimer?.cancel();
    _lastPresenceFingerprint = null;
    if (!_isConnected) return;

    final payload = jsonEncode({
      'cmd': 'SET_ACTIVITY',
      'args': {
        'pid': pid,
        'activity': null,
      },
      'nonce': DateTime.now().millisecondsSinceEpoch.toString(),
    });

    _sendPacket(1, payload);
  }

  Future<void> _disconnect() async {
    _isConnected = false;
    _lastPresenceFingerprint = null;
    if (Platform.isWindows && _winPipeHandle != 0) {
      CloseHandle(_winPipeHandle);
      _winPipeHandle = 0;
    } else if (_unixSocket != null) {
      try {
        await _unixSocket!.close();
      } catch (_) {}
      _unixSocket = null;
    }
  }

  /// Clean shutdown of RPC service.
  Future<void> dispose() async {
    _debounceTimer?.cancel();
    await clearPresence();
    await _disconnect();
  }
}
