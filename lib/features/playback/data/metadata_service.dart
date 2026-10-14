import 'dart:io';
import 'dart:convert';

import 'lyrics_formats/id3_sylt_reader.dart';

class MetadataService {
  static Future<String?> getEmbeddedLyrics(String path) async {
    // Synced lyrics (ID3 SYLT) first: tag readers only return the
    // unsynced USLT copy stored next to them.
    if (path.toLowerCase().endsWith('.mp3')) {
      final synced = await Id3SyltReader.readFile(path);
      if (synced != null && synced.isNotEmpty) return synced;
    }
    if (Platform.isLinux || Platform.isWindows) {
      return await _getLyricsLinux(path);
    }
    return null;
  }

  static Future<String?> _getLyricsLinux(String path) async {
    try {
      final result = await Process.run('ffprobe', [
        '-v',
        'quiet',
        '-print_format',
        'json',
        '-show_format',
        path,
      ]);

      if (result.exitCode == 0) {
        final data = jsonDecode(result.stdout);
        return _extractLyricsFromJson(data);
      }
    } catch (_) {}
    return null;
  }

  static String? _extractLyricsFromJson(Map<String, dynamic> data) {
    final tags = data['format']?['tags'];
    if (tags != null) {
      return _extractLyricsFromMap(Map<String, dynamic>.from(tags));
    }
    return null;
  }

  static String? _extractLyricsFromMap(Map<String, dynamic> tags) {
    for (final key in tags.keys) {
      final lowerKey = key.toLowerCase();
      if (lowerKey == 'lyrics' ||
          lowerKey == 'unsync-lyrics' ||
          lowerKey == 'unsyncedlyrics' ||
          lowerKey == 'uslt') {
        return tags[key]?.toString();
      }
    }
    return null;
  }
}
