import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';

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
        // Entering true fullscreen immediately when the user enables the
        // setting while the player is already open.
        if (next) {
          _autoEnteredFullscreen = true;
          windowManager.setFullScreen(true);
        }
      },
    );
  }

  Future<void> _maybeAutoFullscreen() async {
    final enable = ref.read(settingsProvider).nowPlayingFullscreen;
    if (!enable) return;
    _autoEnteredFullscreen = true;
    await windowManager.setFullScreen(true);
    if (mounted) _syncFullscreen();
  }

  @override
  void dispose() {
    _fullscreenSettingSub?.close();
    if (!(Platform.isAndroid || Platform.isIOS)) {
      windowManager.removeListener(this);
      // Restore the normal window when the now-playing view closes if the
      // "True fullscreen" setting opened it fullscreen.
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
          onTap: windowManager.hide,
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
// tap): bass radiates from the playhead outwards to treble, so the whole strip
// visibly reacts to the music. No Ticker here — Riverpod rebuilds at the tap's
// emit rate drive the motion.
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

class _VisualizerSeekBarState extends ConsumerState<VisualizerSeekBar> {
  late List<double> _baseHeights; // procedural fallback shape
  List<double>? _barBases; // real per-song waveform, downsampled to barCount

  @override
  void initState() {
    super.initState();
    _generateFallbackShape();
  }

  void _generateFallbackShape() {
    _baseHeights = List.generate(widget.barCount, (i) {
      final v = 18 +
          14 * sin(i * 0.34) +
          9 * sin(i * 0.71 + 1.3) +
          (i % 7 == 0 ? 6 : 0);
      return (v + 20).clamp(14, 100) / 100;
    });
  }

  void _syncWaveform(List<double>? wave) {
    if (wave == null || wave.isEmpty) {
      _barBases = null;
      return;
    }
    // Downsample the fine timeline to barCount buckets. Blend the peak
    // (drums/beats) with the average so real dynamics stay visible.
    _barBases = List.generate(widget.barCount, (i) {
      final start = (i * wave.length) ~/ widget.barCount;
      final end = ((i + 1) * wave.length) ~/ widget.barCount;
      double sum = 0;
      double peak = 0;
      for (int j = start; j < end; j++) {
        final v = wave[j];
        sum += v;
        if (v > peak) peak = v;
      }
      final avg = end > start ? sum / (end - start) : 0.0;
      final value = peak * 0.65 + avg * 0.35;
      return (pow(value, 0.5).toDouble() * 0.85 + 0.12).clamp(0.12, 1.0);
    });
  }

  @override
  void didUpdateWidget(covariant VisualizerSeekBar old) {
    super.didUpdateWidget(old);
    if (widget.barCount != old.barCount) _generateFallbackShape();
  }

  void _seekAt(double dx, double width) {
    final fraction = (dx / width).clamp(0.0, 1.0);
    widget.onSeek(widget.duration * fraction);
  }

  @override
  Widget build(BuildContext context) {
    final wave = widget.songPath == null
        ? null
        : ref.watch(waveformProvider(widget.songPath!)).value;
    _syncWaveform(wave);

    // Real, live frequency spectrum from mpv's DSP pipeline. Index 0 is the
    // lowest band; higher indices are progressively higher frequencies.
    final spectrum = ref.watch(spectrumProvider);

    final progress = widget.duration.inMilliseconds > 0
        ? widget.position.inMilliseconds / widget.duration.inMilliseconds
        : 0.0;
    final accent = Theme.of(context).colorScheme.primary;
    final unfilled = Colors.white.withValues(alpha: 0.08);
    final playheadBar = progress * widget.barCount;
    final hasReal = _barBases != null;
    // Furthest any bar sits from the playhead; used to map a bar's distance
    // from the playhead onto the frequency axis (bass radiates from the
    // playhead, treble spreads further out).
    final maxDist = max(playheadBar, widget.barCount - 1 - playheadBar);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              // Scroll wheel over the seek bar nudges the playback position.
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
            onHorizontalDragUpdate: (d) => _seekAt(d.localPosition.dx, width),
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(widget.barCount, (i) {
                  final filled = i / widget.barCount < progress;
                  var factor = hasReal ? _barBases![i] : _baseHeights[i];

                  if (widget.isPlaying && spectrum.isNotEmpty) {
                    // Distance from the playhead maps to a spectrum bucket:
                    // the playhead sits on the bass, and frequency climbs as
                    // bars spread outwards. sqrt-lifts quiet bands so the
                    // whole strip visibly dances even during softer parts.
                    final dist = (i - playheadBar).abs();
                    final norm = maxDist > 0
                        ? (dist / maxDist).clamp(0.0, 1.0)
                        : 0.0;
                    final bandIdx = (norm * (spectrum.length - 1)).round();
                    final mag = spectrum[bandIdx];
                    factor *= 0.45 + 1.55 * pow(mag, 0.5);
                  }

                  final barHeight = (factor * widget.height)
                      .clamp(3.0, widget.height)
                      .toDouble();
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.2),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: filled ? accent : unfilled,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// SEEK BAR STYLE SWITCH
// Picks the now-playing seek bar based on the user's setting:
//   0 = visualizer bars, 1 = expressive wiggly slider, 2 = flat clean slider.
// ============================================================================

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
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
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
              _PanelTabs(current: tab, onChanged: onTabChanged, l10n: l10n),
              const Spacer(),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 18, color: Colors.white60),
                onPressed: onClose,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? Colors.white.withValues(alpha: 0.08) : null,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppFonts.jostStyle(
              color: active ? Colors.white : Colors.white60,
              fontSize: 12,
              fontWeight: active ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
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
    final queue = ref.watch(playbackProvider.select((s) => s.queue));
    final currentSongPath = ref.watch(
      playbackProvider.select((s) => s.currentSong?.path),
    );
    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final currentIndex = queue.indexWhere((s) => s.path == currentSongPath);
    _currentIndex = currentIndex;
    if (currentIndex >= 0 && currentIndex != _lastCurrentIndex) {
      _lastCurrentIndex = currentIndex;
      if (widget.visible) _scheduleScrollToActive(currentIndex);
    }

    // When the panel becomes visible, snap to the active song only if it is
    // off-screen; otherwise keep the remembered scroll position.
    if (widget.visible != _lastVisible) {
      _lastVisible = widget.visible;
      if (widget.visible) {
        _scrollTimer?.cancel();
        _scheduleEnsureActiveVisible();
      }
    }

    if (queue.isEmpty) {
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
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: false,
        thickness: 4,
        radius: const Radius.circular(4),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(right: 24, bottom: 24),
          itemExtent: _itemExtent,
          itemCount: queue.length,
          itemBuilder: (context, i) {
            final song = queue[i];
            final isCurrent = currentSongPath == song.path;
            return InkWell(
              onTap: () =>
                  ref.read(playbackProvider.notifier).playAtIndex(i),
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
                            color:
                                isCurrent ? colorScheme.primary : Colors.white,
                            fontSize: 13.5,
                            fontWeight: isCurrent
                                ? FontWeight.w600
                                : FontWeight.w500,
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
                  if (isCurrent && isPlaying)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        LucideIcons.volume2,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                    )
                  else
                    Text(
                      _formatDuration(Duration(milliseconds: song.duration ?? 0)),
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 11,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
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
  static const double _itemExtent = 46;
  final ScrollController _scrollController = ScrollController();
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
    _scrollTimer = Timer(const Duration(milliseconds: 480), () {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      final target =
          (index * _itemExtent - position.viewportDimension / 2 +
                  _itemExtent / 2)
              .clamp(0.0, position.maxScrollExtent);
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    });
  }

  /// When the panel is opened, snap back to the active line only if it is not
  /// already visible, otherwise keep the previous scroll position.
  void _scheduleEnsureActiveVisible() {
    _openTimer?.cancel();
    _openTimer = Timer(const Duration(milliseconds: 200), () {
      if (!mounted || !_scrollController.hasClients || _activeIndex < 0) {
        return;
      }
      final position = _scrollController.position;
      final start = _activeIndex * _itemExtent;
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
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final lyrics = ref.watch(lyricsProvider);
    final position = ref.watch(playbackProvider.select((s) => s.position));
    final l10n = AppLocalizations.of(context)!;

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

    // When the panel becomes visible, snap to the active line only if it is
    // off-screen; otherwise keep the remembered scroll position.
    if (widget.visible != _lastVisible) {
      _lastVisible = widget.visible;
      if (widget.visible) {
        _scrollTimer?.cancel();
        _scheduleEnsureActiveVisible();
      }
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
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: false,
        thickness: 4,
        radius: const Radius.circular(4),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(right: 24, bottom: 24),
          itemExtent: _itemExtent,
          itemCount: lines.length,
          itemBuilder: (context, i) {
            final line = lines[i];
            final isCurrent = i == activeIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${_formatDuration(line.startTime)}  ',
                      style: TextStyle(
                        color: isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white24,
                        fontSize: 11,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    TextSpan(
                      text: line.text,
                      style: AppFonts.jostStyle(
                        color: isCurrent ? Colors.white : Colors.white38,
                        fontSize: isCurrent ? 15.5 : 15,
                        fontWeight: isCurrent
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
