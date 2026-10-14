import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// The elastic follow of the lyrics list: when the list moves on to a new
/// line, the lines below it start a beat later, one after another, so the
/// gaps between them stretch for a moment and then close again.
///
/// The list itself scrolls (or jumps) as usual; this only hands every line
/// a paint offset on top of that, so layout and the scroll position are
/// never touched.
class LyricsFollowMotion extends ChangeNotifier {
  LyricsFollowMotion(TickerProvider vsync) {
    _ticker = vsync.createTicker(_onTick);
  }

  /// Shared with the list's own scroll animation, so the leading lines
  /// (which get no offset) and the trailing ones move as one gesture.
  static const Duration duration = Duration(milliseconds: 470);
  static const Curve curve = Curves.ease;

  /// How much later each further line below the active one starts, and
  /// after how many lines the delay stops growing.
  static const Duration stagger = Duration(milliseconds: 34);
  static const int maxSteps = 6;

  late final Ticker _ticker;
  final List<_Move> _moves = [];
  Duration _now = Duration.zero;

  bool get isRunning => _moves.isNotEmpty;

  /// Starts a move of [delta] pixels towards the line at [anchor].
  ///
  /// With [led] the list is scrolling there itself over [duration] with
  /// [curve], and lines below [anchor] trail behind it. Without it the list
  /// has already jumped, and every line slides in over the same distance.
  ///
  /// A move started while another is still settling adds to it, so quick
  /// line changes stay one continuous motion.
  void push(double delta, {required int anchor, bool led = true}) {
    if (delta == 0) return;
    if (!_ticker.isActive) {
      _now = Duration.zero;
      _ticker.start();
    }
    _moves.add(_Move(delta, anchor, led, _now));
    notifyListeners();
  }

  /// The paint offset of the line at [index], in pixels (down is positive).
  double offsetFor(int index) {
    var offset = 0.0;
    for (final move in _moves) {
      final elapsed = _now - move.start;
      final steps = (index - move.anchor).clamp(0, maxSteps);
      final lead = move.led ? _progress(elapsed) : 1.0;
      offset += move.delta * (lead - _progress(elapsed - stagger * steps));
    }
    return offset;
  }

  static double _progress(Duration elapsed) {
    if (elapsed <= Duration.zero) return 0.0;
    if (elapsed >= duration) return 1.0;
    return curve.transform(elapsed.inMicroseconds / duration.inMicroseconds);
  }

  void _onTick(Duration elapsed) {
    _now = elapsed;
    final life = duration + stagger * maxSteps;
    _moves.removeWhere((move) => _now - move.start >= life);
    if (_moves.isEmpty) _ticker.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

class _Move {
  const _Move(this.delta, this.anchor, this.led, this.start);

  final double delta;
  final int anchor;
  final bool led;
  final Duration start;
}

/// Paints [child] shifted by its line's current [LyricsFollowMotion] offset.
class LyricsFollowOffset extends StatelessWidget {
  const LyricsFollowOffset({
    super.key,
    required this.motion,
    required this.index,
    required this.child,
  });

  final LyricsFollowMotion motion;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motion,
      // Only the offset changes per frame: the line keeps its own picture.
      child: RepaintBoundary(child: child),
      builder: (context, child) => Transform.translate(
        offset: Offset(0, motion.offsetFor(index)),
        child: child,
      ),
    );
  }
}
