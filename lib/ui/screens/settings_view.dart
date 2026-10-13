import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/ui/widgets/folder_picker_helper.dart';
import 'package:looper_player/features/shortcuts/presentation/shortcuts_settings_view.dart';
import 'package:looper_player/features/shortcuts/presentation/widgets/shortcuts_cheatsheet_dialog.dart';
import 'package:looper_player/core/windows_file_association_service.dart';
import 'package:looper_player/features/search/presentation/search_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/app_icons.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/core/system_tray_service.dart';
import 'package:looper_player/features/library/presentation/library_cleanup_view.dart';
import 'package:looper_player/core/update_service.dart';
import 'package:looper_player/ui/screens/android/player/android_equalizer_screen.dart';

enum SettingsCategory {
  appearance,
  audio,
  library,
  desktop,
  scrobbling,
  shortcuts,
  about,
}

final activeSettingsCategoryProvider = StateProvider<SettingsCategory>(
  (ref) => SettingsCategory.appearance,
);

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final activeCategory = ref.watch(activeSettingsCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();
    final isDesktop =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    final categories = [
      _CategoryItemData(
        category: SettingsCategory.appearance,
        label: l10n.appearance,
        icon: LucideIcons.palette,
      ),
      _CategoryItemData(
        category: SettingsCategory.audio,
        label: l10n.audioPlayback,
        icon: LucideIcons.volume2,
      ),
      _CategoryItemData(
        category: SettingsCategory.library,
        label: l10n.librarySettings,
        icon: LucideIcons.folder,
      ),
      if (isDesktop)
        _CategoryItemData(
          category: SettingsCategory.desktop,
          label: 'Desktop & Window',
          icon: LucideIcons.monitor,
        ),
      _CategoryItemData(
        category: SettingsCategory.scrobbling,
        label: 'Scrobbling',
        icon: LucideIcons.radio,
      ),
      _CategoryItemData(
        category: SettingsCategory.shortcuts,
        label: 'Shortcuts',
        icon: LucideIcons.keyboard,
      ),
      _CategoryItemData(
        category: SettingsCategory.about,
        label: l10n.aboutApp,
        icon: LucideIcons.info,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double windowWidth = MediaQuery.of(context).size.width;
            final bool isNarrow = windowWidth < 640;
            final bool isMedium = windowWidth < 1000;

            final contentPadding = isNarrow
                ? const EdgeInsets.fromLTRB(16, 12, 16, 160)
                : isMedium
                ? const EdgeInsets.fromLTRB(20, 16, 20, 160)
                : const EdgeInsets.fromLTRB(28, 20, 28, 160);

            final double sidebarWidth = isMedium ? 64 : 240;

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ...previousChildren,
                    // ignore: use_null_aware_elements
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              child: isNarrow
                  ? SizedBox.expand(
                      key: const ValueKey('narrow_settings_layout'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top category horizontal scrollable chips
                          SizedBox(
                            height: 52,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              physics: const BouncingScrollPhysics(),
                              children: categories.map((cat) {
                                return _CategoryChip(
                                  label: cat.label,
                                  icon: cat.icon,
                                  isSelected:
                                      activeCategory == cat.category &&
                                      searchQuery.isEmpty,
                                  onTap: () {
                                    ref
                                            .read(searchQueryProvider.notifier)
                                            .state =
                                        '';
                                    ref
                                            .read(
                                              activeSettingsCategoryProvider
                                                  .notifier,
                                            )
                                            .state =
                                        cat.category;
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                          Expanded(
                            child: searchQuery.isNotEmpty
                                ? _buildSearchResults(
                                    context,
                                    ref,
                                    settings,
                                    l10n,
                                    searchQuery,
                                    isDesktop,
                                    padding: contentPadding,
                                  )
                                : _buildCategoryContent(
                                    context,
                                    ref,
                                    settings,
                                    l10n,
                                    activeCategory,
                                    isDesktop,
                                    padding: contentPadding,
                                  ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.expand(
                      key: const ValueKey('wide_settings_layout'),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Navigation Sidebar (Full or Compact) with smooth size transition
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOutCubic,
                            width: sidebarWidth,
                            child: ClipRect(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Fixed-height header with crossfade between gear icon (compact) and Settings title (expanded)
                                  SizedBox(
                                    height: 64,
                                    child: Stack(
                                      alignment: Alignment.centerLeft,
                                      children: [
                                        // Compact gear icon (centered in 64px sidebar)
                                        SizedBox(
                                          width: 64,
                                          height: 64,
                                          child: Center(
                                            child: AnimatedOpacity(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              curve: Curves.easeInOut,
                                              opacity: isMedium ? 1.0 : 0.0,
                                              child: const Tooltip(
                                                message: 'Settings',
                                                child: Icon(
                                                  LucideIcons.settings,
                                                  size: 22,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Expanded Settings title
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: AnimatedOpacity(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              curve: Curves.easeInOut,
                                              opacity: isMedium ? 0.0 : 1.0,
                                              child: Text(
                                                l10n.settings,
                                                maxLines: 1,
                                                softWrap: false,
                                                overflow: TextOverflow.clip,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: -0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      physics: const BouncingScrollPhysics(),
                                      children: categories.map((cat) {
                                        return _CategorySidebarTile(
                                          category: cat.category,
                                          label: cat.label,
                                          icon: cat.icon,
                                          isMedium: isMedium,
                                          isSelected:
                                              activeCategory == cat.category &&
                                              searchQuery.isEmpty,
                                          onTap: () {
                                            ref
                                                    .read(
                                                      searchQueryProvider
                                                          .notifier,
                                                    )
                                                    .state =
                                                '';
                                            ref
                                                .read(
                                                  activeSettingsCategoryProvider
                                                      .notifier,
                                                )
                                                .state = cat
                                                .category;
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Vertical divider
                          Container(
                            width: 1,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),

                          // Right Content Area (Selected Category OR Live Search Results)
                          Expanded(
                            child: searchQuery.isNotEmpty
                                ? _buildSearchResults(
                                    context,
                                    ref,
                                    settings,
                                    l10n,
                                    searchQuery,
                                    isDesktop,
                                    padding: contentPadding,
                                  )
                                : _buildCategoryContent(
                                    context,
                                    ref,
                                    settings,
                                    l10n,
                                    activeCategory,
                                    isDesktop,
                                    padding: contentPadding,
                                  ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryContent(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
    SettingsCategory category,
    bool isDesktop, {
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(28, 20, 28, 160),
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (category == SettingsCategory.appearance) ...[
            _buildAppearanceSection(context, ref, settings, l10n),
            _buildSidebarSection(context, ref, settings, l10n),
            _buildLanguageSection(context, ref, settings, l10n),
            _buildTypographySection(context, ref, settings, l10n),
          ] else if (category == SettingsCategory.audio) ...[
            _buildAudioSection(context, ref, settings, l10n),
          ] else if (category == SettingsCategory.library) ...[
            _buildLibrarySection(context, ref, settings, l10n),
          ] else if (category == SettingsCategory.desktop) ...[
            _buildDesktopSection(context, ref, settings, l10n),
            if (isDesktop)
              _buildDiscordRpcSection(context, ref, settings, l10n),
            if (isDesktop)
              _buildFullscreenPlayerSection(context, ref, settings, l10n),
          ] else if (category == SettingsCategory.scrobbling) ...[
            _buildScrobblingSection(context, ref, settings, l10n),
          ] else if (category == SettingsCategory.shortcuts) ...[
            _buildShortcutsSection(context, ref, settings, l10n),
          ] else if (category == SettingsCategory.about) ...[
            _buildAboutSection(context, ref, settings, l10n),
            const _PremiumMaintainerSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
    String query,
    bool isDesktop, {
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(28, 20, 28, 160),
  }) {
    final results =
        _getSearchableSettings(context, ref, settings, l10n, isDesktop)
            .where(
              (item) =>
                  item.title.toLowerCase().contains(query) ||
                  item.subtitle.toLowerCase().contains(query) ||
                  item.category.toLowerCase().contains(query),
            )
            .toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.searchX, size: 48, color: Colors.white30),
            const SizedBox(height: 16),
            Text(
              'No settings found matching "$query"',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final isDynamic =
        settings.enableDynamicTheming || settings.keepBackgroundGradient;
    final useBlur = isDynamic && !settings.disableBlur;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Search Results (${results.length})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PremiumSection(
            borderRadius: BorderRadius.circular(20),
            padding: EdgeInsets.zero,
            useBlur: useBlur,
            useExpanded: false,
            child: Column(
              children: results.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 56, top: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    item.widget,
                    if (idx < results.length - 1)
                      Divider(
                        color: Colors.white.withValues(alpha: 0.05),
                        height: 1,
                        indent: 56,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search Registry ──────────────────────────────────────────────────────

  List<_SearchItem> _getSearchableSettings(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
    bool isDesktop,
  ) {
    return [
      _SearchItem(
        category: 'Appearance',
        title: l10n.dynamicTheming,
        subtitle: l10n.adaptColorsArtwork,
        widget: _PremiumSwitchRow(
          icon: LucideIcons.palette,
          title: l10n.dynamicTheming,
          subtitle: l10n.adaptColorsArtwork,
          value: settings.enableDynamicTheming,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateDynamicTheming(v),
        ),
      ),
      _SearchItem(
        category: 'Appearance',
        title: l10n.keepBackgroundGradient,
        subtitle: l10n.keepBackgroundGradientDesc,
        widget: _PremiumSwitchRow(
          icon: LucideIcons.layers,
          title: l10n.keepBackgroundGradient,
          subtitle: l10n.keepBackgroundGradientDesc,
          value: settings.keepBackgroundGradient,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .updateKeepBackgroundGradient(v),
        ),
      ),
      _SearchItem(
        category: 'Appearance',
        title: l10n.dynamicAccentColor,
        subtitle: l10n.dynamicAccentColorDesc,
        widget: _PremiumSwitchRow(
          icon: LucideIcons.paintBucket,
          title: l10n.dynamicAccentColor,
          subtitle: l10n.dynamicAccentColorDesc,
          value: settings.dynamicAccentColor,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateDynamicAccentColor(v),
        ),
      ),
      if (!settings.dynamicAccentColor)
        _SearchItem(
          category: 'Appearance',
          title: l10n.accentColor,
          subtitle: l10n.accentColorDesc,
          widget: _PremiumAccentColorRow(
            icon: LucideIcons.droplet,
            title: l10n.accentColor,
            subtitle: l10n.accentColorDesc,
            selectedColor: settings.accentColor,
            onColorChanged: (c) =>
                ref.read(settingsProvider.notifier).updateAccentColor(c),
          ),
        ),
      _SearchItem(
        category: 'Appearance',
        title: l10n.pureBlackOled,
        subtitle: l10n.pureBlackOledDesc,
        widget: _PremiumSwitchRow(
          icon: LucideIcons.moon,
          title: l10n.pureBlackOled,
          subtitle: l10n.pureBlackOledDesc,
          value: settings.darkTheme,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateDarkTheme(v),
        ),
      ),
      _SearchItem(
        category: 'Appearance',
        title: l10n.dynamicLyricsBg,
        subtitle: l10n.dynamicLyricsBgDesc,
        widget: _PremiumSwitchRow(
          icon: LucideIcons.music,
          title: l10n.dynamicLyricsBg,
          subtitle: l10n.dynamicLyricsBgDesc,
          value: settings.dynamicLyrics,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateDynamicLyrics(v),
        ),
      ),
      _SearchItem(
        category: 'Appearance',
        title: l10n.disableBlurEffects,
        subtitle: l10n.turnOffBlursOptimize,
        widget: _PremiumSwitchRow(
          icon: LucideIcons.eyeOff,
          title: l10n.disableBlurEffects,
          subtitle: l10n.turnOffBlursOptimize,
          value: settings.disableBlur,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateDisableBlur(v),
        ),
      ),
      _SearchItem(
        category: 'Audio & Playback',
        title: 'Equalizer (EQ)',
        subtitle: '18-band equalizer, presets, sound profiles and audio curves',
        widget: _PremiumActionRow(
          icon: LucideIcons.sliders,
          title: 'Equalizer',
          subtitle: settings.equalizerEnabled
              ? 'Enabled • 18-band EQ, presets & sound profiles'
              : 'Configure 18-band EQ, presets & sound profiles',
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AndroidEqualizerScreen(),
              ),
            );
          },
        ),
      ),
      _SearchItem(
        category: 'Audio & Playback',
        title: 'Auto-Trim Silence',
        subtitle:
            'Automatically detect and skip silence at track start and end',
        widget: _PremiumSwitchRow(
          icon: LucideIcons.scissors,
          title: 'Auto-Trim Silence',
          subtitle:
              'Automatically detect and skip silence at the beginning and end of tracks',
          value: settings.autoTrimSilence,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateAutoTrimSilence(v),
        ),
      ),
      _SearchItem(
        category: 'Audio & Playback',
        title: 'Gapless Playback',
        subtitle: 'Eliminate silence between consecutive tracks',
        widget: _PremiumSwitchRow(
          icon: LucideIcons.infinity,
          title: 'Gapless Playback',
          subtitle: 'Eliminate silence between consecutive tracks',
          value: settings.gaplessPlayback,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateGaplessPlayback(v),
        ),
      ),
      _SearchItem(
        category: 'Audio & Playback',
        title: 'Crossfade Duration',
        subtitle: 'Smoothly crossfade between tracks',
        widget: _PremiumSliderRow(
          icon: LucideIcons.blend,
          title: 'Crossfade Duration',
          subtitle: '${settings.crossfadeDuration}s duration',
          value: settings.crossfadeDuration.toDouble(),
          min: 0,
          max: 12,
          divisions: 12,
          suffix: 's',
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .updateCrossfadeDuration(v.round()),
        ),
      ),
      _SearchItem(
        category: 'Audio & Playback',
        title: l10n.fadePlayPauseStop,
        subtitle: l10n.fadePlayPauseStopDesc,
        widget: _PremiumSwitchRow(
          icon: LucideIcons.music,
          title: l10n.fadePlayPauseStop,
          subtitle: l10n.fadePlayPauseStopDesc,
          value: settings.fadePlayPauseStop,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateFadePlayPauseStop(v),
        ),
      ),
      _SearchItem(
        category: 'Library & Files',
        title: l10n.rescanLibrary,
        subtitle: l10n.updateLibraryIndexing,
        widget: _PremiumActionRow(
          icon: LucideIcons.refreshCcw,
          title: l10n.rescanLibrary,
          subtitle: l10n.updateLibraryIndexing,
          onTap: () {
            ref.read(libraryProvider.notifier).scanSavedFolders();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.scanningLibrary)));
          },
        ),
      ),
      _SearchItem(
        category: 'Library & Files',
        title: 'Smart Playlists',
        subtitle:
            'Auto-generate dynamic playlists (Top Most Played, Recently Added, Forgotten Favorites)',
        widget: _PremiumSwitchRow(
          icon: LucideIcons.sparkles,
          title: 'Smart Playlists',
          subtitle:
              'Auto-generate dynamic playlists (Top Most Played, Recently Added, Forgotten Favorites)',
          value: settings.enableSmartPlaylists,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateEnableSmartPlaylists(v),
        ),
      ),
      _SearchItem(
        category: 'Library & Files',
        title: 'Song View Style',
        subtitle:
            'Choose visual layout for songs list (Normal, Compact, Text Only, Grid)',
        widget: _PremiumDropdownRow<int>(
          icon: LucideIcons.layoutList,
          title: 'Song View Style',
          subtitle:
              'Choose visual layout for songs list (Normal, Compact, Text Only, Grid)',
          value: settings.songViewStyleIndex.clamp(0, 3),
          items: const [
            DropdownMenuItem(value: 0, child: Text('Normal List')),
            DropdownMenuItem(value: 1, child: Text('Compact List')),
            DropdownMenuItem(value: 2, child: Text('Text Only')),
            DropdownMenuItem(value: 3, child: Text('Grid Cards')),
          ],
          onChanged: (v) {
            if (v != null) {
              ref.read(settingsProvider.notifier).updateSongViewStyle(v);
            }
          },
        ),
      ),
      _SearchItem(
        category: 'Library & Files',
        title: 'Album Card Style',
        subtitle: 'Choose visual layout for album grid items',
        widget: _PremiumDropdownRow<int>(
          icon: LucideIcons.disc,
          title: 'Album Card Style',
          subtitle: 'Choose visual layout for album grid items',
          value: settings.albumCardStyleIndex.clamp(0, 4),
          items: const [
            DropdownMenuItem(
              value: 0,
              child: Text('Normal (Rounded Cover & Info Below)'),
            ),
            DropdownMenuItem(
              value: 1,
              child: Text('Circle (Circular Avatar & Centered Info)'),
            ),
            DropdownMenuItem(value: 2, child: Text('Card')),
            DropdownMenuItem(
              value: 3,
              child: Text('Image (Overlay Text on Dark Gradient)'),
            ),
            DropdownMenuItem(
              value: 4,
              child: Text('Gapless (Edge-to-Edge Full Bleed Grid)'),
            ),
          ],
          onChanged: (v) {
            if (v != null) {
              ref.read(settingsProvider.notifier).updateAlbumCardStyle(v);
            }
          },
        ),
      ),
      _SearchItem(
        category: 'Library & Files',
        title: 'Artist Card Style',
        subtitle: 'Choose visual layout for artist grid items',
        widget: _PremiumDropdownRow<int>(
          icon: LucideIcons.mic2,
          title: 'Artist Card Style',
          subtitle: 'Choose visual layout for artist grid items',
          value: settings.artistCardStyleIndex.clamp(0, 4),
          items: const [
            DropdownMenuItem(
              value: 0,
              child: Text('Normal (Rounded Cover & Info Below)'),
            ),
            DropdownMenuItem(
              value: 1,
              child: Text('Circle (Circular Avatar & Centered Info)'),
            ),
            DropdownMenuItem(value: 2, child: Text('Card')),
            DropdownMenuItem(
              value: 3,
              child: Text('Image (Overlay Text on Dark Gradient)'),
            ),
            DropdownMenuItem(
              value: 4,
              child: Text('Gapless (Edge-to-Edge Full Bleed Grid)'),
            ),
          ],
          onChanged: (v) {
            if (v != null) {
              ref.read(settingsProvider.notifier).updateArtistCardStyle(v);
            }
          },
        ),
      ),
      _SearchItem(
        category: 'Library & Files',
        title: l10n.internetMode,
        subtitle: l10n.enableNetworkLyricsArt,
        widget: _PremiumSwitchRow(
          icon: LucideIcons.globe,
          title: l10n.internetMode,
          subtitle: l10n.enableNetworkLyricsArt,
          value: settings.enableInternet,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateEnableInternet(v),
        ),
      ),
      _SearchItem(
        category: 'Library & Files',
        title: 'Library Cleanup & Quality Assistant',
        subtitle:
            'Find duplicate tracks, low bitrate audio, and missing album artwork',
        widget: _PremiumActionRow(
          icon: LucideIcons.sparkles,
          title: 'Library Cleanup & Quality Assistant',
          subtitle:
              'Find duplicate tracks, low bitrate audio, and missing album artwork',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LibraryCleanupView()),
            );
          },
          isLast: false,
        ),
      ),
      if (isDesktop) ...[
        _SearchItem(
          category: 'Desktop & Window',
          title: 'Global Hotkeys (System-Wide)',
          subtitle:
              'Control playback when Looper is minimized in the background',
          widget: _PremiumSwitchRow(
            icon: LucideIcons.globe,
            title: 'Global Hotkeys (System-Wide)',
            subtitle:
                'Control playback when Looper is minimized in the background',
            value: settings.enableGlobalHotkeys,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateEnableGlobalHotkeys(v),
          ),
        ),
        if (Platform.isWindows)
          _SearchItem(
            category: 'Desktop & Window',
            title: 'Windows Taskbar Thumbnail Controls',
            subtitle:
                'Show Play/Pause/Prev/Next buttons in the Windows taskbar preview window',
            widget: _PremiumSwitchRow(
              icon: LucideIcons.appWindow,
              title: 'Windows Taskbar Controls',
              subtitle:
                  'Show Play/Pause/Prev/Next buttons in taskbar thumbnail preview',
              value: settings.enableTaskbarControls,
              onChanged: (v) => ref
                  .read(settingsProvider.notifier)
                  .updateEnableTaskbarControls(v),
            ),
          ),
        _SearchItem(
          category: 'Desktop & Window',
          title: l10n.minimizeToTray,
          subtitle: l10n.minimizeToTrayDesc,
          widget: _PremiumSwitchRow(
            icon: LucideIcons.panelTop,
            title: l10n.minimizeToTray,
            subtitle: l10n.minimizeToTrayDesc,
            value: settings.minimizeToTray,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).updateMinimizeToTray(v),
          ),
        ),
        _SearchItem(
          category: 'Desktop & Window',
          title: 'Hide Tray Icon When Active',
          subtitle: 'Only show the system tray icon when Looper is minimized',
          widget: _PremiumSwitchRow(
            icon: LucideIcons.eyeOff,
            title: 'Hide Tray Icon When Active',
            subtitle: 'Only show the system tray icon when Looper is minimized',
            value: settings.showTrayOnlyWhenMinimized,
            onChanged: (v) {
              ref
                  .read(settingsProvider.notifier)
                  .updateShowTrayOnlyWhenMinimized(v);
              SystemTrayService.instance.syncTrayVisibility();
            },
          ),
        ),
        _SearchItem(
          category: 'Desktop & Window',
          title: 'Discord Rich Presence',
          subtitle: 'Broadcast currently playing track to Discord status',
          widget: _PremiumSwitchRow(
            icon: LucideIcons.messageSquare,
            title: 'Discord Rich Presence',
            subtitle: 'Broadcast currently playing track to Discord status',
            value: settings.enableDiscordRpc,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).updateEnableDiscordRpc(v),
          ),
        ),
        if (Platform.isWindows)
          _SearchItem(
            category: 'Desktop & Window',
            title: 'Windows Explorer Context Menu',
            subtitle:
                'Show "Play in Looper" and "Add to Looper Queue" in Windows right-click menus',
            widget: _PremiumSwitchRow(
              icon: LucideIcons.mousePointerClick,
              title: 'Windows Explorer Context Menu',
              subtitle:
                  'Show "Play in Looper" and "Add to Looper Queue" in Windows right-click menus',
              value: settings.enableWindowsFileAssociations,
              onChanged: (v) => ref
                  .read(settingsProvider.notifier)
                  .updateEnableWindowsFileAssociations(v),
            ),
          ),
      ],
      _SearchItem(
        category: 'Scrobbling',
        title: 'Last.fm Scrobbling',
        subtitle: 'Submit tracks to Last.fm',
        widget: _PremiumSwitchRow(
          icon: LucideIcons.radio,
          title: 'Last.fm Scrobbling',
          subtitle: settings.lastFmUsername.isNotEmpty
              ? 'Connected as ${settings.lastFmUsername}'
              : 'Submit tracks to Last.fm',
          value: settings.enableLastFmScrobbling,
          onChanged: (v) {
            if (v && settings.lastFmSessionKey.isEmpty) {
              _showLastFmConfigDialog(context, ref, settings, isEnabling: true);
            } else {
              ref
                  .read(settingsProvider.notifier)
                  .updateEnableLastFmScrobbling(v);
            }
          },
        ),
      ),
      _SearchItem(
        category: 'Scrobbling',
        title: 'ListenBrainz Scrobbling',
        subtitle: 'Submit tracks to ListenBrainz',
        widget: _PremiumSwitchRow(
          icon: LucideIcons.brain,
          title: 'ListenBrainz Scrobbling',
          subtitle: settings.listenBrainzUserToken.isNotEmpty
              ? 'Token configured'
              : 'Submit tracks to ListenBrainz',
          value: settings.enableListenBrainzScrobbling,
          onChanged: (v) {
            if (v && settings.listenBrainzUserToken.isEmpty) {
              _showListenBrainzConfigDialog(
                context,
                ref,
                settings,
                isEnabling: true,
              );
            } else {
              ref
                  .read(settingsProvider.notifier)
                  .updateEnableListenBrainzScrobbling(v);
            }
          },
        ),
      ),
      _SearchItem(
        category: 'Shortcuts',
        title: 'Customize Shortcuts',
        subtitle: 'Rebind key combinations for playback and navigation',
        widget: _PremiumActionRow(
          icon: LucideIcons.keyboard,
          title: 'Customize Shortcuts',
          subtitle: 'Rebind key combinations for playback and navigation',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const ShortcutsSettingsView(),
              ),
            );
          },
        ),
      ),
    ];
  }

  // ─── Sections ─────────────────────────────────────────────────────────────

  Widget _buildAppearanceSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
  ) {
    return _Section(
      title: l10n.appearance,
      children: [
        _PremiumSwitchRow(
          icon: LucideIcons.palette,
          title: l10n.dynamicTheming,
          subtitle: l10n.adaptColorsArtwork,
          value: settings.enableDynamicTheming,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).updateDynamicTheming(value);
          },
          isLast: false,
        ),
        if (settings.enableDynamicTheming)
          _PremiumSwitchRow(
            icon: LucideIcons.eyeOff,
            title: l10n.disableBlurEffects,
            subtitle: l10n.turnOffBlursOptimize,
            value: settings.disableBlur,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              ref.read(settingsProvider.notifier).updateDisableBlur(value);
            },
            isLast: false,
          ),
        if (!settings.enableDynamicTheming) ...[
          _PremiumSwitchRow(
            icon: LucideIcons.layers,
            title: l10n.keepBackgroundGradient,
            subtitle: l10n.keepBackgroundGradientDesc,
            value: settings.keepBackgroundGradient,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              ref
                  .read(settingsProvider.notifier)
                  .updateKeepBackgroundGradient(value);
            },
            isLast: false,
          ),
          _PremiumSwitchRow(
            icon: LucideIcons.paintBucket,
            title: l10n.dynamicAccentColor,
            subtitle: l10n.dynamicAccentColorDesc,
            value: settings.dynamicAccentColor,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              ref
                  .read(settingsProvider.notifier)
                  .updateDynamicAccentColor(value);
            },
            isLast: false,
          ),
          if (!settings.dynamicAccentColor)
            _PremiumAccentColorRow(
              icon: LucideIcons.droplet,
              title: l10n.accentColor,
              subtitle: l10n.accentColorDesc,
              selectedColor: settings.accentColor,
              onColorChanged: (color) {
                ref.read(settingsProvider.notifier).updateAccentColor(color);
              },
              isLast: false,
            ),
        ],
        _PremiumSwitchRow(
          icon: LucideIcons.moon,
          title: l10n.pureBlackOled,
          subtitle: l10n.pureBlackOledDesc,
          value: settings.darkTheme,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).updateDarkTheme(value);
          },
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.music,
          title: l10n.dynamicLyricsBg,
          subtitle: l10n.dynamicLyricsBgDesc,
          value: settings.dynamicLyrics,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).updateDynamicLyrics(value);
          },
          isLast: false,
        ),
        if (settings.enableDynamicTheming || settings.dynamicLyrics)
          _PremiumSwitchRow(
            icon: LucideIcons.palette,
            title: l10n.dynamicColorActiveLyrics,
            subtitle: l10n.dynamicColorActiveLyricsDesc,
            value: settings.dynamicColorActiveLyrics,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              ref
                  .read(settingsProvider.notifier)
                  .updateDynamicColorActiveLyrics(value);
            },
            isLast: false,
          ),
        _PremiumDropdownRow<String>(
          icon: LucideIcons.alignCenter,
          title: l10n.lyricsAlignment,
          value: settings.lyricsAlignment,
          items: [
            DropdownMenuItem(value: 'left', child: Text(l10n.left)),
            DropdownMenuItem(value: 'center', child: Text(l10n.center)),
            DropdownMenuItem(value: 'right', child: Text(l10n.right)),
          ],
          onChanged: (align) {
            if (align != null) {
              HapticFeedback.lightImpact();
              ref.read(settingsProvider.notifier).updateLyricsAlignment(align);
            }
          },
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.type,
          title: 'Uniform Line Size',
          subtitle: 'Keep all lyrics lines at the same font size',
          value: settings.uniformLyricsFontSize,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref
                .read(settingsProvider.notifier)
                .updateUniformLyricsFontSize(value);
          },
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.sliders,
          title: l10n.flatProgressBar,
          subtitle: l10n.disableSquigglyProgressBar,
          value: settings.disableSquiggle,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).updateDisableSquiggle(value);
          },
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.clock,
          title: l10n.plainTimestamps,
          subtitle: l10n.useStaticTextTimestamps,
          value: settings.disableAnimatedDuration,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref
                .read(settingsProvider.notifier)
                .updateDisableAnimatedDuration(value);
          },
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.move,
          title: l10n.verticalMotionEffectPlayer,
          subtitle: l10n.verticalMotionEffectPlayerDesc,
          value: settings.enableSlideGesture,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).updateEnableSlideGesture(value);
          },
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.power,
          title: l10n.stopServiceOnAppDismissal,
          subtitle: l10n.stopServiceOnAppDismissalDesc,
          value: settings.stopOnTaskRemoved,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).updateStopOnTaskRemoved(value);
          },
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildSidebarSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
  ) {
    return _Section(
      title: 'Sidebar Navigation Items',
      children: [
        _PremiumSwitchRow(
          icon: LucideIcons.headphones,
          title: l10n.nowPlaying,
          subtitle: 'Show Now Playing in the sidebar',
          value: settings.showSidebarNowPlaying,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .updateShowSidebarNowPlaying(v),
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.disc,
          title: l10n.albums,
          subtitle: 'Show Albums library item in the sidebar',
          value: settings.showSidebarAlbums,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateShowSidebarAlbums(v),
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.mic2,
          title: l10n.artists,
          subtitle: 'Show Artists library item in the sidebar',
          value: settings.showSidebarArtists,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateShowSidebarArtists(v),
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.library,
          title: l10n.playlists,
          subtitle: 'Show Playlists in the sidebar',
          value: settings.showSidebarPlaylists,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateShowSidebarPlaylists(v),
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.folder,
          title: 'Folders',
          subtitle: 'Show Directory Tree & Folders in the sidebar',
          value: settings.showSidebarFolders,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateShowSidebarFolders(v),
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.clock,
          title: 'Recently Played',
          subtitle: 'Show Recently Played in the sidebar',
          value: settings.showSidebarRecentlyPlayed,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .updateShowSidebarRecentlyPlayed(v),
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.heart,
          title: 'Favorites',
          subtitle: 'Show Favorites in the sidebar',
          value: settings.showSidebarFavorites,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateShowSidebarFavorites(v),
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.radio,
          title: l10n.genres,
          subtitle: 'Show Genres in the sidebar',
          value: settings.showSidebarGenres,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateShowSidebarGenres(v),
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.barChart2,
          title: 'Stats & Analyze',
          subtitle: 'Show Looper Analyze in the sidebar',
          value: settings.showSidebarAnalyze,
          onChanged: (v) =>
              ref.read(settingsProvider.notifier).updateShowSidebarAnalyze(v),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
  ) {
    return _Section(
      title: l10n.language,
      children: [
        _PremiumDropdownRow<String>(
          icon: LucideIcons.languages,
          title: l10n.language,
          value: settings.language,
          items: [
            DropdownMenuItem(value: '', child: Text(l10n.systemDefault)),
            ...AppLocalizations.supportedLocales.map((locale) {
              final code = locale.languageCode;
              final name =
                  {
                    'en': 'English',
                    'es': 'Español',
                    'fr': 'Français',
                    'de': 'Deutsch',
                    'pt': 'Português',
                    'ru': 'Русский',
                    'it': 'Italiano',
                    'zh': '中文',
                    'ja': '日本語',
                    'ko': '한국어',
                    'ar': 'العربية',
                    'tr': 'Türkçe',
                    'nl': 'Nederlands',
                    'hi': 'हिन्दी',
                  }[code] ??
                  code;
              return DropdownMenuItem(value: code, child: Text(name));
            }),
          ],
          onChanged: (lang) {
            if (lang != null) {
              HapticFeedback.lightImpact();
              ref.read(settingsProvider.notifier).updateLanguage(lang);
            }
          },
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTypographySection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
  ) {
    return _Section(
      title: 'Typography & Fonts',
      children: [
        _FontPickerTile(
          icon: LucideIcons.type,
          title: 'Application Font',
          subtitle: settings.customFontFamily.isNotEmpty
              ? settings.customFontFamily
              : (settings.useNewFont ? 'Jost' : 'DM Sans (Default)'),
          useNewFont: settings.useNewFont,
          customFamily: settings.customFontFamily,
          weightDelta: settings.customFontWeightDelta,
          onTap: () => _showFontPicker(context, ref, settings),
          isLast: false,
        ),
        _FontPickerTile(
          icon: LucideIcons.music,
          title: 'Lyrics Font',
          subtitle: settings.customFontFamilyLyrics.isNotEmpty
              ? settings.customFontFamilyLyrics
              : (settings.useNewFontLyrics ? 'Jost' : 'DM Sans (Default)'),
          useNewFont: settings.useNewFontLyrics,
          customFamily: settings.customFontFamilyLyrics,
          weightDelta: settings.customFontWeightLyricsDelta,
          onTap: () => _showLyricsFontPicker(context, ref, settings),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildAudioSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
  ) {
    return _Section(
      title: l10n.audioPlayback,
      children: [
        _PremiumActionRow(
          icon: LucideIcons.sliders,
          title: 'Equalizer',
          subtitle: settings.equalizerEnabled
              ? 'Enabled • 18-band EQ, presets & sound profiles'
              : 'Configure 18-band EQ, presets & sound profiles',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                settings.equalizerEnabled ? 'ON' : 'OFF',
                style: TextStyle(
                  color: settings.equalizerEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: Colors.white38,
              ),
            ],
          ),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AndroidEqualizerScreen(),
              ),
            );
          },
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.listMusic,
          title: l10n.showPlayedSongsInQueue,
          subtitle: l10n.showPlayedSongsInQueueDesc,
          value: settings.showPlayedSongsInQueue,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref
                .read(settingsProvider.notifier)
                .updateShowPlayedSongsInQueue(value);
          },
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.scissors,
          title: 'Auto-Trim Silence',
          subtitle:
              'Automatically detect and skip silence at the beginning and end of tracks for a tight transition',
          value: settings.autoTrimSilence,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).updateAutoTrimSilence(value);
          },
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.infinity,
          title: 'Gapless Playback',
          subtitle:
              'Eliminate silence between consecutive tracks for continuous album & live playback',
          value: settings.gaplessPlayback,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).updateGaplessPlayback(value);
          },
          isLast: false,
        ),
        _PremiumSliderRow(
          icon: LucideIcons.blend,
          title: 'Crossfade Duration',
          subtitle: settings.crossfadeDuration == 0
              ? 'Disabled (Pure Gapless transitions)'
              : 'Smoothly fade out track and fade in next over ${settings.crossfadeDuration}s',
          value: settings.crossfadeDuration.toDouble(),
          min: 0,
          max: 12,
          divisions: 12,
          suffix: 's',
          onChanged: (value) {
            ref
                .read(settingsProvider.notifier)
                .updateCrossfadeDuration(value.round());
          },
          isLast: false,
        ),
        if (settings.crossfadeDuration > 0)
          _PremiumDropdownRow<int>(
            icon: LucideIcons.gitCommit,
            title: 'Crossfade Mode',
            subtitle: 'Choose when crossfade transitions are triggered',
            value: settings.crossfadeMode,
            items: const [
              DropdownMenuItem(value: 0, child: Text('Always (Auto & Manual)')),
              DropdownMenuItem(
                value: 1,
                child: Text('Automatic Transitions Only'),
              ),
              DropdownMenuItem(value: 2, child: Text('Manual Skips Only')),
            ],
            onChanged: (value) {
              if (value != null) {
                HapticFeedback.lightImpact();
                ref.read(settingsProvider.notifier).updateCrossfadeMode(value);
              }
            },
            isLast: false,
          ),
        _PremiumSwitchRow(
          icon: LucideIcons.music,
          title: l10n.fadePlayPauseStop,
          subtitle: l10n.fadePlayPauseStopDesc,
          value: settings.fadePlayPauseStop,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).updateFadePlayPauseStop(value);
          },
          isLast: false,
        ),
        if (settings.fadePlayPauseStop)
          _PremiumSliderRow(
            icon: LucideIcons.sliders,
            title: l10n.fadeDuration,
            subtitle: l10n.fadeDurationDesc,
            value: settings.playPauseStopFadeLength.toDouble(),
            min: 10,
            max: 1000,
            divisions: 99,
            suffix: 'ms',
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updatePlayPauseStopFadeLength(value.round());
            },
            isLast: false,
          ),
        _PremiumSwitchRow(
          icon: LucideIcons.phoneCall,
          title: l10n.manageAudioFocusTitle,
          subtitle: l10n.manageAudioFocusDesc,
          value: settings.audioFocus,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).updateAudioFocus(value);
          },
          isLast: !settings.audioFocus,
        ),
        if (settings.audioFocus) ...[
          _PremiumSwitchRow(
            icon: LucideIcons.phoneCall,
            title: l10n.resumeAfterCallTitle,
            subtitle: l10n.resumeAfterCallDesc,
            value: settings.resumeAfterCall,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              ref.read(settingsProvider.notifier).updateResumeAfterCall(value);
            },
            isLast: false,
          ),
          _PremiumSwitchRow(
            icon: LucideIcons.power,
            title: l10n.resumeOnStartTitle,
            subtitle: l10n.resumeOnStartDesc,
            value: settings.resumeOnStart,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              ref.read(settingsProvider.notifier).updateResumeOnStart(value);
            },
            isLast: false,
          ),
          _PremiumSwitchRow(
            icon: LucideIcons.alertCircle,
            title: l10n.permanentFocusChangePause,
            subtitle: l10n.permanentFocusChangePauseDesc,
            value: settings.permanentAudioFocusChange,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              ref
                  .read(settingsProvider.notifier)
                  .updatePermanentAudioFocusChange(value);
            },
            isLast: true,
          ),
        ],
      ],
    );
  }

  Widget _buildLibrarySection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
  ) {
    return _Section(
      title: l10n.librarySettings,
      children: [
        const _PremiumLibraryFoldersList(),
        _PremiumActionRow(
          icon: LucideIcons.plus,
          title: l10n.addFolder,
          subtitle: l10n.selectFolderIndex,
          onTap: () {
            HapticFeedback.lightImpact();
            FolderPickerHelper.pickFolder(context, ref);
          },
          isLast: false,
        ),
        _PremiumActionRow(
          icon: LucideIcons.refreshCcw,
          title: l10n.rescanLibrary,
          subtitle: l10n.updateLibraryIndexing,
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(libraryProvider.notifier).scanSavedFolders();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.scanningLibrary)));
          },
          isLast: false,
        ),
        _PremiumActionRow(
          icon: LucideIcons.sparkles,
          title: 'Library Cleanup & Quality Assistant',
          subtitle:
              'Find duplicate tracks, low bitrate audio, and missing album artwork',
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LibraryCleanupView()),
            );
          },
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.listMusic,
          title: 'Smart Playlists',
          subtitle:
              'Auto-generate dynamic playlists (Top Most Played, Recently Added, Forgotten Favorites)',
          value: settings.enableSmartPlaylists,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref
                .read(settingsProvider.notifier)
                .updateEnableSmartPlaylists(value);
          },
          isLast: false,
        ),
        _PremiumDropdownRow<int>(
          icon: LucideIcons.layoutList,
          title: 'Song View Style',
          subtitle: 'Choose visual layout for songs list',
          value: settings.songViewStyleIndex.clamp(0, 3),
          items: const [
            DropdownMenuItem(value: 0, child: Text('Normal List')),
            DropdownMenuItem(value: 1, child: Text('Compact List')),
            DropdownMenuItem(value: 2, child: Text('Text Only')),
            DropdownMenuItem(value: 3, child: Text('Grid Cards')),
          ],
          onChanged: (value) {
            if (value != null) {
              HapticFeedback.lightImpact();
              ref.read(settingsProvider.notifier).updateSongViewStyle(value);
            }
          },
          isLast: false,
        ),
        _PremiumDropdownRow<int>(
          icon: LucideIcons.disc,
          title: 'Album Card Style',
          subtitle: 'Choose visual layout for album grid items',
          value: settings.albumCardStyleIndex.clamp(0, 4),
          items: const [
            DropdownMenuItem(
              value: 0,
              child: Text('Normal (Rounded Cover & Info Below)'),
            ),
            DropdownMenuItem(
              value: 1,
              child: Text('Circle (Circular Avatar & Centered Info)'),
            ),
            DropdownMenuItem(value: 2, child: Text('Card')),
            DropdownMenuItem(
              value: 3,
              child: Text('Image (Overlay Text on Dark Gradient)'),
            ),
            DropdownMenuItem(
              value: 4,
              child: Text('Gapless (Edge-to-Edge Full Bleed Grid)'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              HapticFeedback.lightImpact();
              ref.read(settingsProvider.notifier).updateAlbumCardStyle(value);
            }
          },
          isLast: false,
        ),
        _PremiumDropdownRow<int>(
          icon: LucideIcons.mic2,
          title: 'Artist Card Style',
          subtitle: 'Choose visual layout for artist grid items',
          value: settings.artistCardStyleIndex.clamp(0, 4),
          items: const [
            DropdownMenuItem(
              value: 0,
              child: Text('Normal (Rounded Cover & Info Below)'),
            ),
            DropdownMenuItem(
              value: 1,
              child: Text('Circle (Circular Avatar & Centered Info)'),
            ),
            DropdownMenuItem(value: 2, child: Text('Card')),
            DropdownMenuItem(
              value: 3,
              child: Text('Image (Overlay Text on Dark Gradient)'),
            ),
            DropdownMenuItem(
              value: 4,
              child: Text('Gapless (Edge-to-Edge Full Bleed Grid)'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              HapticFeedback.lightImpact();
              ref.read(settingsProvider.notifier).updateArtistCardStyle(value);
            }
          },
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.globe,
          title: l10n.internetMode,
          subtitle: l10n.enableNetworkLyricsArt,
          value: settings.enableInternet,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).updateEnableInternet(value);
          },
          isLast: false,
        ),
        _PremiumActionRow(
          icon: LucideIcons.trash2,
          title: l10n.resetLibrary,
          textColor: Colors.redAccent,
          subtitle: l10n.resetLibraryDesc,
          onTap: () {
            HapticFeedback.heavyImpact();
            _showClearDialog(context, l10n);
          },
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildDesktopSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
  ) {
    return _Section(
      title: 'Desktop & System Tray',
      children: [
        _PremiumSwitchRow(
          icon: LucideIcons.globe,
          title: 'Global Hotkeys (System-Wide)',
          subtitle:
              'Control playback (Play/Pause, Next, Prev, Like, Copy info) when Looper is in the background',
          value: settings.enableGlobalHotkeys,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref
                .read(settingsProvider.notifier)
                .updateEnableGlobalHotkeys(value);
          },
          isLast: false,
        ),
        if (Platform.isWindows)
          _PremiumSwitchRow(
            icon: LucideIcons.appWindow,
            title: 'Windows Taskbar Controls',
            subtitle:
                'Show Play/Pause/Prev/Next buttons in the Windows taskbar preview hover window',
            value: settings.enableTaskbarControls,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              ref
                  .read(settingsProvider.notifier)
                  .updateEnableTaskbarControls(value);
            },
            isLast: false,
          ),
        _PremiumSwitchRow(
          icon: LucideIcons.panelTop,
          title: l10n.minimizeToTray,
          subtitle: l10n.minimizeToTrayDesc,
          value: settings.minimizeToTray,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).updateMinimizeToTray(value);
          },
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.eyeOff,
          title: 'Hide Tray Icon When Active',
          subtitle: 'Only show the system tray icon when Looper is minimized',
          value: settings.showTrayOnlyWhenMinimized,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref
                .read(settingsProvider.notifier)
                .updateShowTrayOnlyWhenMinimized(value);
            SystemTrayService.instance.syncTrayVisibility();
          },
          isLast: false,
        ),
        _PremiumDropdownRow<int>(
          icon: LucideIcons.minimize2,
          title: 'Default Mini Player Shortcut',
          subtitle:
              'Select which mini player style is opened by the keyboard shortcut',
          value: settings.defaultMiniPlayerType,
          items: const [
            DropdownMenuItem(value: 0, child: Text('Mini Player')),
            DropdownMenuItem(value: 1, child: Text('Corner Widget')),
          ],
          onChanged: (value) {
            if (value != null) {
              HapticFeedback.lightImpact();
              ref
                  .read(settingsProvider.notifier)
                  .updateDefaultMiniPlayerType(value);
            }
          },
          isLast: !Platform.isWindows,
        ),
        if (Platform.isWindows)
          _PremiumSwitchRow(
            icon: LucideIcons.mousePointerClick,
            title: 'Windows Explorer Context Menu',
            subtitle:
                'Show "Play in Looper" and "Add to Looper Queue" in Windows right-click menus',
            value: settings.enableWindowsFileAssociations,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              ref
                  .read(settingsProvider.notifier)
                  .updateEnableWindowsFileAssociations(value);
            },
            isLast: true,
          ),
      ],
    );
  }

  Widget _buildDiscordRpcSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
  ) {
    return _Section(
      title: 'Discord Rich Presence',
      children: [
        _PremiumSwitchRow(
          icon: LucideIcons.messageSquare,
          title: 'Discord Rich Presence',
          subtitle:
              'Broadcast currently playing track title, artist, album, and timeline to Discord',
          value: settings.enableDiscordRpc,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).updateEnableDiscordRpc(value);
          },
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildFullscreenPlayerSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
  ) {
    return _Section(
      title: 'Fullscreen Player',
      children: [
        _PremiumSwitchRow(
          icon: LucideIcons.maximize2,
          title: l10n.nowPlayingFullscreen,
          subtitle: l10n.nowPlayingFullscreenDesc,
          value: settings.nowPlayingFullscreen,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref
                .read(settingsProvider.notifier)
                .updateNowPlayingFullscreen(value);
          },
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.activity,
          title: 'Bottom Visualizer',
          subtitle:
              'Display a dynamic audio visualizer across the bottom of the player',
          value: settings.fullscreenVisualizerEnabled,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref
                .read(settingsProvider.notifier)
                .updateFullscreenVisualizerEnabled(value);
          },
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.repeat1,
          title: 'Show A-B Looper Button',
          subtitle:
              'Display the A-B section looper shortcut in the player toolbar',
          value: settings.showFullscreenABLooper,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref
                .read(settingsProvider.notifier)
                .updateShowFullscreenABLooper(value);
          },
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.timer,
          title: 'Show Sleep Timer Button',
          subtitle: 'Display the sleep timer shortcut in the player toolbar',
          value: settings.showFullscreenSleepTimer,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref
                .read(settingsProvider.notifier)
                .updateShowFullscreenSleepTimer(value);
          },
          isLast: false,
        ),
        _PremiumDropdownRow<int>(
          icon: LucideIcons.barChart2,
          title: 'Now playing seek bar',
          value: settings.seekBarStyleIndex,
          items: const [
            DropdownMenuItem(value: 0, child: Text('Visualizer')),
            DropdownMenuItem(value: 1, child: Text('Expressive')),
            DropdownMenuItem(value: 2, child: Text('Flat')),
          ],
          onChanged: (value) {
            if (value != null) {
              HapticFeedback.lightImpact();
              ref.read(settingsProvider.notifier).updateSeekBarStyle(value);
            }
          },
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildScrobblingSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
  ) {
    return _Section(
      title: 'Scrobbling (Last.fm & ListenBrainz)',
      children: [
        _PremiumSwitchRow(
          icon: LucideIcons.radio,
          title: 'Last.fm Scrobbling',
          subtitle: settings.lastFmUsername.isNotEmpty
              ? 'Connected as ${settings.lastFmUsername}'
              : 'Automatically scrobble played tracks to your Last.fm profile',
          value: settings.enableLastFmScrobbling,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            if (value && settings.lastFmSessionKey.isEmpty) {
              _showLastFmConfigDialog(context, ref, settings, isEnabling: true);
            } else {
              ref
                  .read(settingsProvider.notifier)
                  .updateEnableLastFmScrobbling(value);
            }
          },
          isLast: false,
        ),
        if (settings.enableLastFmScrobbling)
          _PremiumActionRow(
            icon: LucideIcons.key,
            title: 'Configure Last.fm Account',
            subtitle: settings.lastFmSessionKey.isNotEmpty
                ? 'Session Key configured'
                : 'Set your Last.fm Username & Session Key',
            onTap: () {
              HapticFeedback.lightImpact();
              _showLastFmConfigDialog(context, ref, settings);
            },
            isLast: false,
          ),
        _PremiumSwitchRow(
          icon: LucideIcons.brain,
          title: 'ListenBrainz Scrobbling',
          subtitle: settings.listenBrainzUserToken.isNotEmpty
              ? 'ListenBrainz User Token configured'
              : 'Submit listens directly to your ListenBrainz profile',
          value: settings.enableListenBrainzScrobbling,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            if (value && settings.listenBrainzUserToken.isEmpty) {
              _showListenBrainzConfigDialog(
                context,
                ref,
                settings,
                isEnabling: true,
              );
            } else {
              ref
                  .read(settingsProvider.notifier)
                  .updateEnableListenBrainzScrobbling(value);
            }
          },
          isLast: false,
        ),
        if (settings.enableListenBrainzScrobbling)
          _PremiumActionRow(
            icon: LucideIcons.keyRound,
            title: 'Configure ListenBrainz Token',
            subtitle: settings.listenBrainzUserToken.isNotEmpty
                ? 'Token configured'
                : 'Enter your ListenBrainz User Token',
            onTap: () {
              HapticFeedback.lightImpact();
              _showListenBrainzConfigDialog(context, ref, settings);
            },
            isLast: false,
          ),
        _PremiumSliderRow(
          icon: LucideIcons.percent,
          title: 'Scrobble Threshold',
          subtitle:
              'Track completion percentage required before sending a scrobble',
          value:
              (settings.scrobbleThresholdPercent < 20 ||
                  settings.scrobbleThresholdPercent > 90)
              ? 50.0
              : settings.scrobbleThresholdPercent.toDouble(),
          min: 20,
          max: 90,
          divisions: 7,
          suffix: '%',
          onChanged: (value) {
            ref
                .read(settingsProvider.notifier)
                .updateScrobbleThresholdPercent(value.round());
          },
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildShortcutsSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
  ) {
    return _Section(
      title: 'Keyboard Shortcuts',
      children: [
        _PremiumActionRow(
          icon: LucideIcons.keyboard,
          title: 'Customize Shortcuts',
          subtitle:
              'Rebind and customize key combinations for playback, seeking, volume, and navigation',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const ShortcutsSettingsView(),
              ),
            );
          },
          trailing: const Icon(
            LucideIcons.chevronRight,
            color: Colors.white38,
            size: 18,
          ),
          isLast: false,
        ),
        _PremiumActionRow(
          icon: LucideIcons.helpCircle,
          title: 'Shortcuts Cheatsheet',
          subtitle:
              'Quick reference card of all currently active shortcuts (Press ?)',
          onTap: () => showShortcutsCheatsheetDialog(context),
          trailing: const Icon(
            LucideIcons.chevronRight,
            color: Colors.white38,
            size: 18,
          ),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildAboutSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
  ) {
    return _Section(
      title: l10n.aboutApp,
      children: [
        _PremiumActionRow(
          icon: LucideIcons.info,
          title: l10n.appTitle,
          subtitle: 'Version 2.2.0',
          onTap: () async {
            final url = Uri.parse('https://github.com/mikiyasmechalo/looper');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'v2.2.0',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/about/github_icon.svg',
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    Colors.white70,
                    BlendMode.srcIn,
                  ),
                ),
                tooltip: 'GitHub Repository',
                onPressed: () async {
                  final url = Uri.parse(
                    'https://github.com/mikiyasmechalo/looper',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
          isLast: false,
        ),
        _PremiumActionRow(
          icon: LucideIcons.refreshCw,
          title: 'Check for Updates',
          subtitle: 'Check GitHub for the latest release',
          onTap: () {
            HapticFeedback.lightImpact();
            UpdateService.checkForUpdates(
              ref: ref,
              context: context,
              manual: true,
            );
          },
          isLast: false,
        ),
        _PremiumSwitchRow(
          icon: LucideIcons.bellRing,
          title: 'Update Notifications',
          subtitle:
              'Automatically check for new releases and show notifications',
          value: settings.enableUpdateNotifications,
          onChanged: (val) => ref
              .read(settingsProvider.notifier)
              .updateEnableUpdateNotifications(val),
          isLast: settings.skippedUpdateVersion.isEmpty,
        ),
        if (settings.skippedUpdateVersion.isNotEmpty)
          _PremiumActionRow(
            icon: LucideIcons.skipForward,
            title: 'Skipped Version: ${settings.skippedUpdateVersion}',
            subtitle: 'Tap to reset and receive notifications for this version',
            trailing: Text(
              'Reset',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              ref
                  .read(settingsProvider.notifier)
                  .updateSkippedUpdateVersion('');
            },
            isLast: false,
          ),
        _PremiumActionRow(
          icon: LucideIcons.music,
          title: l10n.lyricsProvider,
          subtitle: l10n.lyricsProviderDesc,
          onTap: () async {
            final url = Uri.parse('https://lrclib.net');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          isLast: false,
        ),
        _PremiumActionRow(
          icon: LucideIcons.gitFork,
          title: l10n.sourceCode,
          subtitle: l10n.visitOfficialRepository,
          onTap: () async {
            final url = Uri.parse('https://github.com/mikiyasmechalo/looper');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          isLast: true,
        ),
      ],
    );
  }

  // ─── Dialogs ──────────────────────────────────────────────────────────────

  void _showClearDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          l10n.resetLibrary,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.resetLibraryDesc,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.white60),
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              return TextButton(
                onPressed: () async {
                  await ref.read(libraryProvider.notifier).clearAllData();
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(
                  l10n.reset,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showFontPicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return _FontSelectionDialog(
          title: 'Application Font',
          currentFamily: settings.customFontFamily,
          useNewFont: settings.useNewFont,
          currentWeightDelta: settings.customFontWeightDelta,
          onSave: (useNew, family, weightDelta) async {
            await ref.read(settingsProvider.notifier).updateUseNewFont(useNew);
            await ref
                .read(settingsProvider.notifier)
                .updateCustomFontFamily(family);
            await ref
                .read(settingsProvider.notifier)
                .updateCustomFontWeightDelta(weightDelta);
          },
        );
      },
    );
  }

  void _showLyricsFontPicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return _FontSelectionDialog(
          title: 'Lyrics Font',
          currentFamily: settings.customFontFamilyLyrics,
          useNewFont: settings.useNewFontLyrics,
          currentWeightDelta: settings.customFontWeightLyricsDelta,
          onSave: (useNew, family, weightDelta) async {
            await ref
                .read(settingsProvider.notifier)
                .updateUseNewFontLyrics(useNew);
            await ref
                .read(settingsProvider.notifier)
                .updateCustomFontFamilyLyrics(family);
            await ref
                .read(settingsProvider.notifier)
                .updateCustomFontWeightLyricsDelta(weightDelta);
          },
        );
      },
    );
  }

  static void _showLastFmConfigDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings, {
    bool isEnabling = false,
  }) {
    final userController = TextEditingController(text: settings.lastFmUsername);
    final keyController = TextEditingController(
      text: settings.lastFmSessionKey,
    );
    bool saved = false;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(LucideIcons.radio, color: Colors.redAccent, size: 20),
            SizedBox(width: 10),
            Text(
              'Last.fm Account',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Last.fm username and authorization session key to enable scrobbling:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: userController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Session Key',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              final user = userController.text.trim();
              final key = keyController.text.trim();
              if (user.isNotEmpty && key.isNotEmpty) {
                saved = true;
                await ref
                    .read(settingsProvider.notifier)
                    .updateLastFmCredentials(username: user, sessionKey: key);
                await ref
                    .read(settingsProvider.notifier)
                    .updateEnableLastFmScrobbling(true);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
        ],
      ),
    ).then((_) {
      if (!saved &&
          isEnabling &&
          ref.read(settingsProvider).lastFmSessionKey.isEmpty) {
        ref.read(settingsProvider.notifier).updateEnableLastFmScrobbling(false);
      }
    });
  }

  static void _showListenBrainzConfigDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings, {
    bool isEnabling = false,
  }) {
    final tokenController = TextEditingController(
      text: settings.listenBrainzUserToken,
    );
    bool saved = false;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(LucideIcons.brain, color: Colors.amberAccent, size: 20),
            SizedBox(width: 10),
            Text(
              'ListenBrainz User Token',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Copy your User Token from listenbrainz.org/profile/ and paste it below:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tokenController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'ListenBrainz User Token',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              final token = tokenController.text.trim();
              if (token.isNotEmpty) {
                saved = true;
                await ref
                    .read(settingsProvider.notifier)
                    .updateListenBrainzUserToken(token);
                await ref
                    .read(settingsProvider.notifier)
                    .updateEnableListenBrainzScrobbling(true);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
        ],
      ),
    ).then((_) {
      if (!saved &&
          isEnabling &&
          ref.read(settingsProvider).listenBrainzUserToken.isEmpty) {
        ref
            .read(settingsProvider.notifier)
            .updateEnableListenBrainzScrobbling(false);
      }
    });
  }
}

