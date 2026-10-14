import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looper_player/core/battery_service.dart';
import 'package:looper_player/features/library/domain/models/models.dart';

void main() {
  group('BatteryInfo Model Tests', () {
    test('Default unavailable state has safe fallbacks', () {
      const info = BatteryInfo.unavailable();
      expect(info.isAvailable, isFalse);
      expect(info.isCharging, isFalse);
      expect(info.level, 100);
      expect(info.state, BatteryState.unknown);
    });

    test('BatteryInfo equality and copyWith', () {
      const info1 = BatteryInfo(
        level: 42,
        state: BatteryState.discharging,
        isAvailable: true,
        isCharging: false,
      );
      final info2 = info1.copyWith(level: 42);
      final info3 = info1.copyWith(level: 41);

      expect(info1, equals(info2));
      expect(info1 == info3, isFalse);
      expect(info1.hashCode, equals(info2.hashCode));
    });
  });

  group('Battery Saver Activation Logic Tests', () {
    bool evaluateSaver({
      required bool autoBatterySaver,
      required int threshold,
      required bool manualBatterySaver,
      required BatteryInfo battery,
    }) {
      if (manualBatterySaver) return true;
      if (!autoBatterySaver) return false;
      if (!battery.isAvailable || battery.isCharging) return false;
      return battery.level <= threshold;
    }

    test('Auto Battery Saver triggers when discharging and level <= threshold', () {
      const battery = BatteryInfo(
        level: 18,
        state: BatteryState.discharging,
        isAvailable: true,
        isCharging: false,
      );

      final isActive = evaluateSaver(
        autoBatterySaver: true,
        threshold: 20,
        manualBatterySaver: false,
        battery: battery,
      );

      expect(isActive, isTrue);
    });

    test('Auto Battery Saver does not trigger when battery level > threshold', () {
      const battery = BatteryInfo(
        level: 45,
        state: BatteryState.discharging,
        isAvailable: true,
        isCharging: false,
      );

      final isActive = evaluateSaver(
        autoBatterySaver: true,
        threshold: 20,
        manualBatterySaver: false,
        battery: battery,
      );

      expect(isActive, isFalse);
    });

    test('Auto Battery Saver stands down when device is actively charging even if below threshold', () {
      const battery = BatteryInfo(
        level: 10,
        state: BatteryState.charging,
        isAvailable: true,
        isCharging: true,
      );

      final isActive = evaluateSaver(
        autoBatterySaver: true,
        threshold: 20,
        manualBatterySaver: false,
        battery: battery,
      );

      expect(isActive, isFalse);
    });

    test('Manual Battery Saver forces power-saving mode on regardless of level or charging state', () {
      const chargingHighBattery = BatteryInfo(
        level: 95,
        state: BatteryState.charging,
        isAvailable: true,
        isCharging: true,
      );

      final isActive = evaluateSaver(
        autoBatterySaver: false,
        threshold: 20,
        manualBatterySaver: true,
        battery: chargingHighBattery,
      );

      expect(isActive, isTrue);
    });

    test('Unavailable battery on desktop PC stays off for auto saver but respects manual toggle', () {
      const unavailable = BatteryInfo.unavailable();

      final autoActive = evaluateSaver(
        autoBatterySaver: true,
        threshold: 20,
        manualBatterySaver: false,
        battery: unavailable,
      );
      expect(autoActive, isFalse);

      final manualActive = evaluateSaver(
        autoBatterySaver: true,
        threshold: 20,
        manualBatterySaver: true,
        battery: unavailable,
      );
      expect(manualActive, isTrue);
    });
  });

  group('Effective Settings Overrides Simulation Tests', () {
    AppSettings applyOverrides(AppSettings base, bool isActive) {
      if (!isActive) {
        return base..isBatterySaverActive = false;
      }
      return AppSettings()
        ..id = base.id
        ..enableDynamicTheming = false
        ..darkTheme = true
        ..disableBlur = true
        ..disableSquiggle = true
        ..dynamicLyrics = false
        ..blurredArtworkForLyrics = false
        ..disableAnimatedDuration = true
        ..keepBackgroundGradient = false
        ..enablePlayerGradient = false
        ..fullscreenVisualizerEnabled = false
        ..ambientColorBackground = false
        ..dynamicColorActiveLyrics = false
        ..dynamicAccentColor = false
        ..isBatterySaverActive = true;
    }

    test('Overrides apply OLED Pure Black, disable blur, squiggle, and dynamic theming', () {
      final userSettings = AppSettings()
        ..enableDynamicTheming = true
        ..darkTheme = false
        ..disableBlur = false
        ..disableSquiggle = false
        ..dynamicLyrics = true
        ..blurredArtworkForLyrics = true
        ..disableAnimatedDuration = false
        ..keepBackgroundGradient = true
        ..enablePlayerGradient = true;

      final overridden = applyOverrides(userSettings, true);

      expect(overridden.isBatterySaverActive, isTrue);
      expect(overridden.enableDynamicTheming, isFalse);
      expect(overridden.darkTheme, isTrue); // Pure Black OLED
      expect(overridden.disableBlur, isTrue);
      expect(overridden.disableSquiggle, isTrue);
      expect(overridden.dynamicLyrics, isFalse);
      expect(overridden.blurredArtworkForLyrics, isFalse);
      expect(overridden.disableAnimatedDuration, isTrue);
      expect(overridden.keepBackgroundGradient, isFalse);
      expect(overridden.enablePlayerGradient, isFalse);
    });

    test('Deactivating battery saver restores user preferences exactly', () {
      final userSettings = AppSettings()
        ..enableDynamicTheming = true
        ..darkTheme = false
        ..disableBlur = false
        ..disableSquiggle = false
        ..dynamicLyrics = true
        ..blurredArtworkForLyrics = true;

      final overridden = applyOverrides(userSettings, true);
      expect(overridden.isBatterySaverActive, isTrue);
      expect(overridden.enableDynamicTheming, isFalse);

      final restored = applyOverrides(userSettings, false);
      expect(restored.isBatterySaverActive, isFalse);
      expect(restored.enableDynamicTheming, isTrue);
      expect(restored.darkTheme, isFalse);
      expect(restored.disableBlur, isFalse);
      expect(restored.disableSquiggle, isFalse);
      expect(restored.dynamicLyrics, isTrue);
      expect(restored.blurredArtworkForLyrics, isTrue);
    });
  });
}
