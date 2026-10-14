import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/common/app_skeleton.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Shimmering stand-in for [AdvancedLyricRenderer] while lyrics load.
///
/// It lays out real [Text] lines in the user's lyrics font, size and
/// alignment, with the renderer's paddings, and lets [Skeletonizer] paint
/// each wrapped line as a bone. The layout matches the lyrics that replace
/// it, so the cross-fade doesn't jump. The placeholder strings are never
/// shown (only their wrapped shape is), so they aren't localized.
class LyricsSkeleton extends ConsumerWidget {
  const LyricsSkeleton({super.key});

  // Varied lengths give the ragged edge of real lyrics: some lines wrap
  // to two rows, some are a couple of words.
  static const List<String> _lines = [
    'Lorem ipsum dolor sit amet',
    'Consectetur adipiscing elit sed do',
    'Eiusmod tempor',
    'Ut enim ad minim veniam quis nostrud exercitation',
    'Duis aute irure dolor',
    'In reprehenderit in voluptate velit',
    'Esse cillum dolore',
    'Excepteur sint occaecat cupidatat non proident',
    'Sunt in culpa qui officia',
    'Deserunt mollit anim',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final textAlign = switch (settings.lyricsAlignment) {
      'left' => TextAlign.left,
      'right' => TextAlign.right,
      _ => TextAlign.center,
    };
    final style = AppFonts.getLyricsStyle(
      useNewFontLyrics: settings.useNewFontLyrics,
      family: settings.customFontFamilyLyrics,
      weightDelta: settings.customFontWeightLyricsDelta,
      activeWeightDelta: settings.activeLyricsFontWeightDelta,
      isActive: false,
      fontSize: 30,
      height: 1.15,
      color: Colors.white,
    );

    return AppSkeleton(
      // Justifying would stretch every wrapped row to full width and lose
      // the ragged edge that makes this read as lyrics.
      justifyMultiLineText: false,
      textBoneBorderRadius: const TextBoneBorderRadius.fromHeightFactor(.35),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        // Same insets as AdvancedLyricRenderer's list.
        padding: EdgeInsets.only(top: 60.s, left: 24.s, right: 24.s),
        children: [
          for (final line in _lines)
            Padding(
              // The renderer's 8 around each line plus the 8 inside it.
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(line, style: style, textAlign: textAlign),
            ),
        ],
      ),
    );
  }
}