class _SearchItem {
  final String category;
  final String title;
  final String subtitle;
  final Widget widget;

  const _SearchItem({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.widget,
  });
}

class _CategoryItemData {
  final SettingsCategory category;
  final String label;
  final IconData icon;

  const _CategoryItemData({
    required this.category,
    required this.label,
    required this.icon,
  });
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected
            ? accent.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? accent.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isSelected ? accent : Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
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

class _CategorySidebarTile extends StatelessWidget {
  final SettingsCategory category;
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isMedium;
  final VoidCallback onTap;

  const _CategorySidebarTile({
    required this.category,
    required this.label,
    required this.icon,
    required this.isSelected,
    this.isMedium = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final unselectedColor = Colors.white.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: label,
        waitDuration: const Duration(milliseconds: 400),
        child: Material(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            hoverColor: Colors.white.withValues(alpha: 0.05),
            child: SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Icon(
                            icon,
                            size: AppIcons.sidebarIcon.s,
                            color: isSelected ? selectedColor : unselectedColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRect(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            opacity: isMedium ? 0.0 : 1.0,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Text(
                                label,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.clip,
                                style: AppFonts.jostStyle(
                                  fontSize: 14.ts,
                                  color: isSelected
                                      ? selectedColor
                                      : unselectedColor,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isSelected)
                    Positioned(
                      right: 12,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        opacity: isMedium ? 0.0 : 1.0,
                        child: Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: selectedColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends ConsumerWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDynamic =
        settings.enableDynamicTheming || settings.keepBackgroundGradient;
    final useBlur = isDynamic && !settings.disableBlur;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PremiumSection(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                bottomLeft: Radius.circular(32),
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              useBlur: useBlur,
              useExpanded: false,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PremiumSection(
          borderRadius: BorderRadius.circular(20),
          padding: EdgeInsets.zero,
          useBlur: useBlur,
          useExpanded: false,
          child: Column(children: children),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _PremiumSwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _PremiumSwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.white.withValues(alpha: 0.05),
            height: 1,
            indent: 58,
          ),
      ],
    );
  }
}

class _PremiumActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? textColor;
  final bool isLast;

  const _PremiumActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.textColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: textColor ?? Colors.white.withValues(alpha: 0.9),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor ?? Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 16), trailing!],
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.white.withValues(alpha: 0.05),
            height: 1,
            indent: 58,
          ),
      ],
    );
  }
}

