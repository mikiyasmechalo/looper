import 'package:flutter_test/flutter_test.dart';
import 'package:looper_player/features/library/domain/models/models.dart';

Song createSong(int id, String path, String title) {
  return Song()
    ..id = id
    ..path = path
    ..title = title
    ..dateAdded = DateTime.now();
}

class TestQueueManager {
  List<Song> playlist = [];
  List<Song> originalPlaylist = [];
  int currentIndex = -1;
  int manualQueueCount = 0;

  void removeExistingFromQueue(String songPath) {
    for (int i = playlist.length - 1; i >= 0; i--) {
      if (i == currentIndex) continue; // Keep actively playing song
      if (playlist[i].path == songPath) {
        playlist.removeAt(i);
        if (i < currentIndex) {
          currentIndex--;
        } else if (i <= currentIndex + manualQueueCount) {
          if (manualQueueCount > 0) manualQueueCount--;
        }
      }
    }
    originalPlaylist.removeWhere((s) => s.path == songPath);
  }

  void addNext(Song song) {
    if (currentIndex >= 0 &&
        currentIndex < playlist.length &&
        playlist[currentIndex].path == song.path) {
      return; // Do not duplicate active song
    }

    removeExistingFromQueue(song.path);

    if (playlist.isEmpty || currentIndex == -1) {
      playlist = [song];
      originalPlaylist = [song];
      currentIndex = 0;
      manualQueueCount = 0;
      return;
    }

    final insertIndex = currentIndex + 1;
    if (insertIndex >= playlist.length) {
      playlist.add(song);
    } else {
      playlist.insert(insertIndex, song);
    }

    final origIdx = originalPlaylist.indexWhere((s) => s.path == playlist[currentIndex].path);
    if (origIdx != -1) {
      originalPlaylist.insert(origIdx + 1, song);
    } else {
      originalPlaylist.add(song);
    }
    manualQueueCount++;
  }

  void addToQueue(Song song) {
    if (currentIndex >= 0 &&
        currentIndex < playlist.length &&
        playlist[currentIndex].path == song.path) {
      return; // Do not duplicate active song
    }

    removeExistingFromQueue(song.path);

    if (playlist.isEmpty || currentIndex == -1) {
      playlist = [song];
      originalPlaylist = [song];
      currentIndex = 0;
      manualQueueCount = 0;
      return;
    }

    final insertIndex = currentIndex + 1 + manualQueueCount;
    if (insertIndex >= playlist.length) {
      playlist.add(song);
    } else {
      playlist.insert(insertIndex, song);
    }
    originalPlaylist.add(song);
    manualQueueCount++;
  }

  void reorderQueueDirect(int oldOriginalIdx, int newOriginalIdx, {String? currentSongPath}) {
    if (playlist.isEmpty) return;
    if (oldOriginalIdx == newOriginalIdx) return;
    if (oldOriginalIdx < 0 || oldOriginalIdx >= playlist.length) return;
    if (newOriginalIdx < 0 || newOriginalIdx >= playlist.length) return;

    final wasManual = manualQueueCount > 0 &&
        oldOriginalIdx > currentIndex &&
        oldOriginalIdx <= currentIndex + manualQueueCount;

    final targetPath = currentSongPath ??
        (currentIndex >= 0 && currentIndex < playlist.length
            ? playlist[currentIndex].path
            : null);

    final song = playlist.removeAt(oldOriginalIdx);
    playlist.insert(newOriginalIdx, song);

    if (targetPath != null) {
      currentIndex = playlist.indexWhere((s) => s.path == targetPath);
    }

    if (wasManual && newOriginalIdx < currentIndex) {
      if (manualQueueCount > 0) manualQueueCount--;
    }
  }
}

