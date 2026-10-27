import 'package:flutter_test/flutter_test.dart';
import 'package:looper_player/core/single_instance_service.dart';
import 'package:looper_player/core/update_service.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/folder_browser_view.dart';
import 'package:path/path.dart' as p;

void main() {
  group('SingleInstanceService CLI & Multi-Select Parsing Tests', () {
    test('Empty arguments returns focus action and empty files', () {
      final res = SingleInstanceService.parseArgs([]);
      expect(res['action'], equals('focus'));
      expect(res['files'], isEmpty);
    });

    test('Single audio file defaults to play action', () {
      final res = SingleInstanceService.parseArgs([r'D:\Music\song.mp3']);
      expect(res['action'], equals('play'));
      expect(res['files'], equals([r'D:\Music\song.mp3']));
    });

    test('Multiple audio files for Play in Looper parses all files', () {
      final res = SingleInstanceService.parseArgs([
        r'D:\Music\track1.mp3',
        r'D:\Music\track2.flac',
        r'D:\Music\track3.wav',
      ]);
      expect(res['action'], equals('play'));
      expect(
        res['files'],
        equals([
          r'D:\Music\track1.mp3',
          r'D:\Music\track2.flac',
          r'D:\Music\track3.wav',
        ]),
      );
    });

    test('--enqueue flag correctly sets enqueue action with multiple files', () {
      final res = SingleInstanceService.parseArgs([
        '--enqueue',
        r'D:\Music\track1.mp3',
        r'D:\Music\track2.flac',
      ]);
      expect(res['action'], equals('enqueue'));
      expect(
        res['files'],
        equals([r'D:\Music\track1.mp3', r'D:\Music\track2.flac']),
      );
    });

    test('Handles quoted string containing multiple files passed by shell', () {
      final res = SingleInstanceService.parseArgs([
        '"D:\\Music\\track 1.mp3" "D:\\Music\\track 2.mp3"',
      ]);
      expect(res['action'], equals('play'));
      expect(
        res['files'],
        equals([r'D:\Music\track 1.mp3', r'D:\Music\track 2.mp3']),
      );
    });
  });

  group('Library Isolation & External Folder Filtering Tests', () {
    test('Songs outside configured library folders are filtered out', () {
      final libraryFolders = [r'D:\Music\Singles', r'D:\Music\Albums'];

      bool isWithinAnyFolder(String filePath, List<String> folders) {
        final normFile = p.normalize(p.absolute(filePath)).toLowerCase();
        for (final folder in folders) {
          final normFolder = p.normalize(p.absolute(folder)).toLowerCase();
          if (normFile == normFolder ||
              normFile.startsWith(normFolder.endsWith(p.separator)
                  ? normFolder
                  : '$normFolder${p.separator}')) {
            return true;
          }
        }
        return false;
      }

      // Valid library tracks
      expect(isWithinAnyFolder(r'D:\Music\Singles\track.mp3', libraryFolders), isTrue);
      expect(isWithinAnyFolder(r'D:\Music\Albums\Artist\album_track.flac', libraryFolders), isTrue);

      // External files from Downloads, Desktop, USB, etc.
      expect(isWithinAnyFolder(r'C:\Users\User\Downloads\external.mp3', libraryFolders), isFalse);
      expect(isWithinAnyFolder(r'C:\Users\User\Desktop\sample.wav', libraryFolders), isFalse);
      expect(isWithinAnyFolder(r'E:\USB\podcast.mp3', libraryFolders), isFalse);
    });
  });

  group('UpdateService Version Comparison & Endpoint Tests', () {
    test('repoUrl points strictly to mikiyasmechalo/looper without upstream fallbacks', () {
      expect(UpdateService.repoUrl, contains('mikiyasmechalo/looper'));
      expect(UpdateService.releasesListUrl, contains('mikiyasmechalo/looper'));
      expect(UpdateService.releasesHtmlUrl, contains('mikiyasmechalo/looper'));
      expect(UpdateService.repoUrl, isNot(contains('SthrNilshaaa')));
    });

    test('Same version does not trigger update', () {
      expect(UpdateService.isUpdateAvailable('1.0.0-beta.1+1', 'v1.0.0-beta.1'), isFalse);
      expect(UpdateService.isUpdateAvailable('1.0.0', '1.0.0'), isFalse);
    });

    test('Newer version triggers update', () {
      expect(UpdateService.isUpdateAvailable('1.0.0-beta.1+1', 'v1.0.1'), isTrue);
      expect(UpdateService.isUpdateAvailable('1.0.0', '1.1.0'), isTrue);
      expect(UpdateService.isUpdateAvailable('1.0.0', 'v2.0.0'), isTrue);
    });

    test('Older version does not trigger update', () {
      expect(UpdateService.isUpdateAvailable('1.0.0-beta.1+1', 'v0.9.8'), isFalse);
    });
  });
}
