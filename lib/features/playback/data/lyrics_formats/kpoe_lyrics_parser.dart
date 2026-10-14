import 'timed_lyrics.dart';

/// Parses the JSON returned by LyricsPlus (`/v2/lyrics/get`, the "KPoe"
/// format) into [TimedLyricLine]s.
///
/// Shape (times are integer milliseconds; some mirrors send float seconds):
/// ```json
/// { "type": "Word" | "Line",
///   "metadata": { "source": "...", "agents": { "v1": { "type": "person" } } },
///   "lyrics": [ { "time": 27395, "duration": 1565, "text": "...",
///                 "syllabus": [ { "time": 27395, "duration": 154,
///                                 "text": "I ", "isBackground": false } ],
///                 "element": { "singer": "v1" } } ] }
/// ```
class KpoeLyricsParser {
  static List<TimedLyricLine>? parse(Object? payload) {
    if (payload is! Map) return null;

    final rawLines = _findLines(payload);
    if (rawLines == null || rawLines.isEmpty) return null;

    final type = payload['type']?.toString().toLowerCase();
    final lineSyncedOnly = type == 'line';

    final agentTypes = <String, String>{};
    final agents = (payload['metadata'] as Map?)?['agents'];
    if (agents is Map) {
      agents.forEach((key, value) {
        if (value is Map && value['type'] != null) {
          agentTypes[(value['alias'] ?? key).toString()] = value['type']
              .toString();
        }
      });
    }

    final lines = <TimedLyricLine>[];
    final singers = <String?>[];

    for (final entry in rawLines.whereType<Map>()) {
      final start = toMs(entry['time']);
      final duration = toMs(entry['duration']);
      final explicitEnd = toMs(entry['endTime']);
      final end = explicitEnd > 0 ? explicitEnd : start + duration;
      final text = entry['text'] is String ? entry['text'] as String : '';

      final main = <TimedSyllable>[];
      final background = <TimedSyllable>[];
      final syllabus = entry['syllabus'] ?? entry['words'];
      if (!lineSyncedOnly && syllabus is List) {
        final items = syllabus.whereType<Map>().toList();
        for (final syl in items) {
          final sylText = syl['text'] is String ? syl['text'] as String : '';
          if (sylText.isEmpty) continue;
          final sylStart = syl['time'] == null ? start : toMs(syl['time']);
          final sylDuration = toMs(syl['duration']);
          // A lone zero-length syllable is a line-synced line in disguise.
          final sylEnd = sylDuration == 0 && items.length == 1
              ? end
              : sylStart + sylDuration;
          (syl['isBackground'] == true ? background : main).add(
            TimedSyllable(text: sylText, startMs: sylStart, endMs: sylEnd),
          );
        }
      }

      final lineText = main.isNotEmpty
          ? main.map((s) => s.text).join().trim()
          : text.trim();
      if (lineText.isEmpty) continue;

      lines.add(
        TimedLyricLine(
          startMs: start,
          endMs: end,
          text: lineText,
          // A single syllable carries no word-level information.
          words: main.length > 1 ? main : const [],
          background: background,
        ),
      );
      final element = entry['element'];
      singers.add(element is Map ? element['singer']?.toString() : null);
    }

    if (lines.isEmpty) return null;

    final sides = assignDuetSides(singers, agentTypes);
    return [
      for (var i = 0; i < lines.length; i++)
        sides[i]
            ? TimedLyricLine(
                startMs: lines[i].startMs,
                endMs: lines[i].endMs,
                text: lines[i].text,
                words: lines[i].words,
                background: lines[i].background,
                oppositeSide: true,
              )
            : lines[i],
    ];
  }

  /// Source label the mirror reports, e.g. "qApple", "Musixmatch".
  static String? sourceOf(Object? payload) {
    if (payload is! Map) return null;
    final metadata = payload['metadata'];
    if (metadata is! Map) return null;
    return (metadata['source'] ?? metadata['provider'])?.toString();
  }

  static List? _findLines(Map payload) {
    if (payload['lyrics'] is List) return payload['lyrics'] as List;
    final data = payload['data'];
    if (data is List) return data;
    if (data is Map && data['lyrics'] is List) return data['lyrics'] as List;
    return null;
  }

  /// Integers are milliseconds; fractional numbers are seconds.
  static int toMs(Object? value) {
    final n = value is num ? value : num.tryParse(value?.toString() ?? '');
    if (n == null || !n.isFinite || n < 0) return 0;
    if (n is double && n != n.roundToDouble()) return (n * 1000).round();
    return n.round();
  }
}
