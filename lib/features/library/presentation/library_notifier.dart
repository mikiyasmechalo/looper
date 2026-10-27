import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/logger_helper.dart';
import 'package:looper_player/core/memory_service.dart';
import 'package:path/path.dart' as p;
import 'package:looper_player/features/library/data/scanner.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/library/data/artist_image_service.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/features/playback/data/lyrics_fetcher.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/library/data/recommendations_service.dart';
import 'dart:async';

enum SongSortStrategy {
  title,
  artist,
  album,
  dateAdded,
  duration,
  year,
  playCount,
  lastPlayed,
}

class LibraryState {
  final bool isScanning;
  final bool isInitialized;
  final List<Song> songs;
  final List<Artist> artists;
  final List<Album> albums;
  final List<Playlist> playlists;
  final SongSortStrategy sortStrategy;
  final bool isAscending;
  final String? scanStatus;
  final int? _scanProgress;
  final int? _scanTotal;

  int get scanProgress => _scanProgress ?? 0;
  int get scanTotal => _scanTotal ?? 0;

  LibraryState({
    this.isScanning = false,
    this.isInitialized = false,
    this.songs = const [],
    this.artists = const [],
    this.albums = const [],
    this.playlists = const [],
    this.sortStrategy = SongSortStrategy.title,
    this.isAscending = false,
    this.scanStatus,
    int? scanProgress = 0,
    int? scanTotal = 0,
  })  : _scanProgress = scanProgress ?? 0,
        _scanTotal = scanTotal ?? 0;

  LibraryState copyWith({
    bool? isScanning,
    bool? isInitialized,
    List<Song>? songs,
    List<Artist>? artists,
    List<Album>? albums,
    List<Playlist>? playlists,
    SongSortStrategy? sortStrategy,
    bool? isAscending,
    String? scanStatus,
    int? scanProgress,
    int? scanTotal,
  }) {
    return LibraryState(
      isScanning: isScanning ?? this.isScanning,
      isInitialized: isInitialized ?? this.isInitialized,
      songs: songs ?? this.songs,
      artists: artists ?? this.artists,
      albums: albums ?? this.albums,
      playlists: playlists ?? this.playlists,
      sortStrategy: sortStrategy ?? this.sortStrategy,
      isAscending: isAscending ?? this.isAscending,
      scanStatus: scanStatus ?? (isScanning == false ? null : this.scanStatus),
      scanProgress: scanProgress ?? _scanProgress ?? 0,
      scanTotal: scanTotal ?? _scanTotal ?? 0,
    );
  }
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  final Ref _ref;
  StreamSubscription<List<Song>>? _songsSubscription;
  bool _isFetchingArtistImages = false;
  bool _isScanRunning = false;

  LibraryNotifier(this._ref) : super(LibraryState()) {
    // Automatically clean up database and refresh songs whenever active library folders change!
    _ref.listen<List<String>>(
      settingsProvider.select((s) => s.libraryFolders),
      (previous, next) async {
        if (previous != null && !listEquals(previous, next) && next.isNotEmpty) {
          await syncSongsWithFolders(next);
          _loadLibrary(); // Force-reload lists immediately
        }
      },
      fireImmediately: false,
    );

    _init();
  }

  Future<void> _init() async {
    // Wait for settings to load
    await _ref.read(settingsProvider.notifier).initialization;

    // Load initial sort strategy and order from persisted settings
    final initialSettings = _ref.read(settingsProvider);
    state = state.copyWith(
      sortStrategy: SongSortStrategy.values[initialSettings.sortStrategyIndex],
      isAscending: initialSettings.sortAscending,
    );

    _loadLibrary();
  }

  void _loadLibrary() {
    _watchSongs();
    _watchArtists();
    _watchAlbums();
    _watchPlaylists();
    _fetchMissingArtistImages();
  }

  void setSortStrategy(SongSortStrategy strategy) {
    if (state.sortStrategy == strategy) {
      // Toggle direction if same strategy
      final newAsc = !state.isAscending;
      state = state.copyWith(isAscending: newAsc);
      _ref.read(settingsProvider.notifier).updateSortAscending(newAsc);
    } else {
      final smartAsc = defaultAscendingForSongStrategy(strategy);
      state = state.copyWith(sortStrategy: strategy, isAscending: smartAsc);
      _ref.read(settingsProvider.notifier).updateSortStrategy(strategy.index);
      _ref.read(settingsProvider.notifier).updateSortAscending(smartAsc);
    }
    _watchSongs();
  }

