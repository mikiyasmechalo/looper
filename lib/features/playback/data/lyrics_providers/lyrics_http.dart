import 'dart:async';

import 'package:looper_player/core/utils/app_links.dart';

/// Shared request settings for the community lyrics APIs (lrc.red,
/// LyricsPlus). They're free, volunteer-run services: identify the app
/// honestly so operators can reach out, and give up quickly instead of
/// stalling the fallback chain.
class LyricsHttp {
  static const Map<String, String> headers = {
    'User-Agent': 'LooperPlayer (${AppLinks.githubRepo})',
    'Accept': 'application/json, application/ttml+xml, */*',
  };

  /// For the commercial catalogues (NetEase, KuGou), which turn away
  /// clients that don't look like a browser.
  static const Map<String, String> browserHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
    'Accept': 'application/json, text/plain, */*',
  };

  static const Duration timeout = Duration(seconds: 6);

  static const Object _reportKey = #lyricsLookupReport;

  /// Runs one provider lookup so that the clients underneath can say it
  /// didn't get through ([failed]) - which a "no lyrics" answer must not be
  /// mistaken for: only a real "no" is remembered for the song.
  static Future<T> tracked<T>(
    LyricsLookupReport report,
    Future<T> Function() lookup,
  ) => runZoned(lookup, zoneValues: {_reportKey: report});

  /// Called by a client when its service couldn't be asked properly: a
  /// timeout, no network, a rate limit, a block.
  static void failed() {
    final report = Zone.current[_reportKey];
    if (report is LyricsLookupReport) report.failed = true;
  }

  /// Whether a response is a usable answer. Anything else is "no lyrics",
  /// except the statuses that mean the service turned the request away -
  /// those count as [failed].
  static bool ok(int statusCode) {
    if (statusCode == 200) return true;
    if (statusCode == 401 ||
        statusCode == 403 ||
        statusCode == 408 ||
        statusCode == 429 ||
        statusCode >= 500) {
      failed();
    }
    return false;
  }
}

/// What [LyricsHttp.tracked] learns about a lookup besides its answer.
class LyricsLookupReport {
  bool failed = false;
}
