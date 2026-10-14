import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/widgets/app_input_dialog.dart';
import 'package:looper_player/core/import_export_service.dart';
import 'package:looper_player/ui/widgets/playlist_artwork.dart';
import 'package:looper_player/ui/widgets/playlist_options_bottom_sheet.dart';
import 'package:looper_player/ui/widgets/collection_options_bottom_sheet.dart';
import 'package:looper_player/features/playlists/domain/smart_playlist.dart';
import 'package:looper_player/features/playlists/presentation/smart_playlists_provider.dart';

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
    final smartPlaylists = ref.watch(smartPlaylistsProvider).value ?? const <SmartPlaylist>[];
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    final bool hasAnyContent = smartPlaylists.isNotEmpty || playlists.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Top action bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Text(
                    '${playlists.length + smartPlaylists.length} ${l10n.playlists}',
                    style: AppFonts.jostStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => ImportExportService.importPlaylistFiles(context, ref),
                    icon: const Icon(LucideIcons.upload, size: 16),
                    label: Text(
                      'Import',
                      style: AppFonts.jostStyle(fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 8),
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

            // Main Content Area
            Expanded(
              child: !hasAnyContent
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
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Smart Playlists Section
                        if (smartPlaylists.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.sparkles,
                                    size: 16,
                                    color: accent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Smart Playlists',
                                    style: AppFonts.jostStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: accent.withValues(alpha: 0.35),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '${smartPlaylists.length}',
                                      style: TextStyle(
                                        color: accent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Auto-updating',
                                    style: AppFonts.jostStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 224,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                itemCount: smartPlaylists.length,
                                separatorBuilder: (_, _) => const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    width: 165,
                                    child: _SmartPlaylistCard(
                                      smartPlaylist: smartPlaylists[index],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 24),
                          ),
                        ],

                        // User Playlists Section Header
                        if (smartPlaylists.isNotEmpty && playlists.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                              child: Row(
                                children: [
                                  const Icon(
                                    LucideIcons.listMusic,
                                    size: 16,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Your Playlists',
                                    style: AppFonts.jostStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${playlists.length}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // User Playlists Grid
                        if (playlists.isNotEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 180),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio: 0.74,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _PlaylistCard(playlist: playlists[index]),
                                childCount: playlists.length,
                              ),
                            ),
                          )
                        else if (smartPlaylists.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 180),
                              child: Material(
                                color: Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(16),
                                clipBehavior: Clip.hardEdge,
                                child: InkWell(
                                  onTap: () => _showCreateDialog(context, ref),
                                  borderRadius: BorderRadius.circular(16),
                                  hoverColor: Colors.white.withValues(alpha: 0.06),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.06),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: accent.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            LucideIcons.plus,
                                            size: 20,
                                            color: accent,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Create Custom Playlist',
                                                style: AppFonts.jostStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Click here to create and curate your own playlists',
                                                style: AppFonts.jostStyle(
                                                  color: Colors.white54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          LucideIcons.chevronRight,
                                          size: 18,
                                          color: Colors.white30,
                                        ),
                                      ],
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

class _SmartPlaylistCard extends ConsumerWidget {
  final SmartPlaylist smartPlaylist;
  const _SmartPlaylistCard({required this.smartPlaylist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(appNavigationProvider);
    final isSelected =
        nav.activeItem == NavItem.collectionDetail &&
        nav.collectionTitle == smartPlaylist.title;
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return GestureDetector(
      onSecondaryTap: () => showSmartPlaylistOptionsBottomSheet(
        context: context,
        ref: ref,
        smartPlaylist: smartPlaylist,
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            ref.read(appNavigationProvider.notifier).showCollection(
              title: smartPlaylist.title,
              subtitle: 'Smart Playlist',
              songs: smartPlaylist.songs,
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
                  ? const Color.fromARGB(255, 53, 53, 53)
                  : Colors.white.withValues(alpha: 0.03),
              border: Border.all(
                color: isSelected
                    ? accent.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.07),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Artwork Container with Smart Badge
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: smartPlaylist.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: smartPlaylist.gradientColors.first.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                // Subtle album art collage background
                                if (smartPlaylist.songs.isNotEmpty)
                                  Opacity(
                                    opacity: 0.22,
                                    child: PlaylistArtwork(
                                      songs: smartPlaylist.songs,
                                      fallbackBackground: Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                // Centered glowing icon
                                Center(
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.35),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        smartPlaylist.icon,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Smart top-right badge (icon only)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                              width: 0.8,
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.sparkles,
                            size: 11,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                Text(
                  smartPlaylist.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.jostStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${smartPlaylist.songCount} songs',
                  style: AppFonts.jostStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
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
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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
                  ? const Color.fromARGB(255, 53, 53, 53)
                  : Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: PlaylistArtwork(
                    songs: songs,
                    fallbackBackground: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  playlist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.jostStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${songs.length} songs',
                  style: AppFonts.jostStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
