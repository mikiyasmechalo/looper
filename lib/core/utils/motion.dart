import 'package:flutter/widgets.dart';

/// The system "remove animations" accessibility setting, in one place.
/// Decorative motion (slides, scales, loops, marquees) checks this and falls
/// back to a plain fade or a still frame; motion that carries meaning
/// (lyrics following the song, the seek bar) is left alone.
abstract final class Motion {
  /// For code without a [BuildContext] - route durations, controllers
  /// started in initState.
  static bool get reduced => WidgetsBinding
      .instance
      .platformDispatcher
      .accessibilityFeatures
      .disableAnimations;

  /// Rebuilds the caller when the setting changes.
  static bool reducedOf(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}
