import 'package:looper_player/core/utils/app_links.dart';
import 'package:looper_player/l10n/app_localizations.dart';

/// Services and projects Looper's online lyrics rely on, credited in About.
typedef LyricsCredit = ({String name, String description, String url});

List<LyricsCredit> lyricsCredits(AppLocalizations l10n) => [
  (
    name: 'lrc.red',
    description: l10n.creditLrcRedDesc,
    url: AppLinks.lrcRedWeb,
  ),
  (
    name: 'LyricsPlus',
    description: l10n.creditLyricsPlusDesc,
    url: AppLinks.lyricsPlusSource,
  ),
  for (final (name, url) in const [
    ('AMLL', AppLinks.amllWeb),
    ('NetEase', AppLinks.neteaseWeb),
    ('KuGou', AppLinks.kugouWeb),
    ('Musixmatch', AppLinks.musixmatchWeb),
    ('Lyricify', AppLinks.lyricifyWeb),
  ])
    (name: name, description: l10n.creditWordSyncedDesc, url: url),
  (name: 'LRCLIB', description: l10n.creditLrclibDesc, url: AppLinks.lrclibWeb),
  (
    name: 'MusicBrainz',
    description: l10n.creditMusicBrainzDesc,
    url: AppLinks.musicBrainzWeb,
  ),
  (
    name: 'am-lyrics',
    description: l10n.creditAmLyricsDesc,
    url: AppLinks.amLyricsSource,
  ),
  (
    name: 'Morphe Patches',
    description: l10n.creditMorpheDesc,
    url: AppLinks.morphePatchesSource,
  ),
];
