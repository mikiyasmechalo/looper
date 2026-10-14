import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/playback/data/queue_repository.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/ui/widgets/app_refresh_indicator.dart';
import 'package:looper_player/ui/widgets/app_bottom_sheet.dart';

import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:isar/isar.dart';

import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/widgets/premium_section.dart';
import 'package:looper_player/ui/widgets/song_options_bottom_sheet.dart';

import 'package:looper_player/core/ui_utils.dart';

class SongsList extends ConsumerWidget {
  final List<Song> songs;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final String? searchQuery;
  final Playlist? playlist;
  final ScrollController? controller;
  final bool showShuffleButton;
  final String? queueName;

  const SongsList({
    super.key,
    required this.songs,
    this.shrinkWrap = false,
    this.physics,
    this.searchQuery,
    this.playlist,
    this.controller,
    this.showShuffleButton = false,
    this.queueName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final songViewStyle = SongViewStyle.values[ref
        .watch(settingsProvider.select((s) => s.songViewStyleIndex))
        .clamp(0, SongViewStyle.values.length - 1)];

    final double? itemExtent = (searchQuery == null || searchQuery!.isEmpty)
        ? switch (songViewStyle) {
            SongViewStyle.normal => 72.0,
            SongViewStyle.compact => 48.0,
            SongViewStyle.textOnly => 40.0,
            SongViewStyle.grid => null,
          }
        : null;

    Widget buildSongItem(int index) {
      final song = songs[index];
      return switch (songViewStyle) {
        SongViewStyle.normal => SongTile(
            song: song,
            l10n: l10n,
            songs: songs,
            searchQuery: searchQuery,
            playlist: playlist,
            queueName: queueName,
          ),
        SongViewStyle.compact => _SongCompactTile(
            song: song,
            l10n: l10n,
            songs: songs,
            searchQuery: searchQuery,
            playlist: playlist,
            queueName: queueName,
          ),
        SongViewStyle.textOnly => _SongTextOnlyTile(
            song: song,
            index: index,
            l10n: l10n,
            songs: songs,
            searchQuery: searchQuery,
            playlist: playlist,
            queueName: queueName,
          ),
        SongViewStyle.grid => _SongGridCard(
            song: song,
            songs: songs,
            l10n: l10n,
            playlist: playlist,
            queueName: queueName,
          ),
      };
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 10,
            right: 14,
            top: 8,
            bottom: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${songs.length} ${l10n.songs}',
                    style: AppFonts.jostStyle(color: Colors.grey, fontSize: 13),
                  ),
                  if (showShuffleButton) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: songs.isEmpty
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(playbackProvider.notifier)
                                  .playShuffled(
                                    songs,
                                    queueName:
                                        queueName ??
                                        QueueRepository.allSongsQueueName,
                                  );
                            },
                      icon: const Icon(LucideIcons.shuffle, size: 18),
                      tooltip: l10n.shuffleTitle,
                      style: IconButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showSongViewStyleMenu(context, ref),
                    icon: Icon(
                      switch (songViewStyle) {
                        SongViewStyle.normal => LucideIcons.list,
                        SongViewStyle.compact => LucideIcons.alignJustify,
                        SongViewStyle.textOnly => LucideIcons.fileText,
                        SongViewStyle.grid => LucideIcons.layoutGrid,
                      },
                      size: 18,
                    ),
                    tooltip: 'Song View Style',
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showSortBottomSheet(context, ref, l10n),
                    icon: const Icon(LucideIcons.listFilter, size: 18),
                    tooltip: l10n.sortBy,
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.resetLibrary),
                            content: Text(l10n.resetLibraryConfirm),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  l10n.reset,
                                  style: AppFonts.jostStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref
                                .read(libraryProvider.notifier)
                                .resetAndRescan();
                        }
                      },
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: Text(
                        l10n.resetLibrary,
                        style: AppFonts.jostStyle(fontSize: 13),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        foregroundColor: Colors.red[300],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (shrinkWrap)
          songViewStyle == SongViewStyle.grid
              ? GridView.builder(
                  controller: controller,
                  shrinkWrap: true,
                  physics: physics ?? const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(10, 8, 14, 180),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: songs.length,
                  itemBuilder: (context, index) => buildSongItem(index),
                )
              : ListView.builder(
                  controller: controller,
                  shrinkWrap: true,
                  physics: physics ?? const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 180),
                  itemCount: songs.length,
                  itemExtent: itemExtent,
                  itemBuilder: (context, index) => buildSongItem(index),
                )
        else
          Expanded(
            child: AppRefreshIndicator(
              onRefresh: () =>
                  ref.read(libraryProvider.notifier).scanSavedFolders(),
              child: songViewStyle == SongViewStyle.grid
                  ? GridView.builder(
                      controller: controller,
                      shrinkWrap: false,
                      physics: physics ??
                          const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                      padding: const EdgeInsets.fromLTRB(10, 8, 14, 180),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 180,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: songs.length,
                      itemBuilder: (context, index) => buildSongItem(index),
                    )
                  : ListView.builder(
                      controller: controller,
                      shrinkWrap: false,
                      physics: physics ??
                          const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 180),
                      itemCount: songs.length,
                      itemExtent: itemExtent,
                      itemBuilder: (context, index) => buildSongItem(index),
                    ),
            ),
          ),
      ],
    );
  }
}

