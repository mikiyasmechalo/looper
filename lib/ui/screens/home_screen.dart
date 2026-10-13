import 'dart:async';
import 'dart:io';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/core/app_icons.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/ui/widgets/app_loading_indicator.dart';
import 'package:looper_player/ui/widgets/color_maper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:animations/animations.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:window_manager/window_manager.dart';
import '../widgets/player_bar.dart';
import '../widgets/expanded_player.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/features/library/presentation/library_grids.dart';
import 'package:looper_player/ui/screens/home_dashboard.dart';
import 'package:looper_player/features/playlists/presentation/playlist_view.dart';
import 'package:looper_player/features/search/presentation/search_view.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/library/presentation/smart_views.dart';
import 'package:looper_player/ui/screens/settings_view.dart';
import 'package:looper_player/ui/screens/welcome_screen.dart';
import 'package:looper_player/ui/widgets/folder_picker_helper.dart';
import 'package:looper_player/features/analyze/presentation/screens/looper_analyze_view.dart';

import 'package:looper_player/ui/widgets/collection_detail_view.dart';
import 'package:looper_player/features/playback/presentation/lyrics_view.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/playback/presentation/lyrics_notifier.dart';
import 'package:looper_player/features/library/presentation/queue_view.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/core/providers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import '../widgets/global_search_bar.dart';
import 'package:looper_player/features/playback/presentation/widgets/overlay_lyrics_widget.dart';
import 'package:looper_player/core/update_service.dart';
import 'package:looper_player/core/memory_service.dart';

