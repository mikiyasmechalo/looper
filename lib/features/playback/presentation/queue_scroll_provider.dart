import 'package:flutter_riverpod/flutter_riverpod.dart';

class QueueScrollState {
  final double pageScrollOffset;
  final String? pageLastScrolledSongPath;
  final double sidebarScrollOffset;
  final String? sidebarLastScrolledSongPath;

  const QueueScrollState({
    this.pageScrollOffset = 0.0,
    this.pageLastScrolledSongPath,
    this.sidebarScrollOffset = 0.0,
    this.sidebarLastScrolledSongPath,
  });

  QueueScrollState copyWith({
    double? pageScrollOffset,
    String? pageLastScrolledSongPath,
    double? sidebarScrollOffset,
    String? sidebarLastScrolledSongPath,
  }) {
    return QueueScrollState(
      pageScrollOffset: pageScrollOffset ?? this.pageScrollOffset,
      pageLastScrolledSongPath:
          pageLastScrolledSongPath ?? this.pageLastScrolledSongPath,
      sidebarScrollOffset: sidebarScrollOffset ?? this.sidebarScrollOffset,
      sidebarLastScrolledSongPath:
          sidebarLastScrolledSongPath ?? this.sidebarLastScrolledSongPath,
    );
  }
}

class QueueScrollNotifier extends Notifier<QueueScrollState> {
  @override
  QueueScrollState build() => const QueueScrollState();

  void updatePageOffset(double offset) {
    if ((state.pageScrollOffset - offset).abs() > 0.5) {
      state = state.copyWith(pageScrollOffset: offset);
    }
  }

  void markPageScrolledTo(String? songPath, double offset) {
    state = state.copyWith(
      pageLastScrolledSongPath: songPath,
      pageScrollOffset: offset,
    );
  }

  void updateSidebarOffset(double offset) {
    if ((state.sidebarScrollOffset - offset).abs() > 0.5) {
      state = state.copyWith(sidebarScrollOffset: offset);
    }
  }

  void markSidebarScrolledTo(String? songPath, double offset) {
    state = state.copyWith(
      sidebarLastScrolledSongPath: songPath,
      sidebarScrollOffset: offset,
    );
  }

  void reset() {
    state = const QueueScrollState();
  }
}

final queueScrollProvider =
    NotifierProvider<QueueScrollNotifier, QueueScrollState>(
      QueueScrollNotifier.new,
    );
