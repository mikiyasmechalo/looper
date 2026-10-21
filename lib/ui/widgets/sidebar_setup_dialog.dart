import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/app_fonts.dart';
import '../../core/app_icons.dart';
import '../../core/ui_utils.dart';
import '../../features/settings/presentation/settings_notifier.dart';

class SidebarSetupDialog extends ConsumerStatefulWidget {
  const SidebarSetupDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SidebarSetupDialog(),
    );
  }

  @override
  ConsumerState<SidebarSetupDialog> createState() => _SidebarSetupDialogState();
}

class _SidebarSetupDialogState extends ConsumerState<SidebarSetupDialog> {
  int _activeTab = 0; // 0: Sidebar, 1: Home Screen

  // Sidebar items
  late bool _nowPlaying;
  late bool _songs;
  late bool _albums;
  late bool _artists;
  late bool _playlists;
  late bool _folders;
  late bool _recentlyPlayed;
  late bool _favorites;
  late bool _queue;
  late bool _genres;
  late bool _lyrics;
  late bool _analyze;

  // Home Screen sections
  late bool _homeRecentlyPlayed;
  late bool _homeQuickPicks;
  late bool _homeTopSongs;
  late bool _homeNewlyAdded;
  late bool _homeRediscover;
  late bool _homeArtists;
  late bool _homeAlbums;
  late bool _homeGenres;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _nowPlaying = s.showSidebarNowPlaying;
    _songs = s.showSidebarSongs;
    _albums = s.showSidebarAlbums;
    _artists = s.showSidebarArtists;
    _playlists = s.showSidebarPlaylists;
    _folders = s.showSidebarFolders;
    _recentlyPlayed = s.showSidebarRecentlyPlayed;
    _favorites = s.showSidebarFavorites;
    _queue = s.showSidebarQueue;
    _genres = s.showSidebarGenres;
    _lyrics = s.showSidebarLyrics;
    _analyze = s.showSidebarAnalyze;