  static bool defaultAscendingForSongStrategy(SongSortStrategy strategy) {
    switch (strategy) {
      case SongSortStrategy.title:
      case SongSortStrategy.artist:
      case SongSortStrategy.album:
      case SongSortStrategy.duration:
        return true;
      case SongSortStrategy.dateAdded:
      case SongSortStrategy.lastPlayed:
      case SongSortStrategy.playCount:
      case SongSortStrategy.year:
        return false;
    }
  }

  void toggleSortOrder() {
    final newAsc = !state.isAscending;
    state = state.copyWith(isAscending: newAsc);
    _ref.read(settingsProvider.notifier).updateSortAscending(newAsc);
    _watchSongs();
  }

  void _watchSongs() {
    _songsSubscription?.cancel();
    
    QueryBuilder<Song, Song, QAfterSortBy> query;
    final isAsc = state.isAscending;

    switch (state.sortStrategy) {
      case SongSortStrategy.title:
        query = isAsc
            ? DbService.isar.songs.where().sortByTitle()
            : DbService.isar.songs.where().sortByTitleDesc();
        break;
      case SongSortStrategy.artist:
        query = isAsc
            ? DbService.isar.songs.where().sortByArtist().thenByTitle()
            : DbService.isar.songs.where().sortByArtistDesc().thenByTitle();
        break;
      case SongSortStrategy.album:
        query = isAsc
            ? DbService.isar.songs.where().sortByAlbum().thenByTrackNumber()
            : DbService.isar.songs.where().sortByAlbumDesc().thenByTrackNumber();
        break;
      case SongSortStrategy.duration:
        query = isAsc
            ? DbService.isar.songs.where().sortByDuration()
            : DbService.isar.songs.where().sortByDurationDesc();
        break;
      case SongSortStrategy.year:
        query = isAsc
            ? DbService.isar.songs.where().sortByYear()
            : DbService.isar.songs.where().sortByYearDesc();
        break;
      case SongSortStrategy.playCount:
        query = isAsc
            ? DbService.isar.songs.where().sortByPlayCount().thenByLastPlayed().thenByTitle()
            : DbService.isar.songs.where().sortByPlayCountDesc().thenByLastPlayedDesc().thenByTitle();
        break;
      case SongSortStrategy.lastPlayed:
        query = isAsc
            ? DbService.isar.songs.where().sortByLastPlayed().thenByTitle()
            : DbService.isar.songs.where().sortByLastPlayedDesc().thenByTitle();
        break;
      case SongSortStrategy.dateAdded:
      default:
        query = isAsc
            ? DbService.isar.songs.where().sortByDateAdded()
            : DbService.isar.songs.where().sortByDateAddedDesc();
        break;
    }

    _songsSubscription = query.watch(fireImmediately: true).listen((songs) {
      state = state.copyWith(
        songs: songs,
        isInitialized: true,
      );
      _ref.read(playbackProvider.notifier).syncQueueWithAvailableSongs(songs);
    });
  }

  void _watchArtists() {
    DbService.isar.artists
        .where()
        .sortByName()
        .watch(fireImmediately: true)
        .listen((artists) {
      state = state.copyWith(artists: artists);
    });
  }

  void _watchAlbums() {
    DbService.isar.albums
        .where()
        .sortByName()
        .watch(fireImmediately: true)
        .listen((albums) {
      state = state.copyWith(albums: albums);
    });
  }

  void _watchPlaylists() {
    DbService.isar.playlists
        .where()
        .sortByName()
        .watch(fireImmediately: true)
        .listen((playlists) {
      state = state.copyWith(playlists: playlists);
    });
  }

