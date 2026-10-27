import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path/path.dart' as p;
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/logger_helper.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/search/presentation/search_view.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/app_refresh_indicator.dart';

class FolderItem {
  final String path;
  final String name;
  final List<Song> songs;
  final List<FolderItem> subFolders;

  FolderItem({
    required this.path,
    required this.name,
    required this.songs,
    List<FolderItem>? subFolders,
  }) : subFolders = subFolders ?? <FolderItem>[];

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
  String? _currentDrilledPath;
  final List<String> _breadcrumbs = [];
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

  static bool _isWithinAnyFolder(String filePath, List<String> folders) {
    if (folders.isEmpty) return false;
    final normFile = p.normalize(p.absolute(filePath)).toLowerCase();
    for (final folder in folders) {
      final normFolder = p.normalize(p.absolute(folder)).toLowerCase();
      if (normFile == normFolder ||
          normFile.startsWith(normFolder.endsWith(Platform.pathSeparator)
              ? normFolder
              : '$normFolder${Platform.pathSeparator}')) {
        return true;
      }
    }
    return false;
  }

  /// Groups songs into flat directory buckets (only folders containing songs)
  List<FolderItem> _buildFlatFolders(List<Song> songs, [List<String>? libraryFolders]) {
    final Map<String, List<Song>> folderMap = {};

    for (final song in songs) {
      if (song.path.isEmpty) continue;
      if (libraryFolders != null && libraryFolders.isNotEmpty) {
        if (!_isWithinAnyFolder(song.path, libraryFolders)) {
          continue;
        }
      }
      try {
        final dir = File(song.path).parent.path;
        folderMap.putIfAbsent(dir, () => []).add(song);
      } catch (_) {}
    }

    final list = folderMap.entries.map((e) {
      final folderPath = e.key;
      final folderName = folderPath
              .split(Platform.isWindows ? r'\' : '/')
              .where((p) => p.isNotEmpty)
              .lastOrNull ??
          folderPath;
      return FolderItem(
        path: folderPath,
        name: folderName,
        songs: e.value,
        subFolders: <FolderItem>[],
      );
    }).toList();

    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  /// Groups songs into a nested tree structure (safely cloning nodes with mutable subFolders)
  List<FolderItem> _buildTree(List<Song> songs, String searchQuery, [List<String>? libraryFolders]) {
    try {
      final flatFolders = _buildFlatFolders(songs, libraryFolders);
      if (flatFolders.isEmpty) return [];

      // Create isolated mutable nodes with growable subFolders list
      final Map<String, FolderItem> nodeMap = {};
      for (final flat in flatFolders) {
        nodeMap[flat.path] = FolderItem(
          path: flat.path,
          name: flat.name,
          songs: flat.songs,
          subFolders: <FolderItem>[],
        );
      }

      final List<FolderItem> rootNodes = [];

      for (final flat in flatFolders) {
        final node = nodeMap[flat.path]!;
        try {
          final parentDir = File(flat.path).parent.path;
          if (nodeMap.containsKey(parentDir)) {
            final parent = nodeMap[parentDir]!;
            if (!parent.subFolders.any((s) => s.path == node.path)) {
              parent.subFolders.add(node);
            }
          } else {
            rootNodes.add(node);
          }
        } catch (_) {
          rootNodes.add(node);
        }
      }

      rootNodes.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      if (searchQuery.isNotEmpty) {
        return _filterTreeNodes(rootNodes, searchQuery);
      }

      return rootNodes;
    } catch (e, st) {
      LoggerHelper.write('FolderBrowserView._buildTree error: $e\n$st');
      return _buildFlatFolders(songs, libraryFolders);
    }
  }

  List<FolderItem> _filterTreeNodes(List<FolderItem> nodes, String query) {
    final List<FolderItem> filtered = [];
    for (final node in nodes) {
      final nameMatches = node.name.toLowerCase().contains(query) ||
          node.path.toLowerCase().contains(query);
      final filteredSub = _filterTreeNodes(node.subFolders, query);

      if (nameMatches || filteredSub.isNotEmpty) {
        filtered.add(FolderItem(
          path: node.path,
          name: node.name,
          songs: node.songs,
          subFolders: filteredSub,
        ));
      }
    }
    return filtered;
  }

  void _playFolder(FolderItem folder) {
    final all = folder.allSongs;
    if (all.isEmpty) return;
    HapticFeedback.lightImpact();
    ref.read(playbackProvider.notifier).setPlaylist(
      all,
      queueName: 'Folder: ${folder.name}',
      disableShuffle: true,
    );
    ref.read(playbackProvider.notifier).play(all.first);
  }

  void _shuffleFolder(FolderItem folder) {
    final all = folder.allSongs;
    if (all.isEmpty) return;
    HapticFeedback.lightImpact();
    ref.read(playbackProvider.notifier).playShuffled(
      all,
      queueName: 'Folder: ${folder.name}',
    );
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
    final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();

    final flatFolders = _buildFlatFolders(library.songs, settings.libraryFolders);
    final filteredFlatFolders = flatFolders.where((f) {
      if (searchQuery.isEmpty) return true;
      final q = searchQuery;
      return f.name.toLowerCase().contains(q) || f.path.toLowerCase().contains(q);
    }).toList();

    final tree = _buildTree(library.songs, '', settings.libraryFolders);

    FolderItem? findNodeByPath(List<FolderItem> nodes, String targetPath) {
      final normTarget = p.normalize(targetPath).toLowerCase();
      for (final n in nodes) {
        if (p.normalize(n.path).toLowerCase() == normTarget) {
          return n;
        }
        final found = findNodeByPath(n.subFolders, targetPath);
        if (found != null) return found;
      }
      return null;
    }

    FolderItem? activeDrilledFolder;
    if (_currentDrilledPath != null) {
      activeDrilledFolder = findNodeByPath(tree, _currentDrilledPath!);
      if (activeDrilledFolder == null) {
        final normTarget = p.normalize(_currentDrilledPath!).toLowerCase();
        final flatMatch = flatFolders
            .where((f) => p.normalize(f.path).toLowerCase() == normTarget)
            .firstOrNull;
        if (flatMatch != null) {
          activeDrilledFolder = flatMatch;
        } else {
          final folderName = _currentDrilledPath!
                  .split(Platform.isWindows ? r'\' : '/')
                  .where((s) => s.isNotEmpty)
                  .lastOrNull ??
              _currentDrilledPath!;
          activeDrilledFolder = FolderItem(
            path: _currentDrilledPath!,
            name: folderName,
            songs: [],
            subFolders: [],
          );
        }
      }
    }

    final isDrilled = activeDrilledFolder != null;

    return Column(
      children: [
        // Unified Single-Line Top Header Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            children: [
              if (isDrilled) ...[
                IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                  tooltip: 'Back to Folders',
                  onPressed: () {
                    setState(() {
                      if (_breadcrumbs.isNotEmpty) {
                        _breadcrumbs.removeLast();
                        _currentDrilledPath = _breadcrumbs.lastOrNull;
                      } else {
                        _currentDrilledPath = null;
                      }
                    });
                  },
                ),
                const SizedBox(width: 4),
              ],

              // Folder Title & Track Counts
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        isDrilled
                            ? activeDrilledFolder.name
                            : 'Music Folders',
                        style: AppFonts.jostStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDrilled
                          ? '• ${activeDrilledFolder.allSongs.length} tracks • ${_formatDuration(activeDrilledFolder.totalDurationMs)}'
                          : '• ${flatFolders.length} folders • ${library.songs.length} tracks',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Inline Action Buttons when drilled in a folder
              if (activeDrilledFolder != null) ...[
                const SizedBox(width: 10),
                _HeaderActionButton(
                  icon: LucideIcons.play,
                  label: 'Play All',
                  filled: true,
                  onTap: () => _playFolder(activeDrilledFolder!),
                ),
                const SizedBox(width: 6),
                _HeaderActionButton(
                  icon: LucideIcons.shuffle,
                  tooltip: 'Shuffle Folder',
                  onTap: () => _shuffleFolder(activeDrilledFolder!),
                ),
                const SizedBox(width: 6),
                _HeaderActionButton(
                  icon: LucideIcons.listPlus,
                  tooltip: 'Add to Queue',
                  label: 'Queue',
                  onTap: () => _addFolderToQueue(activeDrilledFolder!),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(LucideIcons.refreshCw, size: 16, color: Colors.white70),
                  tooltip: 'Rescan Folder',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => ref.read(libraryProvider.notifier).scanLibrary(activeDrilledFolder!.path),
                ),
                const SizedBox(width: 12),
              ],

              // Rescan Button when at root level
              if (!isDrilled) ...[
                if (library.isScanning) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        library.scanStatus ?? 'Scanning...',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(LucideIcons.refreshCw, size: 16, color: Colors.white70),
                    tooltip: 'Rescan Folders',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => ref.read(libraryProvider.notifier).scanSavedFolders(),
                  ),
                  const SizedBox(width: 6),
                ],
              ],

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
                        size: 17,
                        color: !isTreeMode ? theme.colorScheme.primary : Colors.white54,
                      ),
                      tooltip: 'Flat Folders List',
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        ref.read(settingsProvider.notifier).updateFolderViewTreeMode(false);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.folderTree,
                        size: 17,
                        color: isTreeMode ? theme.colorScheme.primary : Colors.white54,
                      ),
                      tooltip: 'Directory Tree View',
                      visualDensity: VisualDensity.compact,
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

        // Main Body Content
        Expanded(
          child: activeDrilledFolder != null
              ? _buildDrilledFolderView(activeDrilledFolder, searchQuery)
              : isTreeMode
                  ? _buildTreeView(_buildTree(library.songs, searchQuery, settings.libraryFolders), searchQuery)
                  : _buildFlatListView(filteredFlatFolders),
        ),
      ],
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

