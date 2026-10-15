import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/premium_section.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/core/import_export_service.dart';
import 'package:looper_player/core/logger_helper.dart';
import 'package:looper_player/ui/widgets/menu_option_tile.dart';

void showSettingsOptionsBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
}) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    isScrollControlled: true,
    builder: (modalContext) => _SettingsOptionsSheetContent(
      parentContext: context,
    ),
  );
}

class _SettingsOptionsSheetContent extends ConsumerWidget {
  final BuildContext parentContext;

  const _SettingsOptionsSheetContent({
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final useBlur = !settings.disableBlur && !settings.isBatterySaverActive;
    final isPureBlack = settings.isBatterySaverActive ||
        (settings.darkTheme && !useBlur);
    final accentColor = Color(settings.accentColor);

    final sheetBg = isPureBlack
        ? Colors.black
        : (useBlur ? const Color(0x66141418) : const Color(0xFF1E1E1E));

    Widget sheetContent = Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: useBlur && !isPureBlack
            ? Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1)
            : (isPureBlack ? Border.all(color: Colors.white12, width: 1) : null),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.settings, color: Colors.white70, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings & Backups',
                        style: AppFonts.jostStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage preferences and library data',
                        style: AppFonts.jostStyle(
                          fontSize: 13,
                          color: Colors.white54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: PremiumSection(
              borderRadius: BorderRadius.circular(20),
              padding: EdgeInsets.zero,
              useExpanded: false,
              backgroundColor: useBlur
                  ? Colors.white.withValues(alpha: 0.05)
                  : (isPureBlack ? const Color(0xFF161618) : const Color(0xFF28282C)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MenuOptionTile(
                    label: 'App Settings',
                    icon: LucideIcons.settings,
                    iconColor: accentColor,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      ref.read(appNavigationProvider.notifier).setItem(NavItem.settings);
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.8,
                    color: useBlur
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.06),
                    indent: 20,
                    endIndent: 20,
                  ),
                  MenuOptionTile(
                    label: 'Export Backup (JSON)',
                    icon: LucideIcons.upload,
                    iconColor: accentColor,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      ImportExportService.exportLibraryData(parentContext);
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.8,
                    color: useBlur
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.06),
                    indent: 20,
                    endIndent: 20,
                  ),
                  MenuOptionTile(
                    label: 'Import Backup (JSON)',
                    icon: LucideIcons.download,
                    iconColor: accentColor,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      ImportExportService.importLibraryData(parentContext, ref);
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.8,
                    color: useBlur
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.06),
                    indent: 20,
                    endIndent: 20,
                  ),
                  MenuOptionTile(
                    label: 'Export Diagnostics Logs',
                    icon: LucideIcons.fileText,
                    iconColor: accentColor,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      LoggerHelper.exportLogs();
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.8,
                    color: useBlur
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.06),
                    indent: 20,
                    endIndent: 20,
                  ),
                  MenuOptionTile(
                    label: 'Clear Diagnostics Logs',
                    icon: LucideIcons.trash2,
                    iconColor: const Color(0xFFFF5252),
                    textColor: const Color(0xFFFF5252),
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      await LoggerHelper.clearLogs();
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(
                          content: Text('Logs cleared successfully'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );

    if (useBlur && !isPureBlack) {
      return RepaintBoundary(
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: sheetContent,
          ),
        ),
      );
    }

    return sheetContent;
  }
}
