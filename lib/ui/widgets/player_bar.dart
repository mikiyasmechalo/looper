import 'dart:async';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:window_manager/window_manager.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/navigation_provider.dart';
import '../../features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/ui/widgets/color_maper.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/song_options_bottom_sheet.dart';
import 'premium_progress_bar.dart';
import 'package:looper_player/core/providers.dart';
import 'package:looper_player/features/playback/presentation/mini_player_overlay_service.dart';
import 'package:looper_player/core/system_tray_service.dart';
import 'looper_dropdown.dart';

class PlayerBar extends ConsumerWidget {
  const PlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(playbackProvider.select((s) => s.currentSong));
    if (song == null) return const SizedBox.shrink();

    return const _PremiumPlayerBar();
  }
}

class _PremiumPlayerBar extends ConsumerWidget {
  const _PremiumPlayerBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final song = ref.watch(playbackProvider.select((s) => s.currentSong));
    if (song == null) return const SizedBox.shrink();

    final isFavorite = ref.watch(
      playbackProvider.select((s) => s.currentSong?.isFavorite ?? false),
    );
    final isShuffle = ref.watch(playbackProvider.select((s) => s.isShuffle));
    final repeatMode = ref.watch(playbackProvider.select((s) => s.repeatMode));
    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));

    final isLyricsActive = ref.watch(
      appNavigationProvider.select((s) => s.activeItem == NavItem.lyrics),
    );
    final isQueueActive = ref.watch(
      appNavigationProvider.select((s) => s.activeItem == NavItem.queue),
    );
    final isDynamic = ref.watch(
      settingsProvider.select((s) => s.enableDynamicTheming),
    );

    final title = song.title;
    final artist = song.artist ?? AppLocalizations.of(context)!.unknownArtist;
    final artPath = song.artPath;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isVeryNarrow = constraints.maxWidth < 600;
        final bool isTightActions = constraints.maxWidth < 900;
        final bool stackControls = constraints.maxWidth < 1100;
        final bool wideVolume = constraints.maxWidth > 1100;
        final bool hoverVolume = !isVeryNarrow && !wideVolume;

        void openPlayer() =>
            ref.read(appNavigationProvider.notifier).setPlayerExpansion(true);

        return Container(
          height: 80.s,
          margin: EdgeInsets.only(
            left: 48.s,
            right: 48.s,
            bottom: 32.sp,
            top: 0,
          ),
          decoration: BoxDecoration(
            color: isDynamic
                ? colorScheme.primary.withValues(alpha: 0.04)
                : colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 24,
                spreadRadius: -4,
              ),
            ],
          ),
          child: RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    flex: isVeryNarrow ? 3 : 4,
                    child: RepaintBoundary(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: openPlayer,
                        onSecondaryTap: () => showSongOptionsBottomSheet(
                          context: context,
                          ref: ref,
                          song: song,
                        ),
                        child: _buildSongInfo(
                          context,
                          title,
                          artist,
                          artPath,
                          isVeryNarrow,
                        ),
                      ),
                    ),
                  ),

                  if (!isVeryNarrow)
                    Container(
                      height: 40,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: Colors.white10,
                    ),

                  RepaintBoundary(
                    child: _buildControls(
                      context,
                      ref,
                      colorScheme,
                      isPlaying,
                      isShuffle,
                      repeatMode,
                      isVeryNarrow,
                      stackControls,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    flex: stackControls ? 4 : 6,
                    child: RepaintBoundary(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final position = ref.watch(
                            playbackProvider.select((s) => s.position),
                          );
                          final duration = ref.watch(
                            playbackProvider.select((s) => s.duration),
                          );
                          final isPlayingVal = ref.watch(
                            playbackProvider.select((s) => s.isPlaying),
                          );
                          return ExpressiveSlider(
                            position: position,
                            duration: duration,
                            isPlaying: isPlayingVal,
                            onSeek: (pos) =>
                                ref.read(playbackProvider.notifier).seek(pos),
                            onSeekStart: () => ref
                                .read(playbackProvider.notifier)
                                .startScrubbing(),
                            onSeekEnd: () => ref
                                .read(playbackProvider.notifier)
                                .stopScrubbing(),
                            color: colorScheme.primary,
                          );
                        },
                      ),
                    ),
                  ),

                  if (!isVeryNarrow) ...[
                    const SizedBox(width: 24),
                    Container(
                      height: 40,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: Colors.white10,
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (wideVolume) ...[
                    const SizedBox(width: 16),
                    const RepaintBoundary(child: _VolumeInlineControl()),
                    const SizedBox(width: 16),
                  ],
                  if (hoverVolume) ...[
                    const RepaintBoundary(child: _VolumeHoverControl()),
                  ],

                  if (stackControls)
                    const SizedBox(width: 16)
                  else if (hoverVolume)
                    const SizedBox(width: 8)
                  else
                    const Spacer(),

                  RepaintBoundary(
                    child: _buildActions(
                      context,
                      ref,
                      colorScheme,
                      isFavorite,
                      isLyricsActive,
                      isQueueActive,
                      isVeryNarrow,
                      isTightActions,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSongInfo(
    BuildContext context,
    String title,
    String artist,
    String? artPath,
    bool isVeryNarrow,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: (isVeryNarrow ? 40 : 56).s,
          height: (isVeryNarrow ? 40 : 56).s,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: OptimizedImage(
            imagePath: artPath,
            width: (isVeryNarrow ? 40 : 56).s,
            height: (isVeryNarrow ? 40 : 56).s,
            borderRadius: BorderRadius.circular(6),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
            placeholder: Icon(
              LucideIcons.music,
              color: Colors.white24,
              size: (isVeryNarrow ? 16 : 24).s,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: (isVeryNarrow ? 12 : 14).ts,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                artist,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: (isVeryNarrow ? 10 : 12).ts,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    bool isPlaying,
    bool isShuffle,
    RepeatMode repeatMode,
    bool isVeryNarrow,
    bool stacked,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PlayerBarIconButton(
          size: (isVeryNarrow ? 28.0 : 32.0),
          tooltip: 'Previous',
          onTap: () => ref.read(playbackProvider.notifier).skipPrevious(),
          iconBuilder: (context, isHovered) {
            return SvgPicture.asset(
              'assets/music_bar_Icons/prev_track.svg',
              width: 12,
              height: 12,
              colorFilter: ColorFilter.mode(
                isHovered ? Colors.white : Colors.white70,
                BlendMode.srcIn,
              ),
            );
          },
        ),
        const SizedBox(width: 4),
        _BouncyTap(
          onTap: () => ref.read(playbackProvider.notifier).togglePlay(),
          child: Container(
            width: (isVeryNarrow ? 28 : 36).s,
            height: (isVeryNarrow ? 28 : 36).s,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: isPlaying
                ? Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: (isVeryNarrow ? 12 : 18).s,
                  )
                : Icon(
                    Icons.play_arrow_sharp,
                    color: Colors.white,
                    size: (isVeryNarrow ? 12 : 18).s,
                  ),
          ),
        ),
        const SizedBox(width: 4),
        _PlayerBarIconButton(
          size: (isVeryNarrow ? 28.0 : 32.0),
          tooltip: 'Next',
          onTap: () => ref.read(playbackProvider.notifier).skipNext(),
          iconBuilder: (context, isHovered) {
            return SvgPicture.asset(
              'assets/music_bar_Icons/next_track.svg',
              width: 12,
              height: 12,
              colorFilter: ColorFilter.mode(
                isHovered ? Colors.white : Colors.white70,
                BlendMode.srcIn,
              ),
            );
          },
        ),
        if (!isVeryNarrow)
          Container(
            height: 40,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.white10,
          ),

        if (!isVeryNarrow)
          stacked
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildShuffle(ref, colorScheme, isShuffle),
                    const SizedBox(height: 8),
                    _buildRepeat(ref, colorScheme, repeatMode),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 12),
                    _buildShuffle(ref, colorScheme, isShuffle),
                    const SizedBox(width: 16),
                    _buildRepeat(ref, colorScheme, repeatMode),
                  ],
                ),
      ],
    );
  }

  Widget _buildShuffle(WidgetRef ref, ColorScheme colorScheme, bool isShuffle) {
    return _PlayerBarIconButton(
      size: 28.0,
      tooltip: 'Shuffle',
      isActive: isShuffle,
      onTap: () => ref.read(playbackProvider.notifier).toggleShuffle(),
      iconBuilder: (context, isHovered) {
        return SvgPicture.asset(
          'assets/music_bar_Icons/shuffle.svg',
          width: 12,
          height: 12,
          colorFilter: ColorFilter.mode(
            isShuffle
                ? colorScheme.primary
                : (isHovered ? Colors.white : Colors.white38),
            BlendMode.srcIn,
          ),
        );
      },
    );
  }

  Widget _buildRepeat(
    WidgetRef ref,
    ColorScheme colorScheme,
    RepeatMode repeatMode,
  ) {
    return _PlayerBarIconButton(
      size: 28.0,
      tooltip: repeatMode == RepeatMode.one
          ? 'Repeat (One)'
          : (repeatMode == RepeatMode.all ? 'Repeat (All)' : 'Repeat'),
      isActive: repeatMode != RepeatMode.off,
      onTap: () => ref.read(playbackProvider.notifier).nextRepeatMode(),
      iconBuilder: (context, isHovered) {
        return SvgPicture.asset(
          repeatMode == RepeatMode.one
              ? 'assets/music_bar_Icons/repeat_1.svg'
              : 'assets/music_bar_Icons/repeat.svg',
          width: 12,
          height: 12,
          colorFilter: repeatMode == RepeatMode.one
              ? null
              : ColorFilter.mode(
                  repeatMode == RepeatMode.all
                      ? (isHovered ? Colors.white : Colors.white)
                      : (isHovered ? Colors.white : Colors.white38),
                  BlendMode.srcIn,
                ),
          colorMapper: repeatMode == RepeatMode.one
              ? AccentColorMapper(colorScheme.primary)
              : null,
        );
      },
    );
  }

  Widget _buildActions(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    bool isFavorite,
    bool isLyricsActive,
    bool isQueueActive,
    bool isVeryNarrow,
    bool isTightActions,
  ) {
    final bool isCompact = isTightActions || isVeryNarrow;
    final double buttonSize = isCompact ? 28.0 : 34.0;
    final double iconSize = isCompact ? 14.0 : 16.0;
    // Favorite heart SVG has 24x24 viewBox padding so it needs a larger box to match visual icon weight
    final double favoriteIconSize = isCompact ? 17.5 : 20.0;
    final double spacing = isCompact ? 2.0 : 4.0;

    return Row(
      key: const ValueKey('player_actions_row'),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isVeryNarrow) ...[
          _PlayerBarIconButton(
            size: buttonSize,
            tooltip: 'Favorite',
            isActive: isFavorite,
            onTap: () => ref.read(playbackProvider.notifier).toggleFavorite(),
            iconBuilder: (context, isHovered) {
              return SvgPicture.asset(
                isFavorite
                    ? 'assets/music_bar_Icons/liked.svg'
                    : 'assets/music_bar_Icons/like.svg',
                width: favoriteIconSize,
                height: favoriteIconSize,
                colorFilter: ColorFilter.mode(
                  isFavorite
                      ? Colors.red
                      : (isHovered ? Colors.white : Colors.white54),
                  BlendMode.srcIn,
                ),
              );
            },
          ),
          SizedBox(width: spacing),
        ],
        _PlayerBarIconButton(
          size: buttonSize,
          tooltip: 'Lyrics',
          isActive: isLyricsActive,
          activeColor: colorScheme.primary,
          onTap: () => ref
              .read(appNavigationProvider.notifier)
              .toggleItem(NavItem.lyrics),
          iconBuilder: (context, isHovered) {
            return SvgPicture.asset(
              'assets/music_bar_Icons/lyrics.svg',
              width: iconSize,
              height: iconSize,
              colorFilter: ColorFilter.mode(
                isLyricsActive
                    ? colorScheme.primary
                    : (isHovered ? Colors.white : Colors.white54),
                BlendMode.srcIn,
              ),
            );
          },
        ),
        SizedBox(width: spacing),
        _PlayerBarIconButton(
          size: buttonSize,
          tooltip: 'Queue',
          isActive: isQueueActive,
          activeColor: colorScheme.primary,
          onTap: () => ref
              .read(appNavigationProvider.notifier)
              .toggleItem(NavItem.queue),
          iconBuilder: (context, isHovered) {
            return Icon(
              LucideIcons.listMusic,
              size: iconSize,
              color: isQueueActive
                  ? colorScheme.primary
                  : (isHovered ? Colors.white : Colors.white54),
            );
          },
        ),
        SizedBox(width: spacing),
        _FullscreenButton(size: buttonSize, iconSize: iconSize),
        SizedBox(width: spacing),
        _MiniPlayerMenuButton(size: buttonSize, iconSize: iconSize),
      ],
    );
  }
}

