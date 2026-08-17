import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio_service.dart';
import 'db_service.dart';
import 'package:isar/isar.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final rootNavigatorKey = GlobalKey<NavigatorState>();

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

final isarProvider = Provider<Isar>((ref) {
  return DbService.isar;
});

final startupFileProvider = Provider<String?>((ref) => null);

final searchFocusNodeProvider = Provider<FocusNode>((ref) {
  final node = FocusNode(debugLabel: 'SearchFocusNode');
  ref.onDispose(() => node.dispose());
  return node;
});

final overlayModeProvider = StateProvider<bool>((ref) => false);

final forceWelcomeProvider = StateProvider<bool>((ref) => false);

/// Which desktop mini-player mode is currently active.
enum MiniPlayerMode { none, miniPlayer, cornerWidget }

final miniPlayerModeProvider =
    StateProvider<MiniPlayerMode>((ref) => MiniPlayerMode.none);
