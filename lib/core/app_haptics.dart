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
}
