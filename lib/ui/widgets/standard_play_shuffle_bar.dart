import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';

/// A standardized action bar providing "Play All" and "Shuffle" buttons
/// with dynamic glassmorphic/blurred backgrounds when blur is enabled.
class StandardPlayShuffleBar extends ConsumerWidget {
  final VoidCallback onPlayAll;
  final VoidCallback? onShuffle;
  final List<Widget>? extraActions;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const StandardPlayShuffleBar({
    super.key,
    required this.onPlayAll,
    this.onShuffle,
    this.extraActions,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    final useBlur = (settings.enableDynamicTheming || settings.keepBackgroundGradient) &&
        !settings.disableBlur &&
        !settings.isBatterySaverActive;

    return Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Play All Button
          StandardActionButton(
            useBlur: useBlur,
            onTap: () {
              HapticFeedback.mediumImpact();
              onPlayAll();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.playAll,
                  style: AppFonts.jostStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (onShuffle != null) ...[
            const SizedBox(width: 8),
            // Shuffle Button
            StandardActionButton(
              useBlur: useBlur,
              width: 44,
              onTap: () {
                HapticFeedback.lightImpact();
                onShuffle!();
              },
              tooltip: l10n.shuffleTitle,
              child: const Icon(
                LucideIcons.shuffle,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
          if (extraActions != null) ...[
            for (final action in extraActions!) ...[
              const SizedBox(width: 8),
              action,
            ],
          ],

          if (trailing != null) ...[
            const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class StandardActionButton extends ConsumerWidget {
  final bool? useBlur;
  final VoidCallback onTap;
  final Widget child;
  final double? width;
  final double height;
  final String? tooltip;

  const StandardActionButton({
    super.key,
    this.useBlur,
    required this.onTap,
    required this.child,
    this.width,
    this.height = 42,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveBlur = useBlur ??
        (() {
          final settings = ref.watch(settingsProvider);
          return (settings.enableDynamicTheming || settings.keepBackgroundGradient) &&
              !settings.disableBlur &&
              !settings.isBatterySaverActive;
        })();

    final borderRadius = BorderRadius.circular(12);

    final buttonDecoration = BoxDecoration(
      color: effectiveBlur
          ? Colors.white.withValues(alpha: 0.08)
          : Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: borderRadius,
      border: Border.all(
        color: effectiveBlur
            ? Colors.white.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.08),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    Widget inner = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          width: width,
          height: height,
          padding: width == null
              ? const EdgeInsets.symmetric(horizontal: 16)
              : EdgeInsets.zero,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );

    Widget content = effectiveBlur
        ? ClipRRect(
            borderRadius: borderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: DecoratedBox(
                decoration: buttonDecoration,
                child: inner,
              ),
            ),
          )
        : DecoratedBox(
            decoration: buttonDecoration,
            child: inner,
          );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        waitDuration: const Duration(milliseconds: 400),
        child: content,
      );
    }

    return content;
  }
}
