import 'dart:io';
import 'package:flutter/foundation.dart';
import 'logger_helper.dart';

class WindowsFileAssociationService {
  static const List<String> supportedExtensions = [
    '.mp3',
    '.flac',
    '.wav',
    '.m4a',
    '.ogg',
    '.opus',
    '.aac',
    '.alac',
    '.wma',
    '.aiff',
    '.ape',
  ];

  static const String progId = 'Looper.AudioFile';

  /// Registers Windows file associations, "Open With", and context menu entries.
  /// Runs completely under `HKCU` (no admin privileges required).
  static Future<bool> register() async {
    if (!Platform.isWindows || kIsWeb) return false;

    try {
      final exePath = Platform.resolvedExecutable;
      if (exePath.isEmpty || !exePath.endsWith('.exe')) {
        return false;
      }

      LoggerHelper.write('WindowsFileAssociationService: Registering for $exePath');

      // 1. ProgID definition
      await _runReg([
        'add',
        r'HKCU\Software\Classes\Looper.AudioFile',
        '/ve',
        '/t',
        'REG_SZ',
        '/d',
        'Looper Audio File',
        '/f',
      ]);
      await _runReg([
        'add',
        r'HKCU\Software\Classes\Looper.AudioFile\DefaultIcon',
        '/ve',
        '/t',
        'REG_SZ',
        '/d',
        '"$exePath",0',
        '/f',
      ]);
      // Set default verb of ProgID to Looper.Play so Windows Explorer matches the verb key
      // used in SystemFileAssociations, preventing duplicate "Play in Looper" context menu entries.
      await _runReg([
        'add',
        r'HKCU\Software\Classes\Looper.AudioFile\shell',
        '/ve',
        '/t',
        'REG_SZ',
        '/d',
        'Looper.Play',
        '/f',
      ]);
      await _runReg([
        'add',
        r'HKCU\Software\Classes\Looper.AudioFile\shell\Looper.Play',
        '/ve',
        '/t',
        'REG_SZ',
        '/d',
        'Play in Looper',
        '/f',
      ]);
      await _runReg([
        'add',
        r'HKCU\Software\Classes\Looper.AudioFile\shell\Looper.Play',
        '/v',
        'MultiSelectModel',
        '/t',
        'REG_SZ',
        '/d',
        'Player',
        '/f',
      ]);
      await _runReg([
        'add',
        r'HKCU\Software\Classes\Looper.AudioFile\shell\Looper.Play',
        '/v',
        'Icon',
        '/t',
        'REG_SZ',
        '/d',
        '"$exePath"',
        '/f',
      ]);
      await _runReg([
        'add',
        r'HKCU\Software\Classes\Looper.AudioFile\shell\Looper.Play\command',
        '/ve',
        '/t',
        'REG_SZ',
        '/d',
        '"$exePath" "%1"',
        '/f',
      ]);

      // Remove legacy or duplicate HKCU ProgID open and enqueue verbs if present,
      // as they have been unified to Looper.Play and Looper.Enqueue.
      await _runReg([
        'delete',
        r'HKCU\Software\Classes\Looper.AudioFile\shell\open',
        '/f',
      ]);
      await _runReg([
        'delete',
        r'HKCU\Software\Classes\Looper.AudioFile\shell\enqueue',
        '/f',
      ]);

      // 2. Generic SystemFileAssociations for audio files
      await _runReg([
        'add',
        r'HKCU\Software\Classes\SystemFileAssociations\audio\shell\Looper.Play',
        '/ve',
        '/t',
        'REG_SZ',
        '/d',
        'Play in Looper',
        '/f',
      ]);
      await _runReg([
        'add',
        r'HKCU\Software\Classes\SystemFileAssociations\audio\shell\Looper.Play',
        '/v',
        'MultiSelectModel',
        '/t',
        'REG_SZ',
        '/d',
        'Player',
        '/f',
      ]);
      await _runReg([
        'add',
        r'HKCU\Software\Classes\SystemFileAssociations\audio\shell\Looper.Play',
        '/v',
        'Icon',
        '/t',
        'REG_SZ',
        '/d',
        '"$exePath"',
        '/f',
      ]);
      await _runReg([
        'add',
        r'HKCU\Software\Classes\SystemFileAssociations\audio\shell\Looper.Play\command',
        '/ve',
        '/t',
        'REG_SZ',
        '/d',
        '"$exePath" "%1"',
        '/f',
      ]);

      await _runReg([
        'add',
        r'HKCU\Software\Classes\SystemFileAssociations\audio\shell\Looper.Enqueue',
        '/ve',
        '/t',
        'REG_SZ',
        '/d',
        'Add to Looper Queue',
        '/f',
      ]);
      await _runReg([
        'add',
        r'HKCU\Software\Classes\SystemFileAssociations\audio\shell\Looper.Enqueue',
        '/v',
        'MultiSelectModel',
        '/t',
        'REG_SZ',
        '/d',
        'Player',
        '/f',
      ]);
      await _runReg([
        'add',
        r'HKCU\Software\Classes\SystemFileAssociations\audio\shell\Looper.Enqueue',
        '/v',
        'Icon',
        '/t',
        'REG_SZ',
        '/d',
        '"$exePath"',
        '/f',
      ]);
      await _runReg([
        'add',
        r'HKCU\Software\Classes\SystemFileAssociations\audio\shell\Looper.Enqueue\command',
        '/ve',
        '/t',
        'REG_SZ',
        '/d',
        '"$exePath" "--enqueue" "%1"',
        '/f',
      ]);

      // 3. Register individual extension associations
      for (final ext in supportedExtensions) {
        await _runReg([
          'add',
          'HKCU\\Software\\Classes\\$ext\\OpenWithProgids',
          '/v',
          progId,
          '/t',
          'REG_SZ',
          '/d',
          '',
          '/f',
        ]);
        await _runReg([
          'add',
          'HKCU\\Software\\Classes\\SystemFileAssociations\\$ext\\shell\\Looper.Play',
          '/ve',
          '/t',
          'REG_SZ',
          '/d',
          'Play in Looper',
          '/f',
        ]);
        await _runReg([
          'add',
          'HKCU\\Software\\Classes\\SystemFileAssociations\\$ext\\shell\\Looper.Play',
          '/v',
          'MultiSelectModel',
          '/t',
          'REG_SZ',
          '/d',
          'Player',
          '/f',
        ]);
        await _runReg([
          'add',
          'HKCU\\Software\\Classes\\SystemFileAssociations\\$ext\\shell\\Looper.Play',
          '/v',
          'Icon',
          '/t',
          'REG_SZ',
          '/d',
          '"$exePath"',
          '/f',
        ]);
        await _runReg([
          'add',
          'HKCU\\Software\\Classes\\SystemFileAssociations\\$ext\\shell\\Looper.Play\\command',
          '/ve',
          '/t',
          'REG_SZ',
          '/d',
          '"$exePath" "%1"',
          '/f',
        ]);
        await _runReg([
          'add',
          'HKCU\\Software\\Classes\\SystemFileAssociations\\$ext\\shell\\Looper.Enqueue',
          '/ve',
          '/t',
          'REG_SZ',
          '/d',
          'Add to Looper Queue',
          '/f',
        ]);
        await _runReg([
          'add',
          'HKCU\\Software\\Classes\\SystemFileAssociations\\$ext\\shell\\Looper.Enqueue',
          '/v',
          'MultiSelectModel',
          '/t',
          'REG_SZ',
          '/d',
          'Player',
          '/f',
        ]);
        await _runReg([
          'add',
          'HKCU\\Software\\Classes\\SystemFileAssociations\\$ext\\shell\\Looper.Enqueue',
          '/v',
          'Icon',
          '/t',
          'REG_SZ',
          '/d',
          '"$exePath"',
          '/f',
        ]);
        await _runReg([
          'add',
          'HKCU\\Software\\Classes\\SystemFileAssociations\\$ext\\shell\\Looper.Enqueue\\command',
          '/ve',
          '/t',
          'REG_SZ',
          '/d',
          '"$exePath" "--enqueue" "%1"',
          '/f',
        ]);
      }

      LoggerHelper.write('WindowsFileAssociationService: Registration completed successfully.');
      return true;
    } catch (e, s) {
      LoggerHelper.write('WindowsFileAssociationService: Registration error', e, s);
      return false;
    }
  }

