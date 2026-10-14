import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:looper_player/core/utils/app_links.dart';
import 'package:looper_player/core/utils/logger_helper.dart';

import '../lyrics_formats/kpoe_lyrics_parser.dart';
import '../lyrics_formats/timed_lyrics.dart';
import 'lyrics_http.dart';
import 'lyrics_query.dart';

/// LyricsPlus ("KPoe"): an aggregator over Apple Music, QQ Music,
/// Musixmatch, Spotify and Deezer lyrics, often with syllable timing.
/// Community mirrors serve the same API; the primary is tried first and
/// the mirrors only when it fails.
class LyricsPlusClient {
  /// Tries the cleaned title with each artist credit ([LyricsQuery]); per
  /// try, the primary mirror answers unless it's unreachable or rate
  /// limited. [album] isn't sent: local album tags make it miss songs it
  /// has (checked 2026-09-28 - any album other than Apple's gives 404).
  static Future<String?> fetch({
    required String title,
    required String artist,
    String album = '',
    int durationSeconds = 0,
  }) async {
    final cleanTitle = LyricsQuery.cleanTitle(title);
    String? lineSyncedFallback;

    for (final name in LyricsQuery.artistVariants(artist)) {
      final params = {
        'title': cleanTitle,
        'artist': name,
        if (durationSeconds > 0) 'duration': '$durationSeconds',
      };
      var answered = false;
      for (final base in AppLinks.lyricsPlusMirrors) {
        try {
          final uri = Uri.parse(
            '$base/v2/lyrics/get',
          ).replace(queryParameters: params);
          final response = await http
              .get(uri, headers: LyricsHttp.headers)
              .timeout(LyricsHttp.timeout);
          // 404: the mirrors share one catalogue - try the next credit.
          if (response.statusCode == 404) {
            answered = true;
            break;
          }
          if (response.statusCode != 200) continue;

          final payload = jsonDecode(utf8.decode(response.bodyBytes));
          answered = true;
          final lines = KpoeLyricsParser.parse(payload);
          final lrc = lines == null ? null : TimedLrcWriter.write(lines);
          if (lrc == null) break;
          if (lines!.any((l) => l.isWordSynced)) return lrc;
          lineSyncedFallback ??= lrc;
          break;
        } catch (e) {
          LoggerHelper.write('LyricsPlusClient: $base failed ($e)');
        }
      }
      // No mirror answered at all: the lookup didn't get through.
      if (!answered) LyricsHttp.failed();
      // A line-synced hit already means the song matched; another credit
      // won't turn it word-synced.
      if (lineSyncedFallback != null) break;
    }
    return lineSyncedFallback;
  }
}