import 'android/android_main_screen.dart';
import 'android/widgets/empty_library_view.dart';
import 'package:looper_player/features/library/presentation/folder_browser_view.dart';
import 'package:looper_player/ui/widgets/mini_player_standard.dart';
import 'package:looper_player/ui/widgets/mini_player_corner_widget.dart';
import 'package:looper_player/core/single_instance_service.dart';
import 'package:looper_player/core/window_state_service.dart';
import 'package:looper_player/core/global_hotkeys_service.dart';
import 'package:looper_player/core/windows_taskbar_service.dart';
import 'package:looper_player/features/playback/presentation/mini_player_overlay_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isDraggingOver = false;
  Timer? _enqueueToastTimer;
  int _pendingEnqueueCount = 0;

  void _showEnqueueToast(int count) {
    _pendingEnqueueCount += count;
    _enqueueToastTimer?.cancel();
    _enqueueToastTimer = Timer(const Duration(milliseconds: 250), () {
      if (!mounted || _pendingEnqueueCount <= 0) return;
      final total = _pendingEnqueueCount;
      _pendingEnqueueCount = 0;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            total == 1
                ? 'Added 1 song to queue'
                : 'Added $total songs to queue',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  void dispose() {
    _enqueueToastTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Register listener for runtime file associations & context menu actions
    SingleInstanceService.setListener((action, files) {
      if (!mounted || files.isEmpty) return;
      final notifier = ref.read(playbackProvider.notifier);
      if (action == 'enqueue') {
        notifier.enqueueFromFiles(files);
        _showEnqueueToast(files.length);
      } else {
        notifier.playFromFile(files.first);
        if (files.length > 1) {
          notifier.enqueueFromFiles(files.sublist(1));
          _showEnqueueToast(files.length - 1);
        }
      }
    });

    // Trigger library scan for saved folders on startup
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Wait for settings to load from DB
      await ref.read(settingsProvider.notifier).initialization;
      final settings = ref.read(settingsProvider);

      // Initialize System-Wide Global Hotkeys (Desktop)
      await ref.read(globalHotkeysServiceProvider).init();

      // Initialize Windows Taskbar Thumbnail Toolbar Controls
      ref.read(windowsTaskbarServiceProvider).init();

      // Check for application updates on GitHub
      UpdateService.checkForUpdates(ref: ref, context: context);

      // Release transient startup memory and start background periodic sweep
      Future.delayed(const Duration(seconds: 4), () {
        MemoryService.trimWorkingSet();
        MemoryService.startPeriodicTrimming();
      });

      // Handle CLI / Startup arguments (e.g. Open With, Add to Queue)
      final startupArgs = ref.read(startupArgsProvider);
      final parsed = SingleInstanceService.parseArgs(startupArgs);
      final List<String> files = List<String>.from(parsed['files'] as List);
      final String action = parsed['action'] as String;

      if (files.isNotEmpty) {
        final notifier = ref.read(playbackProvider.notifier);
        if (action == 'enqueue') {
          await notifier.enqueueFromFiles(files);
        } else {
          await notifier.playFromFile(files.first);
          if (files.length > 1) {
            await notifier.enqueueFromFiles(files.sublist(1));
          }
        }
        if (settings.libraryFolders.isNotEmpty) {
          ref
              .read(libraryProvider.notifier)
              .scanSavedFolders(showVisualIndicator: false);
        }
        return;
      }

      // Always trigger background scan for saved/discovered folders on startup
      ref
          .read(libraryProvider.notifier)
          .scanSavedFolders(showVisualIndicator: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return const AndroidMainScreen();
    }

    WindowStateService.instance.attach(ref);

    final library = ref.watch(libraryProvider);
    final nav = ref.watch(appNavigationProvider);
    final currentSongArtPath = ref.watch(
      playbackProvider.select((s) => s.currentSong?.artPath),
    );
    final settings = ref.watch(settingsProvider);
    final isDynamic = settings.enableDynamicTheming;
    final l10n = AppLocalizations.of(context)!;

    // Ensure lyrics pre-fetching is active
    ref.watch(lyricsProvider);

    final isSetupComplete = ref.watch(welcomeBypassedProvider);
    final bool showWelcome = !isSetupComplete;
    // Only below this width does the sidebar collapse into a drawer; above it
    // it always stays visible (just with reduced padding when compact).
    final bool isNarrow = MediaQuery.of(context).size.width < 560;

    final isOverlayMode = ref.watch(overlayModeProvider);

    if (isOverlayMode) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: OverlayLyricsWidget(),
      );
    }

    final miniPlayerMode = ref.watch(miniPlayerModeProvider);
    if (miniPlayerMode == MiniPlayerMode.miniPlayer) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: StandardMiniPlayer(),
      );
    }
    if (miniPlayerMode == MiniPlayerMode.cornerWidget) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: CornerWidgetPlayer(),
      );
    }

    final bool hasBgLayer =
        settings.enableDynamicTheming || settings.keepBackgroundGradient;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: isNarrow
          ? Drawer(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: Sidebar(l10n: l10n),
              ),
            )
          : null,
      body: DropTarget(
        onDragEntered: (detail) {
          setState(() => _isDraggingOver = true);
        },
        onDragExited: (detail) {
          setState(() => _isDraggingOver = false);
        },
        onDragDone: (detail) async {
          setState(() => _isDraggingOver = false);
          final rawPaths = detail.files.map((f) => f.path).toList();
          final supportedExtensions = {
            '.mp3', '.flac', '.wav', '.m4a', '.ogg', '.opus',
            '.aac', '.alac', '.wma', '.aiff', '.ape',
          };
          final audioPaths = rawPaths.where((p) {
            final lower = p.toLowerCase();
            return supportedExtensions.any((ext) => lower.endsWith(ext));
          }).toList();

          if (audioPaths.isEmpty) return;

          final notifier = ref.read(playbackProvider.notifier);
          if (audioPaths.length == 1) {
            await notifier.playFromFile(audioPaths.first);
          } else {
            await notifier.playFromFiles(audioPaths);
          }
        },
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
            // Solid Base Layer to guarantee 100% opacity against the OS desktop
            Positioned.fill(
              child: ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),

            // Global Background Art / persistent gradient
            if (!showWelcome) ...[
              if (currentSongArtPath != null && settings.enableDynamicTheming) ...[
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: _DesktopBlurredBackgroundArt(
                      key: ValueKey(currentSongArtPath),
                      artPath: currentSongArtPath,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.78),
                  ),
                ),
              ] else if (settings.keepBackgroundGradient) ...[
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.5,
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.18),
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ],

            Positioned.fill(
              child: Column(
                children: [
                  // Custom Title Bar always at the top
                  SizedBox(height: 30, child: CustomTitleBar(showMenu: isNarrow)),
                Expanded(
                  child: showWelcome
                      ? const WelcomeScreen()
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final bool isNarrowLayout =
                                constraints.maxWidth < 560;

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Sidebar - hidden only on very narrow screens
                                if (!isNarrowLayout)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOutCubic,
                                    clipBehavior: Clip.hardEdge,
                                    width: (constraints.maxWidth < 1000
                                            ? 200
                                            : 240)
                                        .s,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.01),
                                      border: Border(
                                        right: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant
                                              .withValues(alpha: 0.2),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Sidebar(l10n: l10n),
                                    ),
                                  ),

                                 // Main Content Area
                                 Expanded(
                                   child: Column(
                                     crossAxisAlignment:
                                         CrossAxisAlignment.start,
                                     children: [
                                       if (nav.activeItem != NavItem.lyrics &&
                                           nav.activeItem != NavItem.analyze)
                                         Padding(
                                           padding: const EdgeInsets.symmetric(
                                             horizontal: 24,
                                           ),
                                           child: Row(
                                             children: [
                                               AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  curve: Curves.easeInOutCubic,
                                                  width: nav.history.isEmpty
                                                      ? 0
                                                      : 120,
                                                  child: ClipRect(
                                                    child: AnimatedScale(
                                                      scale: nav.history.isEmpty
                                                          ? 0.0
                                                          : 1.0,
                                                      duration: const Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      curve: Curves.easeOutBack,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              right: 16,
                                                            ),
                                                        child: _HeaderButton(
                                                          onTap: () => ref
                                                              .read(
                                                                appNavigationProvider
                                                                    .notifier,
                                                              )
                                                              .goBack(),
                                                          icon: LucideIcons
                                                              .arrowLeft,
                                                          label: 'Back',
                                                          isDynamic: isDynamic,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 6,
                                                  child: Align(
                                                    alignment: Alignment
                                                        .centerLeft,
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                        maxWidth: 720,
                                                      ),
                                                      child: GlobalSearchBar(),
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                if (nav.activeItem == NavItem.home) ...[
                                                  _HeaderButton(
                                                    onTap: () {
                                                      ref
                                                          .read(
                                                            appNavigationProvider
                                                                .notifier,
                                                          )
                                                          .setItem(
                                                            NavItem.analyze,
                                                          );
                                                    },
                                                    icon: LucideIcons.barChart2,
                                                    label: 'Stats',
                                                    isDynamic: isDynamic,
                                                  ),
                                                  const SizedBox(width: 8),
                                                ],
                                                _HeaderButton(
                                                  onTap: () {
                                                    FolderPickerHelper.pickFolder(
                                                      context,
                                                      ref,
                                                    );
                                                  },
                                                  icon: LucideIcons.plus,
                                                  label: 'Add Folder',
                                                  isDynamic: isDynamic,
                                                ),
                                              ],
                                            ),
                                          ),
                                        Expanded(
                                          child: _buildMainContent(
                                            nav,
                                            library,
                                            context,
                                            l10n,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                ),
                // Global Player Bar always at the bottom
                if (!nav.isPlayerExpanded)
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (Platform.isAndroid || Platform.isIOS) {
                        if (details.delta.dy < -10) {
                          ref
                              .read(appNavigationProvider.notifier)
                              .setPlayerExpansion(true);
                        }
                      }
                    },
                    child: const PlayerBar(),
                  ),
              ],
            ),
          ),
            // Expanded Player View
            if (nav.isPlayerExpanded)
              Positioned.fill(
                child: WillPopScope(
                  onWillPop: () async {
                    ref
                        .read(appNavigationProvider.notifier)
                        .setPlayerExpansion(false);
                    return false;
                  },
                  child: const ExpandedPlayer(),
                ),
              ),

            // Drag & Drop visual overlay
            if (_isDraggingOver)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.75),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.35),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.playCircle,
                            size: 52,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Drop to Play in Looper',
                            style: AppFonts.jostStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildMainContent(
    NavigationState nav,
    LibraryState library,
    BuildContext context,
    AppLocalizations l10n,
  ) {
    if (!library.isInitialized ||
        (library.isScanning && library.songs.isEmpty)) {
      return const AppLoadingIndicator();
    }

    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return FadeThroughTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          fillColor: Colors.transparent,
          child: child,
        );
      },
      child: _getWidgetForNavItem(nav, library, context, l10n),
    );
  }

  Widget _getWidgetForNavItem(
    NavigationState nav,
    LibraryState library,
    BuildContext context,
    AppLocalizations l10n,
  ) {
    switch (nav.activeItem) {
      case NavItem.search:
        return const SearchView(key: ValueKey('search'));
      case NavItem.albums:
        return const AlbumsGrid(key: ValueKey('albums'));
      case NavItem.artists:
        return const ArtistsGrid(key: ValueKey('artists'));
      case NavItem.playlists:
        return const PlaylistView(key: ValueKey('playlists'));
      case NavItem.favorites:
        return const FavoritesView(key: ValueKey('favorites'));
      case NavItem.recentlyPlayed:
      case NavItem.history:
        return const RecentlyPlayedView(key: ValueKey('recentlyPlayed'));
      case NavItem.lyrics:
        return const LyricsView(key: ValueKey('lyrics'));
      case NavItem.settings:
        return const SettingsView(key: ValueKey('settings'));
      case NavItem.collectionDetail:
        return CollectionDetailView(
          key: ValueKey('collection_${nav.collectionTitle}'),
          title: nav.collectionTitle ?? 'Unknown',
          subtitle: nav.collectionSubtitle,
          artPath: nav.collectionArt,
          imageUrl: nav.collectionImageUrl,
          images: nav.collectionImages,
          songs: nav.collectionSongs,
          playlist: nav.activePlaylist,
        );
      case NavItem.queue:
        return const QueueView(key: ValueKey('queue'));
      case NavItem.songs:
        return library.songs.isEmpty
            ? _buildEmptyState(context, l10n)
            : SongsList(
                songs: library.songs,
                showShuffleButton: true,
                key: const ValueKey('songs'),
              );
      case NavItem.genres:
        return const GenresGrid(key: ValueKey('genres'));
      case NavItem.folders:
        return const FolderBrowserView(key: ValueKey('folders'));
      case NavItem.analyze:
        return const LooperAnalyzeView(key: ValueKey('analyze'));
      case NavItem.home:
      default:
        return library.songs.isEmpty
            ? _buildEmptyState(context, l10n)
            : const HomeDashboard(key: ValueKey('home'));
    }
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return EmptyLibraryView(title: l10n.noSongsFound);
  }
}