  /// Removes registered file associations and context menu entries.
  static Future<bool> unregister() async {
    if (!Platform.isWindows || kIsWeb) return false;

    try {
      await _runReg(['delete', r'HKCU\Software\Classes\Looper.AudioFile', '/f']);
      await _runReg([
        'delete',
        r'HKCU\Software\Classes\SystemFileAssociations\audio\shell\Looper.Play',
        '/f',
      ]);
      await _runReg([
        'delete',
        r'HKCU\Software\Classes\SystemFileAssociations\audio\shell\Looper.Enqueue',
        '/f',
      ]);

      for (final ext in supportedExtensions) {
        await _runReg([
          'delete',
          'HKCU\\Software\\Classes\\$ext\\OpenWithProgids',
          '/v',
          progId,
          '/f',
        ]);
        await _runReg([
          'delete',
          'HKCU\\Software\\Classes\\SystemFileAssociations\\$ext\\shell\\Looper.Play',
          '/f',
        ]);
        await _runReg([
          'delete',
          'HKCU\\Software\\Classes\\SystemFileAssociations\\$ext\\shell\\Looper.Enqueue',
          '/f',
        ]);
      }

      LoggerHelper.write('WindowsFileAssociationService: Unregistered successfully.');
      return true;
    } catch (e, s) {
      LoggerHelper.write('WindowsFileAssociationService: Unregistration error', e, s);
      return false;
    }
  }

  /// Checks if file associations are registered.
  static Future<bool> isRegistered() async {
    if (!Platform.isWindows || kIsWeb) return false;
    try {
      final result = await Process.run('reg', [
        'query',
        r'HKCU\Software\Classes\Looper.AudioFile',
      ]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  static Future<ProcessResult> _runReg(List<String> args) {
    return Process.run('reg', args, runInShell: true);
  }
}
