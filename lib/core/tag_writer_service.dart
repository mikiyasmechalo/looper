import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:ffmpeg_kit_flutter_new_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_full/return_code.dart';
import 'logger_helper.dart';

class TagWriterService {
  /// Writes updated metadata directly to the physical audio file using FFmpeg stream-copy.
  /// 100% preserves embedded artwork, audio stream quality (0 re-encoding), and unedited tags.
  static Future<bool> writeToFile({
    required String filePath,
    String? title,
    String? artist,
    String? albumArtist,
    String? album,
    int? trackNumber,
    int? trackTotal,
    int? discNumber,
    int? discTotal,
    int? year,
    String? genre,
    String? lyrics,
    String? newArtPath, // null = preserve existing; '' = remove art; non-empty = replace art
    String? fallbackArtPath,
  }) async {
    final originalFile = File(filePath);
    if (!await originalFile.exists()) {
      LoggerHelper.write('TagWriterService: Target file does not exist: $filePath');
      return false;
    }

    final ext = p.extension(filePath);
    final dir = p.dirname(filePath);
    final tempFileName = '.__looper_edit_${DateTime.now().millisecondsSinceEpoch}$ext';
    final tempFilePath = p.join(dir, tempFileName);
    final tempFile = File(tempFilePath);

    try {
      final List<String> args = ['-y', '-i', filePath];

      final bool isReplacingArt = newArtPath != null && newArtPath.isNotEmpty;
      final bool isClearingArt = newArtPath == '';

      if (isReplacingArt) {
        final artFile = File(newArtPath);
        if (await artFile.exists()) {
          args.addAll(['-i', newArtPath]);
          args.addAll(['-map', '0:a', '-map', '1:v']);
          args.addAll(['-c', 'copy']);
          args.addAll(['-disposition:v:0', 'attached_pic']);
          args.addAll(['-metadata:s:v', 'title=Album cover', '-metadata:s:v', 'comment=Cover (front)']);
        } else {
          // Fallback to preserve all streams if art file not found
          args.addAll(['-map', '0', '-c', 'copy']);
        }
      } else if (isClearingArt) {
        args.addAll(['-map', '0:a', '-c', 'copy', '-vn']);
      } else {
        // PRESERVE ALL EXISTING STREAMS (including embedded album artwork stream 100% byte-for-byte)
        args.addAll(['-map', '0', '-c', 'copy']);
      }

      // Metadata overrides
      if (title != null && title.trim().isNotEmpty) {
        args.addAll(['-metadata', 'title=${title.trim()}']);
      }
      if (artist != null && artist.trim().isNotEmpty) {
        args.addAll(['-metadata', 'artist=${artist.trim()}']);
      }
      if (albumArtist != null && albumArtist.trim().isNotEmpty) {
        args.addAll([
          '-metadata', 'album_artist=${albumArtist.trim()}',
          '-metadata', 'ALBUMARTIST=${albumArtist.trim()}',
        ]);
      }
      if (album != null && album.trim().isNotEmpty) {
        args.addAll(['-metadata', 'album=${album.trim()}']);
      }

      if (trackNumber != null && trackNumber > 0) {
        final trackStr = (trackTotal != null && trackTotal > 0)
            ? '$trackNumber/$trackTotal'
            : '$trackNumber';
        args.addAll(['-metadata', 'track=$trackStr']);
      }

      if (discNumber != null && discNumber > 0) {
        final discStr = (discTotal != null && discTotal > 0)
            ? '$discNumber/$discTotal'
            : '$discNumber';
        args.addAll(['-metadata', 'disc=$discStr']);
      }

      if (year != null && year > 0) {
        args.addAll([
          '-metadata', 'date=$year',
          '-metadata', 'year=$year',
        ]);
      }

      if (genre != null && genre.trim().isNotEmpty) {
        args.addAll(['-metadata', 'genre=${genre.trim()}']);
      }

      if (lyrics != null && lyrics.trim().isNotEmpty) {
        args.addAll([
          '-metadata', 'lyrics=${lyrics.trim()}',
          '-metadata', 'UNSYNCEDLYRICS=${lyrics.trim()}',
        ]);
      }

      // MP3 tag versioning
      if (ext.toLowerCase() == '.mp3') {
        args.addAll(['-id3v2_version', '3', '-write_id3v1', '1']);
      }

      args.add(tempFilePath);

      LoggerHelper.write('TagWriterService: Executing FFmpeg with args: $args');

      bool executionSuccess = false;

      // 1. First try system FFmpeg process on desktop
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        try {
          final res = await Process.run('ffmpeg', args);
          if (res.exitCode == 0 && await tempFile.exists() && await tempFile.length() > 512) {
            executionSuccess = true;
          } else {
            LoggerHelper.write('TagWriterService: System ffmpeg exited with ${res.exitCode}: ${res.stderr}');
          }
        } catch (e) {
          LoggerHelper.write('TagWriterService: System ffmpeg process failed, falling back to FFmpegKit: $e');
        }
      }

      // 2. Fallback to FFmpegKit (or primary on mobile)
      if (!executionSuccess) {
        try {
          final session = await FFmpegKit.executeWithArguments(args);
          final returnCode = await session.getReturnCode();
          if (ReturnCode.isSuccess(returnCode) && await tempFile.exists() && await tempFile.length() > 512) {
            executionSuccess = true;
          } else {
            final logs = await session.getAllLogsAsString();
            LoggerHelper.write('TagWriterService: FFmpegKit failed: $logs');
          }
        } catch (e, s) {
          LoggerHelper.write('TagWriterService: FFmpegKit execution exception: $e', e, s);
        }
      }

      if (!executionSuccess || !await tempFile.exists() || await tempFile.length() < 512) {
        if (await tempFile.exists()) {
          try {
            await tempFile.delete();
          } catch (_) {}
        }
        return false;
      }

      // 3. Safe Atomic File Replacement
      final backupPath = '$filePath.bak.${DateTime.now().millisecondsSinceEpoch}';
      final backupFile = File(backupPath);

      try {
        await originalFile.rename(backupPath);
      } catch (e) {
        // If rename fails (e.g. cross-volume), try copy & delete
        await tempFile.copy(filePath);
        await tempFile.delete();
        return true;
      }

      try {
        await tempFile.rename(filePath);
        if (await backupFile.exists()) {
          await backupFile.delete();
        }
        LoggerHelper.write('TagWriterService: File successfully updated on disk: $filePath');
        return true;
      } catch (e) {
        // Rollback from backup if renaming failed
        if (await backupFile.exists()) {
          await backupFile.rename(filePath);
        }
        rethrow;
      }
    } catch (e, s) {
      LoggerHelper.write('TagWriterService: Critical write error', e, s);
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      return false;
    }
  }
}
