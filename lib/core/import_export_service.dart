import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'db_service.dart';
import 'logger_helper.dart';
import 'app_fonts.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';

class ImportExportService {
  static Future<void> exportLibraryData(BuildContext context) async {
    LoggerHelper.write('ImportExportService: Starting library backup export...');
    final messenger = ScaffoldMessenger.of(context);
    try {
      // 1. Get all liked songs
      final likedSongs = await DbService.isar.songs.filter().isFavoriteEqualTo(true).findAll();
      final favoritesJson = likedSongs.map((s) => {
        'path': s.path,
        'title': s.title,
        'artist': s.artist,
        'album': s.album,
      }).toList();
      LoggerHelper.write('ImportExportService: Found ${likedSongs.length} favorited songs to export.');

      // 2. Get all playlists
      final playlists = await DbService.isar.playlists.where().findAll();
      final playlistsJson = playlists.map((p) => {
        'name': p.name,
        'songPaths': p.songPaths,
        'dateCreated': p.dateCreated.toIso8601String(),
        'dateModified': p.dateModified.toIso8601String(),
      }).toList();
      LoggerHelper.write('ImportExportService: Found ${playlists.length} playlists to export.');

      // 3. Construct JSON structure
      final backup = {
        'version': 1,
        'favorites': favoritesJson,
        'playlists': playlistsJson,
      };

      final jsonStr = const JsonEncoder.withIndent('  ').convert(backup);

      // 4. Write to temp directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/looper_player_backup.json');
      await file.writeAsString(jsonStr);
      LoggerHelper.write('ImportExportService: Serialised backup written to: ${file.path}');

      // 5. Native Share
      await Share.shareXFiles([XFile(file.path)], subject: 'Looper Player Backup');
      LoggerHelper.write('ImportExportService: Shared backup file successfully.');
    } catch (e, stack) {
      LoggerHelper.write('ImportExportService: Failed to export library data', e, stack);
      messenger.showSnackBar(SnackBar(
        content: const Text('Failed to export backup: An internal error occurred while saving the backup file.'),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  static Future<void> importLibraryData(BuildContext context, WidgetRef ref) async {
    LoggerHelper.write('ImportExportService: Starting library backup import...');
    final messenger = ScaffoldMessenger.of(context);
    try {
      // 1. Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty || result.files.single.path == null) {
        LoggerHelper.write('ImportExportService: Import cancelled by user (no file selected).');
        return;
      }

      final filePath = result.files.single.path!;
      LoggerHelper.write('ImportExportService: User selected file: $filePath');

      final file = File(filePath);
      final content = await file.readAsString();
      final Map<String, dynamic> backup = jsonDecode(content);

      if (backup['version'] != 1) {
        throw 'Unsupported backup version: ${backup['version']}';
      }

      int favoritesMerged = 0;
      int playlistsCreated = 0;

      // 2. Import Favorites
      final favorites = backup['favorites'] as List<dynamic>? ?? [];
      LoggerHelper.write('ImportExportService: Parsing ${favorites.length} favorited songs from backup.');
      for (final fav in favorites) {
        final path = fav['path'] as String?;
        final title = fav['title'] as String?;
        final artist = fav['artist'] as String?;
        final album = fav['album'] as String?;

        if (path == null) continue;

        // Try to match song by path first
        var song = await DbService.isar.songs.filter().pathEqualTo(path).findFirst();

        // Fallback: match by title and artist if path fails
        if (song == null && title != null && artist != null) {
          song = await DbService.isar.songs.filter()
              .titleEqualTo(title)
              .and()
              .artistEqualTo(artist)
              .findFirst();
        }

        if (song != null && !song.isFavorite) {
          song.isFavorite = true;
          await DbService.isar.writeTxn(() async {
            await DbService.isar.songs.put(song!);
          });
          favoritesMerged++;
        }
      }
      LoggerHelper.write('ImportExportService: Merged $favoritesMerged favorites.');

      // 3. Import Playlists
      final playlists = backup['playlists'] as List<dynamic>? ?? [];
      LoggerHelper.write('ImportExportService: Parsing ${playlists.length} playlists from backup.');
      for (final pl in playlists) {
        final name = pl['name'] as String?;
        final songPaths = List<String>.from(pl['songPaths'] ?? []);
        final dateCreatedStr = pl['dateCreated'] as String?;
        final dateModifiedStr = pl['dateModified'] as String?;

        if (name == null || name.isEmpty) continue;

        final dateCreated = dateCreatedStr != null ? DateTime.parse(dateCreatedStr) : DateTime.now();
        final dateModified = dateModifiedStr != null ? DateTime.parse(dateModifiedStr) : DateTime.now();

        // Check if playlist exists
        var playlist = await DbService.isar.playlists.filter().nameEqualTo(name).findFirst();
        if (playlist == null) {
          playlist = Playlist()
            ..name = name
            ..songPaths = songPaths
            ..dateCreated = dateCreated
            ..dateModified = dateModified;
          await DbService.isar.writeTxn(() async {
            await DbService.isar.playlists.put(playlist!);
          });
          playlistsCreated++;
        } else {
          // Merge paths
          final mergedPaths = Set<String>.from(playlist.songPaths)..addAll(songPaths);
          playlist.songPaths = mergedPaths.toList();
          playlist.dateModified = DateTime.now();
          await DbService.isar.writeTxn(() async {
            await DbService.isar.playlists.put(playlist!);
          });
          playlistsCreated++;
        }
      }
      LoggerHelper.write('ImportExportService: Synced $playlistsCreated playlists.');

      // Trigger Library ref scan / updates to sync UI
      ref.read(libraryProvider.notifier).scanSavedFolders(showVisualIndicator: false);

      messenger.showSnackBar(SnackBar(
        content: Text('Backup imported: Merged $favoritesMerged favorites, synced $playlistsCreated playlists'),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e, stack) {
      LoggerHelper.write('ImportExportService: Failed to import library data', e, stack);
      messenger.showSnackBar(SnackBar(
        content: const Text('Failed to import backup: The file could not be read or the backup format is invalid.'),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  static Future<void> exportSinglePlaylist(
    BuildContext context,
    Playlist playlist,
    List<Song> songs,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    // Format Selection Dialog
    final String? chosenFormat = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).colorScheme.surfaceContainer,
          title: Text(
            'Export Playlist',
            style: AppFonts.jostStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Text(
            'Choose format for "${playlist.name}":',
            style: AppFonts.jostStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'm3u8'),
              child: Text('M3U8 (Universal)', style: AppFonts.jostStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'json'),
              child: Text('JSON (Full Metadata)', style: AppFonts.jostStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: Text('Cancel', style: AppFonts.jostStyle(color: Colors.white54)),
            ),
          ],
        );
      },
    );

    if (chosenFormat == null) return;

    final sanitizedName = playlist.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final String defaultFileName = '$sanitizedName.$chosenFormat';

    String? savePath;
    try {
      savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Playlist "${playlist.name}"',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: [chosenFormat],
      );
    } catch (e) {
      LoggerHelper.write('ImportExportService: FilePicker.saveFile fallback required: $e');
    }

    String content;
    if (chosenFormat == 'json') {
      final jsonMap = {
        'type': 'looper_playlist',
        'version': 1,
        'name': playlist.name,
        'dateCreated': playlist.dateCreated.toIso8601String(),
        'dateModified': playlist.dateModified.toIso8601String(),
        'songs': songs.map((s) => {
          'path': s.path,
          'title': s.title,
          'artist': s.artist,
          'album': s.album,
          'duration': s.duration,
        }).toList(),
      };
      content = const JsonEncoder.withIndent('  ').convert(jsonMap);
    } else {
      // M3U8 format
      final buffer = StringBuffer();
      buffer.writeln('#EXTM3U');
      buffer.writeln('#PLAYLIST:${playlist.name}');
      for (final s in songs) {
        final durationSec = s.duration != null ? (s.duration! / 1000).round() : -1;
        final artistStr = s.artist ?? 'Unknown Artist';
        buffer.writeln('#EXTINF:$durationSec,$artistStr - ${s.title}');
        buffer.writeln(s.path);
      }
      content = buffer.toString();
    }

    if (savePath != null && savePath.isNotEmpty) {
      final file = File(savePath);
      await file.writeAsString(content);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Exported playlist "${playlist.name}"'),
          backgroundColor: Colors.green.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static Future<void> importPlaylistFiles(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['m3u', 'm3u8', 'json'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return;

      // Pre-load all songs in library for fast matching
      final allLibrarySongs = await DbService.isar.songs.where().findAll();
      final exactPathMap = <String, String>{};
      final filenameMap = <String, String>{};
      final titleArtistMap = <String, String>{};

      for (final song in allLibrarySongs) {
        exactPathMap[song.path.toLowerCase()] = song.path;
        final fname = song.path.split(RegExp(r'[/\\]')).last.toLowerCase();
        filenameMap[fname] = song.path;
        if (song.artist != null && song.artist!.isNotEmpty) {
          final key = '${song.artist!.toLowerCase()} - ${song.title.toLowerCase()}';
          titleArtistMap[key] = song.path;
        }
      }

      int playlistsImported = 0;
      int totalTracksMatched = 0;

      for (final fileObj in result.files) {
        if (fileObj.path == null) continue;
        final file = File(fileObj.path!);
        final content = await file.readAsString();
        final ext = fileObj.extension?.toLowerCase();

        String playlistName = fileObj.name.replaceAll(RegExp(r'\.[^.]+$'), '');
        final matchedSongPaths = <String>[];

        if (ext == 'json') {
          try {
            final Map<String, dynamic> data = jsonDecode(content);
            if (data.containsKey('name')) {
              playlistName = data['name'] as String;
            }
            final songList = data['songs'] as List<dynamic>? ?? [];
            for (final item in songList) {
              if (item is Map<String, dynamic>) {
                final path = item['path'] as String?;
                final title = item['title'] as String?;
                final artist = item['artist'] as String?;

                final matched = _matchTrackPath(
                  path: path,
                  title: title,
                  artist: artist,
                  exactPathMap: exactPathMap,
                  filenameMap: filenameMap,
                  titleArtistMap: titleArtistMap,
                );
                if (matched != null && !matchedSongPaths.contains(matched)) {
                  matchedSongPaths.add(matched);
                }
              }
            }
          } catch (_) {}
        } else {
          // M3U or M3U8
          final lines = LineSplitter.split(content).map((l) => l.trim()).toList();
          String? currentTitle;
          String? currentArtist;

          for (final line in lines) {
            if (line.isEmpty) continue;
            if (line.startsWith('#PLAYLIST:')) {
              playlistName = line.substring(10).trim();
            } else if (line.startsWith('#EXTINF:')) {
              final commaIdx = line.indexOf(',');
              if (commaIdx != -1) {
                final meta = line.substring(commaIdx + 1).trim();
                final parts = meta.split(' - ');
                if (parts.length >= 2) {
                  currentArtist = parts[0].trim();
                  currentTitle = parts.sublist(1).join(' - ').trim();
                } else {
                  currentTitle = meta;
                }
              }
            } else if (!line.startsWith('#')) {
              // Track path line
              final matched = _matchTrackPath(
                path: line,
                title: currentTitle,
                artist: currentArtist,
                exactPathMap: exactPathMap,
                filenameMap: filenameMap,
                titleArtistMap: titleArtistMap,
              );
              if (matched != null && !matchedSongPaths.contains(matched)) {
                matchedSongPaths.add(matched);
              }
              currentTitle = null;
              currentArtist = null;
            }
          }
        }

        if (matchedSongPaths.isNotEmpty) {
          var existing = await DbService.isar.playlists
              .filter()
              .nameEqualTo(playlistName)
              .findFirst();

          if (existing != null) {
            final merged = Set<String>.from(existing.songPaths)..addAll(matchedSongPaths);
            existing.songPaths = merged.toList();
            existing.dateModified = DateTime.now();
            await DbService.isar.writeTxn(() => DbService.isar.playlists.put(existing));
          } else {
            final newPl = Playlist()
              ..name = playlistName
              ..songPaths = matchedSongPaths
              ..dateCreated = DateTime.now()
              ..dateModified = DateTime.now();
            await DbService.isar.writeTxn(() => DbService.isar.playlists.put(newPl));
          }
          playlistsImported++;
          totalTracksMatched += matchedSongPaths.length;
        }
      }

      if (playlistsImported > 0) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Imported $playlistsImported playlist(s) ($totalTracksMatched tracks matched)'),
            backgroundColor: Colors.green.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('No matching tracks found in library for imported playlist(s)'),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e, stack) {
      LoggerHelper.write('ImportExportService: Failed to import playlist file', e, stack);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to import playlist: $e'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static String? _matchTrackPath({
    String? path,
    String? title,
    String? artist,
    required Map<String, String> exactPathMap,
    required Map<String, String> filenameMap,
    required Map<String, String> titleArtistMap,
  }) {
    // 1. Exact path match
    if (path != null && path.isNotEmpty) {
      final normPath = path.toLowerCase();
      if (exactPathMap.containsKey(normPath)) {
        return exactPathMap[normPath];
      }
      // 2. Filename match
      final fname = path.split(RegExp(r'[/\\]')).last.toLowerCase();
      if (filenameMap.containsKey(fname)) {
        return filenameMap[fname];
      }
    }
    // 3. Artist - Title match
    if (artist != null && title != null && artist.isNotEmpty && title.isNotEmpty) {
      final key = '${artist.toLowerCase()} - ${title.toLowerCase()}';
      if (titleArtistMap.containsKey(key)) {
        return titleArtistMap[key];
      }
    }
    return null;
  }
}
