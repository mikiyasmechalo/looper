import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/playback/presentation/saved_queues_provider.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/core/app_fonts.dart';

class QueueSelectorDropdown extends ConsumerStatefulWidget {
  const QueueSelectorDropdown({super.key});

  @override
  ConsumerState<QueueSelectorDropdown> createState() => _QueueSelectorDropdownState();
}

class _QueueSelectorDropdownState extends ConsumerState<QueueSelectorDropdown> {
  final _overlayController = OverlayPortalController();
  final _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    final activeQueueName = ref.watch(settingsProvider.select((s) => s.activeQueueName));
    final displayName = activeQueueName.isEmpty ? 'All Songs' : activeQueueName;

    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (context) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () => _overlayController.hide(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
              CompositedTransformFollower(
                link: _layerLink,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 4),
                child: Material(
                  elevation: 8,
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.hardEdge,
                  child: Container(
                    width: 260,
                    decoration: BoxDecoration(
                      color: const Color(0xFF222222),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: _QueueDropdownMenuContent(
                      displayName: displayName,
                      onSelect: (queue) {
                        if (queue.name == displayName) {
                          _overlayController.hide();
                          return;
                        }
                        _overlayController.hide();
                        ref.read(playbackProvider.notifier).switchToSavedQueue(queue);
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        child: InkWell(
          onTap: () => _overlayController.toggle(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.listMusic, size: 16, color: Colors.white70),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    displayName,
                    style: AppFonts.jostStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(LucideIcons.chevronDown, size: 14, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QueueDropdownMenuContent extends ConsumerWidget {
  final String displayName;
  final ValueChanged<SavedQueue> onSelect;

  const _QueueDropdownMenuContent({
    required this.displayName,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedQueuesAsync = ref.watch(savedQueuesProvider);

    return savedQueuesAsync.when(
      data: (queues) {
        final userQueues = queues.where((q) => !q.isPermanent).toList();
        SavedQueue? allSongsQueue;
        for (final q in queues) {
          if (q.isPermanent) {
            allSongsQueue = q;
            break;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (allSongsQueue != null) ...[
                InkWell(
                  onTap: () => onSelect(allSongsQueue!),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: _QueueTile(
                      queue: allSongsQueue,
                      isActive: displayName == allSongsQueue.name,
                      ref: ref,
                    ),
                  ),
                ),
                if (userQueues.isNotEmpty)
                  const Divider(color: Colors.white10, height: 1),
              ],
              if (userQueues.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.inbox,
                        size: 15,
                        color: Colors.white38,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'No saved queues',
                        style: AppFonts.jostStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...userQueues.map((q) => InkWell(
                onTap: () => onSelect(q),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: _QueueTile(
                    queue: q,
                    isActive: displayName == q.name,
                    ref: ref,
                  ),
                ),
              )),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(height: 20, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _QueueTile extends StatelessWidget {
  final SavedQueue queue;
  final bool isActive;
  final WidgetRef ref;

  const _QueueTile({
    required this.queue,
    required this.isActive,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final age = _relativeTime(queue.lastPlayed);
    final accentColor = Theme.of(context).colorScheme.primary;

    return Container(
      constraints: const BoxConstraints(minWidth: 200),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  isActive ? LucideIcons.volume2 : LucideIcons.music,
                  size: 16,
                  color: isActive ? accentColor : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        queue.name,
                        style: AppFonts.jostStyle(
                          color: isActive ? accentColor : Colors.white,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${queue.songIds.length} songs · $age',
                        style: AppFonts.jostStyle(color: Colors.grey, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!queue.isPermanent)
            _DeleteQueueButton(
              onDelete: () {
                ref.read(playbackProvider.notifier).deleteQueue(queue.name);
              },
            ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _DeleteQueueButton extends StatefulWidget {
  final VoidCallback onDelete;

  const _DeleteQueueButton({required this.onDelete});

  @override
  State<_DeleteQueueButton> createState() => _DeleteQueueButtonState();
}

class _DeleteQueueButtonState extends State<_DeleteQueueButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onDelete,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.red.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            LucideIcons.trash2,
            size: 15,
            color: _isHovered
                ? Colors.redAccent
                : Colors.red.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }
}
