import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/library_cleanup_notifier.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/ui/widgets/player_bar.dart';

class LibraryCleanupView extends ConsumerStatefulWidget {
  const LibraryCleanupView({super.key});

  @override
  ConsumerState<LibraryCleanupView> createState() => _LibraryCleanupViewState();
}

class _LibraryCleanupViewState extends ConsumerState<LibraryCleanupView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmDeleteSelected(BuildContext context) async {
    final notifier = ref.read(libraryCleanupProvider.notifier);
    final count = ref.read(libraryCleanupProvider).selectedSongIdsToDelete.length;
    if (count == 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1B22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Selected Tracks?', style: TextStyle(color: Colors.white)),
          content: Text(
            'This will delete $count audio files permanently from your computer and library.',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final deleted = await notifier.deleteSelectedTracks(deleteFromDisk: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully deleted $deleted tracks.'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _playFromList(Song song, List<Song> playlist, String queueTitle) {
    if (playlist.isEmpty) return;
    ref.read(playbackProvider.notifier).setPlaylist(
      playlist,
      queueName: queueTitle,
    );
    ref.read(playbackProvider.notifier).play(song);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(libraryCleanupProvider);
    final notifier = ref.read(libraryCleanupProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Library Cleanup Assistant',
          style: AppFonts.jostStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 18, color: Colors.white70),
            tooltip: 'Rescan Library',
            onPressed: () => notifier.scanLibrary(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: 'Duplicates (${state.duplicateGroups.length})'),
            Tab(text: 'Low Bitrate (${state.lowBitrateTracks.length})'),
            Tab(text: 'Missing Art (${state.missingArtworkTracks.length})'),
            Tab(text: 'Short Tracks (${state.shortAudioTracks.length})'),
          ],
        ),
      ),
      body: state.isScanning
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing audio quality and duplicates...', style: TextStyle(color: Colors.white54)),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDuplicatesTab(state, notifier, theme),
                _buildQualityListTab(
                  state.lowBitrateTracks,
                  state,
                  notifier,
                  'Low Bitrate (< 160 kbps)',
                  'No low bitrate tracks found.',
                  'All tracks meet or exceed 160 kbps quality.',
                ),
                _buildQualityListTab(
                  state.missingArtworkTracks,
                  state,
                  notifier,
                  'Missing Album Art',
                  'No missing album artwork.',
                  'All your tracks have album covers.',
                ),
                _buildQualityListTab(
                  state.shortAudioTracks,
                  state,
                  notifier,
                  'Short Tracks (< 30s)',
                  'No short tracks found.',
                  'No audio files under 30 seconds detected.',
                ),
              ],
            ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.selectedSongIdsToDelete.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A22),
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Text(
                      '${state.selectedSongIdsToDelete.length} selected for deletion',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => notifier.clearSelection(),
                      child: const Text('Clear', style: TextStyle(color: Colors.white60)),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () => _confirmDeleteSelected(context),
                      icon: const Icon(LucideIcons.trash2, size: 16),
                      label: const Text('Delete'),
                    ),
                  ],
                ),
              ),
            ),
          const PlayerBar(),
        ],
      ),
    );
  }

  Widget _buildDuplicatesTab(
    LibraryCleanupState state,
    LibraryCleanupNotifier notifier,
    ThemeData theme,
  ) {
    if (state.duplicateGroups.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.checkCircle2, size: 48, color: Colors.greenAccent),
            SizedBox(height: 12),
            Text('No duplicate tracks detected', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Your music library is clean and organized!', style: TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ),
      );
    }

    final allDuplicateSongs = state.duplicateGroups
        .expand((g) => g.tracks.map((t) => t.song))
        .toList();

    return Column(
      children: [
        // Quick Action Banner
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            children: [
              Text(
                '${state.duplicateGroups.length} duplicate sets found',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: () => notifier.selectLowerQualityDuplicates(),
                icon: const Icon(LucideIcons.checkCheck, size: 14),
                label: const Text('Auto-Select Lower Bitrates', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: state.duplicateGroups.length,
            itemBuilder: (context, index) {
              final group = state.duplicateGroups[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.035),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(LucideIcons.copy, size: 16, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  group.title,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  group.artist,
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${group.tracks.length} copies',
                              style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Colors.white10),

                    // Duplicate Copies List
                    for (int i = 0; i < group.tracks.length; i++) ...[
                      _buildTrackRow(
                        group.tracks[i],
                        state,
                        notifier,
                        allDuplicateSongs,
                        'Cleanup: Duplicate Tracks',
                        isHighestQuality: i == 0,
                      ),
                      if (i < group.tracks.length - 1)
                        const Divider(height: 1, indent: 48, color: Colors.white10),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrackRow(
    TrackQualityInfo info,
    LibraryCleanupState state,
    LibraryCleanupNotifier notifier,
    List<Song> matchingPlaylist,
    String queueTitle, {
    bool isHighestQuality = false,
  }) {
    final isSelected = state.selectedSongIdsToDelete.contains(info.song.id);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Checkbox(
        value: isSelected,
        activeColor: Colors.redAccent,
        onChanged: (_) => notifier.toggleSelectToDelete(info.song.id),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isHighestQuality ? Colors.green.withValues(alpha: 0.2) : Colors.white10,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isHighestQuality ? Colors.greenAccent.withValues(alpha: 0.3) : Colors.transparent),
            ),
            child: Text(
              info.fileExtension,
              style: TextStyle(
                color: isHighestQuality ? Colors.greenAccent : Colors.white70,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            info.formattedBitrate,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Text(
            '• ${info.formattedDuration} • ${info.formattedSize}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12),
          ),
        ],
      ),
      subtitle: Text(
        info.song.path,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(LucideIcons.play, size: 16, color: Colors.white70),
        tooltip: 'Play Track with Matching Queue',
        onPressed: () => _playFromList(info.song, matchingPlaylist, queueTitle),
      ),
      onTap: () => notifier.toggleSelectToDelete(info.song.id),
    );
  }

  Widget _buildQualityListTab(
    List<TrackQualityInfo> items,
    LibraryCleanupState state,
    LibraryCleanupNotifier notifier,
    String categoryName,
    String emptyTitle,
    String emptySubtitle,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.sparkles, size: 48, color: Colors.greenAccent),
            SizedBox(height: 12),
            Text(emptyTitle, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(emptySubtitle, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ),
      );
    }

    final allItemIds = items.map((i) => i.song.id).toSet();
    final allSelected = allItemIds.isNotEmpty && allItemIds.every((id) => state.selectedSongIdsToDelete.contains(id));
    final matchingSongs = items.map((t) => t.song).toList();
    final queueTitle = 'Cleanup: $categoryName';

    return Column(
      children: [
        // Tab Header Actions
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            children: [
              Text(
                '${items.length} tracks found',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: () {
                  if (allSelected) {
                    notifier.deselectAll(allItemIds);
                  } else {
                    notifier.selectAll(allItemIds);
                  }
                },
                icon: Icon(allSelected ? LucideIcons.square : LucideIcons.checkSquare, size: 14),
                label: Text(
                  allSelected ? 'Deselect Tab' : 'Select All Tab',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = state.selectedSongIdsToDelete.contains(item.song.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.white.withValues(alpha: isSelected ? 0.07 : 0.03),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? Colors.redAccent.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: isSelected,
                            activeColor: Colors.redAccent,
                            onChanged: (_) => notifier.toggleSelectToDelete(item.song.id),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white10,
                              image: item.hasArtwork
                                  ? DecorationImage(
                                      image: FileImage(File(item.song.artPath!)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: !item.hasArtwork
                                ? const Icon(LucideIcons.music, color: Colors.white38, size: 18)
                                : null,
                          ),
                        ],
                      ),
                      title: Text(
                        item.song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${item.song.artist ?? 'Unknown'} • ${item.formattedDuration} • ${item.formattedBitrate} • ${item.formattedSize}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(LucideIcons.play, size: 16, color: Colors.white70),
                        tooltip: 'Play with Tab Queue',
                        onPressed: () => _playFromList(item.song, matchingSongs, queueTitle),
                      ),
                      onTap: () => notifier.toggleSelectToDelete(item.song.id),
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
