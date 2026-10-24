import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/battery_service.dart';
import '../../../core/db_service.dart';
import '../../../core/logger_helper.dart';
import '../../library/domain/models/models.dart';

import '../../library/data/artwork_downloader_service.dart';
import '../../../core/app_fonts.dart';
import '../../../core/discord_rpc_service.dart';
import '../../../core/windows_file_association_service.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  late Future<void> initialization;
  AppSettings _persistedSettings = AppSettings();
  bool _batterySaverActive = false;
  StreamSubscription<BatteryInfo>? _batterySubscription;

  bool get isBatterySaverActive => _batterySaverActive;
  AppSettings get persistedSettings => _persistedSettings;

  SettingsNotifier() : super(AppSettings()) {
    initialization = _loadSettings();
  }

  List<double> _createDefaultGains() {
    final list = List<double>.filled(48, 0.0);
    list[20] = -50.0; // Silence remove threshold dB
    list[22] = 0.2; // Crossfeed strength
    list[24] = -20.0; // Compressor threshold dB
    list[25] = 2.0; // Compressor ratio
    list[26] = 20.0; // Compressor attack ms
    list[27] = 250.0; // Compressor release ms
    list[29] = -24.0; // Loudnorm target
    list[31] = 2.5; // Stereo width factor
    list[34] = 1.0; // Pitch shift
    list[35] = 1.0; // Tempo shift
    list[36] = 0.0; // ReplayGain mode
    list[37] = 0.0; // ReplayGain preamp
    list[39] = 150.0; // Speech highpass
    list[40] = 4000.0; // Speech lowpass
    list[44] = 1.0; // Tone shelving enabled
    list[45] = 1.0; // Pitch/tempo enabled
    return list;
  }

  Future<void> _loadSettings() async {
    final settings = await DbService.isar.appSettings.get(0);
    if (settings != null) {
      // Migrate old settings record safely
      bool needsSave = false;
      if (settings.bgBrightness == 0.0) {
        settings.bgBrightness = 0.5;
        needsSave = true;
      }
      if (settings.bgOpacity == 0.0) {
        settings.bgOpacity = 0.3;
        needsSave = true;
      }
      // Since uninitialized booleans in old DB records default to false:
      // if keepBackgroundGradient is false, that is fine.
      // showHomeArtists defaults to true, but showHomeAlbums and showHomeGenres should default to false (off)!
      if (!settings.showHomeArtists &&
          !settings.showHomeAlbums &&
          !settings.showHomeGenres) {
        settings.showHomeArtists = true;
        settings.showHomeAlbums = false;
        settings.showHomeGenres = false;
        needsSave = true;
      }
      if (settings.homeSectionOrder.isEmpty) {
        settings.homeSectionOrder = [
          'recently_played',
          'quick_picks',
          'top_songs',
          'newly_added',
          'rediscover',
          'artists',
          'albums',
          'genres',
        ];
        needsSave = true;
      } else {
        // Migrate legacy entries: replace 'songs' with 'artists' and 'albums' if needed, and add missing sections
        final order = List<String>.from(settings.homeSectionOrder);
        bool orderChanged = false;
        if (order.contains('songs')) {
          final idx = order.indexOf('songs');
          order.removeAt(idx);
          if (!order.contains('artists')) order.insert(idx, 'artists');
          if (!order.contains('albums')) order.insert(idx + 1, 'albums');
          orderChanged = true;
        }
        final allSections = [
          'recently_played',
          'quick_picks',
          'top_songs',
          'newly_added',
          'rediscover',
          'artists',
          'albums',
          'genres',
        ];
        if (!order.contains('recently_played')) {
          order.insert(0, 'recently_played');
          orderChanged = true;
        } else if (order.indexOf('recently_played') == order.length - 1 && order.length > 1) {
          order.remove('recently_played');
          order.insert(0, 'recently_played');
          orderChanged = true;
        }
        // Ensure top_songs is placed right below quick_picks by default
        if (order.contains('quick_picks') && order.contains('top_songs')) {
          final qIdx = order.indexOf('quick_picks');
          final tIdx = order.indexOf('top_songs');
          if (tIdx != qIdx + 1) {
            order.removeAt(tIdx);
            final newQIdx = order.indexOf('quick_picks');
            order.insert(newQIdx + 1, 'top_songs');
            orderChanged = true;
          }
        }
        for (final sec in allSections) {
          if (!order.contains(sec)) {
            if (sec == 'top_songs' && order.contains('quick_picks')) {
              order.insert(order.indexOf('quick_picks') + 1, sec);
            } else {
              order.add(sec);
            }
            orderChanged = true;
          }
        }
        if (orderChanged) {
          settings.homeSectionOrder = order;
          needsSave = true;
        }
      }
      if (settings.sidebarItemOrder.isEmpty) {
        settings.sidebarItemOrder = [
          'now_playing',
          'songs',
          'albums',
          'artists',
          'playlists',
          'folders',
          'recently_played',
          'favorites',
          'queue',
          'genres',
          'lyrics',
          'analyze',
        ];
        needsSave = true;
      } else {
        final order = List<String>.from(settings.sidebarItemOrder);
        final defaultSidebarItems = [
          'now_playing',
          'songs',
          'albums',
          'artists',
          'playlists',
          'folders',
          'recently_played',
          'favorites',
          'queue',
          'genres',
          'lyrics',
          'analyze',
        ];
        bool sidebarChanged = false;
        for (final item in defaultSidebarItems) {
          if (!order.contains(item)) {
            order.add(item);
            sidebarChanged = true;
          }
        }
        if (sidebarChanged) {
          settings.sidebarItemOrder = order;
          needsSave = true;
        }
      }
      if (settings.homeDarkness.isNaN || (settings.homeDarkness == 0.0 && !settings.settingsV3)) {
        settings.homeDarkness = 0.72;
        needsSave = true;
      }
      if (settings.songsDarkness.isNaN || (settings.songsDarkness == 0.0 && !settings.settingsV3)) {
        settings.songsDarkness = 0.72;
        needsSave = true;
      }
      if (settings.libraryDarkness.isNaN || (settings.libraryDarkness == 0.0 && !settings.settingsV3)) {
        settings.libraryDarkness = 0.72;
        needsSave = true;
      }
      if (settings.musicDarkness.isNaN || (settings.musicDarkness == 0.0 && !settings.settingsV3)) {
        settings.musicDarkness = 0.62;
        needsSave = true;
      }
      if (settings.lyricsDarkness.isNaN || (settings.lyricsDarkness == 0.0 && !settings.settingsV3)) {
        settings.lyricsDarkness = 0.55;
        needsSave = true;
      }
      if (settings.seekBarStyleIndex == -9223372036854775808 || settings.seekBarStyleIndex < 0 || settings.seekBarStyleIndex > 2) {
        settings.seekBarStyleIndex = 1;
        needsSave = true;
      }
      if (settings.crossfadeMode == -9223372036854775808 || settings.crossfadeMode < 0 || settings.crossfadeMode > 2) {
        settings.crossfadeMode = 0;
        needsSave = true;
      }
      if (settings.crossfadeDuration == -9223372036854775808 || settings.crossfadeDuration < 0) {
        settings.crossfadeDuration = 0;
        needsSave = true;
      }
      if (settings.defaultMiniPlayerType == -9223372036854775808 || settings.defaultMiniPlayerType < 0 || settings.defaultMiniPlayerType > 1) {
        settings.defaultMiniPlayerType = 0;
        needsSave = true;
      }
      if (settings.playbackModeIndex == -9223372036854775808 || settings.playbackModeIndex < 0 || settings.playbackModeIndex > 2) {
        settings.playbackModeIndex = 0;
        needsSave = true;
      }
      if (settings.streamingQuality == -9223372036854775808 || settings.streamingQuality < 0 || settings.streamingQuality > 1) {
        settings.streamingQuality = 1;
        needsSave = true;
      }
      if (settings.sortStrategyIndex == -9223372036854775808 || settings.sortStrategyIndex < 0) {
        settings.sortStrategyIndex = 0;
        needsSave = true;
      }
      if (settings.albumSortOptionIndex == -9223372036854775808 || settings.albumSortOptionIndex < 0) {
        settings.albumSortOptionIndex = 0;
        needsSave = true;
      }
      if (settings.artistSortOptionIndex == -9223372036854775808 || settings.artistSortOptionIndex < 0) {
        settings.artistSortOptionIndex = 0;
        needsSave = true;
      }
      if (settings.genreSortOptionIndex == -9223372036854775808 || settings.genreSortOptionIndex < 0) {
        settings.genreSortOptionIndex = 0;
        needsSave = true;
      }
      if (settings.collectionSortOptionIndex == -9223372036854775808 || settings.collectionSortOptionIndex < 0) {
        settings.collectionSortOptionIndex = 0;
        needsSave = true;
      }
      if (settings.albumDetailSortOptionIndex == -9223372036854775808 || settings.albumDetailSortOptionIndex < 0) {
        settings.albumDetailSortOptionIndex = 0;
        needsSave = true;
      }
      if (settings.artistDetailSortOptionIndex == -9223372036854775808 || settings.artistDetailSortOptionIndex < 0) {
        settings.artistDetailSortOptionIndex = 1;
        needsSave = true;
      }
      if (settings.playlistDetailSortOptionIndex == -9223372036854775808 || settings.playlistDetailSortOptionIndex < 0) {
        settings.playlistDetailSortOptionIndex = 0;
        needsSave = true;
      }
      if (settings.scrobbleThresholdPercent < 20 || settings.scrobbleThresholdPercent > 90) {
        settings.scrobbleThresholdPercent = 50;
        needsSave = true;
      }
      if (!settings.settingsV2) {
        settings.showQualityBadge = true;
        settings.enablePlayerGradient = true;
        settings.settingsV2 = true;
        needsSave = true;
      }
      if (!settings.settingsV3) {
        settings.dynamicLyrics = false;
        settings.blurredArtworkForLyrics = true;
        settings.settingsV3 = true;
        needsSave = true;
      }
      if (!settings.settingsV4) {
        settings.enableUpdateNotifications = true;
        settings.settingsV4 = true;
        needsSave = true;
      }
      if (!settings.settingsV5) {
        settings.enableTaskbarControls = true;
        settings.settingsV5 = true;
        needsSave = true;
      }
      if (!settings.settingsV6) {
        settings.enableDynamicTheming = true;
        settings.disableBlur = false;
        settings.settingsV6 = true;
        needsSave = true;
      }
      if (!settings.settingsV7) {
        settings.disableSquiggle = true;
        settings.disableAnimatedDuration = true;
        settings.fullscreenVisualizerEnabled = false;
        settings.seekBarStyleIndex = 1;
        settings.settingsV7 = true;
        needsSave = true;
      }
      if (!settings.autoLyricsFallbackMigrated) {
        settings.autoLyricsFallback = true;
        settings.autoLyricsFallbackMigrated = true;
        needsSave = true;
      }
      if (settings.globalEqualizerGains.length < 48) {
        settings.globalEqualizerGains = _createDefaultGains();
        needsSave = true;
      }
      if (settings.batterySaverThreshold <= 0 || settings.batterySaverThreshold > 50) {
        settings.batterySaverThreshold = 20;
        needsSave = true;
      }
      if (needsSave) {
        await DbService.isar.writeTxn(() async {
          await DbService.isar.appSettings.put(settings);
        });
      }
      _persistedSettings = settings;
    } else {
      // Initialize default settings
      final defaultSettings = AppSettings()
        ..enableDynamicTheming = true
        ..disableBlur = false
        ..bgBrightness = 0.5
        ..bgOpacity = 0.3
        ..showHomeRecentlyPlayed = true
        ..showHomeQuickPicks = true
        ..showHomeTopSongs = true
        ..showHomeArtists = true
        ..showHomeAlbums = true
        ..showHomeGenres = true
        ..showHomeNewlyAdded = true
        ..showHomeRediscover = true
        ..homeSectionOrder = [
          'recently_played',
          'quick_picks',
          'top_songs',
          'artists',
          'albums',
          'genres',
          'newly_added',
          'rediscover',
        ]
        ..sidebarItemOrder = [
          'now_playing',
          'songs',
          'albums',
          'artists',
          'playlists',
          'folders',
          'recently_played',
          'favorites',
          'queue',
          'genres',
          'lyrics',
          'analyze',
        ]
        ..homeDarkness = 0.72
        ..songsDarkness = 0.72
        ..libraryDarkness = 0.72
        ..musicDarkness = 0.62
        ..lyricsDarkness = 0.55
        ..showQualityBadge = true
        ..enablePlayerGradient = true
        ..disableSquiggle = true
        ..disableAnimatedDuration = true
        ..fullscreenVisualizerEnabled = false
        ..seekBarStyleIndex = 1
        ..settingsV2 = true
        ..settingsV3 = true
        ..settingsV4 = true
        ..settingsV5 = true
        ..settingsV6 = true
        ..settingsV7 = true
        ..enableTaskbarControls = true
        ..enableUpdateNotifications = true
        ..dynamicLyrics = false
        ..blurredArtworkForLyrics = true
        ..showPerformanceOptimizer = false
        ..autoBatterySaver = true
        ..batterySaverThreshold = 20
        ..manualBatterySaver = false
        ..isBatterySaverActive = false
        ..equalizerEnabled = false
        ..enableAudioCache = true
        ..audioCacheSizeMB = 200
        ..audioCacheSecs = 120
        ..audioBackCacheSizeMB = 100
        ..persistQueue = true
        ..globalEqualizerGains = _createDefaultGains();
      await DbService.isar.writeTxn(() async {
        await DbService.isar.appSettings.put(defaultSettings);
      });
      _persistedSettings = defaultSettings;
    }

    int density = 2;
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/visualizer_density.txt');
      if (await file.exists()) {
        final content = await file.readAsString();
        final parsed = int.tryParse(content.trim());
        if (parsed != null && parsed >= 0 && parsed <= 3) {
          density = parsed;
        }
      }
    } catch (_) {}

    _persistedSettings.fullscreenVisualizerDensity = density;
    state = _clone(_persistedSettings);

    BatteryService.instance.initialize().then((info) {
      _evaluateBatterySaver(info);
    });
    _batterySubscription ??=
        BatteryService.instance.onBatteryInfoChanged.listen((info) {
      _evaluateBatterySaver(info);
    });
    _evaluateBatterySaver();

    _updateActiveFont();

    if (state.downloadArtwork && state.enableInternet) {
      ArtworkDownloaderService().downloadAllMissingArtworks();
    }
  }

  void _updateActiveFont([AppSettings? customState]) {
    final activeState = customState ?? state;
    AppFonts.activeFontFamily = activeState.useNewFont
        ? (activeState.customFontFamily ?? 'Jost')
        : 'DM Sans';
    AppFonts.appFontWeightDelta = activeState.useNewFont
        ? activeState.customFontWeightDelta
        : 0;
    AppFonts.lyricsFontWeightDelta = activeState.useNewFontLyrics
        ? activeState.customFontWeightLyricsDelta
        : 0;

    // Initialize Discord RPC
    DiscordRpcService.instance.initialize(enabled: activeState.enableDiscordRpc);
  }

  Future<void> updateLibraryFolders(List<String> folders) async {
    final newState = _clone(state)..libraryFolders = folders;
    await _save(newState);
  }

  Future<void> updateLanguage(String lang) async {
    final newState = _clone(state)..language = lang;
    await _save(newState);
  }

  Future<void> updateShuffle(bool shuffle) async {
    final newState = _clone(state)..shuffle = shuffle;
    await _save(newState);
  }

  Future<void> updateRepeatMode(int mode) async {
    final newState = _clone(state)..repeatMode = mode;
    await _save(newState);
  }

  Future<void> updateHomeSectionOrder(List<String> newOrder) async {
    final newState = _clone(state)..homeSectionOrder = newOrder;
    await _save(newState);
  }

  AppSettings _clone([AppSettings? input]) {
    final s = (input == null || identical(input, state))
        ? _persistedSettings
        : input;
    return AppSettings()
      ..id = s.id
      ..libraryFolders = List.from(s.libraryFolders)
      ..lastPlayedSongId = s.lastPlayedSongId
      ..lastQueueSongIds = List.from(s.lastQueueSongIds)
      ..lastQueueIndex = s.lastQueueIndex
      ..activeQueueName = s.activeQueueName
      ..volume = s.volume
      ..lastPositionMs = s.lastPositionMs
      ..shuffle = s.shuffle
      ..repeatMode = s.repeatMode
      ..language = s.language
      ..enableDynamicTheming = s.enableDynamicTheming
      ..darkTheme = s.darkTheme
      ..saveDynamicColor = s.saveDynamicColor
      ..dynamicLyrics = s.dynamicLyrics
      ..accentColor = s.accentColor
      ..audioFocus = s.audioFocus
      ..audioFocusRequestOnPlay = s.audioFocusRequestOnPlay
      ..audioFocusReleaseOnPause = s.audioFocusReleaseOnPause
      ..audioFocusStopOnOtherSession = s.audioFocusStopOnOtherSession
      ..audioFocusRestartOnGain = s.audioFocusRestartOnGain
      ..disableSquiggle = s.disableSquiggle
      ..disableAnimatedDuration = s.disableAnimatedDuration
      ..disableBlur = s.disableBlur
      ..enableInternet = s.enableInternet
      ..downloadArtwork = s.downloadArtwork
      ..keepBackgroundGradient = s.keepBackgroundGradient
      ..showQualityBadge = s.showQualityBadge
      ..enablePlayerGradient = s.enablePlayerGradient
      ..settingsV2 = s.settingsV2
      ..settingsV3 = s.settingsV3
      ..settingsV4 = s.settingsV4
      ..settingsV5 = s.settingsV5
      ..settingsV6 = s.settingsV6
      ..settingsV7 = s.settingsV7
      ..blurredArtworkForLyrics = s.blurredArtworkForLyrics
      ..customBackgroundImagePath = s.customBackgroundImagePath
      ..bgBrightness = s.bgBrightness
      ..bgOpacity = s.bgOpacity
      ..showHomeRecentlyPlayed = s.showHomeRecentlyPlayed
      ..showHomeQuickPicks = s.showHomeQuickPicks
      ..showHomeTopSongs = s.showHomeTopSongs
      ..showHomeArtists = s.showHomeArtists
      ..showHomeAlbums = s.showHomeAlbums
      ..showHomeGenres = s.showHomeGenres
      ..showHomeNewlyAdded = s.showHomeNewlyAdded
      ..showHomeRediscover = s.showHomeRediscover
      ..homeSectionOrder = List.from(
        s.homeSectionOrder.isEmpty
            ? [
                'recently_played',
                'quick_picks',
                'top_songs',
                'artists',
                'albums',
                'genres',
                'newly_added',
                'rediscover',
              ]
            : s.homeSectionOrder,
      )
      ..enableSlideGesture = s.enableSlideGesture
      ..stopOnTaskRemoved = s.stopOnTaskRemoved
      ..persistQueue = s.persistQueue
      ..minimizeToTray = s.minimizeToTray
      ..closeToTray = s.closeToTray
      ..nowPlayingFullscreen = s.nowPlayingFullscreen
      ..seekBarStyleIndex = s.seekBarStyleIndex
      ..uniformLyricsFontSize = s.uniformLyricsFontSize
      ..fullscreenVisualizerEnabled = s.fullscreenVisualizerEnabled
      ..fullscreenVisualizerDensity = s.fullscreenVisualizerDensity
      ..showFullscreenABLooper = s.showFullscreenABLooper
      ..showFullscreenSleepTimer = s.showFullscreenSleepTimer
      ..disableFullscreenBreathingEffect = s.disableFullscreenBreathingEffect
      ..gaplessPlayback = s.gaplessPlayback
      ..crossfadeDuration = s.crossfadeDuration
      ..crossfadeMode = s.crossfadeMode
      ..autoTrimSilence = s.autoTrimSilence
      ..enableGlobalHotkeys = s.enableGlobalHotkeys
      ..enableTaskbarControls = s.enableTaskbarControls
      ..showPlayedSongsInQueue = s.showPlayedSongsInQueue
      ..customShortcutsJson = s.customShortcutsJson
      ..defaultMiniPlayerType = s.defaultMiniPlayerType
      ..fadePlayPauseStop = s.fadePlayPauseStop
      ..playPauseStopFadeLength = s.playPauseStopFadeLength
      ..resumeAfterCall = s.resumeAfterCall
      ..pauseOnDuck = s.pauseOnDuck
      ..resumeOnBluetoothConnect = s.resumeOnBluetoothConnect
      ..resumeOnStart = s.resumeOnStart
      ..permanentAudioFocusChange = s.permanentAudioFocusChange
      ..dynamicColorActiveLyrics = s.dynamicColorActiveLyrics
      ..lyricsAlignment = s.lyricsAlignment
      ..dynamicAccentColor = s.dynamicAccentColor
      ..sortStrategyIndex = s.sortStrategyIndex
      ..sortAscending = s.sortAscending
      ..albumSortOptionIndex = s.albumSortOptionIndex
      ..artistSortOptionIndex = s.artistSortOptionIndex
      ..genreSortOptionIndex = s.genreSortOptionIndex
      ..collectionSortOptionIndex = s.collectionSortOptionIndex
      ..collectionSortAscending = s.collectionSortAscending
      ..albumDetailSortOptionIndex = s.albumDetailSortOptionIndex
      ..albumDetailSortAscending = s.albumDetailSortAscending
      ..artistDetailSortOptionIndex = s.artistDetailSortOptionIndex
      ..artistDetailSortAscending = s.artistDetailSortAscending
      ..playlistDetailSortOptionIndex = s.playlistDetailSortOptionIndex
      ..playlistDetailSortAscending = s.playlistDetailSortAscending
      ..homeDarkness = s.homeDarkness
      ..songsDarkness = s.songsDarkness
      ..libraryDarkness = s.libraryDarkness
      ..musicDarkness = s.musicDarkness
      ..lyricsDarkness = s.lyricsDarkness
      ..showPerformanceOptimizer = s.showPerformanceOptimizer
      ..autoBatterySaver = s.autoBatterySaver
      ..batterySaverThreshold = s.batterySaverThreshold
      ..manualBatterySaver = s.manualBatterySaver
      ..isBatterySaverActive = s.isBatterySaverActive
      ..useNewFont = s.useNewFont
      ..customFontFamily = s.customFontFamily
      ..customFontWeight = s.customFontWeight
      ..customFontWeightDelta = s.customFontWeightDelta
      ..useNewFontLyrics = s.useNewFontLyrics
      ..customFontFamilyLyrics = s.customFontFamilyLyrics
      ..customFontWeightLyrics = s.customFontWeightLyrics
      ..customFontWeightLyricsDelta = s.customFontWeightLyricsDelta
      ..activeLyricsFontWeightDelta = s.activeLyricsFontWeightDelta
      ..equalizerEnabled = s.equalizerEnabled
      ..globalEqualizerGains = List.from(
        s.globalEqualizerGains.isEmpty
            ? _createDefaultGains()
            : s.globalEqualizerGains,
      )
      ..enableAudioCache = s.enableAudioCache
      ..audioCacheSizeMB = s.audioCacheSizeMB
      ..audioCacheSecs = s.audioCacheSecs
      ..audioBackCacheSizeMB = s.audioBackCacheSizeMB
      ..exclusiveHardwareMode = s.exclusiveHardwareMode
      ..lyricsProvider = s.lyricsProvider
      ..autoLyricsFallback = s.autoLyricsFallback
      ..autoLyricsFallbackMigrated = s.autoLyricsFallbackMigrated
      ..lyricsProviderOrder = List.from(s.lyricsProviderOrder)
      ..lyricsProvidersOff = List.from(s.lyricsProvidersOff)
      ..lyricsProviderWordSyncMigrated = s.lyricsProviderWordSyncMigrated
      ..lyricsSyncStyle = s.lyricsSyncStyle
      ..lyricsOffsetMs = s.lyricsOffsetMs
      ..lyricsOffsetPerSongMigrated = s.lyricsOffsetPerSongMigrated
      ..lyricsOffsetEarlierMigrated = s.lyricsOffsetEarlierMigrated
      ..lyricsFontScale = s.lyricsFontScale
      ..activeLyricsIntensity = s.activeLyricsIntensity
      ..activeLyricsSoftColor = s.activeLyricsSoftColor
      ..ambientColorBackground = s.ambientColorBackground
      ..equalizerGlobalMode = s.equalizerGlobalMode
      ..firstTimeEqualizer = s.firstTimeEqualizer
      ..enableDiscordRpc = s.enableDiscordRpc
      ..enableLastFmScrobbling = s.enableLastFmScrobbling
      ..lastFmUsername = s.lastFmUsername
      ..lastFmSessionKey = s.lastFmSessionKey
      ..lastFmApiKey = s.lastFmApiKey
      ..lastFmSecret = s.lastFmSecret
      ..enableListenBrainzScrobbling = s.enableListenBrainzScrobbling
      ..listenBrainzUserToken = s.listenBrainzUserToken
      ..scrobbleThresholdPercent = s.scrobbleThresholdPercent
      ..enableWindowsFileAssociations = s.enableWindowsFileAssociations
      ..enableSmartPlaylists = s.enableSmartPlaylists
      ..albumCardStyleIndex = s.albumCardStyleIndex
      ..artistCardStyleIndex = s.artistCardStyleIndex
      ..albumGridColumns = s.albumGridColumns
      ..artistGridColumns = s.artistGridColumns
      ..songViewStyleIndex = s.songViewStyleIndex
      ..showTrayOnlyWhenMinimized = s.showTrayOnlyWhenMinimized
      ..showSidebarNowPlaying = s.showSidebarNowPlaying
      ..showSidebarSongs = s.showSidebarSongs
      ..showSidebarAlbums = s.showSidebarAlbums
      ..showSidebarArtists = s.showSidebarArtists
      ..showSidebarPlaylists = s.showSidebarPlaylists
      ..showSidebarRecentlyPlayed = s.showSidebarRecentlyPlayed
      ..showSidebarFavorites = s.showSidebarFavorites
      ..showSidebarQueue = s.showSidebarQueue
      ..showSidebarGenres = s.showSidebarGenres
      ..showSidebarFolders = s.showSidebarFolders
      ..showSidebarAnalyze = s.showSidebarAnalyze
      ..showSidebarLyrics = s.showSidebarLyrics
      ..sidebarItemOrder = List.from(
        s.sidebarItemOrder.isEmpty
            ? [
                'now_playing',
                'songs',
                'albums',
                'artists',
                'playlists',
                'folders',
                'recently_played',
                'favorites',
                'queue',
                'genres',
                'lyrics',
                'analyze',
              ]
            : s.sidebarItemOrder,
      )
      ..isSidebarCollapsed = s.isSidebarCollapsed
      ..moveNavButtonsToSidebar = s.moveNavButtonsToSidebar
      ..hasCompletedSidebarSetup = s.hasCompletedSidebarSetup
      ..showFullscreenTrayButton = s.showFullscreenTrayButton
      ..showSongDurationInLists = s.showSongDurationInLists
      ..folderViewTreeMode = s.folderViewTreeMode
      ..enableUpdateNotifications = s.enableUpdateNotifications
      ..skippedUpdateVersion = s.skippedUpdateVersion;
  }

  Future<void> updateShowTrayOnlyWhenMinimized(bool value) async {
    final newState = _clone(state)..showTrayOnlyWhenMinimized = value;
    await _save(newState);
  }

  Future<void> updateShowSidebarNowPlaying(bool value) async {
    final newState = _clone(state)..showSidebarNowPlaying = value;
    await _save(newState);
  }

  Future<void> updateShowSidebarSongs(bool value) async {
    final newState = _clone(state)..showSidebarSongs = value;
    await _save(newState);
  }

  Future<void> updateShowSidebarAlbums(bool value) async {
    final newState = _clone(state)..showSidebarAlbums = value;
    await _save(newState);
  }

  Future<void> updateShowSidebarArtists(bool value) async {
    final newState = _clone(state)..showSidebarArtists = value;
    await _save(newState);
  }

  Future<void> updateShowSidebarPlaylists(bool value) async {
    final newState = _clone(state)..showSidebarPlaylists = value;
    await _save(newState);
  }

  Future<void> updateShowSidebarRecentlyPlayed(bool value) async {
    final newState = _clone(state)..showSidebarRecentlyPlayed = value;
    await _save(newState);
  }

  Future<void> updateShowSidebarFavorites(bool value) async {
    final newState = _clone(state)..showSidebarFavorites = value;
    await _save(newState);
  }

  Future<void> updateShowSidebarQueue(bool value) async {
    final newState = _clone(state)..showSidebarQueue = value;
    await _save(newState);
  }

  Future<void> updateShowSidebarGenres(bool value) async {
    final newState = _clone(state)..showSidebarGenres = value;
    await _save(newState);
  }

  Future<void> updateShowSidebarFolders(bool value) async {
    final newState = _clone(state)..showSidebarFolders = value;
    await _save(newState);
  }

  Future<void> updateShowSidebarAnalyze(bool value) async {
    final newState = _clone(state)..showSidebarAnalyze = value;
    await _save(newState);
  }

  Future<void> updateShowSidebarLyrics(bool value) async {
    final newState = _clone(state)..showSidebarLyrics = value;
    await _save(newState);
  }

  Future<void> updateIsSidebarCollapsed(bool value) async {
    final newState = _clone(state)..isSidebarCollapsed = value;
    await _save(newState);
  }

  Future<void> updateMoveNavButtonsToSidebar(bool value) async {
    final newState = _clone(state)..moveNavButtonsToSidebar = value;
    await _save(newState);
  }

  Future<void> updateHasCompletedSidebarSetup(bool value) async {
    final newState = _clone(state)..hasCompletedSidebarSetup = value;
    await _save(newState);
  }

  Future<void> updateShowFullscreenTrayButton(bool value) async {
    final newState = _clone(state)..showFullscreenTrayButton = value;
    await _save(newState);
  }

  Future<void> updateShowSongDurationInLists(bool value) async {
    final newState = _clone(state)..showSongDurationInLists = value;
    await _save(newState);
  }

  Future<void> updateFolderViewTreeMode(bool value) async {
    final newState = _clone(state)..folderViewTreeMode = value;
    await _save(newState);
  }

  Future<void> updateAlbumCardStyle(int style) async {
    final newState = _clone(state)..albumCardStyleIndex = style;
    await _save(newState);
  }

  Future<void> updateArtistCardStyle(int style) async {
    final newState = _clone(state)..artistCardStyleIndex = style;
    await _save(newState);
  }

  Future<void> updateAlbumGridColumns(int cols) async {
    final newState = _clone(state)..albumGridColumns = cols;
    await _save(newState);
  }

  Future<void> updateArtistGridColumns(int cols) async {
    final newState = _clone(state)..artistGridColumns = cols;
    await _save(newState);
  }

  Future<void> updateSongViewStyle(int style) async {
    final newState = _clone(state)..songViewStyleIndex = style;
    await _save(newState);
  }

  Future<void> updateEnableSmartPlaylists(bool value) async {
    final newState = _clone(state)..enableSmartPlaylists = value;
    await _save(newState);
  }

  Future<void> toggleSmartPlaylists() async {
    await updateEnableSmartPlaylists(!state.enableSmartPlaylists);
  }

  Future<void> updateEnableWindowsFileAssociations(bool value) async {
    final newState = _clone(state)..enableWindowsFileAssociations = value;
    await _save(newState);
    if (Platform.isWindows) {
      if (value) {
        await WindowsFileAssociationService.register();
      } else {
        await WindowsFileAssociationService.unregister();
      }
    }
  }

  Future<void> updateEnableDiscordRpc(bool value) async {
    final newState = _clone(state)..enableDiscordRpc = value;
    await _save(newState);
    await DiscordRpcService.instance.setEnabled(value);
  }

  Future<void> updateEnableLastFmScrobbling(bool value) async {
    final newState = _clone(state)..enableLastFmScrobbling = value;
    await _save(newState);
  }

  Future<void> updateLastFmCredentials({
    String? username,
    String? sessionKey,
    String? apiKey,
    String? secret,
  }) async {
    final newState = _clone(state);
    if (username != null) newState.lastFmUsername = username;
    if (sessionKey != null) newState.lastFmSessionKey = sessionKey;
    if (apiKey != null) newState.lastFmApiKey = apiKey;
    if (secret != null) newState.lastFmSecret = secret;
    await _save(newState);
  }

  Future<void> updateEnableListenBrainzScrobbling(bool value) async {
    final newState = _clone(state)..enableListenBrainzScrobbling = value;
    await _save(newState);
  }

  Future<void> updateListenBrainzUserToken(String token) async {
    final newState = _clone(state)..listenBrainzUserToken = token;
    await _save(newState);
  }

  Future<void> updateScrobbleThresholdPercent(int value) async {
    final newState = _clone(state)..scrobbleThresholdPercent = value;
    await _save(newState);
  }

  Future<void> updateLyricsProvider(String value) async {
    final newState = _clone(state)..lyricsProvider = value;
    await _save(newState);
  }

  Future<void> updateLyricsProviderOrder(List<String> order) async {
    final newState = _clone(state)..lyricsProviderOrder = List.from(order);
    await _save(newState);
  }

  Future<void> setLyricsProviderEnabled(String id, bool enabled) async {
    final newState = _clone(state)
      ..lyricsProvidersOff = [
        ...state.lyricsProvidersOff.where((p) => p != id),
        if (!enabled) id,
      ];
    await _save(newState);
  }

  Future<void> updateAutoLyricsFallback(bool value) async {
    final newState = _clone(state)..autoLyricsFallback = value;
    await _save(newState);
  }

  Future<void> updateLyricsSyncStyle(String value) async {
    final newState = _clone(state)..lyricsSyncStyle = value;
    await _save(newState);
  }

  Future<void> updateLyricsFontScale(double value) async {
    final newState = _clone(state)..lyricsFontScale = value;
    await _save(newState);
  }

  Future<void> updateActiveLyricsIntensity(double value) async {
    final newState = _clone(state)..activeLyricsIntensity = value;
    await _save(newState);
  }

  Future<void> updateActiveLyricsSoftColor(bool value) async {
    final newState = _clone(state)..activeLyricsSoftColor = value;
    await _save(newState);
  }

  Future<void> updateAmbientColorBackground(bool value) async {
    final newState = _clone(state)..ambientColorBackground = value;
    await _save(newState);
  }

  Future<void> updateBlurredArtworkForLyrics(bool value) async {
    final newState = _clone(state)..blurredArtworkForLyrics = value;
    await _save(newState);
  }

  Future<void> updateShowQualityBadge(bool value) async {
    final newState = _clone(state)..showQualityBadge = value;
    await _save(newState);
  }

  Future<void> updateShowPerformanceOptimizer(bool value) async {
    final newState = _clone(state)..showPerformanceOptimizer = value;
    await _save(newState);
  }

  Future<void> updateEnablePlayerGradient(bool value) async {
    final newState = _clone(state);
    newState.enablePlayerGradient = value;
    if (!value) {
      newState.keepBackgroundGradient = false;
    }
    await _save(newState);
  }

  Future<void> updateFadePlayPauseStop(bool value) async {
    final newState = _clone(state)..fadePlayPauseStop = value;
    await _save(newState);
  }

  Future<void> updatePlayPauseStopFadeLength(int value) async {
    final newState = _clone(state)..playPauseStopFadeLength = value;
    await _save(newState);
  }

  Future<void> updatePersistQueue(bool value) async {
    final newState = _clone(state)..persistQueue = value;
    await _save(newState);
  }

  Future<void> updateMinimizeToTray(bool value) async {
    final newState = _clone(state)..minimizeToTray = value;
    await _save(newState);
  }

  Future<void> updateCloseToTray(bool value) async {
    final newState = _clone(state)..closeToTray = value;
    await _save(newState);
  }

  Future<void> updateNowPlayingFullscreen(bool value) async {
    final newState = _clone(state)..nowPlayingFullscreen = value;
    await _save(newState);
  }

  Future<void> updateSeekBarStyle(int value) async {
    final newState = _clone(state)..seekBarStyleIndex = value;
    await _save(newState);
  }

  Future<void> updateUniformLyricsFontSize(bool value) async {
    final newState = _clone(state)..uniformLyricsFontSize = value;
    await _save(newState);
  }

  Future<void> updateFullscreenVisualizerEnabled(bool value) async {
    final newState = _clone(state)..fullscreenVisualizerEnabled = value;
    await _save(newState);
  }

  Future<void> updateFullscreenVisualizerDensity(int value) async {
    final newState = _clone(state)..fullscreenVisualizerDensity = value;
    state = newState;
    _persistedSettings.fullscreenVisualizerDensity = value;
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/visualizer_density.txt');
      await file.writeAsString(value.toString());
    } catch (e) {
      LoggerHelper.write('Failed to persist visualizer density: $e');
    }
  }

  Future<void> updateShowFullscreenABLooper(bool value) async {
    final newState = _clone(state)..showFullscreenABLooper = value;
    await _save(newState);
  }

  Future<void> updateShowFullscreenSleepTimer(bool value) async {
    final newState = _clone(state)..showFullscreenSleepTimer = value;
    await _save(newState);
  }

  Future<void> updateDisableFullscreenBreathingEffect(bool value) async {
    final newState = _clone(state)..disableFullscreenBreathingEffect = value;
    await _save(newState);
  }

  Future<void> updateGaplessPlayback(bool value) async {
    final newState = _clone(state)..gaplessPlayback = value;
    await _save(newState);
  }

  Future<void> updateCrossfadeDuration(int seconds) async {
    final newState = _clone(state)..crossfadeDuration = seconds;
    await _save(newState);
  }

  Future<void> updateCrossfadeMode(int mode) async {
    final newState = _clone(state)..crossfadeMode = mode;
    await _save(newState);
  }

  Future<void> updateAutoTrimSilence(bool value) async {
    final newState = _clone(state)..autoTrimSilence = value;
    await _save(newState);
  }

  Future<void> updateEnableGlobalHotkeys(bool value) async {
    final newState = _clone(state)..enableGlobalHotkeys = value;
    await _save(newState);
  }

  Future<void> updateEnableTaskbarControls(bool value) async {
    final newState = _clone(state)..enableTaskbarControls = value;
    await _save(newState);
  }

  Future<void> updateShowPlayedSongsInQueue(bool value) async {
    final newState = _clone(state)..showPlayedSongsInQueue = value;
    await _save(newState);
  }

  Future<void> updateCustomShortcutsJson(String value) async {
    final newState = _clone(state)..customShortcutsJson = value;
    await _save(newState);
  }

  Future<void> updateDefaultMiniPlayerType(int value) async {
    final newState = _clone(state)..defaultMiniPlayerType = value;
    await _save(newState);
  }


  Future<void> updateDownloadArtwork(bool enabled) async {
    final newState = _clone(state)..downloadArtwork = enabled;
    await _save(newState);

    if (enabled && newState.enableInternet) {
      // Trigger full async scan to download all missing artworks
      ArtworkDownloaderService().downloadAllMissingArtworks();
    }
  }

  Future<void> updateKeepBackgroundGradient(bool value) async {
    final newState = _clone(state)..keepBackgroundGradient = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateCustomBackgroundImagePath(String? path) async {
    final newState = _clone(state)..customBackgroundImagePath = path;
    await _save(newState);
    state = newState;
  }

  Future<void> updateBgBrightness(double value) async {
    final newState = _clone(state)..bgBrightness = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateBgOpacity(double value) async {
    final newState = _clone(state)..bgOpacity = value;
    await _save(newState);
    state = newState;
  }

  int countEnabledHomeSections() {
    int count = 0;
    if (state.showHomeRecentlyPlayed) count++;
    if (state.showHomeQuickPicks) count++;
    if (state.showHomeTopSongs) count++;
    if (state.showHomeArtists) count++;
    if (state.showHomeAlbums) count++;
    if (state.showHomeGenres) count++;
    if (state.showHomeNewlyAdded) count++;
    if (state.showHomeRediscover) count++;
    return count;
  }

  bool canToggleHomeSectionOff() {
    return countEnabledHomeSections() > 2;
  }

  Future<bool> updateShowHomeRecentlyPlayed(bool value) async {
    if (!value && !canToggleHomeSectionOff()) return false;
    final newState = _clone(state)..showHomeRecentlyPlayed = value;
    await _save(newState);
    state = newState;
    return true;
  }

  Future<bool> updateShowHomeQuickPicks(bool value) async {
    if (!value && !canToggleHomeSectionOff()) return false;
    final newState = _clone(state)..showHomeQuickPicks = value;
    await _save(newState);
    state = newState;
    return true;
  }

  Future<bool> updateShowHomeTopSongs(bool value) async {
    if (!value && !canToggleHomeSectionOff()) return false;
    final newState = _clone(state)..showHomeTopSongs = value;
    await _save(newState);
    state = newState;
    return true;
  }

  Future<bool> updateShowHomeArtists(bool value) async {
    if (!value && !canToggleHomeSectionOff()) return false;
    final newState = _clone(state)..showHomeArtists = value;
    await _save(newState);
    state = newState;
    return true;
  }

  Future<bool> updateShowHomeAlbums(bool value) async {
    if (!value && !canToggleHomeSectionOff()) return false;
    final newState = _clone(state)..showHomeAlbums = value;
    await _save(newState);
    state = newState;
    return true;
  }

  Future<bool> updateShowHomeGenres(bool value) async {
    if (!value && !canToggleHomeSectionOff()) return false;
    final newState = _clone(state)..showHomeGenres = value;
    await _save(newState);
    state = newState;
    return true;
  }

  Future<bool> updateShowHomeNewlyAdded(bool value) async {
    if (!value && !canToggleHomeSectionOff()) return false;
    final newState = _clone(state)..showHomeNewlyAdded = value;
    await _save(newState);
    state = newState;
    return true;
  }

  Future<bool> updateShowHomeRediscover(bool value) async {
    if (!value && !canToggleHomeSectionOff()) return false;
    final newState = _clone(state)..showHomeRediscover = value;
    await _save(newState);
    state = newState;
    return true;
  }

  Future<void> resetHomeSectionOrder() async {
    final newState = _clone(state)
      ..homeSectionOrder = [
        'recently_played',
        'quick_picks',
        'top_songs',
        'newly_added',
        'rediscover',
        'artists',
        'albums',
        'genres',
      ]
      ..showHomeRecentlyPlayed = true
      ..showHomeQuickPicks = true
      ..showHomeTopSongs = true
      ..showHomeArtists = true
      ..showHomeAlbums = true
      ..showHomeGenres = true
      ..showHomeNewlyAdded = true
      ..showHomeRediscover = true;
    await _save(newState);
    state = newState;
  }

  Future<void> updateSidebarItemOrder(List<String> order) async {
    final newState = _clone(state)..sidebarItemOrder = List.from(order);
    await _save(newState);
    state = newState;
  }

  Future<void> resetSidebarItemOrder() async {
    final newState = _clone(state)
      ..sidebarItemOrder = [
        'now_playing',
        'songs',
        'albums',
        'artists',
        'playlists',
        'folders',
        'recently_played',
        'favorites',
        'queue',
        'genres',
        'lyrics',
        'analyze',
      ];
    await _save(newState);
    state = newState;
  }

  Future<void> updateDisableSquiggle(bool disabled) async {
    final newState = _clone(state)..disableSquiggle = disabled;
    await _save(newState);
  }

  Future<void> updateDisableAnimatedDuration(bool disabled) async {
    final newState = _clone(state)..disableAnimatedDuration = disabled;
    await _save(newState);
  }

  Future<void> updateDisableBlur(bool disabled) async {
    final newState = _clone(state)..disableBlur = disabled;
    await _save(newState);
  }

  Future<void> updateEnableInternet(bool enabled) async {
    final newState = _clone(state)..enableInternet = enabled;
    await _save(newState);
  }


  Future<void> updateDynamicTheming(bool enabled) async {
    final newState = _clone(state)..enableDynamicTheming = enabled;
    if (!enabled) {
      // If dynamic theming is disabled, ensure accent color resets to default Green (0xFF41C25E)
      // if the current color is not one of the manual selection options.
      const allowedColors = [
        0xFF41C25E,
        0xFFF7EAA6,
        0xFF448AFF,
      ]; // Green, Yellow, Blue Accent
      if (!allowedColors.contains(newState.accentColor)) {
        newState.accentColor = 0xFF41C25E;
      }
    }
    await _save(newState);
  }

  Future<void> updateDarkTheme(bool enabled) async {
    final newState = _clone(state)..darkTheme = enabled;
    await _save(newState);
  }

  Future<void> updateDynamicLyrics(bool enabled) async {
    final newState = _clone(state)..dynamicLyrics = enabled;
    await _save(newState);
  }

  Future<void> updateAccentColor(int color) async {
    final newState = _clone(state)..accentColor = color;
    await _save(newState);
  }

  Future<void> updateSaveDynamicColor(bool enabled) async {
    final newState = _clone(state)..saveDynamicColor = enabled;
    await _save(newState);
  }

  Future<void> updateLastPlayedSong(int? songId) async {
    final newState = _clone(state)..lastPlayedSongId = songId;
    await _save(newState);
  }

  Future<void> updateLastQueueState(
    List<int> queueIds,
    int index,
    int? lastSongId, {
    int? positionMs,
    String? activeQueueName,
  }) async {
    final newState = _clone(state)
      ..lastQueueSongIds = queueIds
      ..lastQueueIndex = index
      ..lastPlayedSongId = lastSongId
      ..lastPositionMs = positionMs ?? 0;
    if (activeQueueName != null) {
      newState.activeQueueName = activeQueueName;
    }
    await _save(newState);
  }

  Future<void> updateActiveQueueName(String name) async {
    final newState = _clone(state)..activeQueueName = name;
    await _save(newState);
  }

  Future<void> updateLastPosition(int positionMs) async {
    _persistedSettings.lastPositionMs = positionMs;
    state.lastPositionMs = positionMs;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(_persistedSettings);
    });
  }

  Future<void> updateVolume(double volume) async {
    final newState = _clone(state)..volume = volume;
    await _save(newState);
  }

  Future<void> updateDynamicColorActiveLyrics(bool enabled) async {
    final newState = _clone(state)..dynamicColorActiveLyrics = enabled;
    await _save(newState);
    state = newState;
  }

  Future<void> updateLyricsAlignment(String alignment) async {
    final newState = _clone(state)..lyricsAlignment = alignment;
    await _save(newState);
    state = newState;
  }

  Future<void> updateDynamicAccentColor(bool enabled) async {
    final newState = _clone(state)..dynamicAccentColor = enabled;
    await _save(newState);
    state = newState;
  }

  Future<void> updateSortStrategy(int strategyIndex) async {
    final newState = _clone(state)..sortStrategyIndex = strategyIndex;
    await _save(newState);
    state = newState;
  }

  Future<void> updateSortAscending(bool ascending) async {
    final newState = _clone(state)..sortAscending = ascending;
    await _save(newState);
    state = newState;
  }

  Future<void> updateAlbumSortOptionIndex(int index) async {
    final newState = _clone(state)..albumSortOptionIndex = index;
    await _save(newState);
    state = newState;
  }

  Future<void> updateArtistSortOptionIndex(int index) async {
    final newState = _clone(state)..artistSortOptionIndex = index;
    await _save(newState);
    state = newState;
  }

  Future<void> updateGenreSortOptionIndex(int index) async {
    final newState = _clone(state)..genreSortOptionIndex = index;
    await _save(newState);
    state = newState;
  }

  Future<void> updateCollectionSortOptionIndex(int index) async {
    final newState = _clone(state)..collectionSortOptionIndex = index;
    await _save(newState);
    state = newState;
  }

  Future<void> updateCollectionSortAscending(bool ascending) async {
    final newState = _clone(state)..collectionSortAscending = ascending;
    await _save(newState);
    state = newState;
  }

  Future<void> updateAlbumDetailSortOptionIndex(int index) async {
    final newState = _clone(state)..albumDetailSortOptionIndex = index;
    await _save(newState);
    state = newState;
  }

  Future<void> updateAlbumDetailSortAscending(bool ascending) async {
    final newState = _clone(state)..albumDetailSortAscending = ascending;
    await _save(newState);
    state = newState;
  }

  Future<void> updateArtistDetailSortOptionIndex(int index) async {
    final newState = _clone(state)..artistDetailSortOptionIndex = index;
    await _save(newState);
    state = newState;
  }

  Future<void> updateArtistDetailSortAscending(bool ascending) async {
    final newState = _clone(state)..artistDetailSortAscending = ascending;
    await _save(newState);
    state = newState;
  }

  Future<void> updatePlaylistDetailSortOptionIndex(int index) async {
    final newState = _clone(state)..playlistDetailSortOptionIndex = index;
    await _save(newState);
    state = newState;
  }

  Future<void> updatePlaylistDetailSortAscending(bool ascending) async {
    final newState = _clone(state)..playlistDetailSortAscending = ascending;
    await _save(newState);
    state = newState;
  }

  Future<void> updateHomeDarkness(double value) async {
    final newState = _clone(state)..homeDarkness = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateSongsDarkness(double value) async {
    final newState = _clone(state)..songsDarkness = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateLibraryDarkness(double value) async {
    final newState = _clone(state)..libraryDarkness = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateMusicDarkness(double value) async {
    final newState = _clone(state)..musicDarkness = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateLyricsDarkness(double value) async {
    final newState = _clone(state)..lyricsDarkness = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateUseNewFont(bool value) async {
    final newState = _clone(state)..useNewFont = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateCustomFontFamily(String value) async {
    final newState = _clone(state)..customFontFamily = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateCustomFontWeight(int value) async {
    final newState = _clone(state)..customFontWeight = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateCustomFontWeightDelta(int value) async {
    final newState = _clone(state)..customFontWeightDelta = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateUseNewFontLyrics(bool value) async {
    final newState = _clone(state)..useNewFontLyrics = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateCustomFontFamilyLyrics(String value) async {
    final newState = _clone(state)..customFontFamilyLyrics = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateCustomFontWeightLyrics(String value) async {
    final newState = _clone(state)..customFontWeightLyrics = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateCustomFontWeightLyricsDelta(int value) async {
    final newState = _clone(state)..customFontWeightLyricsDelta = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateActiveLyricsFontWeightDelta(int value) async {
    final newState = _clone(state)..activeLyricsFontWeightDelta = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateEqualizerEnabled(bool value) async {
    final newState = _clone(state)..equalizerEnabled = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateGlobalEqualizerGains(List<double> value) async {
    final newState = _clone(state)..globalEqualizerGains = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateEnableAudioCache(bool value) async {
    final newState = _clone(state)..enableAudioCache = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateAudioCacheSizeMB(int value) async {
    final newState = _clone(state)..audioCacheSizeMB = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateAudioCacheSecs(int value) async {
    final newState = _clone(state)..audioCacheSecs = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateAudioBackCacheSizeMB(int value) async {
    final newState = _clone(state)..audioBackCacheSizeMB = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateExclusiveHardwareMode(bool value) async {
    final newState = _clone(state)..exclusiveHardwareMode = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateEqualizerGlobalMode(bool value) async {
    final newState = _clone(state)..equalizerGlobalMode = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateFirstTimeEqualizer(bool value) async {
    final newState = _clone(state)..firstTimeEqualizer = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updatePlaybackMode(int mode) async {
    final newState = _clone(state)..playbackModeIndex = mode;
    await _save(newState);
    state = newState;
  }

  Future<void> updateEnableUpdateNotifications(bool value) async {
    final newState = _clone(state)..enableUpdateNotifications = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateSkippedUpdateVersion(String version) async {
    final newState = _clone(state)..skippedUpdateVersion = version;
    await _save(newState);
    state = newState;
  }

  Future<void> updateAutoBatterySaver(bool value) async {
    final newState = _clone(state)..autoBatterySaver = value;
    await _save(newState);
    _evaluateBatterySaver();
  }

  Future<void> updateBatterySaverThreshold(int value) async {
    final clamped = value.clamp(5, 50);
    final newState = _clone(state)..batterySaverThreshold = clamped;
    await _save(newState);
    _evaluateBatterySaver();
  }

  Future<void> updateManualBatterySaver(bool value) async {
    final newState = _clone(state)..manualBatterySaver = value;
    await _save(newState);
    _evaluateBatterySaver();
  }

  void _evaluateBatterySaver([BatteryInfo? info]) {
    final battery = info ?? BatteryService.instance.currentInfo;
    final isManual = _persistedSettings.manualBatterySaver;
    final isAuto = _persistedSettings.autoBatterySaver &&
        battery.isAvailable &&
        !battery.isCharging &&
        battery.level <= _persistedSettings.batterySaverThreshold;

    final shouldBeActive = isManual || isAuto;
    if (_batterySaverActive != shouldBeActive ||
        state.isBatterySaverActive != shouldBeActive) {
      _batterySaverActive = shouldBeActive;
      state = _persistedSettings;
    }
  }

  AppSettings _applyBatterySaverOverrides(AppSettings source) {
    return _clone(source)
      ..isBatterySaverActive = true
      ..enableDynamicTheming = false
      ..darkTheme = true
      ..disableBlur = true
      ..disableSquiggle = true
      ..dynamicLyrics = false
      ..blurredArtworkForLyrics = false
      ..disableAnimatedDuration = true
      ..keepBackgroundGradient = false
      ..enablePlayerGradient = false
      ..fullscreenVisualizerEnabled = false
      ..ambientColorBackground = false
      ..dynamicColorActiveLyrics = false
      ..dynamicAccentColor = false;
  }

  @override
  set state(AppSettings value) {
    if (_batterySaverActive) {
      super.state = _applyBatterySaverOverrides(value);
    } else {
      super.state = value;
    }
  }

  Future<void> _save(AppSettings settings) async {
    _persistedSettings = settings;
    state = settings;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(settings);
    });
  }

  @override
  void dispose() {
    _batterySubscription?.cancel();
    super.dispose();
  }
}
