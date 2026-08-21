import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'settings_dialogs.dart';

class AddFolderTile extends ConsumerWidget {
  const AddFolderTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(LucideIcons.plus, color: Colors.white70),
      title: Text(
        l10n.addFolder,
        style: _tileTitleStyle(),
      ),
      trailing: const Icon(
        LucideIcons.chevronRight,
        color: Colors.white30,
        size: 18,
      ),
      onTap: () async {
        HapticFeedback.lightImpact();
        final String? path = await FilePicker.platform.getDirectoryPath();
        if (path != null) {
          ref.read(libraryProvider.notifier).scanLibrary(path);
        }
      },
    );
  }
}

class SyncLyricsOfflineTile extends ConsumerWidget {
  const SyncLyricsOfflineTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(LucideIcons.downloadCloud, color: Colors.white70),
      title: Text(
        l10n.syncLyricsOffline,
        style: _tileTitleStyle(),
      ),
      trailing: const Icon(
        LucideIcons.chevronRight,
        color: Colors.white30,
        size: 18,
      ),
      onTap: () {
        HapticFeedback.mediumImpact();
        ref.read(libraryProvider.notifier).prefetchLibraryLyrics();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.downloadingLyricsOffline)),
        );
      },
    );
  }
}

class RescanLibraryTile extends ConsumerWidget {
  const RescanLibraryTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(LucideIcons.refreshCcw, color: Colors.white70),
      title: Text(
        l10n.rescanLibrary,
        style: _tileTitleStyle(),
      ),
      trailing: const Icon(
        LucideIcons.chevronRight,
        color: Colors.white30,
        size: 18,
      ),
      onTap: () {
        HapticFeedback.mediumImpact();
        ref.read(libraryProvider.notifier).scanSavedFolders();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.scanningLibrary)));
      },
    );
  }
}

class SongViewStyleTile extends ConsumerWidget {
  const SongViewStyleTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final labels = ['Normal List', 'Compact List', 'Text Only', 'Grid Cards'];
    final currentStyle = settings.songViewStyleIndex.clamp(0, 3);

    return ListTile(
      leading: const Icon(LucideIcons.layoutList, color: Colors.white70),
      title: Text(
        'Song View Style',
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        labels[currentStyle],
        style: AppFonts.jostStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 13,
        ),
      ),
      trailing: DropdownButton<int>(
        value: currentStyle,
        dropdownColor: const Color(0xFF1E1E1E),
        underline: const SizedBox(),
        icon: const Icon(LucideIcons.chevronDown, color: Colors.white54, size: 18),
        items: const [
          DropdownMenuItem(value: 0, child: Text('Normal List', style: TextStyle(color: Colors.white))),
          DropdownMenuItem(value: 1, child: Text('Compact List', style: TextStyle(color: Colors.white))),
          DropdownMenuItem(value: 2, child: Text('Text Only', style: TextStyle(color: Colors.white))),
          DropdownMenuItem(value: 3, child: Text('Grid Cards', style: TextStyle(color: Colors.white))),
        ],
        onChanged: (val) {
          if (val != null) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).updateSongViewStyle(val);
          }
        },
      ),
    );
  }
}

class ResetLibraryTile extends ConsumerWidget {
  const ResetLibraryTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(LucideIcons.trash2, color: Colors.redAccent),
      title: Text(
        l10n.resetLibrary,
        style: AppFonts.jostStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        LucideIcons.alertTriangle,
        color: Colors.redAccent,
        size: 16,
      ),
      onTap: () {
        HapticFeedback.heavyImpact();
        showClearDialog(context, l10n);
      },
    );
  }
}

TextStyle _tileTitleStyle() => AppFonts.jostStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
    );

