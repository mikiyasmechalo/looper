import 'dart:io';
import 'package:flutter/material.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';

/// Renders a single artist image or a collage of up to four images
/// (e.g. when the artist is a collaboration like "A ft. B").
class ArtistImage extends StatelessWidget {
  final List<String>? images;
  final String? imageUrl;
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Widget? placeholder;

  const ArtistImage({
    super.key,
    this.images,
    this.imageUrl,
    this.imagePath,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final localPaths = <String>[
      if (images != null)
        for (final path in images!)
          if (File(path).existsSync()) path,
    ];

    final Widget content;
    if (localPaths.length >= 2) {
      content = _buildCollage(localPaths.take(4).toList());
    } else if (localPaths.length == 1) {
      content = OptimizedImage(
        imagePath: localPaths.first,
        fit: fit,
        placeholder: placeholder,
      );
    } else {
      content = OptimizedImage(
        imageUrl: imageUrl,
        imagePath: imagePath,
        fit: fit,
        placeholder: placeholder,
      );
    }

    if (shape == BoxShape.circle) {
      return SizedBox(
        width: width,
        height: height,
        child: ClipOval(child: content),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: borderRadius != null
          ? ClipRRect(borderRadius: borderRadius!, child: content)
          : content,
    );
  }

  Widget _buildCollage(List<String> paths) {
    // SizedBox.expand forces tight constraints on each cell so the image is
    // drawn at full size with BoxFit.cover (cropped to fill) instead of being
    // letterboxed with black bars.
    Widget cell(String path, {EdgeInsets padding = EdgeInsets.zero}) => Padding(
          padding: padding,
          child: SizedBox.expand(
            child: OptimizedImage(
              imagePath: path,
              fit: BoxFit.cover,
              placeholder: const SizedBox.shrink(),
            ),
          ),
        );

    const gap = 2.0;

    switch (paths.length) {
      case 1:
        return cell(paths[0]);
      case 2:
        return Row(
          children: [
            Expanded(
              child: cell(paths[0], padding: const EdgeInsets.only(right: gap / 2)),
            ),
            Expanded(
              child: cell(paths[1], padding: const EdgeInsets.only(left: gap / 2)),
            ),
          ],
        );
      case 3:
        return Row(
          children: [
            Expanded(
              child: cell(paths[0], padding: const EdgeInsets.only(right: gap / 2)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: gap / 2),
                child: Column(
                  children: [
                    Expanded(
                      child: cell(paths[1], padding: const EdgeInsets.only(bottom: gap / 2)),
                    ),
                    Expanded(
                      child: cell(paths[2], padding: const EdgeInsets.only(top: gap / 2)),
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
                    child: cell(paths[0], padding: const EdgeInsets.only(right: gap / 2, bottom: gap / 2)),
                  ),
                  Expanded(
                    child: cell(paths[1], padding: const EdgeInsets.only(left: gap / 2, bottom: gap / 2)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: cell(paths[2], padding: const EdgeInsets.only(right: gap / 2, top: gap / 2)),
                  ),
                  Expanded(
                    child: cell(paths[3], padding: const EdgeInsets.only(left: gap / 2, top: gap / 2)),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }
}
