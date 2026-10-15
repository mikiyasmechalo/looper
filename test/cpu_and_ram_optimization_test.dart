import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/premium_progress_bar.dart';
import 'package:looper_player/ui/widgets/squiggly_slider/slider.dart';

void main() {
  group('SquigglySlider CPU Optimizations', () {
    testWidgets('SquigglySlider does not animate when amplitude is 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SquigglySlider(
              value: 0.5,
              onChanged: (_) {},
              squiggleAmplitude: 0.0,
              squiggleSpeed: 0.05,
            ),
          ),
        ),
      );

      final state = tester.state(find.byType(SquigglySlider)) as dynamic;
      expect(state.phaseController.isAnimating, isFalse);
    });

    testWidgets('SquigglySlider does not animate when speed is 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SquigglySlider(
              value: 0.5,
              onChanged: (_) {},
              squiggleAmplitude: 2.0,
              squiggleSpeed: 0.0,
            ),
          ),
        ),
      );

      final state = tester.state(find.byType(SquigglySlider)) as dynamic;
      expect(state.phaseController.isAnimating, isFalse);
    });

    testWidgets('SquigglySlider animates only when amplitude > 0 and speed != 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SquigglySlider(
              value: 0.5,
              onChanged: (_) {},
              squiggleAmplitude: 2.0,
              squiggleSpeed: 0.05,
            ),
          ),
        ),
      );

      final state = tester.state(find.byType(SquigglySlider)) as dynamic;
      expect(state.phaseController.isAnimating, isTrue);

      // Update widget to amplitude 0 -> should stop animating
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SquigglySlider(
              value: 0.5,
              onChanged: (_) {},
              squiggleAmplitude: 0.0,
              squiggleSpeed: 0.05,
            ),
          ),
        ),
      );

      expect(state.phaseController.isAnimating, isFalse);
    });
  });

  group('ExpressiveSlider Flat Progress Bar', () {
    testWidgets('Renders standard Slider without SquigglySlider when disableSquiggle is true', (tester) async {
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith((ref) => _MockSettingsNotifier(disableSquiggle: true)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: ExpressiveSlider(
                position: const Duration(seconds: 30),
                duration: const Duration(seconds: 120),
                isPlaying: true,
                onSeek: (_) {},
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      // With disableSquiggle = true, SquigglySlider is bypassed entirely
      expect(find.byType(SquigglySlider), findsNothing);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('Renders SquigglySlider when disableSquiggle is false', (tester) async {
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith((ref) => _MockSettingsNotifier(disableSquiggle: false)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: ExpressiveSlider(
                position: const Duration(seconds: 30),
                duration: const Duration(seconds: 120),
                isPlaying: true,
                onSeek: (_) {},
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SquigglySlider), findsOneWidget);
    });
  });
}

class _MockSettingsNotifier extends StateNotifier<AppSettings> implements SettingsNotifier {
  _MockSettingsNotifier({required bool disableSquiggle})
      : super(AppSettings()..disableSquiggle = disableSquiggle);

  @override
  Future<void> get initialization => Future.value();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
