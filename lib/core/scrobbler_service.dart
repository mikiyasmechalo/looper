import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/core/logger_helper.dart';
import 'package:looper_player/features/library/domain/models/models.dart';

class ScrobblerService {
  ScrobblerService._();
  static final ScrobblerService instance = ScrobblerService._();

  static const String defaultLastFmApiKey = '2a7a4f91ef380bba3b51e59275a593ca';
  static const String defaultLastFmSecret = '62fa8c13f63116e0be5b8ea0e8082dd6';

  final List<Map<String, dynamic>> _offlineQueue = [];
  bool _isProcessingQueue = false;

  /// Generate MD5 API signature for Last.fm API calls.
  String _generateLastFmSignature(Map<String, String> params, String secret) {
    final sortedKeys = params.keys.toList()..sort();
    final buffer = StringBuffer();
    for (final key in sortedKeys) {
      if (key == 'format' || key == 'callback') continue;
      buffer.write(key);
      buffer.write(params[key]);
    }
    buffer.write(secret);
    return md5.convert(utf8.encode(buffer.toString())).toString();
  }

  /// Sends "Now Playing" notification to enabled services (Last.fm & ListenBrainz).
  Future<void> updateNowPlaying({
    required Song song,
    required AppSettings settings,
  }) async {
    final title = song.title.trim();
    final artist = song.artist?.trim() ?? 'Unknown Artist';
    final album = song.album?.trim();

    if (title.isEmpty) return;

    // 1. Last.fm Now Playing
    if (settings.enableLastFmScrobbling && settings.lastFmSessionKey.isNotEmpty) {
      _sendLastFmNowPlaying(
        title: title,
        artist: artist,
        album: album,
        sessionKey: settings.lastFmSessionKey,
        apiKey: settings.lastFmApiKey.isNotEmpty ? settings.lastFmApiKey : defaultLastFmApiKey,
        secret: settings.lastFmSecret.isNotEmpty ? settings.lastFmSecret : defaultLastFmSecret,
      );
    }

    // 2. ListenBrainz Now Playing
    if (settings.enableListenBrainzScrobbling && settings.listenBrainzUserToken.isNotEmpty) {
      _sendListenBrainzNowPlaying(
        title: title,
        artist: artist,
        album: album,
        userToken: settings.listenBrainzUserToken,
      );
    }
  }

  /// Submits completed scrobble to Last.fm & ListenBrainz and records PlaybackHistoryEntry.
  Future<void> scrobble({
    required Song song,
    required AppSettings settings,
    required DateTime playTimestamp,
    required int listenedMs,
  }) async {
    final title = song.title.trim();
    final artist = song.artist?.trim() ?? 'Unknown Artist';
    final album = song.album?.trim();
    final genre = song.genre?.trim();
    final durationMs = song.duration ?? listenedMs;

    if (title.isEmpty) return;

    // 1. Save to local database playback history
    try {
      final entry = PlaybackHistoryEntry()
        ..timestamp = playTimestamp
        ..songPath = song.path
        ..title = title
        ..artist = artist
        ..album = album
        ..genre = genre
        ..durationMs = durationMs
        ..listenedMs = listenedMs
        ..artPath = song.artPath;

      await DbService.isar.writeTxn(() async {
        await DbService.isar.playbackHistoryEntrys.put(entry);
      });
      LoggerHelper.write('ScrobblerService: Recorded playback history entry for "$title" by $artist');
    } catch (e) {
      LoggerHelper.write('ScrobblerService: Error recording history entry: $e');
    }

    final timestampSec = (playTimestamp.millisecondsSinceEpoch / 1000).round();

    // 2. Last.fm Scrobble
    if (settings.enableLastFmScrobbling && settings.lastFmSessionKey.isNotEmpty) {
      _sendLastFmScrobble(
        title: title,
        artist: artist,
        album: album,
        timestampSec: timestampSec,
        sessionKey: settings.lastFmSessionKey,
        apiKey: settings.lastFmApiKey.isNotEmpty ? settings.lastFmApiKey : defaultLastFmApiKey,
        secret: settings.lastFmSecret.isNotEmpty ? settings.lastFmSecret : defaultLastFmSecret,
      );
    }

    // 3. ListenBrainz Scrobble
    if (settings.enableListenBrainzScrobbling && settings.listenBrainzUserToken.isNotEmpty) {
      _sendListenBrainzScrobble(
        title: title,
        artist: artist,
        album: album,
        timestampSec: timestampSec,
        userToken: settings.listenBrainzUserToken,
      );
    }

    // Process queued offline scrobbles
    _processOfflineQueue(settings);
  }

