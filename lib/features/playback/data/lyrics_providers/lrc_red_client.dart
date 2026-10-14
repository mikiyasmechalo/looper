import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:looper_player/core/utils/app_links.dart';
import 'package:looper_player/core/utils/logger_helper.dart';

import '../lyrics_formats/timed_lyrics.dart';
import '../lyrics_formats/ttml_lyrics_parser.dart';
import 'lyrics_http.dart';
import 'lyrics_query.dart';
import 'musicbrainz_isrc.dart';

/// lrc.red: Apple-quality TTML lyrics (word timing, background vocals,
/// duets) keyed by ISRC.
///
/// Flow: find ISRCs -> `/s/{isrc}.ttml` -> parse -> enhanced LRC. ISRCs come
/// from, in order: the caller, lrc.red's `match.json` (hits whose duration
/// matches this file), MusicBrainz ([MusicBrainzIsrc] - lrc.red's search
/// endpoints can hang while its TTML files still load), then lrc.red's
/// `search.json`.
class LrcRedClient {
  /// A hit further than this from the local file's duration is treated as a
  /// different recording (radio edit, live, "Mixed" compilation cut...) and
  /// skipped - wrong-version lyrics drift out of sync within seconds.
  static const int _maxDurationDriftSec = 4;

  /// A missing TTML can hang instead of 404ing; real ones load in <1s.
  static const Duration _ttmlTimeout = Duration(seconds: 4);

  /// Set when lrc.red's search times out: it's skipped (MusicBrainz still
  /// supplies ISRCs) until then, instead of costing every song a timeout.
  static DateTime? _searchDownUntil;
  static const Duration _searchBackoff = Duration(minutes: 10);

  static bool get _searchUp =>
      _searchDownUntil == null || DateTime.now().isAfter(_searchDownUntil!);

  /// [album] is accepted for symmetry but not sent: local album tags
  /// ("Unknown Album", "... (Original Motion Picture Soundtrack)") make the
  /// lyrics APIs miss songs they have.
  static Future<String?> fetch({
    required String title,
    required String artist,
    String album = '',
    int durationSeconds = 0,
    String? isrc,
  }) async {
    final cleanTitle = LyricsQuery.cleanTitle(title);
    final artists = LyricsQuery.artistVariants(artist);
    final tried = <String>{};

    // One song has several ISRCs (single, album, clean...) and lrc.red may
    // hold only one, while a missing TTML hangs until the timeout - so the
    // best few are requested together, first in rank order that parses wins.
    Future<String?> fromIsrcs(Iterable<String> isrcs) async {
      final batch = isrcs.where(tried.add).take(3).toList();
      final results = await Future.wait(
        batch.map((candidate) async {
          try {
            return await _fetchTtml(candidate);
          } catch (e) {
            LoggerHelper.write('LrcRedClient: ttml $candidate failed ($e)');
            return null;
          }
        }),
      );
      return results.firstWhere((lrc) => lrc != null, orElse: () => null);
    }

    if (isrc != null && isrc.trim().isNotEmpty) {
      final direct = await fromIsrcs([isrc.trim()]);
      if (direct != null) return direct;
    }

    // lrc.red's own match, per artist credit.
    var searchDown = !_searchUp;
    if (_searchUp) {
      try {
        for (final name in artists.take(2)) {
          final hits = await _query('/match.json', {
            'track': cleanTitle,
            'artist': name,
            if (durationSeconds > 0) 'duration': '$durationSeconds',
          });
          final lrc = await fromIsrcs(
            _rankHits(_byArtist(hits, artists), durationSeconds),
          );
          if (lrc != null) return lrc;
        }
      } catch (e) {
        searchDown = true;
        _searchDownUntil = DateTime.now().add(_searchBackoff);
        LoggerHelper.write('LrcRedClient: match.json unavailable ($e)');
      }
    }

    final isrcs = await MusicBrainzIsrc.find(
      title: cleanTitle,
      artists: artists,
      durationSeconds: durationSeconds,
    );
    final viaMusicBrainz = await fromIsrcs(isrcs);
    if (viaMusicBrainz != null) return viaMusicBrainz;

    if (_searchUp) {
      try {
        final hits = await _query('/search.json', {
          'q': '${artists.length > 1 ? artists[1] : artist} $cleanTitle',
        });
        final lrc = await fromIsrcs(
          _rankHits(_byArtist(hits, artists), durationSeconds),
        );
        if (lrc != null) return lrc;
      } catch (e) {
        searchDown = true;
        _searchDownUntil = DateTime.now().add(_searchBackoff);
        LoggerHelper.write('LrcRedClient: search.json unavailable ($e)');
      }
    }
    // With lrc.red's search down, only MusicBrainz's ISRCs were tried:
    // when it knew none either, the song was never really looked up.
    if (searchDown && isrcs.isEmpty) LyricsHttp.failed();
    return null;
  }

