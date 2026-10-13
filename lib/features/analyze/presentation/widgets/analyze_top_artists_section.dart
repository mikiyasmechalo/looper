import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/l10n.dart';
import 'package:looper_player/features/analyze/domain/analyze_models.dart';
import 'package:looper_player/features/analyze/presentation/widgets/analyze_common.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/app_haptics.dart';

/// Ranked "Top Artists": a carousel of round portraits, each with a ring
/// showing its plays against the #1 artist. Tapping one opens the artist.
class AnalyzeTopArtistsSection extends ConsumerWidget {
  final List<ArtistStat> topArtists;
  final Color accent;

  const AnalyzeTopArtistsSection({
    super.key,
    required this.topArtists,
    required this.accent,
  });

  void _open(WidgetRef ref, BuildContext context, ArtistStat stat) {
    AppHaptics.light();
    final songs = ref
        .read(libraryProvider)
        .songs
        .where((s) => (s.artist ?? 'Unknown Artist') == stat.name)
        .toList();
    final url = stat.imageUrl;
    final isNetwork = url != null && url.startsWith('http');
    ref
        .read(appNavigationProvider.notifier)
        .showCollection(
          title: stat.name,
          subtitle: context.l10n.artist,
          art: url != null && !isNetwork ? url : stat.imagePath,
          imageUrl: isNetwork ? url : null,
          songs: songs,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyzeSectionHeader(title: context.l10n.topArtists),
        SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            physics: const BouncingScrollPhysics(),
            itemCount: topArtists.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) => _ArtistAvatar(
              stat: topArtists[i],
              accent: accent,
              onTap: () => _open(ref, context, topArtists[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArtistAvatar extends StatefulWidget {
  final ArtistStat stat;
  final Color accent;
  final VoidCallback onTap;

  const _ArtistAvatar({
    required this.stat,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_ArtistAvatar> createState() => _ArtistAvatarState();
}

class _ArtistAvatarState extends State<_ArtistAvatar> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final url = widget.stat.imageUrl;
    final isNetwork = url != null && url.startsWith('http');
    final isFirst = widget.stat.rank == 1;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: SizedBox(
        width: 96,
        child: InkWell(
          onTap: widget.onTap,
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              AnimatedScale(
                scale: _isHovered ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated drop shadow / glow on hover (scales with avatar)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        width: _isHovered ? 96 : 84,
                        height: _isHovered ? 96 : 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: _isHovered
                              ? [
                                  BoxShadow(
                                    color: widget.accent.withValues(alpha: 0.55),
                                    blurRadius: 24,
                                    spreadRadius: 4,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: widget.stat.share),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, share, _) => SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: share.clamp(0.03, 1.0),
                            strokeWidth: _isHovered ? 3.5 : 3,
                            strokeCap: StrokeCap.round,
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            valueColor: AlwaysStoppedAnimation(widget.accent),
                          ),
                        ),
                      ),
                      ClipOval(
                        child: SizedBox(
                          width: 82,
                          height: 82,
                          child: OptimizedImage(
                            imageUrl: isNetwork ? url : null,
                            imagePath: url != null && !isNetwork
                                ? url
                                : widget.stat.imagePath,
                            placeholder: Container(
                              color: Colors.white.withValues(alpha: 0.05),
                              child: const Icon(
                                LucideIcons.user,
                                size: 28,
                                color: Colors.white38,
                              ),
                            ),
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        bottom: 0,
                        end: 2,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          constraints: const BoxConstraints(minWidth: 26),
                          height: 26,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isFirst ? widget.accent : const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: _isHovered ? Colors.white : Colors.black,
                              width: _isHovered ? 1.5 : 2,
                            ),
                            boxShadow: _isHovered
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            '${widget.stat.rank}',
                            style: AppFonts.jostStyle(
                              color: isFirst
                                  ? (widget.accent.computeLuminance() > 0.45
                                        ? Colors.black
                                        : Colors.white)
                                  : Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: AppFonts.jostStyle(
                  color: _isHovered ? widget.accent : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                child: Text(
                  widget.stat.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                context.l10n.playsCount(widget.stat.totalPlays),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppFonts.jostStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

