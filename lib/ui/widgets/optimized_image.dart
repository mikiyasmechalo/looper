import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OptimizedImage extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final BoxFit fit;
  final int? cacheWidth;
  final int? cacheHeight;

  final FilterQuality filterQuality;

  const OptimizedImage({
    super.key,
    this.imagePath,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.cacheHeight,
    this.filterQuality = FilterQuality.low,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = placeholder ?? Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.white.withValues(alpha: 0.3),
          size: width != null ? (width! * 0.5).clamp(16, 48) : 32,
        ),
      ),
    );

    final bool imageUrlIsHttp = imageUrl?.startsWith('http') ?? false;
    final bool imagePathIsHttp = imagePath?.startsWith('http') ?? false;
    final String? resolvedImageUrl = imageUrlIsHttp
        ? imageUrl
        : (imagePathIsHttp ? imagePath : null);
    final String? resolvedImagePath = resolvedImageUrl == null
        ? (imagePath ?? imageUrl)
        : null;

    Widget imageWidget;

    final double dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;

    int? computedCacheWidth = cacheWidth;
    int? computedCacheHeight = cacheHeight;

    if (computedCacheWidth == null && computedCacheHeight == null) {
      const int minThumbnailSize = 128;
      const int maxMasterSize = 512;

      if (width != null && width!.isFinite && width! <= 220) {
        // Thumbnail / list / tile mode:
        // Use a resolution floor of 128px for small rows and clamp to 256px for tiles.
        final int scaled = (width! * dpr).round();
        computedCacheWidth = scaled.clamp(minThumbnailSize, 256);
      } else if (height != null && height!.isFinite && height! <= 220 && width == null) {
        final int scaled = (height! * dpr).round();
        computedCacheHeight = scaled.clamp(minThumbnailSize, 256);
      } else if (width != null && width!.isFinite) {
        // Large player views / header banners with explicit width:
        // Cap decode size to maxMasterSize (512px) to deliver pristine fidelity at ~1.04MB bitmap.
        final int scaled = (width! * dpr).round();
        computedCacheWidth = scaled.clamp(256, maxMasterSize);
      } else if (height != null && height!.isFinite) {
        // Large player views with explicit height:
        final int scaled = (height! * dpr).round();
        computedCacheHeight = scaled.clamp(256, maxMasterSize);
      } else {
        // Unconstrained flexible containers (cards, collages, responsive boxes):
        // Decodes at a lean 256px (~262KB) instead of bloated master decodes.
        computedCacheWidth = 256;
      }
    }

    if (resolvedImagePath != null && resolvedImagePath.isNotEmpty) {
      imageWidget = Image.file(
        File(resolvedImagePath),
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        cacheWidth: computedCacheWidth,
        cacheHeight: computedCacheHeight,
        filterQuality: filterQuality,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    } else if (resolvedImageUrl != null && resolvedImageUrl.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: resolvedImageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => fallback,
        errorWidget: (context, url, error) => fallback,
        memCacheWidth: computedCacheWidth,
        memCacheHeight: computedCacheHeight,
        filterQuality: filterQuality,
      );
    } else {
      imageWidget = fallback;
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: SizedBox(width: width, height: height, child: imageWidget),
      );
    }

    return SizedBox(width: width, height: height, child: imageWidget);
  }
}
