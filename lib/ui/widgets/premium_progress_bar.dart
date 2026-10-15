import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'squiggly_slider/slider.dart';
import 'package:looper_player/core/ui_utils.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/animated_duration_counter.dart';

class ExpressiveSlider extends ConsumerStatefulWidget {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final ValueChanged<Duration> onSeek;
  final VoidCallback? onSeekStart;
  final VoidCallback? onSeekEnd;
  final Color color;
  final bool showTimestamps;

  const ExpressiveSlider({
    super.key,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.onSeek,
    this.onSeekStart,
    this.onSeekEnd,
    required this.color,
    this.showTimestamps = true,
  });

  @override
  ConsumerState<ExpressiveSlider> createState() => _ExpressiveSliderState();
}

class _ExpressiveSliderState extends ConsumerState<ExpressiveSlider> {
  double? _dragValue;

  Widget _buildAnimatedDuration(Duration duration, bool isRightAligned) {
    return AnimatedDurationCounter(
      duration: duration,
      isRightAligned: isRightAligned,
      style: AppFonts.jostStyle(
        color: Colors.white70,
        fontWeight: Platform.isLinux ? FontWeight.w300 : FontWeight.w600,
        fontSize: Platform.isLinux ? 14 : 12,
      ),
    );
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final delta = event.scrollDelta.dy;
    final stepMs = widget.duration.inMilliseconds > 0
        ? (widget.duration.inMilliseconds * 0.02).round().clamp(500, 5000)
        : 1000;
    final currentMs =
        (_dragValue != null
                ? _dragValue! * widget.duration.inMilliseconds
                : widget.position.inMilliseconds)
            .round();
    final newMs = (currentMs + (delta > 0 ? -stepMs : stepMs)).clamp(
      0,
      widget.duration.inMilliseconds,
    );
    final newValue = widget.duration.inMilliseconds > 0
        ? newMs / widget.duration.inMilliseconds
        : 0.0;
    setState(() => _dragValue = newValue.clamp(0.0, 1.0));
    widget.onSeek(Duration(milliseconds: newMs));
  }

  @override
  Widget build(BuildContext context) {
    final disableSquiggle =
        ref.watch(settingsProvider.select((s) => s.disableSquiggle));
    final double progress = widget.duration.inMilliseconds > 0
        ? (widget.position.inMilliseconds / widget.duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    final displayValue = _dragValue ?? progress;
    final bool enableWave =
        !disableSquiggle && widget.isPlaying && displayValue > 0.12;
    final displayPosition = _dragValue != null
        ? widget.duration * _dragValue!
        : widget.position;

    final targetAmplitude = enableWave ? 2.0 : 0.0;

    final Widget innerSlider;
    if (disableSquiggle) {
      innerSlider = Slider(
        value: displayValue,
        onChanged: (val) {
          setState(() => _dragValue = val);
          widget.onSeek(widget.duration * val);
        },
        onChangeStart: (val) {
          setState(() => _dragValue = val);
          widget.onSeekStart?.call();
        },
        onChangeEnd: (val) {
          setState(() => _dragValue = null);
          widget.onSeekEnd?.call();
        },
        activeColor: widget.color,
        inactiveColor: Colors.white10,
      );
    } else {
      innerSlider = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: targetAmplitude),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        builder: (context, amplitude, child) {
          return SquigglySlider(
            value: displayValue,
            onChanged: (val) {
              setState(() => _dragValue = val);
              widget.onSeek(widget.duration * val);
            },
            onChangeStart: (val) {
              setState(() => _dragValue = val);
              widget.onSeekStart?.call();
            },
            onChangeEnd: (val) {
              setState(() => _dragValue = null);
              widget.onSeekEnd?.call();
            },
            activeColor: widget.color,
            inactiveColor: Colors.white10,
            squiggleAmplitude: amplitude,
            squiggleWavelength: Platform.isLinux ? 4.5 : 6.0,
            squiggleSpeed: enableWave ? (Platform.isLinux ? 0.08 : 0.05) : 0.0,
            useLineThumb: false,
          );
        },
      );
    }

    final sliderWidget = Listener(
      onPointerSignal: _onPointerSignal,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: Platform.isLinux ? 3.0 : 8.0,
          activeTrackColor: widget.color,
          trackShape: PremiumGapTrackShape(gap: Platform.isLinux ? 4 : 6),
          inactiveTrackColor: Colors.white10,
          thumbShape: LineThumbShape(
            thumbHeight: Platform.isLinux ? 12 : 16,
            thumbWidth: Platform.isLinux ? 3 : 6,
          ),
          overlayShape: SliderComponentShape.noOverlay,
        ),
        child: innerSlider,
      ),
    );

    if (Platform.isLinux) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.showTimestamps) ...[
            _buildAnimatedDuration(displayPosition, false),
            const SizedBox(width: 12),
          ],
          Expanded(child: sliderWidget),
          if (widget.showTimestamps) ...[
            const SizedBox(width: 12),
            _buildAnimatedDuration(widget.duration, true),
          ],
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        sliderWidget,
        if (widget.showTimestamps) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAnimatedDuration(displayPosition, false),
                _buildAnimatedDuration(widget.duration, true),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class LineThumbShape extends SliderComponentShape {
  final double thumbHeight;
  final double thumbWidth;

  const LineThumbShape({this.thumbHeight = 12, this.thumbWidth = 2});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbWidth, thumbHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: thumbWidth, height: thumbHeight),
        Radius.circular(thumbWidth / 2),
      ),
      paint,
    );
  }
}

class PremiumGapTrackShape extends RoundedRectSliderTrackShape {
  final double gap;

  const PremiumGapTrackShape({this.gap = 6});

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
    double additionalActiveTrackHeight = 0.0,
  }) {
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Paint activePaint = Paint()..color = sliderTheme.activeTrackColor!;

    final Paint inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor!;

    final double trackHeight = sliderTheme.trackHeight!;
    final Radius radius = Radius.circular(trackHeight / 2);

    // ACTIVE TRACK
    final RRect activeRRect = RRect.fromLTRBAndCorners(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx - gap,
      trackRect.bottom,
      topLeft: radius,
      bottomLeft: radius,
      topRight: radius,
      bottomRight: radius,
    );

    // INACTIVE TRACK
    final RRect inactiveRRect = RRect.fromLTRBAndCorners(
      thumbCenter.dx + gap,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
      topLeft: radius,
      bottomLeft: radius,
      topRight: radius,
      bottomRight: radius,
    );

    context.canvas.drawRRect(activeRRect, activePaint);
    context.canvas.drawRRect(inactiveRRect, inactivePaint);
  }
}
