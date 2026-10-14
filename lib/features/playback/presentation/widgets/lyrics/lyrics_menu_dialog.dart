import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/app_haptics.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/data/lyrics_fetcher.dart';
import 'package:looper_player/features/playback/data/lyrics_providers/lyrics_provider_info.dart';
import 'package:looper_player/features/playback/presentation/lyrics_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/features/settings/presentation/widgets/lyrics_services_sheet.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';

import 'desktop_lyrics_toolbar.dart';
import 'lyrics_scale.dart';

/// Desktop lyrics options and provider selector dialog.
void showLyricsMenuDialog(BuildContext context, WidgetRef ref, Song song) {
  final settings = ref.read(settingsProvider);
  final useBlur = (settings.enableDynamicTheming || settings.keepBackgroundGradient) &&
      !settings.disableBlur &&
      !settings.isBatterySaverActive;

  showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: useBlur
              ? BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: _LyricsMenuDialogContent(song: song),
                )
              : _LyricsMenuDialogContent(song: song),
        ),
      ),
    ),
  );
}

class _LyricsMenuDialogContent extends ConsumerWidget {
  final Song song;

  const _LyricsMenuDialogContent({required this.song});

  String _formatSourceLabel(AppLocalizations l10n, String? source) {
    if (source == null || source.isEmpty) return l10n.noLyricsSource;
    final name = switch (source.toLowerCase()) {
      'embedded' => l10n.lyricsSourceEmbedded,
      'local' => l10n.lyricsSourceLocalSidecar,
      'custom_file' => l10n.lyricsSourceCustomFile,
      'lrc.red' => 'lrc.red',
      'lyricsplus' => 'LyricsPlus',
      'lrclib' => 'LRCLIB',
      'genius' => 'Genius',
      'musixmatch' => 'Musixmatch',
      'azlyrics' => 'AZLyrics',
      'lyricsmint' => 'LyricsMINT',
      'lyricfind' => 'LyricFind',
      'netease' => 'NetEase',
      'kugou' => 'KuGou',
      'amll' => 'AMLL',
      'lyricify' => 'Lyricify',
      'not_found' => l10n.lyricsSourceNotFoundOnline,
      _ => source.toUpperCase(),
    };
    return l10n.lyricsSourceLabel(name);
  }

