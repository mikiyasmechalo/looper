import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';

/// Reusable animated duration counter that transitions digits with a smooth
/// slide-fade animation or renders static tabular text if [disableAnimatedDuration] is enabled.
class AnimatedDurationCounter extends ConsumerWidget {
  final Duration duration;
  final TextStyle? style;
  final bool isRightAligned;

  const AnimatedDurationCounter({
    super.key,
    required this.duration,
    this.style,
    this.isRightAligned = false,
  });

  static String format(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableAnimation = ref.watch(
      settingsProvider.select((s) => s.disableAnimatedDuration),
    );
    final durationStr = format(duration);

    final defaultStyle = AppFonts.jostStyle(
      color: Colors.white70,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final effectiveStyle = style != null
        ? style!.copyWith(
            fontFeatures: [
              ...?style!.fontFeatures,
              const FontFeature.tabularFigures(),
            ],
          )
        : defaultStyle;

    if (disableAnimation) {
      return Text(
        durationStr,
        style: effectiveStyle,
        textAlign: isRightAligned ? TextAlign.right : TextAlign.left,
      );
    }

    final fontSize = effectiveStyle.fontSize ?? 12.0;
    final digitWidth = (fontSize * 0.72).clamp(8.0, 16.0);
    final colonWidth = (fontSize * 0.40).clamp(4.0, 8.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          isRightAligned ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: List.generate(durationStr.length, (index) {
        final char = durationStr[index];
        final isColon = char == ':';

        return SizedBox(
          width: isColon ? colonWidth : digitWidth,
          child: isColon
              ? Text(
                  char,
                  style: effectiveStyle,
                  textAlign: TextAlign.center,
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    final isIn = (child as Text).data == char;
                    return ClipRect(
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0.0, isIn ? 0.5 : -0.5),
                          end: Offset.zero,
                        ).animate(animation),
                        child:
                            FadeTransition(opacity: animation, child: child),
                      ),
                    );
                  },
                  child: Text(
                    char,
                    key: ValueKey('$index-$char'),
                    style: effectiveStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
        );
      }),
    );
  }
}
