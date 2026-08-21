import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/ui/widgets/app_loading_indicator.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/playlists/presentation/playlist_view.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/ui/screens/android/widgets/song_details_bottom_sheet.dart';
import 'package:looper_player/ui/screens/android/song/song_info_screen.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/features/playlists/data/playlist_service.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/core/providers.dart';
import 'package:looper_player/ui/screens/android/player/android_equalizer_screen.dart';

// Extracted modular components
import 'package:looper_player/ui/widgets/menu_option_tile.dart';
import 'package:looper_player/ui/widgets/edit_song_sheet.dart';
import 'package:looper_player/ui/widgets/sleep_timer_sheet_content.dart';
import 'package:looper_player/ui/widgets/playlist_selector.dart';
import 'package:looper_player/features/playback/presentation/widgets/ab_looper_widget.dart';

void showSongOptionsBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Song song,
  Playlist? playlist,
  int? queueIndex,
  bool isFromQueue = false,
  bool showDeleteOption = true,
  bool showRenameOption = true,
}) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    builder: (modalContext) => _SongOptionsSheetContent(
      song: song,
      playlist: playlist,
      queueIndex: queueIndex,
      isFromQueue: isFromQueue || queueIndex != null,
      showDeleteOption: showDeleteOption,
      showRenameOption: showRenameOption,
      parentContext: context,
    ),
  );
}

class _SongOptionsSheetContent extends ConsumerWidget {
  final Song song;
  final Playlist? playlist;
  final int? queueIndex;
  final bool isFromQueue;
  final bool showDeleteOption;
  final bool showRenameOption;
  final BuildContext parentContext;

  const _SongOptionsSheetContent({
    required this.song,
    this.playlist,
    this.queueIndex,
    this.isFromQueue = false,
    required this.showDeleteOption,
    required this.showRenameOption,
    required this.parentContext,
  });

