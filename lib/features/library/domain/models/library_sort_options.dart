import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AlbumSortOption {
  name,
  dateAdded,
  year,
  songCount,
  artistAlbumArtist,
}

enum ArtistSortOption { name, songCount }

enum GenreSortOption { nameAsc, nameDesc, songCountDesc, songCountAsc }

final albumSortProvider = StateProvider<AlbumSortOption>(
  (ref) => AlbumSortOption.name,
);
final albumSortAscendingProvider = StateProvider<bool>((ref) => true);
final artistSortProvider = StateProvider<ArtistSortOption>(
  (ref) => ArtistSortOption.name,
);
final artistSortAscendingProvider = StateProvider<bool>((ref) => true);
final genreSortProvider = StateProvider<GenreSortOption>(
  (ref) => GenreSortOption.nameAsc,
);
final artistViewModeProvider = StateProvider<bool>(
  (ref) => false,
);
