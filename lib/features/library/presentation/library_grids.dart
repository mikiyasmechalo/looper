import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:looper_player/ui/widgets/app_bottom_sheet.dart';
import 'package:looper_player/ui/widgets/app_loading_indicator.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/domain/models/library_sort_options.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/ui/widgets/artist_image.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/ui/widgets/global_playing_indicator.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/widgets/premium_section.dart';
import 'package:looper_player/ui/widgets/collection_options_bottom_sheet.dart';

// Providers for Albums and Artists
final albumsProvider = StreamProvider<List<Album>>((ref) {
  return DbService.isar.albums.where().sortByDateAddedDesc().watch(
    fireImmediately: true,
  );
});

final artistsProvider = StreamProvider<List<Artist>>((ref) {
  return DbService.isar.artists.where().sortByName().watch(
    fireImmediately: true,
  );
});

final genresProvider = Provider<List<String>>((ref) {
  final songs = ref.watch(libraryProvider).songs;
  final genreSet = <String>{};
  for (final song in songs) {
    final genre = song.genre;
    if (genre != null && genre.isNotEmpty) {
      genreSet.add(genre);
    }
  }
  return genreSet.toList()..sort();
});

final Map<String, double> _gridScrollOffsets = {};

class AlbumsGrid extends ConsumerStatefulWidget {
  const AlbumsGrid({super.key});

  @override
  ConsumerState<AlbumsGrid> createState() => _AlbumsGridState();
}

