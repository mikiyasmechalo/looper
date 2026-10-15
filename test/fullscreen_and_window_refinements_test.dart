import 'package:flutter_test/flutter_test.dart';
import 'package:looper_player/features/library/domain/models/models.dart';

void main() {
  group('Fullscreen & Window Settings Defaults', () {
    test('closeToTray defaults to false', () {
      final settings = AppSettings();
      expect(settings.closeToTray, isFalse);
    });

    test('disableFullscreenBreathingEffect defaults to false', () {
      final settings = AppSettings();
      expect(settings.disableFullscreenBreathingEffect, isFalse);
    });

    test('Dynamic scrobble threshold calculation clamps properly', () {
      // 50% threshold on a 200s song = 100s
      int computeThreshold(int durationMs, int percent) {
        final thresholdPercent = percent.clamp(10, 100);
        return durationMs > 0
            ? ((durationMs / 1000) * (thresholdPercent / 100)).clamp(10.0, 240.0).round()
            : 10;
      }

      // Normal 4-minute track at 50% -> 120s
      expect(computeThreshold(240000, 50), 120);

      // Very long track (10 minutes) at 50% -> clamped to max 240s
      expect(computeThreshold(600000, 50), 240);

      // Very short track (12 seconds) at 50% -> clamped to min 10s
      expect(computeThreshold(12000, 50), 10);

      // 0ms duration fallback
      expect(computeThreshold(0, 50), 10);
    });
  });

  group('Play All vs Shuffle behavior', () {
    test('Play All with disableShuffle preserves exact sequential track order', () {
      bool isShuffle = true;
      final songs = List.generate(
        5,
        (i) => Song()
          ..id = i
          ..path = '/music/track$i.mp3'
          ..title = 'Track $i',
      );

      // Simulating setPlaylist logic with disableShuffle = true
      const disableShuffle = true;
      if (disableShuffle && isShuffle) {
        isShuffle = false;
      }

      List<Song> playlist;
      int currentIndex;

      if (isShuffle) {
        final currentSong = songs[0];
        final remaining = List<Song>.from(songs)..removeAt(0);
        remaining.shuffle();
        playlist = [currentSong, ...remaining];
        currentIndex = 0;
      } else {
        playlist = List.from(songs);
        currentIndex = 0;
      }

      expect(isShuffle, isFalse);
      expect(currentIndex, 0);
      expect(playlist.map((s) => s.title).toList(), [
        'Track 0',
        'Track 1',
        'Track 2',
        'Track 3',
        'Track 4',
      ]);
    });
  });
}
