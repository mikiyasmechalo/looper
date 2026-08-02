import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/playback/data/audio_analyzer.dart';

/// Real per-song energy timeline (one RMS value per ~50 ms). Resolves to an
/// empty list while analyzing or when a song can't be decoded.
final waveformProvider = FutureProvider.family<List<double>, String>((ref, path) async {
  return await WaveformAnalyzer.analyze(path) ?? const <double>[];
});
