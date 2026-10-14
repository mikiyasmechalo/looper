import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/core/providers.dart';
import 'package:flutter_performance_optimizer/flutter_performance_optimizer.dart';

import 'core/db_service.dart';
import 'core/app_fonts.dart';
import 'core/system_tray_service.dart';
import 'ui/screens/home_screen.dart';

import 'package:metadata_god/metadata_god.dart';
import 'core/theme_provider.dart';
import 'package:looper_player/ui/widgets/keyboard_handler.dart';
import 'package:local_notifier/local_notifier.dart';
import 'core/logger_helper.dart';
import 'core/single_instance_service.dart';
import 'core/windows_file_association_service.dart';
import 'core/window_state_service.dart';
import 'core/navigation_provider.dart';

final dbInitializerProvider = FutureProvider<void>((ref) async {
  LoggerHelper.write('dbInitializerProvider: Initializing db and settings...');
  await DbService.init();
  await ref.read(settingsProvider.notifier).initialization;
  LoggerHelper.write('dbInitializerProvider: Initialization finished.');
});

void main(List<String> args) async {
  // Capture unhandled Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    final exceptionStr = details.exceptionAsString();
    if (exceptionStr.contains('raw_keyboard.dart') ||
        exceptionStr.contains('no keys are in keysPressed') ||
        exceptionStr.contains('Unable to parse JSON message')) {
      // Benign framework Win32 RawKeyboard synchronization anomaly
      return;
    }
    FlutterError.presentError(details);
    LoggerHelper.write(
      'Flutter Framework Exception: $exceptionStr',
      details.exception,
      details.stack,
    );
  };

  // Capture unhandled asynchronous errors
  PlatformDispatcher.instance.onError = (error, stack) {
    final errorStr = error.toString();
    if (errorStr.contains('raw_keyboard.dart') ||
        errorStr.contains('no keys are in keysPressed') ||
        errorStr.contains('Unable to parse JSON message')) {
      return true;
    }
    LoggerHelper.write('Unhandled Async Exception: $error', error, stack);
    return true;
  };

  WidgetsFlutterBinding.ensureInitialized();

  // Bound Flutter's in-memory image cache to prevent memory bloat during heavy library scrolling
  PaintingBinding.instance.imageCache.maximumSize = 25;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 12 * 1024 * 1024; // 12 MB

  // Enforce single instance on desktop before initializing heavy components
  final isPrimary = await SingleInstanceService.ensureSingleInstance(args);
  if (!isPrimary) {
    exit(0);
  }

  // Automatically register Windows file associations and context menu actions in background
  if (Platform.isWindows) {
    WindowsFileAssociationService.register();
  }

  // Initialize rolling file logging helper in parallel
  final Future<void> logsInit = LoggerHelper.init().then((_) {
    LoggerHelper.write('=======================================');
    LoggerHelper.write('Application starting...');
    LoggerHelper.write('Arguments: $args');
  }).catchError((e, s) {});

  final String? initialFile = args.isNotEmpty ? args.first : null;

  // Initialize desktop/window setups in parallel
  WindowState windowState = const WindowState();
  final Future<void> desktopInit = () async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      try {
        await localNotifier.setup(appName: 'Looper Player');
      } catch (e, s) {
        LoggerHelper.write('Failed to initialize LocalNotifier', e, s);
      }
      try {
        windowState = await WindowStateService.load();
        await windowManager.ensureInitialized();

        if (windowState.playerType == 'miniPlayer') {
          final miniMap = await WindowStateService.loadMiniSettings();
          final rawX = (miniMap['miniPlayerX'] as num?)?.toDouble() ?? (miniMap['x'] as num?)?.toDouble();
          final rawY = (miniMap['miniPlayerY'] as num?)?.toDouble() ?? (miniMap['y'] as num?)?.toDouble();
          final alwaysOnTop = miniMap['alwaysOnTop'] as bool? ?? true;

          WindowOptions windowOptions = WindowOptions(
            size: const Size(300, 420),
            center: rawX == null || rawX < 10 || rawY == null || rawY < 10,
            skipTaskbar: false,
            titleBarStyle: TitleBarStyle.hidden,
            title: 'Looper',
            backgroundColor: Colors.transparent,
          );
          await windowManager.waitUntilReadyToShow(windowOptions, () async {
            await windowManager.setMinimumSize(const Size(0, 0));
            await windowManager.setAsFrameless();
            await windowManager.setMaximizable(false);
            await windowManager.setHasShadow(false);
            await windowManager.setSize(const Size(300, 420));
            if (rawX != null && rawX > 10 && rawY != null && rawY > 10) {
              await windowManager.setPosition(Offset(rawX, rawY));
            }
            await windowManager.setAlwaysOnTop(alwaysOnTop);
            await windowManager.show();
            await windowManager.focus();
          });
        } else if (windowState.playerType == 'cornerWidget') {
          final miniMap = await WindowStateService.loadMiniSettings();
          final rawX = (miniMap['cornerX'] as num?)?.toDouble() ?? (miniMap['x'] as num?)?.toDouble();
          final rawY = (miniMap['cornerY'] as num?)?.toDouble() ?? (miniMap['y'] as num?)?.toDouble();
          final alwaysOnTop = miniMap['alwaysOnTop'] as bool? ?? true;

          WindowOptions windowOptions = WindowOptions(
            size: const Size(330, 110),
            center: rawX == null || rawX < 10 || rawY == null || rawY < 10,
            skipTaskbar: false,
            titleBarStyle: TitleBarStyle.hidden,
            title: 'Looper',
            backgroundColor: Colors.transparent,
          );
          await windowManager.waitUntilReadyToShow(windowOptions, () async {
            await windowManager.setMinimumSize(const Size(0, 0));
            await windowManager.setAsFrameless();
            await windowManager.setMaximizable(false);
            await windowManager.setHasShadow(false);
            await windowManager.setSize(const Size(330, 110));
            if (rawX != null && rawX > 10 && rawY != null && rawY > 10) {
              await windowManager.setPosition(Offset(rawX, rawY));
            }
            await windowManager.setAlwaysOnTop(alwaysOnTop);
            await windowManager.show();
            await windowManager.focus();
          });
        } else {
          final initialSize = Size(
            windowState.width.clamp(800.0, 3840.0),
            windowState.height.clamp(600.0, 2160.0),
          );
          WindowOptions windowOptions = WindowOptions(
            size: initialSize,
            center: windowState.x == null || windowState.y == null || windowState.x! < 0 || windowState.y! < 0,
            skipTaskbar: false,
            titleBarStyle: TitleBarStyle.hidden,
            title: 'Looper',
            backgroundColor: const Color(0xFF111111),
          );
          await windowManager.waitUntilReadyToShow(windowOptions, () async {
            await windowManager.setAlwaysOnTop(false);
            await windowManager.setMinimumSize(const Size(800, 600));
            if (windowState.x != null && windowState.y != null && windowState.x! >= 0 && windowState.y! >= 0) {
              await windowManager.setPosition(Offset(windowState.x!, windowState.y!));
            }
            if (windowState.isMaximized) {
              await windowManager.maximize();
            }
            await windowManager.show();
            await windowManager.focus();
          });
        }
        await SystemTrayService.instance.init();
      } catch (e, s) {
        LoggerHelper.write('Failed to initialize Window Manager', e, s);
      }
    }
  }();

  // Initialize database in parallel
  final Future<void> dbInit = () async {
    try {
      await DbService.init();
    } catch (e, s) {
      LoggerHelper.write('Main startup: Failed to load DB', e, s);
    }
  }();

  // Initialize native plugins in parallel
  final Future<void> nativePluginsInit = () async {
    try {
      MetadataGod.initialize();
    } catch (e, s) {
      LoggerHelper.write('Failed to initialize MetadataGod', e, s);
    }
    try {
      MpvAudioKit.ensureInitialized();
    } catch (e, s) {
      LoggerHelper.write('Failed to initialize MpvAudioKit', e, s);
    }
  }();

  // Wait for all boot-up stages concurrently
  await Future.wait([
    logsInit,
    desktopInit,
    dbInit,
    nativePluginsInit,
  ]);

  runApp(
    ProviderScope(
      overrides: [
        startupFileProvider.overrideWithValue(initialFile),
        startupArgsProvider.overrideWithValue(args),
        initialWindowStateProvider.overrideWithValue(windowState),
        if (windowState.playerType == 'full')
          appNavigationProvider.overrideWith(
            (ref) => NavigationNotifier(
              NavigationState(activeItem: NavItem.home, isPlayerExpanded: true),
            ),
          ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbInit = ref.watch(dbInitializerProvider);
    final isInitialized = dbInit.asData != null;

    final themeState = isInitialized ? ref.watch(themeProvider) : null;
    final settings = isInitialized ? ref.watch(settingsProvider) : null;

    Widget buildHome() {
      return dbInit.when(
        data: (_) => KeyboardHandler(
          key: ValueKey('${settings!.useNewFont}_${settings.customFontFamily}_${settings.customFontWeightDelta}_${settings.useNewFontLyrics}_${settings.customFontFamilyLyrics}_${settings.customFontWeightLyricsDelta}'),
          child: const HomeScreen(),
        ),
        loading: () => const PreAppLoadingScreenContent(),
        error: (err, stack) {
          LoggerHelper.write('Error during dbInitializerProvider execution: $err', err, stack);
          return CrashRecoveryScreen(error: err.toString(), stack: stack);
        },
      );
    }

    // Build the MaterialApp using either dynamic/loaded settings or fallback values.
    final ColorScheme colorScheme = (themeState != null)
        ? themeState.colorScheme
        : ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark);

    final bool useNewFont = settings?.useNewFont ?? false;
    final String customFontFamily = settings?.customFontFamily ?? '';
    final int customFontWeightDelta = settings?.customFontWeightDelta ?? 0;
    final String language = settings?.language ?? '';

    final String fontFamily = useNewFont ? (customFontFamily.isEmpty ? 'Jost' : customFontFamily) : 'DM Sans';

    final textTheme = AppFonts.adjustTextTheme(
      ThemeData.dark().textTheme.apply(
        fontFamily: fontFamily,
        displayColor: Colors.white,
        bodyColor: Colors.white70,
      ),
      useNewFont ? customFontWeightDelta : 0,
    );

    Widget buildMaterialApp(ColorScheme colorScheme) {
      return MaterialApp(
        navigatorKey: rootNavigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'Looper',
        color: const Color(0xFF111111),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: colorScheme.surface,
          fontFamily: fontFamily,
          textTheme: textTheme,
        ),
        themeAnimationDuration: const Duration(milliseconds: 1000),
        themeAnimationCurve: Curves.easeInOut,
        locale: language.isEmpty || language == 'system' ? null : Locale(language),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          final showPerformanceOptimizer = settings?.showPerformanceOptimizer ?? false;
          if (!showPerformanceOptimizer) return child!;
          return PerformanceOptimizer(
            enabled: showPerformanceOptimizer,
            showDashboard: showPerformanceOptimizer,
            enableInReleaseMode: true,
            child: child!,
          );
        },
        home: buildHome(),
      );
    }

    return buildMaterialApp(colorScheme);
  }
}

