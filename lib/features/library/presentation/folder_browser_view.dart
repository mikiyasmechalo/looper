import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';

class FolderItem {
  final String path;
  final String name;
  final List<Song> songs;
  final List<FolderItem> subFolders;

  FolderItem({
    required this.path,
    required this.name,
    required this.songs,
    this.subFolders = const [],
  });

  int get totalSongCount {
    int count = songs.length;
    for (final sub in subFolders) {
      count += sub.totalSongCount;
    }
    return count;
  }

  int get totalDurationMs {
    int duration = songs.fold(0, (sum, s) => sum + (s.duration ?? 0));
    for (final sub in subFolders) {
      duration += sub.totalDurationMs;
    }
    return duration;
  }

  List<Song> get allSongs {
    final list = List<Song>.from(songs);
    for (final sub in subFolders) {
      list.addAll(sub.allSongs);
    }
    return list;
  }

  String? get previewArtPath {
    for (final song in allSongs) {
      if (song.artPath != null && song.artPath!.isNotEmpty) {
        return song.artPath;
      }
    }
    return null;
  }
}

class FolderBrowserView extends ConsumerStatefulWidget {
  const FolderBrowserView({super.key});

  @override
  ConsumerState<FolderBrowserView> createState() => _FolderBrowserViewState();
}

class _FolderBrowserViewState extends ConsumerState<FolderBrowserView> {
  String _searchQuery = '';
  FolderItem? _currentDrilledFolder;
  final List<FolderItem> _breadcrumbs = [];
  final Set<String> _expandedTreePaths = {};

