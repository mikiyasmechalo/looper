import 'package:flutter/material.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/analyze/domain/analyze_models.dart';
import 'package:looper_player/features/analyze/presentation/widgets/analyze_common.dart';
import 'package:looper_player/core/l10n.dart';

/// Monday-first narrow weekday labels in the app's language.
List<String> _weekdayLabels(BuildContext context) {
  final narrow = MaterialLocalizations.of(
    context,
  ).narrowWeekdays; // Sunday-first
  return [...narrow.skip(1), narrow.first];
}

/// "When do you listen most" — a 7 (weekday) x 4 (day-part) heatmap grid
/// built from the play-event log, cell intensity = share of the accent
/// color's alpha. The busiest cell gets an outline.
class AnalyzeActivityHeatmap extends StatelessWidget {
  final List<DayPartCount> grid;
  final Color accent;

  const AnalyzeActivityHeatmap({
    super.key,
    required this.grid,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final maxPlays = grid
        .map((c) => c.plays)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final safeMax = maxPlays == 0 ? 1 : maxPlays;
    final byCell = {for (final c in grid) c.weekday * 10 + c.part.index: c};
    DayPartCount? peak;
    for (final c in grid) {
      if (c.plays > 0 && (peak == null || c.plays > peak.plays)) peak = c;
    }

    Widget cellFor(int weekday, DayPart part) {
      final match =
          byCell[weekday * 10 + part.index] ??
          DayPartCount(weekday: weekday, part: part, plays: 0);
      final isPeak = identical(match, peak);
      final intensity = match.plays / safeMax;
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: intensity),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, animatedIntensity, _) => AspectRatio(
          aspectRatio: 1,
          child: Container(
            margin: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: match.plays == 0
                  ? Colors.white.withValues(alpha: 0.04)
                  : accent.withValues(alpha: 0.12 + 0.75 * animatedIntensity),
              borderRadius: BorderRadius.circular(7),
              border: isPeak
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.85),
                      width: 1.5,
                    )
                  : null,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyzeSectionHeader(
          title: context.l10n.activityPattern,
          subtitle: context.l10n.whenYouListenMost,
        ),
        AnalyzeCard(
          padding: const EdgeInsets.all(16),
          // The label column's Expanded rows line up with the grid's rows,
          // so the Row needs the grid's height.
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 34,
                  child: Column(
                    children: [
                      const SizedBox(height: 22),
                      for (final part in DayPart.values)
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              dayPartShortName(context, part),
                              style: AppFonts.jostStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          for (final label in _weekdayLabels(context))
                            Expanded(
                              child: Center(
                                child: Text(
                                  label,
                                  style: AppFonts.jostStyle(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    fontSize: 10.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      for (final part in DayPart.values)
                        Row(
                          children: [
                            for (var weekday = 1; weekday <= 7; weekday++)
                              Expanded(child: cellFor(weekday, part)),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

