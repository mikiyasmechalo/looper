import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/battery_saver_provider.dart';
import 'package:looper_player/core/battery_service.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';

/// Live status banner showing battery status and active power-saving status.
class BatterySaverStatusBanner extends ConsumerWidget {
  const BatterySaverStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final batteryAsync = ref.watch(batteryInfoProvider);
    final battery = batteryAsync.valueOrNull ?? BatteryService.instance.currentInfo;
    final l10n = AppLocalizations.of(context)!;

    final isActive = settings.isBatterySaverActive;
    final isCharging = battery.isCharging;

    final Color badgeColor;
    final Color badgeBg;
    final IconData badgeIcon;
    final String statusText;

    if (isActive) {
      badgeColor = const Color(0xFFFFB300); // Amber
      badgeBg = const Color(0xFFFFB300).withValues(alpha: 0.15);
      badgeIcon = LucideIcons.zap;
      statusText = l10n.batterySaverActive;
    } else if (isCharging) {
      badgeColor = const Color(0xFF41C25E); // Green
      badgeBg = const Color(0xFF41C25E).withValues(alpha: 0.15);
      badgeIcon = LucideIcons.batteryCharging;
      statusText = 'Charging';
    } else if (battery.isAvailable) {
      badgeColor = Colors.white70;
      badgeBg = Colors.white.withValues(alpha: 0.08);
      badgeIcon = LucideIcons.battery;
      statusText = 'Battery';
    } else {
      badgeColor = Colors.white54;
      badgeBg = Colors.white.withValues(alpha: 0.05);
      badgeIcon = LucideIcons.plug;
      statusText = l10n.batteryUnavailable;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFFFB300).withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? const Color(0xFFFFB300).withValues(alpha: 0.35)
              : Colors.white10,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 14, color: badgeColor),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: AppFonts.jostStyle(
                        color: badgeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isActive)
                Text(
                  'Power Saving',
                  style: AppFonts.jostStyle(
                    color: const Color(0xFFFFB300),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 8),
            Text(
              l10n.batterySaverOptimizationsSummary,
              style: AppFonts.jostStyle(
                color: Colors.white70,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small floating pill badge displayed in the main window when Battery Saver is active.
class BatterySaverFloatingBadge extends ConsumerWidget {
  const BatterySaverFloatingBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    if (!settings.isBatterySaverActive) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final batteryAsync = ref.watch(batteryInfoProvider);
    final battery =
        batteryAsync.valueOrNull ?? BatteryService.instance.currentInfo;

    return Tooltip(
      message: '${l10n.batterySaverActive} (${battery.level}%)',
      waitDuration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(LucideIcons.zap,
                        color: Color(0xFFFFB300), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${l10n.batterySaverActive} (${battery.level}%): ${l10n.batterySaverOptimizationsSummary}',
                        style: AppFonts.jostStyle(
                            color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF1E1E1E),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFFFB300), width: 1.2),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFB300).withValues(alpha: 0.7),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.25),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.zap,
                  size: 14,
                  color: Color(0xFFFFB300),
                ),
                if (battery.isAvailable) ...[
                  const SizedBox(width: 4),
                  Text(
                    '${battery.level}%',
                    style: AppFonts.jostStyle(
                      color: const Color(0xFFFFB300),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