    _homeRecentlyPlayed = s.showHomeRecentlyPlayed;
    _homeQuickPicks = s.showHomeQuickPicks;
    _homeTopSongs = s.showHomeTopSongs;
    _homeNewlyAdded = s.showHomeNewlyAdded;
    _homeRediscover = s.showHomeRediscover;
    _homeArtists = s.showHomeArtists;
    _homeAlbums = s.showHomeAlbums;
    _homeGenres = s.showHomeGenres;
  }

  int get _enabledHomeCount {
    int count = 0;
    if (_homeRecentlyPlayed) count++;
    if (_homeQuickPicks) count++;
    if (_homeTopSongs) count++;
    if (_homeNewlyAdded) count++;
    if (_homeRediscover) count++;
    if (_homeArtists) count++;
    if (_homeAlbums) count++;
    if (_homeGenres) count++;
    return count;
  }

  void _toggleHomeSection(String section, bool value) {
    if (!value && _enabledHomeCount <= 2) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least 2 homepage sections must remain enabled.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      switch (section) {
        case 'recently_played':
          _homeRecentlyPlayed = value;
          break;
        case 'quick_picks':
          _homeQuickPicks = value;
          break;
        case 'top_songs':
          _homeTopSongs = value;
          break;
        case 'newly_added':
          _homeNewlyAdded = value;
          break;
        case 'rediscover':
          _homeRediscover = value;
          break;
        case 'artists':
          _homeArtists = value;
          break;
        case 'albums':
          _homeAlbums = value;
          break;
        case 'genres':
          _homeGenres = value;
          break;
      }
    });
  }

  Future<void> _saveAndClose() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.updateShowSidebarNowPlaying(_nowPlaying);
    await notifier.updateShowSidebarSongs(_songs);
    await notifier.updateShowSidebarAlbums(_albums);
    await notifier.updateShowSidebarArtists(_artists);
    await notifier.updateShowSidebarPlaylists(_playlists);
    await notifier.updateShowSidebarFolders(_folders);
    await notifier.updateShowSidebarRecentlyPlayed(_recentlyPlayed);
    await notifier.updateShowSidebarFavorites(_favorites);
    await notifier.updateShowSidebarQueue(_queue);
    await notifier.updateShowSidebarGenres(_genres);
    await notifier.updateShowSidebarLyrics(_lyrics);
    await notifier.updateShowSidebarAnalyze(_analyze);

    await notifier.updateShowHomeRecentlyPlayed(_homeRecentlyPlayed);
    await notifier.updateShowHomeQuickPicks(_homeQuickPicks);
    await notifier.updateShowHomeTopSongs(_homeTopSongs);
    await notifier.updateShowHomeNewlyAdded(_homeNewlyAdded);
    await notifier.updateShowHomeRediscover(_homeRediscover);
    await notifier.updateShowHomeArtists(_homeArtists);
    await notifier.updateShowHomeAlbums(_homeAlbums);
    await notifier.updateShowHomeGenres(_homeGenres);

    await notifier.updateHasCompletedSidebarSetup(true);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _selectAll(bool select) {
    setState(() {
      if (_activeTab == 0) {
        _nowPlaying = select;
        _songs = select;
        _albums = select;
        _artists = select;
        _playlists = select;
        _folders = select;
        _recentlyPlayed = select;
        _favorites = select;
        _queue = select;
        _genres = select;
        _lyrics = select;
        _analyze = select;
      } else {
        if (select) {
          _homeRecentlyPlayed = true;
          _homeQuickPicks = true;
          _homeTopSongs = true;
          _homeNewlyAdded = true;
          _homeRediscover = true;
          _homeArtists = true;
          _homeAlbums = true;
          _homeGenres = true;
        } else {
          // Keep at least 2 enabled
          _homeRecentlyPlayed = true;
          _homeQuickPicks = true;
          _homeTopSongs = false;
          _homeNewlyAdded = false;
          _homeRediscover = false;
          _homeArtists = false;
          _homeAlbums = false;
          _homeGenres = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: const Color(0xFF18181B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.layoutGrid,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customize Looper',
                          style: AppFonts.jostStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _activeTab == 0
                              ? 'Choose which items to display in your navigation sidebar.'
                              : 'Choose which sections to display on your Home screen (min 2).',
                          style: AppFonts.jostStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Tab Selector
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _activeTab = 0),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeTab == 0
                                ? colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.panelLeft,
                                size: 16,
                                color: _activeTab == 0
                                    ? Colors.white
                                    : Colors.white60,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Sidebar Items',
                                style: AppFonts.jostStyle(
                                  fontSize: 13,
                                  fontWeight: _activeTab == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _activeTab == 0
                                      ? Colors.white
                                      : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _activeTab = 1),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeTab == 1
                                ? colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.layoutDashboard,
                                size: 16,
                                color: _activeTab == 1
                                    ? Colors.white
                                    : Colors.white60,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Home Sections',
                                style: AppFonts.jostStyle(
                                  fontSize: 13,
                                  fontWeight: _activeTab == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _activeTab == 1
                                      ? Colors.white
                                      : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _activeTab == 0
                        ? 'Sidebar navigation bar'
                        : 'Home screen sections ($_enabledHomeCount enabled)',
                    style: AppFonts.jostStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _selectAll(true),
                        child: Text(
                          'Select All',
                          style: AppFonts.jostStyle(
                            fontSize: 12,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () => _selectAll(false),
                        child: Text(
                          'Deselect All',
                          style: AppFonts.jostStyle(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 8),
              Expanded(
                child: _activeTab == 0
                    ? _buildSidebarList()
                    : _buildHomeSectionsList(),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _saveAndClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save Preferences',
                      style: AppFonts.jostStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarList() {
    return ListView(
      children: [
        _buildItem(
          label: 'Now Playing',
          subtitle: 'Expand now playing song anytime',
          icon: LucideIcons.headphones,
          value: _nowPlaying,
          onChanged: (v) => setState(() => _nowPlaying = v),
        ),
        _buildItem(
          label: 'Songs',
          subtitle: 'Browse all tracks in your library',
          customIcon: AppIcons.songs,
          value: _songs,
          onChanged: (v) => setState(() => _songs = v),
        ),
        _buildItem(
          label: 'Albums',
          subtitle: 'View library sorted by album collections',
          icon: LucideIcons.disc,
          value: _albums,
          onChanged: (v) => setState(() => _albums = v),
        ),
        _buildItem(
          label: 'Artists',
          subtitle: 'Browse music categorized by artists',
          icon: LucideIcons.mic2,
          value: _artists,
          onChanged: (v) => setState(() => _artists = v),
        ),
        _buildItem(
          label: 'Playlists',
          subtitle: 'Custom user playlists & smart playlists',
          customIcon: AppIcons.library,
          value: _playlists,
          onChanged: (v) => setState(() => _playlists = v),
        ),
        _buildItem(
          label: 'Folders',
          subtitle: 'Directory file browser of your library paths',
          icon: LucideIcons.folder,
          value: _folders,
          onChanged: (v) => setState(() => _folders = v),
        ),
        _buildItem(
          label: 'Recently Played',
          subtitle: 'Fast access to your recent listen history',
          icon: LucideIcons.clock,
          value: _recentlyPlayed,
          onChanged: (v) => setState(() => _recentlyPlayed = v),
        ),
        _buildItem(
          label: 'Favorites',
          subtitle: 'All your liked and starred songs',
          customIcon: AppIcons.heart,
          value: _favorites,
          onChanged: (v) => setState(() => _favorites = v),
        ),
        _buildItem(
          label: 'Play Queue',
          subtitle: 'Up next tracks and current playlist queue',
          icon: LucideIcons.listOrdered,
          value: _queue,
          onChanged: (v) => setState(() => _queue = v),
        ),
        _buildItem(
          label: 'Genres',
          subtitle: 'Explore music grouped by musical genres',
          icon: LucideIcons.radio,
          value: _genres,
          onChanged: (v) => setState(() => _genres = v),
        ),
        _buildItem(
          label: 'Lyrics',
          subtitle: 'Dedicated full lyrics synchronized view',
          customIcon: AppIcons.lyrics,
          value: _lyrics,
          onChanged: (v) => setState(() => _lyrics = v),
        ),
        _buildItem(
          label: 'Stats & Analyze',
          subtitle: 'Detailed listening habits, audio frequency & wrapped',
          icon: LucideIcons.barChart2,
          value: _analyze,
          onChanged: (v) => setState(() => _analyze = v),
        ),
      ],
    );
  }

  Widget _buildHomeSectionsList() {
    return ListView(
      children: [
        _buildItem(
          label: 'Recently Played',
          subtitle: 'Horizontal reel of recently played songs',
          icon: LucideIcons.clock,
          value: _homeRecentlyPlayed,
          onChanged: (v) => _toggleHomeSection('recently_played', v),
        ),
        _buildItem(
          label: 'Quick Picks',
          subtitle: 'Tailored dynamic mix grid based on your history',
          icon: LucideIcons.sparkles,
          value: _homeQuickPicks,
          onChanged: (v) => _toggleHomeSection('quick_picks', v),
        ),
        _buildItem(
          label: 'Top Songs',
          subtitle: 'Leaderboard of most listened tracks with rank badges',
          icon: LucideIcons.flame,
          value: _homeTopSongs,
          onChanged: (v) => _toggleHomeSection('top_songs', v),
        ),
        _buildItem(
          label: 'Newly Added',
          subtitle: 'Recently added tracks to your library',
          icon: LucideIcons.calendarPlus,
          value: _homeNewlyAdded,
          onChanged: (v) => _toggleHomeSection('newly_added', v),
        ),
        _buildItem(
          label: 'Rediscover',
          subtitle: 'Forgotten favorites and deep cuts to revisit',
          icon: LucideIcons.compass,
          value: _homeRediscover,
          onChanged: (v) => _toggleHomeSection('rediscover', v),
        ),
        _buildItem(
          label: 'Top Artists',
          subtitle: 'Horizontal carousel of your top listened artists',
          icon: LucideIcons.mic2,
          value: _homeArtists,
          onChanged: (v) => _toggleHomeSection('artists', v),
        ),
        _buildItem(
          label: 'Top Albums',
          subtitle: 'Featured albums ranked by listen count',
          icon: LucideIcons.disc,
          value: _homeAlbums,
          onChanged: (v) => _toggleHomeSection('albums', v),
        ),
        _buildItem(
          label: 'Musical Genres',
          subtitle: 'Interactive genre tiles to browse by style',
          icon: LucideIcons.radio,
          value: _homeGenres,
          onChanged: (v) => _toggleHomeSection('genres', v),
        ),
      ],
    );
  }

  Widget _buildItem({
    required String label,
    required String subtitle,
    IconData? icon,
    String? customIcon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: value
                ? colorScheme.primary.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : Colors.white10,
            ),
          ),
          child: Row(
            children: [
              customIcon != null
                  ? SvgPicture.asset(
                      customIcon,
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        value ? colorScheme.primary : Colors.white54,
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(
                      icon,
                      size: 18,
                      color: value ? colorScheme.primary : Colors.white54,
                    ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppFonts.jostStyle(
                        fontSize: 14,
                        fontWeight: value ? FontWeight.bold : FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppFonts.jostStyle(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: value,
                activeColor: colorScheme.primary,
                checkColor: Colors.white,
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
