import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/analyze/domain/analyze_models.dart';
import 'package:looper_player/features/analyze/presentation/widgets/analyze_common.dart';
import 'package:looper_player/core/l10n.dart';

/// Last-30-days listening trend — a hand-painted animated bar chart built
/// from the play-event log, headed by the window's total and daily average.
/// Bars grow in from the baseline on first build; hovering over any bar
/// highlights it and reveals its exact count in real time.
class AnalyzeTrendChart extends StatefulWidget {
  final List<DailyCount> dailyCounts;
  final Color accent;

  const AnalyzeTrendChart({
    super.key,
    required this.dailyCounts,
    required this.accent,
  });

  @override
  State<AnalyzeTrendChart> createState() => _AnalyzeTrendChartState();
}

class _AnalyzeTrendChartState extends State<AnalyzeTrendChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final dailyCounts = widget.dailyCounts;
    final accent = widget.accent;
    final total = dailyCounts.fold<int>(0, (sum, d) => sum + d.plays);
    final average = dailyCounts.isEmpty ? 0.0 : total / dailyCounts.length;
    final locale = analyzeLocale(context);
    final dateFormat = DateFormat.MMMd(locale);
    final dateStyle = AppFonts.jostStyle(
      color: Colors.white.withValues(alpha: 0.4),
      fontSize: 11,
    );

    final hoveredDay = _hoveredIndex != null && _hoveredIndex! < dailyCounts.length
        ? dailyCounts[_hoveredIndex!]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyzeSectionHeader(
          title: context.l10n.listeningTrend,
          subtitle: context.l10n.last30Days,
        ),
        AnalyzeCard(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 140),
                child: hoveredDay != null
                    ? Column(
                        key: ValueKey('hover_${hoveredDay.date.millisecondsSinceEpoch}'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.playsCount(hoveredDay.plays),
                            style: AppFonts.jostStyle(
                              color: accent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE, MMM d', locale).format(hoveredDay.date),
                            style: AppFonts.jostStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        key: const ValueKey('summary'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.playsCount(total),
                            style: AppFonts.jostStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            context.l10n.analyzeAvgPerDay(
                              NumberFormat.decimalPatternDigits(
                                locale: locale,
                                decimalDigits: 1,
                              ).format(average),
                            ),
                            style: AppFonts.jostStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onHover: (event) {
                      if (dailyCounts.isEmpty) return;
                      final barWidth = constraints.maxWidth / dailyCounts.length;
                      final idx = (event.localPosition.dx / barWidth)
                          .floor()
                          .clamp(0, dailyCounts.length - 1);
                      if (_hoveredIndex != idx) {
                        setState(() => _hoveredIndex = idx);
                      }
                    },
                    onExit: (_) {
                      if (_hoveredIndex != null) {
                        setState(() => _hoveredIndex = null);
                      }
                    },
                    child: SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, progress, _) => CustomPaint(
                          painter: _TrendPainter(
                            counts: dailyCounts,
                            progress: progress,
                            color: accent,
                            averageFraction: _averageFraction(average),
                            hoveredIndex: _hoveredIndex,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              if (dailyCounts.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat.format(dailyCounts.first.date),
                      style: dateStyle,
                    ),
                    Text(
                      dateFormat.format(
                        dailyCounts[dailyCounts.length ~/ 2].date,
                      ),
                      style: dateStyle,
                    ),
                    Text(
                      dateFormat.format(dailyCounts.last.date),
                      style: dateStyle,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  double _averageFraction(double average) {
    final maxCount = widget.dailyCounts.fold<int>(
      0,
      (a, d) => d.plays > a ? d.plays : a,
    );
    return maxCount == 0 ? 0 : average / maxCount;
  }
}

class _TrendPainter extends CustomPainter {
  final List<DailyCount> counts;
  final double progress;
  final Color color;
  final double averageFraction;
  final int? hoveredIndex;

  _TrendPainter({
    required this.counts,
    required this.progress,
    required this.color,
    required this.averageFraction,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (counts.isEmpty) return;
    var maxCount = 0;
    var peakIndex = -1;
    for (var i = 0; i < counts.length; i++) {
      if (counts[i].plays >= maxCount && counts[i].plays > 0) {
        maxCount = counts[i].plays;
        peakIndex = i;
      }
    }
    final safeMax = maxCount == 0 ? 1 : maxCount;
    final barWidth = size.width / counts.length;
    // The window always ends today (see AnalyzeSnapshot._computeDailyCounts).
    final todayIndex = counts.length - 1;

    // Draw subtle column highlight behind hovered bar
    if (hoveredIndex != null && hoveredIndex! >= 0 && hoveredIndex! < counts.length) {
      final hLeft = hoveredIndex! * barWidth;
      final hRight = (hoveredIndex! + 1) * barWidth;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(hLeft + barWidth * 0.05, 0, hRight - barWidth * 0.05, size.height),
          const Radius.circular(5),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.08),
      );
    }

    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < counts.length; i++) {
      final count = counts[i];
      final left = i * barWidth + barWidth * 0.2;
      final right = (i + 1) * barWidth - barWidth * 0.2;
      final isHovered = hoveredIndex == i;

      if (count.plays == 0) {
        paint.color = isHovered
            ? Colors.white.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.06);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTRB(left, size.height - 3, right, size.height),
            topLeft: const Radius.circular(2),
            topRight: const Radius.circular(2),
          ),
          paint,
        );
        continue;
      }

      final barHeight = (size.height - 4) * (count.plays / safeMax) * progress;
      final strong = i == peakIndex || i == todayIndex;

      if (isHovered) {
        paint.color = Color.lerp(color, Colors.white, 0.25)!;
      } else if (hoveredIndex != null) {
        paint.color = color.withValues(alpha: strong ? 0.45 : 0.2);
      } else {
        paint.color = color.withValues(alpha: strong ? 1.0 : 0.5);
      }

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTRB(left, size.height - barHeight, right, size.height),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        paint,
      );
    }

    // Dashed daily-average guide.
    if (averageFraction > 0) {
      final y = size.height - (size.height - 4) * averageFraction * progress;
      final dash = Paint()
        ..color = Colors.white.withValues(alpha: hoveredIndex != null ? 0.15 : 0.28)
        ..strokeWidth = 1;
      for (var x = 0.0; x < size.width; x += 7) {
        canvas.drawLine(Offset(x, y), Offset(x + 3.5, y), dash);
      }
    }

    // Draw tooltip pill directly on/above the hovered bar showing the exact number
    if (hoveredIndex != null && hoveredIndex! >= 0 && hoveredIndex! < counts.length) {
      final count = counts[hoveredIndex!];
      final left = hoveredIndex! * barWidth + barWidth * 0.2;
      final right = (hoveredIndex! + 1) * barWidth - barWidth * 0.2;
      final barCenterX = (left + right) / 2;
      final barHeight = count.plays == 0
          ? 3.0
          : (size.height - 4) * (count.plays / safeMax) * progress;

      final textSpan = TextSpan(
        text: '${count.plays}',
        style: AppFonts.jostStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      const paddingH = 6.0;
      const paddingV = 3.0;
      final tooltipW = tp.width + paddingH * 2;
      final tooltipH = tp.height + paddingV * 2;

      final clampedCenterX = barCenterX.clamp(tooltipW / 2 + 2, size.width - tooltipW / 2 - 2);
      final tooltipLeft = clampedCenterX - tooltipW / 2;

      double tooltipTop = (size.height - barHeight) - tooltipH - 6;
      if (tooltipTop < 2) {
        tooltipTop = (size.height - barHeight) + 6;
      }

      final pillRect = Rect.fromLTWH(tooltipLeft, tooltipTop, tooltipW, tooltipH);

      // Shadow
      canvas.drawRRect(
        RRect.fromRectAndRadius(pillRect.shift(const Offset(0, 2)), const Radius.circular(6)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Tooltip pill background
      canvas.drawRRect(
        RRect.fromRectAndRadius(pillRect, const Radius.circular(6)),
        Paint()..color = const Color(0xFF1C1C1E),
      );

      // Tooltip border with accent touch
      canvas.drawRRect(
        RRect.fromRectAndRadius(pillRect, const Radius.circular(6)),
        Paint()
          ..color = color.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      // Draw text
      tp.paint(canvas, Offset(tooltipLeft + paddingH, tooltipTop + paddingV));
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.counts != counts ||
      oldDelegate.color != color ||
      oldDelegate.averageFraction != averageFraction ||
      oldDelegate.hoveredIndex != hoveredIndex;
}

