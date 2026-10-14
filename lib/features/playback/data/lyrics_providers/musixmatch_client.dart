import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:looper_player/core/utils/app_links.dart';
import 'package:looper_player/core/utils/logger_helper.dart';

import '../lyrics_formats/richsync_lyrics_parser.dart';
import '../lyrics_formats/timed_lyrics.dart';
import 'lyrics_http.dart';
import 'lyrics_query.dart';

/// Musixmatch, through the API its own apps use: word-timed "richsync"
/// lyrics, else line-timed subtitles, else plain text.
///
/// Flow: a guest token (kept for the session) -> `track.search` -> the hit
/// that is this recording -> `macro.subtitles.get`, which answers with all
/// three kinds at once. Musixmatch throttles guests hard: requests are
/// spaced out, and a refused token pauses the provider instead of costing
/// every song a failed round trip.
class MusixmatchClient {
  static const String _appId = 'android-player-v1.0';
  static const Map<String, String> _headers = {
    'User-Agent': 'Dalvik/2.1.0 (Linux; U; Android 14)',
    'Cookie': 'AWSELB=0; AWSELBCORS=0',
    'Accept': 'application/json',
  };
  static const Duration _minGap = Duration(milliseconds: 500);
  static const Duration _backoff = Duration(minutes: 10);

  static String? _token;
  static DateTime? _pausedUntil;
  static DateTime _lastRequest = DateTime.fromMillisecondsSinceEpoch(0);

  static Future<String?> fetch({
    required String title,
    required String artist,
    String album = '',
    int durationSeconds = 0,
  }) async {
    if (_pausedUntil != null && DateTime.now().isBefore(_pausedUntil!)) {
      LyricsHttp.failed();
      return null;
    }
    final cleanTitle = LyricsQuery.cleanTitle(title);
    try {
      _token ??= _string(
        await _call('token.get', {'user_language': 'en'}),
        'user_token',
      );
      final token = _token;
      if (token == null) {
        LyricsHttp.failed();
        return null;
      }

      final found = await _call('track.search', {
        'page_size': '10',
        'page': '1',
        's_track_rating': 'desc',
        'q_track': cleanTitle,
        'q_artist': LyricsQuery.artistVariants(artist).last,
        if (durationSeconds > 0) 'q_duration': '$durationSeconds',
        'usertoken': token,
      });
      final tracks = found?['track_list'];
      if (tracks is! List) return null;

      for (final entry in tracks.whereType<Map>()) {
        final track = entry['track'];
        if (track is! Map) continue;
        final length = track['track_length'];
        final same =
            LyricsQuery.sameSong(
              wantTitle: cleanTitle,
              wantArtist: artist,
              title: '${track['track_name']}',
              artists: ['${track['artist_name']}'],
            ) &&
            LyricsQuery.sameLength(
              length is num ? length : null,
              durationSeconds,
            );
        if (!same || track['track_id'] == null) continue;

        // The first hit that is this song decides: its answer covers
        // every kind of lyrics Musixmatch has for it.
        return await _lyricsFor('${track['track_id']}', token);
      }
    } catch (e) {
      LyricsHttp.failed();
      LoggerHelper.write('MusixmatchClient: lookup failed ($e)');
    }
    return null;
  }

  static Future<String?> _lyricsFor(String trackId, String token) async {
    final body = await _call('macro.subtitles.get', {
      'namespace': 'lyrics_richsynched',
      'optional_calls': 'track.richsync',
      'subtitle_format': 'lrc',
      'track_id': trackId,
      'f_subtitle_length_max_deviation': '40',
      'usertoken': token,
    });
    final calls = body?['macro_calls'];
    if (calls is! Map) return null;
    Map? answer(String call) {
      final message = calls[call] is Map
          ? (calls[call] as Map)['message']
          : null;
      final inner = message is Map ? message['body'] : null;
      return inner is Map ? inner : null;
    }

    final richsync = answer('track.richsync.get')?['richsync'];
    if (richsync is Map && richsync['richsync_body'] is String) {
      final lines = RichsyncLyricsParser.parse(richsync['richsync_body']);
      final lrc = lines == null ? null : TimedLrcWriter.write(lines);
      if (lrc != null) return lrc;
    }

    final subtitles = answer('track.subtitles.get')?['subtitle_list'];
    if (subtitles is List && subtitles.isNotEmpty && subtitles.first is Map) {
      final subtitle = (subtitles.first as Map)['subtitle'];
      final lrc = subtitle is Map ? subtitle['subtitle_body'] : null;
      if (lrc is String && lrc.trim().isNotEmpty) return lrc.trim();
    }

    final lyrics = answer('track.lyrics.get')?['lyrics'];
    final plain = lyrics is Map ? lyrics['lyrics_body'] : null;
    return plain is String && plain.trim().isNotEmpty ? plain.trim() : null;
  }

  /// One API call, spaced [_minGap] after the previous one. Returns the
  /// answer's `message.body`, or null - and pauses the provider when the
  /// token was refused (401, usually a captcha demand).
  static Future<Map?> _call(String method, Map<String, String> params) async {
    final wait = _minGap - DateTime.now().difference(_lastRequest);
    if (wait > Duration.zero) await Future<void>.delayed(wait);
    _lastRequest = DateTime.now();

    final response = await http
        .get(
          Uri.parse('${AppLinks.musixmatchApiBase}/$method').replace(
            queryParameters: {
              ...params,
              'format': 'json',
              'app_id': _appId,
              't': '${DateTime.now().millisecondsSinceEpoch}',
            },
          ),
          headers: _headers,
        )
        .timeout(LyricsHttp.timeout);
    if (!LyricsHttp.ok(response.statusCode)) return null;

    final root = jsonDecode(utf8.decode(response.bodyBytes));
    final message = root is Map ? root['message'] : null;
    if (message is! Map) return null;
    final header = message['header'];
    final status = header is Map ? header['status_code'] : null;
    if (status == 401) {
      _token = null;
      _pausedUntil = DateTime.now().add(_backoff);
      LyricsHttp.failed();
      LoggerHelper.write('MusixmatchClient: token refused, pausing');
      return null;
    }
    // 402: the guest quota ran out - not an answer about this song.
    if (status == 402) LyricsHttp.failed();
    final body = message['body'];
    return status == 200 && body is Map ? body : null;
  }

  static String? _string(Map? map, String key) {
    final value = map?[key];
    return value is String && value.isNotEmpty ? value : null;
  }
}
