import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/core/providers.dart';
import 'package:looper_player/features/library/data/artist_image_service.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/playlists/presentation/playlist_view.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/widgets/artist_image.dart';
import 'package:looper_player/ui/widgets/menu_option_tile.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/ui/widgets/playlist_selector.dart';
import 'package:looper_player/core/import_export_service.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:looper_player/ui/widgets/edit_album_sheet.dart';

/// Shows the context menu (Play / Shuffle / Play Next / Add to Queue / Add to
/// Playlist / Edit Album / Delete Album) for an album collection.
Future<void> showAlbumOptionsBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Album album,
}) async {
  final songs = await DbService.isar.songs
      .filter()
      .albumEqualTo(album.name)
      .findAll();
  if (!context.mounted) return;
  showCollectionOptionsBottomSheet(
    context: context,
    ref: ref,
    title: album.name,
    subtitle: album.artist,
    artPath: album.artPath,
    songs: songs,
    editActionLabel: 'Edit Album',
    onEditAction: () async {
      Navigator.pop(context);
      showEditAlbumSheet(context, album, songs);
    },
    deleteActionLabel: 'Delete Album',
    onDeleteAction: () async {
      Navigator.pop(context);
      await showConfirmCollectionDeleteDialog(
        context: context,
        collectionType: 'Album',
        name: album.name,
        songCount: songs.length,
        onConfirm: (deleteFromStorage) async {
          final res = await ref.read(playbackProvider.notifier).deleteAlbum(
            album,
            songs,
            deleteFromStorage: deleteFromStorage,
          );
          if (context.mounted) {
            final msg = res == FileActionResult.success
                ? (deleteFromStorage ? 'Album and files deleted from storage' : 'Album removed from library')
                : 'Could not delete some files from storage';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
            );
          }
        },
      );
    },
  );
}

/// Shows the context menu for an artist collection.
Future<void> showArtistOptionsBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Artist artist,
}) async {
  final songs = await DbService.isar.songs
      .filter()
      .artistEqualTo(artist.name)
      .or()
      .albumArtistEqualTo(artist.name)
      .findAll();
  if (!context.mounted) return;
  final isLocalImage =
      artist.artistImageUrl != null &&
      !artist.artistImageUrl!.startsWith('http');
  final isNetworkImage =
      artist.artistImageUrl != null &&
      artist.artistImageUrl!.startsWith('http');
  showCollectionOptionsBottomSheet(
    context: context,
    ref: ref,
    title: artist.name,
    artPath: isLocalImage ? artist.artistImageUrl : artist.artPath,
    imageUrl: isNetworkImage ? artist.artistImageUrl : null,
    images: artist.artistImages,
    songs: songs,
    imageActionLabel: 'Set Artist Image',
    onImageAction: () async {
      Navigator.pop(context);
      await _changeArtistImage(context, artist);
    },
    deleteActionLabel: 'Delete Artist',
    onDeleteAction: () async {
      Navigator.pop(context);
      await showConfirmCollectionDeleteDialog(
        context: context,
        collectionType: 'Artist',
        name: artist.name,
        songCount: songs.length,
        onConfirm: (deleteFromStorage) async {
          final res = await ref.read(playbackProvider.notifier).deleteArtist(
            artist,
            songs,
            deleteFromStorage: deleteFromStorage,
          );
          if (context.mounted) {
            final msg = res == FileActionResult.success
                ? (deleteFromStorage ? 'Artist and files deleted from storage' : 'Artist removed from library')
                : 'Could not delete some files from storage';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
            );
          }
        },
      );
    },
  );
}

/// Lets the user pick local images to assign to an artist whose image the app
/// couldn't fetch automatically. Picked files are copied into the artist
/// images cache and stored on the artist record.
Future<void> _changeArtistImage(
  BuildContext context,
  Artist artist,
) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;
    if (!context.mounted) return;

    final service = ArtistImageService();
    final saved = await service.saveUserImages(
      artist.name,
      result.files.map((f) => f.path).whereType<String>().toList(),
    );
    if (saved.isEmpty) return;

    await DbService.isar.writeTxn(() async {
      artist.artistImages = saved;
      artist.artistImageUrl = saved.first;
      await DbService.isar.artists.put(artist);
    });

    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          'Assigned ${saved.length} image${saved.length == 1 ? '' : 's'} to ${artist.name}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Could not set image: $e'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Generic context menu for a collection of [songs].
///
/// When [shuffleGroups] is provided, the Shuffle action shuffles the group
/// order and plays each group's songs together (e.g. shuffle all albums keeps
/// each album's tracks contiguous). Otherwise it falls back to a flat shuffle.
void showCollectionOptionsBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  String? subtitle,
  String? artPath,
  String? imageUrl,
  List<String>? images,
  required List<Song> songs,
  Playlist? playlist,
  List<List<Song>>? shuffleGroups,
  String? imageActionLabel,
  Future<void> Function()? onImageAction,
  String? editActionLabel,
  Future<void> Function()? onEditAction,
  String? deleteActionLabel,
  Future<void> Function()? onDeleteAction,
}) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    builder: (_) => _CollectionOptionsSheetContent(
      title: title,
      subtitle: subtitle,
      artPath: artPath,
      imageUrl: imageUrl,
      images: images,
      songs: songs,
      playlist: playlist,
      shuffleGroups: shuffleGroups,
      imageActionLabel: imageActionLabel,
      onImageAction: onImageAction,
      editActionLabel: editActionLabel,
      onEditAction: onEditAction,
      deleteActionLabel: deleteActionLabel,
      onDeleteAction: onDeleteAction,
    ),
  );
}

