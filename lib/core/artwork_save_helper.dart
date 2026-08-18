import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ArtworkSaveHelper {
  static Future<void> saveArtworkToFile({
    required BuildContext context,
    required String sourceArtPath,
    required String defaultFileName,
  }) async {
    try {
      final srcFile = File(sourceArtPath);
      if (!await srcFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No artwork file found to save.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Artwork saved to ${p.basename(savePath)}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save artwork: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }
}