class CustomTitleBar extends StatelessWidget {
  final bool showMenu;
  const CustomTitleBar({super.key, this.showMenu = false});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      return const SizedBox.shrink();
    }
    return WindowCaption(
      brightness: Brightness.dark,
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          if (showMenu)
            IconButton(
              icon: const Icon(LucideIcons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
        ],
      ),
    );
  }
}

class Sidebar extends ConsumerWidget {
  final AppLocalizations l10n;
  const Sidebar({super.key, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(appNavigationProvider);
    final settings = ref.watch(settingsProvider);
    final activeItem = nav.activeItem;
    final highlightItem = nav.highlightItem;

    final currentSong = ref.watch(playbackProvider.select((s) => s.currentSong));

    void navigateTo(NavItem item) {
      if (item != NavItem.search) {
        ref.read(searchQueryProvider.notifier).state = '';
      }
      ref.read(appNavigationProvider.notifier).setPlayerExpansion(false);
      ref.read(appNavigationProvider.notifier).setItem(item);
      if (Scaffold.of(context).isDrawerOpen) {
        Navigator.of(context).pop();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - 32).clamp(
                  0.0,
                  double.infinity,
                ),
              ), // -padding
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 42,
                            child: SvgPicture.asset(
                              'assets/main_logo_transparent.svg',
                              fit: BoxFit.contain,
                              colorMapper: AccentColorMapper(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SidebarItem(
                      customIcon: AppIcons.home,
                      label: 'Home',
                      isSelected:
                          activeItem == NavItem.home ||
                          highlightItem == NavItem.home,
                      onTap: () => navigateTo(NavItem.home),
                    ),
                    if (settings.showSidebarNowPlaying)
                      _SidebarItem(
                        icon: LucideIcons.headphones,
                        label: l10n.nowPlaying,
                        isSelected: nav.isPlayerExpanded && currentSong != null,
                        onTap: () {
                          if (currentSong != null) {
                            ref
                                .read(appNavigationProvider.notifier)
                                .setPlayerExpansion(true);
                          } else {
                            navigateTo(NavItem.queue);
                          }
                          if (Scaffold.of(context).isDrawerOpen) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    _SidebarItem(
                      customIcon: AppIcons.songs,
                      label: l10n.songs,
                      isSelected:
                          activeItem == NavItem.songs ||
                          highlightItem == NavItem.songs,
                      onTap: () => navigateTo(NavItem.songs),
                    ),
                    if (settings.showSidebarAlbums)
                      _SidebarItem(
                        icon: LucideIcons.disc,
                        label: l10n.albums,
                        isSelected:
                            activeItem == NavItem.albums ||
                            highlightItem == NavItem.albums,
                        onTap: () => navigateTo(NavItem.albums),
                      ),
                    if (settings.showSidebarArtists)
                      _SidebarItem(
                        icon: LucideIcons.mic2,
                        label: l10n.artists,
                        isSelected:
                            activeItem == NavItem.artists ||
                            highlightItem == NavItem.artists,
                        onTap: () => navigateTo(NavItem.artists),
                      ),
                    if (settings.showSidebarPlaylists)
                      _SidebarItem(
                        customIcon: AppIcons.library,
                        label: l10n.playlists,
                        isSelected:
                            activeItem == NavItem.playlists ||
                            highlightItem == NavItem.playlists,
                        onTap: () => navigateTo(NavItem.playlists),
                      ),
                    if (settings.showSidebarFolders)
                      _SidebarItem(
                        icon: LucideIcons.folder,
                        label: 'Folders',
                        isSelected:
                            activeItem == NavItem.folders ||
                            highlightItem == NavItem.folders,
                        onTap: () => navigateTo(NavItem.folders),
                      ),
                    if (settings.showSidebarRecentlyPlayed)
                      _SidebarItem(
                        icon: LucideIcons.clock,
                        label: 'Recently Played',
                        isSelected:
                            activeItem == NavItem.recentlyPlayed ||
                            highlightItem == NavItem.recentlyPlayed,
                        onTap: () => navigateTo(NavItem.recentlyPlayed),
                      ),
                    if (settings.showSidebarFavorites)
                      _SidebarItem(
                        customIcon: AppIcons.heart,
                        label: 'Favorites',
                        isSelected:
                            activeItem == NavItem.favorites ||
                            highlightItem == NavItem.favorites,
                        onTap: () => navigateTo(NavItem.favorites),
                      ),
                    _SidebarItem(
                      icon: LucideIcons.listOrdered,
                      label: l10n.playQueue,
                      isSelected:
                          activeItem == NavItem.queue ||
                          highlightItem == NavItem.queue,
                      onTap: () => navigateTo(NavItem.queue),
                    ),
                    if (settings.showSidebarGenres)
                      _SidebarItem(
                        icon: LucideIcons.radio,
                        label: l10n.genres,
                        isSelected:
                            activeItem == NavItem.genres ||
                            highlightItem == NavItem.genres,
                        onTap: () => navigateTo(NavItem.genres),
                      ),
                    if (settings.showSidebarAnalyze)
                      _SidebarItem(
                        icon: LucideIcons.barChart2,
                        label: 'Analyze',
                        isSelected:
                            activeItem == NavItem.analyze ||
                            highlightItem == NavItem.analyze,
                        onTap: () => navigateTo(NavItem.analyze),
                      ),
                    _SidebarItem(
                      customIcon: AppIcons.settings,
                      label: l10n.settings,
                      isSelected:
                          activeItem == NavItem.settings ||
                          highlightItem == NavItem.settings,
                      onTap: () => navigateTo(NavItem.settings),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      color: Colors.white10,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final bool isDynamic;

  const _HeaderButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.isDynamic,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 55.s,
        padding: EdgeInsets.symmetric(horizontal: 20.s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color.fromARGB(
            255,
            53,
            53,
            53,
          ).withValues(alpha: isDynamic ? 0.3 : 0.1),
          border: Border.all(
            color: Colors.white10.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          clipBehavior: Clip.hardEdge,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon == LucideIcons.arrowLeft)
                SvgPicture.asset(
                  AppIcons.back,
                  width: AppIcons.headerIcon.s,
                  height: AppIcons.headerIcon.s,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                )
              else
                Icon(icon, size: AppIcons.headerIcon.s, color: Colors.white),
              SizedBox(width: 10.s),
              Flexible(
                child: Text(
                  label,
                  style: AppFonts.jostStyle(
                    color: Colors.white,
                    fontSize: 14.ts,
                    fontWeight: FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData? icon;
  final String? customIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    this.icon,
    this.customIcon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color selectedColor = colorScheme.primary;
    final Color unselectedColor = Colors.white.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: customIcon != null
              ? SvgPicture.asset(
                  customIcon!,
                  width: AppIcons.sidebarIcon.s,
                  height: AppIcons.sidebarIcon.s,
                  colorFilter: ColorFilter.mode(
                    isSelected ? selectedColor : unselectedColor,
                    BlendMode.srcIn,
                  ),
                )
              : Icon(
                  icon,
                  size: AppIcons.sidebarIcon.s,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
          title: Text(
            label,
            style: AppFonts.jostStyle(
              fontSize: 14.ts,
              color: isSelected ? selectedColor : unselectedColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          dense: true,
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _DesktopBlurredBackgroundArt extends StatelessWidget {
  final String artPath;
  const _DesktopBlurredBackgroundArt({required this.artPath, super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: 18.0,
            sigmaY: 18.0,
          ),
          child: Image.file(
            File(artPath),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            filterQuality: FilterQuality.low,
            cacheWidth: 64,
            cacheHeight: 64,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
