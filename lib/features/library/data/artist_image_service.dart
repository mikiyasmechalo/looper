import 'dart:convert';
import 'dart:io';
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