/// Inline volume control used on wide windows: icon + 100px slider.
class _VolumeInlineControl extends ConsumerWidget {
  const _VolumeInlineControl();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(playbackProvider.select((s) => s.volume));
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRect(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PlayerBarIconButton(
            size: 28.0,
            tooltip: volume == 0 ? 'Unmute' : 'Mute',
            onTap: () => ref.read(playbackProvider.notifier).toggleMute(),
            iconBuilder: (context, isHovered) {
              return SvgPicture.asset(
                volume == 0
                    ? 'assets/music_bar_Icons/mute.svg'
                    : 'assets/music_bar_Icons/volume.svg',
                width: 12,
                height: 12,
                colorFilter: ColorFilter.mode(
                  volume == 0
                      ? (isHovered ? Colors.white70 : Colors.white38)
                      : (isHovered ? Colors.white70 : Colors.white),
                  BlendMode.srcIn,
                ),
              );
            },
          ),
          SizedBox(
            width: 100,
            child: Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  final delta = event.scrollDelta.dy > 0 ? -0.05 : 0.05;
                  ref.read(playbackProvider.notifier).adjustVolume(delta);
                }
              },
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: Platform.isLinux ? 4.0 : 6.0,
                  trackShape: const EqualHeightTrackShape(),
                  thumbShape: LineThumbShape(
                    thumbHeight: Platform.isLinux ? 8 : 0,
                    thumbWidth: 3,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                  activeTrackColor: colorScheme.primary,
                  inactiveTrackColor: colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: volume,
                  onChanged: (vol) =>
                      ref.read(playbackProvider.notifier).setVolume(vol),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Volume icon that on hover shows a floating slider card ON TOP of the rest
/// of the UI, so the slider takes up no space on the mini player itself.
class _VolumeHoverControl extends ConsumerStatefulWidget {
  const _VolumeHoverControl();

  @override
  ConsumerState<_VolumeHoverControl> createState() =>
      _VolumeHoverControlState();
}

class _VolumeHoverControlState extends ConsumerState<_VolumeHoverControl> {
  final GlobalKey _anchorKey = GlobalKey();
  OverlayEntry? _overlay;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    _overlay?.remove();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlay != null) return;
    _hideTimer?.cancel();
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final offset = box.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const double cardWidth = 132;
    const double cardHeight = 44;
    final left = (offset.dx + box.size.width / 2 - cardWidth / 2).clamp(
      8.0,
      screenWidth - cardWidth - 8,
    );
    final top = offset.dy - cardHeight - 10;
    final overlay = Overlay.of(context);
    _overlay = OverlayEntry(
      builder: (ctx) => Positioned(
        left: left,
        top: top.clamp(8.0, screenHeight - cardHeight - 8),
        child: _VolumeHoverPopup(
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          onHoverChanged: (v) {
            if (v) {
              _hideTimer?.cancel();
            } else {
              _scheduleHide();
            }
          },
        ),
      ),
    );
    overlay.insert(_overlay!);
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 250), () {
      _overlay?.remove();
      _overlay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final volume = ref.watch(playbackProvider.select((s) => s.volume));
    return MouseRegion(
      key: _anchorKey,
      onEnter: (_) => _showOverlay(),
      onExit: (_) => _scheduleHide(),
      child: _PlayerBarIconButton(
        size: 28.0,
        tooltip: volume == 0 ? 'Unmute' : 'Mute',
        onTap: () => ref.read(playbackProvider.notifier).toggleMute(),
        iconBuilder: (context, isHovered) {
          return SvgPicture.asset(
            volume == 0
                ? 'assets/music_bar_Icons/mute.svg'
                : 'assets/music_bar_Icons/volume.svg',
            width: 12,
            height: 12,
            colorFilter: ColorFilter.mode(
              volume == 0
                  ? (isHovered ? Colors.white70 : Colors.white38)
                  : (isHovered ? Colors.white : Colors.white),
              BlendMode.srcIn,
            ),
          );
        },
      ),
    );
  }
}

