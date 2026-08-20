import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'providers.dart';

class ArtworkSaveHelper {
  static Future<void> saveArtworkToFile({
    required BuildContext context,
    required String sourceArtPath,
    required String defaultFileName,
  }) async {
    try {
      final srcFile = File(sourceArtPath);
      if (!await srcFile.exists()) {
        scaffoldMessengerKey.currentState?.clearSnackBars();
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('No artwork file found to save.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      final bytes = await srcFile.readAsBytes();
      final ext = sourceArtPath.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
      final sanitized = defaultFileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
      final cleanBase = sanitized.isEmpty ? 'cover' : '${sanitized}_cover';
      final fileName = '$cleanBase.$ext';

      String? savePath;

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        savePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Album Artwork',
          fileName: fileName,
          type: FileType.image,
          allowedExtensions: ['jpg', 'jpeg', 'png'],
        );
      } else {
        // Mobile platform: choose folder or save to Downloads
        try {
          final selectedDir = await FilePicker.platform.getDirectoryPath(
            dialogTitle: 'Select folder to save artwork',
          );
          if (selectedDir != null) {
            savePath = p.join(selectedDir, fileName);
          }
        } catch (_) {}

        if (savePath == null) {
          Directory? targetDir;
          try {
            targetDir = await getDownloadsDirectory();
          } catch (_) {}
          targetDir ??= await getApplicationDocumentsDirectory();
          savePath = p.join(targetDir.path, fileName);
        }
      }

      if (savePath == null) return; // User cancelled

      final destFile = File(savePath);
      await destFile.writeAsBytes(bytes);

      scaffoldMessengerKey.currentState?.clearSnackBars();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Artwork saved to ${p.basename(savePath)}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade800,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      scaffoldMessengerKey.currentState?.clearSnackBars();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Could not save artwork: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Exports artwork directly to the Pictures/Looper directory and shows a notification
  /// with a button to open the folder on Windows.
  static Future<void> exportArtworkToPicturesFolder({
    required BuildContext context,
    required String? sourceArtPath,
    required String defaultFileName,
  }) async {
    try {
      if (sourceArtPath == null || sourceArtPath.trim().isEmpty) {
        scaffoldMessengerKey.currentState?.clearSnackBars();
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('No artwork available to export.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      List<int>? bytes;
      String ext = 'jpg';

      if (sourceArtPath.startsWith('http://') || sourceArtPath.startsWith('https://')) {
        // Download from web
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse(sourceArtPath));
        final response = await request.close();
        if (response.statusCode == 200) {
          final builder = BytesBuilder();
          await for (final chunk in response) {
            builder.add(chunk);
          }
          bytes = builder.takeBytes();
          if (sourceArtPath.toLowerCase().contains('.png')) ext = 'png';
        }
        client.close();
      } else {
        // Read local file
        final srcFile = File(sourceArtPath);
        if (await srcFile.exists()) {
          bytes = await srcFile.readAsBytes();
          if (sourceArtPath.toLowerCase().endsWith('.png')) ext = 'png';
        }
      }

      if (bytes == null || bytes.isEmpty) {
        scaffoldMessengerKey.currentState?.clearSnackBars();
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Could not read artwork data.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Determine Pictures/Looper destination directory
      Directory? picturesDir;
      if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'];
        if (userProfile != null) {
          picturesDir = Directory(p.join(userProfile, 'Pictures', 'Looper'));
        }
      } else if (Platform.isAndroid || Platform.isIOS) {
        try {
          final dirs = await getExternalStorageDirectories(type: StorageDirectory.pictures);
          if (dirs != null && dirs.isNotEmpty) {
            picturesDir = Directory(p.join(dirs.first.path, 'Looper'));
          }
        } catch (_) {}
      }

      if (picturesDir == null) {
        final base = await getApplicationDocumentsDirectory();
        picturesDir = Directory(p.join(base.path, 'Pictures', 'Looper'));
      }

      if (!await picturesDir.exists()) {
        await picturesDir.create(recursive: true);
      }

      final sanitized = defaultFileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
      final cleanBase = sanitized.isEmpty ? 'cover' : '${sanitized}_cover';
      final savePath = p.join(picturesDir.path, '$cleanBase.$ext');

      final destFile = File(savePath);
      await destFile.writeAsBytes(bytes);

      scaffoldMessengerKey.currentState?.clearSnackBars();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Saved to Pictures/Looper/${p.basename(savePath)}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 3),
          action: Platform.isWindows
              ? SnackBarAction(
                  label: 'Open Folder',
                  textColor: Colors.white,
                  onPressed: () {
                    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                    Process.run('explorer.exe', ['/select,', savePath]);
                  },
                )
              : null,
        ),
      );
    } catch (e) {
      scaffoldMessengerKey.currentState?.clearSnackBars();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Could not export artwork: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
