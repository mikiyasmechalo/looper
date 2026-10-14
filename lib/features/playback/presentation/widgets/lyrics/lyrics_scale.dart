/// Sizing rules for the lyrics text on desktop.
class LyricsScale {
  /// Same limits the renderer's pinch gesture uses.
  static const double min = 0.6;
  static const double max = 2.5;
  static const double step = 0.1;

  /// Rows saved before the setting existed read back as NaN: 100%.
  static double normalize(double value) {
    if (!value.isFinite || value <= 0) return 1.0;
    return value.clamp(min, max);
  }

  /// One step larger ([direction] > 0) or smaller, rounded to a tenth so
  /// repeated steps don't drift.
  static double stepBy(double value, int direction) {
    final stepped = normalize(value) + (direction > 0 ? step : -step);
    return ((stepped * 10).round() / 10).clamp(min, max);
  }

  /// Grows the text with the lyrics pane: 1.0 up to 760px, 1.6 from 1216px.
  static double auto(double paneWidth) {
    if (paneWidth.isNaN) return 1.0;
    return (paneWidth / 760).clamp(1.0, 1.6);
  }
}