class _CollectionOptionsSheetContent extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final String? artPath;
  final String? imageUrl;
  final List<String>? images;
  final List<Song> songs;
  final Playlist? playlist;
  final List<List<Song>>? shuffleGroups;
  final String? imageActionLabel;
  final Future<void> Function()? onImageAction;
  final String? editActionLabel;
  final Future<void> Function()? onEditAction;
  final String? deleteActionLabel;
  final Future<void> Function()? onDeleteAction;

  const _CollectionOptionsSheetContent({
    required this.title,
    this.subtitle,
    this.artPath,
    this.imageUrl,
    this.images,
    required this.songs,
    this.playlist,
    this.shuffleGroups,
    this.imageActionLabel,
    this.onImageAction,
    this.editActionLabel,
    this.onEditAction,
    this.deleteActionLabel,
    this.onDeleteAction,
  });

  void _showPlaylistSelector(
    BuildContext context,
    WidgetRef ref,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final playlists = ref.watch(playlistProvider);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).colorScheme.surfaceContainer,
        title: Text('${l10n.addToFavorites.split(' ')[0]} ${l10n.playlists}'),
        content: SizedBox(
          width: 360,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlists.isEmpty ? 2 : playlists.length + 1,
            itemBuilder: (dialogContext, index) {
              if (index == 0) {
                return ListTile(
                  leading: const Icon(LucideIcons.plus, color: Colors.white70),
                  title: Text(
                    l10n.createPlaylist,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    showCreatePlaylistWithSongs(
                      context,
                      ref,
                      songPaths: [
                        for (final s in songs) s.path,
                      ],
                    );
                  },
                );
              }
              if (playlists.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    l10n.noPlaylistsCreated,
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                );
              }
              final p = playlists[index - 1];
              return ListTile(
                leading: const Icon(LucideIcons.listMusic),
                title: Text(p.name),
                onTap: () async {
                  final newPaths = <String>[
                    ...p.songPaths,
                    for (final s in songs)
                      if (!p.songPaths.contains(s.path)) s.path,
                  ];
                  if (newPaths.length != p.songPaths.length) {
                    p.songPaths = newPaths;
                    p.dateModified = DateTime.now();
                    await DbService.isar.writeTxn(
                      () => DbService.isar.playlists.put(p),
                    );
                  }
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    scaffoldMessengerKey.currentState?.clearSnackBars();
                    scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(l10n.addedTo(p.name)),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = Theme.of(context).colorScheme.primary;

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
                ArtistImage(
                  images: images,
                  imageUrl: imageUrl,
                  imagePath: artPath,
                  width: 52,
                  height: 52,
                  borderRadius: BorderRadius.circular(12),
                  placeholder: Container(
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.disc,
                      color: Colors.white54,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
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
                        subtitle ?? '${songs.length} ${l10n.songs}',
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
                        ref.read(playbackProvider.notifier).setPlaylist(songs, queueName: title);
                        Navigator.pop(context);
                      },
                    ),
                    MenuOptionTile(
                      label: l10n.shuffleTitle,
                      icon: LucideIcons.shuffle,
                      iconColor: accentColor,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        final notifier =
                            ref.read(playbackProvider.notifier);
                        if (shuffleGroups != null &&
                            shuffleGroups!.isNotEmpty) {
                          notifier.playShuffledGrouped(shuffleGroups!);
                        } else {
                          notifier.playShuffled(songs);
                        }
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.willPlayNext),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.addedToQueue),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    MenuOptionTile(
                      label: l10n.addToPlaylists,
                      icon: LucideIcons.listMusic,
                      iconColor: accentColor,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        _showPlaylistSelector(context, ref);
                      },
                    ),
                    if (playlist != null)
                      MenuOptionTile(
                        label: 'Export Playlist',
                        icon: LucideIcons.download,
                        iconColor: accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          ImportExportService.exportSinglePlaylist(context, playlist!, songs);
                        },
                      ),
                    if (imageActionLabel != null && onImageAction != null)
                      MenuOptionTile(
                        label: imageActionLabel!,
                        icon: LucideIcons.imagePlus,
                        iconColor: accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onImageAction!();
                        },
                      ),
                    if (editActionLabel != null && onEditAction != null)
                      MenuOptionTile(
                        label: editActionLabel!,
                        icon: LucideIcons.pencil,
                        iconColor: accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onEditAction!();
                        },
                      ),
                    if (deleteActionLabel != null && onDeleteAction != null)
                      MenuOptionTile(
                        label: deleteActionLabel!,
                        icon: LucideIcons.trash2,
                        iconColor: Colors.redAccent,
                        textColor: Colors.redAccent,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onDeleteAction!();
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
  }
}

/// Confirmation dialog for mass deletion of Album or Artist collections.
Future<void> showConfirmCollectionDeleteDialog({
  required BuildContext context,
  required String collectionType, // 'Album' or 'Artist'
  required String name,
  required int songCount,
  required Future<void> Function(bool deleteFromStorage) onConfirm,
}) async {
  bool deleteFromStorage = false;
  await showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete $collectionType: $name',
          style: AppFonts.jostStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to remove this $collectionType and its $songCount track${songCount == 1 ? '' : 's'} from your library?',
              style: AppFonts.jostStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => deleteFromStorage = !deleteFromStorage),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: deleteFromStorage,
                      activeColor: Colors.redAccent,
                      onChanged: (val) => setState(() => deleteFromStorage = val ?? false),
                    ),
                    Expanded(
                      child: Text(
                        'Also delete audio files from storage',
                        style: AppFonts.jostStyle(
                          color: deleteFromStorage ? Colors.redAccent : Colors.white70,
                          fontSize: 13,
                          fontWeight: deleteFromStorage ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await onConfirm(deleteFromStorage);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}