  /// Drops hits credited to someone else entirely (covers and karaoke
  /// versions share title and length). Hits without an artist field stay.
  static List<Map> _byArtist(List<Map> hits, List<String> artists) {
    final wanted = artists.map(LyricsQuery.key).where((k) => k.isNotEmpty);
    return hits.where((hit) {
      final credit = hit['artist'] ?? hit['artistName'] ?? hit['artists'];
      if (credit == null) return true;
      final key = LyricsQuery.key(
        credit is List ? credit.join(' ') : '$credit',
      );
      return wanted.any((w) => key.contains(w) || w.contains(key));
    }).toList();
  }

  /// ISRCs of usable hits, best first. Hits keep lrc.red's own relevance
  /// order; with a known duration, only hits close to it survive, closest
  /// first.
  static List<String> _rankHits(List<Map> hits, int durationSeconds) {
    final candidates = hits
        .where((h) => h['isrc'] is String && (h['isrc'] as String).isNotEmpty)
        .toList();
    if (durationSeconds <= 0) {
      return candidates.map((h) => h['isrc'] as String).toList();
    }
    final scored = <(String, double)>[];
    for (final hit in candidates) {
      final d = (hit['duration'] as num?)?.toDouble();
      // Unknown duration: keep it, but behind every verified match.
      final drift = d == null
          ? _maxDurationDriftSec.toDouble()
          : (d - durationSeconds).abs();
      if (drift <= _maxDurationDriftSec) {
        scored.add((hit['isrc'] as String, drift));
      }
    }
    // Stable: equal drift keeps lrc.red's relevance order.
    final indexed = scored.asMap().entries.toList()
      ..sort((a, b) {
        final byDrift = a.value.$2.compareTo(b.value.$2);
        return byDrift != 0 ? byDrift : a.key.compareTo(b.key);
      });
    return indexed.map((e) => e.value.$1).toList();
  }

  static Future<List<Map>> _query(
    String path,
    Map<String, String> params,
  ) async {
    final uri = Uri.parse(
      '${AppLinks.lrcRedApiBase}$path',
    ).replace(queryParameters: params);
    final response = await http
        .get(uri, headers: LyricsHttp.headers)
        .timeout(LyricsHttp.timeout);
    if (!LyricsHttp.ok(response.statusCode)) return const [];
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    final hits = body is Map ? body['hits'] : null;
    return hits is List ? hits.whereType<Map>().toList() : const [];
  }

  static Future<String?> _fetchTtml(String isrc) async {
    final uri = Uri.parse(
      '${AppLinks.lrcRedApiBase}/s/${Uri.encodeComponent(isrc)}.ttml',
    );
    final response = await http
        .get(uri, headers: LyricsHttp.headers)
        .timeout(_ttmlTimeout);
    if (!LyricsHttp.ok(response.statusCode)) return null;
    final lines = TtmlLyricsParser.parse(utf8.decode(response.bodyBytes));
    if (lines == null) return null;
    return TimedLrcWriter.write(lines);
  }
}
