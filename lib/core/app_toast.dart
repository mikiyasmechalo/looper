import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/providers.dart';

/// Lightweight, floating corner toast overlay with fluid animations and premium glass styling.
class AppToast {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show({
    required String title,
    String? subtitle,
    IconData? iconData,
    Widget? customIcon,
    Color? accentColor,
    Duration duration = const Duration(milliseconds: 2200),
  }) {
    final overlayState = rootNavigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    _dismissTimer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;

    final entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        title: title,
        subtitle: subtitle,
        iconData: iconData,
        customIcon: customIcon,
        accentColor: accentColor,
        duration: duration,
        onDismissed: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    overlayState.insert(entry);
  }

  static void showLoopToast({
    required String title,
    String? subtitle,
    Color? accentColor,
    IconData iconData = LucideIcons.repeat1,
    Widget? customIcon,
  }) {
    show(
      title: title,
      subtitle: subtitle,
      iconData: customIcon == null ? iconData : null,
      customIcon: customIcon,
      accentColor: accentColor,
      duration: const Duration(milliseconds: 2200),
    );
  }
}

class _ToastWidget extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? iconData;
  final Widget? customIcon;
  final Color? accentColor;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.title,
    this.subtitle,
    this.iconData,
    this.customIcon,
    this.accentColor,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _controller.forward();

    _timer = Timer(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            widget.onDismissed();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final bottomPadding = isDesktop ? 96.0 : media.padding.bottom + 84.0;
    final rightPadding = isDesktop ? 24.0 : 16.0;
    final primaryColor = widget.accentColor ?? Theme.of(context).colorScheme.primary;

    return Positioned(
      bottom: bottomPadding,
      right: rightPadding,
      child: Material(
        type: MaterialType.transparency,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xE6141418),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.customIcon != null)
                        widget.customIcon!
                      else if (widget.iconData != null)
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            widget.iconData,
                            size: 16,
                            color: primaryColor,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: AppFonts.jostStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 1),
                              Text(
                                widget.subtitle!,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
