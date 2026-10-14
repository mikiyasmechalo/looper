import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';

class AppBottomSheetContainer extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final bool showDragHandle;

  const AppBottomSheetContainer({
    super.key,
    required this.child,
    this.padding,
    this.height,
    this.showDragHandle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final useBlur = (settings.enableDynamicTheming || settings.keepBackgroundGradient) &&
        !settings.disableBlur &&
        !settings.isBatterySaverActive;
    final isPureBlack = settings.isBatterySaverActive ||
        (!settings.enableDynamicTheming && !settings.keepBackgroundGradient && settings.darkTheme);

    final sheetBg = isPureBlack
        ? Colors.black
        : (useBlur ? const Color(0xCC141416) : const Color(0xFF1E1E1E));

    Widget body = Container(
      height: height,
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: useBlur && !isPureBlack
            ? Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1)
            : null,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDragHandle) ...[
              const SizedBox(height: 12),
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
              const SizedBox(height: 8),
            ],
            if (height != null)
              Expanded(
                child: Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: child,
                ),
              )
            else
              Padding(
                padding: padding ?? EdgeInsets.zero,
                child: child,
              ),
          ],
        ),
      ),
    );

    if (useBlur && !isPureBlack) {
      return RepaintBoundary(
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: body,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: body,
    );
  }
}