    return AppRefreshIndicator(
      onRefresh: () => ref.read(libraryProvider.notifier).scanSavedFolders(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 100),
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
                      _breadcrumbs.add(folder.path);
                      _currentDrilledPath = folder.path;
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTreeView(List<FolderItem> rootNodes, String searchQuery) {
    if (rootNodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.folderTree, size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            Text(
              searchQuery.isNotEmpty
                  ? 'No directory tree matching "$searchQuery"'
                  : 'No directory tree available',
              style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return AppRefreshIndicator(
      onRefresh: () => ref.read(libraryProvider.notifier).scanSavedFolders(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 100),
        children: rootNodes.map((node) => _buildTreeNode(node, depth: 0, searchQuery: searchQuery)).toList(),
      ),
    );
  }

  Widget _buildTreeNode(FolderItem node, {required int depth, required String searchQuery}) {
    final theme = Theme.of(context);
    final autoExpand = searchQuery.isNotEmpty && node.subFolders.isNotEmpty;
    final isExpanded = _expandedTreePaths.contains(node.path) || autoExpand;
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
                  isExpanded ? LucideIcons.folderOpen : LucideIcons.folder,
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
                    if (hasChildren && node.songs.isNotEmpty)
                      IconButton(
                        icon: const Icon(LucideIcons.folderOpen, size: 16, color: Colors.white60),
                        tooltip: 'View direct tracks',
                        onPressed: () {
                          setState(() {
                            _breadcrumbs.add(node.path);
                            _currentDrilledPath = node.path;
                          });
                        },
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
                      _breadcrumbs.add(node.path);
                      _currentDrilledPath = node.path;
                    });
                  }
                },
              ),
            ),
          ),
        ),
        if (isExpanded && hasChildren) ...[
          if (node.songs.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: (depth + 1) * 18.0, bottom: 6),
              child: Material(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      LucideIcons.music,
                      size: 18,
                      color: theme.colorScheme.primary.withValues(alpha: 0.8),
                    ),
                    title: Text(
                      '${node.name} (Direct Songs)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      '${node.songs.length} tracks • ${_formatDuration(node.songs.fold(0, (sum, s) => sum + (s.duration ?? 0)))}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.play, size: 16, color: Colors.white70),
                          tooltip: 'Play Direct Songs',
                          onPressed: () {
                            ref.read(playbackProvider.notifier).setPlaylist(
                              node.songs,
                              queueName: 'Folder: ${node.name}',
                              disableShuffle: true,
                            );
                            ref.read(playbackProvider.notifier).play(node.songs.first);
                          },
                        ),
                        const Icon(LucideIcons.arrowRight, size: 14, color: Colors.white38),
                        const SizedBox(width: 8),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _breadcrumbs.add(node.path);
                        _currentDrilledPath = node.path;
                      });
                    },
                  ),
                ),
              ),
            ),
          for (final child in node.subFolders)
            _buildTreeNode(child, depth: depth + 1, searchQuery: searchQuery),
        ],
      ],
    );
  }

  Widget _buildDrilledFolderView(FolderItem folder, String searchQuery) {
    var songs = folder.songs;
    if (searchQuery.isNotEmpty) {
      songs = songs.where((s) {
        return s.title.toLowerCase().contains(searchQuery) ||
            (s.artist?.toLowerCase().contains(searchQuery) ?? false) ||
            (s.album?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    }

    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.folderX, size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            Text(
              searchQuery.isNotEmpty
                  ? 'No songs matching "$searchQuery"'
                  : 'No direct audio files in this folder',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => ref.read(libraryProvider.notifier).scanLibrary(folder.path),
              icon: const Icon(LucideIcons.refreshCw, size: 14),
              label: const Text('Rescan Folder'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    }

    return SongsList(
      songs: songs,
      shrinkWrap: false,
      queueName: 'Folder: ${folder.name}',
      onRescan: () => ref.read(libraryProvider.notifier).scanLibrary(folder.path),
      headerPadding: const EdgeInsets.fromLTRB(24, 6, 24, 8),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final String? tooltip;
  final bool filled;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    this.label,
    this.tooltip,
    this.filled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final button = filled
        ? ElevatedButton.icon(
            icon: Icon(icon, size: 15, color: Colors.black87),
            label: Text(label ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onTap,
          )
        : (label != null)
            ? OutlinedButton.icon(
                icon: Icon(icon, size: 15, color: Colors.white70),
                label: Text(label!, style: const TextStyle(fontSize: 12.5, color: Colors.white70)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onTap,
              )
            : IconButton(
                icon: Icon(icon, size: 17, color: Colors.white70),
                tooltip: tooltip,
                visualDensity: VisualDensity.compact,
                onPressed: onTap,
              );

    if (tooltip != null && (filled || label != null)) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
