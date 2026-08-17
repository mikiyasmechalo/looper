import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/playback/presentation/lyrics_notifier.dart';
import 'widgets/advanced_lyric_renderer.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:looper_player/ui/widgets/app_loading_indicator.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';

enum LyricsSyncMode { line, word, char }

class LyricsView extends ConsumerStatefulWidget {
  const LyricsView({super.key});

  @override
  ConsumerState<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends ConsumerState<LyricsView> {
  LyricsSyncMode _syncMode = LyricsSyncMode.line;

  @override
  void initState() {
    super.initState();
    _enableWakelock();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentSong = ref.read(playbackProvider).currentSong;
        if (currentSong != null) {
          final state = ref.read(lyricsProvider);
          if (state.songId != currentSong.id || state.rawLrc == null) {
            ref.read(lyricsProvider.notifier).fetchForSong(currentSong);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _disableWakelock();
    super.dispose();
  }

  Future<void> _enableWakelock() async {
    try {
      await WakelockPlus.enable();
    } catch (_) {}
  }

  Future<void> _disableWakelock() async {
    try {
      await WakelockPlus.disable();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final lyricsState = ref.watch(lyricsProvider);
    final currentSong = ref.watch(playbackProvider.select((s) => s.currentSong));
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // Trigger lyrics fetch when the song changes
    ref.listen(playbackProvider.select((s) => s.currentSong), (previous, next) {
      if (next != null && (previous == null || previous.id != next.id)) {
        ref.read(lyricsProvider.notifier).fetchForSong(next);
      }
    });

    return SafeArea(
      child: Column(
        children: [
          // Top Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                if (currentSong != null) ...[
                  OptimizedImage(
                    imagePath: currentSong.artPath,
                    width: 44,
                    height: 44,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSong.title,
                          style: AppFonts.jostStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentSong.artist ?? 'Unknown Artist',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Text(
                      'Lyrics',
                      style: AppFonts.jostStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                if (currentSong != null)
                  _buildModeSelector(true),
                if (currentSong != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(LucideIcons.rotateCcw, size: 16, color: Colors.white54),
                    tooltip: 'Reload lyrics',
                    onPressed: () => ref
                        .read(lyricsProvider.notifier)
                        .fetchForSong(currentSong, force: true),
                  ),
                ],
              ],
            ),
          ),

          if (currentSong != null && lyricsState.parsedLines.isNotEmpty)
            _buildSyncOffsetAdjuster(currentSong, lyricsState.syncOffsetMs, primaryColor),

          if (_syncMode != LyricsSyncMode.line) _buildDisclaimer(),

          // Main Lyrics Content
          Expanded(
            child: currentSong == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.music,
                            size: 48,
                            color: Colors.white24,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No track currently playing',
                          style: AppFonts.jostStyle(
                            color: Colors.white70,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Play a song to view synchronized lyrics',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : lyricsState.isLoading
                    ? const Center(child: AppLoadingIndicator())
                    : (lyricsState.rawLrc == null || lyricsState.parsedLines.isEmpty)
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    LucideIcons.languages,
                                    size: 48,
                                    color: primaryColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Lyrics not available',
                                  style: AppFonts.spaceGroteskStyle(
                                    color: Colors.white70,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'No synchronized lyrics found for "${currentSong.title}"',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    fontSize: 12.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () => ref
                                      .read(lyricsProvider.notifier)
                                      .fetchForSong(currentSong, force: true),
                                  icon: const Icon(LucideIcons.refreshCw, size: 15),
                                  label: const Text('Search & Retry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 11,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : AdvancedLyricRenderer(
                            lines: lyricsState.parsedLines,
                            mode: _syncMode,
                            onSeek: (pos) =>
                                ref.read(playbackProvider.notifier).seek(pos),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncOffsetAdjuster(
    Song song,
    int syncOffsetMs,
    Color primaryColor,
  ) {
    final offsetSec = syncOffsetMs / 1000.0;
    final isOffsetZero = syncOffsetMs == 0;
    final offsetText = isOffsetZero
        ? 'Sync Offset: 0.0s'
        : 'Offset: ${offsetSec > 0 ? '+' : ''}${offsetSec.toStringAsFixed(1)}s';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOffsetZero
                ? Colors.white.withValues(alpha: 0.08)
                : primaryColor.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // -0.5s Nudge Button (Advance)
            _NudgeButton(
              label: '-0.5s',
              tooltip: 'Advance lyrics by 0.5s',
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(lyricsProvider.notifier).adjustOffset(song, -500);
              },
            ),
            const SizedBox(width: 4),
            // Offset Display & Reset Pill
            Tooltip(
              message: isOffsetZero ? 'Lyrics are at default sync' : 'Tap to reset sync offset',
              child: GestureDetector(
                onTap: isOffsetZero
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        ref.read(lyricsProvider.notifier).resetOffset(song);
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOffsetZero
                        ? Colors.transparent
                        : primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOffsetZero ? LucideIcons.check : LucideIcons.rotateCcw,
                        size: 11,
                        color: isOffsetZero ? Colors.white54 : primaryColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        offsetText,
                        style: AppFonts.jostStyle(
                          fontSize: 11,
                          fontWeight: isOffsetZero ? FontWeight.normal : FontWeight.w600,
                          color: isOffsetZero ? Colors.white70 : primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // +0.5s Nudge Button (Delay)
            _NudgeButton(
              label: '+0.5s',
              tooltip: 'Delay lyrics by 0.5s',
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(lyricsProvider.notifier).adjustOffset(song, 500);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, size: 12, color: Colors.orange),
          const SizedBox(width: 6),
          Text(
            'Approximated Sync (No Word Timings)',
            style: AppFonts.spaceGroteskStyle(
              fontSize: 10,
              color: Colors.orange,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector([bool isShort = false]) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeButton(
            label: 'LINE',
            isSelected: _syncMode == LyricsSyncMode.line,
            isShort: isShort,
            onTap: () {
              setState(() => _syncMode = LyricsSyncMode.line);
            },
          ),
          _ModeButton(
            label: 'WORD',
            isSelected: _syncMode == LyricsSyncMode.word,
            isShort: isShort,
            onTap: () {
              setState(() => _syncMode = LyricsSyncMode.word);
            },
          ),
          _ModeButton(
            label: 'CHAR',
            isSelected: _syncMode == LyricsSyncMode.char,
            isShort: isShort,
            onTap: () {
              setState(() => _syncMode = LyricsSyncMode.char);
            },
          ),
        ],
      ),
    );
  }
}

class _NudgeButton extends StatelessWidget {
  final String label;
  final String tooltip;
  final VoidCallback onTap;

  const _NudgeButton({
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          hoverColor: Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(
              label,
              style: AppFonts.jostStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isShort;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isShort = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isShort ? 10 : 16,
          vertical: isShort ? 5 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: AppFonts.jostStyle(
            fontSize: isShort ? 9.5 : 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Colors.grey[400],
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
