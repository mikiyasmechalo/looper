import 'timed_lyrics.dart';

/// Lyricify's two text formats, named on the first line:
///
///   [type:LyricifyLines]     `[27395,30189]I been tryna call`
///                            - `[start,end]` in ms, then the line.
///   [type:LyricifySyllable]  `[4]I (27395,154)been (27549,191)...`
///                            - an optional `[n]` singer mark, then each
///                              word followed by `(start,duration)` in ms.
///
/// The API also returns an `offset` (ms) to add to every time.
class LyricifyLyricsParser {
  static final RegExp _line = RegExp(r'^\[(\d+),(\d+)\](.*)$');
  static final RegExp _word = RegExp(r'([^(]+)\((\d+),(\d+)\)');

  static List<TimedLyricLine> parse(String text, {int offsetMs = 0}) {
    final syllables = text.contains('[type:LyricifySyllable]');
    final lines = <TimedLyricLine>[];
    for (final raw in text.split(RegExp(r'\r?\n'))) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('[type:')) continue;
      final parsed = syllables
          ? _syllableLine(line, offsetMs)
          : _plainLine(line, offsetMs);
      if (parsed != null) lines.add(parsed);
    }
    lines.sort((a, b) => a.startMs.compareTo(b.startMs));
    return lines;
  }

  static TimedLyricLine? _plainLine(String line, int offsetMs) {
    final match = _line.firstMatch(line);
    if (match == null) return null;
    final text = match.group(3)!.trim();
    if (text.isEmpty) return null;
    return TimedLyricLine(
      startMs: _at(int.parse(match.group(1)!) + offsetMs),
      endMs: _at(int.parse(match.group(2)!) + offsetMs),
      text: text,
    );
  }

  static TimedLyricLine? _syllableLine(String line, int offsetMs) {
    var body = line;
    if (body.startsWith('[')) {
      final close = body.indexOf(']');
      if (close > 0) body = body.substring(close + 1);
    }
    final words = <TimedSyllable>[];
    for (final w in _word.allMatches(body)) {
      final start = _at(int.parse(w.group(2)!) + offsetMs);
      words.add(
        TimedSyllable(
          text: w.group(1)!,
          startMs: start,
          endMs: start + int.parse(w.group(3)!),
        ),
      );
    }
    if (words.isEmpty) return null;
    return TimedLyricLine(
      startMs: words.first.startMs,
      endMs: words.last.endMs,
      text: words.map((w) => w.text).join().trim(),
      words: words,
    );
  }

  static int _at(int ms) => ms < 0 ? 0 : ms;
}