class SongTile extends ConsumerWidget {
  final Song song;
  final List<Song> songs;
  final AppLocalizations l10n;
  final String? searchQuery;
  final Playlist? playlist;
  final bool showAlbum;
  final String? queueName;

  const SongTile({
    required this.song,
    required this.songs,
    required this.l10n,
    this.searchQuery,
    this.playlist,
    this.showAlbum = true,
    this.queueName,
    super.key,
  });

  Widget _buildSubtitle(BuildContext context, WidgetRef ref) {
    return _HoverableSongSubtitle(
      song: song,
      showAlbum: showAlbum,
      l10n: l10n,
    );
  }

  Widget _buildHighlightedText({
    required BuildContext context,
    required String text,
    required String query,
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
  }) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(text, style: baseStyle);
    }

    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfMatch;

    while ((indexOfMatch = lowerText.indexOf(lowerQuery, start)) != -1) {
      // Add text before match
      if (indexOfMatch > start) {
        spans.add(
          TextSpan(text: text.substring(start, indexOfMatch), style: baseStyle),
        );
      }
      // Add matched text
      spans.add(
        TextSpan(
          text: text.substring(indexOfMatch, indexOfMatch + query.length),
          style: highlightStyle,
        ),
      );
      start = indexOfMatch + query.length;
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCurrent = ref.watch(
      playbackProvider.select((s) => s.currentSong?.path == song.path),
    );
    final isPlaying = ref.watch(
      playbackProvider.select(
        (s) => s.currentSong?.path == song.path && s.isPlaying,
      ),
    );

    String? lyricSnippet;
    if (searchQuery != null && searchQuery!.isNotEmpty && song.lyrics != null) {
      lyricSnippet = _getLyricSnippet(song.lyrics!, searchQuery!);
    }

    return Material(
      color: Colors.transparent,
      child: _SongTileBouncyTap(
        onTap: () {
          final index = songs.indexWhere((s) => s.path == song.path);
          if (index != -1) {
            ref
                .read(playbackProvider.notifier)
                .setPlaylist(
                  songs,
                  initialIndex: index,
                  queueName: queueName ?? QueueRepository.allSongsQueueName,
                );
          } else {
            ref.read(playbackProvider.notifier).play(song);
          }
        },
        onSecondaryTap: () => showSongOptionsBottomSheet(
          context: context,
          ref: ref,
          song: song,
          playlist: playlist,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: isCurrent
                      ? Stack(
                          children: [
                            OptimizedImage(
                              imagePath: song.artPath,
                              width: 52,
                              height: 52,
                              fit: BoxFit.contain,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            Positioned.fill(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: isPlaying ? 1.0 : 0.0,
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/icons/Playing.gif',
                                      width: 24,
                                      height: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : OptimizedImage(
                          imagePath: song.artPath,
                          width: 52,
                          height: 52,
                          fit: BoxFit.contain,
                          borderRadius: BorderRadius.circular(2),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      song.title,
                      style: AppFonts.jostStyle(
                        color: isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    if (lyricSnippet != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSubtitle(context, ref),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.12),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.quote,
                                  size: 9,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _buildHighlightedText(
                                    context: context,
                                    text: lyricSnippet,
                                    query: searchQuery ?? '',
                                    baseStyle: AppFonts.jostStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.75),
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    highlightStyle: AppFonts.jostStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      _buildSubtitle(context, ref),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onPressed: () => showSongOptionsBottomSheet(
                  context: context,
                  ref: ref,
                  song: song,
                  playlist: playlist,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _getLyricSnippet(String lyrics, String query) {
    final lowerLyrics = lyrics.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerLyrics.indexOf(lowerQuery);
    if (index == -1) return null;

    int start = index;
    bool truncatedStart = false;
    while (start > 0 && lyrics[start - 1] != '\n') {
      start--;
      if (index - start > 40) {
        truncatedStart = true;
        break;
      }
    }

    int end = index + query.length;
    bool truncatedEnd = false;
    while (end < lyrics.length && lyrics[end] != '\n') {
      end++;
      if (end - index > 60) {
        truncatedEnd = true;
        break;
      }
    }

    String snippet = lyrics.substring(start, end).trim();
    if (truncatedStart) snippet = '...$snippet';
    if (truncatedEnd) snippet = '$snippet...';
    return snippet;
  }
}

void _showSortBottomSheet(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    builder: (context) {
      return Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(libraryProvider);
          final settings = ref.watch(settingsProvider);
          final accentColor = Color(settings.accentColor);

          return AppBottomSheetContainer(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.sortOrder,
                        style: AppFonts.jostStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ref.read(libraryProvider.notifier).toggleSortOrder();
                        },
                        icon: Icon(
                          state.isAscending
                              ? LucideIcons.arrowUpAZ
                              : LucideIcons.arrowDownAZ,
                          size: 18,
                        ),
                        label: Text(
                          state.isAscending ? l10n.ascending : l10n.descending,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                      child: PremiumSection(
                        borderRadius: BorderRadius.circular(20),
                        padding: EdgeInsets.zero,
                        useExpanded: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _SortOption(
                              label: l10n.title,
                              icon: LucideIcons.type,
                              isSelected:
                                  state.sortStrategy == SongSortStrategy.title,
                              accentColor: accentColor,
                              isLast: false,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(libraryProvider.notifier)
                                    .setSortStrategy(SongSortStrategy.title);
                                Navigator.pop(context);
                              },
                            ),
                            _SortOption(
                              label: l10n.artist,
                              icon: LucideIcons.mic2,
                              isSelected:
                                  state.sortStrategy == SongSortStrategy.artist,
                              accentColor: accentColor,
                              isLast: false,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(libraryProvider.notifier)
                                    .setSortStrategy(SongSortStrategy.artist);
                                Navigator.pop(context);
                              },
                            ),
                            _SortOption(
                              label: l10n.album,
                              icon: LucideIcons.disc,
                              isSelected:
                                  state.sortStrategy == SongSortStrategy.album,
                              accentColor: accentColor,
                              isLast: false,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(libraryProvider.notifier)
                                    .setSortStrategy(SongSortStrategy.album);
                                Navigator.pop(context);
                              },
                            ),
                            _SortOption(
                              label: l10n.dateAdded,
                              icon: LucideIcons.calendar,
                              isSelected:
                                  state.sortStrategy ==
                                  SongSortStrategy.dateAdded,
                              accentColor: accentColor,
                              isLast: false,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(libraryProvider.notifier)
                                    .setSortStrategy(
                                      SongSortStrategy.dateAdded,
                                    );
                                Navigator.pop(context);
                              },
                            ),
                            _SortOption(
                              label: l10n.duration,
                              icon: LucideIcons.clock,
                              isSelected:
                                  state.sortStrategy ==
                                  SongSortStrategy.duration,
                              accentColor: accentColor,
                              isLast: false,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(libraryProvider.notifier)
                                    .setSortStrategy(SongSortStrategy.duration);
                                Navigator.pop(context);
                              },
                            ),
                            _SortOption(
                              label: l10n.year,
                              icon: LucideIcons.calendarDays,
                              isSelected:
                                  state.sortStrategy == SongSortStrategy.year,
                              accentColor: accentColor,
                              isLast: false,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(libraryProvider.notifier)
                                    .setSortStrategy(SongSortStrategy.year);
                                Navigator.pop(context);
                              },
                            ),
                            _SortOption(
                              label: l10n.mostPlayed,
                              icon: LucideIcons.trendingUp,
                              isSelected:
                                  state.sortStrategy ==
                                  SongSortStrategy.playCount,
                              accentColor: accentColor,
                              isLast: false,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(libraryProvider.notifier)
                                    .setSortStrategy(
                                      SongSortStrategy.playCount,
                                    );
                                Navigator.pop(context);
                              },
                            ),
                            _SortOption(
                              label: l10n.recentlyPlayed,
                              icon: LucideIcons.history,
                              isSelected:
                                  state.sortStrategy ==
                                  SongSortStrategy.lastPlayed,
                              accentColor: accentColor,
                              isLast: true,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(libraryProvider.notifier)
                                    .setSortStrategy(
                                      SongSortStrategy.lastPlayed,
                                    );
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    },
  );
}

class _SortOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final bool isLast;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? accentColor
                      : Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: AppFonts.jostStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.check,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.8,
            color: Colors.white.withValues(alpha: 0.04),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}

class _SongTileBouncyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onSecondaryTap;

  const _SongTileBouncyTap({
    required this.child,
    required this.onTap,
    this.onSecondaryTap,
  });

  @override
  State<_SongTileBouncyTap> createState() => _SongTileBouncyTapState();
}

class _SongTileBouncyTapState extends State<_SongTileBouncyTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const isDesktop = true;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: Duration(milliseconds: _isHovered ? 80 : 220),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(
          left: isDesktop ? 10 : 8,
          right: isDesktop ? 14 : 8,
        ),
        decoration: BoxDecoration(
          color: _isHovered
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onTap();
          },
          onTapCancel: () => _controller.reverse(),
          onSecondaryTap: widget.onSecondaryTap,
          behavior: HitTestBehavior.opaque,
          child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
        ),
      ),
    );
  }
}

