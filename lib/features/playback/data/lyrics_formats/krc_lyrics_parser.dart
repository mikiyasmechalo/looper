import 'timed_lyrics.dart';

/// The two Chinese karaoke formats, one line per lyric line:
///
///   KRC (KuGou):   `[27672,2784]<0,200,0>I've <200,144,0>been ...`
///   YRC (NetEase): `[27360,1290](27360,240,0)I've (27600,90,0)been ...`
///
/// Both open with `[line start, line duration]` in ms. KRC times each word
/// as `<offset from the line start, duration, 0>`, YRC as
/// `(start in the song, duration, 0)`. Metadata (`[ti:..]`, JSON credit
/// lines) doesn't match the line pattern and is skipped.
class KrcLyricsParser {
  static final RegExp _line = RegExp(r'^\[(\d+),(\d+)\](.*)$');
  static final RegExp _krcWord = RegExp(r'<(\d+),(\d+),\d+>([^<]*)');
  static final RegExp _yrcWord = RegExp(r'\((\d+),(\d+),\d+\)([^()]*)');
  static final RegExp _latinEnd = RegExp(r"[A-Za-z0-9',.!?]$");
  static final RegExp _latinStart = RegExp(r'^[A-Za-z0-9]');

  static List<TimedLyricLine> parseKrc(String krc) =>
      _parse(krc, _krcWord, relative: true);

  static List<TimedLyricLine> parseYrc(String yrc) =>
      _parse(yrc, _yrcWord, relative: false);

  static List<TimedLyricLine> _parse(
    String source,
    RegExp word, {
    required bool relative,
  }) {
    final lines = <TimedLyricLine>[];
    for (final raw in source.split(RegExp(r'\r?\n'))) {
      final match = _line.firstMatch(raw.trim());
      if (match == null) continue;
      final start = int.parse(match.group(1)!);
      final end = start + int.parse(match.group(2)!);
      final content = match.group(3)!;

      final words = <TimedSyllable>[];
      for (final w in word.allMatches(content)) {
        final text = w.group(3)!;
        if (text.isEmpty) continue;
        // A space timed on its own belongs to the word before it.
        if (text.trim().isEmpty) {
          if (words.isNotEmpty && !words.last.text.endsWith(' ')) {
            final last = words.removeLast();
            words.add(
              TimedSyllable(
                text: '${last.text} ',
                startMs: last.startMs,
                endMs: last.endMs,
              ),
            );
          }
          continue;
        }
        // NetEase times whole Latin words but sometimes drops the space
        // between two of them ("how(..)to").
        if (!relative &&
            words.isNotEmpty &&
            _latinEnd.hasMatch(words.last.text) &&
            _latinStart.hasMatch(text)) {
          final last = words.removeLast();
          words.add(
            TimedSyllable(
              text: '${last.text} ',
              startMs: last.startMs,
              endMs: last.endMs,
            ),
          );
        }
        final wordStart = int.parse(w.group(1)!) + (relative ? start : 0);
        words.add(
          TimedSyllable(
            text: text,
            startMs: wordStart,
            endMs: wordStart + int.parse(w.group(2)!),
          ),
        );
      }

      final text = words.isEmpty
          ? content.trim()
          : words.map((w) => w.text).join().trim();
      if (text.isEmpty) continue;
      lines.add(
        TimedLyricLine(startMs: start, endMs: end, text: text, words: words),
      );
    }
    lines.sort((a, b) => a.startMs.compareTo(b.startMs));
    return lines;
  }
}
