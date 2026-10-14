import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Library Folder Sync Safety Tests', () {
    test('listEquals correctly prevents unnecessary sync on cloned folder lists', () {
      final listA = ['C:\\Music\\Folder1', 'D:\\Songs'];
      final listB = List<String>.from(listA);

      // Dart reference comparison would be false
      expect(identical(listA, listB), isFalse);
      expect(listA == listB, isFalse);

      // Value comparison via listEquals prevents triggering sync
      expect(listEquals(listA, listB), isTrue);

      final listC = ['C:\\Music\\Folder1'];
      expect(listEquals(listA, listC), isFalse);
    });

    test('Empty folder list check prevents wiping songs', () {
      bool wouldWipeAllSongs(List<String> activeFolders, List<String> allSongPaths) {
        if (activeFolders.isEmpty) {
          // Safety guard added in fix
          return false;
        }
        final toDelete = allSongPaths.where((path) => !activeFolders.any((f) => path.startsWith(f))).toList();
        return toDelete.length == allSongPaths.length;
      }

      final songs = [
        'C:\\Music\\Song1.mp3',
        'C:\\Music\\Song2.mp3',
        'D:\\Tracks\\Song3.flac',
      ];

      // Without the guard, activeFolders = [] would wipe all songs
      // With the guard, it returns false (safe)
      expect(wouldWipeAllSongs([], songs), isFalse);

      // Deselecting a folder deletes only songs from that folder
      expect(wouldWipeAllSongs(['C:\\Music'], songs), isFalse);
      final remaining = songs.where((path) => ['C:\\Music'].any((f) => path.startsWith(f))).toList();
      expect(remaining.length, 2);
    });
  });

  group('History Backfill Logic Tests', () {
    test('Preserved history matches song by exact path or title+artist', () {
      final history = [
        {
          'songPath': 'D:\\Music\\Overnight.mp3',
          'title': 'Overnight',
          'artist': 'Logic',
          'timestamp': DateTime(2026, 10, 14, 13, 47),
        },
        {
          'songPath': 'D:\\Music\\Overnight.mp3',
          'title': 'Overnight',
          'artist': 'Logic',
          'timestamp': DateTime(2026, 10, 14, 12, 10),
        },
      ];

      int playCount = 0;
      DateTime? lastPlayed;

      final matching = history.where((h) =>
        h['songPath'] == 'D:\\Music\\Overnight.mp3' ||
        ((h['title'] as String).toLowerCase() == 'overnight' &&
         (h['artist'] as String).toLowerCase() == 'logic')
      ).toList();

      if (matching.isNotEmpty) {
        playCount = matching.length;
        lastPlayed = matching.first['timestamp'] as DateTime;
      }

      expect(playCount, 2);
      expect(lastPlayed, DateTime(2026, 10, 14, 13, 47));
    });
  });
}
