import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';
import 'package:looper_player/core/system_tray_service.dart';

import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/app_icons.dart';
import 'package:looper_player/core/providers.dart';
import 'package:looper_player/features/playback/presentation/audio_level_provider.dart';
import 'package:looper_player/features/playback/presentation/lyrics_notifier.dart';
import 'package:looper_player/features/playback/presentation/mini_player_overlay_service.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/ui/widgets/premium_section.dart';

enum _ExpandedView { none, queue, lyrics }

class CornerWidgetPlayer extends ConsumerStatefulWidget {
  const CornerWidgetPlayer({super.key});

  @override
  ConsumerState<CornerWidgetPlayer> createState() => _CornerWidgetPlayerState();
}

class _CornerWidgetPlayerState extends ConsumerState<CornerWidgetPlayer>
    with WindowListener {
  bool _isHovered = false;
  bool _showSnapOverlay = false;
  _ExpandedView _expandedView = _ExpandedView.none;
  double? _originalY;
  bool _showVolumeHud = false;
  Timer? _volumeHudTimer;

  static const double _collapsedWidth = 330;
  static const double _collapsedHeight = 110;
  static const double _expandedWidth = 330;
  static const double _expandedHeight = 440;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  Timer? _moveDebounce;

  @override
  void dispose() {
    _moveDebounce?.cancel();
    _volumeHudTimer?.cancel();
    windowManager.removeListener(this);
    super.dispose();
  }

  void _onScrollVolume(PointerScrollEvent event) {
    final delta = event.scrollDelta.dy < 0 ? 0.05 : -0.05;
    ref.read(playbackProvider.notifier).adjustVolume(delta);
    _triggerVolumeHud();
  }

  void _triggerVolumeHud() {
    _volumeHudTimer?.cancel();
    if (!_showVolumeHud) {
      setState(() => _showVolumeHud = true);
    }
    _volumeHudTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => _showVolumeHud = false);
      }
    });
  }

  @override
  void onWindowBlur() {
    if (_showSnapOverlay) {
      setState(() => _showSnapOverlay = false);
    }
    if (_expandedView == _ExpandedView.queue) {
      _toggleExpanded(_ExpandedView.queue);
    }
  }

  @override
  void onWindowMaximize() async {
    final service = ref.read(miniPlayerOverlayServiceProvider);
    if (service.isTransitioning) return;

    final mode = ref.read(miniPlayerModeProvider);
    if (mode == MiniPlayerMode.cornerWidget) {
      await windowManager.unmaximize();
      service.exit();
    }
  }

  @override
  void onWindowMoved() async {
    final service = ref.read(miniPlayerOverlayServiceProvider);
    if (service.isTransitioning) return;

    final mode = ref.read(miniPlayerModeProvider);
    if (mode != MiniPlayerMode.cornerWidget) return;

    _moveDebounce?.cancel();
    _moveDebounce = Timer(const Duration(milliseconds: 200), () async {
      if (!mounted) return;
      final isMax = await windowManager.isMaximized();
      final isFs = await windowManager.isFullScreen();
      if (isMax || isFs) return;

      final pos = await windowManager.getPosition();
      if (pos.dx > 10 && pos.dy > 10) {
        ref
            .read(miniPlayerSettingsProvider.notifier)
            .setCornerPosition(pos.dx, pos.dy);
      }
    });
  }

  void _toggleExpanded(_ExpandedView view) async {
    final next = _expandedView == view ? _ExpandedView.none : view;
    final wasExpanded = _expandedView != _ExpandedView.none;
    final willBeExpanded = next != _ExpandedView.none;

    setState(() {
      _expandedView = next;
      _showSnapOverlay = false;
    });

    final pos = await windowManager.getPosition();

    if (willBeExpanded && !wasExpanded) {
      // ONLY adjust window position upwards if near the bottom of the screen (e.g. dy > 650)
      _originalY = pos.dy;
      if (pos.dy > 650) {
        final shift = (_expandedHeight - _collapsedHeight);
        final newY = (pos.dy - shift).clamp(20.0, double.infinity);
        await windowManager.setPosition(Offset(pos.dx, newY));
      }
      await ref
          .read(miniPlayerOverlayServiceProvider)
          .resizeCornerWidget(const Size(_expandedWidth, _expandedHeight));
    } else if (!willBeExpanded && wasExpanded) {
      // Revert window size and position
      await ref
          .read(miniPlayerOverlayServiceProvider)
          .resizeCornerWidget(const Size(_collapsedWidth, _collapsedHeight));
      if (_originalY != null && _originalY! > 650) {
        await Future.delayed(const Duration(milliseconds: 50));
        await windowManager.setPosition(Offset(pos.dx, _originalY!));
      }
      _originalY = null;
    }
  }

  Future<void> _snapTo(Alignment alignment) async {
    final padding = ref.read(miniPlayerSettingsProvider).padding;
    await windowManager.setAlignment(alignment);

    await Future.delayed(const Duration(milliseconds: 150));
    final pos = await windowManager.getPosition();

    double dx = pos.dx;
    double dy = pos.dy;

    if (alignment == Alignment.topLeft) {
      dx += padding;
      dy += padding;
    } else if (alignment == Alignment.topRight) {
      dx -= padding;
      dy += padding;
    } else if (alignment == Alignment.bottomLeft) {
      dx += padding;
      dy += padding;
    } else if (alignment == Alignment.bottomRight) {
      dx -= padding;
      dy -= padding;
    }

    await windowManager.setPosition(Offset(dx, dy));
    ref.read(miniPlayerSettingsProvider.notifier).setCornerPosition(dx, dy);
    setState(() => _showSnapOverlay = false);
  }

  Widget _buildSnapOverlay() {
    final settings = ref.watch(miniPlayerSettingsProvider);
    final padding = settings.padding;
    final alwaysOnTop = settings.alwaysOnTop;
    final visualizerEnabled = settings.visualizerEnabled;
    final accent = Theme.of(context).colorScheme.primary;

    const padOptions = [0.0, 4.0, 8.0, 12.0, 18.0, 24.0, 36.0, 48.0];

    return Positioned(
      top: 6,
      left: 6,
      right: 6,
      child: GestureDetector(
        onTap: () {}, // block taps from dismissing
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          decoration: BoxDecoration(
            color: const Color(0xFF141417).withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Snap buttons + Window Actions
              Row(
                children: [
                  _SnapBtn(
                    icon: LucideIcons.arrowUpLeft,
                    tooltip: 'Top Left',
                    onTap: () => _snapTo(Alignment.topLeft),
                  ),
                  const SizedBox(width: 3),
                  _SnapBtn(
                    icon: LucideIcons.arrowUpRight,
                    tooltip: 'Top Right',
                    onTap: () => _snapTo(Alignment.topRight),
                  ),
                  const SizedBox(width: 3),
                  _SnapBtn(
                    icon: LucideIcons.arrowDownLeft,
                    tooltip: 'Bottom Left',
                    onTap: () => _snapTo(Alignment.bottomLeft),
                  ),
                  const SizedBox(width: 3),
                  _SnapBtn(
                    icon: LucideIcons.arrowDownRight,
                    tooltip: 'Bottom Right',
                    onTap: () => _snapTo(Alignment.bottomRight),
                  ),
                  const Spacer(),
                  _ActionIconBtn(
                    icon: LucideIcons.minus,
                    tooltip: 'Minimize',
                    onTap: () => windowManager.minimize(),
                  ),
                  const SizedBox(width: 4),
                  _ActionIconBtn(
                    icon: LucideIcons.arrowDownToDot,
                    tooltip: 'Minimize to Tray',
                    onTap: () => SystemTrayService.instance.minimizeToTray(),
                  ),
                  const SizedBox(width: 4),
                  _ActionIconBtn(
                    icon: LucideIcons.x,
                    tooltip: 'Close',
                    hoverColor: Colors.red.withValues(alpha: 0.7),
                    onTap: () => windowManager.close(),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              // Row 2: Always on Top, Visualizer, Padding Pill
              Row(
                children: [
                  _TogglePill(
                    icon: LucideIcons.pin,
                    label: 'On Top',
                    isActive: alwaysOnTop,
                    accent: accent,
                    onTap: () {
                      ref
                          .read(miniPlayerSettingsProvider.notifier)
                          .setAlwaysOnTop(!alwaysOnTop);
                      windowManager.setAlwaysOnTop(!alwaysOnTop);
                    },
                  ),
                  const SizedBox(width: 6),
                  _TogglePill(
                    icon: LucideIcons.activity,
                    label: 'Visualizer',
                    isActive: visualizerEnabled,
                    accent: accent,
                    onTap: () {
                      ref
                          .read(miniPlayerSettingsProvider.notifier)
                          .setVisualizer(!visualizerEnabled);
                    },
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      final currIdx = padOptions.indexWhere(
                        (p) => (p - padding).abs() < 0.5,
                      );
                      final next =
                          padOptions[(currIdx + 1) % padOptions.length];
                      ref
                          .read(miniPlayerSettingsProvider.notifier)
                          .setPadding(next);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        'Pad: ${padding.toInt()}px',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = _expandedView != _ExpandedView.none;
    final song = ref.watch(playbackProvider.select((s) => s.currentSong));
    final volume = ref.watch(playbackProvider.select((s) => s.volume));
    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
    final settings = ref.watch(miniPlayerSettingsProvider);
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            _onScrollVolume(event);
          }
        },
        child: GestureDetector(
          onDoubleTap: () => ref.read(miniPlayerOverlayServiceProvider).exit(),
          onPanStart: (details) => windowManager.startDragging(),
          onSecondaryTapDown: (_) =>
              setState(() => _showSnapOverlay = !_showSnapOverlay),
          behavior: HitTestBehavior.translucent,
          child: SizedBox.expand(
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: Container(
                padding: const EdgeInsets.all(8),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF18181B).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Stack(
                    children: [
                      // Top Volume Scroll HUD Line (non-interactable feedback)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: AnimatedOpacity(
                            opacity: _showVolumeHud ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              height: 2.5,
                              width: double.infinity,
                              color: Colors.white.withValues(alpha: 0.12),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: (volume).clamp(
                                  0.0,
                                  1.0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: accent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withValues(alpha: 0.7),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Column(
                      children: [
                        if (isExpanded) ...[
                          SizedBox(
                            height: 94,
                            child: _buildHeaderRow(
                              isPlaying,
                              song,
                              settings,
                              accent,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: _expandedView == _ExpandedView.queue
                                      ? const _QueueDrawer(
                                          key: ValueKey('queue'),
                                        )
                                      : const _LyricsDrawer(
                                          key: ValueKey('lyrics'),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: 314,
                                  height: 94,
                                  child: _buildHeaderRow(
                                    isPlaying,
                                    song,
                                    settings,
                                    accent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Snap Menu Overlay
                    if (_showSnapOverlay) _buildSnapOverlay(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildHeaderRow(
    bool isPlaying,
    dynamic song,
    MiniPlayerSettingsState settings,
    Color accent,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Album Art & Hover Window Controls
        _AlbumArtWithControls(songPath: song?.artPath),

        const SizedBox(width: 12),

        // Info / Controls Crossfade
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Visualizer (under title section)
              if (settings.visualizerEnabled)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: _isHovered ? 0.0 : 0.35,
                    duration: const Duration(
                      milliseconds: 250,
                    ),
                    child: _CornerVisualizerWidget(
                      isPlaying: isPlaying,
                      accent: accent,
                    ),
                  ),
                ),

              // Title & Artist (Visible when NOT hovered)
              AnimatedOpacity(
                opacity: _isHovered ? 0.0 : 1.0,
                duration: const Duration(
                  milliseconds: 300,
                ),
                child: IgnorePointer(
                  ignoring: _isHovered,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(
                      right: 4,
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          song?.title ?? "No track",
                          style: AppFonts.jostStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          song?.artist ??
                              "Unknown artist",
                          style: AppFonts.jostStyle(
                            fontSize: 13,
                            color: Colors.white
                                .withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2-Row Controls (Visible WHEN hovered)
              AnimatedOpacity(
                opacity: _isHovered ? 1.0 : 0.0,
                duration: const Duration(
                  milliseconds: 300,
                ),
                child: IgnorePointer(
                  ignoring: !_isHovered,
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      // 3 at the top
                      const _TopPlaybackControls(
                        width: 48,
                        height: 32,
                      ),
                      const SizedBox(height: 6),
                      // 4 at the bottom
                      _BottomUtilControls(
                        width: 38,
                        height: 28,
                        expandedView: _expandedView,
                        onToggleExpanded: _toggleExpanded,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SnapBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SnapBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, color: Colors.white70, size: 14),
        ),
      ),
    );
  }
}

class _ActionIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color? hoverColor;
  final VoidCallback onTap;

  const _ActionIconBtn({
    required this.icon,
    required this.tooltip,
    this.hoverColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: hoverColor ?? Colors.white.withValues(alpha: 0.15),
          child: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            child: Icon(icon, size: 13, color: Colors.white70),
          ),
        ),
      ),
    );
  }
}

class _TopPlaybackControls extends ConsumerWidget {
  final double width;
  final double height;
  const _TopPlaybackControls({required this.width, required this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PremiumSection(
          heroTag: "mini_corner_prev_$width",
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            bottomLeft: Radius.circular(32),
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          width: width,
          height: height,
          showShadow: false,
          useBlur: true,
          forceNoBlur: true,
          useExpanded: false,
          onTap: () => ref.read(playbackProvider.notifier).skipPrevious(),
          child: SvgPicture.asset(
            AppIcons.prev,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            width: height * 0.4,
            height: height * 0.4,
          ),
        ),
        const SizedBox(width: 4),
        PremiumSection(
          heroTag: "mini_corner_play_pause_$width",
          borderRadius: BorderRadius.circular(12),
          width: width,
          height: height,
          showShadow: false,
          useBlur: true,
          forceNoBlur: true,
          animate: true,
          useExpanded: false,
          backgroundColor: isPlaying ? null : colorScheme.primary,
          onTap: () => ref.read(playbackProvider.notifier).togglePlay(),
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: isPlaying ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              builder: (context, value, child) {
                return AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: AlwaysStoppedAnimation(value),
                  color: isPlaying
                      ? Colors.white
                      : HSLColor.fromColor(
                          colorScheme.primary,
                        ).withLightness(0.15).toColor(),
                  size: height * 0.55,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 4),
        PremiumSection(
          heroTag: "mini_corner_next_$width",
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          width: width,
          height: height,
          showShadow: false,
          useBlur: true,
          forceNoBlur: true,
          useExpanded: false,
          onTap: () => ref.read(playbackProvider.notifier).skipNext(),
          child: SvgPicture.asset(
            AppIcons.next,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            width: height * 0.4,
            height: height * 0.4,
          ),
        ),
      ],
    );
  }
}

class _BottomUtilControls extends ConsumerWidget {
  final double width;
  final double height;
  final _ExpandedView expandedView;
  final Function(_ExpandedView) onToggleExpanded;

  const _BottomUtilControls({
    required this.width,
    required this.height,
    required this.expandedView,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShuffle = ref.watch(playbackProvider.select((s) => s.isShuffle));
    final repeatMode = ref.watch(playbackProvider.select((s) => s.repeatMode));
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Shuffle
        PremiumSection(
          heroTag: "mini_corner_shuffle_$width",
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            bottomLeft: Radius.circular(26),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          width: width,
          height: height,
          showShadow: false,
          useBlur: true,
          forceNoBlur: true,
          useExpanded: false,
          backgroundColor: isShuffle
              ? colorScheme.primary.withValues(alpha: 0.2)
              : null,
          onTap: () => ref.read(playbackProvider.notifier).toggleShuffle(),
          child: Icon(
            LucideIcons.shuffle,
            size: height * 0.5,
            color: isShuffle ? colorScheme.primary : Colors.white70,
          ),
        ),
        const SizedBox(width: 4),

        // Repeat
        PremiumSection(
          heroTag: "mini_corner_repeat_$width",
          borderRadius: BorderRadius.circular(12),
          width: width,
          height: height,
          showShadow: false,
          useBlur: true,
          forceNoBlur: true,
          useExpanded: false,
          backgroundColor: repeatMode != RepeatMode.off
              ? colorScheme.primary.withValues(alpha: 0.2)
              : null,
          onTap: () => ref.read(playbackProvider.notifier).nextRepeatMode(),
          child: Icon(
            repeatMode == RepeatMode.one
                ? LucideIcons.repeat1
                : LucideIcons.repeat,
            size: height * 0.5,
            color: repeatMode != RepeatMode.off
                ? colorScheme.primary
                : Colors.white70,
          ),
        ),
        const SizedBox(width: 4),

        // Lyrics
        PremiumSection(
          heroTag: "mini_corner_lyrics_$width",
          borderRadius: BorderRadius.circular(12),
          width: width,
          height: height,
          showShadow: false,
          useBlur: true,
          forceNoBlur: true,
          useExpanded: false,
          backgroundColor: expandedView == _ExpandedView.lyrics
              ? colorScheme.primary.withValues(alpha: 0.2)
              : null,
          onTap: () => onToggleExpanded(_ExpandedView.lyrics),
          child: Icon(
            LucideIcons.mic2,
            size: height * 0.5,
            color: expandedView == _ExpandedView.lyrics
                ? colorScheme.primary
                : Colors.white70,
          ),
        ),
        const SizedBox(width: 4),

        // Queue
        PremiumSection(
          heroTag: "mini_corner_queue_$width",
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            topRight: Radius.circular(26),
            bottomRight: Radius.circular(26),
          ),
          width: width,
          height: height,
          showShadow: false,
          useBlur: true,
          forceNoBlur: true,
          useExpanded: false,
          backgroundColor: expandedView == _ExpandedView.queue
              ? colorScheme.primary.withValues(alpha: 0.2)
              : null,
          onTap: () => onToggleExpanded(_ExpandedView.queue),
          child: Icon(
            LucideIcons.listMusic,
            size: height * 0.5,
            color: expandedView == _ExpandedView.queue
                ? colorScheme.primary
                : Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _AlbumArtWithControls extends ConsumerStatefulWidget {
  final String? songPath;
  const _AlbumArtWithControls({this.songPath});

  @override
  ConsumerState<_AlbumArtWithControls> createState() =>
      _AlbumArtWithControlsState();
}

class _AlbumArtWithControlsState extends ConsumerState<_AlbumArtWithControls> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        width: 94,
        height: 94,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white10,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.songPath != null && widget.songPath!.isNotEmpty)
              OptimizedImage(
                imagePath: widget.songPath!,
                width: 94,
                height: 94,
              )
            else
              const Center(
                child: Icon(LucideIcons.disc, size: 36, color: Colors.white24),
              ),

            AnimatedOpacity(
              opacity: _hover ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                color: Colors.black.withValues(alpha: 0.55),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _WindowBtn(
                        icon: LucideIcons.square,
                        tooltip: 'Restore Main Player',
                        onTap: () =>
                            ref.read(miniPlayerOverlayServiceProvider).exit(),
                      ),
                      const SizedBox(width: 4),
                      _WindowBtn(
                        icon: LucideIcons.x,
                        tooltip: 'Close',
                        hoverColor: Colors.red.withValues(alpha: 0.8),
                        onTap: windowManager.close,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? hoverColor;
  final String? tooltip;

  const _WindowBtn({
    required this.icon,
    required this.onTap,
    this.hoverColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: hoverColor ?? Colors.white.withValues(alpha: 0.15),
          child: Tooltip(
            message: tooltip ?? '',
            child: Center(
              child: Icon(icon, size: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color accent;
  final VoidCallback onTap;

  const _TogglePill({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? accent.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: isActive ? accent.withValues(alpha: 0.4) : Colors.white12,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 11,
              color: isActive ? accent : Colors.white60,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? accent : Colors.white70,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueDrawer extends ConsumerStatefulWidget {
  const _QueueDrawer({super.key});

  @override
  ConsumerState<_QueueDrawer> createState() => _QueueDrawerState();
}

class _QueueDrawerState extends ConsumerState<_QueueDrawer> {
  bool _isCompact = false;
  final ScrollController _scrollController = ScrollController();
  int _lastScrolledIdx = -1;

  void _scrollToCurrent(int idx) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      const double kItemHeight = 44.0;
      final max = _scrollController.position.maxScrollExtent;
      final viewport = _scrollController.position.viewportDimension;
      final target = (idx * kItemHeight - viewport / 2 + kItemHeight / 2).clamp(0.0, max);
      _scrollController.jumpTo(target);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(playbackProvider.select((s) => s.queue));
    final currentSong = ref.watch(
      playbackProvider.select((s) => s.currentSong),
    );
    final currentPath = currentSong?.path;
    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
    final accent = Theme.of(context).colorScheme.primary;

    final showPlayed =
        ref.watch(settingsProvider.select((s) => s.showPlayedSongsInQueue));
    final idx = queue.indexWhere((s) => s.path == currentPath);
    final displayed = idx == -1
        ? queue
        : (showPlayed
            ? [...queue.sublist(0, idx), ...queue.sublist(idx)]
            : queue.sublist(idx));

    // Auto-scroll to current song only when panel first opens
    if (showPlayed && idx >= 0 && _lastScrolledIdx == -1) {
      _lastScrolledIdx = idx;
      _scrollToCurrent(idx);
    } else if (!showPlayed && _lastScrolledIdx == -1) {
      _lastScrolledIdx = 0;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PLAY QUEUE',
                style: AppFonts.jostStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 6),
              if (queue.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${idx >= 0 ? idx + 1 : 1} / ${queue.length}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _isCompact = !_isCompact),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _isCompact
                        ? accent.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: _isCompact
                          ? accent.withValues(alpha: 0.4)
                          : Colors.white12,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isCompact
                            ? LucideIcons.list
                            : LucideIcons.layoutList,
                        size: 10,
                        color: _isCompact ? accent : Colors.white70,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _isCompact ? 'Compact' : 'Normal',
                        style: TextStyle(
                          color: _isCompact ? accent : Colors.white70,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (showPlayed && idx >= 0) ...[
                Tooltip(
                  message: 'Jump to current song',
                  child: GestureDetector(
                    onTap: () => _scrollToCurrent(idx),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        LucideIcons.locateFixed,
                        size: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                '${displayed.length} tracks',
                style: const TextStyle(fontSize: 10, color: Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ReorderableListView.builder(
              scrollController: _scrollController,
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.only(right: 4),
              onReorder: (oldI, newI) {
                final curDisp = showPlayed ? idx : 0;
                // Block dragging the current song
                if (idx != -1 && oldI == curDisp) return;
                if (newI > oldI) newI -= 1;
                // When played songs are hidden, don't allow dropping above current
                if (!showPlayed && idx != -1 && newI <= curDisp) {
                  newI = curDisp + 1;
                }
                if (oldI == newI) return;
                final int oldOrig;
                final int newOrig;
                if (showPlayed || idx == -1) {
                  oldOrig = oldI;
                  newOrig = newI;
                } else {
                  oldOrig = oldI + idx;
                  newOrig = newI + idx;
                }
                ref.read(playbackProvider.notifier).reorderQueueDirect(oldOrig, newOrig);
              },
              proxyDecorator: (child, index, animation) => Material(
                color: Colors.transparent,
                child: child,
              ),
              itemCount: displayed.length,
              itemBuilder: (context, i) {
                final song = displayed[i];
                final isCurrent = song.path == currentPath;
                final originalIndex = queue.indexWhere(
                  (s) => s.path == song.path,
                );
                final isPlayed = idx != -1 &&
                    originalIndex != -1 &&
                    originalIndex < idx;
                final isDraggable = !isCurrent;

                return Opacity(
                  key: ValueKey('crnq_${song.path}_$i'),
                  opacity: isPlayed ? 0.38 : 1.0,
                  child: GestureDetector(
                    onTap: () {
                      if (originalIndex != -1) {
                        ref
                            .read(playbackProvider.notifier)
                            .playAtIndex(originalIndex);
                      }
                    },
                    child: _isCompact
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? accent.withValues(alpha: 0.14)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isCurrent
                                      ? LucideIcons.disc
                                      : LucideIcons.music,
                                  size: 11,
                                  color: isCurrent ? accent : Colors.white38,
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: RichText(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: song.title ?? "Unknown Title",
                                          style: TextStyle(
                                            color: isCurrent
                                                ? accent
                                                : Colors.white.withValues(
                                                    alpha: 0.9,
                                                  ),
                                            fontSize: 11,
                                            fontWeight: isCurrent
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                        if (song.artist != null &&
                                            song.artist!.isNotEmpty) ...[
                                          TextSpan(
                                            text: "  •  ${song.artist!}",
                                            style: TextStyle(
                                              color: isCurrent
                                                  ? accent.withValues(alpha: 0.75)
                                                  : Colors.white38,
                                              fontSize: 10,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                if (isCurrent) ...[
                                  const SizedBox(width: 6),
                                  isPlaying
                                      ? Image.asset(
                                          'assets/icons/Playing.gif',
                                          width: 13,
                                          height: 13,
                                          color: accent,
                                        )
                                      : Icon(
                                          LucideIcons.pause,
                                          size: 11,
                                          color: accent.withValues(alpha: 0.8),
                                        ),
                                ],
                                if (isDraggable)
                                  ReorderableDragStartListener(
                                    index: i,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Icon(
                                        LucideIcons.gripVertical,
                                        size: 12,
                                        color: Colors.white24,
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox(width: 16),
                              ],
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? accent.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              border: isCurrent
                                  ? Border.all(
                                      color: accent.withValues(alpha: 0.35),
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    color: Colors.white10,
                                    child: song.artPath != null &&
                                            song.artPath!.isNotEmpty
                                        ? OptimizedImage(
                                            imagePath: song.artPath!,
                                            width: 32,
                                            height: 32,
                                          )
                                        : const Icon(
                                            LucideIcons.music,
                                            size: 14,
                                            color: Colors.white38,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        song.title ?? "Unknown",
                                        style: TextStyle(
                                          color: isCurrent
                                              ? accent
                                              : Colors.white.withValues(alpha: 0.9),
                                          fontSize: 12,
                                          fontWeight: isCurrent
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (song.artist != null &&
                                          song.artist!.isNotEmpty)
                                        Text(
                                          song.artist!,
                                          style: TextStyle(
                                            color: isCurrent
                                                ? accent.withValues(alpha: 0.7)
                                                : Colors.white38,
                                            fontSize: 10,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                if (isCurrent) ...[
                                  const SizedBox(width: 6),
                                  isPlaying
                                      ? Image.asset(
                                          'assets/icons/Playing.gif',
                                          width: 14,
                                          height: 14,
                                          color: accent,
                                        )
                                      : Icon(
                                          LucideIcons.pause,
                                          size: 13,
                                          color: accent.withValues(alpha: 0.8),
                                        ),
                                ],
                                if (isDraggable)
                                  ReorderableDragStartListener(
                                    index: i,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Icon(
                                        LucideIcons.gripVertical,
                                        size: 14,
                                        color: Colors.white24,
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox(width: 18),
                              ],
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LyricsDrawer extends ConsumerStatefulWidget {
  const _LyricsDrawer({super.key});

  @override
  ConsumerState<_LyricsDrawer> createState() => _LyricsDrawerState();
}

class _LyricsDrawerState extends ConsumerState<_LyricsDrawer> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _lineKeys = {};
  int _lastActiveIndex = -1;
  int _activeIndex = -1;
  Timer? _scrollTimer;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleScrollToActive(int index) {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(milliseconds: 60), () {
      if (!mounted) return;
      final currentKey = _lineKeys[index];
      if (currentKey?.currentContext != null) {
        Scrollable.ensureVisible(
          currentKey!.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          alignment: 0.38,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lyricsState = ref.watch(lyricsProvider);
    final posMs = ref.watch(
      playbackProvider.select((s) => s.position.inMilliseconds),
    );

    if (lyricsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2.5),
      );
    }
    if (lyricsState.parsedLines.isEmpty) {
      return Center(
        child: Text(
          'No lyrics found',
          style: AppFonts.jostStyle(color: Colors.white54, fontSize: 13),
        ),
      );
    }

    final lines = lyricsState.parsedLines;
    int idx =
        lines.indexWhere((l) => l.startTime.inMilliseconds > posMs) - 1;
    if (idx < -1) idx = lines.length - 1;
    if (idx == -1) idx = 0;

    _activeIndex = idx;
    if (idx != _lastActiveIndex) {
      _lastActiveIndex = idx;
      _scheduleScrollToActive(idx);
    }

    final settings = ref.watch(settingsProvider);
    final uniformFontSize = settings.uniformLyricsFontSize;
    final alignmentString = settings.lyricsAlignment;

    final textAlign = alignmentString == 'left'
        ? TextAlign.left
        : alignmentString == 'right'
            ? TextAlign.right
            : TextAlign.center;

    final lineAlignment = alignmentString == 'left'
        ? Alignment.centerLeft
        : alignmentString == 'right'
            ? Alignment.centerRight
            : Alignment.center;

    final primaryColor = Theme.of(context).colorScheme.primary;

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(scrollbars: false),
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 100),
        itemCount: lines.length,
        itemBuilder: (context, i) {
          final line = lines[i];
          final isCurrent = i == idx;
          final lineKey = _lineKeys.putIfAbsent(i, () => GlobalKey());

          return KeyedSubtree(
            key: lineKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    ref.read(playbackProvider.notifier).seek(line.startTime);
                  },
                  child: Container(
                    alignment: lineAlignment,
                    width: double.infinity,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      textAlign: textAlign,
                      style: AppFonts.jostStyle(
                        color: isCurrent
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.35),
                        fontSize: uniformFontSize
                            ? 16.0
                            : (isCurrent ? 18.5 : 14.5),
                        fontWeight: isCurrent
                            ? FontWeight.w700
                            : FontWeight.w400,
                        height: 1.35,
                        shadows: isCurrent
                            ? [
                                Shadow(
                                  color: primaryColor.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        line.text,
                        textAlign: textAlign,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CornerVisualizerWidget extends ConsumerStatefulWidget {
  final bool isPlaying;
  final Color accent;

  const _CornerVisualizerWidget({
    required this.isPlaying,
    required this.accent,
  });

  @override
  ConsumerState<_CornerVisualizerWidget> createState() =>
      _CornerVisualizerWidgetState();
}

class _CornerVisualizerWidgetState extends ConsumerState<_CornerVisualizerWidget>
    with SingleTickerProviderStateMixin {
  static const int _barCount = 20;
  final List<double> _smoothed = List.filled(_barCount, 0.0);
  static const double _attack = 0.40;
  static const double _release = 0.07;
  late Ticker _ticker;
  Duration _elapsed = Duration.zero;

  static final List<double> _sinePhase = List.generate(
    _barCount,
    (i) => (i / _barCount) * 2 * pi + (i % 3) * 1.1,
  );
  static final List<double> _sineFreq = List.generate(
    _barCount,
    (i) => 1.0 + (i % 5) * 0.3,
  );

  static final List<double> _freqGain = List.generate(_barCount, (i) {
    final norm = i / (_barCount - 1);
    return (0.55 + 0.72 * pow(norm, 0.55)).clamp(0.3, 1.3);
  });

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    if (widget.isPlaying) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant _CornerVisualizerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        if (!_ticker.isActive) _ticker.start();
      }
    }
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    _elapsed = elapsed;

    final raw = ref.read(spectrumProvider);
    final hasFftData = raw.isNotEmpty && raw.any((v) => v > 0.01);
    final t = elapsed.inMicroseconds / 1000000.0;

    bool changed = false;
    for (int i = 0; i < _barCount; i++) {
      double target;
      if (!widget.isPlaying) {
        target = 0.0;
      } else if (hasFftData) {
        // Center-out normal distribution mapping:
        final center = (_barCount - 1) / 2.0;
        final norm = (i - center).abs() / center; // 0.0 at center -> 1.0 at edges
        final rawPos = pow(norm, 0.85).toDouble() * (raw.length - 1);
        final idx0 = rawPos.floor().clamp(0, raw.length - 1);
        final idx1 = rawPos.ceil().clamp(0, raw.length - 1);
        final frac = rawPos - idx0;
        final interpolated = raw[idx0] * (1.0 - frac) + raw[idx1] * frac;

        final startIdx = rawPos.floor().clamp(0, raw.length - 1);
        final endIdx = (rawPos + raw.length / _barCount).ceil().clamp(startIdx + 1, raw.length);
        double rangePeak = 0;
        for (int j = startIdx; j < endIdx; j++) {
          if (raw[j] > rangePeak) rangePeak = raw[j];
        }

        final peak = max(interpolated, rangePeak);
        final bellShape = (1.0 - 0.20 * pow(norm, 1.4)).clamp(0.4, 1.0);
        final trebleBoost = (0.75 + 0.60 * pow(norm, 0.6)).clamp(0.5, 1.35);
        target = (peak * trebleBoost * bellShape).clamp(0.0, 1.0);
      } else {
        final center = (_barCount - 1) / 2.0;
        final norm = (i - center).abs() / center;
        final wave = (sin(t * _sineFreq[i] * 3.5 + _sinePhase[i]) + 1.0) / 2.0;
        target = ((wave * 0.45 + 0.08) * (1.0 - norm * 0.4)).clamp(0.0, 1.0);
      }

      final rate = target > _smoothed[i] ? _attack : _release;
      final nextVal = _smoothed[i] + (target - _smoothed[i]) * rate;
      if ((nextVal - _smoothed[i]).abs() > 0.002) {
        _smoothed[i] = nextVal;
        changed = true;
      }
    }

    if (!widget.isPlaying) {
      final allSettled = _smoothed.every((v) => v < 0.005);
      if (allSettled) {
        _smoothed.fillRange(0, _barCount, 0.0);
        if (changed) setState(() {});
        if (_ticker.isActive) _ticker.stop();
        return;
      }
    }

    if (changed) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep spectrumProvider active while visible without rebuilding widget on every FFT frame
    ref.listen<List<double>>(spectrumProvider, (previous, next) {});
    return CustomPaint(
      painter: _CornerVisualizerPainter(
        bars: _smoothed,
        color: widget.accent,
      ),
    );
  }
}

class _CornerVisualizerPainter extends CustomPainter {
  final List<double> bars;
  final Color color;

  _CornerVisualizerPainter({required this.bars, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty || size.width <= 0 || size.height <= 0) return;

    final n = bars.length;
    const gap = 2.0;
    final totalGaps = gap * (n - 1);
    final barW = max(1.5, (size.width - totalGaps) / n);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < n; i++) {
      final x = i * (barW + gap);
      final barH = (bars[i] * size.height).clamp(1.5, size.height);
      final y = size.height - barH;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barW, barH),
        const Radius.circular(2),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CornerVisualizerPainter old) => true;
}