class _PremiumDropdownRow<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isLast;

  const _PremiumDropdownRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    items: items,
                    onChanged: onChanged,
                    dropdownColor: const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(10),
                    isDense: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    icon: const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(
                        LucideIcons.chevronDown,
                        color: Colors.white70,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.white.withValues(alpha: 0.05),
            height: 1,
            indent: 58,
          ),
      ],
    );
  }
}

class _PremiumSliderRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String suffix;
  final ValueChanged<double> onChanged;
  final bool isLast;

  const _PremiumSliderRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.suffix = '',
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 22,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${value.round()}$suffix',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Colors.white10,
                  thumbColor: Colors.white,
                  overlayColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.12),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                ),
                child: Slider(
                  value: value.clamp(min, max),
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.white.withValues(alpha: 0.05),
            height: 1,
            indent: 58,
          ),
      ],
    );
  }
}

class _PremiumAccentColorRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int selectedColor;
  final ValueChanged<int> onColorChanged;
  final bool isLast;

  const _PremiumAccentColorRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selectedColor,
    required this.onColorChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    const presetColors = [
      0xFF4CAF50, // Green
      0xFF2196F3, // Blue
      0xFF9C27B0, // Purple
      0xFFFF9800, // Orange
      0xFFE91E63, // Pink
      0xFF00BCD4, // Cyan
      0xFFFF5722, // Deep Orange
      0xFF673AB7, // Deep Purple
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: presetColors.map((colorVal) {
                  final isSelected = selectedColor == colorVal;
                  return GestureDetector(
                    onTap: () => onColorChanged(colorVal),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Color(colorVal),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.white.withValues(alpha: 0.05),
            height: 1,
            indent: 58,
          ),
      ],
    );
  }
}

