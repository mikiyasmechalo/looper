import 'package:flutter/material.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/utils/l10n.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';

import 'lyrics_scale.dart';

/// The lyrics buttons a mouse user needs on the page itself: karaoke, full
/// screen and the lyrics menu (text size and sync style live in the menu).
class DesktopLyricsToolbar extends ConsumerWidget {
  /// Null disables the menu button (nothing is playing).
  final VoidCallback? onMenu;

  /// Lyrics-only full screen and its toggle.
  final bool isFullscreen;
  final VoidCallback? onToggleFullscreen;

  const DesktopLyricsToolbar({
    super.key,
    this.onMenu,
    this.isFullscreen = false,
    this.onToggleFullscreen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isKaraoke = ref.watch(
      playbackProvider.select((s) => s.isVocalReducerActive),
    );
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: const ValueKey('lyrics-karaoke'),
          tooltip: isKaraoke
              ? 'Vocal Reducer (Active) - Tap to disable'
              : 'Live Vocal Reducer (Karaoke)',
          onPressed: () {
            ref.read(playbackProvider.notifier).toggleVocalReducer();
          },
          icon: Icon(
            isKaraoke ? LucideIcons.mic : LucideIcons.micOff,
            size: 18,
          ),
          color: isKaraoke ? primaryColor : Colors.white70,
        ),
        if (onToggleFullscreen != null)
          IconButton(
            key: const ValueKey('lyrics-fullscreen'),
            tooltip: isFullscreen
                ? l10n.lyricsExitFullscreen
                : l10n.lyricsFullscreen,
            onPressed: onToggleFullscreen,
            icon: Icon(
              isFullscreen ? LucideIcons.minimize : LucideIcons.maximize,
              size: 18,
            ),
            color: Colors.white70,
          ),
        IconButton(
          key: const ValueKey('lyrics-menu'),
          tooltip: l10n.lyricsOptions,
          onPressed: onMenu,
          icon: const Icon(LucideIcons.moreVertical, size: 18),
          color: Colors.white70,
          disabledColor: Colors.white24,
        ),
      ],
    );
  }
}

/// A− / 100% / A+ pill for the desktop lyrics text size, shown in the lyrics
/// menu.
class LyricsSizeControl extends StatelessWidget {
  /// The user's lyrics scale (1.0 = 100%), before the automatic scale.
  final double scale;
  final VoidCallback onSmaller;
  final VoidCallback onLarger;
  final VoidCallback onReset;

  const LyricsSizeControl({
    super.key,
    required this.scale,
    required this.onSmaller,
    required this.onLarger,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canShrink = scale > LyricsScale.min + 0.001;
    final canGrow = scale < LyricsScale.max - 0.001;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SizeButton(
            key: const ValueKey('lyrics-size-smaller'),
            label: 'A−',
            fontSize: 12,
            tooltip: l10n.lyricsSizeSmaller,
            onTap: canShrink ? onSmaller : null,
          ),
          Tooltip(
            message: l10n.reset,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onReset,
              child: Container(
                width: 52,
                height: 32,
                alignment: Alignment.center,
                child: Text(
                  '${(scale * 100).round()}%',
                  style: AppFonts.jostStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          _SizeButton(
            key: const ValueKey('lyrics-size-larger'),
            label: 'A+',
            fontSize: 15,
            tooltip: l10n.lyricsSizeLarger,
            onTap: canGrow ? onLarger : null,
          ),
        ],
      ),
    );
  }
}

class _SizeButton extends StatelessWidget {
  final String label;
  final double fontSize;
  final String tooltip;
  final VoidCallback? onTap;

  const _SizeButton({
    super.key,
    required this.label,
    required this.fontSize,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 32,
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppFonts.jostStyle(
              color: onTap == null ? Colors.white24 : Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
