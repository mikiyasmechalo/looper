import 'package:xml/xml.dart';

import 'timed_lyrics.dart';

/// Parses Apple-style TTML lyrics (as served by lrc.red) into
/// [TimedLyricLine]s.
///
/// Handles:
/// - `<p begin end>` lines, with or without `<span begin end>` word timing
///   (`timing="Word"` vs `timing="Line"` documents);
/// - syllables of one word written as adjacent spans with no whitespace
///   between them (`<span>e</span><span>nough</span>`);
/// - background vocals: a `<span ttm:role="x-bg">` wrapping timed spans;
/// - duets via `ttm:agent` on each `<p>`, typed by `<ttm:agent type>`.
///
/// Attribute prefixes vary between sources (`itunes:`, `lrc:`, `ttm:`), so
/// everything is matched by local name.
class TtmlLyricsParser {
  static List<TimedLyricLine>? parse(String ttml) {
    final XmlDocument doc;
    try {
      doc = XmlDocument.parse(ttml);
    } catch (_) {
      return null;
    }

    final agentTypes = <String, String>{};
    for (final agent in doc.descendantElements.where(
      (e) => e.name.local == 'agent',
    )) {
      final id = _attr(agent, 'id');
      final type = _attr(agent, 'type');
      if (id != null && type != null) agentTypes[id] = type;
    }

    final lines = <TimedLyricLine>[];
    final singers = <String?>[];

    for (final p in doc.descendantElements.where((e) => e.name.local == 'p')) {
      final begin = parseTime(_attr(p, 'begin'));
      final end = parseTime(_attr(p, 'end')) ?? begin;

      final main = <TimedSyllable>[];
      final background = <TimedSyllable>[];
      _collectSpans(p, main, background, inBackground: false);

      final int startMs;
      final int endMs;
      if (main.isNotEmpty) {
        startMs = begin ?? main.first.startMs;
        endMs = [
          end ?? 0,
          ...main.map((s) => s.endMs),
          ...background.map((s) => s.endMs),
        ].reduce((a, b) => a > b ? a : b);
      } else {
        startMs = begin ?? 0;
        endMs = end ?? startMs;
      }

      final text = main.isNotEmpty
          ? main.map((s) => s.text).join().trim()
          : _ownText(p).replaceAll(RegExp(r'\s+'), ' ').trim();
      if (text.isEmpty) continue;

      lines.add(
        TimedLyricLine(
          startMs: startMs,
          endMs: endMs,
          text: text,
          words: main,
          background: background,
        ),
      );
      singers.add(_attr(p, 'agent'));
    }

    if (lines.isEmpty) return null;

    final sides = assignDuetSides(singers, agentTypes);
    final withSides = [
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
    // Stable sort: TTML is normally already chronological, but <div>s for
    // overlapping song parts aren't guaranteed to be.
    final indexed = withSides.asMap().entries.toList()
      ..sort((a, b) {
        final byTime = a.value.startMs.compareTo(b.value.startMs);
        return byTime != 0 ? byTime : a.key.compareTo(b.key);
      });
    return indexed.map((e) => e.value).toList();
  }

  /// Walks [parent]'s children collecting timed spans. A timed span's text
  /// gets a trailing space when the node right after it is whitespace text -
  /// that's the only signal separating words from syllables of one word.
  static void _collectSpans(
    XmlElement parent,
    List<TimedSyllable> main,
    List<TimedSyllable> background, {
    required bool inBackground,
  }) {
    for (final node in parent.children) {
      if (node is! XmlElement || node.name.local != 'span') continue;

      final isBg = inBackground || _attr(node, 'role') == 'x-bg';
      final begin = parseTime(_attr(node, 'begin'));
      final hasTimedChildren = node.childElements.any(
        (c) => c.name.local == 'span',
      );

      if (hasTimedChildren || begin == null) {
        _collectSpans(node, main, background, inBackground: isBg);
        continue;
      }

      var text = node.innerText;
      if (text.trim().isEmpty) continue;
      final next = node.nextSibling;
      if (next is XmlText &&
          next.value.startsWith(RegExp(r'\s')) &&
          !text.endsWith(' ')) {
        text = '$text ';
      }
      final end = parseTime(_attr(node, 'end')) ?? begin;
      (isBg ? background : main).add(
        TimedSyllable(
          text: isBg ? _stripBgParens(text) : text,
          startMs: begin,
          endMs: end < begin ? begin : end,
        ),
      );
    }
  }

  /// Background vocals are usually written as "(ooh" ... "yeah)"; the
  /// renderer already sets them apart, so the parens are just noise.
  static String _stripBgParens(String text) =>
      text.replaceAll(RegExp(r'^\(|\)(?=\s*$)'), '');

  /// Line text excluding any background-vocal spans.
  static String _ownText(XmlElement p) {
    final buffer = StringBuffer();
    for (final node in p.children) {
      if (node is XmlElement) {
        if (_attr(node, 'role') == 'x-bg') continue;
        buffer.write(node.innerText);
      } else if (node is XmlText) {
        buffer.write(node.value);
      }
    }
    return buffer.toString();
  }

  static String? _attr(XmlElement e, String local) {
    for (final a in e.attributes) {
      if (a.name.local == local) return a.value;
    }
    return null;
  }

  /// TTML clock values: `12.345`, `1:02.345`, `01:02:03.4`, or offset form
  /// with a unit (`12.3s`, `450ms`, `1.5m`, `0.1h`). Returns milliseconds.
  static int? parseTime(String? raw) {
    if (raw == null) return null;
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) return null;

    final unit = RegExp(r'^(\d+(?:\.\d+)?)(ms|s|m|h)$').firstMatch(value);
    if (unit != null) {
      final amount = double.parse(unit.group(1)!);
      const factors = {'ms': 1, 's': 1000, 'm': 60000, 'h': 3600000};
      return (amount * factors[unit.group(2)]!).round();
    }

    final parts = value.split(':');
    if (parts.length > 3) return null;
    var seconds = 0.0;
    for (final part in parts) {
      final n = double.tryParse(part);
      if (n == null) return null;
      seconds = seconds * 60 + n;
    }
    return (seconds * 1000).round();
  }
}