class _FontPickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool useNewFont;
  final String customFamily;
  final int weightDelta;
  final VoidCallback onTap;
  final bool isLast;

  const _FontPickerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.useNewFont,
    required this.customFamily,
    required this.weightDelta,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  color: Colors.white38,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.white.withValues(alpha: 0.05),
            height: 1,
            indent: 58,
          ),
      ],
    );
  }
}

class _FontSelectionDialog extends StatefulWidget {
  final String title;
  final String currentFamily;
  final bool useNewFont;
  final int currentWeightDelta;
  final Function(bool useNew, String family, int weightDelta) onSave;

  const _FontSelectionDialog({
    required this.title,
    required this.currentFamily,
    required this.useNewFont,
    required this.currentWeightDelta,
    required this.onSave,
  });

  @override
  State<_FontSelectionDialog> createState() => _FontSelectionDialogState();
}

class _FontSelectionDialogState extends State<_FontSelectionDialog> {
  late bool _useNewFont;
  late String _family;
  late int _weightDelta;

  @override
  void initState() {
    super.initState();
    _useNewFont = widget.useNewFont;
    _family = widget.currentFamily;
    _weightDelta = widget.currentWeightDelta;
  }

  @override
  Widget build(BuildContext context) {
    const families = [
      '', // DM Sans default
      'Jost',
      'Inter',
      'Roboto',
      'Montserrat',
      'Open Sans',
      'Poppins',
      'Lato',
    ];

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Font Family',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...families.map((fam) {
              final label = fam.isEmpty ? 'DM Sans (Default)' : fam;
              final isSel = _family == fam;
              return RadioListTile<String>(
                title: Text(label, style: const TextStyle(color: Colors.white)),
                value: fam,
                groupValue: _family,
                activeColor: Theme.of(context).colorScheme.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _family = val;
                      _useNewFont = val.isNotEmpty;
                    });
                  }
                },
              );
            }),
            const SizedBox(height: 16),
            const Text(
              'Font Weight Adjustment',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              value: _weightDelta.toDouble(),
              min: -2,
              max: 2,
              divisions: 4,
              label: _weightDelta.toString(),
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (val) {
                setState(() => _weightDelta = val.round());
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(_useNewFont, _family, _weightDelta);
            Navigator.pop(context);
          },
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.greenAccent),
          ),
        ),
      ],
    );
  }
}

