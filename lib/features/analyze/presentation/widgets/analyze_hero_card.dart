import 'package:flutter/material.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/l10n.dart';
import 'package:looper_player/features/analyze/domain/analyze_models.dart';
import 'package:looper_player/features/analyze/presentation/widgets/analyze_common.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/core/app_haptics.dart';

/// The report's opener: the most-played song, big artwork and a play button
/// that starts the Top Songs list from #1.
class AnalyzeHeroCard extends StatelessWidget {
  final SongStat stat;
  final Color accent;
  final VoidCallback onPlay;

  const AnalyzeHeroCard({
    super.key,
    required this.stat,
    required this.accent,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyzeCard(
      padding: const EdgeInsets.all(14),
      radius: 28,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withValues(alpha: 0.26),
          Colors.white.withValues(alpha: 0.04),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 118,
                height: 118,
                child: OptimizedImage(
                  imagePath: stat.song.artPath,
                  cacheWidth: 320,
                  cacheHeight: 320,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.analyzeYourTopSong.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.jostStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  stat.song.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.jostStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.4,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.song.artist ?? context.l10n.unknownArtist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.jostStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          stat.listenedMs >= 60000
                              ? '${context.l10n.playsCount(stat.playCount)} · '
                                    '${formatListeningTime(context, stat.listenedMs)}'
                              : context.l10n.playsCount(stat.playCount),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.jostStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _PlayButton(accent: accent, onTap: onPlay),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final Color accent;
  final VoidCallback onTap;
  const _PlayButton({required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final onAccent = accent.computeLuminance() > 0.45
        ? Colors.black
        : Colors.white;
    return Tooltip(
      message: context.l10n.play,
      child: Material(
        color: accent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            AppHaptics.light();
            onTap();
          },
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.play_arrow_rounded, color: onAccent, size: 24),
          ),
        ),
      ),
    );
  }
}

