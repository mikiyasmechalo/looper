import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:looper_player/ui/screens/android/player/android_expanded_player.dart';
import 'package:looper_player/ui/screens/desktop_expanded_player.dart';

class ExpandedPlayer extends ConsumerWidget {
  const ExpandedPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (Platform.isAndroid) {
      return const AndroidExpandedPlayer();
    }

    return const DesktopExpandedPlayer();
  }
}
