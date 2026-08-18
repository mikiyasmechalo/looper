import 'dart:io';
import 'package:looper_player/core/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/core/providers.dart';
import '../../features/library/presentation/library_notifier.dart';
import '../../features/settings/presentation/settings_notifier.dart';

enum WelcomeState { initial, scanning, noSongs }

final welcomeBypassedProvider = StateProvider<bool>((ref) {
  final forceWelcome = ref.watch(forceWelcomeProvider);
  if (forceWelcome) return false;

  final songs = ref.watch(libraryProvider).songs;
  final settings = ref.watch(settingsProvider);

  if (songs.isEmpty) {
    return false;
  }

  try {
    final checkCount = songs.length < 5 ? songs.length : 5;
    for (int i = 0; i < checkCount; i++) {
      if (File(songs[i].path).existsSync()) {
        return true;
      }
    }
    return false;
  } catch (_) {
    return false;
  }
});

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with WidgetsBindingObserver {
  WelcomeState _currentState = WelcomeState.initial;
  String _scanStatusMessage = "Initializing scanner...";

  bool _permissionGranted =
      false; // true if standard audio/storage OR all files is granted
  bool _notificationGranted = false;
  bool _audioGranted = false;
  bool _allFilesGranted = false;
  bool _autoScanTriggered = false;
  final List<String> _desktopFolders = [];

  int _scannedSongsCount = 0;
  int _processedBatchCount = 0;
  int _totalBatchCount = 0;
  String _currentScanningFolder = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionStatus();
    final existingFolders = ref.read(settingsProvider).libraryFolders;
    if (existingFolders.isNotEmpty) {
      _desktopFolders.addAll(existingFolders);
    }
  }

  Future<void> _addDesktopFolder() async {
    final String? path = await FilePicker.platform.getDirectoryPath();
    if (path != null && path.trim().isNotEmpty) {
      final cleanPath = path.trim();
      if (!_desktopFolders.contains(cleanPath)) {
        setState(() {
          _desktopFolders.add(cleanPath);
        });
      }
    }
  }

  void _removeDesktopFolder(int index) {
    setState(() {
      _desktopFolders.removeAt(index);
    });
  }

  Future<void> _startDesktopScanFlow() async {
    if (_desktopFolders.isEmpty) return;

    ref.read(forceWelcomeProvider.notifier).state = true;

    if (mounted) {
      setState(() {
        _currentState = WelcomeState.scanning;
        _scannedSongsCount = 0;
        _processedBatchCount = 0;
        _totalBatchCount = 0;
        _currentScanningFolder = '';
        _scanStatusMessage = "Saving selected folders...";
      });
    }

    await ref
        .read(settingsProvider.notifier)
        .updateLibraryFolders(_desktopFolders);

    int cumulativeBase = 0;
    int totalSongsDiscovered = 0;
    for (final path in _desktopFolders) {
      if (Directory(path).existsSync()) {
        final folderName = p.context.basename(path);
        if (mounted) {
          setState(() {
            _currentScanningFolder = folderName;
            _scanStatusMessage = "Analyzing path: $folderName...";
          });
        }
        final count = await ref.read(libraryProvider.notifier).scanLibrary(
          path,
          onProgress: (found, processed, total) {
            if (mounted) {
              setState(() {
                _scannedSongsCount = cumulativeBase + found;
                _processedBatchCount = processed;
                _totalBatchCount = total;
              });
            }
          },
        );
        cumulativeBase += count;
        totalSongsDiscovered += count;
      }
    }

    if (totalSongsDiscovered == 0) {
      if (mounted) {
        setState(() {
          _currentState = WelcomeState.noSongs;
        });
      }
    } else {
      ref.read(forceWelcomeProvider.notifier).state = false;
      ref.read(welcomeBypassedProvider.notifier).state = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionStatus();
    }
  }

  Future<void> _checkPermissionStatus() async {
    bool notif = false;
    bool aud = false;
    bool all = false;

    if (Platform.isAndroid) {
      notif = await Permission.notification.isGranted;
      all = await Permission.manageExternalStorage.isGranted;
      aud =
          (await Permission.audio.isGranted) ||
          (await Permission.storage.isGranted);
    } else {
      notif = true;
      aud = true;
      all = true;
    }

    if (mounted) {
      setState(() {
        _notificationGranted = notif;
        _audioGranted = aud;
        _allFilesGranted = all;
        _permissionGranted = aud || all; // Sufficient to scan
      });
    }
  }

  Future<void> _requestNotificationPermission() async {
    HapticFeedback.lightImpact();
    await Permission.notification.request();
    await _checkPermissionStatus();
  }

  Future<void> _requestAudioPermission() async {
    HapticFeedback.lightImpact();
    await Permission.audio.request();
    await Permission.storage.request();
    await _checkPermissionStatus();
  }

  Future<void> _requestAllFilesPermission() async {
    HapticFeedback.lightImpact();
    await Permission.manageExternalStorage.request();
    await _checkPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Elegant animated-like glowing backgrounds
          Positioned(
            top: -100,
            right: -100,
            child: _GlowOrb(color: colorScheme.primary.withValues(alpha: 0.12)),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: _GlowOrb(color: colorScheme.primary.withValues(alpha: 0.08)),
          ),

          // Subtle vignette overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.white.withValues(alpha: 0.001),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Layout Content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28.0,
                      vertical: 24.0,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      switchInCurve: Curves.easeInOutCubic,
                      switchOutCurve: Curves.easeInOutCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.05),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _buildStateContent(colorScheme, l10n),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateContent(ColorScheme colorScheme, AppLocalizations l10n) {
    switch (_currentState) {
      case WelcomeState.scanning:
        return _buildScanningState(colorScheme, l10n);
      case WelcomeState.noSongs:
        return _buildNoSongsState(colorScheme, l10n);
      case WelcomeState.initial:
      default:
        return _buildInitialState(colorScheme, l10n);
    }
  }

  // State 1: Initial Premium Welcome State
  Widget _buildInitialState(ColorScheme colorScheme, AppLocalizations l10n) {
    final librarySongs = ref.watch(libraryProvider).songs;
    final settings = ref.watch(settingsProvider);

    return Column(
      key: const ValueKey('initial_state'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Brand logo container with glowing borders
        Container(
          padding: const EdgeInsets.all(28.0),
          child: SizedBox(
            height: 100.s,
            width: 200.s,
            child: SvgPicture.asset(
              'assets/main_logo_transparent.svg',
              fit: BoxFit.contain,
              placeholderBuilder: (context) => Icon(
                LucideIcons.music,
                size: 50.s,
                color: colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Clean & Modern Title Typography
        Text(
          l10n.appTitle.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28.ts,
            fontWeight: FontWeight.w200,
            letterSpacing: 10,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "LOOPER PLAYER",
          style: TextStyle(
            fontSize: 11.ts,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary.withValues(alpha: 0.6),
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 32),

        // Premium About Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 16.s,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.aboutLooperPlayer.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.ts,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.welcomeAboutDesc,
                style: TextStyle(
                  fontSize: 13.ts,
                  height: 1.6,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Interactive Permission Checklist (Android Setup)
        if (Platform.isAndroid) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.shieldCheck,
                      size: 16.s,
                      color: Color(settings.accentColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.systemPermissionChecklist.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12.ts,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 1. Notification Permission Row
                _buildPermissionRow(
                  title: l10n.notificationAccess.toUpperCase(),
                  description: l10n.welcomeNotificationDesc,
                  isGranted: _notificationGranted,
                  onGrant: _requestNotificationPermission,
                  colorScheme: colorScheme,
                  accentColor: Color(settings.accentColor),
                  l10n: l10n,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1, color: Colors.white10),
                ),

                // 2. Music & Audio Permission Row
                _buildPermissionRow(
                  title: l10n.musicAudioAccess.toUpperCase(),
                  description: l10n.welcomeMusicAudioDesc,
                  isGranted: _audioGranted,
                  onGrant: _requestAudioPermission,
                  colorScheme: colorScheme,
                  accentColor: Color(settings.accentColor),
                  l10n: l10n,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1, color: Colors.white10),
                ),

                // 3. All Files Permission Row (Highly recommended)
                _buildPermissionRow(
                  title: l10n.allFilesAccess.toUpperCase(),
                  description: l10n.welcomeAllFilesDesc,
                  isGranted: _allFilesGranted,
                  onGrant: _requestAllFilesPermission,
                  colorScheme: colorScheme,
                  accentColor: Color(settings.accentColor),
                  l10n: l10n,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Desktop Multi-Folder Selection UI
        if (!Platform.isAndroid) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.folderPlus,
                          size: 16.s,
                          color: Color(settings.accentColor),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'MUSIC DIRECTORIES',
                          style: TextStyle(
                            fontSize: 12.ts,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.8),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Color(settings.accentColor).withValues(alpha: 0.15),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _addDesktopFolder,
                      icon: Icon(
                        LucideIcons.plus,
                        size: 14,
                        color: Color(settings.accentColor),
                      ),
                      label: Text(
                        'Add Folder',
                        style: TextStyle(
                          fontSize: 12.ts,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Add the local directories where your music tracks are stored.',
                  style: TextStyle(
                    fontSize: 12.ts,
                    color: Colors.white.withValues(alpha: 0.45),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Selected Folders List / Empty state
                if (_desktopFolders.isEmpty)
                  InkWell(
                    onTap: _addDesktopFolder,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.015),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.folderSearch,
                            size: 32.s,
                            color: Color(settings.accentColor).withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No folders selected yet',
                            style: TextStyle(
                              fontSize: 13.ts,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Click "+ Add Folder" to select your music directory',
                            style: TextStyle(
                              fontSize: 11.ts,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _desktopFolders.length,
                    separatorBuilder: (context, i) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final folderPath = _desktopFolders[index];
                      final folderName = p.context.basename(folderPath);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.folder,
                              size: 18.s,
                              color: Color(settings.accentColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    folderName.isNotEmpty
                                        ? folderName
                                        : folderPath,
                                    style: TextStyle(
                                      fontSize: 13.ts,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    folderPath,
                                    style: TextStyle(
                                      fontSize: 11.ts,
                                      color: Colors.white38,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                LucideIcons.trash2,
                                size: 16,
                                color: Colors.white54,
                              ),
                              tooltip: 'Remove folder',
                              onPressed: () => _removeDesktopFolder(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Modern Action Button area
        Column(
          children: [
            // GO START Button (Activated when permission is granted on Android, or at least 1 folder is selected on Desktop)
            _PremiumButton(
              onPressed: Platform.isAndroid
                  ? (_permissionGranted ? _startStorageScanFlow : null)
                  : (_desktopFolders.isNotEmpty ? _startDesktopScanFlow : null),
              label: l10n.goStart,
              icon: LucideIcons.playCircle,
              gradientColors: (Platform.isAndroid
                      ? _permissionGranted
                      : _desktopFolders.isNotEmpty)
                  ? [
                      Color(settings.accentColor),
                      Color(settings.accentColor).withValues(alpha: 0.75),
                    ]
                  : [
                      Colors.grey.withValues(alpha: 0.3),
                      Colors.grey.withValues(alpha: 0.2),
                    ],
            ),
            const SizedBox(height: 24),

            // Scan Completion Status feedback
            if (_permissionGranted && librarySongs.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Color(settings.accentColor).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(settings.accentColor).withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.checkCircle2,
                      color: Color(settings.accentColor),
                      size: 18.s,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.scanCompleteSongsDetected(librarySongs.length),
                      style: TextStyle(
                        fontSize: 12.ts,
                        fontWeight: FontWeight.bold,
                        color: Color(settings.accentColor),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (Platform.isAndroid)
              TextButton.icon(
                onPressed: _permissionGranted ? _selectCustomFolder : null,
                icon: Icon(
                  LucideIcons.folderSearch,
                  size: 16.s,
                  color: _permissionGranted ? Colors.white60 : Colors.white24,
                ),
                label: Text(
                  l10n.selectSpecificFolder,
                  style: TextStyle(
                    fontSize: 12.ts,
                    color: _permissionGranted ? Colors.white70 : Colors.white24,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPermissionRow({
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onGrant,
    required ColorScheme colorScheme,
    required Color accentColor,
    required AppLocalizations l10n,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2.0),
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: isGranted
                ? accentColor.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.03),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isGranted ? LucideIcons.check : LucideIcons.shieldAlert,
            size: 16.s,
            color: isGranted ? accentColor : Colors.white60,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11.ts,
                  height: 1.4,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (!isGranted)
          SizedBox(
            height: 30.s,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: accentColor.withValues(alpha: 0.15),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 0.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: onGrant,
              child: Text(
                l10n.grant,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.ts,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              l10n.granted,
              style: TextStyle(
                color: accentColor,
                fontSize: 11.ts,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  // State 2: Deep Scanning State
  Widget _buildScanningState(ColorScheme colorScheme, AppLocalizations l10n) {
    final settings = ref.watch(settingsProvider);
    final accentColor = Color(settings.accentColor);
    final isExtracting = _totalBatchCount > 0;

    return Column(
      key: const ValueKey('scanning_state'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Custom interactive glowing spinner
        SizedBox(
          width: 260.s,
          height: 180.s,
          child: Lottie.asset('assets/loading.json', fit: BoxFit.contain),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.deepStorageScanProgress,
          style: TextStyle(
            fontSize: 15.ts,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),

        // Current Folder Chip
        if (_currentScanningFolder.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.folder, size: 14.s, color: accentColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _currentScanningFolder,
                    style: TextStyle(
                      fontSize: 12.ts,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),

        // Real-time Songs Found & Extraction Progress Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.music,
                    size: 20.s,
                    color: accentColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$_scannedSongsCount Songs Found',
                    style: TextStyle(
                      fontSize: 16.ts,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (isExtracting) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _totalBatchCount > 0
                        ? (_processedBatchCount / _totalBatchCount).clamp(0.0, 1.0)
                        : null,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Reading metadata: $_processedBatchCount / $_totalBatchCount tracks',
                  style: TextStyle(
                    fontSize: 11.ts,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ] else if (_scanStatusMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _scanStatusMessage,
                  style: TextStyle(
                    fontSize: 11.ts,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            l10n.welcomeScanningFoldersDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.ts,
              color: Colors.white.withValues(alpha: 0.4),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // State 3: User Information / Instructions State when No Songs are Found
  Widget _buildNoSongsState(ColorScheme colorScheme, AppLocalizations l10n) {
    final settings = ref.watch(settingsProvider);
    return Column(
      key: const ValueKey('no_songs_state'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Informational Alert Icon
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber.withValues(alpha: 0.05),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Icon(LucideIcons.searchCode, size: 48.s, color: Colors.amber),
        ),
        const SizedBox(height: 24),

        Text(
          l10n.noMusicDetected,
          style: TextStyle(
            fontSize: 18.ts,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.welcomeNoSongsDesc,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.ts,
            color: Colors.white.withValues(alpha: 0.4),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),

        // Custom Step-by-Step Instruction Cards
        _buildInstructionStep(
          stepNumber: "1",
          title: l10n.connectDevice,
          description: l10n.welcomeInstructionConnectDesc,
          icon: LucideIcons.usb,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 16),
        _buildInstructionStep(
          stepNumber: "2",
          title: l10n.transferMusicFiles,
          description: l10n.welcomeInstructionTransferDesc,
          icon: LucideIcons.arrowDownToLine,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 16),
        _buildInstructionStep(
          stepNumber: "3",
          title: l10n.downloadAudioDirectly,
          description: l10n.welcomeInstructionDownloadDesc,
          icon: LucideIcons.globe,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 48),

        // Quick Retry/Actions
        _PremiumButton(
          onPressed: _startStorageScanFlow,
          label: l10n.rescanStorage,
          icon: LucideIcons.refreshCw,
          gradientColors: [
            Color(settings.accentColor),
            Color(settings.accentColor).withValues(alpha: 0.75),
          ],
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _currentState = WelcomeState.initial;
            });
          },
          child: Text(
            l10n.backToMainView,
            style: TextStyle(
              fontSize: 12.ts,
              color: Colors.white60,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.015),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.03),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36.s,
            width: 36.s,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, size: 16.s, color: colorScheme.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "STEP $stepNumber: $title",
                  style: TextStyle(
                    fontSize: 11.ts,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.ts,
                    color: Colors.white.withValues(alpha: 0.45),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Scan & Permission Flow Functions
  Future<void> _startStorageScanFlow() async {
    _autoScanTriggered = true;
    ref.read(forceWelcomeProvider.notifier).state = true;
    if (mounted) {
      setState(() {
        _currentState = WelcomeState.scanning;
        _scannedSongsCount = 0;
        _processedBatchCount = 0;
        _totalBatchCount = 0;
        _currentScanningFolder = '';
        _scanStatusMessage = "Clearing old data...";
      });
    }

    await ref.read(libraryProvider.notifier).clearAllData();

    if (mounted) {
      setState(() {
        _scanStatusMessage = "Checking system permissions...";
      });
    }

    // Check again
    await _checkPermissionStatus();

    if (Platform.isAndroid && !_permissionGranted) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.storagePermissionRequired)),
        );
        setState(() {
          _currentState = WelcomeState.initial;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _scanStatusMessage =
            "Traversing standard device directories recursively...";
      });
    }

    // Determine scan roots including all popular directories for maximum coverage
    final List<String> scanRoots = [];
    if (Platform.isLinux) {
      String defaultPath = '${Platform.environment['HOME']}/Music';
      try {
        final result = await Process.run('xdg-user-dir', ['MUSIC']);
        if (result.exitCode == 0 &&
            result.stdout.toString().trim().isNotEmpty) {
          defaultPath = result.stdout.toString().trim();
        }
      } catch (_) {}
      scanRoots.add(defaultPath);
    } else if (Platform.isAndroid) {
      final List<String> commonPaths = [
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Documents',
        '/storage/emulated/0/Audiobooks',
        '/storage/emulated/0/Podcasts',
        '/storage/emulated/0/Recordings',
        '/storage/emulated/0/Ringtones',
        '/storage/emulated/0/Alarms',
        '/storage/emulated/0/Notifications',
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Pictures',
        '/storage/emulated/0/Movies',
      ];
      int sdkInt = 0;
      try {
        final sdkMatch = RegExp(r'API\s+(\d+)').firstMatch(Platform.operatingSystemVersion);
        if (sdkMatch != null) {
          sdkInt = int.parse(sdkMatch.group(1)!);
        }
      } catch (_) {}

      final isAllFilesGranted = await Permission.manageExternalStorage.isGranted;
      final isLegacyStorageGranted = sdkInt < 30 && await Permission.storage.isGranted;
      final canScanRoot = isAllFilesGranted || isLegacyStorageGranted;

      if (canScanRoot) {
        scanRoots.add('/storage/emulated/0');
      } else {
        scanRoots.addAll(commonPaths);
      }
      // Check for SD Card mount points
      try {
        final storageDir = Directory('/storage');
        if (await storageDir.exists()) {
          final List<FileSystemEntity> entities = await storageDir
              .list()
              .toList();
          for (final entity in entities) {
            final name = p.context.basename(entity.path);
            if (name != 'emulated' &&
                name != 'self' &&
                name != 'knox-emulated' &&
                !name.contains('-')) {
              if (canScanRoot) {
                scanRoots.add(entity.path);
              } else {
                scanRoots.add('${entity.path}/Music');
                scanRoots.add('${entity.path}/Download');
              }
            }
          }
        }
      } catch (_) {}
    }

    int cumulativeBase = 0;
    int totalSongsDiscovered = 0;

    // Run scans
    for (final path in scanRoots) {
      if (Directory(path).existsSync()) {
        final folderName = p.context.basename(path);
        if (mounted) {
          setState(() {
            _currentScanningFolder = folderName;
            _scanStatusMessage = "Analyzing path: $folderName...";
          });
        }
        final count = await ref.read(libraryProvider.notifier).scanLibrary(
          path,
          onProgress: (found, processed, total) {
            if (mounted) {
              setState(() {
                _scannedSongsCount = cumulativeBase + found;
                _processedBatchCount = processed;
                _totalBatchCount = total;
              });
            }
          },
        );
        cumulativeBase += count;
        totalSongsDiscovered += count;
      }
    }

    if (totalSongsDiscovered == 0) {
      if (mounted) {
        setState(() {
          _currentState = WelcomeState.noSongs;
        });
      }
    } else {
      ref.read(forceWelcomeProvider.notifier).state = false;
      ref.read(welcomeBypassedProvider.notifier).state = true;
    }
  }

  // Choose Custom Folder Backup Function
  Future<void> _selectCustomFolder() async {
    await _checkPermissionStatus();
    if (Platform.isAndroid && !_permissionGranted) return;

    final String? path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      ref.read(forceWelcomeProvider.notifier).state = true;
      await ref.read(libraryProvider.notifier).clearAllData();

      final folderName = p.context.basename(path);
      if (mounted) {
        setState(() {
          _currentState = WelcomeState.scanning;
          _scannedSongsCount = 0;
          _processedBatchCount = 0;
          _totalBatchCount = 0;
          _currentScanningFolder = folderName;
          _scanStatusMessage = "Scanning selected path: $folderName...";
        });
      }

      final count = await ref.read(libraryProvider.notifier).scanLibrary(
        path,
        onProgress: (found, processed, total) {
          if (mounted) {
            setState(() {
              _scannedSongsCount = found;
              _processedBatchCount = processed;
              _totalBatchCount = total;
            });
          }
        },
      );
      if (count == 0) {
        if (mounted) {
          setState(() {
            _currentState = WelcomeState.noSongs;
          });
        }
      } else {
        ref.read(forceWelcomeProvider.notifier).state = false;
        ref.read(welcomeBypassedProvider.notifier).state = true;
      }
    }
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  const _GlowOrb({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320.s,
      height: 320.s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class _PremiumButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final List<Color> gradientColors;

  const _PremiumButton({
    required this.onPressed,
    required this.label,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    return Container(
      width: double.infinity,
      height: 56.s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isEnabled
              ? gradientColors
              : [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.02),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isEnabled ? Colors.white : Colors.white30,
                size: 20.s,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15.ts,
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? Colors.white : Colors.white30,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