  Future<void> _fetchMissingArtistImages() async {
    if (_isFetchingArtistImages) return;
    if (state.isScanning) return;

    _isFetchingArtistImages = true;
    try {
      final allArtists = await DbService.isar.artists.where().findAll();
      final service = ArtistImageService();
      final userImageIndex = await service.loadUserImageIndex();

      // First pass: rebuild collage lists from what's already on disk (real
      // photos only, generic placeholders excluded). This re-links images
      // after a Reset & Rescan and also cleans up any generic avatars that
      // were previously stored. No network calls, no rate-limit delay.
      final needsDownload = <Artist>[];
      final toPut = <Artist>[];
      for (final artist in allArtists) {
        if (state.isScanning) break;
        if (artist.name == 'Unknown Artist') continue;

        final cached = await service.findLocalImages(
          artist.name,
          userImageIndex: userImageIndex,
        );
        if (cached.isNotEmpty) {
          final changed =
              artist.artistImages.join('|') != cached.join('|') ||
              artist.artistImageUrl == null;
          if (changed) {
            artist.artistImages = cached;
            artist.artistImageUrl ??= cached.first;
            toPut.add(artist);
          }
        } else {
          // No real images on disk. Clear any stale generic avatars that were
          // stored in the collage list so they don't keep showing as a collage
          // of placeholders.
          if (artist.artistImages.isNotEmpty) {
            artist.artistImages = [];
            toPut.add(artist);
          }
          if (artist.artistImageUrl == null) {
            needsDownload.add(artist);
          }
        }
      }

      if (toPut.isNotEmpty) {
        await DbService.isar.writeTxn(() async {
          await DbService.isar.artists.putAll(toPut);
        });
      }

      // Second pass: download genuinely missing artist images.
      for (final artist in needsDownload) {
        // Yield/stop fetching immediately if a library scan starts
        if (state.isScanning) break;
        if (artist.name == 'Unknown Artist') continue;

        final localPaths = await service.getArtistImages(
          artist.name,
          userImageIndex: userImageIndex,
        );
        if (localPaths.isNotEmpty) {
          await DbService.isar.writeTxn(() async {
            artist.artistImages = localPaths;
            artist.artistImageUrl = localPaths.first;
            await DbService.isar.artists.put(artist);
          });
        } else {
          // No real photo for any part of the name. Keep a single generic
          // avatar as a fallback instead of a collage of placeholders.
          final primary = await service.getArtistImage(artist.name);
          if (primary != null) {
            await DbService.isar.writeTxn(() async {
              artist.artistImageUrl = primary;
              await DbService.isar.artists.put(artist);
            });
          }
        }

        // Wait 2.0 seconds between queries to prevent high CPU, power, and bandwidth usage,
        // and to fully comply with Deezer API rate limits.
        await Future.delayed(const Duration(milliseconds: 2000));
      }
    } finally {
      _isFetchingArtistImages = false;
    }
  }

  Future<void> prefetchLibraryLyrics() async {
    final songs = await DbService.isar.songs.where().findAll();
    final songsToFetch = songs.where((s) => s.lyrics == null || s.lyrics!.isEmpty).toList();
    
    if (songsToFetch.isEmpty) return;

    state = state.copyWith(isScanning: true);
    
    // Use a small concurrency limit to avoid overwhelming services
    const int batchSize = 5;
    for (int i = 0; i < songsToFetch.length; i += batchSize) {
      final end = (i + batchSize < songsToFetch.length) 
          ? i + batchSize 
          : songsToFetch.length;
      final batch = songsToFetch.sublist(i, end);
      
      await Future.wait(batch.map((song) => LyricsFetcher.fetchLyrics(song)));
    }

    state = state.copyWith(isScanning: false);
  }

  Future<int> purgeDeletedSongs() async {
    try {
      final allSongs = await DbService.isar.songs.where().findAll();
      final toDelete = <int>[];
      for (final song in allSongs) {
        if (!File(song.path).existsSync()) {
          toDelete.add(song.id);
        }
      }
      if (toDelete.isNotEmpty) {
        RecommendationsService.clearQuickPicksCache();
        await DbService.isar.writeTxn(() async {
          await DbService.isar.songs.deleteAll(toDelete);
        });
        LoggerHelper.write('LibraryNotifier.purgeDeletedSongs: Purged ${toDelete.length} missing songs.');
      }
      return toDelete.length;
    } catch (e) {
      LoggerHelper.write('LibraryNotifier.purgeDeletedSongs error: $e');
      return 0;
    }
  }