class PreAppLoadingScreenContent extends StatelessWidget {
  const PreAppLoadingScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F0F0C),
      body: SizedBox.shrink(),
    );
  }
}

class CrashRecoveryScreen extends StatefulWidget {
  final String error;
  final StackTrace? stack;

  const CrashRecoveryScreen({super.key, required this.error, this.stack});

  @override
  State<CrashRecoveryScreen> createState() => _CrashRecoveryScreenState();
}

class _CrashRecoveryScreenState extends State<CrashRecoveryScreen> {
  String _savedPath = '';
  bool _isSaving = true;

  @override
  void initState() {
    super.initState();
    _dumpCrashLog();
  }

  Future<void> _dumpCrashLog() async {
    final path = await LoggerHelper.saveCrashLog(widget.error, widget.stack);
    if (mounted) {
      setState(() {
        _savedPath = path;
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFFF5252),
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Looper Player Crashed',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'An unexpected initialization error occurred. A diagnostic crash report has been generated.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const SingleChildScrollView(
                    child: Text(
                      'An error occurred during app database or service initialization. This can happen if storage access is restricted or database files are corrupted.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_isSaving)
                  const CircularProgressIndicator()
                else ...[
                  if (_savedPath.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: const Text(
                        'Diagnostic crash report saved to application support folder.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB4BEFE),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_savedPath.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () => LoggerHelper.shareCrashLog(_savedPath),
                          icon: const Icon(Icons.share, size: 16),
                          label: const Text('Share Log'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C7086),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: () {
                          exit(0);
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Restart App'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5252),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
