import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';

/// Represents real-time device battery health and power state.
class BatteryInfo {
  final int level; // 0 to 100
  final BatteryState state; // charging, discharging, full, unknown
  final bool isAvailable; // true if device has a monitored battery
  final bool isCharging;

  const BatteryInfo({
    required this.level,
    required this.state,
    required this.isAvailable,
    required this.isCharging,
  });

  const BatteryInfo.unavailable()
      : level = 100,
        state = BatteryState.unknown,
        isAvailable = false,
        isCharging = false;

  BatteryInfo copyWith({
    int? level,
    BatteryState? state,
    bool? isAvailable,
    bool? isCharging,
  }) {
    return BatteryInfo(
      level: level ?? this.level,
      state: state ?? this.state,
      isAvailable: isAvailable ?? this.isAvailable,
      isCharging: isCharging ?? this.isCharging,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatteryInfo &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          state == other.state &&
          isAvailable == other.isAvailable &&
          isCharging == other.isCharging;

  @override
  int get hashCode => Object.hash(level, state, isAvailable, isCharging);

  @override
  String toString() =>
      'BatteryInfo(level: $level%, state: $state, available: $isAvailable, charging: $isCharging)';
}

/// Service providing cross-platform battery status and event subscriptions.
class BatteryService {
  static final BatteryService instance = BatteryService._();
  BatteryService._() : _battery = Battery();

  @visibleForTesting
  BatteryService.withBattery(Battery battery) : _battery = battery;

  final Battery _battery;
  final StreamController<BatteryInfo> _controller =
      StreamController<BatteryInfo>.broadcast();
  StreamSubscription<BatteryState>? _stateSubscription;
  Timer? _pollingTimer;

  BatteryInfo _currentInfo = const BatteryInfo.unavailable();
  bool _initialized = false;

  BatteryInfo get currentInfo => _currentInfo;
  Stream<BatteryInfo> get onBatteryInfoChanged => _controller.stream;

  /// Initializes listeners and performs initial query.
  Future<BatteryInfo> initialize() async {
    if (_initialized) return _currentInfo;
    _initialized = true;

    await refresh();

    try {
      _stateSubscription = _battery.onBatteryStateChanged.listen(
        (state) async {
          final isCharging =
              state == BatteryState.charging || state == BatteryState.full;
          int currentLevel = _currentInfo.level;
          try {
            currentLevel = await _battery.batteryLevel;
          } catch (_) {}

          _updateInfo(
            BatteryInfo(
              level: currentLevel,
              state: state,
              isAvailable: true,
              isCharging: isCharging,
            ),
          );
        },
        onError: (e) {
          debugPrint('BatteryService state stream error: $e');
        },
      );
    } catch (e) {
      debugPrint('BatteryService onBatteryStateChanged not supported: $e');
    }

    // Periodic check every 30 seconds to catch battery drainage between state events
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refresh();
    });

    return _currentInfo;
  }

  /// Refreshes current battery level and state.
  Future<BatteryInfo> refresh() async {
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      final isCharging =
          state == BatteryState.charging || state == BatteryState.full;

      final info = BatteryInfo(
        level: level.clamp(0, 100),
        state: state,
        isAvailable: true,
        isCharging: isCharging,
      );
      _updateInfo(info);
      return info;
    } catch (e) {
      // Platform doesn't have a battery or running in test/desktop environment
      const unavailable = BatteryInfo.unavailable();
      _updateInfo(unavailable);
      return unavailable;
    }
  }

  void _updateInfo(BatteryInfo newInfo) {
    if (_currentInfo == newInfo) return;
    _currentInfo = newInfo;
    if (!_controller.isClosed) {
      _controller.add(newInfo);
    }
  }

  void dispose() {
    _stateSubscription?.cancel();
    _pollingTimer?.cancel();
    _controller.close();
  }
}
