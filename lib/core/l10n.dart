import 'package:flutter/widgets.dart';
import 'package:looper_player/l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  /// Shorthand for `AppLocalizations.of(context)!`.
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Extension providing Looper Analyze translation strings.
extension AnalyzeL10n on AppLocalizations {
  String get looperAnalyze => 'Looper Analyze';
  String get noListeningHistoryYet => 'No listening history yet';
  String get noListeningHistoryYetDesc =>
      'Play a few songs and your personal report card — top songs, artists, albums and genres — will come to life here.';
  String analyzePlaysAndSongs(int plays, int songs) => '$plays plays • $songs songs';
  String get analyzeYourTopSong => 'Your #1 song';
  String get analyzeHighlights => 'Highlights';
  String get analyzePeakTime => 'Peak time';
  String get analyzeBusiestDay => 'Busiest day';
  String get analyzeTopGenre => 'Top genre';
  String get analyzeLibraryExplored => 'Library explored';
  String analyzeSongsOfTotal(int played, int total) => '$played of $total songs';
  String get analyzeCurrentStreak => 'Current streak';
  String get analyzeLongestStreak => 'Longest streak';
  String daysCount(int count) => count == 1 ? '1 day' : '$count days';
  String analyzeAvgPerDay(String avg) => '$avg per day on average';
  String get activityPattern => 'Activity Pattern';
  String get whenYouListenMost => 'When you listen most';
  String durationHoursMinutes(int h, int m) => '${h}h ${m}m';
  String durationMinutesOnly(int m) => '${m}m';
  String get dayPartMorning => 'Morning';
  String get dayPartAfternoon => 'Afternoon';
  String get dayPartEvening => 'Evening';
  String get dayPartNight => 'Night';
  String get dayPartMorningShort => 'Morn';
  String get dayPartAfternoonShort => 'Aft';
  String get dayPartEveningShort => 'Eve';
  String get dayPartNightShort => 'Night';
  String get otherGenre => 'Other';
  String get genreBreakdown => 'Genre Breakdown';
  String playsCount(int count) => count == 1 ? '1 play' : '$count plays';
  String get topAlbums => 'Top Albums';
  String get topArtists => 'Top Artists';
  String get topSongs => 'Top Songs';
  String get listeningTrend => 'Listening Trend';
  String get last30Days => 'Last 30 days';
  String get totalPlays => 'Total Plays';
  String get listeningTime => 'Listening Time';
}