  /// Shows the advanced Edit Song sheet (bottom sheet).
  void _showEditSongSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (ctx) => EditSongSheet(song: song),
    );
  }

  /// Shows a confirmation dialog for deleting a song.
  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(playbackProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 22),
                const SizedBox(width: 10),
                Text(l10n.deleteSong, style: AppFonts.jostStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              l10n.deleteSongConfirm,
              style: AppFonts.jostStyle(color: Colors.white60, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel, style: AppFonts.jostStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: isDeleting
                    ? null
                    : () async {
                        setDialogState(() => isDeleting = true);
                        final result = await notifier.deleteSong(song);
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                        String message;
                        Color bgColor;
                        if (result == FileActionResult.success) {
                          message = l10n.songDeletedSuccess;
                          bgColor = Colors.green.shade800;
                        } else if (result == FileActionResult.dbOnly) {
                          message = l10n.songDeletedDbOnly;
                          bgColor = Colors.orange.shade800;
                        } else {
                          message = l10n.songDeleteFailed;
                          bgColor = Colors.red.shade800;
                        }
                        scaffoldMessengerKey.currentState?.clearSnackBars();
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          SnackBar(
                            content: Text(message,
                                style: AppFonts.jostStyle(color: Colors.white)),
                            backgroundColor: bgColor,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isDeleting
                    ? const AppLoadingIndicator(size: 36)
                    : Text(l10n.delete),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPlaylistSelector(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
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
                      songPaths: [song.path],
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
                  if (!p.songPaths.contains(song.path)) {
                    p.songPaths = [...p.songPaths, song.path];
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
    final settings = ref.watch(settingsProvider);
    final playbackState = ref.watch(playbackProvider);
    final useBlur = settings.enableDynamicTheming && !settings.disableBlur;
    final isPureBlack = settings.darkTheme;
    final accentColor = Color(settings.accentColor);

    final sheetBg = isPureBlack
        ? Colors.black
        : (useBlur ? const Color(0xFF141416).withValues(alpha: 0.90) : const Color(0xFF1E1E1E));

    final queue = playbackState.queue;
    final currentSongPath = playbackState.currentSong?.path;
    final currentIdx = queue.indexWhere((s) => s.path == currentSongPath);
    final targetIdx = queueIndex ?? (isFromQueue ? queue.indexWhere((s) => s.path == song.path) : -1);
    final isUpcomingInQueue = isFromQueue && currentIdx != -1 && targetIdx != -1 && targetIdx >= currentIdx;
    final songsUntilStop = isUpcomingInQueue ? (targetIdx - currentIdx + 1) : null;
    final isStoppingAfterThis = playbackState.isSleepTimerActive &&
        playbackState.sleepTimerSongsRemaining != null &&
        playbackState.sleepTimerSongsRemaining == songsUntilStop;

    Widget sheetContent = Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                OptimizedImage(
                  imagePath: song.artPath,
                  width: 52,
                  height: 52,
                  borderRadius: BorderRadius.circular(12),
                  placeholder: Container(
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.music, color: Colors.white54),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: AppFonts.jostStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _ClickableSongSubtitle(
                        song: song,
                        l10n: l10n,
                        parentContext: parentContext,
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
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Builder(
                  builder: (context) {
                    final options = <Widget>[
                      MenuOptionTile(
                        label: l10n.playNext,
                        icon: LucideIcons.playCircle,
                        iconColor: accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(playbackProvider.notifier).addNext(song);
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
                          ref.read(playbackProvider.notifier).addToQueue(song);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.addedToQueue),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      if (isFromQueue && targetIdx != -1)
                        MenuOptionTile(
                          label: 'Remove from Queue',
                          icon: LucideIcons.listMinus,
                          iconColor: Colors.redAccent,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            ref.read(playbackProvider.notifier).removeFromQueue(targetIdx);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Removed from queue'),
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
                          _showPlaylistSelector(parentContext, ref, l10n);
                        },
                      ),
                      MenuOptionTile(
                        label: playbackState.isSleepTimerActive
                            ? 'Sleep Timer (${formatSleepTimerRemaining(playbackState)})'
                            : 'Sleep Timer',
                        icon: LucideIcons.timer,
                        iconColor: playbackState.isSleepTimerActive ? Colors.white70 : accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          showSleepTimerBottomSheet(parentContext, ref);
                        },
                      ),
                      if (isUpcomingInQueue && songsUntilStop != null)
                        MenuOptionTile(
                          label: isStoppingAfterThis
                              ? 'Cancel Stop After This Song'
                              : (songsUntilStop == 1
                                  ? 'Stop After This Song'
                                  : 'Stop After This Song ($songsUntilStop songs)'),
                          icon: isStoppingAfterThis ? LucideIcons.timerOff : LucideIcons.timer,
                          iconColor: isStoppingAfterThis ? Colors.redAccent : accentColor,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                            if (isStoppingAfterThis) {
                              ref.read(playbackProvider.notifier).stopSleepTimer();
                            } else {
                              ref
                                  .read(playbackProvider.notifier)
                                  .startSleepTimer(songCount: songsUntilStop);
                            }
                          },
                        ),
                      MenuOptionTile(
                        label: playbackState.isABLooping
                            ? 'A-B Looper (Active)'
                            : 'A-B Section Looper',
                        icon: LucideIcons.repeat1,
                        iconColor: playbackState.isABLooping ? accentColor : Colors.white70,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          showABLooper(parentContext);
                        },
                      ),
                      MenuOptionTile(
                        label: song.isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
                        icon: song.isFavorite ? Icons.favorite : Icons.favorite_border,
                        iconColor: song.isFavorite ? Colors.redAccent : accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(libraryProvider.notifier).toggleFavorite(song);
                          Navigator.pop(context);
                        },
                      ),
                      if (playlist != null)
                        MenuOptionTile(
                          label: l10n.removeFromPlaylist,
                          icon: LucideIcons.trash2,
                          iconColor: Colors.redAccent,
                          onTap: () async {
                            HapticFeedback.mediumImpact();
                            final messenger = ScaffoldMessenger.of(context);
                            await PlaylistService.removeSongFromPlaylist(playlist!, song);
                            if (context.mounted) {
                              Navigator.pop(context);
                              messenger.showSnackBar(
                                SnackBar(content: Text(l10n.removedFromPlaylist)),
                              );
                            }
                          },
                        ),
                      if (showRenameOption)
                        MenuOptionTile(
                          label: 'Edit Song Info',
                          icon: LucideIcons.edit3,
                          iconColor: accentColor,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                            _showEditSongSheet(parentContext, ref);
                          },
                        ),
                      MenuOptionTile(
                        label: 'Equalizer',
                        icon: LucideIcons.sliders,
                        iconColor: accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          Navigator.push(
                            parentContext,
                            MaterialPageRoute(
                              builder: (context) => const AndroidEqualizerScreen(),
                            ),
                          );
                        },
                      ),
                      MenuOptionTile(
                        label: l10n.songDetails,
                        icon: LucideIcons.info,
                        iconColor: accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            useRootNavigator: true,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => SongDetailsBottomSheet(song: song),
                          );
                        },
                      ),
                      MenuOptionTile(
                        label: l10n.technicalInfoFrequency,
                        icon: LucideIcons.activity,
                        iconColor: accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SongInfoScreen(song: song),
                            ),
                          );
                        },
                      ),
                      MenuOptionTile(
                        label: l10n.share,
                        icon: LucideIcons.share2,
                        iconColor: accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(playbackProvider.notifier).shareSong(song);
                          Navigator.pop(context);
                        },
                      ),
                      if (showDeleteOption)
                        MenuOptionTile(
                          label: l10n.deleteFile,
                          icon: LucideIcons.trash2,
                          iconColor: Colors.redAccent,
                          onTap: () {
                            HapticFeedback.heavyImpact();
                            Navigator.pop(context);
                            _showDeleteDialog(parentContext, ref);
                          },
                        ),
                    ];

                    return PremiumSection(
                      borderRadius: BorderRadius.circular(20),
                      padding: EdgeInsets.zero,
                      useExpanded: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(options.length * 2 - 1, (index) {
                          if (index.isOdd) {
                            return Divider(
                              height: 1,
                              thickness: 0.8,
                              color: Colors.white.withValues(alpha: 0.04),
                              indent: 20,
                              endIndent: 20,
                            );
                          }
                          return options[index ~/ 2];
                        }),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );

    if (useBlur && !isPureBlack) {
      return RepaintBoundary(
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: sheetContent,
          ),
        ),
      );
    }

    return sheetContent;
  }
}

