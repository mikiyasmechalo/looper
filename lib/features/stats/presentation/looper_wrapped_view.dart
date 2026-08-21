import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/stats/presentation/stats_provider.dart';
import 'package:looper_player/features/stats/presentation/wrapped_provider.dart';

class LooperWrappedView extends ConsumerStatefulWidget {
  const LooperWrappedView({super.key});

  @override
  ConsumerState<LooperWrappedView> createState() => _LooperWrappedViewState();
}

class _LooperWrappedViewState extends ConsumerState<LooperWrappedView> {
  final PageController _pageController = PageController();
  final GlobalKey _cardRepaintKey = GlobalKey();
  int _currentPage = 0;
  bool _isExporting = false;

  Future<void> _exportCard() async {
    setState(() => _isExporting = true);
    try {
      final boundary = _cardRepaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final buffer = byteData.buffer.asUint8List();
        // In a desktop environment we can copy feedback or notify user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Looper Wrapped card captured successfully!'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Export error: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wrappedState = ref.watch(wrappedProvider);
    final theme = Theme.of(context);
    final data = wrappedState.data;

    if (wrappedState.isLoading || data == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F12),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final slides = [
      _buildIntroSlide(data, theme),
      _buildTopSongsSlide(data, theme),
      _buildArtistOfTheYearSlide(data, theme),
      _buildGenresSlide(data, theme),
      _buildPersonaSlide(data, theme),
      _buildRecapCardSlide(data, theme),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0F),
      body: Stack(
        children: [
          // Background Gradient Mesh
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(
                    _currentPage % 2 == 0 ? -0.4 : 0.4,
                    _currentPage % 2 == 0 ? -0.3 : 0.3,
                  ),
                  radius: 1.4,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.22),
                    Colors.purple.withValues(alpha: 0.12),
                    const Color(0xFF0B0B0E),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Navigation Bar with Year Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Looper Wrapped',
                        style: AppFonts.jostStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),

                      // Year Selector Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: wrappedState.selectedYear,
                            dropdownColor: const Color(0xFF1E1E24),
                            borderRadius: BorderRadius.circular(16),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            icon: const Icon(LucideIcons.chevronDown, size: 16, color: Colors.white70),
                            items: wrappedState.availableYears.map((y) {
                              return DropdownMenuItem<int>(
                                value: y,
                                child: Text('$y'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(wrappedProvider.notifier).setYear(val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Slide Progress Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: List.generate(slides.length, (idx) {
                      return Expanded(
                        child: Container(
                          height: 3.5,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: idx <= _currentPage
                                ? theme.colorScheme.primary
                                : Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Slide Content PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    children: slides,
                  ),
                ),

                // Bottom Carousel Navigation Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white70),
                        ),
                      const Spacer(),
                      if (_currentPage < slides.length - 1)
                        FilledButton.icon(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          icon: const Icon(LucideIcons.arrowRight, size: 16),
                          label: const Text('Next'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        )
                      else
                        FilledButton.icon(
                          onPressed: _exportCard,
                          icon: const Icon(LucideIcons.share2, size: 16),
                          label: Text(_isExporting ? 'Saving...' : 'Share Wrapped'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroSlide(WrappedYearData data, ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Icon(LucideIcons.sparkles, size: 54, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Your ${data.year} in Looper',
              style: AppFonts.jostStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'A celebration of your music journey, generated completely offline.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Minutes',
                    value: '${data.totalMinutes}',
                    subtitle: 'minutes of pure sound',
                    icon: LucideIcons.clock,
                    accent: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Total Plays',
                    value: '${data.totalPlays}',
                    subtitle: 'across ${data.uniqueSongsCount} tracks',
                    icon: LucideIcons.music,
                    accent: Colors.amberAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSongsSlide(WrappedYearData data, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Top 5 Tracks',
            style: AppFonts.jostStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            'The anthems that defined your ${data.year}',
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 24),
          if (data.topSongs.isEmpty)
            const Center(child: Text('No song plays recorded for this year.'))
          else
            for (int i = 0; i < data.topSongs.length; i++) ...[
              _RankedSongTile(rank: i + 1, stat: data.topSongs[i]),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }

  Widget _buildArtistOfTheYearSlide(WrappedYearData data, ThemeData theme) {
    final topArtist = data.artistOfTheYear;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                '👑 ARTIST OF THE YEAR',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                image: topArtist?.artPath != null
                    ? DecorationImage(image: FileImage(File(topArtist!.artPath!)), fit: BoxFit.cover)
                    : null,
                border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 3),
              ),
              child: topArtist?.artPath == null
                  ? const Icon(LucideIcons.mic2, size: 50, color: Colors.white54)
                  : null,
            ),
            const SizedBox(height: 18),
            Text(
              topArtist?.name ?? 'Unknown Artist',
              style: AppFonts.jostStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '${topArtist?.playCount ?? 0} plays • ${topArtist?.listeningTime.inMinutes ?? 0} mins listened',
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 28),
            if (data.topArtists.length > 1) ...[
              Text(
                'Other Top Artists',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: data.topArtists.skip(1).map((a) {
                  return Chip(
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    avatar: const Icon(LucideIcons.mic2, size: 14, color: Colors.white70),
                    label: Text(a.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGenresSlide(WrappedYearData data, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Sound Identity',
            style: AppFonts.jostStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            'The genres that shaped your musical year',
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 28),
          if (data.topGenres.isEmpty)
            const Center(child: Text('No genre metadata available.'))
          else
            for (final genre in data.topGenres) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(genre.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.5)),
                      Text('${(genre.percentage * 100).round()}%', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: genre.percentage,
                      minHeight: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildPersonaSlide(WrappedYearData data, ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, Colors.deepPurpleAccent],
                ),
              ),
              child: Icon(data.personaIcon, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 22),
            Text(
              data.listeningPersona,
              style: AppFonts.jostStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              data.personaDescription,
              style: TextStyle(fontSize: 14.5, color: Colors.white.withValues(alpha: 0.7), height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Longest Streak', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${data.longestStreakDays} Days 🔥', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Container(width: 1, height: 30, color: Colors.white12),
                  Column(
                    children: [
                      const Text('Peak Listening', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${data.peakListeningHour % 12 == 0 ? 12 : data.peakListeningHour % 12} ${data.peakListeningHour >= 12 ? 'PM' : 'AM'}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecapCardSlide(WrappedYearData data, ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: RepaintBoundary(
          key: _cardRepaintKey,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B1B22), Color(0xFF121216)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('LOOPER WRAPPED', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13)),
                    Text('${data.year}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 18),
                Text('${data.totalMinutes} Minutes', style: AppFonts.jostStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('${data.totalPlays} Songs played • ${data.uniqueArtistsCount} Artists', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.5)),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 10),
                const Text('Top Tracks:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                for (int i = 0; i < data.topSongs.take(3).length; i++) ...[
                  Text(
                    '${i + 1}. ${data.topSongs[i].title} - ${data.topSongs[i].artist ?? 'Unknown'}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                const SizedBox(height: 12),
                const Text('Top Artist:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(data.artistOfTheYear?.name ?? 'Unknown', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(data.personaIcon, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(data.listeningPersona, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.5)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: accent),
          const SizedBox(height: 12),
          Text(value, style: AppFonts.jostStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
        ],
      ),
    );
  }
}

class _RankedSongTile extends StatelessWidget {
  final int rank;
  final SongStat stat;

  const _RankedSongTile({required this.rank, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: rank == 1 ? Colors.amberAccent : Colors.white60,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white10,
              image: stat.artPath != null
                  ? DecorationImage(image: FileImage(File(stat.artPath!)), fit: BoxFit.cover)
                  : null,
            ),
            child: stat.artPath == null ? const Icon(LucideIcons.music, size: 20, color: Colors.white38) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(stat.artist ?? 'Unknown Artist', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${stat.playCount} plays',
              style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
