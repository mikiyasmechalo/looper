import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:ffmpeg_kit_flutter_new_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_full/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_full/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new_full/level.dart';
import 'package:ffmpeg_kit_flutter_new_full/return_code.dart';
import 'package:path_provider/path_provider.dart';

class AudioAnalysis {
  final String codec;
  final String container;
  final int sampleRate;
  final int channels;
  final int bitrate;
  final int bitsPerSample;
  final double duration;
  final double? integratedLufs;
  final double? truePeakDb;
  
  // Extended Metadata
  final String? isrc;
  final String? copyright;
  final String? composer;
  final String? label;
  final String? encoder;

  AudioAnalysis({
    required this.codec,
    required this.container,
    required this.sampleRate,
    required this.channels,
    required this.bitrate,
    required this.bitsPerSample,
    required this.duration,
    this.integratedLufs,
    this.truePeakDb,
    this.isrc,
    this.copyright,
    this.composer,
    this.label,
    this.encoder,
  });

  String get bitDepth => bitsPerSample > 0 ? '$bitsPerSample-bit' : 'N/A';
  String get sampleRateKhz => '${(sampleRate / 1000).toStringAsFixed(1)} kHz';
  String get bitrateKbps => '${(bitrate / 1000).round()} kbps';
}

class AudioAnalyzer {
  static final Map<String, AudioAnalysis> _cache = {};

  static AudioAnalysis? getCachedAnalysis(String filePath) {
    return _cache[filePath];
  }

  static Future<AudioAnalysis?> analyze(String filePath) async {
    if (_cache.containsKey(filePath)) {
      return _cache[filePath];
    }
    try {
      final session = await FFprobeKit.getMediaInformation(filePath);
      final info = session.getMediaInformation();

      if (info == null) return null;

      final streams = info.getStreams();
      final audioStream = streams.firstWhere(
        (s) => s.getAllProperties()?['codec_type'] == 'audio',
        orElse: () => throw Exception('No audio stream found'),
      );

      final props = audioStream.getAllProperties() ?? {};
      final infoProps = info.getAllProperties() ?? {};
      final tags = info.getTags() ?? {};
      
      final codec = props['codec_name']?.toString().toUpperCase() ?? 'UNKNOWN';
      final container = infoProps['format_name']?.toString().toUpperCase() ?? 'UNKNOWN';
      final sampleRate = int.tryParse(props['sample_rate']?.toString() ?? '') ?? 0;
      final channels = int.tryParse(props['channels']?.toString() ?? '') ?? 0;
      final duration = double.tryParse(info.getDuration() ?? '') ?? 0;
      
      int bitrate = int.tryParse(props['bit_rate']?.toString() ?? '') ?? 
                    int.tryParse(info.getBitrate() ?? '') ?? 0;
      
      if (bitrate == 0 && duration > 0) {
        final fileSize = await File(filePath).length();
        bitrate = (fileSize * 8 / duration).round();
      }

      int bitsPerSample = 0;
      if (['FLAC', 'ALAC', 'WAV', 'APE'].contains(codec)) {
        bitsPerSample = int.tryParse(props['bits_per_raw_sample']?.toString() ?? '') ?? 
                        int.tryParse(props['bits_per_sample']?.toString() ?? '') ?? 0;
      }

      final analysis = AudioAnalysis(
        codec: codec,
        container: container,
        sampleRate: sampleRate,
        channels: channels,
        bitrate: bitrate,
        bitsPerSample: bitsPerSample,
        duration: duration,
        isrc: tags['isrc']?.toString() ?? tags['ISRC']?.toString(),
        copyright: tags['copyright']?.toString() ?? tags['COPYRIGHT']?.toString(),
        composer: tags['composer']?.toString() ?? tags['COMPOSER']?.toString(),
        label: tags['label']?.toString() ?? tags['LABEL']?.toString() ?? tags['organization']?.toString(),
        encoder: tags['encoder']?.toString(),
      );
      _cache[filePath] = analysis;
      return analysis;
    } catch (e) {

      return null;
    }
  }