class _ClickableSongSubtitle extends ConsumerStatefulWidget {
  final Song song;
  final AppLocalizations l10n;
  final BuildContext parentContext;

  const _ClickableSongSubtitle({
    required this.song,
    required this.l10n,
    required this.parentContext,
  });

  @override
  ConsumerState<_ClickableSongSubtitle> createState() =>
      _ClickableSongSubtitleState();
}

class _ClickableSongSubtitleState
    extends ConsumerState<_ClickableSongSubtitle> {
  bool _hoverArtist = false;
  bool _hoverAlbum = false;

  @override
  Widget build(BuildContext context) {
    final artist = widget.song.artist ?? widget.l10n.unknownArtist;
    final album = widget.song.album;
    final hasAlbum = album != null && album.isNotEmpty;
    final accentColor = Color(ref.watch(settingsProvider).accentColor);

    final defaultStyle = AppFonts.jostStyle(
      color: Colors.white54,
      fontSize: 13,
    );

    return Text.rich(
      TextSpan(
        style: defaultStyle,
        children: [
          TextSpan(
            text: artist,
            style: defaultStyle.copyWith(
              color: _hoverArtist ? accentColor : Colors.white54,
              decoration:
                  _hoverArtist ? TextDecoration.underline : TextDecoration.none,
              decorationColor: accentColor,
            ),
            mouseCursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hoverArtist = true),
            onExit: (_) => setState(() => _hoverArtist = false),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pop(context);
                _navigateToArtist(
                    widget.parentContext, ref, widget.song, widget.l10n);
              },
          ),
          if (hasAlbum) ...[
            TextSpan(
              text: ' · ',
              style: defaultStyle,
            ),
            TextSpan(
              text: album,
              style: defaultStyle.copyWith(
                color: _hoverAlbum ? accentColor : Colors.white54,
                decoration:
                    _hoverAlbum ? TextDecoration.underline : TextDecoration.none,
                decorationColor: accentColor,
              ),
              mouseCursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hoverAlbum = true),
              onExit: (_) => setState(() => _hoverAlbum = false),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pop(context);
                  _navigateToAlbum(
                      widget.parentContext, ref, widget.song);
                },
            ),
          ],
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

Future<void> _navigateToArtist(
  BuildContext context,
  WidgetRef ref,
  Song song,
  AppLocalizations l10n,
) async {
  if (song.artist == null || song.artist!.isEmpty) return;

  final artistSongs = await DbService.isar.songs
      .filter()
      .artistEqualTo(song.artist!)
      .or()
      .albumArtistEqualTo(song.artist!)
      .findAll();

  final artist = await DbService.isar.artists
      .filter()
      .nameEqualTo(song.artist!)
      .findFirst();

  ref.read(appNavigationProvider.notifier).showCollection(
        title: song.artist!,
        subtitle: l10n.artists,
        art: artist?.artPath ?? song.artPath,
        imageUrl: artist?.artistImageUrl,
        images: artist?.artistImages ?? const [],
        songs: artistSongs,
        highlightItem: NavItem.artists,
      );
}

Future<void> _navigateToAlbum(
  BuildContext context,
  WidgetRef ref,
  Song song,
) async {
  final albumName = song.album;
  if (albumName == null || albumName.isEmpty) return;

  final albumSongs = await DbService.isar.songs
      .filter()
      .albumEqualTo(albumName)
      .findAll();

  final album = await DbService.isar.albums
      .filter()
      .nameEqualTo(albumName)
      .findFirst();

  ref.read(appNavigationProvider.notifier).showCollection(
        title: albumName,
        subtitle: song.artist,
        art: album?.artPath ?? song.artPath,
        songs: albumSongs,
        highlightItem: NavItem.albums,
      );
}