class _AlbumsGridState extends ConsumerState<AlbumsGrid> {
  late final ScrollController _scrollController = ScrollController(
    initialScrollOffset: _gridScrollOffsets['albums'] ?? 0,
    keepScrollOffset: false,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      _gridScrollOffsets['albums'] = _scrollController.offset;
    }
  }

  @override
  void dispose() {
    if (_scrollController.hasClients) {
      _gridScrollOffsets['albums'] = _scrollController.offset;
    }
    _scrollController.dispose();
    super.dispose();
  }

  List<Album> _sort(List<Album> albums, AlbumSortOption opt, bool asc) {
    final list = List<Album>.from(albums);
    switch (opt) {
      case AlbumSortOption.name:
        list.sort((a, b) => asc
            ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
            : b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case AlbumSortOption.dateAdded:
        list.sort((a, b) => asc
            ? a.dateAdded.compareTo(b.dateAdded)
            : b.dateAdded.compareTo(a.dateAdded));
      case AlbumSortOption.year:
        list.sort((a, b) => asc
            ? (a.year ?? 0).compareTo(b.year ?? 0)
            : (b.year ?? 0).compareTo(a.year ?? 0));
      case AlbumSortOption.songCount:
        final counts = <String, int>{};
        for (final song in ref.read(libraryProvider).songs) {
          if (song.album != null) {
            counts[song.album!] = (counts[song.album!] ?? 0) + 1;
          }
        }
        list.sort((a, b) => asc
            ? (counts[a.name] ?? 0).compareTo(counts[b.name] ?? 0)
            : (counts[b.name] ?? 0).compareTo(counts[a.name] ?? 0));
      case AlbumSortOption.artistAlbumArtist:
        list.sort((a, b) => asc
            ? (a.artist ?? '').toLowerCase().compareTo((b.artist ?? '').toLowerCase())
            : (b.artist ?? '').toLowerCase().compareTo((a.artist ?? '').toLowerCase()));
    }
    return list;
  }

  String _sortLabel(AlbumSortOption opt, AppLocalizations l10n) =>
      switch (opt) {
        AlbumSortOption.name => l10n.sortAlphabeticalAZ,
        AlbumSortOption.dateAdded => l10n.sortRecentlyAdded,
        AlbumSortOption.year => l10n.sortYearNewest,
        AlbumSortOption.songCount => l10n.sortMostSongs,
        AlbumSortOption.artistAlbumArtist => l10n.artist,
      };

  void _showSortMenu(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final accentColor = Color(ref.watch(settingsProvider).accentColor);
            final currentSort = ref.watch(albumSortProvider);
            final currentAsc = ref.watch(albumSortAscendingProvider);

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
                            ref.read(albumSortAscendingProvider.notifier).state = !currentAsc;
                          },
                          icon: Icon(
                            currentAsc ? LucideIcons.arrowUpAZ : LucideIcons.arrowDownAZ,
                            size: 18,
                          ),
                          label: Text(
                            currentAsc ? l10n.ascending : l10n.descending,
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: accentColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: PremiumSection(
                          borderRadius: BorderRadius.circular(20),
                          padding: EdgeInsets.zero,
                          useExpanded: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _GridSortOption(
                                label: l10n.sortAlphabeticalAZ,
                                icon: LucideIcons.type,
                                isSelected: currentSort == AlbumSortOption.name,
                                accentColor: accentColor,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref.read(albumSortProvider.notifier).state = AlbumSortOption.name;
                                  Navigator.pop(context);
                                },
                              ),
                              const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                              _GridSortOption(
                                label: l10n.sortRecentlyAdded,
                                icon: LucideIcons.calendar,
                                isSelected: currentSort == AlbumSortOption.dateAdded,
                                accentColor: accentColor,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref.read(albumSortProvider.notifier).state = AlbumSortOption.dateAdded;
                                  Navigator.pop(context);
                                },
                              ),
                              const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                              _GridSortOption(
                                label: l10n.sortYearNewest,
                                icon: LucideIcons.calendarDays,
                                isSelected: currentSort == AlbumSortOption.year,
                                accentColor: accentColor,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref.read(albumSortProvider.notifier).state = AlbumSortOption.year;
                                  Navigator.pop(context);
                                },
                              ),
                              const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                              _GridSortOption(
                                label: l10n.sortMostSongs,
                                icon: LucideIcons.music,
                                isSelected: currentSort == AlbumSortOption.songCount,
                                accentColor: accentColor,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref.read(albumSortProvider.notifier).state = AlbumSortOption.songCount;
                                  Navigator.pop(context);
                                },
                              ),
                              const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                              _GridSortOption(
                                label: l10n.artist,
                                icon: LucideIcons.mic2,
                                isSelected: currentSort == AlbumSortOption.artistAlbumArtist,
                                accentColor: accentColor,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref.read(albumSortProvider.notifier).state = AlbumSortOption.artistAlbumArtist;
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final albumsAsync = ref.watch(albumsProvider);
    final sortOpt = ref.watch(albumSortProvider);
    final sortAsc = ref.watch(albumSortAscendingProvider);
    final l10n = AppLocalizations.of(context)!;

    return albumsAsync.when(
      data: (raw) {
        final albums = _sort(raw, sortOpt, sortAsc);
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.s, 16.s, 24.s, 8.s),
              child: Row(
                children: [
                  Text(
                    '${albums.length} ${l10n.albums}',
                    style: AppFonts.jostStyle(
                      color: Colors.white54,
                      fontSize: 13.ts,
                    ),
                  ),
                  IconButton(
                    onPressed: albums.isEmpty
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(playbackProvider.notifier)
                                .playShuffledGrouped(
                                  _allAlbumsGroups(ref, albums),
                                  queueName: 'All Albums',
                                );
                          },
                    icon: const Icon(LucideIcons.shuffle, size: 18),
                    tooltip: l10n.shuffleTitle,
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showSortMenu(l10n),
                    icon: const Icon(LucideIcons.arrowUpDown, size: 14),
                    label: Text(
                      _sortLabel(sortOpt, l10n),
                      style: AppFonts.jostStyle(fontSize: 13.ts),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showCardStyleMenu(context, ref, isAlbum: true),
                    icon: const Icon(LucideIcons.layoutGrid, size: 16),
                    tooltip: 'Card Style',
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAllAlbumsOptions(context, ref, albums, l10n),
                    icon: const Icon(LucideIcons.moreHorizontal, size: 16),
                    tooltip: 'Options',
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRect(
                child: Builder(
                  builder: (context) {
                    final albumCardStyle = CardStyle.values[ref
                        .watch(settingsProvider.select((s) => s.albumCardStyleIndex))
                        .clamp(0, CardStyle.values.length - 1)];

                    final double maxExtent = (albumCardStyle == CardStyle.card || albumCardStyle == CardStyle.image)
                        ? 175.s
                        : 185.s;
                    final double spacing = albumCardStyle == CardStyle.imageGapless
                        ? 0
                        : ((albumCardStyle == CardStyle.card || albumCardStyle == CardStyle.image) ? 12 : 14);
                    final double aspectRatio = switch (albumCardStyle) {
                      CardStyle.normal => 0.74,
                      CardStyle.circle => 0.81,
                      CardStyle.card => 0.74,
                      CardStyle.image => 1.0,
                      CardStyle.imageGapless => 1.0,
                    };
                    final EdgeInsets padding = albumCardStyle == CardStyle.imageGapless
                        ? EdgeInsets.zero
                        : EdgeInsets.all(20.s);

                    return GridView.builder(
                      controller: _scrollController,
                      padding: padding,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: maxExtent,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                      ),
                      itemCount: albums.length,
                      itemBuilder: (context, index) =>
                          _AlbumCard(album: albums[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const AppLoadingIndicator(),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  void _showAllAlbumsOptions(
    BuildContext context,
    WidgetRef ref,
    List<Album> albums,
    AppLocalizations l10n,
  ) {
    final groups = _allAlbumsGroups(ref, albums);
    final songs = groups.expand((g) => g).toList();
    showCollectionOptionsBottomSheet(
      context: context,
      ref: ref,
      title: 'All Albums',
      subtitle: '${albums.length} ${l10n.albums} • ${songs.length} ${l10n.songs}',
      songs: songs,
      shuffleGroups: groups,
    );
  }

  /// Groups every library song by album in a single pass. Songs with a track
  /// number are sorted by it, so the Shuffle action plays whole albums in order.
  List<List<Song>> _allAlbumsGroups(WidgetRef ref, List<Album> albums) {
    // Use the already-loaded in-memory library instead of a blocking DB query,
    // so the menu opens instantly.
    final allSongs = ref.read(libraryProvider).songs;
    final byAlbum = <String, List<Song>>{};
    for (final s in allSongs) {
      final albumName = s.album;
      if (albumName == null || albumName.isEmpty) continue;
      (byAlbum[albumName] ??= []).add(s);
    }
    for (final group in byAlbum.values) {
      group.sort((a, b) => (a.trackNumber ?? 0).compareTo(b.trackNumber ?? 0));
    }
    return [
      for (final album in albums)
        if (byAlbum[album.name] case final g? when g.isNotEmpty) g,
    ];
  }
}

class _AlbumCard extends ConsumerStatefulWidget {
  final Album album;
  const _AlbumCard({required this.album});

  @override
  ConsumerState<_AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends ConsumerState<_AlbumCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final album = widget.album;
    final cardStyle = CardStyle.values[ref
        .watch(settingsProvider.select((s) => s.albumCardStyleIndex))
        .clamp(0, CardStyle.values.length - 1)];
    final settings = ref.watch(settingsProvider);
    final isDynamic = settings.enableDynamicTheming;
    final useBlur = (settings.enableDynamicTheming || settings.keepBackgroundGradient) &&
        !settings.disableBlur &&
        !settings.isBatterySaverActive;
    final isCurrentAlbum = ref.watch(
      playbackProvider.select((s) => s.currentSong?.album == album.name),
    );
    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
    final nav = ref.watch(appNavigationProvider);
    final isSelected =
        nav.activeItem == NavItem.collectionDetail &&
        nav.collectionTitle == album.name;

    Widget buildArtwork({
      BorderRadius? borderRadius,
      BoxShape shape = BoxShape.rectangle,
      bool isOverlay = false,
    }) {
      final effectiveRadius = shape == BoxShape.circle
          ? BorderRadius.zero
          : (borderRadius ?? BorderRadius.circular(14));

      return Container(
        decoration: BoxDecoration(
          shape: shape,
          borderRadius: shape == BoxShape.circle ? null : effectiveRadius,
          color: isOverlay ? Colors.transparent : Colors.white.withValues(alpha: 0.05),
        ),
        child: PlayingOverlay(
          isPlaying: isCurrentAlbum && isPlaying,
          borderRadius:
              shape == BoxShape.circle ? 999 : effectiveRadius.topLeft.x,
          child: album.artPath != null
              ? (shape == BoxShape.circle
                  ? ClipOval(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: OptimizedImage(
                        imagePath: album.artPath,
                        fit: BoxFit.cover,
                        cacheWidth: 384,
                        placeholder: const Center(
                          child: Icon(LucideIcons.disc, size: 48, color: Colors.grey),
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: effectiveRadius,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: OptimizedImage(
                        imagePath: album.artPath,
                        fit: BoxFit.cover,
                        cacheWidth: 384,
                        placeholder: const Center(
                          child: Icon(LucideIcons.disc, size: 48, color: Colors.grey),
                        ),
                      ),
                    ))
              : const Center(
                  child: Icon(LucideIcons.disc, size: 48, color: Colors.grey),
                ),
        ),
      );
    }

    Future<void> onCardTap() async {
      final songs = await DbService.isar.songs
          .filter()
          .albumEqualTo(album.name)
          .findAll();
      ref.read(appNavigationProvider.notifier).showCollection(
            title: album.name,
            subtitle: album.artist,
            art: album.artPath,
            songs: songs,
            highlightItem: NavItem.albums,
          );
    }

    Widget cardContent;

    switch (cardStyle) {
      case CardStyle.normal:
        cardContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: buildArtwork(borderRadius: BorderRadius.circular(14)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    album.name,
                    style: AppFonts.jostStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.ts,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    album.artist ?? AppLocalizations.of(context)!.unknownArtist,
                    style: AppFonts.jostStyle(
                      fontSize: 12.ts,
                      color: Colors.white60,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
        break;

      case CardStyle.circle:
        cardContent = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: buildArtwork(shape: BoxShape.circle),
              ),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    album.name,
                    style: AppFonts.jostStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.ts,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    album.artist ?? AppLocalizations.of(context)!.unknownArtist,
                    style: AppFonts.jostStyle(
                      fontSize: 12.ts,
                      color: Colors.white60,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
        break;

      case CardStyle.card:
        final cardBg = useBlur
            ? (_isHovered
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.06))
            : (_isHovered
                ? const Color(0xFF282828)
                : const Color(0xFF181818));
        final cardBorder = useBlur
            ? Border.all(
                color: _isHovered
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1,
              )
            : null;

        Widget cardBody = AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: cardBg,
            border: cardBorder,
          ),
          padding: const EdgeInsets.fromLTRB(7, 7, 7, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: buildArtwork(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                album.name,
                style: AppFonts.jostStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.ts,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                album.artist ?? AppLocalizations.of(context)!.unknownArtist,
                style: AppFonts.jostStyle(
                  fontSize: 12.ts,
                  color: Colors.white60,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );

        cardContent = useBlur
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: cardBody,
                ),
              )
            : cardBody;
        break;

      case CardStyle.image:
        cardContent = ClipRRect(
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            fit: StackFit.expand,
            children: [
              buildArtwork(
                borderRadius: BorderRadius.zero,
                isOverlay: true,
              ),
              Positioned(
                left: -1,
                right: -1,
                top: 0,
                bottom: -2,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color.fromARGB(60, 0, 0, 0),
                        Color.fromARGB(220, 0, 0, 0),
                        Colors.black,
                        Colors.black,
                      ],
                      stops: [0.15, 0.45, 0.72, 0.88, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 6,
                child: const ColoredBox(color: Colors.black),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      album.name,
                      style: AppFonts.jostStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.ts,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      album.artist ?? AppLocalizations.of(context)!.unknownArtist,
                      style: AppFonts.jostStyle(
                        fontSize: 12.ts,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: _isHovered
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.transparent,
                    border: Border.all(
                      color: _isHovered
                          ? Colors.white.withValues(alpha: 0.22)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        break;

      case CardStyle.imageGapless:
        cardContent = FractionallySizedBox(
          widthFactor: 1.004,
          heightFactor: 1.004,
          alignment: Alignment.center,
          child: Stack(
            fit: StackFit.expand,
            children: [
              buildArtwork(
                borderRadius: BorderRadius.zero,
                isOverlay: true,
              ),
              Positioned(
                left: -1,
                right: -1,
                top: 0,
                bottom: -2,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color.fromARGB(60, 0, 0, 0),
                        Color.fromARGB(220, 0, 0, 0),
                        Colors.black,
                        Colors.black,
                      ],
                      stops: [0.15, 0.45, 0.72, 0.88, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 6,
                child: const ColoredBox(color: Colors.black),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      album.name,
                      style: AppFonts.jostStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.ts,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      album.artist ?? AppLocalizations.of(context)!.unknownArtist,
                      style: AppFonts.jostStyle(
                        fontSize: 12.ts,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  color: _isHovered
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.transparent,
                ),
              ),
            ],
          ),
        );
        break;
    }

    final BorderRadius cardRadius = cardStyle == CardStyle.imageGapless
        ? BorderRadius.zero
        : BorderRadius.circular(
            (cardStyle == CardStyle.card || cardStyle == CardStyle.image)
                ? 14
                : 18);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onSecondaryTap: () => showAlbumOptionsBottomSheet(
          context: context,
          ref: ref,
          album: album,
        ),
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.none,
          shape: RoundedRectangleBorder(borderRadius: cardRadius),
          child: InkWell(
            onTap: onCardTap,
            borderRadius: cardRadius,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: cardRadius,
                color: isSelected
                    ? const Color.fromARGB(255, 53, 53, 53).withValues(alpha: isDynamic ? 0.3 : 0.1)
                    : Colors.transparent,
                border: isSelected &&
                        cardStyle != CardStyle.imageGapless &&
                        cardStyle != CardStyle.card
                    ? Border.all(
                        color: Colors.white10.withValues(alpha: 0.1),
                        width: 1,
                      )
                    : null,
              ),
              child: cardContent,
            ),
          ),
        ),
      ),
    );
  }
}

class ArtistsGrid extends ConsumerStatefulWidget {
  const ArtistsGrid({super.key});

  @override
  ConsumerState<ArtistsGrid> createState() => _ArtistsGridState();
}

class _ArtistsGridState extends ConsumerState<ArtistsGrid> {
  late final ScrollController _scrollController = ScrollController(
    initialScrollOffset: _gridScrollOffsets['artists'] ?? 0,
    keepScrollOffset: false,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      _gridScrollOffsets['artists'] = _scrollController.offset;
    }
  }

  @override
  void dispose() {
    if (_scrollController.hasClients) {
      _gridScrollOffsets['artists'] = _scrollController.offset;
    }
    _scrollController.dispose();
    super.dispose();
  }

  List<Artist> _sort(List<Artist> artists, ArtistSortOption opt, List<Song> allSongs, bool asc) {
    final list = List<Artist>.from(artists);
    switch (opt) {
      case ArtistSortOption.name:
        list.sort((a, b) => asc
            ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
            : b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case ArtistSortOption.songCount:
        final songCounts = <String, int>{};
        for (final song in allSongs) {
          final names = <String>{};
          if (song.artist != null) names.add(song.artist!);
          if (song.albumArtist != null) names.add(song.albumArtist!);
          for (final name in names) {
            songCounts[name] = (songCounts[name] ?? 0) + 1;
          }
        }
        list.sort((a, b) {
          final diff = (songCounts[a.name] ?? 0).compareTo(songCounts[b.name] ?? 0);
          return asc ? diff : -diff;
        });
    }
    return list;
  }

  String _sortLabel(ArtistSortOption opt, AppLocalizations l10n) =>
      switch (opt) {
        ArtistSortOption.name => l10n.sortAlphabeticalAZ,
        ArtistSortOption.songCount => l10n.sortMostSongs,
      };

  void _showSortMenu(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final accentColor = Color(ref.watch(settingsProvider).accentColor);
            final currentSort = ref.watch(artistSortProvider);
            final currentAsc = ref.watch(artistSortAscendingProvider);

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
                            ref.read(artistSortAscendingProvider.notifier).state = !currentAsc;
                          },
                          icon: Icon(
                            currentAsc ? LucideIcons.arrowUpAZ : LucideIcons.arrowDownAZ,
                            size: 18,
                          ),
                          label: Text(
                            currentAsc ? l10n.ascending : l10n.descending,
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: accentColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: PremiumSection(
                          borderRadius: BorderRadius.circular(20),
                          padding: EdgeInsets.zero,
                          useExpanded: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _GridSortOption(
                                label: l10n.sortAlphabeticalAZ,
                                icon: LucideIcons.type,
                                isSelected: currentSort == ArtistSortOption.name,
                                accentColor: accentColor,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref.read(artistSortProvider.notifier).state = ArtistSortOption.name;
                                  Navigator.pop(context);
                                },
                              ),
                              const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                              _GridSortOption(
                                label: l10n.sortMostSongs,
                                icon: LucideIcons.music,
                                isSelected: currentSort == ArtistSortOption.songCount,
                                accentColor: accentColor,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref.read(artistSortProvider.notifier).state = ArtistSortOption.songCount;
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final artistsAsync = ref.watch(artistsProvider);
    final sortOpt = ref.watch(artistSortProvider);
    final sortAsc = ref.watch(artistSortAscendingProvider);
    final allSongs = ref.watch(libraryProvider.select((s) => s.songs));
    final l10n = AppLocalizations.of(context)!;

    return artistsAsync.when(
      data: (raw) {
        final artists = _sort(raw, sortOpt, allSongs, sortAsc);
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.s, 16.s, 24.s, 8.s),
              child: Row(
                children: [
                  Text(
                    '${artists.length} ${l10n.artists}',
                    style: AppFonts.jostStyle(
                      color: Colors.white54,
                      fontSize: 13.ts,
                    ),
                  ),
                  IconButton(
                    onPressed: artists.isEmpty
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(playbackProvider.notifier)
                                .playShuffledGrouped(
                                  _allArtistsGroups(ref, artists),
                                  queueName: 'All Artists',
                                );
                          },
                    icon: const Icon(LucideIcons.shuffle, size: 18),
                    tooltip: l10n.shuffleTitle,
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showSortMenu(l10n),
                    icon: const Icon(LucideIcons.arrowUpDown, size: 14),
                    label: Text(
                      _sortLabel(sortOpt, l10n),
                      style: AppFonts.jostStyle(fontSize: 13.ts),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showCardStyleMenu(context, ref, isAlbum: false),
                    icon: const Icon(LucideIcons.layoutGrid, size: 16),
                    tooltip: 'Card Style',
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAllArtistsOptions(context, ref, artists, l10n),
                    icon: const Icon(LucideIcons.moreHorizontal, size: 16),
                    tooltip: 'Options',
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRect(
                child: Builder(
                  builder: (context) {
                    final artistCardStyle = CardStyle.values[ref
                        .watch(settingsProvider.select((s) => s.artistCardStyleIndex))
                        .clamp(0, CardStyle.values.length - 1)];

                    final double maxExtent = (artistCardStyle == CardStyle.card || artistCardStyle == CardStyle.image)
                        ? 175.s
                        : 185.s;
                    final double spacing = artistCardStyle == CardStyle.imageGapless
                        ? 0
                        : ((artistCardStyle == CardStyle.card || artistCardStyle == CardStyle.image) ? 12 : 14);
                    final double aspectRatio = switch (artistCardStyle) {
                      CardStyle.normal => 0.82,
                      CardStyle.circle => 0.88,
                      CardStyle.card => 0.86,
                      CardStyle.image => 1.0,
                      CardStyle.imageGapless => 1.0,
                    };
                    final EdgeInsets padding = artistCardStyle == CardStyle.imageGapless
                        ? EdgeInsets.zero
                        : EdgeInsets.all(20.s);

                    return GridView.builder(
                      controller: _scrollController,
                      padding: padding,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: maxExtent,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                      ),
                      itemCount: artists.length,
                      itemBuilder: (context, index) => _ArtistCard(artist: artists[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const AppLoadingIndicator(),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  void _showAllArtistsOptions(
    BuildContext context,
    WidgetRef ref,
    List<Artist> artists,
    AppLocalizations l10n,
  ) {
    final groups = _allArtistsGroups(ref, artists);
    final songs = groups.expand((g) => g).toList();
    showCollectionOptionsBottomSheet(
      context: context,
      ref: ref,
      title: 'All Artists',
      subtitle: '${artists.length} ${l10n.artists} • ${songs.length} ${l10n.songs}',
      songs: songs,
      shuffleGroups: groups,
    );
  }

  /// Groups every library song per artist in a single pass. A song goes into
  /// exactly one group (its track artist, falling back to the album artist) so
  /// the Shuffle action plays each artist together with nothing duplicated.
  List<List<Song>> _allArtistsGroups(WidgetRef ref, List<Artist> artists) {
    // Use the already-loaded in-memory library instead of a blocking DB query,
    // so the menu opens instantly.
    final allSongs = ref.read(libraryProvider).songs;
    final byArtist = <String, List<Song>>{};
    for (final s in allSongs) {
      final artist = s.artist;
      if (artist != null && artist.isNotEmpty) {
        (byArtist[artist] ??= []).add(s);
        continue;
      }
      final albumArtist = s.albumArtist;
      if (albumArtist != null && albumArtist.isNotEmpty) {
        (byArtist[albumArtist] ??= []).add(s);
      }
    }
    return [
      for (final artist in artists)
        if (byArtist[artist.name] case final g? when g.isNotEmpty) g,
    ];
  }
}

void _showCardStyleMenu(BuildContext context, WidgetRef ref, {required bool isAlbum}) {
  final l10n = AppLocalizations.of(context)!;
  final currentStyleIndex = ref.read(settingsProvider.select(
    (s) => isAlbum ? s.albumCardStyleIndex : s.artistCardStyleIndex,
  ));

  final options = [
    (CardStyle.normal, 'Normal', LucideIcons.square),
    (CardStyle.circle, 'Circle', LucideIcons.circle),
    (CardStyle.card, 'Card', LucideIcons.panelTop),
    (CardStyle.image, 'Overlay Image', LucideIcons.image),
    (CardStyle.imageGapless, 'Gapless Grid', LucideIcons.layoutGrid),
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
                      '${isAlbum ? l10n.albums : l10n.artists} Card Style',
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
                        _GridSortOption(
                          label: options[i].$2,
                          icon: options[i].$3,
                          isSelected: currentStyleIndex == options[i].$1.index,
                          accentColor: accent,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            if (isAlbum) {
                              ref.read(settingsProvider.notifier).updateAlbumCardStyle(options[i].$1.index);
                            } else {
                              ref.read(settingsProvider.notifier).updateArtistCardStyle(options[i].$1.index);
                            }
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

class _ArtistCard extends ConsumerStatefulWidget {
  final Artist artist;
  const _ArtistCard({required this.artist});

  @override
  ConsumerState<_ArtistCard> createState() => _ArtistCardState();
}

class _ArtistCardState extends ConsumerState<_ArtistCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final artist = widget.artist;
    final cardStyle = CardStyle.values[ref
        .watch(settingsProvider.select((s) => s.artistCardStyleIndex))
        .clamp(0, CardStyle.values.length - 1)];
    final settings = ref.watch(settingsProvider);
    final isDynamic = settings.enableDynamicTheming;
    final useBlur = (settings.enableDynamicTheming || settings.keepBackgroundGradient) &&
        !settings.disableBlur &&
        !settings.isBatterySaverActive;
    final nav = ref.watch(appNavigationProvider);
    final isSelected =
        nav.activeItem == NavItem.collectionDetail &&
        nav.collectionTitle == artist.name;

    Widget buildArtwork({
      BorderRadius? borderRadius,
      BoxShape shape = BoxShape.rectangle,
      bool isOverlay = false,
    }) {
      final effectiveRadius = shape == BoxShape.circle
          ? BorderRadius.zero
          : (borderRadius ?? BorderRadius.circular(14));

      final isLocalImage =
          artist.artistImageUrl != null &&
          !artist.artistImageUrl!.startsWith('http');
      final isNetworkImage =
          artist.artistImageUrl != null &&
          artist.artistImageUrl!.startsWith('http');

      return Container(
        decoration: BoxDecoration(
          shape: shape,
          borderRadius: shape == BoxShape.circle ? null : effectiveRadius,
          color: isOverlay ? Colors.transparent : Colors.white.withValues(alpha: 0.05),
        ),
        child: shape == BoxShape.circle
            ? ClipOval(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: ArtistImage(
                  images: artist.artistImages,
                  imageUrl: isNetworkImage ? artist.artistImageUrl : null,
                  imagePath: isLocalImage ? artist.artistImageUrl : artist.artPath,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: const Center(
                    child: Icon(
                      LucideIcons.user,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : ClipRRect(
                borderRadius: effectiveRadius,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: ArtistImage(
                  images: artist.artistImages,
                  imageUrl: isNetworkImage ? artist.artistImageUrl : null,
                  imagePath: isLocalImage ? artist.artistImageUrl : artist.artPath,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: const Center(
                    child: Icon(
                      LucideIcons.user,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
      );
    }

    Future<void> onCardTap() async {
      final songs = await DbService.isar.songs
          .filter()
          .artistEqualTo(artist.name)
          .or()
          .albumArtistEqualTo(artist.name)
          .findAll();
      final isLocalImage =
          artist.artistImageUrl != null &&
          !artist.artistImageUrl!.startsWith('http');
      final isNetworkImage =
          artist.artistImageUrl != null &&
          artist.artistImageUrl!.startsWith('http');

      ref.read(appNavigationProvider.notifier).showCollection(
            title: artist.name,
            subtitle: AppLocalizations.of(context)!.artists,
            art: isLocalImage ? artist.artistImageUrl : artist.artPath,
            imageUrl: isNetworkImage ? artist.artistImageUrl : null,
            images: artist.artistImages,
            songs: songs,
            highlightItem: NavItem.artists,
          );
    }

    Widget cardContent;

    switch (cardStyle) {
      case CardStyle.normal:
        cardContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: buildArtwork(borderRadius: BorderRadius.circular(14)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                artist.name,
                style: AppFonts.jostStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.ts,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
        break;

      case CardStyle.circle:
        cardContent = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: buildArtwork(shape: BoxShape.circle),
              ),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                artist.name,
                style: AppFonts.jostStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.ts,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
        break;

      case CardStyle.card:
        final cardBg = useBlur
            ? (_isHovered
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.06))
            : (_isHovered
                ? const Color(0xFF282828)
                : const Color(0xFF181818));
        final cardBorder = useBlur
            ? Border.all(
                color: _isHovered
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1,
              )
            : null;

        Widget cardBody = AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: cardBg,
            border: cardBorder,
          ),
          padding: const EdgeInsets.fromLTRB(7, 7, 7, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: buildArtwork(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                artist.name,
                style: AppFonts.jostStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.ts,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );

        cardContent = useBlur
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: cardBody,
                ),
              )
            : cardBody;
        break;

      case CardStyle.image:
        cardContent = ClipRRect(
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            fit: StackFit.expand,
            children: [
              buildArtwork(
                borderRadius: BorderRadius.zero,
                isOverlay: true,
              ),
              Positioned(
                left: -1,
                right: -1,
                top: 0,
                bottom: -2,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color.fromARGB(60, 0, 0, 0),
                        Color.fromARGB(220, 0, 0, 0),
                        Colors.black,
                        Colors.black,
                      ],
                      stops: [0.15, 0.45, 0.72, 0.88, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 6,
                child: const ColoredBox(color: Colors.black),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 8,
                child: Text(
                  artist.name,
                  style: AppFonts.jostStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.ts,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: _isHovered
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.transparent,
                    border: Border.all(
                      color: _isHovered
                          ? Colors.white.withValues(alpha: 0.22)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        break;

      case CardStyle.imageGapless:
        cardContent = FractionallySizedBox(
          widthFactor: 1.004,
          heightFactor: 1.004,
          alignment: Alignment.center,
          child: Stack(
            fit: StackFit.expand,
            children: [
              buildArtwork(
                borderRadius: BorderRadius.zero,
                isOverlay: true,
              ),
              Positioned(
                left: -1,
                right: -1,
                top: 0,
                bottom: -2,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color.fromARGB(60, 0, 0, 0),
                        Color.fromARGB(220, 0, 0, 0),
                        Colors.black,
                        Colors.black,
                      ],
                      stops: [0.15, 0.45, 0.72, 0.88, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 6,
                child: const ColoredBox(color: Colors.black),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 8,
                child: Text(
                  artist.name,
                  style: AppFonts.jostStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.ts,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  color: _isHovered
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.transparent,
                ),
              ),
            ],
          ),
        );
        break;
    }

    final BorderRadius cardRadius = cardStyle == CardStyle.imageGapless
        ? BorderRadius.zero
        : BorderRadius.circular(
            (cardStyle == CardStyle.card || cardStyle == CardStyle.image)
                ? 14
                : 18);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onSecondaryTap: () => showArtistOptionsBottomSheet(
          context: context,
          ref: ref,
          artist: artist,
        ),
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.none,
          shape: RoundedRectangleBorder(borderRadius: cardRadius),
          child: InkWell(
            onTap: onCardTap,
            borderRadius: cardRadius,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: cardRadius,
                color: isSelected
                    ? const Color.fromARGB(255, 53, 53, 53).withValues(alpha: isDynamic ? 0.3 : 0.1)
                    : Colors.transparent,
                border: isSelected &&
                        cardStyle != CardStyle.imageGapless &&
                        cardStyle != CardStyle.card
                    ? Border.all(
                        color: Colors.white10.withValues(alpha: 0.1),
                        width: 1,
                      )
                    : null,
              ),
              child: cardContent,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared helper for context menu items.
Widget _menuItem(IconData icon, String label) => Row(
  children: [
    Icon(icon, size: 16, color: Colors.white70),
    const SizedBox(width: 12),
    Text(label, style: const TextStyle(color: Colors.white)),
  ],
);

/// Reusable sort option row used in the sort bottom sheet.
class _SortItem<T> extends ConsumerWidget {
  final String label;
  final T value;
  final StateProvider<T> provider;
  const _SortItem({
    required this.label,
    required this.value,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(provider);
    final isSelected = current == value;
    final accentColor = Color(ref.read(settingsProvider).accentColor);
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(provider.notifier).state = value;
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppFonts.jostStyle(
                color: isSelected ? accentColor : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.check, color: accentColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class GenresGrid extends ConsumerWidget {
  const GenresGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(libraryProvider).songs;
    final l10n = AppLocalizations.of(context)!;
    final genresMap = <String, List<Song>>{};
    for (var song in songs) {
      final genre = song.genre ?? l10n.unknown;
      genresMap.putIfAbsent(genre, () => []).add(song);
    }

    final genres = genresMap.keys.toList()..sort();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double minCardWidth = 280.0;
        final int crossAxisCount = (maxWidth / minCardWidth).floor().clamp(
          2,
          6,
        );
        final double totalPadding = 48.0;
        final double totalSpacing = (crossAxisCount - 1) * 20.0;
        final double cardWidth =
            (maxWidth - totalPadding - totalSpacing) / crossAxisCount;

        return ClipRect(
          child: GridView.builder(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: 200,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.35,
            ),
            itemCount: genres.length,
            itemBuilder: (context, index) {
              final genre = genres[index];
              final genreSongs = genresMap[genre]!;

              final int hash = genre.hashCode;
              final double hue = (hash.abs() % 360).toDouble();
              final Color startColor = HSLColor.fromAHSL(
                1.0,
                hue,
                0.70,
                0.35,
              ).toColor();
              final Color endColor = HSLColor.fromAHSL(
                1.0,
                (hue + 45) % 360,
                0.80,
                0.18,
              ).toColor();

              final firstSongWithArt = genreSongs.firstWhere(
                (s) => s.artPath != null,
                orElse: () => genreSongs.first,
              );

              final double artSize = (cardWidth * 0.40).clamp(90.0, 170.0);

              return Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [startColor, endColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: InkWell(
                    onTap: () {
                      final firstWithArt = genreSongs.firstWhere(
                        (s) => s.artPath != null,
                        orElse: () => genreSongs.first,
                      );
                      ref
                          .read(appNavigationProvider.notifier)
                          .showCollection(
                            title: genre,
                            subtitle: l10n.genre,
                            art: firstWithArt.artPath,
                            songs: genreSongs,
                            highlightItem: NavItem.genres,
                          );
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                    children: [
                      if (firstSongWithArt.artPath != null)
                        Positioned(
                          bottom: -artSize * 0.2,
                          right: -artSize * 0.2,
                          child: Transform.rotate(
                            angle: 0.25,
                            child: Container(
                              width: artSize,
                              height: artSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: OptimizedImage(
                                  imagePath: firstSongWithArt.artPath,
                                  width: artSize,
                                  height: artSize,
                                  cacheWidth: 256,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Positioned(
                          bottom: -artSize * 0.17,
                          right: -artSize * 0.17,
                          child: Transform.rotate(
                            angle: 0.25,
                            child: Container(
                              width: artSize,
                              height: artSize,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                LucideIcons.music,
                                size: artSize * 0.47,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 16,
                        top: 16,
                        bottom: 16,
                        right: artSize + 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              genre,
                              style: AppFonts.jostStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${genreSongs.length} ${l10n.songs}',
                              style: AppFonts.jostStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _GridSortOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _GridSortOption({
    required this.label,
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
