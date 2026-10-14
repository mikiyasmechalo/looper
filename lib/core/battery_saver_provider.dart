import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/battery_service.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';

/// Stream provider for live battery information.
final batteryInfoProvider = StreamProvider<BatteryInfo>((ref) async* {
  final service = BatteryService.instance;
  // Yield initial info
  final initial = await service.initialize();
  yield initial;

  // Stream subsequent changes
  yield* service.onBatteryInfoChanged;
});

/// Indicates whether Battery Saver mode is currently active (via manual or auto trigger).
final batterySaverActiveProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider.select((s) => s.isBatterySaverActive));
});
