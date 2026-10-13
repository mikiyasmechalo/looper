
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/analyze/domain/analyze_models.dart';
import 'package:looper_player/features/analyze/presentation/providers/analyze_notifier.dart';
import 'package:looper_player/features/analyze/presentation/widgets/analyze_activity_heatmap.dart';
import 'package:looper_player/features/analyze/presentation/widgets/analyze_genre_donut.dart';
import 'package:looper_player/features/analyze/presentation/widgets/analyze_hero_card.dart';
import 'package:looper_player/features/analyze/presentation/widgets/analyze_highlights.dart';
import 'package:looper_player/features/analyze/presentation/widgets/analyze_overview.dart';
import 'package:looper_player/features/analyze/presentation/widgets/analyze_top_albums_section.dart';
import 'package:looper_player/features/analyze/presentation/widgets/analyze_top_artists_section.dart';
import 'package:looper_player/features/analyze/presentation/widgets/analyze_top_songs_section.dart';
import 'package:looper_player/features/analyze/presentation/widgets/analyze_trend_chart.dart';
import 'package:looper_player/features/analyze/presentation/widgets/staggered_reveal.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/ui/widgets/empty_state_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/l10n.dart';
import 'package:looper_player/core/app_haptics.dart';

/// Looper Analyze — a personal listening "report card": top played songs,
/// top artists/albums/genres, and time-based insights (trend, streaks,
/// activity pattern) derived from [analyzeSnapshotProvider].
class LooperAnalyzeView extends ConsumerWidget {
  const LooperAnalyzeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(analyzeSnapshotProvider);
    final accent = Theme.of(context).colorScheme.primary;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop &&
            ref.read(appNavigationProvider).activeItem == NavItem.analyze) {
          ref.read(appNavigationProvider.notifier).goBack();
        }
      },
      child: Material(
        color: Colors.transparent,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(snapshot: snapshot),
                Expanded(
                  child: snapshot.hasHistory
                      ? _AnalyzeBody(snapshot: snapshot, accent: accent)
                      : EmptyStateCard(
                          icon: LucideIcons.barChart3,
                          title: context.l10n.noListeningHistoryYet,
                          subtitle: context.l10n.noListeningHistoryYetDesc,
                          accentColor: accent,
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

class _Header extends ConsumerWidget {
  final AnalyzeSnapshot snapshot;
  const _Header({required this.snapshot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          PremiumSection(
            borderRadius: BorderRadius.circular(24),
            width: 48,
            height: 48,
            useExpanded: false,
            forceNoBlur: true,
            onTap: () {
              AppHaptics.light();
              ref.read(appNavigationProvider.notifier).goBack();
            },
            child: const Icon(
              LucideIcons.arrowLeft,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.looperAnalyze,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.jostStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                if (snapshot.hasHistory)
                  Text(
                    context.l10n.analyzePlaysAndSongs(
                      snapshot.totalPlays,
                      snapshot.uniqueSongsPlayed,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.jostStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyzeBody extends ConsumerWidget {
  final AnalyzeSnapshot snapshot;
  final Color accent;
  const _AnalyzeBody({required this.snapshot, required this.accent});

  /// Past this width the report splits into two columns (landscape phones,
  /// tablets); below it, one column.
  static const double _twoColumnWidth = 720;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topSong = snapshot.topSongs.isNotEmpty
        ? snapshot.topSongs.first
        : null;

    final lead = <Widget>[
      if (topSong != null)
        AnalyzeHeroCard(
          stat: topSong,
          accent: accent,
          onPlay: () => ref
              .read(playbackProvider.notifier)
              .setPlaylist(snapshot.topSongs.map((s) => s.song).toList()),
        ),
      AnalyzeOverview(snapshot: snapshot, accent: accent),
      AnalyzeHighlights(snapshot: snapshot, accent: accent),
      if (snapshot.topSongs.isNotEmpty)
        AnalyzeTopSongsSection(topSongs: snapshot.topSongs, accent: accent),
    ];
    final rest = <Widget>[
      if (snapshot.topArtists.isNotEmpty)
        AnalyzeTopArtistsSection(
          topArtists: snapshot.topArtists,
          accent: accent,
        ),
      AnalyzeTrendChart(dailyCounts: snapshot.dailyCounts, accent: accent),
      if (snapshot.topGenres.isNotEmpty)
        AnalyzeGenreDonut(genres: snapshot.topGenres),
      if (snapshot.topAlbums.isNotEmpty)
        AnalyzeTopAlbumsSection(topAlbums: snapshot.topAlbums, accent: accent),
      AnalyzeActivityHeatmap(grid: snapshot.activityGrid, accent: accent),
    ];

    Widget column(List<Widget> sections, {int delayOffset = 0}) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sections.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 26),
            child: StaggeredReveal(
              delay: Duration(milliseconds: 60 * (i + delayOffset)),
              child: sections[i],
            ),
          ),
      ],
    );

    final twoColumns = MediaQuery.sizeOf(context).width >= _twoColumnWidth;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 160),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      child: twoColumns
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: column(lead)),
                const SizedBox(width: 20),
                Expanded(child: column(rest, delayOffset: 1)),
              ],
            )
          : column([...lead, ...rest]),
    );
  }
}


