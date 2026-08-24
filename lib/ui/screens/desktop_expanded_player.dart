import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';
import 'package:looper_player/core/system_tray_service.dart';

import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/app_icons.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/ui/widgets/premium_progress_bar.dart';
import 'package:looper_player/ui/widgets/song_options_bottom_sheet.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/audio_level_provider.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/playback/presentation/lyrics_notifier.dart';
import 'package:looper_player/features/playback/presentation/waveform_provider.dart';
import 'package:looper_player/features/playback/presentation/widgets/ab_looper_widget.dart';
import 'package:looper_player/ui/widgets/sleep_timer_sheet_content.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';

enum PlayerPanelTab { queue, lyrics }

/// Below this available width the player switches to the vertical layout.
const double _verticalBreakpoint = 1360;
const double _artMax = 480;

/// Desktop full-screen player — "Split Stage".
///
/// Default: full-width art (left) / info (right) split. Opening Queue or
/// Lyrics slides a panel in from the right while the player keeps the
/// majority of the width. On narrower windows the layout collapses to a
/// vertical "deck" arrangement. Real fullscreen (when enabled) hides the
/// OS taskbar and the window control buttons.
class DesktopExpandedPlayer extends ConsumerStatefulWidget {
  const DesktopExpandedPlayer({super.key});

  @override
  ConsumerState<DesktopExpandedPlayer> createState() =>
      _DesktopExpandedPlayerState();
}

