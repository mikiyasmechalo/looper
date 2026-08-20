import 'package:isar/isar.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/core/tag_writer_service.dart';
import 'package:looper_player/features/library/domain/models/models.dart';

class ArtistRepository {
  /// Consolidates duplicate artist entities that differ only in letter casing
  /// (e.g. "24kGoldn", "24kgolden", "24KGOLDEN"). Merges artist image collages
  /// and points all song records to the canonical display name.
  static Future<void> consolidateArtists() async {
    final allArtists = await DbService.isar.artists.where().findAll();
    if (allArtists.isEmpty) return;

    final Map<String, List<Artist>> grouped = {};
    for (final artist in allArtists) {
      final key = artist.name.trim().toLowerCase();
      if (key.isEmpty) continue;
      (grouped[key] ??= []).add(artist);
    }

    final List<Artist> artistsToPut = [];
    final List<Id> artistIdsToDelete = [];
    final Map<String, String> renamedCaseMap = {}; // lowerKey -> canonicalName

    for (final entry in grouped.entries) {
      final list = entry.value;
      if (list.length == 1) continue;

      // Choose canonical artist:
      // 1. Prefer artist with downloaded/user images or custom artwork.
      // 2. Otherwise prefer mixed-case / capitalized name over all-caps or all-lowercase.
      list.sort((a, b) {
        final aScore = _casingScore(a);
        final bScore = _casingScore(b);
        return bScore.compareTo(aScore);
      });

      final canonical = list.first;
      final duplicates = list.sublist(1);

      // Merge image paths across all duplicate variants
      final Set<String> mergedImages = Set<String>.from(canonical.artistImages);
      for (final dup in duplicates) {
        mergedImages.addAll(dup.artistImages);
        if (canonical.artistImageUrl == null && dup.artistImageUrl != null) {
          canonical.artistImageUrl = dup.artistImageUrl;
        }
        if (canonical.artPath == null && dup.artPath != null) {
          canonical.artPath = dup.artPath;
        }
        artistIdsToDelete.add(dup.id);
      }

      canonical.artistImages = mergedImages.toList();
      artistsToPut.add(canonical);
      renamedCaseMap[entry.key] = canonical.name;
    }

    if (artistIdsToDelete.isNotEmpty || artistsToPut.isNotEmpty) {
      await DbService.isar.writeTxn(() async {
        if (artistsToPut.isNotEmpty) {
          await DbService.isar.artists.putAll(artistsToPut);
        }
        if (artistIdsToDelete.isNotEmpty) {
          await DbService.isar.artists.deleteAll(artistIdsToDelete);
        }
      });
    }

    // Update song records where artist casing differs from canonical display name
    if (renamedCaseMap.isNotEmpty) {
      final allSongs = await DbService.isar.songs.where().findAll();
      final List<Song> songsToUpdate = [];

      for (final song in allSongs) {
        bool changed = false;
        if (song.artist != null) {
          final lower = song.artist!.trim().toLowerCase();
          final canonical = renamedCaseMap[lower];
          if (canonical != null && song.artist != canonical) {
            song.artist = canonical;
            changed = true;
          }
        }
        if (song.albumArtist != null) {
          final lower = song.albumArtist!.trim().toLowerCase();
          final canonical = renamedCaseMap[lower];
          if (canonical != null && song.albumArtist != canonical) {
            song.albumArtist = canonical;
            changed = true;
          }
        }
        if (changed) {
          songsToUpdate.add(song);
        }
      }

      if (songsToUpdate.isNotEmpty) {
        await DbService.isar.writeTxn(() async {
          await DbService.isar.songs.putAll(songsToUpdate);
        });
      }
    }
  }

  /// Calculates a casing preference score.
  /// Prefers TitleCase / camelCase / MixedCase over ALLCAPS or alllowercase.
  static int _casingScore(Artist artist) {
    int score = 0;
    if (artist.artistImageUrl != null && artist.artistImageUrl!.isNotEmpty) score += 50;
    if (artist.artistImages.isNotEmpty) score += 30;
    if (artist.artPath != null && artist.artPath!.isNotEmpty) score += 20;

    final name = artist.name;
    if (name.isEmpty) return score;

    final isAllUpper = name == name.toUpperCase() && name != name.toLowerCase();
    final isAllLower = name == name.toLowerCase() && name != name.toUpperCase();

    if (!isAllUpper && !isAllLower) {
      score += 15; // Mixed case or Title Case
    } else if (isAllLower) {
      score += 5;
    }
    return score;
  }

  /// Finds an existing artist case-insensitively or creates a new one.
  static Future<Artist> findOrCreateArtist(String name) async {
    final existing = await DbService.isar.artists
        .filter()
        .nameEqualTo(name.trim(), caseSensitive: false)
        .findFirst();

    if (existing != null) return existing;

    final artist = Artist()..name = name.trim();
    await DbService.isar.writeTxn(() => DbService.isar.artists.put(artist));
    return artist;
  }

  /// Renames an artist across all database records and writes updated metadata tags
  /// to the matching audio files.
  static Future<void> renameArtist({
    required Artist artist,
    required String newName,
    required List<Song> songs,
    String? newImageUrl,
    void Function(int current, int total)? onProgress,
  }) async {
    final cleanNewName = newName.trim();
    if (cleanNewName.isEmpty) return;

    final oldName = artist.name;

    // 1. Write tags to physical audio files
    for (int i = 0; i < songs.length; i++) {
      final song = songs[i];
      onProgress?.call(i + 1, songs.length);

      final bool isTrackArtist = song.artist != null &&
          song.artist!.trim().toLowerCase() == oldName.toLowerCase();
      final bool isAlbumArtist = song.albumArtist != null &&
          song.albumArtist!.trim().toLowerCase() == oldName.toLowerCase();

      await TagWriterService.writeToFile(
        filePath: song.path,
        artist: isTrackArtist ? cleanNewName : null,
        albumArtist: isAlbumArtist ? cleanNewName : null,
      );

      if (isTrackArtist) song.artist = cleanNewName;
      if (isAlbumArtist) song.albumArtist = cleanNewName;
    }

    // 2. Update database records
    await DbService.isar.writeTxn(() async {
      await DbService.isar.songs.putAll(songs);

      artist.name = cleanNewName;
      if (newImageUrl != null && newImageUrl.isNotEmpty) {
        artist.artistImageUrl = newImageUrl;
        if (!artist.artistImages.contains(newImageUrl)) {
          artist.artistImages = [newImageUrl, ...artist.artistImages];
        }
      }
      await DbService.isar.artists.put(artist);
    });

    // 3. Consolidate to ensure no duplicate casing variants remain
    await consolidateArtists();
  }
}