void main() {
  group('Queue Deduplication Tests', () {
    test('addNext removes already played song from history and inserts at next', () {
      final qm = TestQueueManager();
      final songA = createSong(1, '/a.mp3', 'Song A');
      final songB = createSong(2, '/b.mp3', 'Song B');
      final songC = createSong(3, '/c.mp3', 'Song C');
      final songD = createSong(4, '/d.mp3', 'Song D');

      // Initial queue: [A, B, C, D], currently playing C (index 2)
      qm.playlist = [songA, songB, songC, songD];
      qm.originalPlaylist = [songA, songB, songC, songD];
      qm.currentIndex = 2; // Song C

      // User selects already played Song A and chooses "Play Next"
      qm.addNext(songA);

      // Verify Song A is removed from index 0
      // Current playing song (Song C) must remain current
      // Song A must now be immediately after Song C
      expect(qm.playlist.map((s) => s.title).toList(), ['Song B', 'Song C', 'Song A', 'Song D']);
      expect(qm.currentIndex, 1); // Song C shifted from index 2 to index 1
      expect(qm.playlist[qm.currentIndex].title, 'Song C');
      expect(qm.playlist[qm.currentIndex + 1].title, 'Song A');

      // Ensure NO duplicate of Song A exists
      final countA = qm.playlist.where((s) => s.path == songA.path).length;
      expect(countA, 1);
    });

    test('addNext on upcoming song moves it to next position without duplicates', () {
      final qm = TestQueueManager();
      final songA = createSong(1, '/a.mp3', 'Song A');
      final songB = createSong(2, '/b.mp3', 'Song B');
      final songC = createSong(3, '/c.mp3', 'Song C');
      final songD = createSong(4, '/d.mp3', 'Song D');

      // Queue: [A, B, C, D], currently playing A (index 0)
      qm.playlist = [songA, songB, songC, songD];
      qm.originalPlaylist = [songA, songB, songC, songD];
      qm.currentIndex = 0; // Song A

      // User selects upcoming Song D and chooses "Play Next"
      qm.addNext(songD);

      expect(qm.playlist.map((s) => s.title).toList(), ['Song A', 'Song D', 'Song B', 'Song C']);
      expect(qm.currentIndex, 0);
      expect(qm.playlist[qm.currentIndex].title, 'Song A');
      expect(qm.playlist[1].title, 'Song D');

      final countD = qm.playlist.where((s) => s.path == songD.path).length;
      expect(countD, 1);
    });

    test('addNext does not duplicate currently playing song', () {
      final qm = TestQueueManager();
      final songA = createSong(1, '/a.mp3', 'Song A');
      final songB = createSong(2, '/b.mp3', 'Song B');

      qm.playlist = [songA, songB];
      qm.originalPlaylist = [songA, songB];
      qm.currentIndex = 0; // Song A is playing

      // Attempting to add active Song A next
      qm.addNext(songA);

      // Must remain unchanged
      expect(qm.playlist.map((s) => s.title).toList(), ['Song A', 'Song B']);
      expect(qm.currentIndex, 0);
    });

    test('addToQueue removes already played song from history and appends to manual queue', () {
      final qm = TestQueueManager();
      final songA = createSong(1, '/a.mp3', 'Song A');
      final songB = createSong(2, '/b.mp3', 'Song B');
      final songC = createSong(3, '/c.mp3', 'Song C');

      qm.playlist = [songA, songB, songC];
      qm.originalPlaylist = [songA, songB, songC];
      qm.currentIndex = 1; // Song B is playing

      // User adds already played Song A to queue
      qm.addToQueue(songA);

      expect(qm.playlist.map((s) => s.title).toList(), ['Song B', 'Song A', 'Song C']);
      expect(qm.currentIndex, 0); // Song B moved from index 1 to 0
      expect(qm.playlist[qm.currentIndex].title, 'Song B');

      final countA = qm.playlist.where((s) => s.path == songA.path).length;
      expect(countA, 1);
    });
  });

  group('Queue Reorder Tests', () {
    test('moving upcoming song above currently playing song into played area', () {
      final qm = TestQueueManager();
      final songA = createSong(1, '/a.mp3', 'Song A'); // played
      final songB = createSong(2, '/b.mp3', 'Song B'); // played
      final songC = createSong(3, '/c.mp3', 'Song C'); // CURRENT
      final songD = createSong(4, '/d.mp3', 'Song D'); // upcoming
      final songE = createSong(5, '/e.mp3', 'Song E'); // upcoming

      qm.playlist = [songA, songB, songC, songD, songE];
      qm.currentIndex = 2; // Song C

      // User drags upcoming Song D (index 3) to index 1 (between A and B in played area)
      qm.reorderQueueDirect(3, 1, currentSongPath: songC.path);

      expect(qm.playlist.map((s) => s.title).toList(), ['Song A', 'Song D', 'Song B', 'Song C', 'Song E']);
      // Song C shifted from index 2 to index 3
      expect(qm.currentIndex, 3);
      expect(qm.playlist[qm.currentIndex].title, 'Song C');
      // Song D is at index 1, which is < currentIndex (3) -> now in played area!
      expect(qm.playlist[1].title, 'Song D');
    });

    test('moving upcoming song directly above current song places it at end of played area', () {
      final qm = TestQueueManager();
      final songA = createSong(1, '/a.mp3', 'Song A'); // played
      final songB = createSong(2, '/b.mp3', 'Song B'); // CURRENT
      final songC = createSong(3, '/c.mp3', 'Song C'); // upcoming

      qm.playlist = [songA, songB, songC];
      qm.currentIndex = 1; // Song B

      // Drag upcoming Song C (index 2) to slot 1 (directly above Song B)
      qm.reorderQueueDirect(2, 1, currentSongPath: songB.path);

      expect(qm.playlist.map((s) => s.title).toList(), ['Song A', 'Song C', 'Song B']);
      expect(qm.currentIndex, 2); // Song B is now at index 2
      expect(qm.playlist[1].title, 'Song C'); // Song C is at index 1 < 2 (played area)
    });

    test('moving played song below current song places it into upcoming area', () {
      final qm = TestQueueManager();
      final songA = createSong(1, '/a.mp3', 'Song A'); // played
      final songB = createSong(2, '/b.mp3', 'Song B'); // played
      final songC = createSong(3, '/c.mp3', 'Song C'); // CURRENT
      final songD = createSong(4, '/d.mp3', 'Song D'); // upcoming

      qm.playlist = [songA, songB, songC, songD];
      qm.currentIndex = 2; // Song C

      // User drags played Song A (index 0) to after Song C (index 3)
      // In Flutter ReorderableListView, dragging item 0 to after item 2 gives newI = 3, decremented by 1 -> newOrig = 2
      // After removing 0 (A), C shifted to 1. Inserting at 2 places A directly after C!
      qm.reorderQueueDirect(0, 2, currentSongPath: songC.path);

      expect(qm.playlist.map((s) => s.title).toList(), ['Song B', 'Song C', 'Song A', 'Song D']);
      expect(qm.currentIndex, 1); // Song C shifted to index 1
      expect(qm.playlist[2].title, 'Song A'); // Song A is at index 2 > 1 (upcoming area)
    });

    test('moving a manual queue song to played area decrements manualQueueCount', () {
      final qm = TestQueueManager();
      final songA = createSong(1, '/a.mp3', 'Song A'); // played
      final songB = createSong(2, '/b.mp3', 'Song B'); // CURRENT
      final songC = createSong(3, '/c.mp3', 'Song C'); // manual upcoming (play next)
      final songD = createSong(4, '/d.mp3', 'Song D'); // upcoming

      qm.playlist = [songA, songB, songC, songD];
      qm.currentIndex = 1; // Song B
      qm.manualQueueCount = 1; // Song C

      // Drag manual Song C (index 2) to slot 0 (played area)
      qm.reorderQueueDirect(2, 0, currentSongPath: songB.path);

      expect(qm.playlist.map((s) => s.title).toList(), ['Song C', 'Song A', 'Song B', 'Song D']);
      expect(qm.currentIndex, 2); // Song B shifted to index 2
      expect(qm.manualQueueCount, 0); // No longer in manual queue
    });
  });
}
