part of 'advanced_lyric_line.dart';

/// The instrumental/music-gap symbol ("♫") for the currently active line -
/// same glyph the inactive and already-played instrumental symbols use, but
/// pulsing with a soft glow and a gentle bounce for as long as this line
/// stays active, so the animation itself (not a different symbol) is what
/// marks it as the current one. While playback is paused the pulse eases
/// back to rest (no glow, no bounce) and picks up again on resume.
class PulsingInstrumentalIcon extends StatefulWidget {
  const PulsingInstrumentalIcon({
    super.key,
    required this.color,
    required this.style,
    this.isPlaying = true,
  });

  /// Color of the glow halo behind the symbol - the symbol's own color
  /// already comes from [style].
  final Color color;
  final TextStyle style;
  final bool isPlaying;

  @override
  State<PulsingInstrumentalIcon> createState() =>
      _PulsingInstrumentalIconState();
}

class _PulsingInstrumentalIconState
    extends State<PulsingInstrumentalIcon>
    with SingleTickerProviderStateMixin {
  static const _beat = Duration(milliseconds: 900);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _beat,
  );

  @override
  void initState() {
    super.initState();
    if (widget.isPlaying && !Motion.reduced) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingInstrumentalIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      _syncWithPlayback(widget.isPlaying);
    }
  }

  void _syncWithPlayback(bool playing) {
    if (playing) {
      if (Motion.reduced) return;
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    } else {
      // Settle back down instead of freezing mid-glow.
      _controller.animateTo(0, duration: _beat * _controller.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          // Bounce: rises slightly on each beat, settles back down.
          offset: Offset(0, -4.0 * t),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                // Glow: a soft halo behind the icon that swells and fades
                // with the same beat as the bounce.
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.15 + 0.35 * t),
                  blurRadius: 10 + 14 * t,
                  spreadRadius: 1 + 3 * t,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: Text('♫', style: widget.style),
    );
  }
}
