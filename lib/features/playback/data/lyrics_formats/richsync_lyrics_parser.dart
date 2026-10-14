import 'dart:convert';

import 'timed_lyrics.dart';

/// Musixmatch "richsync": a JSON array of lines, times in seconds -
///
///   {"ts":27.359,"te":28.17,"x":"I've been tryna call",
///    "l":[{"c":"I've","o":0},{"c":" ","o":0.278},{"c":"been","o":0.333}]}
///
/// `ts`/`te` bound the line, `x` is its text, and each `l` chunk starts
/// `o` seconds into the line. Chunks carry no end time: a word ends where
/// the next chunk starts, the last one at `te`.
class RichsyncLyricsParser {
  static List<TimedLyricLine>? parse(String richsyncBody) {
    final Object? decoded;
    try {
      decoded = jsonDecode(richsyncBody);
    } catch (_) {
      return null;
    }
    if (decoded is! List) return null;

    final lines = <TimedLyricLine>[];
    for (final line in decoded.whereType<Map>()) {
      final ts = line['ts'];
      if (ts is! num) continue;
      final te = line['te'] is num ? line['te'] as num : ts;
      final start = (ts * 1000).round();
      final end = (te * 1000).round();

      final chunks = [
        for (final c in (line['l'] is List ? line['l'] as List : const []))
          if (c is Map && c['c'] is String && (c['c'] as String).isNotEmpty)
            (
              text: c['c'] as String,
              at:
                  start +
                  (((c['o'] is num ? c['o'] as num : 0)) * 1000).round(),
            ),
      ];
      final words = <TimedSyllable>[];
      for (var i = 0; i < chunks.length; i++) {
        final chunk = chunks[i];
        // A space chunk only marks where the word before it ends.
        if (chunk.text.trim().isEmpty) {
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
        final next = i + 1 < chunks.length ? chunks[i + 1].at : end;
        words.add(
          TimedSyllable(
            text: chunk.text,
            startMs: chunk.at,
            endMs: next > chunk.at ? next : chunk.at,
          ),
        );
      }

      final text = words.isEmpty
          ? '${line['x'] ?? ''}'.trim()
          : words.map((w) => w.text).join().trim();
      if (text.isEmpty) continue;
      lines.add(
        TimedLyricLine(startMs: start, endMs: end, text: text, words: words),
      );
    }
    return lines.isEmpty ? null : lines;
  }
}
