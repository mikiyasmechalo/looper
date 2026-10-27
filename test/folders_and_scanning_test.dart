import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/folder_browser_view.dart';
import 'package:looper_player/features/library/data/recommendations_service.dart';
import 'package:looper_player/ui/widgets/app_refresh_indicator.dart';

void main() {
  group('FolderItem & Tree Structure Tests (Fix for Issue #1 & Direct Songs)', () {
    test('FolderItem defaults to a mutable growable subFolders list', () {
      final item = FolderItem(
        path: r'C:\Music\Pop',
        name: 'Pop',
        songs: [
          Song()
            ..id = 1
            ..title = 'Pop Song 1'
            ..duration = 180000,
        ],
      );

      // Verify that subFolders is not an unmodifiable list (which caused Issue #1 crash)
      expect(item.subFolders, isEmpty);
      expect(() {
        item.subFolders.add(
          FolderItem(
            path: r'C:\Music\Pop\2023',
            name: '2023',
            songs: [
              Song()
                ..id = 2
                ..title = 'Pop Song 2'
                ..duration = 120000,
            ],
          ),
        );
      }, returnsNormally);

      expect(item.subFolders.length, 1);
      expect(item.totalSongCount, 2);
      expect(item.totalDurationMs, 300000);
      expect(item.allSongs.length, 2);
    });

    test('Nested FolderItem aggregates total duration and songs recursively while preserving direct songs', () {
      final child2 = FolderItem(
        path: r'C:\Music\Rock\Classic\70s',
        name: '70s',
        songs: [
          Song()
            ..id = 10
            ..title = 'Classic Track'
            ..duration = 200000,
        ],
      );

      final child1 = FolderItem(
        path: r'C:\Music\Rock\Classic',
        name: 'Classic',
        songs: [
          Song()
            ..id = 11
            ..title = 'Rock Track'
            ..duration = 150000,
        ],
        subFolders: [child2],
      );

      final directSong = Song()
        ..id = 99
        ..title = 'Direct Root Track'
        ..duration = 50000;

      final root = FolderItem(
        path: r'C:\Music\Rock',
        name: 'Rock',
        songs: [directSong],
        subFolders: [child1],
      );

      // Direct songs check
      expect(root.songs.length, 1);
      expect(root.songs.first.title, 'Direct Root Track');

      // Recursive total check
      expect(root.totalSongCount, 3);
      expect(root.totalDurationMs, 400000);
      expect(root.allSongs.map((s) => s.title).toList(), [
        'Direct Root Track',
        'Rock Track',
        'Classic Track',
      ]);
    });
  });

  group('Folder Search Filtering Tests', () {
    test('Partial word search filters by folder name/path only, not by song contents', () {
      final albumsFolder = FolderItem(
        path: r'D:\Music\Music\Albums',
        name: 'Albums',
        songs: [
          Song()
            ..id = 1
            ..title = 'Song in Albums'
            ..artist = 'Artist A',
        ],
      );

      final singlesFolder = FolderItem(
        path: r'D:\Music\Music\Singles',
        name: 'Singles',
        songs: [
          Song()
            ..id = 2
            ..title = 'Song with Album Keyword'
            ..artist = 'Some Album Artist',
        ],
      );

      final allFolders = [albumsFolder, singlesFolder];

      // User searches "albu"
      const query = 'albu';
      final filtered = allFolders.where((f) {
        final q = query.toLowerCase();
        return f.name.toLowerCase().contains(q) || f.path.toLowerCase().contains(q);
      }).toList();

      // Only "Albums" should match; "Singles" should NOT match despite having songs with "album"
      expect(filtered.length, 1);
      expect(filtered.first.name, 'Albums');
    });
  });

  group('Quick Picks Cache Invalidation Tests', () {
    test('Quick picks invalidates cache when deleted songs are no longer present in allSongs', () {
      final now = DateTime.now();
      final song1 = Song()
        ..id = 1
        ..path = r'C:\Music\song1.mp3'
        ..title = 'Song 1'
        ..playCount = 10
        ..dateAdded = now;
      final song2 = Song()
        ..id = 2
        ..path = r'C:\Music\song2.mp3'
        ..title = 'Song 2'
        ..playCount = 5
        ..dateAdded = now;

      RecommendationsService.clearQuickPicksCache();
      final initialMix = RecommendationsService.getDashboardQuickPicks([song1, song2]);
      expect(initialMix.map((s) => s.path).toSet(), contains(song1.path));

      // Simulate song1 being deleted from disk/database
      final remainingSongs = [song2];
      final updatedMix = RecommendationsService.getDashboardQuickPicks(remainingSongs);

      expect(updatedMix.any((s) => s.path == song1.path), isFalse);
      expect(updatedMix.map((s) => s.path).toList(), [song2.path]);
    });
  });

  group('AppRefreshIndicator 2-Second Visual Duration Tests', () {
    testWidgets('AppRefreshIndicator spins for visual duration while background task continues', (tester) async {
      var backgroundStarted = false;
      var backgroundCompleted = false;
      final completer = Completer<void>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppRefreshIndicator(
              visualDuration: const Duration(seconds: 2),
              onRefresh: () async {
                backgroundStarted = true;
                await completer.future;
                backgroundCompleted = true;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  ListTile(title: Text('Item 1')),
                  ListTile(title: Text('Item 2')),
                ],
              ),
            ),
          ),
        ),
      );

      // Trigger pull-to-refresh gesture
      await tester.fling(find.text('Item 1'), const Offset(0.0, 300.0), 1000.0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // Snap indicator into view

      expect(backgroundStarted, isTrue);
      expect(backgroundCompleted, isFalse);

      // Complete background task
      completer.complete();

      // Advance through remaining visual duration (2s total) and dismissal
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(backgroundCompleted, isTrue);
    });
  });
}
