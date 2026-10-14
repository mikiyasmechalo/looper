import 'package:flutter_test/flutter_test.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/domain/lyric_models.dart';
import 'package:looper_player/features/playback/presentation/lyrics_notifier.dart';

void main() {
  group('Lyrics Rework & Synchronizer Tests', () {
    test('Default and per-song offset calculations', () {
      expect(AppSettings.defaultLyricsOffsetMs, equals(200));
      expect(lyricsShiftMs(null), equals(200));
      expect(lyricsShiftMs(250), equals(250));
      expect(lyricsShiftMs(-250), equals(-250));
      expect(lyricsShiftMs(500), equals(500));
    });

    test('LrcParser parses standard timed LRC with offset shift', () {
      const lrc = '''[00:01.00]First line
[00:02.50]Second line
[00:04.00]Third line''';

      // Without shift
      final linesZeroShift = LrcParser.parse(
        lrc,
        const Duration(seconds: 10),
        shift: Duration.zero,
      );
      expect(linesZeroShift.length, equals(3));
      expect(linesZeroShift[0].startTime.inMilliseconds, equals(1000));
      expect(linesZeroShift[1].startTime.inMilliseconds, equals(2500));

      // With +250ms earlier offset (shift = -250ms)
      final linesEarlier = LrcParser.parse(
        lrc,
        const Duration(seconds: 10),
        shift: const Duration(milliseconds: -250),
      );
      expect(linesEarlier.length, equals(3));
      expect(linesEarlier[0].startTime.inMilliseconds, equals(750));
      expect(linesEarlier[1].startTime.inMilliseconds, equals(2250));

      // With -250ms later offset (shift = +250ms)
      final linesLater = LrcParser.parse(
        lrc,
        const Duration(seconds: 10),
        shift: const Duration(milliseconds: 250),
      );
      expect(linesLater.length, equals(3));
      expect(linesLater[0].startTime.inMilliseconds, equals(1250));
      expect(linesLater[1].startTime.inMilliseconds, equals(2750));
    });

    test('LrcParser detects timed vs untimed lyrics', () {
      const timedLrc = '[00:01.00]Hello world';
      const plainText = 'Hello world\nAnother line without timestamps';

      expect(LrcParser.isTimed(timedLrc), isTrue);
      expect(LrcParser.isTimed(plainText), isFalse);
    });

    test('AppSettings defaults autoLyricsFallback to true', () {
      final settings = AppSettings();
      expect(settings.autoLyricsFallback, isTrue);
      expect(settings.autoLyricsFallbackMigrated, isFalse);
    });
  });
}