class _DesktopExpandedPlayerState extends ConsumerState<DesktopExpandedPlayer>
    with WindowListener {
  PlayerPanelTab? _openPanel;
  PlayerPanelTab _lastTab = PlayerPanelTab.queue;
  bool _fullscreen = false;
  bool _autoEnteredFullscreen = false;
  ProviderSubscription<bool>? _fullscreenSettingSub;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) return;
    windowManager.addListener(this);
    _syncFullscreen();
    _maybeAutoFullscreen();
    _fullscreenSettingSub = ref.listenManual(
      settingsProvider.select((s) => s.nowPlayingFullscreen),
      (prev, next) {
        if (next) {
          _autoEnteredFullscreen = true;
          windowManager.setFullScreen(true);
        }
      },
    );
  }

  Future<void> _maybeAutoFullscreen() async {
    final enable = ref.read(settingsProvider).nowPlayingFullscreen;
    if (enable) {
      _autoEnteredFullscreen = true;
      await windowManager.setFullScreen(true);
    }
    if (mounted) _syncFullscreen();
  }

  @override
  void dispose() {
    _fullscreenSettingSub?.close();
    if (!(Platform.isAndroid || Platform.isIOS)) {
      windowManager.removeListener(this);
      if (_autoEnteredFullscreen) {
        windowManager.setFullScreen(false);
      }
    }
    super.dispose();
  }

  Future<void> _syncFullscreen() async {
    final f = await windowManager.isFullScreen();
    if (!mounted) return;
    setState(() => _fullscreen = f);
  }

  @override
  void onWindowEnterFullScreen() => _syncFullscreen();

  @override
  void onWindowLeaveFullScreen() => _syncFullscreen();

  Future<void> _toggleFullscreen() async {
    final isFs = await windowManager.isFullScreen();
    final next = !isFs;
    // Update the label immediately (the OS fullscreen event is unreliable on
    // some platforms), then re-sync with the real state afterwards.
    if (mounted) setState(() => _fullscreen = next);
    await windowManager.setFullScreen(next);
    final actual = await windowManager.isFullScreen();
    if (mounted && actual != _fullscreen) {
      setState(() => _fullscreen = actual);
    }
  }

  void _togglePanel(PlayerPanelTab tab) {
    setState(() {
      _lastTab = tab;
      _openPanel = _openPanel == tab ? null : tab;
    });
  }

  void _closePanel() => setState(() => _openPanel = null);

  double _panelWidth(double screenWidth) =>
      (screenWidth * 0.29).clamp(300.0, 420.0);

  @override
  Widget build(BuildContext context) {
    final song = ref.watch(playbackProvider.select((s) => s.currentSong));
    if (song == null) return const SizedBox.shrink();

    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
    final isShuffle = ref.watch(playbackProvider.select((s) => s.isShuffle));
    final repeatMode = ref.watch(playbackProvider.select((s) => s.repeatMode));
    final position = ref.watch(playbackProvider.select((s) => s.position));
    final duration = ref.watch(playbackProvider.select((s) => s.duration));

    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = _panelWidth(screenWidth);
    final notifier = ref.read(playbackProvider.notifier);
    final showBottomVisualizer = ref.watch(
      settingsProvider.select((s) => s.fullscreenVisualizerEnabled),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.18),
                  Colors.black,
                ],
              ),
            ),
          ),
          if (showBottomVisualizer)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 200,
              child: IgnorePointer(
                child: _DesktopBottomVisualizer(
                  isPlaying: isPlaying,
                  accent: colorScheme.primary,
                ),
              ),
            ),
          SafeArea(
            child: _PlayerStage(
              screenWidth: screenWidth,
              panelWidth: panelWidth,
              activePanel: _openPanel,
              lastTab: _lastTab,
              fullscreen: _fullscreen,
              onToggleFullscreen: _toggleFullscreen,
              song: song,
              isPlaying: isPlaying,
              isShuffle: isShuffle,
              repeatMode: repeatMode,
              position: position,
              duration: duration,
              l10n: l10n,
              onCollapse: () => ref
                  .read(appNavigationProvider.notifier)
                  .setPlayerExpansion(false),
              onTogglePlay: notifier.togglePlay,
              onSkipPrevious: notifier.skipPrevious,
              onSkipNext: notifier.skipNext,
              onToggleShuffle: notifier.toggleShuffle,
              onCycleRepeat: notifier.nextRepeatMode,
              onToggleFavorite: notifier.toggleFavorite,
              onSeek: notifier.seek,
              onToggleQueue: () => _togglePanel(PlayerPanelTab.queue),
              onToggleLyrics: () => _togglePanel(PlayerPanelTab.lyrics),
              onTabChanged: (t) => setState(() {
                _lastTab = t;
                _openPanel = t;
              }),
              onClosePanel: _closePanel,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STAGE — persistent header (window controls + menu) + responsive content
// ============================================================================

class _PlayerStage extends StatelessWidget {
  const _PlayerStage({
    required this.screenWidth,
    required this.panelWidth,
    required this.activePanel,
    required this.lastTab,
    required this.fullscreen,
    required this.onToggleFullscreen,
    required this.song,
    required this.isPlaying,
    required this.isShuffle,
    required this.repeatMode,
    required this.position,
    required this.duration,
    required this.l10n,
    required this.onCollapse,
    required this.onTogglePlay,
    required this.onSkipPrevious,
    required this.onSkipNext,
    required this.onToggleShuffle,
    required this.onCycleRepeat,
    required this.onToggleFavorite,
    required this.onSeek,
    required this.onToggleQueue,
    required this.onToggleLyrics,
    required this.onTabChanged,
    required this.onClosePanel,
  });

  final double screenWidth;
  final double panelWidth;
  final PlayerPanelTab? activePanel;
  final PlayerPanelTab lastTab;
  final bool fullscreen;
  final VoidCallback onToggleFullscreen;
  final Song song;
  final bool isPlaying;
  final bool isShuffle;
  final RepeatMode repeatMode;
  final Duration position;
  final Duration duration;
  final AppLocalizations l10n;
  final VoidCallback onCollapse;
  final VoidCallback onTogglePlay;
  final VoidCallback onSkipPrevious;
  final VoidCallback onSkipNext;
  final VoidCallback onToggleShuffle;
  final VoidCallback onCycleRepeat;
  final VoidCallback onToggleFavorite;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onToggleQueue;
  final VoidCallback onToggleLyrics;
  final ValueChanged<PlayerPanelTab> onTabChanged;
  final VoidCallback onClosePanel;

  @override
  Widget build(BuildContext context) {
    final panelOpen = activePanel != null;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: Stack(
            children: [
              // Full-strip drag area: reaches from the very top of the window
              // down through the header row (buttons are stacked on top and
              // still receive their own gestures).
              if (!fullscreen)
                Positioned.fill(
                  child: DragToMoveArea(
                    child: const SizedBox.expand(),
                  ),
                ),
              // Title is always centered on screen, regardless of the
              // side-button widths. IgnorePointer keeps the whole strip
              // draggable (the drag area lives below this layer).
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: _TitleText(l10n: l10n),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 12,
                child: IconButton(
                  icon: const Icon(LucideIcons.chevronDown, color: Colors.white),
                  onPressed: onCollapse,
                  tooltip: 'Collapse',
                ),
              ),
              Positioned(
                right: 20,
                top: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HeaderMenu(
                      fullscreen: fullscreen,
                      onToggleFullscreen: onToggleFullscreen,
                    ),
                    _WindowControls(fullscreen: fullscreen),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              // Player content — shrinks to make room for the panel.
              Positioned.fill(
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.only(
                    right: panelOpen ? panelWidth : 0,
                  ),
                  child: _ResponsiveContent(
                    screenWidth: screenWidth,
                    song: song,
                    isPlaying: isPlaying,
                    isShuffle: isShuffle,
                    repeatMode: repeatMode,
                    position: position,
                    duration: duration,
                    l10n: l10n,
                    activePanel: activePanel,
                    onTogglePlay: onTogglePlay,
                    onSkipPrevious: onSkipPrevious,
                    onSkipNext: onSkipNext,
                    onToggleShuffle: onToggleShuffle,
                    onCycleRepeat: onCycleRepeat,
                    onToggleFavorite: onToggleFavorite,
                    onSeek: onSeek,
                    onToggleQueue: onToggleQueue,
                    onToggleLyrics: onToggleLyrics,
                  ),
                ),
              ),
              // Side panel — always mounted (keeps scroll state) and laid out
              // at full width; clipped + slid away while closed.
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: ClipRect(
                  child: IgnorePointer(
                    ignoring: !panelOpen,
                    child: AnimatedSlide(
                      offset: panelOpen ? Offset.zero : const Offset(1, 0),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                      child: SizedBox(
                        width: panelWidth,
                        child: _SidePanel(
                          tab: activePanel ?? lastTab,
                          visible: panelOpen,
                          onTabChanged: onTabChanged,
                          onClose: onClosePanel,
                        ),
                      ),
                    ),
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

/// "NOW PLAYING" label in the stage header.
class _TitleText extends StatelessWidget {
  const _TitleText({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Text(
      l10n.nowPlaying.toUpperCase(),
      textAlign: TextAlign.center,
      style: AppFonts.jostStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }
}

/// Three-dot menu in the header: song options, fullscreen toggle (with a
/// dynamic label that reflects the real state), and Settings.
class _HeaderMenu extends ConsumerWidget {
  const _HeaderMenu({
    required this.fullscreen,
    required this.onToggleFullscreen,
  });

  final bool fullscreen;
  final VoidCallback onToggleFullscreen;

  void _openSongOptions(BuildContext context, WidgetRef ref) {
    final song = ref.read(playbackProvider.select((s) => s.currentSong));
    if (song == null) return;
    showSongOptionsBottomSheet(context: context, ref: ref, song: song);
  }

  Future<void> _openSettings(BuildContext context, WidgetRef ref) async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      final isFs = await windowManager.isFullScreen();
      if (isFs) await windowManager.setFullScreen(false);
      if (!context.mounted) return;
    }
    final notifier = ref.read(appNavigationProvider.notifier);
    // Let the popup menu route close before collapsing the player so the
    // navigation happens against a live widget tree.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier.setPlayerExpansion(false);
      notifier.setItem(NavItem.settings);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical, color: Colors.white, size: 22),
      color: const Color(0xFF232323),
      onSelected: (value) {
        switch (value) {
          case 'songOptions':
            _openSongOptions(context, ref);
          case 'fullscreen':
            onToggleFullscreen();
          case 'settings':
            _openSettings(context, ref);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'songOptions',
          child: Row(
            children: [
              const Icon(LucideIcons.listMusic, size: 18, color: Colors.white70),
              const SizedBox(width: 10),
              Text(
                l10n.songOptions,
                style: AppFonts.jostStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'fullscreen',
          child: Row(
            children: [
              Icon(
                fullscreen ? LucideIcons.minimize : LucideIcons.maximize,
                size: 18,
                color: Colors.white70,
              ),
              const SizedBox(width: 10),
              Text(
                fullscreen ? l10n.exitFullscreen : l10n.fullscreen,
                style: AppFonts.jostStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              const Icon(LucideIcons.settings, size: 18, color: Colors.white70),
              const SizedBox(width: 10),
              Text(l10n.settings, style: AppFonts.jostStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Minimize / maximize / close buttons, hidden in true fullscreen.
class _WindowControls extends StatefulWidget {
  const _WindowControls({required this.fullscreen});

  final bool fullscreen;

  @override
  State<_WindowControls> createState() => _WindowControlsState();
}

class _WindowControlsState extends State<_WindowControls> with WindowListener {
  bool _maximized = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) return;
    windowManager.addListener(this);
    _refresh();
  }

  Future<void> _refresh() async {
    final m = await windowManager.isMaximized();
    if (!mounted) return;
    setState(() => _maximized = m);
  }

  @override
  void onWindowMaximize() => _refresh();
  @override
  void onWindowUnmaximize() => _refresh();

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      super.dispose();
      return;
    }
    windowManager.removeListener(this);
    super.dispose();
  }

  Widget _button({
    required IconData icon,
    required VoidCallback onTap,
    Color? hoverColor,
    String? tooltip,
  }) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: hoverColor ?? Colors.white.withValues(alpha: 0.1),
          child: Tooltip(
            message: tooltip ?? '',
            child: Center(
              child: Icon(icon, size: 15, color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS || widget.fullscreen) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _button(
          icon: LucideIcons.minus,
          tooltip: 'Minimize',
          onTap: windowManager.minimize,
        ),
        _button(
          icon: LucideIcons.panelTop,
          tooltip: AppLocalizations.of(context)!.minimizeToTray,
          onTap: () => SystemTrayService.instance.minimizeToTray(),
        ),
        _button(
          icon: _maximized ? LucideIcons.copy : LucideIcons.square,
          tooltip: _maximized ? 'Restore' : 'Maximize',
          onTap: () => _maximized
              ? windowManager.unmaximize()
              : windowManager.maximize(),
        ),
        _button(
          icon: LucideIcons.x,
          tooltip: 'Close',
          hoverColor: Colors.redAccent,
          onTap: windowManager.close,
        ),
      ],
    );
  }
}

// ============================================================================
// RESPONSIVE CONTENT — horizontal split when wide, vertical deck when narrow
// ============================================================================

class _ResponsiveContent extends StatelessWidget {
  const _ResponsiveContent({
    required this.screenWidth,
    required this.song,
    required this.isPlaying,
    required this.isShuffle,
    required this.repeatMode,
    required this.position,
    required this.duration,
    required this.l10n,
    required this.activePanel,
    required this.onTogglePlay,
    required this.onSkipPrevious,
    required this.onSkipNext,
    required this.onToggleShuffle,
    required this.onCycleRepeat,
    required this.onToggleFavorite,
    required this.onSeek,
    required this.onToggleQueue,
    required this.onToggleLyrics,
  });

  final Song song;
  final bool isPlaying;
  final bool isShuffle;
  final RepeatMode repeatMode;
  final Duration position;
  final Duration duration;
  final AppLocalizations l10n;
  final PlayerPanelTab? activePanel;
  final double screenWidth;
  final VoidCallback onTogglePlay;
  final VoidCallback onSkipPrevious;
  final VoidCallback onSkipNext;
  final VoidCallback onToggleShuffle;
  final VoidCallback onCycleRepeat;
  final VoidCallback onToggleFavorite;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onToggleQueue;
  final VoidCallback onToggleLyrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        // Decide the arrangement from the un-shrunk window width so that
        // opening the side panel never flips the player between the split
        // and the deck layout.
        if (screenWidth < _verticalBreakpoint) {
          return _VerticalContent(
            width: w,
            song: song,
            isPlaying: isPlaying,
            isShuffle: isShuffle,
            repeatMode: repeatMode,
            position: position,
            duration: duration,
            l10n: l10n,
            activePanel: activePanel,
            onTogglePlay: onTogglePlay,
            onSkipPrevious: onSkipPrevious,
            onSkipNext: onSkipNext,
            onToggleShuffle: onToggleShuffle,
            onCycleRepeat: onCycleRepeat,
            onToggleFavorite: onToggleFavorite,
            onSeek: onSeek,
            onToggleQueue: onToggleQueue,
            onToggleLyrics: onToggleLyrics,
          );
        }
        return _HorizontalContent(
          width: w,
          song: song,
          isPlaying: isPlaying,
          isShuffle: isShuffle,
          repeatMode: repeatMode,
          position: position,
          duration: duration,
          l10n: l10n,
          activePanel: activePanel,
          onTogglePlay: onTogglePlay,
          onSkipPrevious: onSkipPrevious,
          onSkipNext: onSkipNext,
          onToggleShuffle: onToggleShuffle,
          onCycleRepeat: onCycleRepeat,
          onToggleFavorite: onToggleFavorite,
          onSeek: onSeek,
          onToggleQueue: onToggleQueue,
          onToggleLyrics: onToggleLyrics,
        );
      },
    );
  }
}

/// Horizontal split: art left / info right. The art keeps a 1:1 aspect and
/// scales down gently between 1350 and 1100 px; the seek bar shrinks faster.
class _HorizontalContent extends StatelessWidget {
  const _HorizontalContent({
    required this.width,
    required this.song,
    required this.isPlaying,
    required this.isShuffle,
    required this.repeatMode,
    required this.position,
    required this.duration,
    required this.l10n,
    required this.activePanel,
    required this.onTogglePlay,
    required this.onSkipPrevious,
    required this.onSkipNext,
    required this.onToggleShuffle,
    required this.onCycleRepeat,
    required this.onToggleFavorite,
    required this.onSeek,
    required this.onToggleQueue,
    required this.onToggleLyrics,
  });

  final double width;
  final Song song;
  final bool isPlaying;
  final bool isShuffle;
  final RepeatMode repeatMode;
  final Duration position;
  final Duration duration;
  final AppLocalizations l10n;
  final PlayerPanelTab? activePanel;
  final VoidCallback onTogglePlay;
  final VoidCallback onSkipPrevious;
  final VoidCallback onSkipNext;
  final VoidCallback onToggleShuffle;
  final VoidCallback onCycleRepeat;
  final VoidCallback onToggleFavorite;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onToggleQueue;
  final VoidCallback onToggleLyrics;

  double get _artSize {
    if (width >= 1350) return _artMax;
    return (_artMax - ((1350 - width) * (120 / 250))).clamp(360.0, _artMax);
  }

  double get _seekHeight {
    if (width >= 1350) return 44;
    return (44 - ((1350 - width) * (18 / 250))).clamp(26.0, 44.0);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 44,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _BreathingAlbumArt(
                artPath: song.artPath,
                isPlaying: isPlaying,
                maxSize: _artSize,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 56,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 40, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  song.title,
                                  style: AppFonts.jostStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(
                                  width: 40,
                                  height: 40,
                                ),
                                icon: Icon(
                                  song.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: song.isFavorite
                                      ? Colors.red
                                      : Colors.white60,
                                  size: 24,
                                ),
                                onPressed: onToggleFavorite,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            song.artist ?? l10n.unknownArtist,
                            style: AppFonts.jostStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 32),
                          _SeekBarView(
                            position: position,
                            duration: duration,
                            isPlaying: isPlaying,
                            onSeek: onSeek,
                            songPath: song.path,
                            height: _seekHeight,
                          ),
                          _TimeRow(position: position, duration: duration),
                          const SizedBox(height: 24),
                          _MobileMainControls(
                            isPlaying: isPlaying,
                            onTogglePlay: onTogglePlay,
                            onSkipPrevious: onSkipPrevious,
                            onSkipNext: onSkipNext,
                          ),
                          const SizedBox(height: 14),
                          _MobileUtilityControls(
                            isShuffle: isShuffle,
                            repeatMode: repeatMode,
                            activePanel: activePanel,
                            onToggleShuffle: onToggleShuffle,
                            onCycleRepeat: onCycleRepeat,
                            onToggleQueue: onToggleQueue,
                            onToggleLyrics: onToggleLyrics,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const _BottomRow(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Vertical "deck" composition for narrow widths — art on top, controls below.
class _VerticalContent extends StatelessWidget {
  const _VerticalContent({
    required this.width,
    required this.song,
    required this.isPlaying,
    required this.isShuffle,
    required this.repeatMode,
    required this.position,
    required this.duration,
    required this.l10n,
    required this.activePanel,
    required this.onTogglePlay,
    required this.onSkipPrevious,
    required this.onSkipNext,
    required this.onToggleShuffle,
    required this.onCycleRepeat,
    required this.onToggleFavorite,
    required this.onSeek,
    required this.onToggleQueue,
    required this.onToggleLyrics,
  });

  final double width;
  final Song song;
  final bool isPlaying;
  final bool isShuffle;
  final RepeatMode repeatMode;
  final Duration position;
  final Duration duration;
  final AppLocalizations l10n;
  final PlayerPanelTab? activePanel;
  final VoidCallback onTogglePlay;
  final VoidCallback onSkipPrevious;
  final VoidCallback onSkipNext;
  final VoidCallback onToggleShuffle;
  final VoidCallback onCycleRepeat;
  final VoidCallback onToggleFavorite;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onToggleQueue;
  final VoidCallback onToggleLyrics;

  double _artSize(double maxHeight) {
    final byWidth = (width * 0.5).clamp(240.0, 360.0);
    // Reserve everything below the art plus its trailing gap so the column
    // always fits (prevents the bottom controls from overflowing at the
    // 800px minimum window height).
    const double fixedHeight = 340;
    final byHeight = maxHeight - fixedHeight;
    return min(byWidth, max(200.0, byHeight));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 8, 48, 20),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final artSize = _artSize(constraints.maxHeight);
                  return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BreathingAlbumArt(
                    artPath: song.artPath,
                    isPlaying: isPlaying,
                    maxSize: artSize,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          song.title,
                          textAlign: TextAlign.center,
                          style: AppFonts.jostStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 44,
                            height: 44,
                          ),
                          icon: Icon(
                            song.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: song.isFavorite
                                ? Colors.red
                                : Colors.white60,
                            size: 24,
                          ),
                          onPressed: onToggleFavorite,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    song.artist ?? l10n.unknownArtist,
                    textAlign: TextAlign.center,
                    style: AppFonts.jostStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 15.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        _SeekBarView(
                          position: position,
                          duration: duration,
                          isPlaying: isPlaying,
                          onSeek: onSeek,
                          songPath: song.path,
                          height: 36,
                          barCount: 40,
                        ),
                        _TimeRow(position: position, duration: duration),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        _MobileMainControls(
                          isPlaying: isPlaying,
                          onTogglePlay: onTogglePlay,
                          onSkipPrevious: onSkipPrevious,
                          onSkipNext: onSkipNext,
                        ),
                        const SizedBox(height: 14),
                        _MobileUtilityControls(
                          isShuffle: isShuffle,
                          repeatMode: repeatMode,
                          activePanel: activePanel,
                          onToggleShuffle: onToggleShuffle,
                          onCycleRepeat: onCycleRepeat,
                          onToggleQueue: onToggleQueue,
                          onToggleLyrics: onToggleLyrics,
                        ),
                      ],
                    ),
                  ),
                ],
              );
                },
              ),
            ),
          ),
          const _BottomRow(),
        ],
      ),
    );
  }
}