class _PremiumLibraryFoldersList extends ConsumerWidget {
  const _PremiumLibraryFoldersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final folders = settings.libraryFolders;

    if (folders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            const Icon(LucideIcons.folderX, color: Colors.white38, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'No music folders added yet.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: folders.asMap().entries.map((entry) {
        final idx = entry.key;
        final folder = entry.value;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.folder,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      folder,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.x,
                      color: Colors.white38,
                      size: 16,
                    ),
                    onPressed: () {
                      final updated = folders
                          .where((f) => f != folder)
                          .toList();
                      ref
                          .read(settingsProvider.notifier)
                          .updateLibraryFolders(updated);
                    },
                  ),
                ],
              ),
            ),
            if (idx < folders.length - 1)
              Divider(
                color: Colors.white.withValues(alpha: 0.05),
                height: 1,
                indent: 56,
              ),
          ],
        );
      }).toList(),
    );
  }
}

class _PremiumMaintainerSection extends StatelessWidget {
  const _PremiumMaintainerSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Maintainers & Contributors',
      children: const [
        _AboutMaintainerTile(
          name: 'Nilesh Suthar',
          role: 'Creator & Maintainer',
          avatar: 'assets/about/maintainer_avatar.png',
          github: 'https://github.com/SthrNilshaaa',
          telegram: 'https://t.me/neelshy',
          isLast: false,
        ),
        _AboutMaintainerTile(
          name: 'Karan Suthar',
          role: 'Designer & Maintainer',
          avatar: 'assets/about/designer_avatar.png',
          github: 'https://github.com/sthrkaran',
          telegram: 'https://t.me/karanwhy',
          isLast: false,
        ),
        _AboutMaintainerTile(
          name: 'Mikiyas Mechalo',
          role: 'Active Contributor',
          avatar: 'assets/about/miki_avatar.jpg',
          github: 'https://github.com/mikiyasmechalo',
          telegram: 'https://t.me/mikeme2',
          isLast: false,
        ),
        _AboutMaintainerTile(
          name: 'Madan Suthar',
          role: 'Active Contributor',
          avatar: 'assets/about/free_rider_avatar.png',
          github: 'https://github.com/',
          telegram: 'https://t.me/madansthr',
          isLast: true,
        ),
      ],
    );
  }
}

