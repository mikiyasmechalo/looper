import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playlists/data/smart_playlist_service.dart';
import 'package:looper_player/features/playlists/domain/smart_playlist.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';

/// StreamProvider that emits the active list of computed [SmartPlaylist]s.
/// Reactively auto-updates when songs are played, favorited, or scanned.
final smartPlaylistsProvider = StreamProvider<List<SmartPlaylist>>((ref) {
  final isEnabled = ref.watch(settingsProvider.select((s) => s.enableSmartPlaylists));

  if (!isEnabled) {
    return Stream.value(const <SmartPlaylist>[]);
  }

  return DbService.isar.songs
      .where()
      .watch(fireImmediately: true)
      .map((allSongs) => SmartPlaylistService.computeSmartPlaylists(allSongs));
});
