import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:looper_player/core/utils/app_links.dart';
import 'package:looper_player/core/utils/logger_helper.dart';

import '../lyrics_formats/krc_lyrics_parser.dart';
import '../lyrics_formats/timed_lyrics.dart';
import 'lyrics_http.dart';
import 'lyrics_query.dart';

/// KuGou: word-timed "KRC" lyrics. Its catalogue reaches well beyond
/// Chinese music - it's the one source here that often has Indian songs.
///
/// Flow: song search -> the hit that is this recording -> its file hash ->
/// lyrics search by hash -> download -> decode.
class KuGouClient {
  /// KRC files are zlib data XORed with this key, after a `krc1` marker.
  static const List<int> _krcKey = [
    64, 71, 97, 119, 94, 50, 116, 71, 81, 54, 49, 45, 206, 210, 110, 105, //
  ];

  static Future<String?> fetch({
    required String title,
    required String artist,
    String album = '',
    int durationSeconds = 0,
  }) async {
    final cleanTitle = LyricsQuery.cleanTitle(title);
    try {
      final name = LyricsQuery.artistVariants(artist).last;
      final found = await _get(AppLinks.kugouSongSearchUrl, {
        'version': '10000',
        'plat': '0',
        'correct': '1',
        'pagesize': '10',
        'keyword': '$name $cleanTitle',
      });
      final songs = found?['data'] is Map
          ? (found!['data'] as Map)['info']
          : null;
      if (songs is! List) return null;

      var asked = 0;
      for (final song in songs.whereType<Map>()) {
        final length = song['duration'];
        final same =
            LyricsQuery.sameSong(
              wantTitle: cleanTitle,
              wantArtist: artist,
              title: '${song['songname']}',
              artists: ['${song['singername']}'],
            ) &&
            LyricsQuery.sameLength(
              length is num ? length : null,
              durationSeconds,
            );
        final hash = song['hash'];
        if (!same || hash is! String || hash.isEmpty) continue;
        if (asked++ == 2) break;

        final lrc = await _lyricsFor(hash, cleanTitle, durationSeconds);
        if (lrc != null) return lrc;
      }
    } catch (e) {
      LyricsHttp.failed();
      LoggerHelper.write('KuGouClient: lookup failed ($e)');
    }
    return null;
  }

  static Future<String?> _lyricsFor(
    String hash,
    String title,
    int durationSeconds,
  ) async {
    final found = await _get('${AppLinks.kugouLyricsBase}/search', {
      'ver': '1',
      'man': 'yes',
      'client': 'mobi',
      'hash': hash,
    });
    final candidates = found?['candidates'];
    if (candidates is! List) return null;

    for (final candidate in candidates.whereType<Map>().take(2)) {
      final length = candidate['duration'];
      if (!LyricsQuery.sameLength(
        length is num ? length / 1000 : null,
        durationSeconds,
      )) {
        continue;
      }
      final file = await _get('${AppLinks.kugouLyricsBase}/download', {
        'ver': '1',
        'client': 'pc',
        'fmt': 'krc',
        'charset': 'utf8',
        'id': '${candidate['id']}',
        'accesskey': '${candidate['accesskey']}',
      });
      final content = file?['content'];
      if (content is! String || content.isEmpty) continue;

      final krc = decodeKrc(base64.decode(content));
      if (krc == null) continue;
      final lines = withoutCreditLines(
        KrcLyricsParser.parseKrc(krc),
        title: title,
      );
      final lrc = TimedLrcWriter.write(lines);
      if (lrc != null) return lrc;
    }
    return null;
  }

  /// The KRC text inside a downloaded file, or null when it isn't one.
  static String? decodeKrc(List<int> file) {
    if (file.length <= 4 || String.fromCharCodes(file.take(4)) != 'krc1') {
      return null;
    }
    final packed = [
      for (var i = 4; i < file.length; i++)
        file[i] ^ _krcKey[(i - 4) % _krcKey.length],
    ];
    return utf8.decode(zlib.decode(packed), allowMalformed: true);
  }

  static Future<Map?> _get(String url, Map<String, String> params) async {
    // Spaces as %20: KuGou's search reads the `+` that Uri's own query
    // encoding writes as a literal plus, and finds remixes instead.
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final response = await http
        .get(Uri.parse('$url?$query'), headers: LyricsHttp.browserHeaders)
        .timeout(LyricsHttp.timeout);
    if (!LyricsHttp.ok(response.statusCode)) return null;
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    return body is Map ? body : null;
  }
}