// ============================================================================
// SHARED SUB-WIDGETS
// ============================================================================

/// Bottom row: volume control (queue / lyrics live in the utility row now).
class _BottomRow extends StatelessWidget {
  const _BottomRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _VolumeControl(),
      ],
    );
  }
}

/// Main playback controls matching the mobile expanded player: previous /
/// play-pause / next as glass pills that stretch across the row.
class _MobileMainControls extends StatelessWidget {
  const _MobileMainControls({
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onSkipPrevious,
    required this.onSkipNext,
  });

  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final VoidCallback onSkipPrevious;
  final VoidCallback onSkipNext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PremiumSection(
          heroTag: 'desktop_player_prev_btn',
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            bottomLeft: Radius.circular(32),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          width: 96,
          height: 60,
          showShadow: false,
          useBlur: true,
          forceNoBlur: true,
          useExpanded: false,
          onTap: onSkipPrevious,
          child: SvgPicture.asset(
            AppIcons.prev,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
            width: 18,
            height: 18,
          ),
        ),
        const SizedBox(width: 6),
        PremiumSection(
          heroTag: 'desktop_player_play_pause_btn',
          borderRadius: BorderRadius.circular(12),
          width: 96,
          height: 60,
          showShadow: false,
          useBlur: true,
          forceNoBlur: true,
          animate: true,
          useExpanded: false,
          backgroundColor: isPlaying ? null : colorScheme.primary,
          onTap: onTogglePlay,
          child: AnimatedScale(
            scale: 1.1,
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
                      : HSLColor.fromColor(colorScheme.primary)
                          .withLightness(0.15)
                          .toColor(),
                  size: 28,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 6),
        PremiumSection(
          heroTag: 'desktop_player_next_btn',
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          width: 96,
          height: 60,
          useBlur: true,
          showShadow: false,
          forceNoBlur: true,
          useExpanded: false,
          onTap: onSkipNext,
          child: SvgPicture.asset(
            AppIcons.next,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
            width: 18,
            height: 18,
          ),
        ),
      ],
    );
  }
}

