import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';

/// Renders a playlist as a collage of up to four distinct song artworks.
///
/// Layouts mirror the artist collage (2 tiles split vertically, 3 tiles with a
/// stacked pair, 4 tiles as a 2x2 grid). When no artwork exists a fallback
/// background with a playlist icon is shown instead.
class PlaylistArtwork extends StatelessWidget {
  final List<Song> songs;
  final Color fallbackBackground;

  const PlaylistArtwork({
    super.key,
    required this.songs,
    required this.fallbackBackground,
  });

  @override
  Widget build(BuildContext context) {
    final distinct = _distinctArtworks();

    if (distinct.isEmpty) {
      return Container(
        color: fallbackBackground,
        child: const Center(
          child: Icon(LucideIcons.listMusic, size: 48, color: Colors.grey),
        ),
      );
    }

    return _buildCollage(distinct);
  }

  List<String> _distinctArtworks() {
    final seen = <String>{};
    final result = <String>[];
    for (final song in songs) {
      final art = song.artPath;
      if (art == null || art.isEmpty) continue;
      if (seen.add(art)) {
        result.add(art);
        if (result.length == 4) break;
      }
    }
    return result;
  }

  // SizedBox.expand forces tight constraints on each cell so images are drawn
  // at full size with BoxFit.cover (cropped) instead of being letterboxed.
  Widget _cell(String path, {EdgeInsets padding = EdgeInsets.zero}) {
    return Padding(
      padding: padding,
      child: SizedBox.expand(
        child: OptimizedImage(
          imagePath: path,
          fit: BoxFit.cover,
          placeholder: const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildCollage(List<String> paths) {
    const gap = 2.0;

    switch (paths.length) {
      case 1:
        return _cell(paths[0]);
      case 2:
        return Row(
          children: [
            Expanded(
              child: _cell(
                paths[0],
                padding: const EdgeInsets.only(right: gap / 2),
              ),
            ),
            Expanded(
              child: _cell(
                paths[1],
                padding: const EdgeInsets.only(left: gap / 2),
              ),
            ),
          ],
        );
      case 3:
        return Row(
          children: [
            Expanded(
              child: _cell(
                paths[0],
                padding: const EdgeInsets.only(right: gap / 2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: gap / 2),
                child: Column(
                  children: [
                    Expanded(
                      child: _cell(
                        paths[1],
                        padding: const EdgeInsets.only(bottom: gap / 2),
                      ),
                    ),
                    Expanded(
                      child: _cell(
                        paths[2],
                        padding: const EdgeInsets.only(top: gap / 2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      default:
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _cell(
                      paths[0],
                      padding: const EdgeInsets.only(
                        right: gap / 2,
                        bottom: gap / 2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _cell(
                      paths[1],
                      padding: const EdgeInsets.only(
                        left: gap / 2,
                        bottom: gap / 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _cell(
                      paths[2],
                      padding: const EdgeInsets.only(
                        right: gap / 2,
                        top: gap / 2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _cell(
                      paths[3],
                      padding: const EdgeInsets.only(
                        left: gap / 2,
                        top: gap / 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }
}
