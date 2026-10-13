import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/core/app_haptics.dart';
import 'package:looper_player/features/analyze/domain/analyze_models.dart';
import 'package:looper_player/features/analyze/presentation/widgets/analyze_common.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/core/l10n.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void _openGenre(WidgetRef ref, BuildContext context, GenreStat genre) {
  final name = genre.name;
  if (name.toLowerCase() == 'other') return;

  AppHaptics.light();
  final allSongs = ref.read(libraryProvider).songs;
  final isUnknown = name == 'Unknown' ||
      name == 'Unknown Genre' ||
      name == context.l10n.unknown;

  final genreSongs = allSongs.where((s) {
    if (isUnknown) {
      return s.genre == null || s.genre!.trim().isEmpty || s.genre == 'Unknown';
    }
    return (s.genre ?? '').toLowerCase() == name.toLowerCase();
  }).toList();

  if (genreSongs.isEmpty) return;

  final firstWithArt = genreSongs.firstWhere(
    (s) => s.artPath != null,
    orElse: () => genreSongs.first,
  );

  ref.read(appNavigationProvider.notifier).showCollection(
    title: genreLabel(context, name),
    subtitle: context.l10n.genre,
    art: firstWithArt.artPath,
    songs: genreSongs,
    highlightItem: NavItem.genres,
  );
}

/// Genre breakdown: an animated donut ring (hand-painted, no chart
/// dependency) that sweeps in on first build, paired with a clickable legend.
class AnalyzeGenreDonut extends ConsumerWidget {
  final List<GenreStat> genres;

  const AnalyzeGenreDonut({super.key, required this.genres});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyzeSectionHeader(title: context.l10n.genreBreakdown),
        AnalyzeCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, progress, _) => SizedBox(
                  width: 116,
                  height: 116,
                  child: CustomPaint(
                    painter: _DonutPainter(genres: genres, progress: progress),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          if (genres.isNotEmpty &&
                              genres.first.name.toLowerCase() != 'other') {
                            _openGenre(ref, context, genres.first);
                          }
                        },
                        child: MouseRegion(
                          cursor: (genres.isNotEmpty &&
                                  genres.first.name.toLowerCase() != 'other')
                              ? SystemMouseCursors.click
                              : SystemMouseCursors.basic,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                genres.isEmpty
                                    ? '—'
                                    : '${(genres.first.fraction * 100).round()}%',
                                style: AppFonts.jostStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (genres.isNotEmpty)
                                Text(
                                  genreLabel(context, genres.first.name),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.jostStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 10.5,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [for (final g in genres) _LegendRow(genre: g)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends ConsumerStatefulWidget {
  final GenreStat genre;
  const _LegendRow({required this.genre});

  @override
  ConsumerState<_LegendRow> createState() => _LegendRowState();
}

class _LegendRowState extends ConsumerState<_LegendRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final genre = widget.genre;
    final isOther = genre.name.toLowerCase() == 'other';

    final rowContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: _isHovered ? 10 : 8,
                height: _isHovered ? 10 : 8,
                decoration: BoxDecoration(
                  color: genre.color,
                  shape: BoxShape.circle,
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: genre.color.withValues(alpha: 0.6),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  genreLabel(context, genre.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.jostStyle(
                    color: _isHovered
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.5,
                    fontWeight:
                        _isHovered ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (!isOther && _isHovered)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    LucideIcons.chevronRight,
                    size: 13,
                    color: genre.color,
                  ),
                ),
              Text(
                '${(genre.fraction * 100).round()}%',
                style: AppFonts.jostStyle(
                  color: _isHovered
                      ? genre.color
                      : Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: genre.fraction.clamp(0.02, 1.0),
              minHeight: _isHovered ? 3.5 : 2.5,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(genre.color),
            ),
          ),
        ],
      ),
    );

    if (isOther) {
      return rowContent;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () => _openGenre(ref, context, genre),
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(6),
        child: rowContent,
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<GenreStat> genres;
  final double progress;
  static const _gapDegrees = 3.0;

  _DonutPainter({required this.genres, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (genres.isEmpty) return;
    final rect = Offset.zero & size;
    final strokeWidth = size.shortestSide * 0.16;
    final ringRect = rect.deflate(strokeWidth / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    var remainingSweep = 2 * math.pi * progress;
    var startAngle = -math.pi / 2;
    final gapRad = _gapDegrees * math.pi / 180;

    for (final genre in genres) {
      if (remainingSweep <= 0) break;
      final fullSweep = math.max(0.0, (2 * math.pi * genre.fraction) - gapRad);
      final sweep = math.min(fullSweep, remainingSweep);
      if (sweep > 0) {
        paint.color = genre.color;
        canvas.drawArc(ringRect, startAngle, sweep, false, paint);
      }
      startAngle += fullSweep + gapRad;
      remainingSweep -= fullSweep + gapRad;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.genres != genres;
}

