import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/premium_section.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Opens the sleep timer modal dialog on desktop.
void showSleepTimer(BuildContext context, [WidgetRef? ref]) {
  showDialog(
    context: context,
    builder: (ctx) => const _SleepTimerDesktopDialog(),
  );
}

/// Backwards compatibility alias for showSleepTimer
void showSleepTimerBottomSheet(BuildContext context, WidgetRef ref) {
  showSleepTimer(context, ref);
}

class _SleepTimerDesktopDialog extends StatelessWidget {
  const _SleepTimerDesktopDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF18181B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: const ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          child: SingleChildScrollView(
            child: SleepTimerSheetContent(isDialog: true),
          ),
        ),
      ),
    );
  }
}

class SleepTimerSheetContent extends ConsumerStatefulWidget {
  final bool isDialog;
  const SleepTimerSheetContent({super.key, this.isDialog = false});

  @override
  ConsumerState<SleepTimerSheetContent> createState() => _SleepTimerSheetContentState();
}

class _SleepTimerSheetContentState extends ConsumerState<SleepTimerSheetContent> {
  int _customMinutes = 30;
  int _customSongs = 3;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final playbackState = ref.watch(playbackProvider);
    final accentColor = Color(settings.accentColor);
    final useBlur = settings.enableDynamicTheming && !settings.disableBlur;
    final isPureBlack = settings.darkTheme;

    final sheetBg = widget.isDialog
        ? const Color(0xFF18181B)
        : (isPureBlack
            ? Colors.black
            : (useBlur ? Colors.black.withValues(alpha: 0.6) : const Color(0xFF1E1E1E)));

    Widget sheetContent = Container(
      padding: EdgeInsets.fromLTRB(
        24,
        widget.isDialog ? 24 : 20,
        24,
        widget.isDialog ? 24 : 32,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: widget.isDialog
            ? BorderRadius.circular(24)
            : const BorderRadius.vertical(top: Radius.circular(28)),
        border: widget.isDialog
            ? null
            : Border.all(
                color: isPureBlack
                    ? Colors.white10
                    : Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.isDialog) ...[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: playbackState.isSleepTimerActive
                        ? accentColor.withValues(alpha: 0.2)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.timer,
                    color: playbackState.isSleepTimerActive ? accentColor : Colors.white70,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sleep Timer',
                        style: AppFonts.jostStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        playbackState.isSleepTimerActive
                            ? (playbackState.sleepTimerDurationRemaining != null
                                ? 'Active: Stopping in ${formatSleepTimerRemaining(playbackState)}'
                                : 'Active: Stopping after ${formatSleepTimerRemaining(playbackState)}')
                            : 'Automatically fade out and pause playback',
                        style: AppFonts.jostStyle(
                          fontSize: 13,
                          color: playbackState.isSleepTimerActive
                              ? accentColor
                              : Colors.white54,
                          fontWeight: playbackState.isSleepTimerActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isDialog && Navigator.of(context).canPop())
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'STOP BY DURATION',
              style: AppFonts.jostStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white38,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            PremiumSection(
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              useExpanded: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          if (_customMinutes > 5) {
                            setState(() => _customMinutes -= 5);
                          } else if (_customMinutes > 1) {
                            setState(() => _customMinutes--);
                          }
                        },
                        icon: const Icon(LucideIcons.minus, color: Colors.white70, size: 16),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '$_customMinutes ${_customMinutes == 1 ? 'Min' : 'Mins'}',
                        style: AppFonts.jostStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _customMinutes += 5);
                        },
                        icon: const Icon(LucideIcons.plus, color: Colors.white70, size: 16),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(playbackProvider.notifier)
                          .startSleepTimer(duration: Duration(minutes: _customMinutes));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text('Start',
                        style: AppFonts.jostStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildCustomChip(
                      label: '5 Min',
                      onTap: () => _startTimer(const Duration(minutes: 5))),
                  _buildCustomChip(
                      label: '15 Min',
                      onTap: () => _startTimer(const Duration(minutes: 15))),
                  _buildCustomChip(
                      label: '30 Min',
                      onTap: () => _startTimer(const Duration(minutes: 30))),
                  _buildCustomChip(
                      label: '45 Min',
                      onTap: () => _startTimer(const Duration(minutes: 45))),
                  _buildCustomChip(
                      label: '1 Hour',
                      onTap: () => _startTimer(const Duration(hours: 1))),
                  _buildCustomChip(
                      label: '2 Hours',
                      onTap: () => _startTimer(const Duration(hours: 2))),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'STOP BY TRACKS',
              style: AppFonts.jostStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white38,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            PremiumSection(
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              useExpanded: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          if (_customSongs > 1) {
                            setState(() => _customSongs--);
                          }
                        },
                        icon: const Icon(LucideIcons.minus, color: Colors.white70, size: 16),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '$_customSongs ${_customSongs == 1 ? 'Song' : 'Songs'}',
                        style: AppFonts.jostStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _customSongs++);
                        },
                        icon: const Icon(LucideIcons.plus, color: Colors.white70, size: 16),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(playbackProvider.notifier)
                          .startSleepTimer(songCount: _customSongs);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text('Start',
                        style: AppFonts.jostStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildCustomChip(
                      label: 'End of Current Track (1 Song)',
                      highlight: true,
                      accentColor: accentColor,
                      onTap: () => _startSongs(1)),
                  _buildCustomChip(
                      label: '2 Songs', onTap: () => _startSongs(2)),
                  _buildCustomChip(
                      label: '3 Songs', onTap: () => _startSongs(3)),
                  _buildCustomChip(
                      label: '5 Songs', onTap: () => _startSongs(5)),
                  _buildCustomChip(
                      label: '10 Songs', onTap: () => _startSongs(10)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (playbackState.isSleepTimerActive)
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(playbackProvider.notifier).stopSleepTimer();
                  Navigator.pop(context);
                },
                icon: const Icon(LucideIcons.xCircle, size: 18),
                label: Text('Cancel Sleep Timer',
                    style: AppFonts.jostStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  side: const BorderSide(color: Colors.redAccent, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
          ],
        ),
      ),
    );

    if (useBlur && !isPureBlack && !widget.isDialog) {
      return RepaintBoundary(
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: sheetContent,
          ),
        ),
      );
    }

    return sheetContent;
  }

  void _startTimer(Duration duration) {
    ref.read(playbackProvider.notifier).startSleepTimer(duration: duration);
    Navigator.pop(context);
  }

  void _startSongs(int count) {
    ref.read(playbackProvider.notifier).startSleepTimer(songCount: count);
    Navigator.pop(context);
  }

  Widget _buildCustomChip({
    required String label,
    required VoidCallback onTap,
    bool highlight = false,
    Color? accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: highlight
              ? (accentColor ?? Colors.white).withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.06),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                label,
                style: AppFonts.jostStyle(
                  color: highlight && accentColor != null ? accentColor : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String formatSleepTimerRemaining(PlaybackState state) {
  if (state.sleepTimerDurationRemaining != null) {
    final duration = state.sleepTimerDurationRemaining!;
    final minutes = duration.inMinutes;
    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  } else if (state.sleepTimerSongsRemaining != null) {
    final count = state.sleepTimerSongsRemaining!;
    return count == 1 ? '1 song left' : '$count songs left';
  }
  return '';
}
