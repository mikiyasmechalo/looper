import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';

/// Reusable animated duration counter that transitions digits with a smooth
/// slide-fade animation or renders static tabular text if [disableAnimatedDuration] is enabled.
class AnimatedDurationCounter extends ConsumerStatefulWidget {
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
  ConsumerState<AnimatedDurationCounter> createState() =>
      _AnimatedDurationCounterState();
}

class _AnimatedDurationCounterState
    extends ConsumerState<AnimatedDurationCounter> {
  late String _formatted;
  Widget? _cachedWidget;
  String? _lastBuiltFormatted;
  TextStyle? _lastBuiltStyle;
  bool? _lastBuiltDisableAnimation;

  @override
  void initState() {
    super.initState();
    _formatted = AnimatedDurationCounter.format(widget.duration);
  }

  @override
  void didUpdateWidget(covariant AnimatedDurationCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration.inSeconds != widget.duration.inSeconds) {
      final next = AnimatedDurationCounter.format(widget.duration);
      if (next != _formatted) {
        _formatted = next;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimation = ref.watch(
      settingsProvider.select((s) => s.disableAnimatedDuration),
    );
    final durationStr = _formatted;

    final defaultStyle = AppFonts.jostStyle(
      color: Colors.white70,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final effectiveStyle = widget.style != null
        ? widget.style!.copyWith(
            fontFeatures: [
              ...?widget.style!.fontFeatures,
              const FontFeature.tabularFigures(),
            ],
          )
        : defaultStyle;

    if (_cachedWidget != null &&
        _lastBuiltFormatted == durationStr &&
        _lastBuiltStyle == effectiveStyle &&
        _lastBuiltDisableAnimation == disableAnimation) {
      return _cachedWidget!;
    }

    _lastBuiltFormatted = durationStr;
    _lastBuiltStyle = effectiveStyle;
    _lastBuiltDisableAnimation = disableAnimation;

    if (disableAnimation) {
      _cachedWidget = Text(
        durationStr,
        style: effectiveStyle,
        textAlign: widget.isRightAligned ? TextAlign.right : TextAlign.left,
      );
      return _cachedWidget!;
    }

    final fontSize = effectiveStyle.fontSize ?? 12.0;
    final digitWidth = (fontSize * 0.72).clamp(8.0, 16.0);
    final colonWidth = (fontSize * 0.40).clamp(4.0, 8.0);

    _cachedWidget = RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: widget.isRightAligned
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
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
      ),
    );
    return _cachedWidget!;
  }
}
