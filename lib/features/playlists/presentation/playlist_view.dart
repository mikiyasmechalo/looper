import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/widgets/app_input_dialog.dart';
import 'package:looper_player/ui/widgets/playlist_artwork.dart';
import 'package:looper_player/ui/widgets/playlist_options_bottom_sheet.dart';

class PlaylistNotifier extends StateNotifier<List<Playlist>> {
  PlaylistNotifier() : super([]) {
    _loadPlaylists();
  }

  void _loadPlaylists() {
    DbService.isar.playlists
        .where()
        .sortByDateModifiedDesc()
        .watch(fireImmediately: true)
        .listen((playlists) {
          state = playlists;
        });
  }

  Future<void> createPlaylist(String name) async {
    final playlist = Playlist()
      ..name = name
      ..songPaths = []
      ..dateCreated = DateTime.now()
      ..dateModified = DateTime.now();

    await DbService.isar.writeTxn(() => DbService.isar.playlists.put(playlist));
  }

  Future<void> deletePlaylist(int id) async {
    await DbService.isar.writeTxn(() => DbService.isar.playlists.delete(id));
  }
}

final playlistProvider =
    StateNotifierProvider<PlaylistNotifier, List<Playlist>>((ref) {
      return PlaylistNotifier();
    });

final playlistSongsProvider = StreamProvider.family<List<Song>, int>((ref, playlistId) {
  return DbService.isar.playlists
      .watchObject(playlistId, fireImmediately: true)
      .asyncMap((playlist) async {
        if (playlist == null || playlist.songPaths.isEmpty) return <Song>[];
        
        final songs = await DbService.isar.songs
            .filter()
            .anyOf(playlist.songPaths, (q, path) => q.pathEqualTo(path))
            .findAll();
            
        final songMap = {for (var s in songs) s.path: s};
        return playlist.songPaths
            .map((path) => songMap[path])
            .whereType<Song>()
            .toList();
      });
});

class PlaylistView extends ConsumerWidget {
  const PlaylistView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Text(
                    '${playlists.length} ${l10n.playlists}',
                    style: AppFonts.jostStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showCreateDialog(context, ref),
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: Text(
                      l10n.newPlaylist,
                      style: AppFonts.jostStyle(fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: playlists.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.listMusic,
                            size: 64,
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No playlists yet',
                            style: AppFonts.jostStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 180),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                      itemCount: playlists.length,
                      itemBuilder: (context, index) =>
                          _PlaylistCard(playlist: playlists[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AppInputDialog(
        title: l10n.newPlaylist,
        hint: 'Playlist name',
        confirmLabel: l10n.create,
        onConfirm: (name) =>
            ref.read(playlistProvider.notifier).createPlaylist(name),
      ),
    );
  }
}

class _PlaylistCard extends ConsumerWidget {
  final Playlist playlist;
  const _PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs =
        ref.watch(playlistSongsProvider(playlist.id)).value ?? const <Song>[];
    final isDynamic = ref.watch(settingsProvider).enableDynamicTheming;
    final nav = ref.watch(appNavigationProvider);
    final isSelected =
        nav.activeItem == NavItem.collectionDetail &&
        nav.collectionTitle == playlist.name;

    return GestureDetector(
      onSecondaryTap: () => showPlaylistOptionsBottomSheet(
        context: context,
        ref: ref,
        playlist: playlist,
        songs: songs,
      ),
      child: InkWell(
        onTap: () async {
          final loaded = await DbService.isar.songs
              .filter()
              .anyOf(playlist.songPaths, (q, path) => q.pathEqualTo(path))
              .findAll();

        final songMap = {for (var s in loaded) s.path: s};
        final orderedSongs = playlist.songPaths
            .map((path) => songMap[path])
            .whereType<Song>()
            .toList();

        ref
            .read(appNavigationProvider.notifier)
            .showCollection(
              title: playlist.name,
              subtitle: 'Playlist',
              songs: orderedSongs,
              playlist: playlist,
              highlightItem: NavItem.playlists,
            );
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? const Color.fromARGB(
                  255,
                  53,
                  53,
                  53,
                ).withValues(alpha: isDynamic ? 0.3 : 0.1)
              : Colors.transparent,
          border: isSelected
              ? Border.all(
                  color: Colors.white10.withValues(alpha: 0.1),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: PlaylistArtwork(
                    songs: songs,
                    fallbackBackground: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(
                      alpha: isDynamic ? 0.8 : 0.3,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: AppFonts.jostStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${playlist.songPaths.length} songs',
                    style: AppFonts.jostStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
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
      ),
    );
  }
}