class _VolumeHoverPopup extends ConsumerStatefulWidget {
  const _VolumeHoverPopup({
    required this.cardWidth,
    required this.cardHeight,
    required this.onHoverChanged,
  });

  final double cardWidth;
  final double cardHeight;
  final ValueChanged<bool> onHoverChanged;

  @override
  ConsumerState<_VolumeHoverPopup> createState() => _VolumeHoverPopupState();
}

class _VolumeHoverPopupState extends ConsumerState<_VolumeHoverPopup> {
  @override
  Widget build(BuildContext context) {
    final volume = ref.watch(playbackProvider.select((s) => s.volume));
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => widget.onHoverChanged(true),
      onExit: (_) => widget.onHoverChanged(false),
      child: Material(
        color: const Color(0xFF2A2A2A),
        elevation: 12,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: widget.cardWidth,
          height: widget.cardHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              _PlayerBarIconButton(
                size: 28.0,
                tooltip: volume == 0 ? 'Unmute' : 'Mute',
                onTap: () => ref.read(playbackProvider.notifier).toggleMute(),
                iconBuilder: (context, isHovered) {
                  return SvgPicture.asset(
                    volume == 0
                        ? 'assets/music_bar_Icons/mute.svg'
                        : 'assets/music_bar_Icons/volume.svg',
                    width: 12,
                    height: 12,
                    colorFilter: ColorFilter.mode(
                      volume == 0
                          ? (isHovered ? Colors.white70 : Colors.white38)
                          : (isHovered ? Colors.white : Colors.white),
                      BlendMode.srcIn,
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    trackShape: const EqualHeightTrackShape(),
                    thumbShape: LineThumbShape(thumbHeight: 6, thumbWidth: 3),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                    activeTrackColor: colorScheme.primary,
                    inactiveTrackColor: colorScheme.primary.withValues(
                      alpha: 0.15,
                    ),
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: volume,
                    onChanged: (v) =>
                        ref.read(playbackProvider.notifier).setVolume(v),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EqualHeightTrackShape extends RoundedRectSliderTrackShape {
  const EqualHeightTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight: 0,
    );
  }
}

class _BouncyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BouncyTap({required this.child, required this.onTap});

  @override
  State<_BouncyTap> createState() => _BouncyTapState();
}

class _BouncyTapState extends State<_BouncyTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
      ),
    );
  }
}

