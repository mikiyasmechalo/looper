import 'dart:io';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../core/db_service.dart';
import '../domain/models/models.dart';
import 'package:isar/isar.dart';
import '../../playback/data/metadata_service.dart';
import 'artwork_downloader_service.dart';
import "package:audiotags/audiotags.dart" as audiotags;

class ScanResult {
  final int songsCount;
  final Set<String> musicFolders;

  ScanResult({required this.songsCount, required this.musicFolders});
}

class LibraryScanner {
  final List<String> supportedExtensions = [
    '.mp3',
    '.flac',
    '.opus',
    '.aac',
    '.m4a',
    '.m4b',
    '.wav',
    '.ogg',
    '.aiff',
    '.alac',
    '.wma',
  ];

  Future<ScanResult> scanDirectory(
    String path, {
    bool addFolderToSettings = false,
    void Function(int count)? onProgress,
  }) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      return ScanResult(songsCount: 0, musicFolders: {});
    }

    final List<File> filesToProcess = [];
    final Set<String> musicFolders = {};
    final Set<String> visitedPaths = {};

    Future<void> traverse(Directory currentDir, [int depth = 0]) async {
      if (depth > 12) return;

      String canonicalPath;
      try {
        canonicalPath = currentDir.resolveSymbolicLinksSync();
      } catch (_) {
        canonicalPath = currentDir.path;
      }
      if (visitedPaths.contains(canonicalPath)) return;
      visitedPaths.add(canonicalPath);

      final baseName = p.basename(currentDir.path);
      // Skip hidden folders and Android/system directories to avoid slow scans or access issues
      if (baseName.startsWith('.') && baseName != '.') return;
      final lowerName = baseName.toLowerCase();
      if (lowerName == 'android' ||
          lowerName == 'node_modules' ||
          lowerName == '\$recycle.bin' ||
          lowerName == 'system volume information') {
        return;
      }

      List<FileSystemEntity> entities = [];
      try {
        entities = await currentDir
            .list(recursive: false, followLinks: false)
            .toList();
      } catch (e) {
        // Silently catch and skip restricted directories without crashing the whole scan!
        return;
      }

      for (final entity in entities) {
        final name = p.basename(entity.path);
        if (name.startsWith('.') && name != '.') continue;

        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (supportedExtensions.contains(ext)) {
            filesToProcess.add(entity);
            musicFolders.add(p.dirname(entity.path));
            onProgress?.call(filesToProcess.length);
          }
        } else if (entity is Directory) {
          await traverse(entity, depth + 1);
        }
      }
    }

    try {
      await traverse(dir);
    } catch (e) {}

    if (filesToProcess.isEmpty) {
      // Clean up any songs in Isar that were in this folder
      await DbService.isar.writeTxn(() async {
        final prefix = path.endsWith(p.separator) ? path : '$path${p.separator}';
        final toDelete = await DbService.isar.songs
            .filter()
            .pathStartsWith(prefix)
            .or()
            .pathEqualTo(path)
            .findAll();
        final idsToDelete = toDelete.map((s) => s.id).toList();
        if (idsToDelete.isNotEmpty) {
          await DbService.isar.songs.deleteAll(idsToDelete);
        }
      });
      return ScanResult(songsCount: 0, musicFolders: {});
    }

    // Get all existing songs under this scan path
    // (keys lowercased for case-insensitive comparison on Windows)
    final prefix = path.endsWith(p.separator) ? path : '$path${p.separator}';
    final songsInPathDb = await DbService.isar.songs
        .filter()
        .pathStartsWith(prefix)
        .or()
        .pathEqualTo(path)
        .findAll();

    final Map<String, Song> dbSongsMap = {
      for (var s in songsInPathDb) s.path.toLowerCase(): s,
    };

    // Find deleted files (present in DB but no longer on disk)
    final Set<String> currentFilePaths = filesToProcess
        .map((f) => f.path.toLowerCase())
        .toSet();
    final List<int> idsToDelete = [];
    dbSongsMap.forEach((p, song) {
      if (!currentFilePaths.contains(p)) {
        idsToDelete.add(song.id);
      }
    });

    if (idsToDelete.isNotEmpty) {
      await DbService.isar.writeTxn(() async {
        await DbService.isar.songs.deleteAll(idsToDelete);
      });
    }

    // Check and update dateAdded of existing songs to match file modification time
    final List<Song> songsToUpdate = [];
    for (final file in filesToProcess) {
      final dbSong = dbSongsMap[file.path.toLowerCase()];
      if (dbSong != null) {
        try {
          final fileDate = file.lastModifiedSync();
          // If the difference is more than 5 seconds, update it to the file date
          if (dbSong.dateAdded.difference(fileDate).inSeconds.abs() > 5) {
            dbSong.dateAdded = fileDate;
            songsToUpdate.add(dbSong);
          }
        } catch (_) {}
      }
    }

    if (songsToUpdate.isNotEmpty) {
      await DbService.isar.writeTxn(() async {
        await DbService.isar.songs.putAll(songsToUpdate);
      });
    }

    // Re-check songs with missing metadata or missing discNumber
    final songsToRetry = songsInPathDb
        .where(
          (s) =>
              s.artist == 'Unknown Artist' ||
              s.album == 'Unknown Album' ||
              s.artist == null ||
              s.discNumber == null,
        )
        .toList();

    if (songsToRetry.isNotEmpty) {
      for (final song in songsToRetry) {
        final file = File(song.path);
        if (!await file.exists()) continue;
        try {
          final result = await _extractMetadata(file);
          if (result != null) {
            final newSong = result['song'] as Song;
            bool updated = false;
            if (newSong.artist != null &&
                newSong.artist != 'Unknown Artist' &&
                (song.artist == null || song.artist == 'Unknown Artist')) {
              song.artist = newSong.artist;
              updated = true;
            }
            if (newSong.album != null &&
                newSong.album != 'Unknown Album' &&
                (song.album == null || song.album == 'Unknown Album')) {
              song.album = newSong.album;
              updated = true;
            }
            if (newSong.albumArtist != null && song.albumArtist == null) {
              song.albumArtist = newSong.albumArtist;
              updated = true;
            }
            if (newSong.genre != null && song.genre == null) {
              song.genre = newSong.genre;
              updated = true;
            }
            if (newSong.duration != null && song.duration == null) {
              song.duration = newSong.duration;
              updated = true;
            }
            if (newSong.trackNumber != null && song.trackNumber == null) {
              song.trackNumber = newSong.trackNumber;
              updated = true;
            }
            if (newSong.trackTotal != null && song.trackTotal == null) {
              song.trackTotal = newSong.trackTotal;
              updated = true;
            }
            if (newSong.discNumber != null && song.discNumber == null) {
              song.discNumber = newSong.discNumber;
              updated = true;
            }
            if (newSong.discTotal != null && song.discTotal == null) {
              song.discTotal = newSong.discTotal;
              updated = true;
            }
            if (newSong.artPath != null && song.artPath == null) {
              song.artPath = newSong.artPath;
              updated = true;
            }
            if (updated) {
              await DbService.isar.writeTxn(() async {
                await DbService.isar.songs.put(song);
              });
            }
          }
        } catch (_) {}
      }
    }

    // Find new files to process (on disk but not in DB)
    final List<File> newFilesToProcess = filesToProcess
        .where((f) => !dbSongsMap.containsKey(f.path.toLowerCase()))
        .toList();

    // If requested, add discovered folders to settings
    if (addFolderToSettings) {}

    if (newFilesToProcess.isNotEmpty) {
      const int batchSize =
          16; // Process in batches of 16 to keep memory footprint minimal
      final settings =
          await DbService.isar.appSettings.where().findFirst() ?? AppSettings();
      final useAlbumArtist = settings.useAlbumArtistForArtists;

      for (int i = 0; i < newFilesToProcess.length; i += batchSize) {
        final end = (i + batchSize < newFilesToProcess.length)
            ? i + batchSize
            : newFilesToProcess.length;
        final batch = newFilesToProcess.sublist(i, end);

        final results = await Future.wait(
          batch.map((f) => _extractMetadata(f)),
        );
        final batchResults = results.whereType<Map<String, dynamic>>().toList();

        if (batchResults.isNotEmpty) {
          await DbService.isar.writeTxn(() async {
            for (final data in batchResults) {
              final song = data['song'] as Song;
              final albumName = (data['album'] as String?) ?? song.album;
              final artistName = (data['artist'] as String?) ?? song.artist;
              final albumArtistName = (data['albumArtist'] as String?) ?? song.albumArtist;
              final artPath = data['artPath'] as String?;

              // Put song — reuse ID if path already exists to avoid unique violations
              final existingSong = await DbService.isar.songs
                  .filter()
                  .pathEqualTo(song.path)
                  .findFirst();
              if (existingSong != null) {
                song.id = existingSong.id;
              }
              await DbService.isar.songs.put(song);

              if (albumName != null) {
                final existingAlbum = await DbService.isar.albums
                    .filter()
                    .nameEqualTo(albumName)
                    .findFirst();
                if (existingAlbum == null) {
                  final album = Album()
                    ..name = albumName
                    ..artist = artistName
                    ..artPath = artPath
                    ..dateAdded = DateTime.now();
                  await DbService.isar.albums.put(album);
                } else if (existingAlbum.artPath == null && artPath != null) {
                  existingAlbum.artPath = artPath;
                  await DbService.isar.albums.put(existingAlbum);
                }
              }

              final targetArtistName = useAlbumArtist
                  ? (albumArtistName ?? artistName)
                  : artistName;

              if (targetArtistName != null) {
                final existingArtist = await DbService.isar.artists
                    .filter()
                    .nameEqualTo(targetArtistName)
                    .findFirst();
                if (existingArtist == null) {
                  final artist = Artist()..name = targetArtistName;
                  await DbService.isar.artists.put(artist);
                }
              }
            }
          });
        }

        // Small pause to allow Dart GC and UI thread to breathe
        await Future.delayed(const Duration(milliseconds: 20));
      }
    }

    return ScanResult(
      songsCount: filesToProcess.length,
      musicFolders: musicFolders,
    );
  }

  Future<Map<String, dynamic>?> _extractMetadata(
    File file, {
    bool downloadArtworkIfMissing = false,
  }) async {
    try {
      Metadata? metadata;
      try {
        // Enforce strict 800ms timeout on native metadata read to prevent scanning/UI hangs
        metadata = await MetadataGod.readMetadata(
          file: file.path,
        ).timeout(const Duration(milliseconds: 800));
      } catch (e) {}

      // Fallback or supplement: if metadata_god failed OR was missing discNumber/trackNumber/albumArtist/etc.
      if (metadata == null ||
          metadata.discNumber == null ||
          metadata.trackNumber == null ||
          metadata.albumArtist == null ||
          metadata.title == null ||
          metadata.artist == null ||
          metadata.album == null) {
        try {
          final tag = await audiotags.AudioTags.read(file.path);
          if (tag != null) {
            // Merge AudioTags with any partial metadata_god results
            metadata = Metadata(
              title: (metadata?.title != null && metadata!.title!.isNotEmpty)
                  ? metadata.title
                  : tag.title,
              artist: (metadata?.artist != null &&
                      metadata!.artist != 'Unknown Artist')
                  ? metadata.artist
                  : (tag.trackArtist ?? tag.albumArtist),
              album: (metadata?.album != null &&
                      metadata!.album != 'Unknown Album')
                  ? metadata.album
                  : tag.album,
              albumArtist: metadata?.albumArtist ?? tag.albumArtist,
              genre: metadata?.genre ?? tag.genre,
              trackNumber: metadata?.trackNumber ?? tag.trackNumber,
              trackTotal: metadata?.trackTotal ?? tag.trackTotal,
              discNumber: metadata?.discNumber ?? tag.discNumber,
              discTotal: metadata?.discTotal ?? tag.discTotal,
              year: metadata?.year ?? tag.year,
              durationMs: metadata?.durationMs ??
                  (tag.duration != null ? tag.duration! * 1000.0 : null),
              picture: metadata?.picture ??
                  (tag.pictures.isNotEmpty
                      ? Picture(
                          mimeType:
                              tag.pictures.first.mimeType?.name ?? 'image/jpeg',
                          data: tag.pictures.first.bytes,
                        )
                      : null),
            );
          }
        } catch (_) {}
      }

      String? artPath;
      if (metadata?.picture != null) {
        artPath = await saveAlbumArt(
          metadata?.album ?? 'unknown',
          metadata!.picture!.data,
        );
      }

      final lyrics = await MetadataService.getEmbeddedLyrics(file.path);

      DateTime fileDate;
      try {
        fileDate = file.lastModifiedSync();
      } catch (_) {
        fileDate = DateTime.now();
      }

      final song = Song()
        ..path = file.path
        ..title = metadata?.title ?? p.basenameWithoutExtension(file.path)
        ..artist = metadata?.artist ?? 'Unknown Artist'
        ..album = metadata?.album ?? 'Unknown Album'
        ..albumArtist = metadata?.albumArtist
        ..genre = metadata?.genre
        ..duration = metadata?.durationMs?.toInt()
        ..trackNumber = metadata?.trackNumber
        ..trackTotal = metadata?.trackTotal
        ..discNumber = metadata?.discNumber
        ..discTotal = metadata?.discTotal
        ..year = metadata?.year
        ..artPath = artPath
        ..lyrics = lyrics
        ..dateAdded = fileDate;

      if (artPath == null && downloadArtworkIfMissing) {
        artPath = await ArtworkDownloaderService().downloadArtworkForSong(song);
        song.artPath = artPath;
      }

      return {
        'song': song,
        'metadata':
            metadata ??
            Metadata(title: song.title, artist: song.artist, album: song.album),
        'artPath': artPath,
      };
    } catch (e) {
      return null;
    }
  }

  Future<String?> saveAlbumArt(String albumName, List<int> data) async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final artDir = Directory(p.join(appDir.path, 'album_art'));
      if (!await artDir.exists()) await artDir.create(recursive: true);

      final hash =
          data.length.toString() +
          data.take(10).join() +
          data.reversed.take(10).join();
      final fileName =
          '${albumName.replaceAll(RegExp(r'[^\w\s]+'), '')}_${hash.hashCode}.jpg';

      final file = File(p.join(artDir.path, fileName));
      if (!await file.exists()) {
        await file.writeAsBytes(data);
      }
      return file.path;
    } catch (e) {
      return null;
    }
  }
}
