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
  final NavItem? searchSourceTab;
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
    this.searchSourceTab,
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
    NavItem? Function()? searchSourceTab,
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
      searchSourceTab: searchSourceTab != null
          ? searchSourceTab()
          : this.searchSourceTab,
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

    final sourceTab = item == NavItem.search
        ? (state.highlightItem ?? state.activeItem)
        : state.searchSourceTab;

    // Do not push NavItem.search into navigation history
    final newHistory = List<NavigationState>.from(state.history);
    if (state.activeItem != NavItem.search) {
      newHistory.add(_captureCurrentState());
    }

    final nextHighlight = item == NavItem.search ? state.highlightItem : null;

    state = NavigationState(
      activeItem: item,
      highlightItem: nextHighlight,
      searchSourceTab: sourceTab,
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
      state = state.copyWith(isPlayerExpanded: false);
      return;
    }

    // Do not push NavItem.search into navigation history
    final newHistory = List<NavigationState>.from(state.history);
    if (state.activeItem != NavItem.search) {
      newHistory.add(_captureCurrentState());
    }

    state = NavigationState(
      activeItem: NavItem.collectionDetail,
      highlightItem: highlightItem,
      searchSourceTab: state.searchSourceTab,
      collectionTitle: title,
      collectionSubtitle: subtitle,
      collectionArt: art,
      collectionImageUrl: imageUrl,
      collectionImages: images ?? const [],
      collectionSongs: songs,
      activePlaylist: playlist,
      history: newHistory,
      isPlayerExpanded: false,
    );
  }

  void updateActiveCollection({
    required String oldTitle,
    required String newTitle,
    String? newSubtitle,
    String? newArt,
    List<Song>? newSongs,
  }) {
    if (state.activeItem == NavItem.collectionDetail && state.collectionTitle == oldTitle) {
      state = NavigationState(
        activeItem: state.activeItem,
        highlightItem: state.highlightItem,
        searchSourceTab: state.searchSourceTab,
        collectionTitle: newTitle,
        collectionSubtitle: newSubtitle ?? state.collectionSubtitle,
        collectionArt: newArt ?? state.collectionArt,
        collectionImageUrl: state.collectionImageUrl,
        collectionImages: state.collectionImages,
        collectionSongs: newSongs ?? state.collectionSongs,
        activePlaylist: state.activePlaylist,
        history: state.history,
        isPlayerExpanded: state.isPlayerExpanded,
      );
    }
  }

  void closeCollectionIfActive(String title) {
    if (state.activeItem == NavItem.collectionDetail && state.collectionTitle == title) {
      goBack();
    }
  }

  void goBack() {
    if (state.history.isEmpty) {
      state = NavigationState(activeItem: NavItem.home);
      return;
    }

    final newHistory = List<NavigationState>.from(state.history);
    NavigationState? target;
    while (newHistory.isNotEmpty) {
      final candidate = newHistory.removeLast();
      if (candidate.activeItem != NavItem.search) {
        target = candidate;
        break;
      }
    }

    if (target != null) {
      state = target.copyWith(history: newHistory);
    } else {
      state = NavigationState(activeItem: NavItem.home);
    }
  }

  NavigationState _captureCurrentState() {
    return NavigationState(
      activeItem: state.activeItem,
      highlightItem: state.highlightItem,
      searchSourceTab: state.searchSourceTab,
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
