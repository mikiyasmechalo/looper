import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';

/// Shows the A-B Looper modal dialog on desktop.
void showABLooper(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => const _ABLooperDialog(),
  );
}

class _ABLooperDialog extends StatelessWidget {
  const _ABLooperDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF18181B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: ABLooperContent(),
        ),
      ),
    );
  }
}

class ABLooperContent extends ConsumerWidget {
  const ABLooperContent({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final millis = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$minutes:$seconds.$millis';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackProvider);
    final notifier = ref.read(playbackProvider.notifier);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final song = playback.currentSong;
    final totalDuration = playback.duration;
    final currentPos = playback.position;
    final startA = playback.loopStart;
    final endB = playback.loopEnd;
    final isLooping = playback.isABLooping;

    if (song == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No track currently playing',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    final hasValidLoop = startA != null && endB != null && endB > startA;
    final loopLength = hasValidLoop ? endB - startA : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isLooping
                    ? primaryColor.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.repeat1,
                color: isLooping ? primaryColor : Colors.white70,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'A-B Section Looper',
                        style: AppFonts.jostStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (isLooping) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            'LOOPING',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (Navigator.of(context).canPop())
              IconButton(
                icon: const Icon(LucideIcons.x, size: 18, color: Colors.white54),
                onPressed: () => Navigator.of(context).pop(),
              ),
          ],
        ),

        const SizedBox(height: 20),

        // Visual Timeline Slider Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLooping
                  ? primaryColor.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              // Custom Timeline Graphic
              LayoutBuilder(
                builder: (context, constraints) {
                  final totalMs = totalDuration.inMilliseconds > 0
                      ? totalDuration.inMilliseconds
                      : 1;
                  final curPercent =
                      (currentPos.inMilliseconds / totalMs).clamp(0.0, 1.0);
                  final aPercent = startA != null
                      ? (startA.inMilliseconds / totalMs).clamp(0.0, 1.0)
                      : null;
                  final bPercent = endB != null
                      ? (endB.inMilliseconds / totalMs).clamp(0.0, 1.0)
                      : null;

                  return SizedBox(
                    height: 38,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Track Background
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),

                        // Shaded Loop Zone [A ── B]
                        if (aPercent != null && bPercent != null && bPercent > aPercent)
                          Positioned(
                            left: aPercent * constraints.maxWidth,
                            width: (bPercent - aPercent) * constraints.maxWidth,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: isLooping
                                    ? primaryColor.withValues(alpha: 0.6)
                                    : Colors.white38,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),

                        // Current Position indicator
                        Positioned(
                          left: (curPercent * constraints.maxWidth - 3).clamp(0.0, constraints.maxWidth - 6),
                          child: Container(
                            width: 6,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Marker A Pin
                        if (aPercent != null && startA != null)
                          Positioned(
                            left: (aPercent * constraints.maxWidth - 12).clamp(0.0, constraints.maxWidth - 24),
                            child: GestureDetector(
                              onTap: () => notifier.seek(startA),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'A',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Marker B Pin
                        if (bPercent != null && endB != null)
                          Positioned(
                            left: (bPercent * constraints.maxWidth - 12).clamp(0.0, constraints.maxWidth - 24),
                            child: GestureDetector(
                              onTap: () => notifier.seek(endB),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'B',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),

              // Time labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(currentPos),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (loopLength != null)
                    Text(
                      'Loop Length: ${_formatDuration(loopLength)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    _formatDuration(totalDuration),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Marker A & B Control Cards
        Row(
          children: [
            // Marker A Card
            Expanded(
              child: _MarkerCard(
                letter: 'A',
                label: 'Start Marker',
                duration: startA,
                isActive: startA != null,
                primaryColor: primaryColor,
                onSet: () {
                  HapticFeedback.lightImpact();
                  notifier.setLoopPointA();
                },
                onJump: startA != null ? () => notifier.seek(startA) : null,
                onNudgeBack: startA != null
                    ? () => notifier.adjustLoopPointA(const Duration(milliseconds: -500))
                    : null,
                onNudgeForward: startA != null
                    ? () => notifier.adjustLoopPointA(const Duration(milliseconds: 500))
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            // Marker B Card
            Expanded(
              child: _MarkerCard(
                letter: 'B',
                label: 'End Marker',
                duration: endB,
                isActive: endB != null,
                primaryColor: primaryColor,
                onSet: () {
                  HapticFeedback.lightImpact();
                  notifier.setLoopPointB();
                },
                onJump: endB != null ? () => notifier.seek(endB) : null,
                onNudgeBack: endB != null
                    ? () => notifier.adjustLoopPointB(const Duration(milliseconds: -500))
                    : null,
                onNudgeForward: endB != null
                    ? () => notifier.adjustLoopPointB(const Duration(milliseconds: 500))
                    : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Quick Preset Segment Buttons
        Row(
          children: [
            _PresetChip(
              label: 'Last 5s',
              onTap: () {
                HapticFeedback.lightImpact();
                final start = currentPos - const Duration(seconds: 5);
                notifier.setLoopRange(
                  start < Duration.zero ? Duration.zero : start,
                  currentPos,
                );
              },
            ),
            const SizedBox(width: 8),
            _PresetChip(
              label: 'Last 10s',
              onTap: () {
                HapticFeedback.lightImpact();
                final start = currentPos - const Duration(seconds: 10);
                notifier.setLoopRange(
                  start < Duration.zero ? Duration.zero : start,
                  currentPos,
                );
              },
            ),
            const SizedBox(width: 8),
            _PresetChip(
              label: 'Next 10s',
              onTap: () {
                HapticFeedback.lightImpact();
                final end = currentPos + const Duration(seconds: 10);
                notifier.setLoopRange(
                  currentPos,
                  end > totalDuration ? totalDuration : end,
                );
              },
            ),
            const Spacer(),
            if (startA != null || endB != null)
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  notifier.clearABLoop();
                },
                icon: const Icon(LucideIcons.trash2, size: 14),
                label: const Text('Clear Loop'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Main Action Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              notifier.toggleABLoop();
            },
            icon: Icon(
              isLooping ? LucideIcons.pause : LucideIcons.play,
              size: 18,
            ),
            label: Text(
              isLooping
                  ? 'Pause A-B Loop'
                  : (hasValidLoop ? 'Start A-B Loop' : 'Set Loop Point'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLooping
                  ? primaryColor
                  : (hasValidLoop
                      ? primaryColor.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.12)),
              foregroundColor: isLooping || hasValidLoop ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MarkerCard extends StatelessWidget {
  final String letter;
  final String label;
  final Duration? duration;
  final bool isActive;
  final Color primaryColor;
  final VoidCallback onSet;
  final VoidCallback? onJump;
  final VoidCallback? onNudgeBack;
  final VoidCallback? onNudgeForward;

  const _MarkerCard({
    required this.letter,
    required this.label,
    required this.duration,
    required this.isActive,
    required this.primaryColor,
    required this.onSet,
    this.onJump,
    this.onNudgeBack,
    this.onNudgeForward,
  });

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final millis = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$minutes:$seconds.$millis';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? primaryColor.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? primaryColor : Colors.white24,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.black : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              if (onJump != null)
                InkWell(
                  onTap: onJump,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      LucideIcons.cornerDownRight,
                      size: 14,
                      color: primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            duration != null ? _format(duration!) : '--:--.-',
            style: AppFonts.jostStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.white38,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onSet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive
                        ? primaryColor.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.08),
                    foregroundColor: isActive ? primaryColor : Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Set $letter',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(LucideIcons.minus, size: 14, color: Colors.white70),
                  tooltip: '-0.5s',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  onPressed: onNudgeBack,
                ),
                IconButton(
                  icon: const Icon(LucideIcons.plus, size: 14, color: Colors.white70),
                  tooltip: '+0.5s',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  onPressed: onNudgeForward,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
