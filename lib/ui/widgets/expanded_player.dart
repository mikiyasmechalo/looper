import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/ui/screens/desktop_expanded_player.dart';

class ExpandedPlayer extends ConsumerWidget {
  const ExpandedPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DesktopExpandedPlayer();
  }
}
