import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
