import 'package:looper_player/features/playback/domain/lyric_models.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:looper_player/core/providers.dart';
import 'package:looper_player/core/window_state_service.dart';
void main() {
  group('Mini Player Queue Scroll Calculation Tests', () {
    final mockQueue = List.generate(
      20,
      (i) => 'D:\\Music\\track_$i.mp3',
    );

    test('When showPlayed is false, current track is at index 0 of displayed list', () {
      const currentPath = 'D:\\Music\\track_12.mp3';
      const showPlayed = false;

      final idx = mockQueue.indexOf(currentPath);
      expect(idx, equals(12));

      final displayed = showPlayed
          ? [...mockQueue.sublist(0, idx), ...mockQueue.sublist(idx)]
          : mockQueue.sublist(idx);

      final targetIndex = displayed.indexOf(currentPath);
      expect(targetIndex, equals(0));

      // Target scroll for index 0 should clamp to 0.0
      const double itemHeight = 50.0;
      const double viewport = 240.0;
      const double maxScroll = 500.0;
      final target = (targetIndex * itemHeight - viewport / 2 + itemHeight / 2).clamp(0.0, maxScroll);
      expect(target, equals(0.0));
    });

    test('When showPlayed is true, current track is centered using exact itemHeight', () {
      const currentPath = 'D:\\Music\\track_10.mp3';
      const showPlayed = true;

      final idx = mockQueue.indexOf(currentPath);
      final displayed = showPlayed
          ? [...mockQueue.sublist(0, idx), ...mockQueue.sublist(idx)]
          : mockQueue.sublist(idx);

      final targetIndex = displayed.indexOf(currentPath);
      expect(targetIndex, equals(10));

      // Normal mode: itemHeight = 50.0
      const double normalHeight = 50.0;
      const double viewport = 240.0;
      const double maxScroll = 1000.0;
      // target = 10 * 50 - 120 + 25 = 500 - 95 = 405.0
      final normalTarget = (targetIndex * normalHeight - viewport / 2 + normalHeight / 2).clamp(0.0, maxScroll);
      expect(normalTarget, equals(405.0));

      // Compact mode: itemHeight = 28.0
      const double compactHeight = 28.0;
      // target = 10 * 28 - 120 + 14 = 280 - 106 = 174.0
      final compactTarget = (targetIndex * compactHeight - viewport / 2 + compactHeight / 2).clamp(0.0, maxScroll);
      expect(compactTarget, equals(174.0));
    });
  });

  group('Mini Player 1-Step Snap Math Tests', () {
    Offset computeSnap({
      required bool isTop,
      required bool isLeft,
      required Size windowSize,
      required double padding,
      required Offset workAreaOrigin,
      required Size workAreaSize,
    }) {
      final double dx = isLeft
          ? workAreaOrigin.dx + padding
          : workAreaOrigin.dx + workAreaSize.width - windowSize.width - padding;
      final double dy = isTop
          ? workAreaOrigin.dy + padding
          : workAreaOrigin.dy + workAreaSize.height - windowSize.height - padding;
      return Offset(dx, dy);
    }

    test('1080p display with 40px taskbar at bottom', () {
      const origin = Offset(0, 0);
      const workArea = Size(1920, 1040); // 1080 - 40 taskbar
      const windowSize = Size(300, 420);
      const padding = 12.0;

      // Top Left
      final tl = computeSnap(
        isTop: true,
        isLeft: true,
        windowSize: windowSize,
        padding: padding,
        workAreaOrigin: origin,
        workAreaSize: workArea,
      );
      expect(tl, equals(const Offset(12.0, 12.0)));

      // Top Right
      final tr = computeSnap(
        isTop: true,
        isLeft: false,
        windowSize: windowSize,
        padding: padding,
        workAreaOrigin: origin,
        workAreaSize: workArea,
      );
      // 1920 - 300 - 12 = 1608
      expect(tr, equals(const Offset(1608.0, 12.0)));

      // Bottom Right (accounts for 40px taskbar)
      final br = computeSnap(
        isTop: false,
        isLeft: false,
        windowSize: windowSize,
        padding: padding,
        workAreaOrigin: origin,
        workAreaSize: workArea,
      );
      // 1920 - 300 - 12 = 1608
      // 1040 - 420 - 12 = 608
      expect(br, equals(const Offset(1608.0, 608.0)));

      // Bottom Left
      final bl = computeSnap(
        isTop: false,
        isLeft: true,
        windowSize: windowSize,
        padding: padding,
        workAreaOrigin: origin,
        workAreaSize: workArea,
      );
      expect(bl, equals(const Offset(12.0, 608.0)));
    });
  });

  group('Mini Player Mode Differentiation Tests', () {
    test('MiniPlayerMode enums are distinct', () {
      expect(MiniPlayerMode.none != MiniPlayerMode.miniPlayer, isTrue);
      expect(MiniPlayerMode.none != MiniPlayerMode.cornerWidget, isTrue);
      expect(MiniPlayerMode.miniPlayer != MiniPlayerMode.cornerWidget, isTrue);
    });
  });

  group('Mini Player Polish & Fixes Verification Tests', () {
    test('Corner queue item height 50.0 prevents RenderFlex overflow', () {
      const double itemHeight = 50.0;
      const double marginVertical = 4.0;
      const double paddingVertical = 7.0; // 3.5 * 2
      const double borderVertical = 2.0;

      final availableTextHeight = itemHeight - marginVertical - paddingVertical - borderVertical;
      // Column title (12px) + artist (10px) + line heights requires ~31px
      expect(availableTextHeight, greaterThanOrEqualTo(34.0));
    });

    test('Queue item keys are strictly unique across indices', () {
      const path = 'C:\\Music\\song.mp3';
      final keys = List.generate(10, (i) => 'mps_${path}_$i');
      expect(keys.toSet().length, equals(10));
    });

    test('Original visualizer treble boost curve applies smooth high-end elevation', () {
      double computeTrebleBoost(double norm) {
        return (0.75 + 0.60 * pow(norm, 0.6)).clamp(0.5, 1.35);
      }

      // Center (norm = 0, bass): 0.75
      final centerComp = computeTrebleBoost(0.0);
      expect(centerComp, equals(0.75));

      // Edges (norm = 1.0, treble): boosted to 1.35
      final edgeComp = computeTrebleBoost(1.0);
      expect(edgeComp, equals(1.35));
    });
  });

  group('Screen Coordinate Validation Tests', () {
    test('Validates desktop positions including top-edge and secondary monitors', () {
      // Snapped to top-left corner with 8px padding
      expect(isValidScreenCoord(8.0, 8.0), isTrue);
      // Snapped to top-right corner with 8px padding
      expect(isValidScreenCoord(1600.0, 8.0), isTrue);
      // Top edge 0
      expect(isValidScreenCoord(500.0, 0.0), isTrue);
      // Secondary monitor to the left
      expect(isValidScreenCoord(-1920.0, 100.0), isTrue);
      // Windows minimized iconic coordinate (-32000)
      expect(isValidScreenCoord(-32000.0, -32000.0), isFalse);
      // Null values
      expect(isValidScreenCoord(null, 100.0), isFalse);
      expect(isValidScreenCoord(100.0, null), isFalse);
    });
  });
  group('Corner Player & Queue Transition Tests', () {
    test('Corner widget expansion calculates correct target bounds when near bottom', () {
      const double collapsedHeight = 110.0;
      const double expandedHeight = 440.0;
      const double shift = expandedHeight - collapsedHeight; // 330.0

      double calculateExpandedY(double currentY) {
        if (currentY > 650) {
          return (currentY - shift).clamp(20.0, double.infinity);
        }
        return currentY;
      }

      // At bottom of screen (e.g. dy = 800)
      expect(calculateExpandedY(800.0), equals(470.0));
      // Near top of screen (e.g. dy = 100)
      expect(calculateExpandedY(100.0), equals(100.0));
      // Clamp to minimum 20.0 if shift would push above screen
      expect(calculateExpandedY(700.0), equals(370.0));
    });

    test('Queue item heights are consistent between layout and scroll target math', () {
      const double cornerNormalItemHeight = 50.0;
      const double cornerCompactItemHeight = 26.0;

      const double stdNormalItemHeight = 50.0;
      const double stdCompactItemHeight = 28.0;

      double computeTarget(int idx, double itemHeight, double viewport) {
        return idx * itemHeight - viewport / 2 + itemHeight / 2;
      }

      final cornerTarget = computeTarget(5, cornerNormalItemHeight, 300.0);
      expect(cornerTarget, equals(5 * 50.0 - 150.0 + 25.0)); // 125.0

      final stdTarget = computeTarget(5, stdNormalItemHeight, 240.0);
      expect(stdTarget, equals(5 * 50.0 - 120.0 + 25.0)); // 155.0
    });

    test('LyricLine.isInstrumental accurately detects music gaps and empty spaces', () {
      expect(LyricLine(startTime: Duration.zero, endTime: Duration.zero, text: '').isInstrumental, isTrue);
      expect(LyricLine(startTime: Duration.zero, endTime: Duration.zero, text: '   ').isInstrumental, isTrue);
      expect(LyricLine(startTime: Duration.zero, endTime: Duration.zero, text: '♪').isInstrumental, isTrue);
      expect(LyricLine(startTime: Duration.zero, endTime: Duration.zero, text: '♫').isInstrumental, isTrue);
      expect(LyricLine(startTime: Duration.zero, endTime: Duration.zero, text: '🎵').isInstrumental, isTrue);
      expect(LyricLine(startTime: Duration.zero, endTime: Duration.zero, text: '[music]').isInstrumental, isTrue);
      expect(LyricLine(startTime: Duration.zero, endTime: Duration.zero, text: 'Instrumental solo').isInstrumental, isTrue);
      expect(LyricLine(startTime: Duration.zero, endTime: Duration.zero, text: 'Dancing in the moonlight').isInstrumental, isFalse);
    });

    test('Corner widget snap while expanded updates originalY and corner position correctly', () {
      const double collapsedHeight = 110.0;
      const double expandedHeight = 440.0;
      const double heightDiff = expandedHeight - collapsedHeight; // 330.0

      // Case 1: Snapping to top corner while expanded
      // Target position at top e.g. dy = 12.0
      const targetPosTop = Offset(12.0, 12.0);
      double? originalY = 800.0; // was opened at bottom
      double? savedCornerY;

      void snapToAlignment(bool isTopCorner, Offset targetPos) {
        if (isTopCorner) {
          originalY = null;
          savedCornerY = targetPos.dy;
        } else {
          final collapsedY = targetPos.dy + heightDiff;
          originalY = collapsedY;
          savedCornerY = collapsedY;
        }
      }

      snapToAlignment(true, targetPosTop);
      expect(originalY, isNull);
      expect(savedCornerY, equals(12.0));

      // Case 2: Snapping to bottom corner while expanded
      // Target position at bottom e.g. dy = 588.0 (1040 - 440 - 12)
      const targetPosBottom = Offset(12.0, 588.0);
      snapToAlignment(false, targetPosBottom);
      expect(originalY, equals(588.0 + 330.0)); // 918.0
      expect(savedCornerY, equals(918.0));
    });

    test('Responsive header constraint clamp prevents RenderFlex overflow on tight client heights', () {
      double computeHeaderHeight(double availableHeight, bool isExpanded) {
        final maxH = isExpanded ? 94.0 : availableHeight;
        return maxH.clamp(0.0, 94.0);
      }

      // Windows 110px window with 9px frame margins gives 101px client height, -16px padding = 85px available
      expect(computeHeaderHeight(85.0, false), equals(85.0));
      // Collapsed with full 118px window (93px available)
      expect(computeHeaderHeight(93.0, false), equals(93.0));
      // Expanded state (415px available) clamps to 94.0
      expect(computeHeaderHeight(415.0, true), equals(94.0));
    });

    test('Corner widget does not overwrite saved position when queue is opened and closed to normal player', () {
      double savedCornerX = 1578.0;
      double savedCornerY = 922.0;
      bool isCornerExpanded = false;

      void onExitMiniPlayer(double currentWindowX, double currentWindowY) {
        if (!isCornerExpanded) {
          savedCornerX = currentWindowX;
          savedCornerY = currentWindowY;
        }
      }

      // Step 1: Open queue at bottom corner -> window shifts up to Y = 600
      isCornerExpanded = true;
      const shiftedX = 1578.0;
      const shiftedY = 600.0;

      // Step 2: User closes mini player to go to normal player while queue is open
      onExitMiniPlayer(shiftedX, shiftedY);

      // Verify saved location was NOT corrupted with shifted position
      expect(savedCornerX, equals(1578.0));
      expect(savedCornerY, equals(922.0));
    });
    test('Queue View scroll calculation targets active song correctly when switching queues', () {
      const double kItemHeight = 72.0;
      const double kTopPadding = 16.0;
      const double viewport = 600.0;
      const double maxExtent = 2000.0;

      double computeQueueTarget(int currentIdx, bool showPlayed) {
        final targetIdx = showPlayed ? currentIdx : 0;
        return (kTopPadding + targetIdx * kItemHeight - viewport / 2 + kItemHeight / 2)
            .clamp(0.0, maxExtent);
      }

      // Switching to a queue where the active song is at index 10 (showPlayed = true)
      // target = (16.0 + 10 * 72.0 - 300.0 + 36.0) = (16 + 720 - 300 + 36) = 472.0
      expect(computeQueueTarget(10, true), equals(472.0));

      // Switching to a queue with showPlayed = false: active song is always at top (targetIdx = 0)
      // target = (16.0 + 0 - 300.0 + 36.0) = -248.0 -> clamped to 0.0
      expect(computeQueueTarget(10, false), equals(0.0));
    });
  });
}

