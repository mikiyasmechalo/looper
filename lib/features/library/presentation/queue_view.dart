import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/ui/widgets/song_options_bottom_sheet.dart';
import 'package:looper_player/ui/widgets/queue_selector_dropdown.dart';

class QueueView extends ConsumerStatefulWidget {
  const QueueView({super.key});

  @override
  ConsumerState<QueueView> createState() => _QueueViewState();
}

class _QueueViewState extends ConsumerState<QueueView> {
  final _scrollController = ScrollController();
  int _lastCurrentIdx = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrent(int currentIdx) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      const double kItemHeight = 72.0;
      const double kTopPadding = 16.0;
      final maxExtent = _scrollController.position.maxScrollExtent;
      final viewport = _scrollController.position.viewportDimension;
      final target = (kTopPadding + currentIdx * kItemHeight - viewport / 2 + kItemHeight / 2)
          .clamp(0.0, maxExtent);
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(playbackProvider.select((s) => s.queue));
    final currentSongPath = ref.watch(playbackProvider.select((s) => s.currentSong?.path));
    final l10n = AppLocalizations.of(context)!;

    final showPlayed =
        ref.watch(settingsProvider.select((s) => s.showPlayedSongsInQueue));
    final currentIdx = queue.indexWhere((s) => s.path == currentSongPath);

    // [played... (dimmed), current, upcoming...] — same layout as fullscreen player
    final List<Song> displayedQueue;
    if (currentIdx != -1) {
      displayedQueue = showPlayed
          ? [
              ...queue.sublist(0, currentIdx),
              ...queue.sublist(currentIdx),
            ]
          : queue.sublist(currentIdx);
    } else {
      displayedQueue = List.from(queue);
    }

    // displayedIdx → originalQueueIdx
    // When showPlayed=true: displayed IS the full queue in order → displayedIdx == originalIdx
    // When showPlayed=false: displayed starts at currentIdx → originalIdx = displayedIdx + currentIdx
    int displayedToOriginal(int displayedIdx) {
      if (currentIdx == -1 || showPlayed) return displayedIdx;
      return displayedIdx + currentIdx;
    }

    if (showPlayed && currentIdx != -1 && currentIdx != _lastCurrentIdx) {
      _lastCurrentIdx = currentIdx;
      _scrollToCurrent(currentIdx);
    } else if (!showPlayed && _lastCurrentIdx != 0) {
      _lastCurrentIdx = 0;
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: Platform.isAndroid ? 12 : 24,
          ),
          child: Row(
            children: [
              if (!Platform.isAndroid) ...[
                Text(
                  l10n.playQueue,
                  style: AppFonts.jostStyle(fontSize: 32, fontWeight: FontWeight.normal),
                ),
                const SizedBox(width: 16),
                const QueueSelectorDropdown(),
              ],
              const Spacer(),
              if (queue.isNotEmpty)
                TextButton.icon(
                  onPressed: () =>
                      ref.read(playbackProvider.notifier).clearQueue(),
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  label: Text(l10n.clearQueue),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
        ),
        Expanded(
          child: displayedQueue.isEmpty
              ? Center(
                  child: Text(
                    l10n.queueIsEmpty,
                    style: AppFonts.jostStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ReorderableListView.builder(
                  scrollController: _scrollController,
                  buildDefaultDragHandles: false,
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 16,
                    bottom: Platform.isAndroid ? 200 : 16,
                  ),
                  itemCount: displayedQueue.length,
                  onReorder: (oldI, newI) {
                    // Index of current song in the displayed list
                    final curDisp = showPlayed ? currentIdx : 0;
                    // Block dragging played songs or the current song
                    if (currentIdx != -1 && oldI <= curDisp) return;
                    // Flutter's standard adjustment for downward moves
                    if (newI > oldI) newI -= 1;
                    // Clamp: cannot drop at or before the current song
                    if (currentIdx != -1 && newI <= curDisp) newI = curDisp + 1;
                    if (oldI == newI) return;
                    final oldOrig = displayedToOriginal(oldI);
                    final newOrig = displayedToOriginal(newI);
                    ref.read(playbackProvider.notifier).reorderQueueDirect(oldOrig, newOrig);
                  },
                  itemBuilder: (context, index) {
                    final song = displayedQueue[index];
                    final isCurrent = currentSongPath == song.path;
                    final originalIndex = displayedToOriginal(index);
                    final isPlayed = currentIdx != -1 &&
                        originalIndex < currentIdx;
                    final isDraggable = !isPlayed && !isCurrent;

                    return GestureDetector(
                      key: ValueKey('queue_view_${song.path}_$index'),
                      onSecondaryTap: () => showSongOptionsBottomSheet(
                        context: context,
                        ref: ref,
                        song: song,
                        showDeleteOption: true,
                        showRenameOption: true,
                      ),
                      child: Dismissible(
                        key: ValueKey('queue_dismiss_${song.path}_$index'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          ref
                              .read(playbackProvider.notifier)
                              .removeFromQueue(originalIndex);
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          color: Colors.red.withValues(alpha: 0.1),
                          child: const Icon(LucideIcons.x, color: Colors.red),
                        ),
                        child: Opacity(
                          opacity: isPlayed ? 0.40 : 1.0,
                          child: AnimatedContainer(
                            key: ValueKey('queue_tile_${song.path}_$index'),
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: ListTile(
                                leading: OptimizedImage(
                                  imagePath: song.artPath,
                                  width: 44,
                                  height: 44,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                title: Text(
                                  song.title,
                                  style: AppFonts.jostStyle(
                                    fontWeight: FontWeight.normal,
                                    color: isCurrent
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Row(
                                  children: [
                                    if (song.isOnlineStream) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'ONLINE',
                                          style: AppFonts.jostStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Expanded(
                                      child: Text(
                                        song.album != null && song.album!.isNotEmpty
                                            ? '${song.artist ?? 'Unknown Artist'} · ${song.album}'
                                            : (song.artist ?? 'Unknown Artist'),
                                        style: AppFonts.jostStyle(fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: isCurrent
                                    ? const Padding(
                                        padding: EdgeInsets.only(right: 20.0),
                                        child: Icon(
                                          LucideIcons.volume2,
                                          color: Colors.yellow,
                                          size: 20,
                                        ),
                                      )
                                    : isDraggable
                                        ? ReorderableDragStartListener(
                                            index: index,
                                            child: const Padding(
                                              padding: EdgeInsets.only(right: 20.0),
                                              child: Icon(
                                                LucideIcons.gripVertical,
                                                size: 24,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                        : const SizedBox(width: 44),
                                onTap: () =>
                                    ref.read(playbackProvider.notifier).playAtIndex(originalIndex),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
