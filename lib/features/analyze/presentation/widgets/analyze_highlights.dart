import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/l10n.dart';
import 'package:looper_player/features/analyze/domain/analyze_models.dart';
import 'package:looper_player/features/analyze/presentation/widgets/analyze_common.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Short, readable takeaways computed from the snapshot: when you listen
/// most, your busiest day, your top genre, and how much of the library
/// you've actually played. Cards without data are left out.
class AnalyzeHighlights extends StatelessWidget {
  final AnalyzeSnapshot snapshot;
  final Color accent;

  const AnalyzeHighlights({
    super.key,
    required this.snapshot,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final peak = snapshot.peakSlot;
    final busiest = snapshot.busiestDay;
    final topGenre = snapshot.topGenreName;
    final explored = snapshot.libraryExplored;

    final items = <_Highlight>[
      if (peak != null)
        _Highlight(
          icon: dayPartIcon(peak.part),
          label: l10n.analyzePeakTime,
          value: weekdayName(context, peak.weekday),
          caption: dayPartName(context, peak.part),
        ),
      if (busiest != null)
        _Highlight(
          icon: LucideIcons.calendarDays,
          label: l10n.analyzeBusiestDay,
          value: DateFormat.MMMd(analyzeLocale(context)).format(busiest.date),
          caption: l10n.playsCount(busiest.plays),
        ),
      if (topGenre != null)
        _Highlight(
          icon: LucideIcons.tags,
          label: l10n.analyzeTopGenre,
          value: genreLabel(context, topGenre),
          caption: '${(snapshot.topGenres.first.fraction * 100).round()}%',
        ),
      if (snapshot.totalSongsInLibrary > 0)
        _Highlight(
          icon: LucideIcons.library,
          label: l10n.analyzeLibraryExplored,
          value: '${(explored * 100).round()}%',
          caption: l10n.analyzeSongsOfTotal(
            snapshot.uniqueSongsPlayed,
            snapshot.totalSongsInLibrary,
          ),
          progress: explored,
        ),
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyzeSectionHeader(title: l10n.analyzeHighlights),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            // Two per row on a phone, four across once there's room. Rows
            // are equal-height so the one card with a progress bar doesn't
            // leave its neighbour short.
            final columns = constraints.maxWidth >= 640 ? 4 : 2;
            return Column(
              children: [
                for (var start = 0; start < items.length; start += columns)
                  Padding(
                    padding: EdgeInsets.only(top: start == 0 ? 0 : spacing),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = start; i < start + columns; i++) ...[
                            if (i != start) const SizedBox(width: spacing),
                            Expanded(
                              child: i < items.length
                                  ? _HighlightCard(
                                      item: items[i],
                                      accent: accent,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Highlight {
  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final double? progress;

  const _Highlight({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    this.progress,
  });
}

class _HighlightCard extends StatelessWidget {
  final _Highlight item;
  final Color accent;
  const _HighlightCard({required this.item, required this.accent});

  @override
  Widget build(BuildContext context) {
    return AnalyzeCard(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, color: accent, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.jostStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.jostStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            item.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.jostStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11.5,
            ),
          ),
          if (item.progress != null) ...[
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: item.progress!),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: v.clamp(0.02, 1.0),
                  minHeight: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.07),
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

