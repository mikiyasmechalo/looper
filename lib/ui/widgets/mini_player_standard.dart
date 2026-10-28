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
import 'package:looper_player/core/window_state_service.dart';
import 'package:looper_player/features/playback/presentation/audio_level_provider.dart';
import 'package:looper_player/features/playback/presentation/lyrics_notifier.dart';
import 'package:looper_player/features/playback/presentation/widgets/lyrics/advanced_lyric_line/advanced_lyric_line.dart';
import 'package:looper_player/features/playback/presentation/mini_player_overlay_service.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/ui/widgets/premium_section.dart';
import 'package:looper_player/ui/widgets/premium_progress_bar.dart';

class StandardMiniPlayer extends ConsumerStatefulWidget {
  const StandardMiniPlayer({super.key});

  @override
  ConsumerState<StandardMiniPlayer> createState() => _StandardMiniPlayerState();
}

class _StandardMiniPlayerState extends ConsumerState<StandardMiniPlayer>
    with WindowListener {
  bool _isHoveringControls = false;
  bool _isHoveringScrollableList = false;
  bool _lyricsEnabled = false;
  bool _showQueue = false;
  bool _showSnapOverlay = false;
  bool _visualizerEnabled = false;
  bool _showVolumeHud = false;
  Timer? _volumeHudTimer;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    Future.microtask(() {
      final settings = ref.read(miniPlayerSettingsProvider);
      if (settings.lyricsEnabled) setState(() => _lyricsEnabled = true);
      setState(() => _visualizerEnabled = settings.visualizerEnabled);
    });
  }

  Timer? _moveDebounce;

  @override
  void dispose() {
    if (_moveDebounce?.isActive ?? false) {
      _moveDebounce?.cancel();
      windowManager.getPosition().then((pos) {
        if (isValidScreenCoord(pos.dx, pos.dy)) {
          ref
              .read(miniPlayerSettingsProvider.notifier)
              .setMiniPlayerPosition(pos.dx, pos.dy);
        }
      }).catchError((_) {});
    }
    _volumeHudTimer?.cancel();
    windowManager.removeListener(this);
    super.dispose();
  }

  void _onScrollVolume(PointerScrollEvent event) {
    if (_isHoveringScrollableList) return;
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
    if (!mounted) return;
    if (_showSnapOverlay || _showQueue) {
      if (!mounted) return;
      setState(() {
        _showSnapOverlay = false;
        _showQueue = false;
      });
    }
  }

  @override
  void onWindowMaximize() async {
    final service = ref.read(miniPlayerOverlayServiceProvider);
    if (service.isTransitioning) return;

    final mode = ref.read(miniPlayerModeProvider);
    if (mode == MiniPlayerMode.miniPlayer) {
      await windowManager.unmaximize();
      service.exit();
    }
  }

  @override
  void onWindowMoved() async {
    final service = ref.read(miniPlayerOverlayServiceProvider);
    if (service.isTransitioning) return;

    final mode = ref.read(miniPlayerModeProvider);
    if (mode != MiniPlayerMode.miniPlayer) return;

    _moveDebounce?.cancel();
    _moveDebounce = Timer(const Duration(milliseconds: 200), () async {
      if (!mounted) return;
      final isMax = await windowManager.isMaximized();
      final isFs = await windowManager.isFullScreen();
      if (isMax || isFs) return;

      final pos = await windowManager.getPosition();
      if (isValidScreenCoord(pos.dx, pos.dy)) {
        await ref
            .read(miniPlayerSettingsProvider.notifier)
            .setMiniPlayerPosition(pos.dx, pos.dy);
      }
    });
  }

  void _onHover(bool hover) {
    setState(() => _isHoveringControls = hover);
  }

  void _toggleQueue() {
    setState(() {
      _showQueue = !_showQueue;
      _showSnapOverlay = false;
    });
  }

  void _toggleLyrics() {
    setState(() {
      _lyricsEnabled = !_lyricsEnabled;
      _showSnapOverlay = false;
    });
    ref.read(miniPlayerSettingsProvider.notifier).setLyrics(_lyricsEnabled);
  }

  void _toggleVisualizer() {
    final next = !_visualizerEnabled;
    setState(() {
      _visualizerEnabled = next;
      _showSnapOverlay = false;
    });
    ref
        .read(miniPlayerSettingsProvider.notifier)
        .setVisualizer(_visualizerEnabled);
  }

  Future<void> _snapTo(Alignment alignment) async {
    final padding = ref.read(miniPlayerSettingsProvider).padding;
    final targetPos = await ref
        .read(miniPlayerOverlayServiceProvider)
        .calculateSnapPosition(
          alignment: alignment,
          windowSize: const Size(300, 420),
          padding: padding,
        );
    await windowManager.setPosition(targetPos);
    await ref
        .read(miniPlayerSettingsProvider.notifier)
        .setMiniPlayerPosition(targetPos.dx, targetPos.dy);
    setState(() => _showSnapOverlay = false);
  }

  Widget _buildWindowControls() {
    return AnimatedOpacity(
      opacity: _isHoveringControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        height: 28,
        padding: EdgeInsets.zero,
        alignment: Alignment.topRight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _WindowBtn(
                icon: LucideIcons.minus,
                onTap: windowManager.minimize,
                tooltip: 'Minimize',
              ),
              _WindowBtn(
                icon: LucideIcons.panelTop,
                onTap: () => SystemTrayService.instance.minimizeToTray(),
                tooltip: 'Minimize to tray',
              ),
              _WindowBtn(
                icon: LucideIcons.square,
                tooltip: 'Restore',
                onTap: () => ref.read(miniPlayerOverlayServiceProvider).exit(),
              ),
              _WindowBtn(
                icon: LucideIcons.x,
                tooltip: 'Close',
                hoverColor: Colors.red,
                onTap: windowManager.close,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSnapOverlay() {
    final settings = ref.watch(miniPlayerSettingsProvider);
    final padding = settings.padding;
    final expressiveSlider = settings.expressiveSlider;
    final alwaysOnTop = settings.alwaysOnTop;
    final accent = Theme.of(context).colorScheme.primary;

    const padPresets = [0.0, 4.0, 8.0, 12.0, 18.0, 24.0, 36.0, 48.0];

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showSnapOverlay = false),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Center(
              child: GestureDetector(
                onTap: () {}, // block taps from dismissing
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B).withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Snap to Corner',
                        style: AppFonts.jostStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _SnapBtn(
                            icon: LucideIcons.arrowUpLeft,
                            onTap: () => _snapTo(Alignment.topLeft),
                          ),
                          _SnapBtn(
                            icon: LucideIcons.arrowUpRight,
                            onTap: () => _snapTo(Alignment.topRight),
                          ),
                          _SnapBtn(
                            icon: LucideIcons.arrowDownLeft,
                            onTap: () => _snapTo(Alignment.bottomLeft),
                          ),
                          _SnapBtn(
                            icon: LucideIcons.arrowDownRight,
                            onTap: () => _snapTo(Alignment.bottomRight),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Always on Top',
                            style: AppFonts.jostStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Transform.scale(
                            scale: 0.72,
                            alignment: Alignment.centerRight,
                            child: Switch(
                              value: alwaysOnTop,
                              activeColor: accent,
                              onChanged: (val) {
                                ref
                                    .read(miniPlayerSettingsProvider.notifier)
                                    .setAlwaysOnTop(val);
                                windowManager.setAlwaysOnTop(val);
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Expressive Slider',
                            style: AppFonts.jostStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Transform.scale(
                            scale: 0.72,
                            alignment: Alignment.centerRight,
                            child: Switch(
                              value: expressiveSlider,
                              activeColor: accent,
                              onChanged: (val) => ref
                                  .read(miniPlayerSettingsProvider.notifier)
                                  .setExpressiveSlider(val),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Visualizer',
                            style: AppFonts.jostStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Transform.scale(
                            scale: 0.72,
                            alignment: Alignment.centerRight,
                            child: Switch(
                              value: _visualizerEnabled,
                              activeColor: accent,
                              onChanged: (val) => _toggleVisualizer(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Corner Padding',
                            style: AppFonts.jostStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${padding.toInt()}px',
                            style: TextStyle(
                              color: accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: padPresets.map((p) {
                          final isSelected = (padding - p).abs() < 0.5;
                          return GestureDetector(
                            onTap: () => ref
                                .read(miniPlayerSettingsProvider.notifier)
                                .setPadding(p),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? accent.withValues(alpha: 0.25)
                                    : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: isSelected
                                      ? accent.withValues(alpha: 0.6)
                                      : Colors.white12,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                '${p.toInt()}',
                                style: TextStyle(
                                  color: isSelected ? accent : Colors.white70,
                                  fontSize: 10,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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

  @override
  Widget build(BuildContext context) {
    final song = ref.watch(playbackProvider.select((s) => s.currentSong));
    final volume = ref.watch(playbackProvider.select((s) => s.volume));
    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));

    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

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
          behavior: HitTestBehavior.translucent,
          child: MouseRegion(
            onEnter: (_) => _onHover(true),
            onExit: (_) => _onHover(false),
            child: GestureDetector(
              onSecondaryTapDown: (_) {
                setState(() => _showSnapOverlay = !_showSnapOverlay);
              },
              behavior: HitTestBehavior.translucent,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 300,
                    height: 420,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0A0A0A),
                    ),
                    child: Stack(
                    fit: StackFit.expand,
                    children: [

                      // Layer 0: Album Art Image
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 300,
                        child: ClipRect(
                          child: AnimatedScale(
                            scale: _lyricsEnabled ? 1.15 : 1.0,
                            duration: const Duration(milliseconds: 700),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 700),
                              width: double.infinity,
                              height: double.infinity,
                              child: ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: _lyricsEnabled ? 5 : 0,
                                  sigmaY: _lyricsEnabled ? 5 : 0,
                                ),
                                child: song != null
                                    ? OptimizedImage(
                                        imagePath: song.artPath ?? "",
                                        cacheWidth: 384,
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.low,
                                      )
                                    : Container(color: Colors.white10),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Layer 1: Full-height dark tint for lyrics (sits BEHIND lyrics text)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedOpacity(
                            opacity: _lyricsEnabled ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 700),
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.50),
                            ),
                          ),
                        ),
                      ),

                      // Layer 2: Lyrics text overlay (rendered ON TOP of dark tint)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 300,
                        child: AnimatedOpacity(
                          opacity: _lyricsEnabled ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 700),
                          child: _lyricsEnabled
                              ? MouseRegion(
                                  onEnter: (_) => setState(
                                    () => _isHoveringScrollableList = true,
                                  ),
                                  onExit: (_) => setState(
                                    () => _isHoveringScrollableList = false,
                                  ),
                                  child: const _LyricsOverlay(),
                                )
                              : const SizedBox.expand(),
                        ),
                      ),

                      // Layer 3: Volume Button in Bottom-Right Corner of Album Art (shown on hover)
                      Positioned(
                        bottom: 128,
                        right: 8,
                        child: AnimatedOpacity(
                          opacity: _isHoveringControls ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: IgnorePointer(
                            ignoring: !_isHoveringControls,
                            child: _AlbumArtVolumeControl(accent: accent),
                          ),
                        ),
                      ),

                      // Draggable Window Controls
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 60,
                        child: _buildWindowControls(),
                      ),

                      // Controls Area — visualizer is layer 0, scrim is layer 1, content is layer 2
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 120,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Layer 0: real-spectrum visualizer, fills the whole controls area
                            if (_visualizerEnabled)
                              _VisualizerWidget(
                                isPlaying: isPlaying,
                                accent: accent,
                              ),

                            // Layer 1: dark scrim — subtle contrast gradient
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: [0.0, 0.70, 1.0],
                                  colors: [
                                    Colors.transparent,
                                    Color(0x550A0A0A),
                                    Color(0x880A0A0A),
                                  ],
                                ),
                              ),
                            ),

                            // Layer 2: content
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _ProgressBar(accent: accent),
                                  const SizedBox(height: 2),
                                  SizedBox(
                                    height: 60,
                                    child: Stack(
                                      children: [
                                        // Title / Artist
                                        AnimatedOpacity(
                                          opacity: _isHoveringControls
                                              ? 0.0
                                              : 1.0,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          child: IgnorePointer(
                                            ignoring: _isHoveringControls,
                                            child: Container(
                                              alignment: Alignment.centerLeft,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    song?.title ?? "No track",
                                                    style: AppFonts.jostStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    song?.artist ??
                                                        "Unknown artist",
                                                    style: AppFonts.jostStyle(
                                                      fontSize: 13,
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.6,
                                                          ),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Controls
                                        AnimatedOpacity(
                                          opacity: _isHoveringControls
                                              ? 1.0
                                              : 0.0,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          child: IgnorePointer(
                                            ignoring: !_isHoveringControls,
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  _UtilBtn(
                                                    icon: LucideIcons.mic2,
                                                    isActive: _lyricsEnabled,
                                                    accent: accent,
                                                    onTap: _toggleLyrics,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  const _PlaybackControls(
                                                    width: 52,
                                                    height: 40,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  _UtilBtn(
                                                    icon: LucideIcons.listMusic,
                                                    isActive: _showQueue,
                                                    accent: accent,
                                                    onTap: _toggleQueue,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Queue Bottom Sheet Backdrop
                      if (_showQueue)
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: _toggleQueue,
                            behavior: HitTestBehavior.opaque,
                            child: Container(color: Colors.transparent),
                          ),
                        ),

                      // Queue Bottom Sheet
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        left: 0,
                        right: 0,
                        bottom: _showQueue ? 0 : -300,
                        height: 300,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF121212,
                            ).withValues(alpha: 0.95),
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: MouseRegion(
                                onEnter: (_) => setState(
                                  () => _isHoveringScrollableList = true,
                                ),
                                onExit: (_) => setState(
                                  () => _isHoveringScrollableList = false,
                                ),
                                child: _QueuePanelContent(
                                  isOpen: _showQueue,
                                  onClose: _toggleQueue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

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
                              height: 3,
                              width: double.infinity,
                              color: Colors.white.withValues(alpha: 0.12),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: (volume).clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: accent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withValues(alpha: 0.7),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Border overlay (drawn on top of content so it does not inset the top volume bar)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
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
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SnapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SnapBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white70, size: 16),
      ),
    );
  }
}

class _PlaybackControls extends ConsumerWidget {
  final double width;
  final double height;
  const _PlaybackControls({required this.width, required this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PremiumSection(
          heroTag: "mini_prev_$width",
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
            width: height * 0.35,
            height: height * 0.35,
          ),
        ),
        const SizedBox(width: 4),
        PremiumSection(
          heroTag: "mini_play_pause_$width",
          borderRadius: BorderRadius.circular(8),
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
                  size: height * 0.5,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 4),
        PremiumSection(
          heroTag: "mini_next_$width",
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
            width: height * 0.35,
            height: height * 0.35,
          ),
        ),
      ],
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
      width: 22,
      height: 22,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          hoverColor: hoverColor ?? Colors.white.withValues(alpha: 0.1),
          child: Tooltip(
            message: tooltip ?? '',
            child: Center(child: Icon(icon, size: 11, color: Colors.white70)),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends ConsumerWidget {
  final Color accent;
  const _ProgressBar({required this.accent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(playbackProvider.select((s) => s.position));
    final duration = ref.watch(playbackProvider.select((s) => s.duration));
    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
    final ms = position.inMilliseconds.toDouble();
    final total = duration.inMilliseconds.toDouble();
    final pct = total > 0 ? (ms / total).clamp(0.0, 1.0) : 0.0;

    final useExpressive = ref
        .watch(miniPlayerSettingsProvider)
        .expressiveSlider;

    String fmt(int ms) {
      final s = ms ~/ 1000;
      final m = s ~/ 60;
      final r = s % 60;
      return '$m:${r.toString().padLeft(2, '0')}';
    }

    void handleSeek(TapDownDetails details, double maxWidth) {
      if (total <= 0) return;
      final dx = details.localPosition.dx.clamp(0.0, maxWidth);
      final newPosMs = (dx / maxWidth) * total;
      ref
          .read(playbackProvider.notifier)
          .seek(Duration(milliseconds: newPosMs.toInt()));
    }

    void handleDrag(DragUpdateDetails details, double maxWidth) {
      if (total <= 0) return;
      final dx = details.localPosition.dx.clamp(0.0, maxWidth);
      final newPosMs = (dx / maxWidth) * total;
      ref
          .read(playbackProvider.notifier)
          .seek(Duration(milliseconds: newPosMs.toInt()));
    }

    final slider = useExpressive
        ? Container(
            height: 24, // consistent tap area
            alignment: Alignment.center,
            child: ExpressiveSlider(
              position: position,
              duration: duration,
              isPlaying: isPlaying,
              showTimestamps: false,
              onSeek: (pos) => ref.read(playbackProvider.notifier).seek(pos),
              onSeekStart: () =>
                  ref.read(playbackProvider.notifier).startScrubbing(),
              onSeekEnd: () =>
                  ref.read(playbackProvider.notifier).stopScrubbing(),
              color: accent,
            ),
          )
        : LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (d) => handleSeek(d, constraints.maxWidth),
                onPanStart: (_) =>
                    ref.read(playbackProvider.notifier).startScrubbing(),
                onPanUpdate: (d) => handleDrag(d, constraints.maxWidth),
                onPanEnd: (_) =>
                    ref.read(playbackProvider.notifier).stopScrubbing(),
                child: Container(
                  height:
                      24, // MATCH height of expressive slider so layout is consistent
                  color: Colors.transparent, // Expand hit area
                  alignment: Alignment.center,
                  child: Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: constraints.maxWidth * pct,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        slider,
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              fmt(ms.toInt()),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white54,
                fontFamily: 'monospace',
              ),
            ),
            Text(
              fmt(total.toInt()),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white54,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UtilBtn extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color accent;
  final VoidCallback onTap;

  const _UtilBtn({
    required this.icon,
    required this.isActive,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isActive
              ? accent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 14,
            color: isActive ? accent : Colors.white60,
          ),
        ),
      ),
    );
  }
}

class _LyricsOverlay extends ConsumerStatefulWidget {
  const _LyricsOverlay();

  @override
  ConsumerState<_LyricsOverlay> createState() => _LyricsOverlayState();
}

class _LyricsOverlayState extends ConsumerState<_LyricsOverlay> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _lineKeys = {};
  int _lastActiveIndex = -1;
  int _activeIndex = -1;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActive(animate: false, force: true);
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActive({bool animate = true, bool force = false}) {
    if (!mounted || _activeIndex < 0) return;
    final index = _activeIndex;
    final ctx = _lineKeys[index]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: animate ? const Duration(milliseconds: 400) : Duration.zero,
        curve: Curves.easeOutCubic,
        alignment: 0.38,
      );
      return;
    }

    if (_scrollController.hasClients) {
      final pos = _scrollController.position;
      final estimatedOffset = (index * 42.0).clamp(
        pos.minScrollExtent,
        pos.maxScrollExtent,
      );
      _scrollController.jumpTo(estimatedOffset);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final targetCtx = _lineKeys[index]?.currentContext;
        if (targetCtx != null) {
          Scrollable.ensureVisible(
            targetCtx,
            duration: animate
                ? const Duration(milliseconds: 350)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            alignment: 0.38,
          );
        }
      });
    }
  }

  void _scheduleScrollToActive(int index) {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(milliseconds: 60), () {
      if (!mounted) return;
      _scrollToActive(animate: true);
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
        child: CircularProgressIndicator(
          color: Colors.white54,
          strokeWidth: 2.5,
        ),
      );
    }
    if (lyricsState.parsedLines.isEmpty) {
      return Center(
        child: Text(
          'No lyrics found',
          style: AppFonts.jostStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }

    final lines = lyricsState.parsedLines;
    int idx = lines.indexWhere((l) => l.startTime.inMilliseconds > posMs) - 1;
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
        itemCount: lines.length,
        itemBuilder: (context, i) {
          final line = lines[i];
          final isCurrent = i == idx;
          final isPast = i < idx;
          final isInstrumental = line.isInstrumental;
          final lineKey = _lineKeys.putIfAbsent(i, () => GlobalKey());

          final currentStyle = AppFonts.jostStyle(
            color: isCurrent
                ? Colors.white
                : (isPast
                    ? Colors.white.withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.35)),
            fontSize: uniformFontSize
                ? (isInstrumental ? 18.0 : 16.5)
                : (isCurrent
                    ? (isInstrumental ? 22.0 : 18.5)
                    : (isInstrumental ? 17.0 : 15.0)),
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
          );

          Widget lineContent;
          if (isInstrumental) {
            if (isCurrent) {
              lineContent = PulsingInstrumentalIcon(
                color: primaryColor,
                style: currentStyle,
              );
            } else {
              lineContent = Text(
                '♫',
                style: currentStyle.copyWith(
                  color: isPast
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.28),
                ),
                textAlign: textAlign,
              );
            }
          } else {
            lineContent = Text(line.text, textAlign: textAlign);
          }

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
                      style: currentStyle,
                      child: lineContent,
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

class _QueuePanelContent extends ConsumerStatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  const _QueuePanelContent({
    required this.isOpen,
    required this.onClose,
  });

  @override
  ConsumerState<_QueuePanelContent> createState() => _QueuePanelContentState();
}

class _QueuePanelContentState extends ConsumerState<_QueuePanelContent> {
  bool _isCompact = false;
  late final ScrollController _scrollController;
  int _lastScrolledIdx = -1;

  @override
  void didUpdateWidget(covariant _QueuePanelContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _scrollToCurrent();
    }
  }

  @override
  void initState() {
    super.initState();
    final currentPath = ref.read(playbackProvider).currentSong?.path;
    final queue = ref.read(playbackProvider).queue;
    final showPlayed = ref.read(settingsProvider).showPlayedSongsInQueue;
    final idx = queue.indexWhere((s) => s.path == currentPath);
    double initialOffset = 0.0;
    if (idx >= 0) {
      final targetIndex = (showPlayed || idx == -1) ? idx : 0;
      final double itemHeight = _isCompact ? 28.0 : 50.0;
      initialOffset = (targetIndex * itemHeight - 110.0 + itemHeight / 2)
            .clamp(0.0, double.infinity);
    }
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _lastScrolledIdx = idx;
  }

  void _scrollToCurrent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final currentPath = ref.read(playbackProvider).currentSong?.path;
      final queue = ref.read(playbackProvider).queue;
      final showPlayed = ref.read(settingsProvider).showPlayedSongsInQueue;
      final idx = queue.indexWhere((s) => s.path == currentPath);
      if (idx == -1) return;

      final targetIndex = (showPlayed || idx == -1) ? idx : 0;

      final double itemHeight = _isCompact ? 28.0 : 50.0;
      final max = _scrollController.position.maxScrollExtent;
      final viewport = _scrollController.position.viewportDimension;
      final target = (targetIndex * itemHeight - viewport / 2 + itemHeight / 2)
          .clamp(0.0, max);
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
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

    final showPlayed = ref.watch(
      settingsProvider.select((s) => s.showPlayedSongsInQueue),
    );
    final idx = queue.indexWhere((s) => s.path == currentPath);

    // played... (dimmed), current, upcoming... — mirrors fullscreen player
    final displayed = (idx == -1 || showPlayed) ? queue : queue.sublist(idx);

    // Auto-scroll to the current song only when panel first opens
    if (idx >= 0 && _lastScrolledIdx == -1) {
      _lastScrolledIdx = idx;
      _scrollToCurrent();
    }

    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Queue',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: _isCompact ? 'Normal View' : 'Compact View',
                child: GestureDetector(
                  onTap: () => setState(() => _isCompact = !_isCompact),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _isCompact
                          ? accent.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _isCompact
                            ? accent.withValues(alpha: 0.4)
                            : Colors.white12,
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      _isCompact ? LucideIcons.list : LucideIcons.layoutList,
                      size: 12,
                      color: _isCompact ? accent : Colors.white70,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onClose,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(LucideIcons.x, size: 16, color: Colors.white54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ReorderableListView.builder(
                    itemExtent: _isCompact ? 28.0 : 50.0,
                    scrollController: _scrollController,
                    buildDefaultDragHandles: false,
                    padding: const EdgeInsets.only(right: 4, bottom: 42),
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
                ref
                    .read(playbackProvider.notifier)
                    .reorderQueueDirect(oldOrig, newOrig);
              },
              proxyDecorator: (child, index, animation) =>
                  Material(color: Colors.transparent, child: child),
              itemCount: displayed.length,
              itemBuilder: (context, i) {
                final song = displayed[i];
                final isCurrent = song.path == currentPath;
                final originalIndex = (showPlayed || idx == -1) ? i : (i + idx);
                final isPlayed = idx != -1 && originalIndex < idx;
                final isDraggable = !isCurrent;

                return SizedBox(
                  key: ValueKey('mps_${song.path}_$i'),
                  height: _isCompact ? 28.0 : 50.0,
                  child: Opacity(
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
                                horizontal: 8,
                                vertical: 5,
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
                                  const SizedBox(width: 8),
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
                                              fontSize: 11.5,
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
                                                    ? accent.withValues(
                                                        alpha: 0.75,
                                                      )
                                                    : Colors.white38,
                                                fontSize: 10.5,
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
                                            color: accent.withValues(
                                              alpha: 0.8,
                                            ),
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
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? accent.withValues(alpha: 0.12)
                                    : Colors.transparent,
                                border: isCurrent
                                    ? Border.all(
                                        color: accent.withValues(alpha: 0.3),
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: OptimizedImage(
                                      imagePath: song.artPath ?? "",
                                      width: 32,
                                      height: 32,
                                      cacheWidth: 64,
                                      cacheHeight: 64,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          song.title ?? "",
                                          style: TextStyle(
                                            color: isCurrent
                                                ? accent
                                                : Colors.white,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w600,
                                            height: 1.15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (song.artist != null &&
                                            song.artist!.isNotEmpty)
                                          Text(
                                            song.artist!,
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 10.5,
                                              height: 1.15,
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
                                            color: accent.withValues(
                                              alpha: 0.8,
                                            ),
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
                  ),
                );
              },
                  ),
                ),
                if (queue.isNotEmpty)
                  Positioned(
                    bottom: 6,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _scrollToCurrent,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E22).withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                              width: 0.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${idx >= 0 ? idx + 1 : 1} / ${queue.length}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(width: 1, height: 10, color: Colors.white24),
                              const SizedBox(width: 8),
                              Tooltip(
                                message: 'Jump to current song',
                                child: Icon(
                                  LucideIcons.locateFixed,
                                  size: 13,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumArtVolumeControl extends ConsumerStatefulWidget {
  final Color accent;
  const _AlbumArtVolumeControl({required this.accent});

  @override
  ConsumerState<_AlbumArtVolumeControl> createState() =>
      _AlbumArtVolumeControlState();
}

class _AlbumArtVolumeControlState
    extends ConsumerState<_AlbumArtVolumeControl> {
  bool _isHovered = false;
  bool _isDragging = false;
  Timer? _hideTimer;

  void _onEnter() {
    _hideTimer?.cancel();
    setState(() => _isHovered = true);
  }

  void _onExit() {
    if (_isDragging) return;
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isHovered = false);
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final volume = ref.watch(playbackProvider.select((s) => s.volume));
    final isExpanded = _isHovered || _isDragging;

    final IconData volIcon = volume == 0
        ? LucideIcons.volumeX
        : volume < 0.5
        ? LucideIcons.volume1
        : LucideIcons.volume2;

    return MouseRegion(
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            final delta = event.scrollDelta.dy < 0 ? 0.05 : -0.05;
            ref.read(playbackProvider.notifier).adjustVolume(delta);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: 32,
          height: isExpanded ? 130 : 30,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: isExpanded ? 0.88 : 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isExpanded ? Colors.white24 : Colors.white12,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: isExpanded
                ? OverflowBox(
                    minHeight: 130,
                    maxHeight: 130,
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: 32,
                      height: 130,
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            '${(volume * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final trackH = constraints.maxHeight;
                                  if (trackH <= 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onVerticalDragStart: (details) {
                                      setState(() => _isDragging = true);
                                      _updateVolume(
                                        details.localPosition.dy,
                                        trackH,
                                      );
                                    },
                                    onVerticalDragUpdate: (details) {
                                      _updateVolume(
                                        details.localPosition.dy,
                                        trackH,
                                      );
                                    },
                                    onVerticalDragEnd: (_) {
                                      setState(() => _isDragging = false);
                                      _onExit();
                                    },
                                    onTapDown: (details) {
                                      _updateVolume(
                                        details.localPosition.dy,
                                        trackH,
                                      );
                                    },
                                    child: Center(
                                      child: Container(
                                        width: 5,
                                        height: trackH,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            Container(
                                              height: (trackH * volume).clamp(
                                                0.0,
                                                trackH,
                                              ),
                                              width: 5,
                                              decoration: BoxDecoration(
                                                color: widget.accent,
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: widget.accent
                                                        .withValues(alpha: 0.5),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => ref
                                .read(playbackProvider.notifier)
                                .toggleMute(),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 32,
                              height: 28,
                              alignment: Alignment.center,
                              child: Icon(
                                volIcon,
                                size: 14,
                                color: volume == 0
                                    ? Colors.white38
                                    : widget.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      volIcon,
                      size: 14,
                      color: volume == 0 ? Colors.white38 : Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _updateVolume(double localDy, double totalHeight) {
    if (totalHeight <= 0) return;
    final clamped = (1.0 - (localDy / totalHeight)).clamp(0.0, 1.0);
    ref.read(playbackProvider.notifier).setVolume(clamped);
  }
}

// ─── Visualizer ───────────────────────────────────────────────────────────────

class _VisualizerWidget extends ConsumerStatefulWidget {
  final bool isPlaying;
  final Color accent;

  const _VisualizerWidget({required this.isPlaying, required this.accent});

  @override
  ConsumerState<_VisualizerWidget> createState() => _VisualizerWidgetState();
}

class _VisualizerWidgetState extends ConsumerState<_VisualizerWidget>
    with SingleTickerProviderStateMixin {
  static const int _barCount = 32;

  // Smoothed per-bar heights (0..1) — persisted across frames
  final List<double> _smoothed = List.filled(_barCount, 0.0);

  static const double _attack = 0.40;
  static const double _release = 0.07;

  late Ticker _ticker;
  // Total elapsed time drives the fallback sine animation
  Duration _elapsed = Duration.zero;
  Duration _lastTickTime = Duration.zero;

  // Pre-baked per-bar sine params for organic fallback
  static final List<double> _sinePhase = List.generate(
    _barCount,
    (i) => (i / _barCount) * 2 * pi + (i % 3) * 1.1,
  );
  static final List<double> _sineFreq = List.generate(
    _barCount,
    (i) => 1.0 + (i % 5) * 0.3,
  );

  // Spectral-tilt compensation: bass naturally dominates FFT energy.
  // This power curve reduces low bars and lifts highs — smooth, not equal.
  // ~0.55 at bar 0 (sub-bass), ~0.90 at midpoint, ~1.25 at bar 31 (treble).
  static final List<double> _freqGain = List.generate(_barCount, (i) {
    final norm = i / (_barCount - 1); // 0..1
    return (0.55 + 0.72 * pow(norm, 0.55)).clamp(0.3, 1.3);
  });

  static final List<double> _norm = List.generate(
    _barCount,
    (i) {
      final center = (_barCount - 1) / 2.0;
      return (i - center).abs() / center;
    },
  );
  static final List<double> _audioFreqScale = List.generate(
    _barCount,
    (i) => pow(_norm[i], 0.85).toDouble(),
  );
  static final List<double> _bellShape = List.generate(
    _barCount,
    (i) => (1.0 - 0.20 * pow(_norm[i], 1.4)).clamp(0.4, 1.0),
  );
  static final List<double> _trebleBoost = List.generate(
    _barCount,
    (i) => (0.75 + 0.60 * pow(_norm[i], 0.6)).clamp(0.5, 1.35),
  );
  static final List<double> _fallbackScale = List.generate(
    _barCount,
    (i) => (1.0 - _norm[i] * 0.45),
  );

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    if (widget.isPlaying) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant _VisualizerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        if (!_ticker.isActive) _ticker.start();
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    if (ref.read(isWindowMinimizedProvider)) {
      if (_ticker.isActive) _ticker.stop();
      _lastTickTime = Duration.zero;
      return;
    }
    if (_lastTickTime != Duration.zero && (elapsed - _lastTickTime).inMilliseconds < 33) {
      return;
    }
    _lastTickTime = elapsed;
    _elapsed = elapsed;

    final raw = ref.read(spectrumProvider);
    final hasFftData = raw.isNotEmpty && raw.any((v) => v > 0.01);
    final t = elapsed.inMicroseconds / 1000000.0; // seconds

    bool changed = false;
    for (int i = 0; i < _barCount; i++) {
      double target;
      if (!widget.isPlaying) {
        target = 0.0;
      } else if (hasFftData) {
        final rawPos = _audioFreqScale[i] * (raw.length - 1);
        final idx0 = rawPos.floor().clamp(0, raw.length - 1);
        final idx1 = rawPos.ceil().clamp(0, raw.length - 1);
        final frac = rawPos - idx0;
        final interpolated = raw[idx0] * (1.0 - frac) + raw[idx1] * frac;

        final startIdx = idx0;
        final endIdx = (rawPos + raw.length / _barCount).ceil().clamp(startIdx + 1, raw.length);
        double rangePeak = 0;
        for (int j = startIdx; j < endIdx; j++) {
          if (raw[j] > rangePeak) rangePeak = raw[j];
        }

        final peak = max(interpolated, rangePeak);
        target = (peak * _trebleBoost[i] * _bellShape[i]).clamp(0.0, 1.0);
      } else {
        final v =
            (sin(t * _sineFreq[i] * 2.5 + _sinePhase[i]) * 0.4 +
                    sin(t * _sineFreq[i] * 1.3 + _sinePhase[i] * 0.7) * 0.3) *
                0.5 +
            0.5;
        target = (v * _fallbackScale[i]).clamp(0.1, 1.0);
      }

      // Micro-jitter for sustained notes: when target ≈ smoothed (bar is
      // "stuck" on a held note), add a small breathing wobble so it never
      // looks frozen. Magnitude ±3%, rate 2–4 Hz, distinct phase per bar.
      if (widget.isPlaying && target > 0.05) {
        final diff = (target - _smoothed[i]).abs();
        if (diff < 0.035) {
          final jitter = sin(t * (2.2 + _sineFreq[i] * 0.6) + _sinePhase[i] * 1.3) * 0.030;
          target = (target + jitter).clamp(0.0, 1.0);
        }
      }

      final alpha = target > _smoothed[i] ? _attack : _release;
      final next = _smoothed[i] + (target - _smoothed[i]) * alpha;
      if ((next - _smoothed[i]).abs() > 0.0005) {
        _smoothed[i] = next;
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
  Widget build(BuildContext context) {
    ref.listen<bool>(isWindowMinimizedProvider, (prev, isMinimized) {
      if (isMinimized) {
        if (_ticker.isActive) _ticker.stop();
        _lastTickTime = Duration.zero;
      } else if (widget.isPlaying) {
        if (!_ticker.isActive) _ticker.start();
      }
    });

    // Keep spectrumProvider active while visible without rebuilding widget on every FFT frame
    ref.listen<List<double>>(spectrumProvider, (previous, next) {});

    return AnimatedOpacity(
      opacity: widget.isPlaying ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      child: CustomPaint(
        painter: _VisualizerPainter(
          heights: _smoothed.toList(growable: false),
          accent: widget.accent,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _VisualizerPainter extends CustomPainter {
  final List<double> heights;
  final Color accent;

  const _VisualizerPainter({required this.heights, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final count = heights.length;
    if (count == 0) return;

    // Bar geometry — leave a little horizontal padding
    const hPad = 12.0;
    final totalBarW = size.width - hPad * 2;
    final barW = totalBarW / (count * 1.55);
    final gap = barW * 0.55;
    final slotW = barW + gap;

    // Center the bar field
    final fieldW = slotW * count - gap;
    final startX = (size.width - fieldW) / 2;

    final maxH = size.height * 0.60;
    final minH = 4.0;

    final shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [accent.withValues(alpha: 1.0), accent.withValues(alpha: 0.95)],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final barPaint = Paint()..shader = shader;
    const cornerRadius = Radius.circular(3);

    for (int i = 0; i < count; i++) {
      final h = (minH + (maxH - minH) * heights[i]).clamp(minH, maxH);
      final x = startX + i * slotW;
      final top = size.height - h;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barW, h),
        cornerRadius,
      );

      canvas.drawRRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(_VisualizerPainter old) =>
      old.heights != heights || old.accent != accent;
}
