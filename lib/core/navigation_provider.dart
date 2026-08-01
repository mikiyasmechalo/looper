import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/domain/models/models.dart';

enum NavItem {
  home,
  songs,
  albums,
  artists,
  playlists,
  search,
  favorites,
  recentlyPlayed,
  lyrics,
  settings,
  collectionDetail,
  queue,
  genres,
  folders,
  history,
  mostPlayed,
  downloads,
  smartCollections,
  library,
}

class NavigationState {
  final NavItem activeItem;
  final NavItem? highlightItem;
  final String? collectionTitle;
  final String? collectionSubtitle;
  final String? collectionArt;
  final String? collectionImageUrl;
  final List<String> collectionImages;
  final List<Song> collectionSongs;
  final Playlist? activePlaylist;
  final List<NavigationState> history;
  final bool isPlayerExpanded;

  NavigationState({
    required this.activeItem,
    this.highlightItem,
    this.collectionTitle,
    this.collectionSubtitle,
    this.collectionArt,
    this.collectionImageUrl,
    this.collectionImages = const [],
    this.collectionSongs = const [],
    this.activePlaylist,
    this.history = const [],
    this.isPlayerExpanded = false,
  });

  NavigationState copyWith({
    NavItem? activeItem,
    NavItem? Function()? highlightItem,
    String? collectionTitle,
    String? collectionSubtitle,
    String? collectionArt,
    String? collectionImageUrl,
    List<String>? collectionImages,
    List<Song>? collectionSongs,
    Playlist? activePlaylist,
    List<NavigationState>? history,
    bool? isPlayerExpanded,
  }) {
    return NavigationState(
      activeItem: activeItem ?? this.activeItem,
      highlightItem: highlightItem != null
          ? highlightItem()
          : this.highlightItem,
      collectionTitle: collectionTitle ?? this.collectionTitle,
      collectionSubtitle: collectionSubtitle ?? this.collectionSubtitle,
      collectionArt: collectionArt ?? this.collectionArt,
      collectionImageUrl: collectionImageUrl ?? this.collectionImageUrl,
      collectionImages: collectionImages ?? this.collectionImages,
      collectionSongs: collectionSongs ?? this.collectionSongs,
      activePlaylist: activePlaylist ?? this.activePlaylist,
      history: history ?? this.history,
      isPlayerExpanded: isPlayerExpanded ?? this.isPlayerExpanded,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState(activeItem: NavItem.home));

  void setItem(NavItem item) {
    if (state.activeItem == item) return;

    if (item == NavItem.home) {
      state = NavigationState(activeItem: NavItem.home);
      return;
    }

    // Push current state to history
    final newHistory = List<NavigationState>.from(state.history)
      ..add(_captureCurrentState());

    state = NavigationState(
      activeItem: item,
      history: newHistory,
      isPlayerExpanded: state.isPlayerExpanded,
    );
  }

  void toggleItem(NavItem item) {
    if (state.activeItem == item) {
      goBack();
    } else {
      setItem(item);
    }
  }

  void showCollection({
    required String title,
    String? subtitle,
    String? art,
    String? imageUrl,
    List<String>? images,
    required List<Song> songs,
    Playlist? playlist,
    NavItem? highlightItem,
  }) {
    if (state.activeItem == NavItem.collectionDetail &&
        state.collectionTitle == title) {
      return;
    }

    // Push current state to history
    final newHistory = List<NavigationState>.from(state.history)
      ..add(_captureCurrentState());

    state = NavigationState(
      activeItem: NavItem.collectionDetail,
      highlightItem: highlightItem,
      collectionTitle: title,
      collectionSubtitle: subtitle,
      collectionArt: art,
      collectionImageUrl: imageUrl,
      collectionImages: images ?? const [],
      collectionSongs: songs,
      activePlaylist: playlist,
      history: newHistory,
      isPlayerExpanded: state.isPlayerExpanded,
    );
  }

  void goBack() {
    if (state.history.isEmpty) {
      state = NavigationState(activeItem: NavItem.home);
      return;
    }

    final previousState = state.history.last;
    final newHistory = List<NavigationState>.from(state.history)..removeLast();

    state = previousState.copyWith(history: newHistory);
  }

  NavigationState _captureCurrentState() {
    return NavigationState(
      activeItem: state.activeItem,
      highlightItem: state.highlightItem,
      collectionTitle: state.collectionTitle,
      collectionSubtitle: state.collectionSubtitle,
      collectionArt: state.collectionArt,
      collectionImageUrl: state.collectionImageUrl,
      collectionImages: state.collectionImages,
      collectionSongs: state.collectionSongs,
      activePlaylist: state.activePlaylist,
      isPlayerExpanded: state.isPlayerExpanded,
    );
  }

  void togglePlayerExpansion() {
    state = state.copyWith(isPlayerExpanded: !state.isPlayerExpanded);
  }

  void setPlayerExpansion(bool expanded) {
    state = state.copyWith(isPlayerExpanded: expanded);
  }
}

final appNavigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier();
    });
