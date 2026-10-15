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
      // 30 fps (33 ms) provides ultra-smooth motion while reducing CPU overhead
      // by ~40% compared to 20ms polling.
      await player.updateSpectrum(
        (s) => s.copyWith(emitInterval: const Duration(milliseconds: 33)),
      );
      _fftSub = player.stream.fft.listen(_onFrame);
    } catch (_) {
      // Player not ready yet, or the platform doesn't expose the tap — the
      // visualizer just stays static rather than crashing playback.
    }
  }

  void _onFrame(FftFrame frame) {
    final isPlaying = _ref.read(playbackProvider.select((s) => s.isPlaying));
    if (!isPlaying) return;

    final bands = frame.bands;
    if (bands.isEmpty) return;

    final volume =
        _ref.read(playbackProvider.select((s) => s.volume)).clamp(0.0, 1.0);
    // Apply 30%-70% virtual volume scaling:
    // - Higher volume ALWAYS produces higher or equal bar heights (monotonic).
    // - At 100% volume, maximum visualizer scale is capped at 0.70 (70% height) so bars never clip into solid blocks.
    // - At lower volumes (10%-30%), bars stay active with a gentle minimum floor (~0.30-0.42).
    final effectiveVol = volume > 0.001 ? volume : 0.001;
    final targetVolScale = 0.30 + 0.40 * volume; // 0.30 at vol=0 -> 0.70 at vol=1.0
    final gain = targetVolScale / effectiveVol;

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
      final rawVal = (peak * 0.75 + avg * 0.25) * gain;
      buckets[b] = rawVal.clamp(0.0, 0.80);
    }
    state = buckets;
  }

  @override
  void dispose() {
    _fftSub?.cancel();
    super.dispose();
  }
}