/// Utility controls matching the mobile expanded player: shuffle / repeat /
/// lyrics / queue as glass pills that stretch across the row.
class _MobileUtilityControls extends StatelessWidget {
  const _MobileUtilityControls({
    required this.isShuffle,
    required this.repeatMode,
    required this.activePanel,
    required this.onToggleShuffle,
    required this.onCycleRepeat,
    required this.onToggleQueue,
    required this.onToggleLyrics,
  });

  final bool isShuffle;
  final RepeatMode repeatMode;
  final PlayerPanelTab? activePanel;
  final VoidCallback onToggleShuffle;
  final VoidCallback onCycleRepeat;
  final VoidCallback onToggleQueue;
  final VoidCallback onToggleLyrics;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Shuffle
        PremiumSection(
          heroTag: 'desktop_util_shuffle',
          width: 68,
          height: 52,
          useBlur: true,
          showShadow: false,
          animate: true,
          backgroundColor: isShuffle ? colorScheme.primary : null,
          forceNoBlur: true,
          useExpanded: false,
          onTap: onToggleShuffle,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            bottomLeft: Radius.circular(26),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          child: SvgPicture.asset(
            AppIcons.shuffle,
            colorFilter: ColorFilter.mode(
              isShuffle
                  ? HSLColor.fromColor(colorScheme.primary)
                      .withLightness(0.15)
                      .toColor()
                  : Colors.white70,
              BlendMode.srcIn,
            ),
            width: 15,
            height: 15,
          ),
        ),
        const SizedBox(width: 6),
        // Repeat
        PremiumSection(
          heroTag: 'desktop_util_repeat',
          width: 68,
          height: 52,
          showShadow: false,
          useBlur: true,
          animate: true,
          backgroundColor: repeatMode != RepeatMode.off
              ? colorScheme.primary
              : null,
          forceNoBlur: true,
          useExpanded: false,
          onTap: onCycleRepeat,
          borderRadius: BorderRadius.circular(12),
          child: SvgPicture.asset(
            repeatMode == RepeatMode.one
                ? 'assets/music_bar_Icons/repeat_1.svg'
                : AppIcons.repeat,
            colorFilter: repeatMode == RepeatMode.one
                ? null
                : ColorFilter.mode(
                    repeatMode != RepeatMode.off
                        ? HSLColor.fromColor(colorScheme.primary)
                            .withLightness(0.15)
                            .toColor()
                        : Colors.white70,
                    BlendMode.srcIn,
                  ),
            width: 15,
            height: 15,
          ),
        ),
        // A-B Looper
        Consumer(
          builder: (context, ref, _) {
            final showAB = ref.watch(
              settingsProvider.select((s) => s.showFullscreenABLooper),
            );
            if (!showAB) return const SizedBox.shrink();

            final isABLooping =
                ref.watch(playbackProvider.select((s) => s.isABLooping));
            final hasLoop = ref.watch(playbackProvider.select(
                (s) => s.loopStart != null && s.loopEnd != null));
            return Padding(
              padding: const EdgeInsets.only(left: 6),
              child: PremiumSection(
                heroTag: 'desktop_util_ab_looper',
                width: 68,
                height: 52,
                useBlur: true,
                showShadow: false,
                animate: true,
                forceNoBlur: true,
                useExpanded: false,
                backgroundColor: isABLooping
                    ? colorScheme.primary
                    : (hasLoop
                        ? colorScheme.primary.withValues(alpha: 0.25)
                        : null),
                onTap: () => showABLooper(context),
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Text(
                    'A-B',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isABLooping
                          ? HSLColor.fromColor(colorScheme.primary)
                              .withLightness(0.15)
                              .toColor()
                          : (hasLoop ? colorScheme.primary : Colors.white70),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Sleep Timer
        Consumer(
          builder: (context, ref, _) {
            final showSleep = ref.watch(
              settingsProvider.select((s) => s.showFullscreenSleepTimer),
            );
            if (!showSleep) return const SizedBox.shrink();

            final isSleepActive =
                ref.watch(playbackProvider.select((s) => s.isSleepTimerActive));
            final playbackState = ref.watch(playbackProvider);
            return Padding(
              padding: const EdgeInsets.only(left: 6),
              child: PremiumSection(
                heroTag: 'desktop_util_sleep_timer',
                width: 68,
                height: 52,
                useBlur: true,
                showShadow: false,
                animate: true,
                forceNoBlur: true,
                useExpanded: false,
                backgroundColor:
                    isSleepActive ? colorScheme.primary : null,
                onTap: () => showSleepTimer(context, ref),
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: isSleepActive
                      ? Text(
                          formatSleepTimerRemaining(playbackState),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: HSLColor.fromColor(colorScheme.primary)
                                .withLightness(0.15)
                                .toColor(),
                          ),
                        )
                      : Icon(
                          LucideIcons.timer,
                          size: 16,
                          color: Colors.white70,
                        ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        // Lyrics
        PremiumSection(
          heroTag: 'desktop_util_lyrics',
          width: 68,
          height: 52,
          useBlur: true,
          showShadow: false,
          animate: true,
          forceNoBlur: true,
          useExpanded: false,
          backgroundColor: activePanel == PlayerPanelTab.lyrics
              ? colorScheme.primary
              : null,
          onTap: onToggleLyrics,
          borderRadius: BorderRadius.circular(12),
          child: SvgPicture.asset(
            AppIcons.lyrics,
            colorFilter: ColorFilter.mode(
              activePanel == PlayerPanelTab.lyrics
                  ? HSLColor.fromColor(colorScheme.primary)
                      .withLightness(0.15)
                      .toColor()
                  : Colors.white70,
              BlendMode.srcIn,
            ),
            width: 15,
            height: 15,
          ),
        ),
        const SizedBox(width: 6),
        // Queue
        PremiumSection(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            topRight: Radius.circular(26),
            bottomRight: Radius.circular(26),
          ),
          width: 68,
          height: 52,
          showShadow: false,
          forceNoBlur: true,
          useBlur: true,
          animate: true,
          useExpanded: false,
          backgroundColor: activePanel == PlayerPanelTab.queue
              ? colorScheme.primary
              : null,
          onTap: onToggleQueue,
          child: SvgPicture.asset(
            AppIcons.queue,
            colorFilter: ColorFilter.mode(
              activePanel == PlayerPanelTab.queue
                  ? HSLColor.fromColor(colorScheme.primary)
                      .withLightness(0.15)
                      .toColor()
                  : Colors.white70,
              BlendMode.srcIn,
            ),
            width: 14,
            height: 14,
          ),
        ),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.position, required this.duration});

  final Duration position;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.white.withValues(alpha: 0.4),
      fontSize: 12,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_formatDuration(position), style: style),
          Text(_formatDuration(duration), style: style),
        ],
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return '$minutes:$seconds';
}

// ============================================================================
// VISUALIZER SEEK BAR
// Doubles as the seek bar and a live audio visualizer. Each bar keeps a fixed
// base "waveform" shape (used for click/drag-to-seek). While playing, bars
// dance with the real frequency spectrum from spectrumProvider (mpv's own DSP
// tap): bass radiates from the playhead outwards to treble, so the // Live audio visualizer seek bar. Uses real frequency spectrum from mpv's DSP tap
// with attack/release smoothing, spectral tilt normalization, and fallback wave.
// When paused, bars smoothly decay to a crisp linear line.
// ============================================================================

class VisualizerSeekBar extends ConsumerStatefulWidget {
  const VisualizerSeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.onSeek,
    this.songPath,
    this.height = 44,
    this.barCount = 56,
  });

  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final ValueChanged<Duration> onSeek;
  final String? songPath;
  final double height;
  final int barCount;

  @override
  ConsumerState<VisualizerSeekBar> createState() => _VisualizerSeekBarState();
}

class _VisualizerSeekBarState extends ConsumerState<VisualizerSeekBar>
    with SingleTickerProviderStateMixin {
  int _barCount = 56;
  late List<double> _smoothed;

  static const double _attack = 0.40;
  static const double _release = 0.07;

  late Ticker _ticker;
  Duration _elapsed = Duration.zero;

  late List<double> _sinePhase;
  late List<double> _sineFreq;
  late List<double> _freqGain;

  @override
  void initState() {
    super.initState();
    _initBars(widget.barCount);
    _ticker = createTicker(_onTick)..start();
  }

  void _initBars(int count) {
    _barCount = count.clamp(8, 200);
    _smoothed = List.filled(_barCount, 0.0);
    _sinePhase = List.generate(
      _barCount,
      (i) => (i / _barCount) * 2 * pi + (i % 3) * 1.1,
    );
    _sineFreq = List.generate(
      _barCount,
      (i) => 1.0 + (i % 5) * 0.3,
    );
    _freqGain = List.generate(_barCount, (i) {
      final norm = _barCount > 1 ? i / (_barCount - 1) : 0.0;
      return (0.55 + 0.72 * pow(norm, 0.55)).clamp(0.3, 1.3);
    });
  }

  @override
  void didUpdateWidget(covariant VisualizerSeekBar old) {
    super.didUpdateWidget(old);
    if (widget.barCount != old.barCount) {
      _initBars(widget.barCount);
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
        // Center bars = punchy bass & low frequencies; outer bars = mids and treble tapering outward.
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
        final v = (sin(t * _sineFreq[i] * 2.5 + _sinePhase[i]) * 0.4 +
                   sin(t * _sineFreq[i] * 1.3 + _sinePhase[i] * 0.7) * 0.3) *
                  0.5 +
              0.5;
        target = (v * (1.0 - norm * 0.45)).clamp(0.1, 1.0);
      }

      if (widget.isPlaying && target > 0.05) {
        final diff = (target - _smoothed[i]).abs();
        if (diff < 0.035) {
          final jitter =
              sin(t * (2.2 + _sineFreq[i] * 0.6) + _sinePhase[i] * 1.3) * 0.030;
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

    if (changed) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _seekAt(double dx, double width) {
    if (widget.duration.inMilliseconds <= 0 || width <= 0) return;
    final fraction = (dx / width).clamp(0.0, 1.0);
    widget.onSeek(widget.duration * fraction);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(spectrumProvider);

    final progress = widget.duration.inMilliseconds > 0
        ? (widget.position.inMilliseconds / widget.duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;
    final accent = Theme.of(context).colorScheme.primary;
    final unfilled = Colors.white.withValues(alpha: 0.12);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              final deltaMs = -event.scrollDelta.dy / 120.0 * 10000;
              final clamped = Duration(
                milliseconds: (widget.position.inMilliseconds + deltaMs)
                    .clamp(
                      0,
                      widget.duration.inMilliseconds,
                    )
                    .round(),
              );
              widget.onSeek(clamped);
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _seekAt(d.localPosition.dx, width),
            onHorizontalDragStart: (d) => _seekAt(d.localPosition.dx, width),
            onHorizontalDragUpdate: (d) => _seekAt(d.localPosition.dx, width),
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: CustomPaint(
                painter: _VisualizerSeekBarPainter(
                  heights: List.unmodifiable(_smoothed),
                  progress: progress,
                  accent: accent,
                  unfilledColor: unfilled,
                  minHeight: 4.0,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VisualizerSeekBarPainter extends CustomPainter {
  final List<double> heights;
  final double progress;
  final Color accent;
  final Color unfilledColor;
  final double minHeight;

  const _VisualizerSeekBarPainter({
    required this.heights,
    required this.progress,
    required this.accent,
    required this.unfilledColor,
    this.minHeight = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final count = heights.length;
    if (count == 0) return;

    // Bar geometry with clean padding
    const hPad = 2.0;
    final totalBarW = size.width - hPad * 2;
    final barW = totalBarW / (count * 1.55);
    final gap = barW * 0.55;
    final slotW = barW + gap;

    final fieldW = slotW * count - gap;
    final startX = (size.width - fieldW) / 2;

    final maxH = size.height * 0.92;
    final minH = minHeight;

    final playheadX = size.width * progress;

    for (int i = 0; i < count; i++) {
      final h = (minH + (maxH - minH) * heights[i]).clamp(minH, maxH);
      final x = startX + i * slotW;
      final top = size.height - h;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barW, h),
        Radius.circular(barW > 3.0 ? 2.5 : 1.5),
      );

      final isFilled = (x + barW / 2) <= playheadX;

      if (isFilled) {
        final shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            accent.withValues(alpha: 1.0),
            accent.withValues(alpha: 0.70),
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromLTWH(x, top, barW, h));
        canvas.drawRRect(rect, Paint()..shader = shader);
      } else {
        canvas.drawRRect(rect, Paint()..color = unfilledColor);
      }
    }
  }

  @override
  bool shouldRepaint(_VisualizerSeekBarPainter old) =>
      old.heights != heights ||
      old.progress != progress ||
      old.accent != accent ||
      old.unfilledColor != unfilledColor;
}

// ============================================================================
// SEEK BAR STYLE SWITCH
// Picks the now-playing seek bar based on the user's setting:
//   0 = visualizer bars, 1 = expressive wiggly slider, 2 = flat clean slider.
// ==========================================================================================

class _SeekBarView extends ConsumerWidget {
  const _SeekBarView({
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.onSeek,
    this.songPath,
    this.height = 44,
    this.barCount = 56,
  });

  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final ValueChanged<Duration> onSeek;
  final String? songPath;
  final double height;
  final int barCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styleIndex = ref.watch(
      settingsProvider.select((s) => s.seekBarStyleIndex),
    );
    final accent = Theme.of(context).colorScheme.primary;

    switch (styleIndex) {
      case 1:
        return ExpressiveSlider(
          position: position,
          duration: duration,
          isPlaying: isPlaying,
          onSeek: onSeek,
          color: accent,
          showTimestamps: false,
        );
      case 2:
        return _FlatSeekBar(
          position: position,
          duration: duration,
          isPlaying: isPlaying,
          onSeek: onSeek,
          color: accent,
        );
      default:
        return VisualizerSeekBar(
          position: position,
          duration: duration,
          isPlaying: isPlaying,
          onSeek: onSeek,
          songPath: songPath,
          height: height,
          barCount: barCount,
        );
    }
  }
}

/// Clean single-line Material slider used for the "flat" seek bar style.
class _FlatSeekBar extends StatefulWidget {
  const _FlatSeekBar({
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.onSeek,
    required this.color,
  });

  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final ValueChanged<Duration> onSeek;
  final Color color;

  @override
  State<_FlatSeekBar> createState() => _FlatSeekBarState();
}

class _FlatSeekBarState extends State<_FlatSeekBar> {
  double? _dragValue;

  void _seekAt(double value) {
    setState(() => _dragValue = value);
    widget.onSeek(widget.duration * value);
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.duration.inMilliseconds > 0
        ? widget.position.inMilliseconds / widget.duration.inMilliseconds
        : 0.0;
    final value = (_dragValue ?? progress).clamp(0.0, 1.0);

    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          // Scroll wheel over the seek bar nudges the playback position.
          final deltaMs = -event.scrollDelta.dy / 120.0 * 10000;
          final clamped = Duration(
            milliseconds: (widget.position.inMilliseconds + deltaMs)
                .clamp(0, widget.duration.inMilliseconds)
                .round(),
          );
          widget.onSeek(clamped);
        }
      },
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 4,
          activeTrackColor: widget.color,
          inactiveTrackColor: Colors.white10,
          trackShape: const PremiumGapTrackShape(gap: 6),
          thumbShape: const LineThumbShape(thumbHeight: 16, thumbWidth: 6),
          overlayShape: SliderComponentShape.noOverlay,
        ),
        child: Slider(
          value: value,
          onChanged: _seekAt,
          onChangeEnd: (_) => setState(() => _dragValue = null),
        ),
      ),
    );
  }
}

// ============================================================================
// ALBUM ART — with the "breathing" glow tied to play state
// ============================================================================

class _BreathingAlbumArt extends StatefulWidget {
  const _BreathingAlbumArt({
    required this.artPath,
    required this.isPlaying,
    required this.maxSize,
  });

  final String? artPath;
  final bool isPlaying;
  final double maxSize;

  @override
  State<_BreathingAlbumArt> createState() => _BreathingAlbumArtState();
}

class _BreathingAlbumArtState extends State<_BreathingAlbumArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );
    if (widget.isPlaying) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _BreathingAlbumArt old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying != old.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.animateTo(0, curve: Curves.easeOut);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final scale = 1 + _controller.value * 0.03;
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: widget.maxSize,
            height: widget.maxSize,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: OptimizedImage(
                  imagePath: widget.artPath,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: Colors.white10,
                    child: const Icon(
                      LucideIcons.music,
                      color: Colors.white24,
                      size: 80,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// VOLUME — wired to the real playback volume state
// ============================================================================

class _VolumeControl extends ConsumerStatefulWidget {
  const _VolumeControl();

  @override
  ConsumerState<_VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends ConsumerState<_VolumeControl> {
  @override
  Widget build(BuildContext context) {
    final volume = ref.watch(playbackProvider.select((s) => s.volume));
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          final delta = event.scrollDelta.dy > 0 ? -0.05 : 0.05;
          ref.read(playbackProvider.notifier).adjustVolume(delta);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: volume <= 0.01 ? 'Unmute' : 'Mute',
            waitDuration: const Duration(milliseconds: 500),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  ref.read(playbackProvider.notifier).toggleMute(),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  volume <= 0.01 ? LucideIcons.volumeX : LucideIcons.volume2,
                  color: Colors.white60,
                  size: 17,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 88,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: SliderComponentShape.noOverlay,
                activeTrackColor: Colors.white60,
                inactiveTrackColor: Colors.white10,
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
    );
  }
}

// ============================================================================
// SIDE PANEL — Queue / Lyrics
// ============================================================================

class _SidePanel extends ConsumerWidget {
  const _SidePanel({
    required this.tab,
    required this.onTabChanged,
    required this.onClose,
    required this.visible,
  });

  final PlayerPanelTab tab;
  final ValueChanged<PlayerPanelTab> onTabChanged;
  final VoidCallback onClose;
  final bool visible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PanelTabs(current: tab, onChanged: onTabChanged, l10n: l10n),
                      const SizedBox(width: 6),
                      _PanelHeaderBadge(current: tab),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 18, color: Colors.white60),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                splashRadius: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: IndexedStack(
              index: tab == PlayerPanelTab.queue ? 0 : 1,
              children: [
                _QueueList(visible: visible),
                _LyricsList(visible: visible),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelHeaderBadge extends ConsumerWidget {
  const _PanelHeaderBadge({required this.current});

  final PlayerPanelTab current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (current == PlayerPanelTab.queue) {
      final queue = ref.watch(playbackProvider.select((s) => s.queue));
      final currentSongPath = ref.watch(
        playbackProvider.select((s) => s.currentSong?.path),
      );
      final currentIdx = queue.indexWhere((s) => s.path == currentSongPath);
      final activeNum = currentIdx >= 0 ? currentIdx + 1 : 0;
      final totalNum = queue.length;

      return Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.listMusic,
              size: 13,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 5),
            Text(
              '$activeNum / $totalNum',
              style: AppFonts.jostStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );
    } else {
      final alignment = ref.watch(
        settingsProvider.select((s) => s.lyricsAlignment),
      );
      final isKaraokeActive = ref.watch(
        playbackProvider.select((s) => s.isVocalReducerActive),
      );
      final colorScheme = Theme.of(context).colorScheme;

      Widget alignBtn(IconData icon, String value, String tooltip) {
        final isSelected = alignment == value;
        return Tooltip(
          message: tooltip,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(settingsProvider.notifier).updateLyricsAlignment(value);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.22)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: isSelected
                    ? Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                        width: 0.8,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 12.5,
                color: isSelected ? colorScheme.primary : Colors.white54,
              ),
            ),
          ),
        );
      }

      return Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: isKaraokeActive
                  ? 'Vocal Reducer (Active) - Tap to disable'
                  : 'Live Vocal Reducer (Instant Karaoke)',
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(playbackProvider.notifier).toggleVocalReducer();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(
                    color: isKaraokeActive
                        ? colorScheme.primary.withValues(alpha: 0.25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: isKaraokeActive
                        ? Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.5),
                            width: 0.8,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isKaraokeActive ? LucideIcons.mic : LucideIcons.micOff,
                        size: 12.5,
                        color: isKaraokeActive ? colorScheme.primary : Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Karaoke',
                        style: AppFonts.jostStyle(
                          fontSize: 11,
                          fontWeight: isKaraokeActive ? FontWeight.bold : FontWeight.normal,
                          color: isKaraokeActive ? colorScheme.primary : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 14,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: Colors.white.withValues(alpha: 0.12),
            ),
            alignBtn(LucideIcons.alignLeft, 'left', 'Left align'),
            const SizedBox(width: 2),
            alignBtn(LucideIcons.alignCenter, 'center', 'Center align'),
            const SizedBox(width: 2),
            alignBtn(LucideIcons.alignRight, 'right', 'Right align'),
          ],
        ),
      );
    }
  }
}