// ─── Mini-Player Mode picker button ──────────────────────────────────────────

/// Button shown at the far right of the player bar on desktop. Opens a small
/// popup menu that lets the user switch to either mini-player mode.
class _MiniPlayerMenuButton extends ConsumerWidget {
  final double? size;
  final double? iconSize;

  const _MiniPlayerMenuButton({this.size, this.iconSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(miniPlayerModeProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = mode != MiniPlayerMode.none;
    final service = ref.read(miniPlayerOverlayServiceProvider);

    return LooperDropdown<String>(
      value: null,
      menuAlignment: Alignment.topRight,
      width: 175,
      items: [
        LooperDropdownItem(
          value: 'mini_player',
          icon: LucideIcons.minus,
          label: Text(
            'Mini Player',
            style: TextStyle(
              color: mode == MiniPlayerMode.miniPlayer
                  ? colorScheme.primary
                  : Colors.white,
              fontSize: 13,
            ),
          ),
        ),
        LooperDropdownItem(
          value: 'corner',
          icon: LucideIcons.layoutGrid,
          label: Text(
            'Corner Widget',
            style: TextStyle(
              color: mode == MiniPlayerMode.cornerWidget
                  ? colorScheme.primary
                  : Colors.white,
              fontSize: 13,
            ),
          ),
        ),
        const LooperDropdownItem(
          value: 'minimize_tray',
          icon: LucideIcons.panelTop,
          label: Text(
            'Minimize to Tray',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
      onChanged: (result) async {
        if (result == null) return;
        if (result == 'mini_player') {
          await service.enterMiniPlayerMode();
        } else if (result == 'corner') {
          await service.enterCornerWidgetMode();
        } else if (result == 'minimize_tray') {
          await SystemTrayService.instance.minimizeToTray();
        }
      },
      customTrigger: (ctx, isOpen) {
        return _MiniPlayerTrigger(
          size: size ?? 34,
          iconSize: iconSize ?? 16,
          isOpen: isOpen,
          isActive: isActive,
          primaryColor: colorScheme.primary,
        );
      },
    );
  }
}

class _MiniPlayerTrigger extends StatefulWidget {
  final double size;
  final double iconSize;
  final bool isOpen;
  final bool isActive;
  final Color primaryColor;

  const _MiniPlayerTrigger({
    required this.size,
    required this.iconSize,
    required this.isOpen,
    required this.isActive,
    required this.primaryColor,
  });

  @override
  State<_MiniPlayerTrigger> createState() => _MiniPlayerTriggerState();
}

class _MiniPlayerTriggerState extends State<_MiniPlayerTrigger> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hoverColor = Theme.of(context).hoverColor;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: 'Mini player',
        child: Container(
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isOpen
                ? widget.primaryColor.withValues(alpha: 0.15)
                : (_isHovered ? hoverColor : Colors.transparent),
          ),
          child: Icon(
            LucideIcons.minimize2,
            size: widget.iconSize,
            color: widget.isActive
                ? widget.primaryColor
                : (widget.isOpen || _isHovered ? Colors.white : Colors.white54),
          ),
        ),
      ),
    );
  }
}

