/// Search terms for the lyrics APIs, built from a local file's tags.
///
/// Local tags are noisier than the catalogue entries the APIs match on:
/// `Kesariya (From "Brahmastra")` by `Pritam, Arijit Singh, Amitabh
/// Bhattacharya` finds nothing on LyricsPlus, while `Kesariya` by `Pritam`
/// (or `Arijit Singh`) does. So titles lose soundtrack/feature/video
/// suffixes, and each credited artist gets its own try after the full
/// credit.
class LyricsQuery {
  /// Bracketed parts that never change which recording it is.
  static final RegExp _noiseBrackets = RegExp(
    r'\s*[\(\[\{][^\)\]\}]*\b(from|feat|ft|featuring|with|prod|official|video|audio|lyrics?|visuali[sz]er|remaster(ed)?)\b[^\)\]\}]*[\)\]\}]',
    caseSensitive: false,
  );

  /// ` - From "Movie"`, ` - Remastered 2011`, ` - Official Video` tails.
  static final RegExp _noiseTail = RegExp(
    r'\s+[-–—|]\s+(from|feat|ft|official|remaster(ed)?|lyrics?)\b.*$',
    caseSensitive: false,
  );

  /// ` feat. X` / ` ft. X` written without brackets.
  static final RegExp _featTail = RegExp(
    r'\s+(feat\.?|ft\.?|featuring)\s+.*$',
    caseSensitive: false,
  );

  static final RegExp _artistSeparators = RegExp(
    r'\s*(?:,|;|/|\\|&|\+|\s+x\s+|\s+feat\.?\s+|\s+ft\.?\s+|\s+featuring\s+|\s+and\s+)\s*',
    caseSensitive: false,
  );

  static String cleanTitle(String title) {
    final cleaned = title
        .replaceAll(_noiseBrackets, '')
        .replaceAll(_noiseTail, '')
        .replaceAll(_featTail, '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.isEmpty ? title.trim() : cleaned;
  }

  /// The full credit first, then each artist in it (at most [max] tries in
  /// all - the APIs rate-limit bursts).
  static List<String> artistVariants(String artist, {int max = 3}) {
    final full = artist.replaceAll(RegExp(r'\s+'), ' ').trim();
    final variants = <String>[if (full.isNotEmpty) full];
    for (final part in full.split(_artistSeparators)) {
      final name = part.trim();
      if (name.isNotEmpty &&
          !variants.any((v) => v.toLowerCase() == name.toLowerCase())) {
        variants.add(name);
      }
    }
    return variants.take(max).toList();
  }

  /// Whether a catalogue hit ([title] by [artists]) is the song being
  /// looked up: same cleaned title, and one of the wanted artist's names
  /// among its credits. An untagged artist can't be checked, so the caller
  /// has to rely on the duration then.
  static bool sameSong({
    required String wantTitle,
    required String wantArtist,
    required String title,
    required Iterable<String> artists,
  }) {
    if (key(title) != key(wantTitle)) return false;
    if (wantArtist.trim().isEmpty ||
        wantArtist.trim().toLowerCase() == 'unknown artist') {
      return true;
    }
    final credited = artists.map(key).where((a) => a.isNotEmpty).toList();
    final all = credited.join();
    return artistVariants(wantArtist, max: 6)
        .map(key)
        .any(
          (want) =>
              want.isNotEmpty &&
              (all.contains(want) || credited.any(want.contains)),
        );
  }

  /// Whether a hit lasting [seconds] is the same recording as a file
  /// lasting [wantSeconds] - a different cut drifts out of sync. Unknown
  /// lengths pass.
  static bool sameLength(num? seconds, int wantSeconds, {int drift = 4}) =>
      wantSeconds <= 0 ||
      seconds == null ||
      seconds <= 0 ||
      (seconds - wantSeconds).abs() <= drift;

  /// Loose comparison key: lowercase letters and digits only (any script).
  static String key(String s) => cleanTitle(
    s,
  ).toLowerCase().replaceAll(RegExp(r'[^\p{L}\p{M}\p{N}]', unicode: true), '');
}