  Future<void> scanSavedFolders({bool showVisualIndicator = true}) async {
    if (_isScanRunning) {
      LoggerHelper.write('LibraryNotifier.scanSavedFolders: Scan already in progress, ignoring.');
      return;
    }
    _isScanRunning = true;
    try {
      if (showVisualIndicator) {
        state = state.copyWith(isScanning: true, scanStatus: 'Scanning library...');
      }

      await purgeDeletedSongs();

      final rawFolders = _ref.read(settingsProvider).libraryFolders;
      List<String> folders = List<String>.from(rawFolders);

      if (folders.isEmpty) {
        List<String> scanRoots = [];
        if (Platform.isLinux) {
          String defaultPath = '${Platform.environment['HOME']}/Music';
          try {
            final result = await Process.run('xdg-user-dir', ['MUSIC']);
            if (result.exitCode == 0 &&
                result.stdout.toString().trim().isNotEmpty) {
              defaultPath = result.stdout.toString().trim();
            }
          } catch (_) {}
          scanRoots.add(defaultPath);
        } else if (Platform.isWindows) {
          final userProfile = Platform.environment['USERPROFILE'];
          if (userProfile != null) {
            scanRoots.add('$userProfile\\Music');
          }
        }

        for (final path in scanRoots) {
          if (Directory(path).existsSync()) {
            await scanLibrary(path, updateIsScanning: showVisualIndicator);
          }
        }
        if (showVisualIndicator) {
          state = state.copyWith(isScanning: false, scanStatus: null, scanProgress: 0, scanTotal: 0);
        }
        _fetchMissingArtistImages();
        return;
      }

      // Deduplicate folders: keep only top-level roots to avoid scanning subfolders repeatedly
      final normalized = folders.map((f) => p.normalize(f)).toSet().toList();
      final cleanRoots = <String>[];
      for (final f in normalized) {
        final prefix = f.endsWith(p.separator) ? f : '$f${p.separator}';
        final hasParent = normalized.any((other) {
          if (other == f) return false;
          final otherPrefix = other.endsWith(p.separator) ? other : '$other${p.separator}';
          return f.toLowerCase().startsWith(otherPrefix.toLowerCase());
        });
        if (!hasParent) {
          cleanRoots.add(f);
        }
      }

      // If settings had polluted subfolders, clean up settings.libraryFolders
      if (cleanRoots.length != folders.length) {
        await _ref.read(settingsProvider.notifier).updateLibraryFolders(cleanRoots);
      }

      for (int i = 0; i < cleanRoots.length; i++) {
        final folder = cleanRoots[i];
        if (Directory(folder).existsSync()) {
          final dirName = p.basename(folder);
          if (showVisualIndicator) {
            state = state.copyWith(
              isScanning: true,
              scanStatus: 'Scanning $dirName...',
            );
          }
          await LibraryScanner().scanDirectory(
            folder,
            onProgress: (found, processed, total) {
              if (showVisualIndicator) {
                state = state.copyWith(
                  isScanning: true,
                  scanProgress: processed,
                  scanTotal: total,
                  scanStatus: total > 0
                      ? 'Scanning $dirName: $processed / $total'
                      : 'Scanning $dirName: $found found',
                );
              }
            },
          );
        }
      }

      if (showVisualIndicator) {
        state = state.copyWith(isScanning: false, scanStatus: null, scanProgress: 0, scanTotal: 0);
      }
      _fetchMissingArtistImages();
    } finally {
      _isScanRunning = false;
      if (showVisualIndicator) {
        state = state.copyWith(isScanning: false, scanStatus: null, scanProgress: 0, scanTotal: 0);
      }
      MemoryService.trimWorkingSet(clearImageCache: true);
    }
  }

  Future<void> clearAllData() async {
    RecommendationsService.clearQuickPicksCache();
    await DbService.isar.writeTxn(() async {
      await DbService.isar.songs.clear();
      await DbService.isar.albums.clear();
      await DbService.isar.artists.clear();
      await DbService.isar.playlists.clear();
    });
    await _ref.read(settingsProvider.notifier).updateLibraryFolders([]);
    await _ref.read(settingsProvider.notifier).updateLastPlayedSong(null);
  }

