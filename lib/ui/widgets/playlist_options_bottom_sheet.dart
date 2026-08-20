import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/playlists/presentation/playlist_view.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/widgets/app_input_dialog.dart';
import 'package:looper_player/ui/widgets/menu_option_tile.dart';
import 'package:looper_player/core/import_export_service.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shows the context menu for a playlist: playback actions, rename and delete.
Future<void> showPlaylistOptionsBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Playlist playlist,
  required List<Song> songs,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final accentColor = Theme.of(context).colorScheme.primary;

  await showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.listMusic,
                      color: Colors.orangeAccent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.name,
                          style: AppFonts.jostStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${songs.length} ${l10n.songs}',
                          style: AppFonts.jostStyle(
                            fontSize: 13,
                            color: Colors.white54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    children: [
                      MenuOptionTile(
                        label: l10n.playAll,
                        icon: LucideIcons.play,
                        iconColor: accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(playbackProvider.notifier).setPlaylist(songs, queueName: playlist.name);
                          Navigator.pop(context);
                        },
                      ),
                      MenuOptionTile(
                        label: l10n.shuffleTitle,
                        icon: LucideIcons.shuffle,
                        iconColor: accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(playbackProvider.notifier)
                              .playShuffled(songs, queueName: playlist.name);
                          Navigator.pop(context);
                        },
                      ),
                      MenuOptionTile(
                        label: l10n.playNext,
                        icon: LucideIcons.playCircle,
                        iconColor: accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(playbackProvider.notifier)
                              .addNextMany(songs);
                          Navigator.pop(context);
                        },
                      ),
                      MenuOptionTile(
                        label: l10n.addToQueue,
                        icon: LucideIcons.listPlus,
                        iconColor: accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(playbackProvider.notifier)
                              .addToQueueMany(songs);
                          Navigator.pop(context);
                        },
                      ),
                      MenuOptionTile(
                        label: 'Export Playlist',
                        icon: LucideIcons.download,
                        iconColor: accentColor,
                        onTap: () {
                          Navigator.pop(context);
                          ImportExportService.exportSinglePlaylist(context, playlist, songs);
                        },
                      ),
                      MenuOptionTile(
                        label: l10n.renamePlaylist,
                        icon: LucideIcons.edit2,
                        iconColor: Colors.greenAccent,
                        onTap: () {
                          Navigator.pop(context);
                          _showRenameDialog(context, ref, playlist);
                        },
                      ),
                      MenuOptionTile(
                        label: l10n.deletePlaylist,
                        icon: LucideIcons.trash2,
                        iconColor: Colors.redAccent,
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteDialog(context, ref, playlist);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

Future<void> _showRenameDialog(
  BuildContext context,
  WidgetRef ref,
  Playlist playlist,
) async {
  await showDialog(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return AppInputDialog(
        title: l10n.renamePlaylist,
        hint: l10n.newPlaylist,
        initialText: playlist.name,
        confirmLabel: l10n.rename,
        onConfirm: (name) async {
          if (name.isNotEmpty && name != playlist.name) {
            await DbService.isar.writeTxn(() async {
              playlist.name = name;
              playlist.dateModified = DateTime.now();
              await DbService.isar.playlists.put(playlist);
            });
          }
        },
      );
    },
  );
}

Future<void> _showDeleteDialog(
  BuildContext context,
  WidgetRef ref,
  Playlist playlist,
) async {
  final l10n = AppLocalizations.of(context)!;
  await showDialog(
    context: context,
    builder: (context) {
      final accent = Theme.of(context).colorScheme.primary;
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deletePlaylist,
                style: AppFonts.jostStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.deletePlaylistConfirm(playlist.name),
                style: AppFonts.jostStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l10n.cancel,
                      style: AppFonts.jostStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () async {
                      await DbService.isar.writeTxn(
                        () => DbService.isar.playlists.delete(playlist.id),
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      // If the deleted playlist is open, go back to the list.
                      final nav = ref.read(appNavigationProvider);
                      if (nav.activeItem == NavItem.collectionDetail &&
                          nav.collectionTitle == playlist.name) {
                        ref.read(appNavigationProvider.notifier).goBack();
                      }
                    },
                    child: Text(
                      l10n.delete,
                      style: AppFonts.jostStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
