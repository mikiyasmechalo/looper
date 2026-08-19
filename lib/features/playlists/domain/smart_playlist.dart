import 'package:flutter/material.dart';
import 'package:looper_player/features/library/domain/models/models.dart';

/// Represents a dynamically computed smart playlist.
class SmartPlaylist {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final List<Song> songs;

  const SmartPlaylist({
    required this.id,
    required this.title,
    this.subtitle = 'Smart Playlist',
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.songs,
  });

  int get songCount => songs.length;

  int get totalDurationMs {
    return songs.fold(0, (sum, song) => sum + (song.duration ?? 0));
  }

  /// Converts this smart playlist snapshot into a permanent user [Playlist] object.
  Playlist toUserPlaylist([String? customName]) {
    final name = customName?.trim().isNotEmpty == true ? customName!.trim() : title;
    return Playlist()
      ..name = name
      ..songPaths = songs.map((s) => s.path).toList()
      ..dateCreated = DateTime.now()
      ..dateModified = DateTime.now();
  }
}