  Future<void> resetAndRescan() async {
    RecommendationsService.clearQuickPicksCache();
    state = state.copyWith(isScanning: true);

    // Preserve downloaded artist images across the reset so they aren't
    // re-downloaded from the network after rescanning. Keyed by the same
    // normalized name used for the cache filenames so minor tag differences
    // (case, whitespace, stray characters) still match.
    final artistsBefore = await DbService.isar.artists.where().findAll();
    final savedArtistImages = <String, String>{
      for (final a in artistsBefore)
        if (a.artistImageUrl != null)
          _normalizeArtistKey(a.name): a.artistImageUrl!,
    };
    final savedArtistCollages = <String, List<String>>{
      for (final a in artistsBefore)
        if (a.artistImages.isNotEmpty)
          _normalizeArtistKey(a.name): a.artistImages,
    };

    await DbService.isar.writeTxn(() async {
      await DbService.isar.songs.clear();
      await DbService.isar.albums.clear();
      await DbService.isar.artists.clear();
    });
    await _ref.read(settingsProvider.notifier).updateLastPlayedSong(null);

    final folders = _ref.read(settingsProvider).libraryFolders;
    for (final folder in folders) {
      if (Directory(folder).existsSync()) {
        await LibraryScanner().scanDirectory(folder);
      }
    }

    // Re-link preserved artist images to the freshly recreated artist records.
    if (savedArtistImages.isNotEmpty || savedArtistCollages.isNotEmpty) {
      final newArtists = await DbService.isar.artists.where().findAll();
      await DbService.isar.writeTxn(() async {
        for (final artist in newArtists) {
          final key = _normalizeArtistKey(artist.name);
          final saved = savedArtistImages[key];
          if (saved != null) {
            artist.artistImageUrl = saved;
          }
          final collage = savedArtistCollages[key];
          if (collage != null && collage.isNotEmpty) {
            artist.artistImages = collage;
          }
          if (saved != null || (collage != null && collage.isNotEmpty)) {
            await DbService.isar.artists.put(artist);
          }
        }
      });
    }

    state = state.copyWith(isScanning: false);

    // Explicitly kick off the fetch pass now that scanning is done. The Isar
    // watch that drives _fetchMissingArtistImages only fires on DB writes, and
    // flipping isScanning is a plain state change, so without this the
    // disk-relink fallback would never run this session.
    _fetchMissingArtistImages();
    MemoryService.trimWorkingSet(clearImageCache: true);
  }

  String _normalizeArtistKey(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s]+'), '');

  Future<int> scanLibrary(
    String path, {
    bool updateIsScanning = true,
    void Function(int found, int processed, int total)? onProgress,
  }) async {
    if (updateIsScanning) {
      final dirName = p.basename(path);
      state = state.copyWith(
        isScanning: true,
        scanStatus: 'Scanning $dirName...',
      );
    }
    int totalSongsFound = 0;

    try {
      final dir = Directory(path);
      if (dir.existsSync()) {
        final dirName = p.basename(path);
        final result = await LibraryScanner().scanDirectory(
          path,
          onProgress: (found, processed, total) {
            if (updateIsScanning) {
              state = state.copyWith(
                isScanning: true,
                scanProgress: processed,
                scanTotal: total,
                scanStatus: total > 0
                    ? 'Scanning $dirName: $processed / $total'
                    : 'Scanning $dirName: $found found',
              );
            }
            onProgress?.call(found, processed, total);
          },
        );
        totalSongsFound = result.songsCount;
        
        // Always add the selected root folder path to saved library folders (NOT subfolders!)
        final settings = _ref.read(settingsProvider);
        final newFolders = Set<String>.from(settings.libraryFolders)
          ..add(path);
        await _ref
            .read(settingsProvider.notifier)
            .updateLibraryFolders(newFolders.toList());
      }
    } catch (e) {
      LoggerHelper.write('LibraryNotifier.scanLibrary error: $e');
    }

    if (updateIsScanning) {
      state = state.copyWith(isScanning: false, scanStatus: null, scanProgress: 0, scanTotal: 0);
    }

    _fetchMissingArtistImages();
    return totalSongsFound;
  }

  Future<void> toggleAlbumFavorite(Album album) async {
    await DbService.isar.writeTxn(() async {
      final dbAlbum = await DbService.isar.albums.get(album.id);
      if (dbAlbum != null) {
        dbAlbum.isFavorite = !dbAlbum.isFavorite;
        await DbService.isar.albums.put(dbAlbum);
      } else {
        album.isFavorite = !album.isFavorite;
        await DbService.isar.albums.put(album);
      }
    });
  }

