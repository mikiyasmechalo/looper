import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';

class TrackQualityInfo {
  final Song song;
  final int fileSizeBytes;
  final int estimatedBitrateKbps;
  final String fileExtension;
  final bool hasArtwork;

  TrackQualityInfo({
    required this.song,
    required this.fileSizeBytes,
    required this.estimatedBitrateKbps,
    required this.fileExtension,
    required this.hasArtwork,
  });

  String get formattedBitrate {
    if (estimatedBitrateKbps >= 800) return 'Lossless (~$estimatedBitrateKbps kbps)';
    return '$estimatedBitrateKbps kbps';
  }

  String get formattedSize {
    final mb = fileSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  String get formattedDuration {
    final ms = song.duration ?? 0;
    if (ms <= 0) return '0:00';
    final duration = Duration(milliseconds: ms);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class DuplicateGroup {
  final String key;
  final String title;
  final String artist;
  final List<TrackQualityInfo> tracks;

  DuplicateGroup({
    required this.key,
    required this.title,
    required this.artist,
    required this.tracks,
  });
}

class LibraryCleanupState {
  final bool isScanning;
  final List<DuplicateGroup> duplicateGroups;
  final List<TrackQualityInfo> lowBitrateTracks;
  final List<TrackQualityInfo> missingArtworkTracks;
  final List<TrackQualityInfo> shortAudioTracks;
  final Set<int> selectedSongIdsToDelete;

  const LibraryCleanupState({
    this.isScanning = true,
    this.duplicateGroups = const [],
    this.lowBitrateTracks = const [],
    this.missingArtworkTracks = const [],
    this.shortAudioTracks = const [],
    this.selectedSongIdsToDelete = const {},
  });

  LibraryCleanupState copyWith({
    bool? isScanning,
    List<DuplicateGroup>? duplicateGroups,
    List<TrackQualityInfo>? lowBitrateTracks,
    List<TrackQualityInfo>? missingArtworkTracks,
    List<TrackQualityInfo>? shortAudioTracks,
    Set<int>? selectedSongIdsToDelete,
  }) {
    return LibraryCleanupState(
      isScanning: isScanning ?? this.isScanning,
      duplicateGroups: duplicateGroups ?? this.duplicateGroups,
      lowBitrateTracks: lowBitrateTracks ?? this.lowBitrateTracks,
      missingArtworkTracks: missingArtworkTracks ?? this.missingArtworkTracks,
      shortAudioTracks: shortAudioTracks ?? this.shortAudioTracks,
      selectedSongIdsToDelete: selectedSongIdsToDelete ?? this.selectedSongIdsToDelete,
    );
  }
}

final libraryCleanupProvider =
    StateNotifierProvider<LibraryCleanupNotifier, LibraryCleanupState>((ref) {
  return LibraryCleanupNotifier(ref);
});

class LibraryCleanupNotifier extends StateNotifier<LibraryCleanupState> {
  final Ref _ref;

  LibraryCleanupNotifier(this._ref) : super(const LibraryCleanupState()) {
    scanLibrary();
  }

  Future<void> scanLibrary() async {
    state = state.copyWith(isScanning: true, selectedSongIdsToDelete: {});

    final songs = await DbService.isar.songs.where().findAll();
    final List<TrackQualityInfo> qualityList = [];

    for (final song in songs) {
      int size = 0;
      try {
        final file = File(song.path);
        if (file.existsSync()) {
          size = file.lengthSync();
        }
      } catch (_) {}

      final durationSec = (song.duration ?? 0) / 1000.0;
      int bitrate = 0;
      if (durationSec > 0 && size > 0) {
        bitrate = ((size * 8) / (durationSec * 1000)).round();
      }

      final ext = song.path.contains('.')
          ? song.path.split('.').last.toUpperCase()
          : 'AUDIO';

      bool hasArt = false;
      if (song.artPath != null && song.artPath!.isNotEmpty) {
        try {
          hasArt = File(song.artPath!).existsSync();
        } catch (_) {}
      }

      qualityList.add(TrackQualityInfo(
        song: song,
        fileSizeBytes: size,
        estimatedBitrateKbps: bitrate > 0 ? bitrate : 192,
        fileExtension: ext,
        hasArtwork: hasArt,
      ));
    }

    // 1. Group Duplicates with Unicode-safe normalization and duration bucketing
    final Map<String, List<TrackQualityInfo>> groupMap = {};
    for (final item in qualityList) {
      final rawTitle = item.song.title.trim();
      if (rawTitle.isEmpty) continue;

      final normTitle = _normalizeString(rawTitle);
      final normArtist = _normalizeString(item.song.artist ?? '');

      final durSec = ((item.song.duration ?? 0) / 1000).round();
      final durBucket = (durSec / 10).round() * 10;

      final String key;
      if (normArtist.isNotEmpty && normArtist != 'unknown' && normArtist != 'unknown artist') {
        key = '${normTitle}___${normArtist}___$durBucket';
      } else {
        key = '${normTitle}___noartist___$durBucket';
      }
      groupMap.putIfAbsent(key, () => []).add(item);
    }

    final duplicateGroups = groupMap.entries
        .where((e) => e.value.length > 1)
        .map((e) {
          final first = e.value.first;
          // Sort tracks by bitrate descending
          final sortedTracks = List<TrackQualityInfo>.from(e.value)
            ..sort((a, b) => b.estimatedBitrateKbps.compareTo(a.estimatedBitrateKbps));

          return DuplicateGroup(
            key: e.key,
            title: first.song.title,
            artist: first.song.artist ?? 'Unknown Artist',
            tracks: sortedTracks,
          );
        })
        .toList();

    // 2. Low Bitrate (< 160 kbps, excluding streams)
    final lowBitrate = qualityList.where((item) {
      return item.estimatedBitrateKbps > 0 &&
          item.estimatedBitrateKbps < 160 &&
          (item.song.duration ?? 0) > 30000;
    }).toList();

    // 3. Missing Artwork
    final missingArt = qualityList.where((item) => !item.hasArtwork).toList();

    // 4. Short audio (< 30s)
    final shortAudio = qualityList.where((item) {
      final dur = item.song.duration ?? 0;
      return dur > 0 && dur < 30000;
    }).toList();

    state = state.copyWith(
      isScanning: false,
      duplicateGroups: duplicateGroups,
      lowBitrateTracks: lowBitrate,
      missingArtworkTracks: missingArt,
      shortAudioTracks: shortAudio,
    );
  }

  String _normalizeString(String str) {
    final cleaned = str
        .toLowerCase()
        .replaceAll(RegExp(r'[\p{P}\p{S}]', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isNotEmpty) {
      return cleaned;
    }
    return str.toLowerCase().trim();
  }

  void toggleSelectToDelete(int songId) {
    final current = Set<int>.from(state.selectedSongIdsToDelete);
    if (current.contains(songId)) {
      current.remove(songId);
    } else {
      current.add(songId);
    }
    state = state.copyWith(selectedSongIdsToDelete: current);
  }

  void selectAll(Iterable<int> songIds) {
    final current = Set<int>.from(state.selectedSongIdsToDelete)..addAll(songIds);
    state = state.copyWith(selectedSongIdsToDelete: current);
  }

  void deselectAll(Iterable<int> songIds) {
    final current = Set<int>.from(state.selectedSongIdsToDelete)..removeAll(songIds);
    state = state.copyWith(selectedSongIdsToDelete: current);
  }

  /// Automatically selects all lower-quality duplicate tracks in each duplicate group
  void selectLowerQualityDuplicates() {
    final toDelete = <int>{};
    for (final group in state.duplicateGroups) {
      if (group.tracks.length > 1) {
        // Keep the best (index 0) and mark all lower ones (index 1..N)
        for (int i = 1; i < group.tracks.length; i++) {
          toDelete.add(group.tracks[i].song.id);
        }
      }
    }
    state = state.copyWith(selectedSongIdsToDelete: toDelete);
  }

  void clearSelection() {
    state = state.copyWith(selectedSongIdsToDelete: {});
  }

  Future<int> deleteSelectedTracks({bool deleteFromDisk = true}) async {
    final idsToDelete = state.selectedSongIdsToDelete.toList();
    if (idsToDelete.isEmpty) return 0;

    int deletedCount = 0;
    for (final id in idsToDelete) {
      final song = await DbService.isar.songs.get(id);
      if (song != null) {
        if (deleteFromDisk) {
          try {
            final file = File(song.path);
            if (file.existsSync()) {
              file.deleteSync();
            }
          } catch (e) {
            debugPrint('Failed to delete file from disk: $e');
          }
        }
        await DbService.isar.writeTxn(() async {
          await DbService.isar.songs.delete(id);
        });
        deletedCount++;
      }
    }

    await _ref.read(playbackProvider.notifier).removeDeletedSongsFromQueue(idsToDelete);
    await scanLibrary();
    return deletedCount;
  }
}
