import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/stats/presentation/stats_provider.dart';
import 'package:looper_player/features/stats/presentation/looper_wrapped_view.dart';
import 'package:looper_player/ui/widgets/artist_image.dart';

/// Shows the floating Stats & Insights modal dialog on desktop & mobile.
void showStatsDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (context) => const StatsDialog(),
  );
}

class StatsDialog extends ConsumerStatefulWidget {
  const StatsDialog({super.key});

  @override
  ConsumerState<StatsDialog> createState() => _StatsDialogState();
}

class _StatsDialogState extends ConsumerState<StatsDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(statsProvider.notifier).refresh();
      }
    });
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      final hours = d.inHours;
      final mins = d.inMinutes.remainder(60);
      return '${hours}h ${mins}m';
    } else if (d.inMinutes > 0) {
      final mins = d.inMinutes;
      final secs = d.inSeconds.remainder(60);
      return '${mins}m ${secs}s';
    } else {
      return '${d.inSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = min(screenHeight * 0.80, 640.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: GestureDetector(
          onTap: () {}, // Prevent taps inside dialog from dismissing it
          child: Center(
            child: Container(
              width: 750,
              height: dialogHeight,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF141417)
                    : const Color(0xFFFAFAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 36,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    // Header Bar
                    _buildHeader(context, ref, stats, primaryColor, isDark),

                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.white10,
                    ),

                    // Content Body (Instant in-place update without fade flash)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(22.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hero Stat Cards Row
                            _buildHeroMetrics(stats, primaryColor, isDark),

                            const SizedBox(height: 20),

                            // Daily Listening Activity Chart
                            _buildDailyActivityChart(
                              stats,
                              primaryColor,
                              isDark,
                            ),

                            const SizedBox(height: 20),

                            // Top Artist Highlight & Time of Day
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: _buildTopArtistHighlight(
                                    stats,
                                    primaryColor,
                                    isDark,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 4,
                                  child: _buildTimeOfDayCard(stats, isDark),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Top Tracks Leaderboard
                            _buildTopTracksSection(stats, primaryColor, isDark),

                            if (stats.topGenres.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              _buildTopGenresSection(
                                stats,
                                primaryColor,
                                isDark,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    StatsState stats,
    Color primaryColor,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 700;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(LucideIcons.barChart2, color: primaryColor, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Listening Stats',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LooperWrappedView()),
                        );
                      },
                      icon: const Icon(LucideIcons.sparkles, size: 13),
                      label: const Text('Wrapped', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(LucideIcons.x, size: 18),
                      splashRadius: 18,
                      style: IconButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildRangeSelector(ref, stats, primaryColor, isDark),
                ),
              ],
            );
          }

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.barChart2, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Listening Stats & Insights',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Your personal music habits and history',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Looper Wrapped Button
              FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LooperWrappedView()),
                  );
                },
                icon: const Icon(LucideIcons.sparkles, size: 14),
                label: const Text('Wrapped', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
              ),

              const SizedBox(width: 10),

              // Time Range Pills
              _buildRangeSelector(ref, stats, primaryColor, isDark),

              const SizedBox(width: 10),

              // Close Button
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(LucideIcons.x, size: 18),
                splashRadius: 18,
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRangeSelector(
    WidgetRef ref,
    StatsState stats,
    Color primaryColor,
    bool isDark,
  ) {
    final ranges = [
      {'label': 'Today', 'value': StatsTimeRange.today},
      {'label': 'This Week', 'value': StatsTimeRange.thisWeek},
      {'label': 'This Month', 'value': StatsTimeRange.thisMonth},
      {'label': 'All Time', 'value': StatsTimeRange.allTime},
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : const Color(0xFFE8E8EE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ranges.map((r) {
          final isSelected = stats.timeRange == r['value'];
          return GestureDetector(
            onTap: () {
              ref
                  .read(statsProvider.notifier)
                  .setTimeRange(r['value'] as StatsTimeRange);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                r['label'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeroMetrics(StatsState stats, Color primaryColor, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1C1C22) : const Color(0xFFF0F0F5);

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: LucideIcons.clock,
            iconColor: Colors.blueAccent,
            title: 'Listening Time',
            value: _formatDuration(stats.totalListeningTime),
            subtitle: '${stats.totalPlays} total plays',
            bg: cardBg,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildMetricCard(
            icon: LucideIcons.disc,
            iconColor: Colors.purpleAccent,
            title: 'Tracks Scrobbled',
            value: '${stats.totalPlays}',
            subtitle: '${stats.uniqueTracksCount} unique tracks',
            bg: cardBg,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildMetricCard(
            icon: LucideIcons.sparkles,
            iconColor: Colors.amberAccent,
            title: 'Top Artist',
            value: stats.topArtists.isNotEmpty
                ? stats.topArtists.first.name
                : 'None yet',
            subtitle: stats.topArtists.isNotEmpty
                ? '${stats.topArtists.first.playCount} plays (${_formatDuration(stats.topArtists.first.listeningTime)})'
                : 'Start playing tracks',
            bg: cardBg,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required Color bg,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyActivityChart(
    StatsState stats,
    Color primaryColor,
    bool isDark,
  ) {
    final maxMinutes = stats.dailyActivity.fold<double>(
      10.0,
      (maxVal, pt) => max(maxVal, pt.minutes),
    );

    final cardBg = isDark ? const Color(0xFF1C1C22) : const Color(0xFFF0F0F5);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Listening Activity',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Past 7 Days',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats.dailyActivity.map((point) {
                final heightFactor = (point.minutes / maxMinutes).clamp(
                  0.06,
                  1.0,
                );
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        point.minutes > 0 ? '${point.minutes.round()}m' : '',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: FractionallySizedBox(
                          heightFactor: heightFactor,
                          child: Container(
                            width: 24,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  primaryColor,
                                  primaryColor.withValues(alpha: 0.4),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        point.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopArtistHighlight(
    StatsState stats,
    Color primaryColor,
    bool isDark,
  ) {
    final topArtist = stats.topArtists.isNotEmpty
        ? stats.topArtists.first
        : null;
    final cardBg = isDark ? const Color(0xFF1C1C22) : const Color(0xFFF0F0F5);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Artist of the Period',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (topArtist != null)
            Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: ArtistImage(
                    images: topArtist.artistImages,
                    imageUrl: topArtist.artistImageUrl,
                    imagePath:
                        (topArtist.artistImages.isNotEmpty ||
                            topArtist.artistImageUrl != null)
                        ? null
                        : topArtist.artPath,
                    shape: BoxShape.circle,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: 0.15),
                      ),
                      child: Icon(
                        LucideIcons.mic,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topArtist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${topArtist.playCount} plays • ${_formatDuration(topArtist.listeningTime)} listened',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No artist stats yet for this range.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeOfDayCard(StatsState stats, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1C1C22) : const Color(0xFFF0F0F5);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Listening Hours',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTimePill(
                '🌅 Morning',
                stats.timeOfDayCounts['Morning'] ?? 0,
                isDark,
              ),
              _buildTimePill(
                '☀️ Afternoon',
                stats.timeOfDayCounts['Afternoon'] ?? 0,
                isDark,
              ),
              _buildTimePill(
                '🌆 Evening',
                stats.timeOfDayCounts['Evening'] ?? 0,
                isDark,
              ),
              _buildTimePill(
                '🌙 Night',
                stats.timeOfDayCounts['Night'] ?? 0,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePill(String label, int count, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $count',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTopTracksSection(
    StatsState stats,
    Color primaryColor,
    bool isDark,
  ) {
    final cardBg = isDark ? const Color(0xFF1C1C22) : const Color(0xFFF0F0F5);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Songs',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (stats.topSongs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'No song history recorded yet.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: min(stats.topSongs.length, 5),
              separatorBuilder: (context, i) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final song = stats.topSongs[index];
                return Row(
                  children: [
                    Container(
                      width: 24,
                      alignment: Alignment.center,
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: index == 0
                              ? Colors.amberAccent
                              : (index == 1
                                    ? Colors.grey.shade400
                                    : (index == 2
                                          ? Colors.brown.shade300
                                          : Colors.grey)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: song.artPath != null
                          ? Image.file(
                              File(song.artPath!),
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                width: 36,
                                height: 36,
                                color: primaryColor.withValues(alpha: 0.15),
                                child: Icon(
                                  LucideIcons.music,
                                  color: primaryColor,
                                  size: 16,
                                ),
                              ),
                            )
                          : Container(
                              width: 36,
                              height: 36,
                              color: primaryColor.withValues(alpha: 0.15),
                              child: Icon(
                                LucideIcons.music,
                                color: primaryColor,
                                size: 16,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            song.artist ?? 'Unknown Artist',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${song.playCount} plays',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTopGenresSection(
    StatsState stats,
    Color primaryColor,
    bool isDark,
  ) {
    final cardBg = isDark ? const Color(0xFF1C1C22) : const Color(0xFFF0F0F5);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Genre Distribution',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stats.topGenres.map((g) {
              final pct = (g.percentage * 100).round();
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${g.name} ($pct%)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
