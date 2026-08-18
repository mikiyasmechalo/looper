import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

void main() async {
  print('==============================================');
  print('  🎧 Discord IPC Mock Server for Looper 🎧   ');
  print('==============================================');
  print('Creating Windows Named Pipe: \\\\.\\pipe\\discord-ipc-0 ...');

  final pipeName = r'\\.\pipe\discord-ipc-0';
  final pipePtr = pipeName.toNativeUtf16();

  final pipeHandle = CreateNamedPipe(
    pipePtr,
    PIPE_ACCESS_DUPLEX,
    PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT,
    1,
    4096,
    4096,
    0,
    nullptr,
  );
  calloc.free(pipePtr);

  if (pipeHandle == INVALID_HANDLE_VALUE || pipeHandle == 0) {
    print('❌ Failed to create named pipe (Error code: ${GetLastError()}).');
    print('Note: If Discord Desktop is currently running, close it first.');
    return;
  }

  print('✅ Named Pipe created successfully!');
  print('⏳ Waiting for Looper to connect (Enable Discord RPC in Looper Settings & play a track)...');

  final connected = ConnectNamedPipe(pipeHandle, nullptr);
  if (connected == 0) {
    final err = GetLastError();
    if (err != ERROR_PIPE_CONNECTED) {
      print('❌ ConnectNamedPipe failed with error: $err');
      CloseHandle(pipeHandle);
      return;
    }
  }

  print('🎉 Looper connected to Discord IPC pipe!');
  print('----------------------------------------------');

  using((arena) {
    final buffer = arena<Uint8>(8192);
    final bytesRead = arena<DWORD>();

    while (true) {
      final success = ReadFile(
        pipeHandle,
        buffer,
        8192,
        bytesRead,
        nullptr,
      );

      if (success == 0 || bytesRead.value == 0) {
        print('🔌 Looper disconnected from pipe.');
        break;
      }

      final totalBytes = bytesRead.value;
      if (totalBytes < 8) continue;

      final data = Uint8List(totalBytes);
      for (int i = 0; i < totalBytes; i++) {
        data[i] = buffer[i];
      }

      final byteData = ByteData.sublistView(data);
      final opcode = byteData.getUint32(0, Endian.little);
      final length = byteData.getUint32(4, Endian.little);

      final payloadBytes = data.sublist(8, 8 + length);
      final payloadStr = utf8.decode(payloadBytes);

      if (opcode == 0) {
        print('🤝 [HANDSHAKE] Received client authentication:');
        print('   $payloadStr');
        print('----------------------------------------------');
      } else if (opcode == 1) {
        print('🎵 [ACTIVITY UPDATE] Received Rich Presence Frame:');
        try {
          final parsed = jsonDecode(payloadStr);
          final act = parsed['args']?['activity'];
          if (act != null) {
            print('   ▶ Details (Title): ${act['details']}');
            print('   ▶ State (Artist):  ${act['state']}');
            print('   ▶ Status:          ${act['assets']?['small_text']}');
            print('   ▶ Assets:          Large: ${act['assets']?['large_image']}, Small: ${act['assets']?['small_image']}');
            if (act['timestamps'] != null) {
              print('   ▶ Timestamps:      Start: ${act['timestamps']['start']}, End: ${act['timestamps']['end']}');
            }
          } else {
            print('   ⏹ Presence cleared (activity = null)');
          }
        } catch (_) {
          print('   $payloadStr');
        }
        print('----------------------------------------------');
      }
    }
  });

  CloseHandle(pipeHandle);
  print('Server terminated.');
}
