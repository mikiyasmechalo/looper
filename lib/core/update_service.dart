import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:looper_player/core/providers.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class UpdateService {
  static const repoUrl = 'https://api.github.com/repos/mikiyasmechalo/looper/releases/latest';
  static const fallbackRepoUrl = 'https://api.github.com/repos/SthrNilshaaa/looper/releases/latest';
  static const fallbackHtmlUrl = 'https://github.com/mikiyasmechalo/looper/releases';

  static Future<void> checkForUpdates({
    WidgetRef? ref,
    BuildContext? context,
    bool manual = false,
  }) async {
    try {
      if (ref != null) {
        final settings = ref.read(settingsProvider);
        if (!manual && !settings.enableUpdateNotifications) {
          return;
        }
      }

      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      http.Response response = await http.get(Uri.parse(repoUrl)).timeout(
        const Duration(seconds: 8),
        onTimeout: () => http.Response('', 408),
      );

      // If user repo doesn't have releases yet, check original upstream releases as fallback
      if (response.statusCode != 200) {
        response = await http.get(Uri.parse(fallbackRepoUrl)).timeout(
          const Duration(seconds: 8),
          onTimeout: () => http.Response('', 408),
        );
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String tagName = data['tag_name'] ?? '';
        final String htmlUrl = data['html_url'] ?? fallbackHtmlUrl;

        if (ref != null && !manual) {
          final settings = ref.read(settingsProvider);
          if (settings.skippedUpdateVersion.isNotEmpty &&
              settings.skippedUpdateVersion == tagName) {
            return;
          }
        }

        if (tagName.isNotEmpty && _isUpdateAvailable(currentVersion, tagName)) {
          if (context != null && context.mounted) {
            _showUpdateDialog(context, ref, tagName, htmlUrl);
          } else {
            _showUpdateSnackbar(ref, tagName, htmlUrl);
          }
        } else if (manual) {
          final messenger = scaffoldMessengerKey.currentState;
          messenger?.clearSnackBars();
          messenger?.showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1E1E1C),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              content: Row(
                children: [
                  const Icon(LucideIcons.checkCircle2, color: Color(0xFF41C25E), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    "You're on the latest version (v$currentVersion)",
                    style: AppFonts.jostStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }
      } else if (manual) {
        final messenger = scaffoldMessengerKey.currentState;
        messenger?.clearSnackBars();
        messenger?.showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E1E1C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            content: Text(
              'No new updates found.',
              style: AppFonts.jostStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        );
      }
    } catch (_) {
      if (manual) {
        final messenger = scaffoldMessengerKey.currentState;
        messenger?.clearSnackBars();
        messenger?.showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E1E1C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            content: Text(
              'Could not check for updates. Please check your network.',
              style: AppFonts.jostStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        );
      }
    }
  }

  static bool _isUpdateAvailable(String current, String latest) {
    final startVersionRegex = RegExp(r'^\D*(\d+\..*)');
    final currentMatch = startVersionRegex.firstMatch(current);
    final latestMatch = startVersionRegex.firstMatch(latest);

    String cleanCurrent = currentMatch != null ? currentMatch.group(1)! : current;
    String cleanLatest = latestMatch != null ? latestMatch.group(1)! : latest;

    cleanCurrent = cleanCurrent.split('+')[0].split('-')[0];
    cleanLatest = cleanLatest.split('+')[0].split('-')[0];

    cleanCurrent = cleanCurrent.replaceAll(RegExp(r'[^0-9.]'), '');
    cleanLatest = cleanLatest.replaceAll(RegExp(r'[^0-9.]'), '');

    List<int> currentParts = cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> latestParts = cleanLatest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    int maxLength = currentParts.length > latestParts.length ? currentParts.length : latestParts.length;
    while (currentParts.length < maxLength) {
      currentParts.add(0);
    }
    while (latestParts.length < maxLength) {
      latestParts.add(0);
    }

    for (int i = 0; i < maxLength; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  static void _showUpdateDialog(
    BuildContext context,
    WidgetRef? ref,
    String newVersion,
    String htmlUrl,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF41C25E).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.sparkles, color: Color(0xFF41C25E), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Update Available!',
              style: AppFonts.jostStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A new release ($newVersion) is available on GitHub with improvements and fixes.',
              style: AppFonts.jostStyle(color: Colors.white70, fontSize: 14, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (ref != null) {
                ref.read(settingsProvider.notifier).updateSkippedUpdateVersion(newVersion);
              }
              Navigator.pop(ctx);
            },
            child: Text(
              'Skip This Version',
              style: AppFonts.jostStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Later',
              style: AppFonts.jostStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final Uri uri = Uri.parse(htmlUrl);
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (_) {}
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF41C25E),
              foregroundColor: Colors.black,
            ),
            icon: const Icon(LucideIcons.download, size: 16),
            label: Text(
              'Visit Releases',
              style: AppFonts.jostStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  static void _showUpdateSnackbar(WidgetRef? ref, String newVersion, String htmlUrl) {
    final state = scaffoldMessengerKey.currentState;
    if (state == null) return;

    state.clearSnackBars();
    state.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1E1C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 12),
        content: Row(
          children: [
            const Icon(LucideIcons.downloadCloud, color: Color(0xFF41C25E), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update Available ($newVersion)',
                    style: AppFonts.jostStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'New release available on GitHub.',
                    style: AppFonts.jostStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'VISIT',
          textColor: const Color(0xFF41C25E),
          onPressed: () async {
            final Uri uri = Uri.parse(htmlUrl);
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {}
          },
        ),
      ),
    );
  }
}