  Future<void> _sendLastFmNowPlaying({
    required String title,
    required String artist,
    required String? album,
    required String sessionKey,
    required String apiKey,
    required String secret,
  }) async {
    try {
      final params = <String, String>{
        'method': 'track.updateNowPlaying',
        'artist': artist,
        'track': title,
        if (album != null && album.isNotEmpty) 'album': album,
        'api_key': apiKey,
        'sk': sessionKey,
      };

      final apiSig = _generateLastFmSignature(params, secret);
      params['api_sig'] = apiSig;
      params['format'] = 'json';

      final response = await http.post(
        Uri.parse('https://ws.audioscrobbler.com/2.0/'),
        body: params,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        LoggerHelper.write('Last.fm Now Playing updated: $title by $artist');
      } else {
        LoggerHelper.write('Last.fm Now Playing error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      LoggerHelper.write('Last.fm Now Playing network error: $e');
    }
  }

  Future<void> _sendLastFmScrobble({
    required String title,
    required String artist,
    required String? album,
    required int timestampSec,
    required String sessionKey,
    required String apiKey,
    required String secret,
  }) async {
    try {
      final params = <String, String>{
        'method': 'track.scrobble',
        'artist': artist,
        'track': title,
        'timestamp': timestampSec.toString(),
        if (album != null && album.isNotEmpty) 'album': album,
        'api_key': apiKey,
        'sk': sessionKey,
      };

      final apiSig = _generateLastFmSignature(params, secret);
      params['api_sig'] = apiSig;
      params['format'] = 'json';

      final response = await http.post(
        Uri.parse('https://ws.audioscrobbler.com/2.0/'),
        body: params,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        LoggerHelper.write('Last.fm Scrobble success: $title by $artist');
      } else {
        LoggerHelper.write('Last.fm Scrobble error (${response.statusCode}): ${response.body}');
        _offlineQueue.add({
          'type': 'lastfm',
          'title': title,
          'artist': artist,
          'album': album,
          'timestamp': timestampSec,
        });
      }
    } catch (e) {
      LoggerHelper.write('Last.fm Scrobble network error, caching offline: $e');
      _offlineQueue.add({
        'type': 'lastfm',
        'title': title,
        'artist': artist,
        'album': album,
        'timestamp': timestampSec,
      });
    }
  }

  Future<void> _sendListenBrainzNowPlaying({
    required String title,
    required String artist,
    required String? album,
    required String userToken,
  }) async {
    try {
      final body = jsonEncode({
        'listen_type': 'playing_now',
        'payload': [
          {
            'track_metadata': {
              'artist_name': artist,
              'track_name': title,
              if (album != null && album.isNotEmpty) 'release_name': album,
            }
          }
        ]
      });

      final response = await http.post(
        Uri.parse('https://api.listenbrainz.org/1/submit-listens'),
        headers: {
          'Authorization': 'Token $userToken',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        LoggerHelper.write('ListenBrainz Now Playing updated: $title by $artist');
      } else {
        LoggerHelper.write('ListenBrainz Now Playing error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      LoggerHelper.write('ListenBrainz Now Playing network error: $e');
    }
  }

  Future<void> _sendListenBrainzScrobble({
    required String title,
    required String artist,
    required String? album,
    required int timestampSec,
    required String userToken,
  }) async {
    try {
      final body = jsonEncode({
        'listen_type': 'single',
        'payload': [
          {
            'listened_at': timestampSec,
            'track_metadata': {
              'artist_name': artist,
              'track_name': title,
              if (album != null && album.isNotEmpty) 'release_name': album,
            }
          }
        ]
      });

      final response = await http.post(
        Uri.parse('https://api.listenbrainz.org/1/submit-listens'),
        headers: {
          'Authorization': 'Token $userToken',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        LoggerHelper.write('ListenBrainz Scrobble success: $title by $artist');
      } else {
        LoggerHelper.write('ListenBrainz Scrobble error (${response.statusCode}): ${response.body}');
        _offlineQueue.add({
          'type': 'listenbrainz',
          'title': title,
          'artist': artist,
          'album': album,
          'timestamp': timestampSec,
        });
      }
    } catch (e) {
      LoggerHelper.write('ListenBrainz Scrobble network error, caching offline: $e');
      _offlineQueue.add({
        'type': 'listenbrainz',
        'title': title,
        'artist': artist,
        'album': album,
        'timestamp': timestampSec,
      });
    }
  }

  Future<void> _processOfflineQueue(AppSettings settings) async {
    if (_isProcessingQueue || _offlineQueue.isEmpty) return;
    _isProcessingQueue = true;

    final pending = List<Map<String, dynamic>>.from(_offlineQueue);
    _offlineQueue.clear();

    for (final item in pending) {
      if (item['type'] == 'lastfm' && settings.enableLastFmScrobbling) {
        await _sendLastFmScrobble(
          title: item['title'],
          artist: item['artist'],
          album: item['album'],
          timestampSec: item['timestamp'],
          sessionKey: settings.lastFmSessionKey,
          apiKey: settings.lastFmApiKey.isNotEmpty ? settings.lastFmApiKey : defaultLastFmApiKey,
          secret: settings.lastFmSecret.isNotEmpty ? settings.lastFmSecret : defaultLastFmSecret,
        );
      } else if (item['type'] == 'listenbrainz' && settings.enableListenBrainzScrobbling) {
        await _sendListenBrainzScrobble(
          title: item['title'],
          artist: item['artist'],
          album: item['album'],
          timestampSec: item['timestamp'],
          userToken: settings.listenBrainzUserToken,
        );
      }
    }

    _isProcessingQueue = false;
  }
}
