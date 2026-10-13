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
}