class _AboutMaintainerTile extends StatelessWidget {
  final String name;
  final String role;
  final String? avatar;
  final String github;
  final String telegram;
  final bool isLast;

  const _AboutMaintainerTile({
    required this.name,
    required this.role,
    this.avatar,
    required this.github,
    required this.telegram,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatar != null && avatar!.isNotEmpty;
    final hasGithub = github.isNotEmpty && github != 'https://github.com/';
    final hasTelegram = telegram.isNotEmpty && telegram != 'https://t.me/';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white12,
                backgroundImage: hasAvatar ? AssetImage(avatar!) : null,
                child: hasAvatar
                    ? null
                    : const Icon(
                        LucideIcons.user,
                        color: Colors.white60,
                        size: 20,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      role,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasGithub)
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/about/github_icon.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Colors.white70,
                      BlendMode.srcIn,
                    ),
                  ),
                  tooltip: 'GitHub',
                  onPressed: () async {
                    final uri = Uri.parse(github);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
              if (hasTelegram)
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/about/telegram_icon.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Colors.white70,
                      BlendMode.srcIn,
                    ),
                  ),
                  tooltip: 'Telegram',
                  onPressed: () async {
                    final uri = Uri.parse(telegram);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.white.withValues(alpha: 0.05),
            height: 1,
            indent: 58,
          ),
      ],
    );
  }
}
