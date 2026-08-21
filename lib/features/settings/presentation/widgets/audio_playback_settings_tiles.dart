import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'settings_widgets.dart';

class AutoTrimSilenceTile extends ConsumerWidget {
  const AutoTrimSilenceTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return SwitchListTile(
      secondary: const Icon(LucideIcons.scissors, color: Colors.white70),
      title: Text(
        'Auto-Trim Silence',
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        'Automatically detect and skip silence at the beginning and end of tracks for a tight transition',
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.autoTrimSilence,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateAutoTrimSilence(value);
      },
    );
  }
}

class GaplessPlaybackTile extends ConsumerWidget {
  const GaplessPlaybackTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return SwitchListTile(
      secondary: const Icon(LucideIcons.infinity, color: Colors.white70),
      title: Text(
        'Gapless Playback',
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        'Eliminate silence between consecutive tracks for continuous album & live playback',
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.gaplessPlayback,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateGaplessPlayback(value);
      },
    );
  }
}

class CrossfadeDurationSlider extends ConsumerWidget {
  const CrossfadeDurationSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return SettingsSliderTile(
      icon: LucideIcons.blend,
      title: 'Crossfade Duration',
      subtitle: settings.crossfadeDuration == 0
          ? 'Disabled (Pure Gapless transitions)'
          : 'Smoothly fade out track and fade in next over ${settings.crossfadeDuration}s',
      value: settings.crossfadeDuration.toDouble(),
      min: 0,
      max: 12,
      divisions: 12,
      suffix: 's',
      onChanged: (value) {
        ref
            .read(settingsProvider.notifier)
            .updateCrossfadeDuration(value.round());
      },
    );
  }
}

class CrossfadeModeTile extends ConsumerWidget {
  const CrossfadeModeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    if (settings.crossfadeDuration <= 0) return const SizedBox.shrink();

    return ListTile(
      leading: const Icon(LucideIcons.gitCommit, color: Colors.white70),
      title: Text('Crossfade Mode', style: _tileTitleStyle()),
      subtitle: Text(
        settings.crossfadeMode == 0
            ? 'Always (Auto & Manual)'
            : settings.crossfadeMode == 1
                ? 'Automatic Transitions Only'
                : 'Manual Skips Only',
        style: _tileSubtitleStyle(),
      ),
      trailing: DropdownButton<int>(
        value: (settings.crossfadeMode >= 0 && settings.crossfadeMode <= 2)
            ? settings.crossfadeMode
            : 0,
        dropdownColor: const Color(0xFF1E1E1E),
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(value: 0, child: Text('Always')),
          DropdownMenuItem(value: 1, child: Text('Auto Only')),
          DropdownMenuItem(value: 2, child: Text('Manual Only')),
        ],
        onChanged: (value) {
          if (value != null) {
            ref.read(settingsProvider.notifier).updateCrossfadeMode(value);
          }
        },
      ),
    );
  }
}

class FadePlayPauseStopTile extends ConsumerWidget {
  const FadePlayPauseStopTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.music, color: Colors.white70),
      title: Text(
        l10n.fadePlayPauseStop,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.fadePlayPauseStopDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.fadePlayPauseStop,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateFadePlayPauseStop(value);
      },
    );
  }
}

class FadeDurationSlider extends ConsumerWidget {
  const FadeDurationSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SettingsSliderTile(
      icon: LucideIcons.sliders,
      title: l10n.fadeDuration,
      subtitle: l10n.fadeDurationDesc,
      value: settings.playPauseStopFadeLength.toDouble(),
      min: 10,
      max: 1000,
      divisions: 99,
      suffix: 'ms',
      onChanged: (value) {
        ref
            .read(settingsProvider.notifier)
            .updatePlayPauseStopFadeLength(value.round());
      },
    );
  }
}


class ManageAudioFocusTile extends ConsumerWidget {
  const ManageAudioFocusTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.phoneCall, color: Colors.white70),
      title: Text(
        l10n.manageAudioFocusTitle,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.manageAudioFocusDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.audioFocus,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateAudioFocus(value);
      },
    );
  }
}

class ResumeAfterCallTile extends ConsumerWidget {
  const ResumeAfterCallTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.phoneCall, color: Colors.white70),
      title: Text(
        l10n.resumeAfterCallTitle,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.resumeAfterCallDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.resumeAfterCall,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateResumeAfterCall(value);
      },
    );
  }
}