class _FullscreenButton extends ConsumerWidget {
  final double? size;
  final double? iconSize;

  const _FullscreenButton({this.size, this.iconSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double s = size ?? 34.0;
    return _PlayerBarIconButton(
      size: s,
      tooltip: 'Fullscreen Player',
      onTap: () async {
        ref.read(appNavigationProvider.notifier).setPlayerExpansion(true);
        final isMax = await windowManager.isMaximized();
        if (!isMax) {
          await windowManager.maximize();
        }
      },
      iconBuilder: (context, isHovered) {
        return Icon(
          LucideIcons.maximize,
          size: iconSize ?? 16,
          color: isHovered ? Colors.white : Colors.white54,
        );
      },
    );
  }
}

/// Generic player bar button featuring a hand cursor, circular hover backdrop,
/// and icon brightening to white on hover matching the mini-player trigger.
class _PlayerBarIconButton extends StatefulWidget {
  final double size;
  final String tooltip;
  final VoidCallback onTap;
  final Widget Function(BuildContext context, bool isHovered) iconBuilder;
  final bool isActive;
  final Color? activeColor;

  const _PlayerBarIconButton({
    required this.size,
    required this.tooltip,
    required this.onTap,
    required this.iconBuilder,
    this.isActive = false,
    this.activeColor,
  });

  @override
  State<_PlayerBarIconButton> createState() => _PlayerBarIconButtonState();
}

class _PlayerBarIconButtonState extends State<_PlayerBarIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hoverColor = Theme.of(context).hoverColor;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isActive && widget.activeColor != null
                  ? widget.activeColor!.withValues(alpha: 0.15)
                  : (_isHovered ? hoverColor : Colors.transparent),
            ),
            child: widget.iconBuilder(context, _isHovered),
          ),
        ),
      ),
    );
  }
}
