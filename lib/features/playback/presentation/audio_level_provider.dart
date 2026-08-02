// ============================================================================
// Provides REAL, live spectrum data driven by mpv_audio_kit's own DSP tap
// (`PlayerStream.fft`), so the seekbar visualizer dances with the actual
// frequency content of the song instead of a synthetic pulse.
//
// The original plan (mpv `af add lavfi=[label=...:graph=[in]astats...[out]]`
// + polling `af-metadata/<label>`) is intentionally NOT used: mpv_audio_kit
// guards `sendRawCommand(['af', ...])` / `setRawProperty('af', ...)` and
// rejects them, because the typed `AudioEffects` bundle owns mpv's `af`
// property. The package instead exposes a first-class, listener-gated
// real-time DSP tap — `PlayerStream.fft` (log-spaced band magnitudes, already
// normalised to 0..1 with asymmetric attack/release smoothing) and
// `PlayerStream.pcm` (raw post-DSP samples) — which is exactly the signal this
// visualizer needs, with no filter bookkeeping on our side.
//
// The fft stream is lazy: it arms the native tap on first listen and tears
// down on last cancel. The provider is autoDispose, so the tap only costs CPU
// while the visualizer is actually on screen.
// ============================================================================

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';

import 'playback_notifier.dart';

/// Number of buckets the raw FFT bands are downsampled to before being
/// published. Cheap to copy on every tick.
const _kBucketCount = 48;

/// Current per-bucket frequency magnitudes (0..1), index 0 = lowest band.
/// Updated from mpv's live FFT tap (~30-50 fps while audio flows).
final spectrumProvider =
    StateNotifierProvider.autoDispose<SpectrumLevelNotifier, List<double>>(
  (ref) => SpectrumLevelNotifier(ref),
);

class SpectrumLevelNotifier extends StateNotifier<List<double>> {
  SpectrumLevelNotifier(this._ref) : super(const []) {
    _setup();
  }

  final Ref _ref;
  StreamSubscription<FftFrame>? _fftSub;

  Future<void> _setup() async {
    try {
      final player = _ref.read(playbackProvider.notifier).player;
      // 50 fps (20 ms) makes the dancing noticeably smoother than the 33 ms
      // default; the tap still only runs while something is listening.
      await player.updateSpectrum(
        (s) => s.copyWith(emitInterval: const Duration(milliseconds: 20)),
      );
      _fftSub = player.stream.fft.listen(_onFrame);
    } catch (_) {
      // Player not ready yet, or the platform doesn't expose the tap — the
      // visualizer just stays static rather than crashing playback.
    }
  }

  void _onFrame(FftFrame frame) {
    final bands = frame.bands;
    if (bands.isEmpty) return;

    final buckets = List<double>.filled(_kBucketCount, 0);
    for (int b = 0; b < _kBucketCount; b++) {
      final start = (b * bands.length) ~/ _kBucketCount;
      final end = ((b + 1) * bands.length) ~/ _kBucketCount;
      double peak = 0;
      double sum = 0;
      for (int j = start; j < end; j++) {
        final v = bands[j];
        sum += v;
        if (v > peak) peak = v;
      }
      final avg = end > start ? sum / (end - start) : 0.0;
      // Peak dominates so transient hits (kicks, snare) stay punchy while a
      // little average keeps sustained tones visible.
      buckets[b] = (peak * 0.7 + avg * 0.3).clamp(0.0, 1.0);
    }
    state = buckets;
  }

  @override
  void dispose() {
    _fftSub?.cancel();
    super.dispose();
  }
}