  static Future<Map<String, double>?> getLoudness(String filePath) async {
    await FFmpegKitConfig.setLogLevel(Level.avLogInfo);
    try {
      final session = await FFmpegKit.executeWithArguments([
        '-hide_banner',
        '-nostats',
        '-i', filePath,
        '-af', 'ebur128=peak=true',
        '-f', 'null',
        '-',
      ]);

      final logs = await session.getLogsAsString();
      final integratedMatches = RegExp(r'I:\s+(-?\d+\.?\d*)\s+LUFS').allMatches(logs);
      final integrated = integratedMatches.isEmpty
          ? null
          : double.tryParse(integratedMatches.last.group(1) ?? '');

      double? truePeak;
      for (final match in RegExp(r'Peak:\s+(-?\d+\.?\d*)\s+dBFS').allMatches(logs)) {
        final value = double.tryParse(match.group(1) ?? '');
        if (value != null && (truePeak == null || value > truePeak)) {
          truePeak = value;
        }
      }

      if (integrated != null || truePeak != null) {
        return {
          'lufs': integrated ?? 0.0,
          'truePeak': truePeak ?? 0.0,
        };
      }
    } finally {
      await FFmpegKitConfig.setLogLevel(Level.avLogError);
    }
    return null;
  }
}

/// Decodes the actual audio content of a song (via ffmpeg) into a per-bucket
/// energy waveform, so UI can render a visualizer that reflects the song
/// instead of a synthetic pattern.
class WaveformAnalyzer {
  static const int _decodeSampleRate = 8000;

  static final Map<String, List<double>> _cache = {};

  static List<double>? getCached(String filePath) => _cache[filePath];

  /// Decodes the song and returns a fine-grained energy timeline (one RMS
  /// value per ~50 ms of audio, normalized to 0..1) so a seekbar can both
  /// render a real waveform profile and react to the energy at the current
  /// playback position.
  static Future<List<double>?> analyze(String filePath) async {
    final cached = _cache[filePath];
    if (cached != null) return cached;

    String? pcmPath;
    try {
      pcmPath = '${(await getTemporaryDirectory()).path}'
          '${Platform.pathSeparator}looper_waveform_'
          '${DateTime.now().microsecondsSinceEpoch}.pcm';

      final session = await FFmpegKit.executeWithArguments([
        '-hide_banner',
        '-nostats',
        '-loglevel', 'error',
        '-y',
        '-i', filePath,
        '-ac', '1',
        '-ar', '$_decodeSampleRate',
        '-f', 's16le',
        pcmPath,
      ]);

      final rc = await session.getReturnCode();
      if (!ReturnCode.isSuccess(rc)) {
        _deleteFile(pcmPath);
        return null;
      }

      final file = File(pcmPath);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      await file.delete();

      final wave = await Isolate.run(() => _computeWaveform(bytes));
      _cache[filePath] = wave;
      return wave;
    } catch (_) {
      _deleteFile(pcmPath);
      return null;
    }
  }

  static void _deleteFile(String? path) {
    if (path != null) {
      try {
        final f = File(path);
        if (f.existsSync()) f.deleteSync();
      } catch (_) {}
    }
  }

  /// Turns interleaved s16le mono samples into an energy timeline with one
  /// RMS value per ~50 ms, normalized to the 0..1 range. Runs inside a
  /// background isolate.
  static List<double> _computeWaveform(Uint8List bytes) {
    final sampleCount = bytes.length ~/ 2;
    final buckets = max(1, (sampleCount / 400).round());
    final out = List<double>.filled(buckets, 0);
    if (sampleCount < 400) return out;

    final view = ByteData.sublistView(bytes);
    double sumSquares = 0;
    for (int b = 0; b < buckets; b++) {
      final start = (b * sampleCount) ~/ buckets;
      final end = ((b + 1) * sampleCount) ~/ buckets;
      for (int i = start; i < end; i++) {
        final s = view.getInt16(i * 2, Endian.little) / 32768.0;
        sumSquares += s * s;
      }
      out[b] = sqrt(sumSquares / (end - start));
      sumSquares = 0;
    }

    double maxValue = 0;
    for (final v in out) {
      if (v > maxValue) maxValue = v;
    }
    if (maxValue < 1e-6) return out;

    // Lift quiet content so the profile keeps visible dynamics instead of a
    // flat envelope, then normalize.
    for (int i = 0; i < buckets; i++) {
      out[i] = pow(out[i] / maxValue, 0.6).toDouble().clamp(0.0, 1.0);
    }
    return out;
  }
}