class _PanelTabs extends StatelessWidget {
  const _PanelTabs({
    required this.current,
    required this.onChanged,
    required this.l10n,
  });

  final PlayerPanelTab current;
  final ValueChanged<PlayerPanelTab> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, PlayerPanelTab value) {
      final active = current == value;
      return GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: active ? Colors.white.withValues(alpha: 0.08) : null,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppFonts.jostStyle(
              color: active ? Colors.white : Colors.white60,
              fontSize: 11.5,
              fontWeight: active ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        tab(l10n.playQueue, PlayerPanelTab.queue),
        tab(l10n.lyrics, PlayerPanelTab.lyrics),
      ]),
    );
  }
}

// ============================================================================
// QUEUE — real queue from the playback provider, auto-scrolls to the active
// song and shows a playing equalizer on it.
// ============================================================================

class _QueueList extends ConsumerStatefulWidget {
  const _QueueList({required this.visible});

  final bool visible;

  @override
  ConsumerState<_QueueList> createState() => _QueueListState();
}

class _QueueListState extends ConsumerState<_QueueList> {
  static const double _itemExtent = 58;
  final ScrollController _scrollController = ScrollController();
  int _lastCurrentIndex = -1;
  int _currentIndex = -1;
  bool _lastVisible = false;
  Timer? _scrollTimer;
  Timer? _openTimer;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _openTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  /// Delays the centering until the side panel has finished sliding in,
  /// otherwise the scroll target is computed against a ~0 width viewport and
  /// the active song never becomes visible on open.
  void _scheduleScrollToActive(int index) {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(milliseconds: 480), () {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      final target =
          (index * _itemExtent - position.viewportDimension / 2 +
                  _itemExtent / 2)
              .clamp(0.0, position.maxScrollExtent);
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  /// When the panel is opened, snap back to the active song only if it is not
  /// already visible, otherwise keep the previous scroll position.
  void _scheduleEnsureActiveVisible() {
    _openTimer?.cancel();
    _openTimer = Timer(const Duration(milliseconds: 200), () {
      if (!mounted || !_scrollController.hasClients || _currentIndex < 0) {
        return;
      }
      final position = _scrollController.position;
      final start = _currentIndex * _itemExtent;
      final end = start + _itemExtent;
      if (start >= position.pixels &&
          end <= position.pixels + position.viewportDimension) {
        return;
      }
      final target =
          (start - position.viewportDimension / 2 + _itemExtent / 2)
              .clamp(0.0, position.maxScrollExtent);
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final playback = ref.watch(playbackProvider);
    final queue = playback.queue;
    final currentSongPath = playback.currentSong?.path;
    final isPlaying = playback.isPlaying;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final showPlayed =
        ref.watch(settingsProvider.select((s) => s.showPlayedSongsInQueue));
    final currentIndex = queue.indexWhere((s) => s.path == currentSongPath);
    final displayedQueue = (showPlayed || currentIndex == -1)
        ? queue
        : queue.sublist(currentIndex);
    final targetActiveIdx = showPlayed ? currentIndex : (currentIndex >= 0 ? 0 : -1);

    _currentIndex = targetActiveIdx;
    if (targetActiveIdx >= 0 && targetActiveIdx != _lastCurrentIndex) {
      _lastCurrentIndex = targetActiveIdx;
      if (widget.visible) _scheduleScrollToActive(targetActiveIdx);
    }

    // When the panel becomes visible, scroll to the active song.
    if (widget.visible != _lastVisible) {
      _lastVisible = widget.visible;
      if (widget.visible && targetActiveIdx >= 0) {
        _scrollTimer?.cancel();
        _scheduleScrollToActive(targetActiveIdx);
      }
    }

    if (displayedQueue.isEmpty) {
      return Center(
        child: Text(
          l10n.queueIsEmpty,
          style: AppFonts.jostStyle(color: Colors.white38, fontSize: 14),
        ),
      );
    }

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbVisibility: const WidgetStatePropertyAll(true),
        trackVisibility: const WidgetStatePropertyAll(false),
        thumbColor: WidgetStatePropertyAll(
          Colors.white.withValues(alpha: 0.3),
        ),
        mainAxisMargin: 8,
        crossAxisMargin: 4,
        minThumbLength: 40,
      ),
      child: ReorderableListView.builder(
        scrollController: _scrollController,
        buildDefaultDragHandles: false,
        padding: const EdgeInsets.only(right: 8, bottom: 24),
        itemCount: displayedQueue.length,
        onReorder: (oldI, newI) {
          // displayedQueue is full queue when showPlayed=true, sublist from currentIndex otherwise
          final curDisp = (showPlayed || currentIndex == -1) ? currentIndex : 0;
          // Block dragging played/current songs
          if (currentIndex != -1 && oldI <= curDisp) return;
          // Flutter adjustment
          if (newI > oldI) newI -= 1;
          // Clamp: cannot drop at or before current
          if (currentIndex != -1 && newI <= curDisp) newI = curDisp + 1;
          if (oldI == newI) return;
          // Map displayed → original index
          final int oldOrig;
          final int newOrig;
          if (showPlayed || currentIndex == -1) {
            oldOrig = oldI;
            newOrig = newI;
          } else {
            oldOrig = oldI + currentIndex;
            newOrig = newI + currentIndex;
          }
          ref.read(playbackProvider.notifier).reorderQueueDirect(oldOrig, newOrig);
        },
        proxyDecorator: (child, index, animation) => Material(
          color: Colors.transparent,
          child: child,
        ),
        itemBuilder: (context, i) {
          final song = displayedQueue[i];
          final isCurrent = currentSongPath == song.path;
          final originalIndex = queue.indexWhere((s) => s.path == song.path);
          final isPlayed = currentIndex != -1 &&
              originalIndex != -1 &&
              originalIndex < currentIndex;
          final isDraggable = !isPlayed && !isCurrent;

          final isStopTarget = playback.isSleepTimerActive &&
              playback.sleepTimerSongsRemaining != null &&
              currentIndex != -1 &&
              originalIndex != -1 &&
              originalIndex == currentIndex + playback.sleepTimerSongsRemaining! - 1;

          return GestureDetector(
            key: ValueKey('fsq_${song.path}_$i'),
            onSecondaryTap: () => showSongOptionsBottomSheet(
              context: context,
              ref: ref,
              song: song,
              queueIndex: originalIndex,
              isFromQueue: true,
            ),
            child: Opacity(
              opacity: isPlayed ? 0.38 : 1.0,
              child: SizedBox(
                height: _itemExtent,
                child: InkWell(
                  onTap: () =>
                      ref.read(playbackProvider.notifier).playAtIndex(originalIndex),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? colorScheme.primary.withValues(alpha: 0.16)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isCurrent
                          ? Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.4),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              OptimizedImage(
                                imagePath: song.artPath,
                                width: 38,
                                height: 38,
                                fit: BoxFit.cover,
                                placeholder: Container(
                                  width: 38,
                                  height: 38,
                                  color: Colors.white10,
                                  child: const Icon(
                                    LucideIcons.music,
                                    size: 14,
                                    color: Colors.white24,
                                  ),
                                ),
                              ),
                              if (isCurrent)
                                Positioned.fill(
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: isPlaying ? 1.0 : 0.0,
                                    child: Container(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/android_icons/Playing.gif',
                                          width: 20,
                                          height: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.jostStyle(
                                  color: isCurrent ? colorScheme.primary : Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                              Text(
                                song.album != null && song.album!.isNotEmpty
                                    ? '${song.artist ?? l10n.unknownArtist} · ${song.album}'
                                    : (song.artist ?? l10n.unknownArtist),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.jostStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isStopTarget)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.35),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.timer, size: 10, color: colorScheme.primary),
                                const SizedBox(width: 3),
                                Text(
                                  'STOP',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (isCurrent && isPlaying)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              LucideIcons.volume2,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              _formatDuration(Duration(milliseconds: song.duration ?? 0)),
                              style: TextStyle(
                                color: Colors.white24,
                                fontSize: 11,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                        if (isDraggable)
                          ReorderableDragStartListener(
                            index: i,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                LucideIcons.gripVertical,
                                size: 16,
                                color: Colors.white24,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 28),
                      ],
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

// ============================================================================
// LYRICS — real parsed lyrics with auto-scroll centering the active line
// ============================================================================

class _LyricsList extends ConsumerStatefulWidget {
  const _LyricsList({required this.visible});

  final bool visible;

  @override
  ConsumerState<_LyricsList> createState() => _LyricsListState();
}

class _LyricsListState extends ConsumerState<_LyricsList> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _lineKeys = {};
  int _lastActiveIndex = -1;
  int _activeIndex = -1;
  bool _lastVisible = false;
  Timer? _scrollTimer;
  Timer? _openTimer;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _openTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleScrollToActive(int index) {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      final currentKey = _lineKeys[index];
      if (currentKey?.currentContext != null) {
        Scrollable.ensureVisible(
          currentKey!.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          alignment: 0.48,
        );
      }
    });
  }

  void _scheduleEnsureActiveVisible() {
    _openTimer?.cancel();
    _openTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted || _activeIndex < 0) return;
      final currentKey = _lineKeys[_activeIndex];
      if (currentKey?.currentContext != null) {
        Scrollable.ensureVisible(
          currentKey!.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          alignment: 0.48,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lyrics = ref.watch(lyricsProvider);
    final position = ref.watch(playbackProvider.select((s) => s.position));
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final uniformFontSize = settings.uniformLyricsFontSize;
    final alignmentString = settings.lyricsAlignment;

    final textAlign = alignmentString == 'left'
        ? TextAlign.left
        : alignmentString == 'right'
            ? TextAlign.right
            : TextAlign.center;

    final crossAxis = alignmentString == 'left'
        ? CrossAxisAlignment.start
        : alignmentString == 'right'
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.center;

    final lineAlignment = alignmentString == 'left'
        ? Alignment.centerLeft
        : alignmentString == 'right'
            ? Alignment.centerRight
            : Alignment.center;

    if (lyrics.isLoading) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white38,
          ),
        ),
      );
    }

    if (lyrics.parsedLines.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.languages, size: 32, color: Colors.white24),
            const SizedBox(height: 12),
            Text(
              l10n.noLyrics,
              textAlign: TextAlign.center,
              style: AppFonts.jostStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final lines = lyrics.parsedLines;
    int activeIndex = 0;
    for (int i = 0; i < lines.length; i++) {
      if (position >= lines[i].startTime) {
        activeIndex = i;
      } else {
        break;
      }
    }

    _activeIndex = activeIndex;
    if (activeIndex != _lastActiveIndex) {
      _lastActiveIndex = activeIndex;
      if (widget.visible) _scheduleScrollToActive(activeIndex);
    }

    if (widget.visible != _lastVisible) {
      _lastVisible = widget.visible;
      if (widget.visible) {
        _scrollTimer?.cancel();
        _scheduleEnsureActiveVisible();
      }
    }

    final primaryColor = Theme.of(context).colorScheme.primary;

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbVisibility: const WidgetStatePropertyAll(true),
        trackVisibility: const WidgetStatePropertyAll(false),
        thumbColor: WidgetStatePropertyAll(
          Colors.white.withValues(alpha: 0.25),
        ),
        mainAxisMargin: 8,
        crossAxisMargin: 4,
        minThumbLength: 40,
      ),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: false,
        thickness: 4,
        radius: const Radius.circular(4),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(
            left: 20,
            right: 28,
            top: 180,
            bottom: 260,
          ),
          itemCount: lines.length,
          itemBuilder: (context, i) {
            final line = lines[i];
            final isCurrent = i == activeIndex;
            final lineKey = _lineKeys.putIfAbsent(i, () => GlobalKey());

            return KeyedSubtree(
              key: lineKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                              ? 19.0
                              : (isCurrent ? 22.0 : 17.5),
                          fontWeight: isCurrent
                              ? FontWeight.w700
                              : FontWeight.w400,
                          height: 1.35,
                          shadows: isCurrent
                              ? [
                                  Shadow(
                                    color: primaryColor.withValues(alpha: 0.3),
                                    blurRadius: 18,
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
      ),
    );
  }
}

class _DesktopBottomVisualizer extends ConsumerStatefulWidget {
  final bool isPlaying;
  final Color accent;

  const _DesktopBottomVisualizer({
    required this.isPlaying,
    required this.accent,
  });

  @override
  ConsumerState<_DesktopBottomVisualizer> createState() =>
      _DesktopBottomVisualizerState();
}

class _DesktopBottomVisualizerState
    extends ConsumerState<_DesktopBottomVisualizer>
    with SingleTickerProviderStateMixin {
  static const int _barCount = 64;
  final List<double> _smoothed = List.filled(_barCount, 0.0);
  static const double _attack = 0.45;
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

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
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
        // Normal distribution center-out mapping:
        // Center of the screen represents punchy bass and powerful lower mids.
        // Moving towards both outer edges maps gracefully to mids, highs, and air.
        final center = (_barCount - 1) / 2.0;
        final norm = (i - center).abs() / center; // 0.0 at center -> 1.0 at outer edges

        final audioFreqScale = pow(norm, 0.85).toDouble();
        final maxActiveBucket =
            (raw.length * 0.72).clamp(1.0, raw.length.toDouble() - 1);
        final rawPos = audioFreqScale * maxActiveBucket;
        final idx0 = rawPos.floor().clamp(0, raw.length - 1);
        final idx1 = rawPos.ceil().clamp(0, raw.length - 1);
        final frac = rawPos - idx0;
        final interpolated = raw[idx0] * (1.0 - frac) + raw[idx1] * frac;

        final startIdx = (audioFreqScale * maxActiveBucket)
            .floor()
            .clamp(0, raw.length - 1);
        final endIdx = ((audioFreqScale + 1.0 / (_barCount / 2)) * maxActiveBucket)
            .ceil()
            .clamp(startIdx + 1, raw.length);
        double rangePeak = 0;
        for (int j = startIdx; j < endIdx; j++) {
          if (raw[j] > rangePeak) rangePeak = raw[j];
        }

        final peak = max(interpolated, rangePeak);
        // Symmetrical normal distribution bell curve tapering
        final bellShape = (1.0 - 0.22 * pow(norm, 1.4)).clamp(0.4, 1.0);
        final trebleBoost = (0.75 + 0.65 * pow(norm, 0.6)).clamp(0.5, 1.4);
        target = (peak * trebleBoost * bellShape).clamp(0.0, 0.95);
      } else {
        final center = (_barCount - 1) / 2.0;
        final norm = (i - center).abs() / center;
        final v = (sin(t * _sineFreq[i] * 2.5 + _sinePhase[i]) * 0.4 +
                    sin(t * _sineFreq[i] * 1.3 + _sinePhase[i] * 0.7) * 0.3) *
                0.5 +
            0.5;
        target = (v * (1.0 - norm * 0.45)).clamp(0.1, 1.0);
      }

      if (widget.isPlaying && target > 0.05) {
        final diff = (target - _smoothed[i]).abs();
        if (diff < 0.035) {
          final jitter =
              sin(t * (2.2 + _sineFreq[i] * 0.6) + _sinePhase[i] * 1.3) *
              0.030;
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

    if (changed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep spectrumProvider active and listening to real mpv FFT stream
    ref.watch(spectrumProvider);

    return AnimatedOpacity(
      opacity: widget.isPlaying ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: CustomPaint(
        painter: _DesktopBottomVisualizerPainter(
          levels: List.unmodifiable(_smoothed),
          accent: widget.accent,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _DesktopBottomVisualizerPainter extends CustomPainter {
  final List<double> levels;
  final Color accent;

  const _DesktopBottomVisualizerPainter({
    required this.levels,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (levels.isEmpty || size.width <= 0 || size.height <= 0) return;

    final count = levels.length;
    const hPad = 16.0;
    final totalW = size.width - hPad * 2;
    final barW = totalW / (count * 1.55);
    final gap = barW * 0.55;
    final slotW = barW + gap;

    final fieldW = slotW * count - gap;
    final startX = (size.width - fieldW) / 2;

    final maxH = size.height * 0.70;
    const minH = 4.0;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final val = levels[i].clamp(0.0, 1.0);
      final h = (minH + (maxH - minH) * val).clamp(minH, maxH);
      final x = startX + i * slotW;
      final top = size.height - h;

      final rect = Rect.fromLTWH(x, top, barW, h);
      paint.shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          accent.withValues(alpha: 0.85),
          accent.withValues(alpha: 0.65),
          accent.withValues(alpha: 0.25),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(rect);

      final rrect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(barW / 2),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(_DesktopBottomVisualizerPainter oldDelegate) => true;
}
