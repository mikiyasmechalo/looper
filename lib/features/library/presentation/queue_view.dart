import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/playback/presentation/queue_scroll_provider.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/ui/widgets/song_options_bottom_sheet.dart';
import 'package:looper_player/ui/widgets/queue_selector_dropdown.dart';

class QueueView extends ConsumerStatefulWidget {
  const QueueView({super.key});

  @override
  ConsumerState<QueueView> createState() => _QueueViewState();
}

class _QueueViewState extends ConsumerState<QueueView> {
  static const double kItemHeight = 72.0;
  static const double kTopPadding = 16.0;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final scrollState = ref.read(queueScrollProvider);
    final playback = ref.read(playbackProvider);
    final queue = playback.queue;
    final currentSongPath = playback.currentSong?.path;
    final showPlayed = ref.read(settingsProvider).showPlayedSongsInQueue;
    final currentIdx = queue.indexWhere((s) => s.path == currentSongPath);

    double initialOffset = scrollState.pageScrollOffset;

    if (currentSongPath != null && currentIdx != -1) {
      final targetIdx = showPlayed ? currentIdx : 0;
      initialOffset = (kTopPadding + targetIdx * kItemHeight - 250).clamp(0.0, double.infinity);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scrollToCurrent(targetIdx, currentSongPath, force: true);
      });
    }

    _scrollController = ScrollController(
      initialScrollOffset: initialOffset,
    );
  }

  @override
  void dispose() {
    if (_scrollController.hasClients) {
      ref
          .read(queueScrollProvider.notifier)
          .updatePageOffset(_scrollController.offset);
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrent(int currentIdx, String songPath, {bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final maxExtent = _scrollController.position.maxScrollExtent;
      final viewport = _scrollController.position.viewportDimension;
      final target = (kTopPadding +
              currentIdx * kItemHeight -
              viewport / 2 +
              kItemHeight / 2)
          .clamp(0.0, maxExtent);

      ref
          .read(queueScrollProvider.notifier)
          .markPageScrolledTo(songPath, target);

      final currentOffset = _scrollController.offset;
      if (!force && (target - currentOffset).abs() > 15 * kItemHeight) {
        _scrollController.jumpTo(target);
      } else {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final playbackState = ref.watch(playbackProvider);
    final queue = playbackState.queue;
    final currentSongPath = playbackState.currentSong?.path;
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
    int displayedToOriginal(int displayedIdx) {
      if (currentIdx == -1 || showPlayed) return displayedIdx;
      return displayedIdx + currentIdx;
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
                  style: AppFonts.jostStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 16),
                const QueueSelectorDropdown(),
              ],
              const Spacer(),
              if (currentIdx != -1 && currentSongPath != null)
                IconButton(
                  icon: const Icon(LucideIcons.locateFixed,
                      size: 18, color: Colors.white70),
                  tooltip: 'Jump to current song',
                  onPressed: () {
                    final curDisp = showPlayed ? currentIdx : 0;
                    _scrollToCurrent(curDisp, currentSongPath, force: true);
                  },
                ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(LucideIcons.refreshCw,
                    size: 18, color: Colors.white70),
                tooltip: 'Refresh & Clean Queue',
                onPressed: () =>
                    ref.read(playbackProvider.notifier).validateAndCleanQueue(),
              ),
              const SizedBox(width: 8),
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
                    style:
                        AppFonts.jostStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification) {
                      ref
                          .read(queueScrollProvider.notifier)
                          .updatePageOffset(notification.metrics.pixels);
                    }
                    return false;
                  },
                  child: ScrollbarTheme(
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
                      itemExtent: kItemHeight,
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: kTopPadding,
                        bottom: Platform.isAndroid ? 200 : 16,
                      ),
                      itemCount: displayedQueue.length,
                      onReorder: (oldI, newI) {
                        // Index of current song in the displayed list
                        final curDisp = showPlayed ? currentIdx : 0;
                        // Block dragging the current song
                        if (currentIdx != -1 && oldI == curDisp) return;
                        // Flutter's standard adjustment for downward moves
                        if (newI > oldI) newI -= 1;
                        // When played songs are hidden, don't allow dropping above current
                        if (!showPlayed && currentIdx != -1 && newI <= curDisp) {
                          newI = curDisp + 1;
                        }
                        if (oldI == newI) return;
                        final oldOrig = displayedToOriginal(oldI);
                        final newOrig = displayedToOriginal(newI);
                        ref
                            .read(playbackProvider.notifier)
                            .reorderQueueDirect(oldOrig, newOrig);
                      },
                      itemBuilder: (context, index) {
                        final song = displayedQueue[index];
                        final isCurrent = currentSongPath == song.path;
                        final originalIndex = displayedToOriginal(index);
                        final isPlayed =
                            currentIdx != -1 && originalIndex < currentIdx;
                        final isDraggable = !isCurrent;
                        final isStopTarget = playbackState.isSleepTimerActive &&
                            playbackState.sleepTimerSongsRemaining != null &&
                            currentIdx != -1 &&
                            originalIndex ==
                                currentIdx +
                                    playbackState.sleepTimerSongsRemaining! -
                                    1;

                        return SizedBox(
                          key: ValueKey('queue_view_${song.path}_$index'),
                          height: kItemHeight,
                          child: GestureDetector(
                            onSecondaryTap: () => showSongOptionsBottomSheet(
                              context: context,
                              ref: ref,
                              song: song,
                              queueIndex: originalIndex,
                              isFromQueue: true,
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
                                child: const Icon(LucideIcons.x,
                                    color: Colors.red),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Opacity(
                                  opacity: isPlayed ? 0.40 : 1.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.35)
                                          : Colors.white
                                              .withValues(alpha: 0.025),
                                      borderRadius: BorderRadius.circular(12),
                                      border: isCurrent
                                          ? Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.45),
                                              width: 1,
                                            )
                                          : null,
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        onTap: () => ref
                                            .read(playbackProvider.notifier)
                                            .playAtIndex(originalIndex),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: OptimizedImage(
                                                  imagePath: song.artPath,
                                                  width: 44,
                                                  height: 44,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  fit: BoxFit.cover,
                                                  filterQuality:
                                                      FilterQuality.low,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      song.title,
                                                      style:
                                                          AppFonts.jostStyle(
                                                        fontWeight: isCurrent
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                        color: isCurrent
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                            : Colors.white,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Row(
                                                      children: [
                                                        if (song
                                                            .isOnlineStream) ...[
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 5,
                                                              vertical: 1,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary
                                                                  .withValues(
                                                                      alpha:
                                                                          0.2),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
                                                            child: Text(
                                                              'ONLINE',
                                                              style: AppFonts
                                                                  .jostStyle(
                                                                fontSize: 9,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                        ],
                                                        Expanded(
                                                          child: Text(
                                                            song.album !=
                                                                        null &&
                                                                    song.album!
                                                                        .isNotEmpty
                                                                ? '${song.artist ?? 'Unknown Artist'} · ${song.album}'
                                                                : (song.artist ??
                                                                    'Unknown Artist'),
                                                            style: AppFonts
                                                                .jostStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .white60,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              if (isStopTarget)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 8),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withValues(
                                                            alpha: 0.18),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                          .withValues(
                                                              alpha: 0.35),
                                                      width: 0.8,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        LucideIcons.timer,
                                                        size: 10,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        'STOP',
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              IconButton(
                                                icon: const Icon(
                                                  LucideIcons.moreVertical,
                                                  size: 18,
                                                  color: Colors.white54,
                                                ),
                                                tooltip: 'Song Options',
                                                onPressed: () =>
                                                    showSongOptionsBottomSheet(
                                                  context: context,
                                                  ref: ref,
                                                  song: song,
                                                  queueIndex: originalIndex,
                                                  isFromQueue: true,
                                                  showDeleteOption: true,
                                                  showRenameOption: true,
                                                ),
                                              ),
                                              if (isCurrent)
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 12.0),
                                                  child: Icon(
                                                    LucideIcons.volume2,
                                                    color: Colors.yellow,
                                                    size: 20,
                                                  ),
                                                )
                                              else if (isDraggable)
                                                ReorderableDragStartListener(
                                                  index: index,
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 12.0),
                                                    child: Icon(
                                                      LucideIcons.gripVertical,
                                                      size: 24,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                )
                                              else
                                                const SizedBox(width: 36),
                                            ],
                                          ),
                                        ),
                                      ),
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
                ),
        ),
      ],
    );
  }
}
