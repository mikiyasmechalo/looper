import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:looper_player/core/utils/app_links.dart';
import 'package:looper_player/core/utils/logger_helper.dart';

import '../lyrics_formats/timed_lyrics.dart';
import '../lyrics_formats/ttml_lyrics_parser.dart';
import 'lyrics_http.dart';
import 'lyrics_query.dart';

/// AMLL TTML DB: community-made, word-timed TTML lyrics (the database
/// behind Apple Music-like Lyrics), searched by title and artist.
///
/// Flow: `/search` -> the first hit that is this song -> `/get` its TTML.
/// The search gives no track length, so a hit is also checked against the
/// file's duration once its lyrics are parsed.
class AmllClient {
  static Future<String?> fetch({
    required String title,
    required String artist,
    String album = '',
    int durationSeconds = 0,
  }) async {
    final cleanTitle = LyricsQuery.cleanTitle(title);
    try {
      for (final name in LyricsQuery.artistVariants(artist, max: 2)) {
        final found = await _get('/search', {
          'musicName': cleanTitle,
          'artistName': name,
        });
        final items = found?['items'];
        if (items is! List) continue;

        for (final item in items.whereType<Map>().take(3)) {
          final titles = _strings(item['musicNames']);
          final same = titles.any(
            (t) => LyricsQuery.sameSong(
              wantTitle: cleanTitle,
              wantArtist: artist,
              title: t,
              artists: _strings(item['artistNames']),
            ),
          );
          if (!same || item['id'] == null) continue;

          final data = await _get('/get', {
            'id': '${item['id']}',
            'format': 'ttml',
          });
          final ttml = data?['lyrics'];
          if (ttml is! String || ttml.isEmpty) continue;
          final lines = TtmlLyricsParser.parse(ttml);
          if (lines == null || !fitsDuration(lines, durationSeconds)) continue;
          final lrc = TimedLrcWriter.write(lines);
          if (lrc != null) return lrc;
        }
        // The catalogue answered for this credit; another one won't differ.
        if (items.isNotEmpty) break;
      }
    } catch (e) {
      LyricsHttp.failed();
      LoggerHelper.write('AmllClient: lookup failed ($e)');
    }
    return null;
  }

  /// The `data` object of a 200 answer, else null.
  static Future<Map?> _get(String path, Map<String, String> params) async {
    final response = await http
        .get(
          Uri.parse(
            '${AppLinks.amllApiBase}$path',
          ).replace(queryParameters: params),
          headers: LyricsHttp.headers,
        )
        .timeout(LyricsHttp.timeout);
    if (!LyricsHttp.ok(response.statusCode)) return null;
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    return body is Map && body['data'] is Map ? body['data'] as Map : null;
  }

  static List<String> _strings(Object? list) =>
      list is List ? list.whereType<String>().toList() : const [];
}
