import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:intl/intl.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/l10n/app_localizations.dart';

class SongDetailsBottomSheet extends ConsumerWidget {
  final Song song;

  const SongDetailsBottomSheet({super.key, required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final accent = Theme.of(context).colorScheme.primary;
    final useBlur = !settings.disableBlur && !settings.isBatterySaverActive;
    final isPureBlack = settings.isBatterySaverActive ||
        (settings.darkTheme && !useBlur);
    final sheetBg = isPureBlack
        ? Colors.black
        : (useBlur ? const Color(0x66141418) : const Color(0xFF1E1E1E));

    Widget content = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: useBlur && !isPureBlack
            ? Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1)
            : (isPureBlack ? Border.all(color: Colors.white12, width: 1) : null),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Song Details',
            style: AppFonts.jostStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _detailItem(
            context,
            'Title',
            song.title,
          ),
          _detailItem(
            context,
            'Artist',
            song.artist ?? 'Unknown',
            accentColor: song.artist == null ? null : accent,
            onTap: song.artist == null
                ? null
                : () => _openArtist(context, ref, l10n),
          ),
          _detailItem(
            context,
            'Album',
            song.album ?? 'Unknown',
            accentColor: song.album == null ? null : accent,
            onTap: song.album == null
                ? null
                : () => _openAlbum(context, ref, l10n),
          ),
          if (song.albumArtist != null && song.albumArtist!.isNotEmpty)
            _detailItem(context, 'Album Artist', song.albumArtist!),
          if (song.trackNumber != null && song.trackNumber! > 0)
            _detailItem(
              context,
              'Track Number',
              song.trackTotal != null && song.trackTotal! > 0
                  ? '${song.trackNumber}/${song.trackTotal}'
                  : song.trackNumber.toString(),
            ),
          if (song.discNumber != null && song.discNumber! > 0)
            _detailItem(
              context,
              'Disc Number',
              song.discTotal != null && song.discTotal! > 0
                  ? '${song.discNumber}/${song.discTotal}'
                  : song.discNumber.toString(),
            ),
          _detailItem(
            context,
            'Duration',
            song.duration != null
                ? UiUtils.formatDurationMs(song.duration)
                : 'Unknown',
          ),
          _detailItem(
            context,
            'Play Count',
            '${song.playCount} times',
          ),
          if (song.lastPlayed != null)
            _detailItem(
              context,
              'Last Played',
              DateFormat('MMM dd, yyyy HH:mm').format(song.lastPlayed!),
            ),
          _detailItem(context, 'File Path', song.path),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: useBlur
                    ? Colors.white.withValues(alpha: 0.08)
                    : Theme.of(context).colorScheme.surfaceContainer,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );

    if (useBlur && !isPureBlack) {
      return RepaintBoundary(
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: content,
          ),
        ),
      );
    }

    return content;
  }

  Future<void> _openArtist(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final artistName = song.artist;
    if (artistName == null) return;
    Navigator.pop(context);

    ref.read(appNavigationProvider.notifier).setPlayerExpansion(false);

    final artistSongs = await DbService.isar.songs
        .filter()
        .artistEqualTo(artistName)
        .or()
        .albumArtistEqualTo(artistName)
        .findAll();

    final artist = await DbService.isar.artists
        .filter()
        .nameEqualTo(artistName)
        .findFirst();

    ref
        .read(appNavigationProvider.notifier)
        .showCollection(
          title: artistName,
          subtitle: l10n.artists,
          art: artist?.artPath ?? song.artPath,
          imageUrl: artist?.artistImageUrl,
          images: artist?.artistImages ?? const [],
          songs: artistSongs,
          highlightItem: NavItem.artists,
        );
  }

  Future<void> _openAlbum(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final albumName = song.album;
    if (albumName == null) return;
    Navigator.pop(context);

    ref.read(appNavigationProvider.notifier).setPlayerExpansion(false);

    final album = await DbService.isar.albums
        .filter()
        .nameEqualTo(albumName)
        .findFirst();

    final albumSongs = await DbService.isar.songs
        .filter()
        .albumEqualTo(albumName)
        .findAll();

    ref
        .read(appNavigationProvider.notifier)
        .showCollection(
          title: albumName,
          subtitle: album?.artist ?? song.artist ?? l10n.albums,
          art: album?.artPath ?? song.artPath,
          songs: albumSongs,
          highlightItem: NavItem.albums,
        );
  }

  Widget _detailItem(
    BuildContext context,
    String label,
    String value, {
    Color? accentColor,
    VoidCallback? onTap,
  }) {
    final clickable = onTap != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.jostStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: AppFonts.jostStyle(
                        color: clickable
                            ? accentColor ?? Colors.white
                            : Colors.white,
                        fontSize: 14,
                        fontWeight: clickable
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (clickable) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.north_east,
                      size: 14,
                      color: accentColor,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