Future<void> _navigateToArtist(
  BuildContext context,
  WidgetRef ref,
  Song
  song, // Replace 'Song' with your actual song model class name if different
  AppLocalizations
  l10n, // Replace 'AppLocalizations' with your localizations class if different
) async {
  if (song.artist == null) return;

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

  ref
      .read(appNavigationProvider.notifier)
      .showCollection(
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

  ref
      .read(appNavigationProvider.notifier)
      .showCollection(
        title: albumName,
        subtitle: song.artist,
        art: album?.artPath ?? song.artPath,
        songs: albumSongs,
        highlightItem: NavItem.albums,
      );
}

class _HoverableSongSubtitle extends ConsumerStatefulWidget {
  final Song song;
  final bool showAlbum;
  final AppLocalizations l10n;

  const _HoverableSongSubtitle({
    required this.song,
    required this.showAlbum,
    required this.l10n,
  });

  @override
  ConsumerState<_HoverableSongSubtitle> createState() =>
      _HoverableSongSubtitleState();
}

class _HoverableSongSubtitleState extends ConsumerState<_HoverableSongSubtitle> {
  bool _hoverArtist = false;
  bool _hoverAlbum = false;

  @override
  Widget build(BuildContext context) {
    final artist = widget.song.artist ?? widget.l10n.unknownArtist;
    final album = widget.song.album;
    final hasAlbum = widget.showAlbum && album != null && album.isNotEmpty;
    final accentColor = Color(ref.watch(settingsProvider).accentColor);

    final defaultStyle = AppFonts.jostStyle(
      color: Colors.white.withValues(alpha: 0.5),
      fontSize: 13,
    );

    return Text.rich(
      TextSpan(
        style: defaultStyle,
        children: [
          TextSpan(
            text: artist,
            style: defaultStyle.copyWith(
              color: _hoverArtist ? accentColor : Colors.white.withValues(alpha: 0.5),
              decoration: _hoverArtist ? TextDecoration.underline : TextDecoration.none,
              decorationColor: accentColor,
            ),
            mouseCursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hoverArtist = true),
            onExit: (_) => setState(() => _hoverArtist = false),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _navigateToArtist(context, ref, widget.song, widget.l10n),
          ),
          if (hasAlbum) ...[
            TextSpan(
              text: ' · ',
              style: defaultStyle,
            ),
            TextSpan(
              text: album,
              style: defaultStyle.copyWith(
                color: _hoverAlbum ? accentColor : Colors.white.withValues(alpha: 0.5),
                decoration: _hoverAlbum ? TextDecoration.underline : TextDecoration.none,
                decorationColor: accentColor,
              ),
              mouseCursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hoverAlbum = true),
              onExit: (_) => setState(() => _hoverAlbum = false),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _navigateToAlbum(context, ref, widget.song),
            ),
          ],
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

void _showSongViewStyleMenu(BuildContext context, WidgetRef ref) {
  final currentStyleIndex = ref.read(settingsProvider.select(
    (s) => s.songViewStyleIndex,
  ));

  final options = [
    (SongViewStyle.normal, 'Normal List', LucideIcons.list, 'Standard list with artwork and details'),
    (SongViewStyle.compact, 'Compact List', LucideIcons.alignJustify, 'Dense list with smaller artwork'),
    (SongViewStyle.textOnly, 'Text Only', LucideIcons.fileText, 'Small text only list without artwork'),
    (SongViewStyle.grid, 'Grid Cards', LucideIcons.layoutGrid, 'Visual grid with album cover cards'),
  ];

  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (ctx) => Consumer(
      builder: (context, ref, _) {
        final accent = Theme.of(context).colorScheme.primary;
        return AppBottomSheetContainer(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Row(
                  children: [
                    Text(
                      'Song View Style',
                      style: AppFonts.jostStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: PremiumSection(
                  borderRadius: BorderRadius.circular(20),
                  padding: EdgeInsets.zero,
                  useExpanded: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < options.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            thickness: 0.8,
                            color: Colors.white.withValues(alpha: 0.04),
                            indent: 20,
                            endIndent: 20,
                          ),
                        _SongStyleOption(
                          label: options[i].$2,
                          subtitle: options[i].$4,
                          icon: options[i].$3,
                          isSelected: currentStyleIndex == options[i].$1.index,
                          accentColor: accent,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(settingsProvider.notifier)
                                .updateSongViewStyle(options[i].$1.index);
                            Navigator.pop(ctx);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    ),
  );
}

class _SongStyleOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _SongStyleOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? accentColor : Colors.white70,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppFonts.jostStyle(
                      fontSize: 15.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppFonts.jostStyle(
                      fontSize: 12.5,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                LucideIcons.check,
                color: accentColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _SongCompactTile extends ConsumerWidget {
  final Song song;
  final List<Song> songs;
  final AppLocalizations l10n;
  final String? searchQuery;
  final Playlist? playlist;
  final String? queueName;

  const _SongCompactTile({
    required this.song,
    required this.songs,
    required this.l10n,
    this.searchQuery,
    this.playlist,
    this.queueName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCurrent = ref.watch(
      playbackProvider.select((s) => s.currentSong?.path == song.path),
    );
    final isPlaying = ref.watch(
      playbackProvider.select(
        (s) => s.currentSong?.path == song.path && s.isPlaying,
      ),
    );

    return Material(
      color: Colors.transparent,
      child: _SongTileBouncyTap(
        onTap: () {
          final index = songs.indexWhere((s) => s.path == song.path);
          if (index != -1) {
            ref.read(playbackProvider.notifier).setPlaylist(
                  songs,
                  initialIndex: index,
                  queueName: queueName ?? QueueRepository.allSongsQueueName,
                );
          } else {
            ref.read(playbackProvider.notifier).play(song);
          }
        },
        onSecondaryTap: () => showSongOptionsBottomSheet(
          context: context,
          ref: ref,
          song: song,
          playlist: playlist,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: Stack(
                    children: [
                      OptimizedImage(
                        imagePath: song.artPath,
                        width: 38,
                        height: 38,
                        fit: BoxFit.contain,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      if (isCurrent)
                        Positioned.fill(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: isPlaying ? 1.0 : 0.0,
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.4),
                              child: Center(
                                child: Image.asset(
                                  'assets/icons/Playing.gif',
                                  width: 18,
                                  height: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      song.title,
                      style: AppFonts.jostStyle(
                        color: isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    _HoverableSongSubtitle(
                      song: song,
                      showAlbum: true,
                      l10n: l10n,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (song.duration != null && song.duration! > 0)
                Text(
                  UiUtils.formatDurationMs(song.duration),
                  style: AppFonts.jostStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey, size: 18),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () => showSongOptionsBottomSheet(
                  context: context,
                  ref: ref,
                  song: song,
                  playlist: playlist,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongTextOnlyTile extends ConsumerWidget {
  final Song song;
  final int index;
  final List<Song> songs;
  final AppLocalizations l10n;
  final String? searchQuery;
  final Playlist? playlist;
  final String? queueName;

  const _SongTextOnlyTile({
    required this.song,
    required this.index,
    required this.songs,
    required this.l10n,
    this.searchQuery,
    this.playlist,
    this.queueName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCurrent = ref.watch(
      playbackProvider.select((s) => s.currentSong?.path == song.path),
    );
    final isPlaying = ref.watch(
      playbackProvider.select(
        (s) => s.currentSong?.path == song.path && s.isPlaying,
      ),
    );
    final accent = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: _SongTileBouncyTap(
        onTap: () {
          final targetIndex = songs.indexWhere((s) => s.path == song.path);
          if (targetIndex != -1) {
            ref.read(playbackProvider.notifier).setPlaylist(
                  songs,
                  initialIndex: targetIndex,
                  queueName: queueName ?? QueueRepository.allSongsQueueName,
                );
          } else {
            ref.read(playbackProvider.notifier).play(song);
          }
        },
        onSecondaryTap: () => showSongOptionsBottomSheet(
          context: context,
          ref: ref,
          song: song,
          playlist: playlist,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Row(
            children: [
              SizedBox(
                width: songs.length >= 10000
                    ? 42
                    : (songs.length >= 1000 ? 34 : 26),
                child: isCurrent && isPlaying
                    ? Center(
                        child: Image.asset(
                          'assets/icons/Playing.gif',
                          width: 14,
                          height: 14,
                          color: accent,
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          style: AppFonts.jostStyle(
                            color: isCurrent ? accent : Colors.white38,
                            fontSize: 12,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        song.title,
                        style: AppFonts.jostStyle(
                          color: isCurrent ? accent : Colors.white,
                          fontWeight:
                              isCurrent ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (song.artist != null && song.artist!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '• ${song.artist!}',
                          style: AppFonts.jostStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (song.duration != null && song.duration! > 0)
                Text(
                  UiUtils.formatDurationMs(song.duration),
                  style: AppFonts.jostStyle(
                    color: Colors.white38,
                    fontSize: 11.5,
                  ),
                ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey, size: 16),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () => showSongOptionsBottomSheet(
                  context: context,
                  ref: ref,
                  song: song,
                  playlist: playlist,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongGridCard extends ConsumerStatefulWidget {
  final Song song;
  final List<Song> songs;
  final AppLocalizations l10n;
  final Playlist? playlist;
  final String? queueName;

  const _SongGridCard({
    required this.song,
    required this.songs,
    required this.l10n,
    this.playlist,
    this.queueName,
  });

  @override
  ConsumerState<_SongGridCard> createState() => _SongGridCardState();
}

class _SongGridCardState extends ConsumerState<_SongGridCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    final isCurrent = ref.watch(
      playbackProvider.select((s) => s.currentSong?.path == song.path),
    );
    final isPlaying = ref.watch(
      playbackProvider.select(
        (s) => s.currentSong?.path == song.path && s.isPlaying,
      ),
    );
    final accent = Theme.of(context).colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          final index = widget.songs.indexWhere((s) => s.path == song.path);
          if (index != -1) {
            ref.read(playbackProvider.notifier).setPlaylist(
                  widget.songs,
                  initialIndex: index,
                  queueName: widget.queueName ?? QueueRepository.allSongsQueueName,
                );
          } else {
            ref.read(playbackProvider.notifier).play(song);
          }
        },
        onSecondaryTap: () => showSongOptionsBottomSheet(
          context: context,
          ref: ref,
          song: song,
          playlist: widget.playlist,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrent
                  ? accent.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.05),
              width: isCurrent ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    OptimizedImage(
                      imagePath: song.artPath,
                      fit: BoxFit.cover,
                      cacheWidth: 384,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    if (isCurrent)
                      Positioned.fill(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isPlaying ? 1.0 : 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/icons/Playing.gif',
                                width: 28,
                                height: 28,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => showSongOptionsBottomSheet(
                          context: context,
                          ref: ref,
                          song: song,
                          playlist: widget.playlist,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                song.title,
                style: AppFonts.jostStyle(
                  color: isCurrent ? accent : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                song.artist ?? widget.l10n.unknownArtist,
                style: AppFonts.jostStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
