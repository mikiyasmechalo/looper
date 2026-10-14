import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Lightweight haptics helper that delegates to Flutter's [HapticFeedback].
class AppHaptics {
  AppHaptics._();

  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void selection() => HapticFeedback.selectionClick();
  static void tick() => HapticFeedback.selectionClick();
  static void snap() => HapticFeedback.mediumImpact();
  static void soft() => HapticFeedback.lightImpact();
  static void success() => HapticFeedback.lightImpact();
  static void error() => HapticFeedback.heavyImpact();
}

extension HapticSnackBar on ScaffoldMessengerState {
  /// Shows [snackBar] at once and plays [haptic] (an `AppHaptics` event) with it.
  void showHapticSnackBar(VoidCallback haptic, SnackBar snackBar) {
    clearSnackBars();
    removeCurrentSnackBar();
    showSnackBar(snackBar);
    haptic();
  }
}

