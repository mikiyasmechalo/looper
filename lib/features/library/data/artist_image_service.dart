import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/library/domain/models/models.dart';

class ArtistImageService {
  static const String baseUrl = 'https://api.deezer.com';

  Future<String?> getArtistImage(String artistName) async {
    try {
      // Return an existing cached image without hitting the network. Downloaded
      // files survive library resets (they live outside the database), so this
      // prevents re-downloading after Reset & Rescan.
      final cached = await findLocalImage(artistName);
      if (cached != null) return cached;

      final settings = await DbService.isar.appSettings.get(0);
      if (settings != null && !settings.enableInternet) {
        return null;
      }
      final url = Uri.parse(
        '$baseUrl/search/artist',
      ).replace(queryParameters: {'q': artistName, 'limit': '1'});

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          final imageUrl = data['data'][0]['picture_big'] ??
              data['data'][0]['picture_medium'];
          
          if (imageUrl != null) {
            return await _downloadAndSaveImage(artistName, imageUrl);
          }
        }
      }
    } catch (e) {

    }
    return null;
  }

  /// Returns the path of an already-downloaded artist image for [artistName]
  /// if it exists on disk, without touching the network.
  Future<String?> findLocalImage(String artistName) async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final fileName = '${artistName.replaceAll(RegExp(r'[^\w\s]+'), '')}.jpg';
      final file = File(p.join(appDir.path, 'artist_images', fileName));
      if (await file.exists()) return file.path;
    } catch (e) {

    }
    return null;
  }

  /// Splits a collaboration artist name like "A ft. B" / "C & D" / "E, F & G"
  /// into its individual artist names so each can be looked up separately.
  /// Returns up to 4 trimmed, non-empty, de-duplicated names.
  static List<String> splitArtistNames(String artistName) {
    final parts = artistName.split(
      RegExp(
        r'\s+(?:ft\.?|feat\.?|featuring|vs\.?|with|and|&|\+|\/|x)\s+|,\s*',
        caseSensitive: false,
      ),
    );
    final result = <String>[];
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isEmpty || result.contains(trimmed)) continue;
      result.add(trimmed);
      if (result.length >= 4) break;
    }
    return result;
  }

  /// Returns every real (non-placeholder) artist image already on disk for
  /// [artistName], including images of collaboration partners (e.g. "A ft. B"
  /// also checks "A" and "B") and any images the user assigned manually.
  /// Generic placeholder avatars are excluded so they never end up in collages.
  /// Pass [userImageIndex] (from [loadUserImageIndex]) to avoid re-listing the
  /// images directory on every call.
  Future<List<String>> findLocalImages(
    String artistName, {
    Map<String, List<String>>? userImageIndex,
  }) async {
    final index = userImageIndex ?? await loadUserImageIndex();
    final found = <String>[];
    for (final name in splitArtistNames(artistName)) {
      if (found.length >= 4) break;

      final userPaths =
          index[name.replaceAll(RegExp(r'[^\w\s]+'), '')];
      if (userPaths != null) {
        for (final userPath in userPaths) {
          if (!found.contains(userPath)) found.add(userPath);
          if (found.length >= 4) break;
        }
      }

      final path = await findLocalImage(name);
      if (path != null &&
          !found.contains(path) &&
          !(await _isGenericImage(path))) {
        found.add(path);
      }
    }
    return found;
  }

  /// Scans the artist images directory once and indexes user-assigned images
  /// (saved as `<normalizedName>-user1.jpg` etc.) by their normalized base
  /// name, so the disk relink pass can preserve them.
  Future<Map<String, List<String>>> loadUserImageIndex() async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final artistDir = Directory(p.join(appDir.path, 'artist_images'));
      if (!await artistDir.exists()) return {};

      final index = <String, List<String>>{};
      final matcher = RegExp(r'^(.*)-user\d+\.[A-Za-z0-9]+$');
      await for (final entity in artistDir.list()) {
        if (entity is! File) continue;
        final fileName = p.basename(entity.path);
        final match = matcher.firstMatch(fileName);
        if (match != null) {
          index.putIfAbsent(match.group(1)!, () => []).add(entity.path);
        }
      }
      for (final paths in index.values) {
        paths.sort();
      }
      return index;
    } catch (_) {
      return {};
    }
  }

  /// Returns a list of local paths for [artistName]'s images. First checks the
  /// disk cache (full name + collaboration partners), then downloads whichever
  /// images are still missing via the Deezer API. Generic placeholder avatars
  /// are filtered out, so only real photos make it into the collage.
  Future<List<String>> getArtistImages(
    String artistName, {
    Map<String, List<String>>? userImageIndex,
  }) async {
    final cached = await findLocalImages(
      artistName,
      userImageIndex: userImageIndex,
    );
    if (cached.isNotEmpty) return cached;

    final settings = await DbService.isar.appSettings.get(0);
    if (settings != null && !settings.enableInternet) return const [];

    final found = <String>[];
    for (final name in splitArtistNames(artistName)) {
      if (found.length >= 4) break;
      final path = await getArtistImage(name);
      if (path != null &&
          !found.contains(path) &&
          !(await _isGenericImage(path))) {
        found.add(path);
      }
    }
    return found;
  }

  /// Returns true if [path] points to a flat generic placeholder avatar
  /// (e.g. the default image Deezer serves for artists without a photo).
  /// Real photos have thousands of distinct colours and rich detail, while
  /// placeholder avatars are mostly a single flat colour, so this is detected
  /// by sampling a small (64x64) decode of the file.
  Future<bool> _isGenericImage(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return false;
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 64,
        targetHeight: 64,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      image.dispose();
      codec.dispose();
      if (byteData == null) return false;

      final data = byteData.buffer.asUint8List();
      final pixels = data.length ~/ 4;
      if (pixels < 4) return false;

      final unique = <int>{};
      var adjDiff = 0.0;
      var first = true;
      var prevR = 0, prevG = 0, prevB = 0;
      for (var i = 0; i < pixels; i++) {
        final o = i * 4;
        final r = data[o];
        final g = data[o + 1];
        final b = data[o + 2];
        unique.add((r << 16) | (g << 8) | b);
        if (!first) {
          adjDiff += (r - prevR).abs() + (g - prevG).abs() + (b - prevB).abs();
        }
        prevR = r;
        prevG = g;
        prevB = b;
        first = false;
      }
      adjDiff = adjDiff / (pixels - 1);

      // Generics: unique ~100, adjDiff ~3. Real photos: unique >2500,
      // adjDiff >25. Wide margins, so the thresholds are conservative.
      return unique.length < 400 && adjDiff < 8;
    } catch (_) {
      return false;
    }
  }

  /// Copies user-picked image files into the artist images directory under
  /// artist-specific names, so the app can show them even if fetching failed.
  Future<List<String>> saveUserImages(
    String artistName,
    List<String> sourcePaths,
  ) async {
    final saved = <String>[];
    try {
      final appDir = await getApplicationSupportDirectory();
      final artistDir = Directory(p.join(appDir.path, 'artist_images'));
      if (!await artistDir.exists()) await artistDir.create(recursive: true);

      final base = artistName.replaceAll(RegExp(r'[^\w\s]+'), '');
      var index = 1;
      for (final src in sourcePaths) {
        final source = File(src);
        if (!await source.exists()) continue;
        final dest = File(
          p.join(artistDir.path, '$base-user$index${p.extension(src)}'),
        );
        index++;
        if (await dest.exists()) await dest.delete();
        await source.copy(dest.path);
        saved.add(dest.path);
        if (saved.length >= 4) break;
      }
    } catch (e) {

    }
    return saved;
  }

  Future<String?> _downloadAndSaveImage(
    String artistName,
    String url,
  ) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final appDir = await getApplicationSupportDirectory();
        final artistDir = Directory(p.join(appDir.path, 'artist_images'));
        if (!await artistDir.exists()) await artistDir.create(recursive: true);

        final fileName = '${artistName.replaceAll(RegExp(r'[^\w\s]+'), '')}.jpg';
        final file = File(p.join(artistDir.path, fileName));
        if (await file.exists()) return file.path;
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (e) {

    }
    return null;
  }
}