  String _formatDuration(int durationMs) {
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final lyricsState = ref.watch(lyricsProvider);
    final accent = Color(settings.accentColor);
    final isWordSynced = lyricsState.parsedLines.any((l) => l.hasWordTiming);
    final isSynced = lyricsState.isSynced;
    final hasLyrics = lyricsState.parsedLines.isNotEmpty;
    final lyricsScale = LyricsScale.normalize(settings.lyricsFontScale);

    final syncStyle = switch (settings.lyricsSyncStyle) {
      'line' || 'word' => settings.lyricsSyncStyle,
      _ => 'char',
    };

    final availableProviders = [
      'Local',
      for (final id in LyricsFetcher.providerOrder(settings))
        LyricsProviderInfo.of(id)?.label ?? id,
    ];

    final useBlur = (settings.enableDynamicTheming || settings.keepBackgroundGradient) &&
        !settings.disableBlur &&
        !settings.isBatterySaverActive;

    return Container(
      decoration: BoxDecoration(
        color: useBlur ? const Color(0xCC161618) : const Color(0xFF161618),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: useBlur ? 0.14 : 0.1),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Artwork, Song Info & Close
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: OptimizedImage(
                      imagePath: song.artPath,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.jostStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${song.artist ?? l10n.unknownArtist} • ${_formatDuration(song.duration ?? 0)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.jostStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, color: Colors.white54, size: 20),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Source & Sync Badges
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.disc, size: 13, color: accent),
                        const SizedBox(width: 6),
                        Text(
                          _formatSourceLabel(l10n, lyricsState.source),
                          style: AppFonts.jostStyle(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasLyrics)
                    _SyncBadge(
                      wordSynced: isWordSynced,
                      synced: isSynced,
                      accent: accent,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Timing Synchronizer Section
              _MenuSection(
                children: [
                  if (hasLyrics && isSynced)
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: _LyricsOffsetControl(
                        offsetMs: lyricsState.songId == song.id
                            ? lyricsState.songOffsetMs
                            : lyricsShiftMs(song.lyricsOffsetMs),
                        accent: accent,
                        onChanged: (ms) => ref
                            .read(lyricsProvider.notifier)
                            .updateSongOffsetMs(song, ms),
                      ),
                    ),
                  if (isWordSynced)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(l10n.lyricsHighlightStyle),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final (value, label) in [
                                ('line', l10n.lyricsStyleLine),
                                ('word', l10n.lyricsStyleWord),
                                ('char', l10n.lyricsStyleCharacter),
                              ])
                                _MenuChip(
                                  label: label,
                                  selected: syncStyle == value,
                                  accent: accent,
                                  onSelected: () {
                                    AppHaptics.selection();
                                    ref
                                        .read(settingsProvider.notifier)
                                        .updateLyricsSyncStyle(value);
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else if (hasLyrics && !isSynced)
                    _MenuActionTile(
                      icon: LucideIcons.searchCheck,
                      iconColor: accent,
                      title: l10n.findSyncedLyrics,
                      onTap: () async {
                        AppHaptics.medium();
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(context);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(l10n.searchingSyncedLyrics),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        final found = await ref
                            .read(lyricsProvider.notifier)
                            .findSynced(song);
                        messenger.showHapticSnackBar(
                          found ? AppHaptics.success : AppHaptics.error,
                          SnackBar(
                            content: Text(
                              found
                                  ? l10n.syncedLyricsLoaded
                                  : l10n.noSyncedLyricsFound,
                            ),
                          ),
                        );
                      },
                    )
                  else
                    _MenuActionTile(
                      icon: LucideIcons.sparkles,
                      iconColor: accent,
                      title: l10n.findWordSyncedLyrics,
                      onTap: () async {
                        AppHaptics.medium();
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(context);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(l10n.searchingWordSyncedLyrics),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        final found = await ref
                            .read(lyricsProvider.notifier)
                            .findWordSynced(song);
                        messenger.showHapticSnackBar(
                          found ? AppHaptics.success : AppHaptics.error,
                          SnackBar(
                            content: Text(
                              found
                                  ? l10n.wordSyncedLyricsLoaded
                                  : l10n.noWordSyncedLyricsFound,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Lyrics Provider Selection Section
              _MenuSection(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _SectionLabel(l10n.changeLyricsProvider),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                showLyricsServicesDialog(context);
                              },
                              icon: const Icon(LucideIcons.settings2, size: 14),
                              label: Text(
                                l10n.lyricsServices,
                                style: AppFonts.jostStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: availableProviders.map((provider) {
                            final isLocalSource =
                                lyricsState.source == 'embedded' ||
                                lyricsState.source == 'local';
                            final isSelected =
                                (provider.toLowerCase() == 'local' &&
                                    isLocalSource) ||
                                (lyricsState.source?.toLowerCase() ==
                                    provider.toLowerCase());
                            return _MenuChip(
                              label: provider == 'Local'
                                  ? l10n.lyricsProviderLocal
                                  : provider,
                              selected: isSelected,
                              accent: accent,
                              onSelected: () async {
                                if (isSelected) return;
                                AppHaptics.medium();
                                final messenger = ScaffoldMessenger.of(context);
                                Navigator.pop(context);

                                if (provider != 'Local' &&
                                    !await LyricsFetcher.hasAnswer(song, provider)) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.fetchingLyricsFrom(provider)),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }

                                final source = await ref
                                    .read(lyricsProvider.notifier)
                                    .fetchWithProvider(song, provider);

                                final String resultMsg;
                                if (source == null) {
                                  resultMsg = provider == 'Local'
                                      ? l10n.noLocalLyricsFound
                                      : l10n.noLyricsFoundOn(provider);
                                } else if (source == 'embedded' || source == 'local') {
                                  resultMsg = l10n.loadedLocalLyrics;
                                } else {
                                  resultMsg = l10n.lyricsUpdatedFrom(
                                    availableProviders.firstWhere(
                                      (p) => p.toLowerCase() == source,
                                      orElse: () => source,
                                    ),
                                  );
                                }
                                messenger.showHapticSnackBar(
                                  source == null ? AppHaptics.error : AppHaptics.success,
                                  SnackBar(content: Text(resultMsg)),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  _MenuSwitchTile(
                    icon: LucideIcons.layers,
                    title: l10n.autoFallbackProviders,
                    subtitle: l10n.autoFallbackProvidersDesc,
                    value: settings.autoLyricsFallback,
                    accent: accent,
                    onChanged: (val) => ref
                        .read(settingsProvider.notifier)
                        .updateAutoLyricsFallback(val),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Desktop Display & Size Controls
              _MenuSection(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    dense: true,
                    leading: const _MenuIcon(LucideIcons.type),
                    title: Text(
                      l10n.lyricsSize,
                      style: AppFonts.jostStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    trailing: LyricsSizeControl(
                      scale: lyricsScale,
                      onSmaller: () => ref
                          .read(settingsProvider.notifier)
                          .updateLyricsFontScale(
                            LyricsScale.stepBy(lyricsScale, -1),
                          ),
                      onLarger: () => ref
                          .read(settingsProvider.notifier)
                          .updateLyricsFontScale(
                            LyricsScale.stepBy(lyricsScale, 1),
                          ),
                      onReset: () => ref
                          .read(settingsProvider.notifier)
                          .updateLyricsFontScale(1.0),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // File Import/Export Section
              _MenuSection(
                children: [
                  _MenuActionTile(
                    icon: LucideIcons.download,
                    title: l10n.exportLyricsLrc,
                    subtitle: l10n.saveLyricsToDevice,
                    onTap: () async {
                      AppHaptics.medium();
                      Navigator.pop(context);

                      final rawLrc = lyricsState.rawLrc;
                      if (rawLrc == null || rawLrc.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.noLyricsToExport)),
                        );
                        return;
                      }

                      try {
                        final safeArtist = (song.artist ?? 'Artist').replaceAll(
                          RegExp(r'[^a-zA-Z0-9_\-]'),
                          '_',
                        );
                        final safeTitle = song.title.replaceAll(
                          RegExp(r'[^a-zA-Z0-9_\-]'),
                          '_',
                        );
                        final defaultFileName = '$safeArtist - $safeTitle.lrc';

                        final exportPath = await FilePicker.platform.saveFile(
                          dialogTitle: l10n.exportLyrics,
                          fileName: defaultFileName,
                          bytes: Uint8List.fromList(rawLrc.codeUnits),
                        );

                        if (context.mounted && exportPath != null) {
                          ScaffoldMessenger.of(context).showHapticSnackBar(
                            AppHaptics.success,
                            SnackBar(content: Text(l10n.lyricsExportedTo(exportPath))),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showHapticSnackBar(
                            AppHaptics.error,
                            SnackBar(content: Text(l10n.failedToExportLyrics('$e'))),
                          );
                        }
                      }
                    },
                  ),
                  _MenuActionTile(
                    icon: LucideIcons.filePlus,
                    title: l10n.useCustomLyricsLrc,
                    subtitle: l10n.selectLocalLrcFile,
                    onTap: () async {
                      AppHaptics.medium();
                      Navigator.pop(context);

                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['lrc', 'txt'],
                      );

                      if (result != null && result.files.single.path != null) {
                        final file = File(result.files.single.path!);
                        final content = await file.readAsString();

                        if (content.trim().isNotEmpty) {
                          await ref
                              .read(lyricsProvider.notifier)
                              .applyCustomLyrics(song, content);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.customLyricsAppliedSuccess)),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lyrics timing offset control with quick -0.25s / +0.25s buttons,
/// -100ms / +100ms fine-tuning, and reset.
class _LyricsOffsetControl extends StatelessWidget {
  static const int _step100 = 100;
  static const int _step250 = 250; // +0.25s option requested by user

  final int offsetMs;
  final Color accent;
  final ValueChanged<int> onChanged;

  const _LyricsOffsetControl({
    required this.offsetMs,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const int defaultMs = AppSettings.defaultLyricsOffsetMs;
    final bool isDefault = offsetMs == defaultMs;
    final seconds = (offsetMs / 1000).toStringAsFixed(2);
    final label = offsetMs > 0 ? '+$seconds s' : '$seconds s';

    Widget stepButton(IconData icon, String tooltip, int delta) => IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 18, color: Colors.white70),
      onPressed: () {
        AppHaptics.selection();
        onChanged(offsetMs + delta);
      },
    );

    Widget quarterSecButton(String text, int delta) => InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        AppHaptics.selection();
        onChanged(offsetMs + delta);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Text(
          text,
          style: AppFonts.jostStyle(
            color: accent,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.lyricsTiming,
          style: AppFonts.jostStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          l10n.lyricsTimingDesc,
          style: AppFonts.jostStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            quarterSecButton('-0.25s', -_step250),
            const SizedBox(width: 4),
            stepButton(LucideIcons.minus, l10n.lyricsTimingLater, -_step100),
            Container(
              constraints: const BoxConstraints(minWidth: 76),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isDefault ? Colors.white : accent).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                label,
                style: AppFonts.jostStyle(
                  color: isDefault ? Colors.white70 : accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            stepButton(LucideIcons.plus, l10n.lyricsTimingEarlier, _step100),
            const SizedBox(width: 4),
            quarterSecButton('+0.25s', _step250),
            const Spacer(),
            if (!isDefault)
              TextButton(
                onPressed: () {
                  AppHaptics.selection();
                  onChanged(defaultMs);
                },
                child: Text(
                  l10n.lyricsTimingReset,
                  style: AppFonts.jostStyle(color: accent, fontSize: 13),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<Widget> children;

  const _MenuSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppFonts.jostStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _MenuIcon(this.icon, {this.color = Colors.white70});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

class _MenuActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: _MenuIcon(icon, color: iconColor),
      title: Text(
        title,
        style: AppFonts.jostStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: AppFonts.jostStyle(color: Colors.white54, fontSize: 12),
            ),
      trailing: const Icon(LucideIcons.chevronRight, color: Colors.white38, size: 16),
      onTap: onTap,
    );
  }
}

class _MenuSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color accent;
  final ValueChanged<bool> onChanged;

  const _MenuSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.only(left: 14, right: 10),
      dense: true,
      visualDensity: VisualDensity.compact,
      activeColor: accent,
      secondary: _MenuIcon(icon),
      title: Text(
        title,
        style: AppFonts.jostStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppFonts.jostStyle(color: Colors.white54, fontSize: 12),
      ),
      value: value,
      onChanged: (val) {
        AppHaptics.light();
        onChanged(val);
      },
    );
  }
}

class _SyncBadge extends StatelessWidget {
  final bool wordSynced;
  final bool synced;
  final Color accent;

  const _SyncBadge({
    required this.wordSynced,
    required this.synced,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = wordSynced ? accent : Colors.white54;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            wordSynced
                ? LucideIcons.sparkles
                : synced
                ? LucideIcons.alignLeft
                : LucideIcons.timerOff,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            wordSynced
                ? l10n.lyricsWordSynced
                : synced
                ? l10n.lyricsLineSynced
                : l10n.lyricsNotSynced,
            style: AppFonts.jostStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onSelected;

  const _MenuChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: AppFonts.jostStyle(
          color: selected ? Colors.white : Colors.white70,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12.5,
        ),
      ),
      selected: selected,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      selectedColor: accent,
      backgroundColor: Colors.white.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? accent : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      onSelected: (_) => onSelected(),
    );
  }
}