class ResumeOnStartTile extends ConsumerWidget {
  const ResumeOnStartTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.power, color: Colors.white70),
      title: Text(
        l10n.resumeOnStartTitle,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.resumeOnStartDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.resumeOnStart,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateResumeOnStart(value);
      },
    );
  }
}

class PersistQueueTile extends ConsumerWidget {
  const PersistQueueTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.save, color: Colors.white70),
      title: Text(
        l10n.persistQueueTitle,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.persistQueueDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.persistQueue,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updatePersistQueue(value);
      },
    );
  }
}

class PermanentAudioFocusChangeTile extends ConsumerWidget {
  const PermanentAudioFocusChangeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.alertCircle, color: Colors.white70),
      title: Text(
        l10n.permanentFocusChangePause,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.permanentFocusChangePauseDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.permanentAudioFocusChange,
      onChanged: (value) {
        ref
            .read(settingsProvider.notifier)
            .updatePermanentAudioFocusChange(value);
      },
    );
  }
}

class AudioFocusRequestOnPlayTile extends ConsumerWidget {
  const AudioFocusRequestOnPlayTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.playCircle, color: Colors.white70),
      title: Text(
        l10n.audioFocusGetFocus,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.audioFocusGetFocusDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.audioFocusRequestOnPlay,
      onChanged: (value) {
        ref
            .read(settingsProvider.notifier)
            .updateAudioFocusRequestOnPlay(value);
      },
    );
  }
}

class AudioFocusReleaseOnPauseTile extends ConsumerWidget {
  const AudioFocusReleaseOnPauseTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.pauseCircle, color: Colors.white70),
      title: Text(
        l10n.audioFocusReleaseFocus,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.audioFocusReleaseFocusDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.audioFocusReleaseOnPause,
      onChanged: (value) {
        ref
            .read(settingsProvider.notifier)
            .updateAudioFocusReleaseOnPause(value);
      },
    );
  }
}

class AudioFocusStopOnOtherSessionTile extends ConsumerWidget {
  const AudioFocusStopOnOtherSessionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.stopCircle, color: Colors.white70),
      title: Text(
        l10n.audioFocusStopOnOtherSession,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.audioFocusStopOnOtherSessionDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.audioFocusStopOnOtherSession,
      onChanged: (value) {
        ref
            .read(settingsProvider.notifier)
            .updateAudioFocusStopOnOtherSession(value);
      },
    );
  }
}

class AudioFocusRestartOnGainTile extends ConsumerWidget {
  const AudioFocusRestartOnGainTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.refreshCw, color: Colors.white70),
      title: Text(
        l10n.audioFocusRestartOnGain,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.audioFocusRestartOnGainDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.audioFocusRestartOnGain,
      onChanged: (value) {
        ref
            .read(settingsProvider.notifier)
            .updateAudioFocusRestartOnGain(value);
      },
    );
  }
}

class ShuffleTile extends ConsumerWidget {
  const ShuffleTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          secondary: const Icon(LucideIcons.shuffle, color: Colors.white70),
          title: Text(
            l10n.shuffleTitle,
            style: _tileTitleStyle(),
          ),
          subtitle: Text(
            settings.shuffle ? l10n.shuffleEnabledDesc : l10n.shuffleDisabledDesc,
            style: _tileSubtitleStyle(),
          ),
          activeThumbColor: Color(settings.accentColor),
          value: settings.shuffle,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateShuffle(value);
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 72, right: 16, bottom: 12),
          child: Text(
            l10n.shuffleSwitchingDesc,
            style: AppFonts.jostStyle(
              color: Colors.white30,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

class PauseOnDuckTile extends ConsumerWidget {
  const PauseOnDuckTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.volumeX, color: Colors.white70),
      title: Text(
        l10n.pauseOnDuckTitle,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.pauseOnDuckDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.pauseOnDuck,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updatePauseOnDuck(value);
      },
    );
  }
}

class ResumeOnBluetoothConnectTile extends ConsumerWidget {
  const ResumeOnBluetoothConnectTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.bluetooth, color: Colors.white70),
      title: Text(
        l10n.resumeOnBluetoothConnectTitle,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.resumeOnBluetoothConnectDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.resumeOnBluetoothConnect,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateResumeOnBluetoothConnect(value);
      },
    );
  }
}

TextStyle _tileTitleStyle() => AppFonts.jostStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
    );

TextStyle _tileSubtitleStyle() => AppFonts.jostStyle(
      color: Colors.white54,
      fontSize: 12,
    );

