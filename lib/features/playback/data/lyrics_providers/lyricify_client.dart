import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:looper_player/core/utils/app_links.dart';
import 'package:looper_player/core/utils/logger_helper.dart';

import '../lyrics_formats/lyricify_lyrics_parser.dart';
import '../lyrics_formats/timed_lyrics.dart';
import 'lyrics_http.dart';
import 'lyrics_query.dart';
import 'musicbrainz_isrc.dart';

/// Lyricify: line- or syllable-timed lyrics keyed by ISRC.
///
/// Flow: ISRCs for the song (MusicBrainz, which checks the recording's
/// length; else credits.fm, which is slow but knows more Indian releases)
/// -> Lyricify's lyrics for the first ISRC it has.
class LyricifyClient {
  static final Random _random = Random();

  /// credits.fm takes 7-10 s to answer.
  static const Duration _creditsTimeout = Duration(seconds: 12);

  static Future<String?> fetch({
    required String title,
    required String artist,
    String album = '',
    int durationSeconds = 0,
  }) async {
    final cleanTitle = LyricsQuery.cleanTitle(title);
    final artists = LyricsQuery.artistVariants(artist);
    try {
      var isrcs = await MusicBrainzIsrc.find(
        title: cleanTitle,
        artists: artists,
        durationSeconds: durationSeconds,
      );
      if (isrcs.isEmpty) {
        final isrc = await _isrcFromCredits(cleanTitle, artists.last);
        if (isrc != null) isrcs = [isrc];
      }

      for (final isrc in isrcs.take(3)) {
        final lines = await _lyricsFor(isrc);
        if (lines == null || !fitsDuration(lines, durationSeconds)) continue;
        final lrc = TimedLrcWriter.write(
          withoutCreditLines(lines, title: cleanTitle),
        );
        if (lrc != null) return lrc;
      }
    } catch (e) {
      LyricsHttp.failed();
      LoggerHelper.write('LyricifyClient: lookup failed ($e)');
    }
    return null;
  }

  static Future<List<TimedLyricLine>?> _lyricsFor(String isrc) async {
    final response = await http
        .get(
          Uri.parse(AppLinks.lyricifyApiUrl).replace(
            queryParameters: {
              // The API wants some user name; a random one, as its other
              // open-source clients send.
              'username': 'user${100000 + _random.nextInt(900000)}',
              'isrc': base64.encode(utf8.encode(isrc)),
            },
          ),
          headers: LyricsHttp.browserHeaders,
        )
        .timeout(LyricsHttp.timeout);
    if (!LyricsHttp.ok(response.statusCode)) return null;
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (body is! Map || body['isInstrumental'] == true) return null;
    final text = body['text'];
    if (text is! String || text.isEmpty) return null;
    final offset = body['offset'];
    final lines = LyricifyLyricsParser.parse(
      text,
      offsetMs: offset is num ? offset.toInt() : 0,
    );
    return lines.isEmpty ? null : lines;
  }

  static Future<String?> _isrcFromCredits(String title, String artist) async {
    if (artist.toLowerCase() == 'unknown artist') return null;
    final response = await http
        .post(
          Uri.parse(AppLinks.creditsFmResolveUrl),
          headers: {...LyricsHttp.headers, 'Content-Type': 'application/json'},
          body: jsonEncode({'name': title, 'artist': artist}),
        )
        .timeout(_creditsTimeout);
    if (!LyricsHttp.ok(response.statusCode)) return null;
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (body is! Map || body['match_status'] != 'matched') return null;
    // It matches loosely; only trust a hit with the same title.
    if (LyricsQuery.key('${body['recording_title']}') !=
        LyricsQuery.key(title)) {
      return null;
    }
    final isrc = body['isrc'];
    return isrc is String && isrc.isNotEmpty ? isrc : null;
  }
}
