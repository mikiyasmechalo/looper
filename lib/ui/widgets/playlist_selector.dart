import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/core/providers.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/widgets/app_input_dialog.dart';

/// Prompts for a new playlist name, creates it with [songPaths] already added,
/// and shows a confirmation snackbar. Lets users create + add to a playlist
/// directly from the "Add to Playlist" dialog without leaving the current view.
Future<void> showCreatePlaylistWithSongs(
  BuildContext context,
  WidgetRef ref, {
  required List<String> songPaths,
}) async {
  final l10n = AppLocalizations.of(context)!;
  await showDialog<void>(
    context: context,
    builder: (_) => AppInputDialog(
      title: l10n.newPlaylist,
      hint: l10n.createPlaylist,
      confirmLabel: l10n.create,
      onConfirm: (name) async {
        final playlist = Playlist()
          ..name = name.trim()
          ..songPaths = List<String>.from(songPaths)
          ..dateCreated = DateTime.now()
          ..dateModified = DateTime.now();
        await DbService.isar.writeTxn(
          () => DbService.isar.playlists.put(playlist),
        );
        scaffoldMessengerKey.currentState?.clearSnackBars();
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(l10n.addedTo(playlist.name)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    ),
  );
}