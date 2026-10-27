import 'dart:async';
import 'package:flutter/material.dart';

class AppRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Duration visualDuration;

  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.visualDuration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: const Color(0xFF1E1E1E),
      onRefresh: () async {
        // Run refresh in background without blocking UI indefinitely
        unawaited(onRefresh());
        // Maintain visual feedback for consistent duration before dismiss
        await Future.delayed(visualDuration);
      },
      child: child,
    );
  }
}
