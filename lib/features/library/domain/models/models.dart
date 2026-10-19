import 'package:isar/isar.dart';

part 'models.g.dart';

@collection
class Song {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String path;

  late String title;

  @Index()
  String? artist;

  @Index()
  String? albumArtist;

  @Index()
  String? album;

  String? genre;
  int? duration; // In milliseconds
  int? trackNumber;
  int? trackTotal;
  int? discNumber;
  int? discTotal;
  int? lyricsOffsetMs;
  int? year;
  String? artPath;

  @Index()
  late DateTime dateAdded;

  int playCount = 0;
  @Index()
  DateTime? lastPlayed;
  bool isFavorite = false;
  String? lyrics;
  bool hasCustomEqualizer = false;
  List<double>? equalizerGains;

  // SpatialFlow Online Streaming fields
  bool isOnlineStream = false;
  String? streamUrl;
  String? youtubeId;
  String? onlineArtUrl;
  int? streamQuality; // 0: low, 1: high

  // Metadata for search
  @Index(type: IndexType.value, caseSensitive: false)
  List<String> get searchTerms => [
    title,
    artist ?? '',
    album ?? '',
    lyrics ?? '',
  ];
}

@collection
class Album {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  String? artist;
  String? artPath;
  int? year;

  @Index()
  late DateTime dateAdded;
}

@collection
class Artist {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  String? artPath;
  String? artistImageUrl;

  /// Local file paths of downloaded artist images. May contain several images
  /// (e.g. when the artist name includes collaborations like "A ft. B") which
  /// are rendered as a collage.
  List<String> artistImages = [];
}

@collection
class Playlist {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  late List<String> songPaths;
  late DateTime dateCreated;
  late DateTime dateModified;
}

@collection
class SavedQueue {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  late List<int> songIds;
  int currentIndex = 0;
  int positionMs = 0;
  bool isShuffle = false;
  late DateTime lastPlayed;
  bool isPermanent = false;
}

@collection
class AppSettings {
  Id id = 0; // Always use ID 0 for single settings object

  List<String> libraryFolders = [];
  int? lastPlayedSongId;
  List<int> lastQueueSongIds = [];
  int lastQueueIndex = -1;
  String activeQueueName = '';
  double volume = 1.0;
  int lastPositionMs = 0;
  bool shuffle = false;
  int repeatMode = 0; // 0: off, 1: one, 2: all
  String language = 'en';
  bool enableDynamicTheming = true;
  bool darkTheme = true;
  bool saveDynamicColor = true;
  bool dynamicLyrics = false;
  bool blurredArtworkForLyrics = true;
  int accentColor = 0xFF41C25E; // Default Green
  bool audioFocus = true;
  bool audioFocusRequestOnPlay = true;
  bool audioFocusReleaseOnPause = true;
  bool audioFocusStopOnOtherSession = true;
  bool audioFocusRestartOnGain = true;
  bool disableSquiggle = true;
  bool disableAnimatedDuration = true;
  bool disableBlur = false;
  bool enableInternet = true;
  bool downloadArtwork = false;
  bool keepBackgroundGradient = false;
  bool showQualityBadge = true;
  bool enablePlayerGradient = true;
  bool settingsV2 = false;
  bool settingsV3 = false;
  bool settingsV4 = false;
  bool settingsV5 = false;
  bool settingsV6 = false;
  bool settingsV7 = false;
  bool showPerformanceOptimizer = false;
  bool autoBatterySaver = true;
  int batterySaverThreshold = 20;
  bool manualBatterySaver = false;
  bool isBatterySaverActive = false;
  String? customBackgroundImagePath;
  double bgBrightness = 0.5;
  double bgOpacity = 0.3;
  bool showHomeArtists = true;
  bool showHomeAlbums = false;
  bool showHomeGenres = true;
  List<String> homeSectionOrder = [
    'quick_picks',
    'songs',
    'albums',
    'artists',
    'genres',
  ];
  bool enableSlideGesture = false;
  bool stopOnTaskRemoved = true;
  bool persistQueue = true;