  String _formatDuration(int ms) {
    if (ms <= 0) return '0 min';
    final duration = Duration(milliseconds: ms);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Groups songs into flat directory buckets (only folders containing songs)
  List<FolderItem> _buildFlatFolders(List<Song> songs) {
    final Map<String, List<Song>> folderMap = {};

    for (final song in songs) {
      final dir = File(song.path).parent.path;
      folderMap.putIfAbsent(dir, () => []).add(song);
    }

    final list = folderMap.entries.map((e) {
      final folderPath = e.key;
      final folderName = folderPath.split(Platform.isWindows ? r'\' : '/').where((p) => p.isNotEmpty).lastOrNull ?? folderPath;
      return FolderItem(
        path: folderPath,
        name: folderName,
        songs: e.value,
      );
    }).toList();

    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  /// Groups songs into a nested tree structure
  List<FolderItem> _buildTree(List<Song> songs) {
    final flatFolders = _buildFlatFolders(songs);
    if (flatFolders.isEmpty) return [];

    final Map<String, FolderItem> nodeMap = {};

    for (final flat in flatFolders) {
      nodeMap[flat.path] = flat;
    }

    final List<FolderItem> rootNodes = [];

    for (final folder in flatFolders) {
      final parentDir = File(folder.path).parent.path;
      if (nodeMap.containsKey(parentDir)) {
        final parent = nodeMap[parentDir]!;
        if (!parent.subFolders.any((s) => s.path == folder.path)) {
          parent.subFolders.add(folder);
        }
      } else {
        rootNodes.add(folder);
      }
    }

    rootNodes.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return rootNodes;
  }

  void _playFolder(FolderItem folder) {
    final all = folder.allSongs;
    if (all.isEmpty) return;
    HapticFeedback.lightImpact();
    ref.read(playbackProvider.notifier).setPlaylist(
      all,
      queueName: 'Folder: ${folder.name}',
    );
    ref.read(playbackProvider.notifier).play(all.first);
  }

  void _addFolderToQueue(FolderItem folder) {
    final all = folder.allSongs;
    if (all.isEmpty) return;
    HapticFeedback.lightImpact();
    for (final song in all) {
      ref.read(playbackProvider.notifier).addToQueue(song);
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryProvider);
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isTreeMode = settings.folderViewTreeMode;

    final flatFolders = _buildFlatFolders(library.songs);
    final filteredFlatFolders = flatFolders.where((f) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return f.name.toLowerCase().contains(q) || f.path.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  if (_currentDrilledFolder != null) ...[
                    IconButton(
                      icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          if (_breadcrumbs.isNotEmpty) {
                            _breadcrumbs.removeLast();
                            _currentDrilledFolder = _breadcrumbs.lastOrNull;
                          } else {
                            _currentDrilledFolder = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentDrilledFolder != null
                              ? _currentDrilledFolder!.name
                              : 'Music Folders',
                          style: AppFonts.jostStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _currentDrilledFolder != null
                              ? '${_currentDrilledFolder!.allSongs.length} tracks • ${_formatDuration(_currentDrilledFolder!.totalDurationMs)}'
                              : '${flatFolders.length} folders • ${library.songs.length} total tracks',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Mode Switcher Toggle (Tree vs Flat)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            LucideIcons.layoutGrid,
                            size: 18,
                            color: !isTreeMode ? theme.colorScheme.primary : Colors.white54,
                          ),
                          tooltip: 'Flat Folders List',
                          onPressed: () {
                            ref.read(settingsProvider.notifier).updateFolderViewTreeMode(false);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            LucideIcons.folderTree,
                            size: 18,
                            color: isTreeMode ? theme.colorScheme.primary : Colors.white54,
                          ),
                          tooltip: 'Directory Tree View',
                          onPressed: () {
                            ref.read(settingsProvider.notifier).updateFolderViewTreeMode(true);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Search folders or directory paths...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 13.5,
                  ),
                  prefixIcon: const Icon(LucideIcons.search, color: Colors.white38, size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, size: 16, color: Colors.white38),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Main Body Content
            Expanded(
              child: _currentDrilledFolder != null
                  ? _buildDrilledFolderView(_currentDrilledFolder!)
                  : isTreeMode
                      ? _buildTreeView(_buildTree(library.songs))
                      : _buildFlatListView(filteredFlatFolders),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlatListView(List<FolderItem> folders) {
    if (folders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.folderX, size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            const Text(
              'No music folders found',
              style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Add music folders in Settings -> Media Library',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folder = folders[index];
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.white.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Icon(
                    LucideIcons.folder,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                title: Text(
                  folder.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      folder.path,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${folder.songs.length} tracks',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(folder.totalDurationMs),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.play, size: 18, color: Colors.white70),
                      tooltip: 'Play Folder',
                      onPressed: () => _playFolder(folder),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.listPlus, size: 18, color: Colors.white54),
                      tooltip: 'Add to Queue',
                      onPressed: () => _addFolderToQueue(folder),
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _breadcrumbs.add(folder);
                    _currentDrilledFolder = folder;
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTreeView(List<FolderItem> rootNodes) {
    if (rootNodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.folderTree, size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            const Text(
              'No directory tree available',
              style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: rootNodes.map((node) => _buildTreeNode(node, depth: 0)).toList(),
    );
  }

  Widget _buildTreeNode(FolderItem node, {required int depth}) {
    final theme = Theme.of(context);
    final isExpanded = _expandedTreePaths.contains(node.path);
    final hasChildren = node.subFolders.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 18.0, bottom: 6),
          child: Material(
            color: Colors.white.withValues(alpha: isExpanded ? 0.05 : 0.025),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: ListTile(
                dense: true,
                leading: Icon(
                  hasChildren
                      ? (isExpanded ? LucideIcons.folderOpen : LucideIcons.folder)
                      : LucideIcons.music,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  node.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
                subtitle: Text(
                  '${node.totalSongCount} songs • ${_formatDuration(node.totalDurationMs)}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11.5),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.play, size: 16, color: Colors.white70),
                      tooltip: 'Play',
                      onPressed: () => _playFolder(node),
                    ),
                    if (hasChildren)
                      IconButton(
                        icon: Icon(
                          isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                          size: 16,
                          color: Colors.white54,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedTreePaths.remove(node.path);
                            } else {
                              _expandedTreePaths.add(node.path);
                            }
                          });
                        },
                      ),
                  ],
                ),
                onTap: () {
                  if (hasChildren) {
                    setState(() {
                      if (isExpanded) {
                        _expandedTreePaths.remove(node.path);
                      } else {
                        _expandedTreePaths.add(node.path);
                      }
                    });
                  } else {
                    setState(() {
                      _breadcrumbs.add(node);
                      _currentDrilledFolder = node;
                    });
                  }
                },
              ),
            ),
          ),
        ),
        if (isExpanded && hasChildren) ...[
          for (final child in node.subFolders)
            _buildTreeNode(child, depth: depth + 1),
        ],
      ],
    );
  }

  Widget _buildDrilledFolderView(FolderItem folder) {
    final songs = folder.songs;

    return Column(
      children: [
        // Action Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              FilledButton.icon(
                onPressed: () => _playFolder(folder),
                icon: const Icon(LucideIcons.play, size: 16),
                label: const Text('Play All'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => _addFolderToQueue(folder),
                icon: const Icon(LucideIcons.listPlus, size: 16, color: Colors.white70),
                label: const Text('Add to Queue', style: TextStyle(color: Colors.white70)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),

        // Songs list
        Expanded(
          child: songs.isEmpty
              ? Center(
                  child: Text(
                    'No direct audio files in this folder',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                )
              : SongsList(
                  songs: songs,
                  shrinkWrap: false,
                  queueName: 'Folder: ${folder.name}',
                ),
        ),
      ],
    );
  }
}