  Future<void> toggleArtistFavorite(Artist artist) async {
    await DbService.isar.writeTxn(() async {
      final dbArtist = await DbService.isar.artists.get(artist.id);
      if (dbArtist != null) {
        dbArtist.isFavorite = !dbArtist.isFavorite;
        await DbService.isar.artists.put(dbArtist);
      } else {
        artist.isFavorite = !artist.isFavorite;
        await DbService.isar.artists.put(artist);
      }
    });
  }

  Future<void> toggleFavorite(Song song) async {
    await DbService.isar.writeTxn(() async {
      // Direct ID lookup is safer to ensure we're updating the correct record
      final dbSong = await DbService.isar.songs.get(song.id);
      if (dbSong != null) {
        dbSong.isFavorite = !dbSong.isFavorite;
        await DbService.isar.songs.put(dbSong);
      } else {
        // Fallback for songs not yet in DB (e.g. played from file)
        song.isFavorite = !song.isFavorite;
        await DbService.isar.songs.put(song);
      }
    });
  }

  Future<void> syncSongsWithFolders(List<String> activeFolders) async {
    // Safety guard: NEVER wipe the library if activeFolders is empty or uninitialized
    if (activeFolders.isEmpty) {
      return;
    }
    await DbService.isar.writeTxn(() async {
      // Find all songs in the DB
      final allSongs = await DbService.isar.songs.where().findAll();
      
      // Filter songs that do NOT belong to any of the active folders
      final songsToDelete = allSongs.where((song) {
        if (song.path.isEmpty) return true;
        final normSong = p.normalize(p.absolute(song.path)).toLowerCase();
        return !activeFolders.any((folder) {
          final normFolder = p.normalize(p.absolute(folder)).toLowerCase();
          return normSong == normFolder ||
              normSong.startsWith(normFolder.endsWith(Platform.pathSeparator)
                  ? normFolder
                  : '$normFolder${Platform.pathSeparator}');
        });
      }).toList();
      
      if (songsToDelete.isNotEmpty) {
        final idsToDelete = songsToDelete.map((s) => s.id).toList();
        await DbService.isar.songs.deleteAll(idsToDelete);

        
        // Clean up empty albums & artists
        final remainingSongs = await DbService.isar.songs.where().findAll();
        final activeAlbumNames = remainingSongs.map((s) => s.album).toSet();
        final activeArtistNames = remainingSongs.map((s) => s.artist).toSet();
        
        // Load all albums and artists
        final allAlbums = await DbService.isar.albums.where().findAll();
        final albumsToDelete = allAlbums.where((a) => !activeAlbumNames.contains(a.name)).map((a) => a.id).toList();
        if (albumsToDelete.isNotEmpty) {
          await DbService.isar.albums.deleteAll(albumsToDelete);

        }

        final allArtists = await DbService.isar.artists.where().findAll();
        final artistsToDelete = allArtists.where((art) => !activeArtistNames.contains(art.name)).map((art) => art.id).toList();
        if (artistsToDelete.isNotEmpty) {
          await DbService.isar.artists.deleteAll(artistsToDelete);

        }
      }
    });
  }

  @override
  void dispose() {
    _songsSubscription?.cancel();
    super.dispose();
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((
  ref,
) {
  return LibraryNotifier(ref);
});

final recentlyPlayedProvider = StreamProvider<List<Song>>((ref) {
  return DbService.isar.songs
      .where()
      .filter()
      .lastPlayedIsNotNull()
      .sortByLastPlayedDesc()
      .limit(30)
      .watch(fireImmediately: true);
});

final topSongsProvider = StreamProvider<List<Song>>((ref) {
  return DbService.isar.songs
      .where()
      .filter()
      .playCountGreaterThan(0)
      .sortByPlayCountDesc()
      .thenByLastPlayedDesc()
      .thenByTitle()
      .limit(20)
      .watch(fireImmediately: true);
});

final newlyAddedSongsProvider = StreamProvider<List<Song>>((ref) {
  return DbService.isar.songs
      .where()
      .sortByDateAddedDesc()
      .limit(20)
      .watch(fireImmediately: true);
});

final rediscoverSongsProvider = StreamProvider<List<Song>>((ref) {
  return DbService.isar.songs
      .where()
      .filter()
      .group((q) => q.isFavoriteEqualTo(true).or().playCountGreaterThan(1))
      .sortByLastPlayed()
      .limit(20)
      .watch(fireImmediately: true);
});