  bool fadePlayPauseStop = true;
  int playPauseStopFadeLength = 150; // ms (10ms-1000ms)
  bool resumeAfterCall = true;
  bool pauseOnDuck = false;
  bool resumeOnBluetoothConnect = false;
  bool resumeOnStart = false;
  bool permanentAudioFocusChange = false;
  bool dynamicColorActiveLyrics = true;
  double activeLyricsIntensity = 0.0;
  bool activeLyricsSoftColor = false;
  bool ambientColorBackground = true;
  String lyricsAlignment = 'left'; // 'left', 'center', 'right'
  bool dynamicAccentColor = true;
  int sortStrategyIndex = 0;
  bool sortAscending = true;
  bool useAlbumArtistForArtists = true;
  int albumSortOptionIndex = 0;
  int artistSortOptionIndex = 0;
  int genreSortOptionIndex = 0;
  int collectionSortOptionIndex = 0;
  bool collectionSortAscending = true;
  int albumDetailSortOptionIndex = 0;
  bool albumDetailSortAscending = true;
  int artistDetailSortOptionIndex = 1;
  bool artistDetailSortAscending = true;
  int playlistDetailSortOptionIndex = 0;
  bool playlistDetailSortAscending = true;

  double homeDarkness = 0.62;
  double songsDarkness = 0.62;
  double libraryDarkness = 0.62;
  double musicDarkness = 0.62;
  double lyricsDarkness = 0.55;

  bool useNewFont = false;
  String customFontFamily = 'Jost';
  int customFontWeight = 400;
  int customFontWeightDelta = 0;
  bool useNewFontLyrics = false;
  String customFontFamilyLyrics = 'Sora';
  String customFontWeightLyrics = 'Normal';
  int customFontWeightLyricsDelta = 0;
  int activeLyricsFontWeightDelta = 0;
  bool equalizerEnabled = false;
  List<double> globalEqualizerGains = [];
  bool equalizerGlobalMode = true;
  bool firstTimeEqualizer = true;
  bool enableAudioCache = true;
  int audioCacheSizeMB = 200;
  int audioCacheSecs = 120;
  int audioBackCacheSizeMB = 100;
  bool exclusiveHardwareMode = false;
  String lyricsProvider = 'lrc.red';
  bool autoLyricsFallback = true;
  bool autoLyricsFallbackMigrated = false;
  List<String> lyricsProviderOrder = [];
  List<String> lyricsProvidersOff = [];
  bool lyricsProviderWordSyncMigrated = false;
  String lyricsSyncStyle = 'char';
  static const int defaultLyricsOffsetMs = 200;
  int lyricsOffsetMs = defaultLyricsOffsetMs;
  bool lyricsOffsetPerSongMigrated = false;
  bool lyricsOffsetEarlierMigrated = false;
  double lyricsFontScale = 1.0;

  // SpatialFlow Operational Mode & Network Streaming
  int playbackModeIndex = 0; // 0: hybrid, 1: localOnly, 2: onlineOnly
  int streamingQuality = 1; // 0: Low (128k), 1: High (256k)
  bool cacheOnlineStreams = true;

  // Desktop: system tray behaviors.
  bool minimizeToTray = false;
  bool closeToTray = false;
  bool showTrayOnlyWhenMinimized = true;

  // Sidebar navigation visibility settings
  bool showSidebarNowPlaying = true;
  bool showSidebarSongs = true;
  bool showSidebarAlbums = true;
  bool showSidebarArtists = true;
  bool showSidebarPlaylists = true;
  bool showSidebarRecentlyPlayed = true;
  bool showSidebarFavorites = true;
  bool showSidebarQueue = true;
  bool showSidebarGenres = true;
  bool showSidebarFolders = true;
  bool showSidebarAnalyze = false;

  // Folder view preferences
  bool folderViewTreeMode = false;

