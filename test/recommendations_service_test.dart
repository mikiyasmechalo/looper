import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/data/recommendations_service.dart';

Song createTestSong({
  required int id,
  required String path,
  required String title,
  int playCount = 0,
  bool isFavorite = false,
  DateTime? dateAdded,
}) {
  return Song()
    ..id = id
    ..path = path
    ..title = title
    ..playCount = playCount
    ..isFavorite = isFavorite
    ..dateAdded = dateAdded ?? DateTime.now();
}

void main() {
  group('RecommendationsService Quick Picks Tests', () {
    test('buildQuickPicksQueue never returns more than requested count', () {
      final songs = List.generate(
        50,
        (i) => createTestSong(
          id: i,
          path: '/music/song_$i.mp3',
          title: 'Song $i',
          playCount: i * 3,
          isFavorite: i % 3 == 0,
          dateAdded: DateTime.now().subtract(Duration(days: i)),
        ),
      );

      final result12 = RecommendationsService.buildQuickPicksQueue(
        songs,
        count: 12,
        random: Random(42),
      );

      expect(result12.length, equals(12));

      // Test with various counts
      for (final count in [1, 4, 7, 12, 15, 20]) {
        final res = RecommendationsService.buildQuickPicksQueue(
          songs,
          count: count,
          random: Random(1234),
        );
        expect(res.length, equals(count));
      }
    });

    test('buildQuickPicksQueue returns all unique songs if pool is smaller than count', () {
      final songs = List.generate(
        5,
        (i) => createTestSong(
          id: i,
          path: '/music/song_$i.mp3',
          title: 'Song $i',
        ),
      );

      final result = RecommendationsService.buildQuickPicksQueue(
        songs,
        count: 12,
        random: Random(42),
      );

      expect(result.length, equals(5));
    });

    test('buildQuickPicksQueue handles empty song list gracefully', () {
      final result = RecommendationsService.buildQuickPicksQueue(
        [],
        count: 12,
      );
      expect(result, isEmpty);
    });

    test('buildQuickPicksQueue deduplicates across source pools', () {
      // Create songs where the same songs are top played AND favorites AND recently added
      final songs = List.generate(
        30,
        (i) => createTestSong(
          id: i,
          path: '/music/unique_path_$i.mp3',
          title: 'Track $i',
          playCount: i == 0 ? 100 : 0,
          isFavorite: i == 0,
          dateAdded: i == 0 ? DateTime.now() : DateTime(2020),
        ),
      );

      final result = RecommendationsService.buildQuickPicksQueue(
        songs,
        count: 12,
        random: Random(99),
      );

      final paths = result.map((s) => s.path).toSet();
      expect(paths.length, equals(result.length));
      expect(result.length, equals(12));
    });
    test('buildQuickPicksQueue includes songs beyond 5th rank and outside top songs', () {
      // 100 songs total:
      // Songs 0-29 have playCounts from 100 down to 71 (top songs pool)
      // Songs 30-99 have 0 playCount (outside top songs)
      final songs = List.generate(
        100,
        (i) => createTestSong(
          id: i,
          path: '/music/song_$i.mp3',
          title: 'Song $i',
          playCount: i < 30 ? (100 - i) : 0,
          dateAdded: DateTime(2023, 1, 1).add(Duration(days: i)),
        ),
      );

      final picks = RecommendationsService.buildQuickPicksQueue(
        songs,
        count: 12,
        random: Random(123),
      );

      expect(picks.length, equals(12));

      // Verify that songs beyond the top 5 (rank > 5, i.e. id >= 5) are included
      final hasRankBeyond5 = picks.any((s) => s.id >= 5 && s.id < 30);
      expect(hasRankBeyond5, isTrue, reason: 'Expected top songs beyond 5th rank to be included');

      // Verify that songs outside the top songs (id >= 30, playCount == 0) are included
      final outsideTopCount = picks.where((s) => s.id >= 30).length;
      expect(outsideTopCount, greaterThanOrEqualTo(3), reason: 'Expected multiple random songs outside top songs');
    });
  });
}