  // Desktop: open the now-playing view in true fullscreen (hides the OS
  // taskbar / title bar controls).
  bool nowPlayingFullscreen = false;

  // Desktop: seek bar style in the now-playing view.
  // 0: visualizer bars, 1: expressive wiggly slider, 2: flat clean slider.
  int seekBarStyleIndex = 1;

  // Lyrics: uniform font size across active and non-active lines (no scaling).
  bool uniformLyricsFontSize = false;

  // Desktop Fullscreen: bottom full-width visualizer.
  bool fullscreenVisualizerEnabled = false;

  // Desktop Fullscreen: bottom visualizer density (0: 64 Classic, 1: 96 Balanced, 2: 128 Dense [Default], 3: 160 Ultra-Fine).
  @ignore
  int fullscreenVisualizerDensity = 2;

  // Queue: show previously played songs in the queue list with darker styling.
  bool showPlayedSongsInQueue = true;

  // Keyboard Shortcuts: JSON map of customized shortcut action IDs to key combos.
  String customShortcutsJson = '{}';

  // Desktop Mini-Player: default mini-player style triggered by shortcut.
  // 0: standard (300x420), 1: corner widget (330x110)
  int defaultMiniPlayerType = 0;

  // Desktop Fullscreen: show A-B Looper button in player toolbar.
  bool showFullscreenABLooper = false;

  // Desktop Fullscreen: show Sleep Timer button in player toolbar.
  bool showFullscreenSleepTimer = false;

  // Desktop Fullscreen: disable pulsing animation on album art.
  bool disableFullscreenBreathingEffect = false;

  // Playback: True Gapless Playback
  bool gaplessPlayback = true;

  // Playback: Crossfade Duration (0 = disabled / pure gapless, 1-12 seconds)
  int crossfadeDuration = 0;

  // Playback: Crossfade Mode (0: Always, 1: Automatic Only, 2: Manual Only)
  int crossfadeMode = 0;

  // Playback: Auto-Trim Silence (Skip Silence) - off by default
  bool autoTrimSilence = false;

  // Desktop: System-wide Global Hotkeys
  bool enableGlobalHotkeys = false;

  // Desktop: Windows Taskbar Thumbnail Preview Controls (ITaskbarList3)
  bool enableTaskbarControls = true;

  // Desktop: Discord Rich Presence (RPC)
  bool enableDiscordRpc = false;

  // Scrobbling: Last.fm
  bool enableLastFmScrobbling = false;
  String lastFmUsername = '';
  String lastFmSessionKey = '';
  String lastFmApiKey = '';
  String lastFmSecret = '';

  // Scrobbling: ListenBrainz
  bool enableListenBrainzScrobbling = false;
  String listenBrainzUserToken = '';

  // Scrobbling Threshold Percentage (default 50%)
  int scrobbleThresholdPercent = 50;

  // Desktop: Windows Explorer Context Menu & File Associations
  bool enableWindowsFileAssociations = true;

  // Playlists: Auto-updating Smart Playlists
  bool enableSmartPlaylists = true;

  // Library Card Styles (0: normal, 1: circle, 2: card, 3: image, 4: imageGapless)
  int albumCardStyleIndex = 2;
  int artistCardStyleIndex = 1;

  // Song View Style (0: normal, 1: compact, 2: textOnly, 3: grid)
  int songViewStyleIndex = 0;

  // App Updates & Notifications
  bool enableUpdateNotifications = true;
  String skippedUpdateVersion = '';
}

enum CardStyle { normal, circle, card, image, imageGapless }

enum SongViewStyle { normal, compact, textOnly, grid }

@collection
class PlaybackHistoryEntry {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime timestamp;

  late String songPath;
  late String title;
  String? artist;
  String? album;
  String? genre;
  int durationMs = 0;
  int listenedMs = 0;
  String? artPath;
}

enum SeekBarStyle { visualizer, expressive, flat }

enum PlaybackMode { hybrid, localOnly, onlineOnly }
