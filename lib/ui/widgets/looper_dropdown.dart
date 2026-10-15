import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';

class LooperDropdownItem<T> {
  final T value;
  final Widget label;
  final String? text;
  final IconData? icon;

  const LooperDropdownItem({
    required this.value,
    required this.label,
    this.text,
    this.icon,
  });

  factory LooperDropdownItem.fromDropdownMenuItem(DropdownMenuItem<T> item) {
    return LooperDropdownItem(
      value: item.value as T,
      label: item.child,
    );
  }
}

/// A modern, glassmorphic dropdown widget replacing Flutter's default DropdownButton.
/// Supports backdrop blur, smooth scale/fade animations, custom widths, and hover highlights.
class LooperDropdown<T> extends ConsumerStatefulWidget {
  final T? value;
  final List<LooperDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final double? width;
  final double height;
  final String? placeholder;
  final EdgeInsetsGeometry padding;
  final Alignment menuAlignment;
  final Widget Function(BuildContext context, bool isOpen)? customTrigger;

  const LooperDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width,
    this.height = 36,
    this.placeholder,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.menuAlignment = Alignment.bottomRight,
    this.customTrigger,
  });

  factory LooperDropdown.fromDropdownMenuItems({
    Key? key,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    double? width,
    double height = 36,
    String? placeholder,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 12),
    Alignment menuAlignment = Alignment.bottomRight,
  }) {
    return LooperDropdown<T>(
      key: key,
      value: value,
      items: items.map((i) => LooperDropdownItem<T>.fromDropdownMenuItem(i)).toList(),
      onChanged: onChanged,
      width: width,
      height: height,
      placeholder: placeholder,
      padding: padding,
      menuAlignment: menuAlignment,
    );
  }

  @override
  ConsumerState<LooperDropdown<T>> createState() => _LooperDropdownState<T>();
}

class _LooperDropdownState<T> extends ConsumerState<LooperDropdown<T>>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_overlayController.isShowing) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    HapticFeedback.selectionClick();
    _overlayController.show();
    _animationController.forward(from: 0.0);
    setState(() {});
  }

  Future<void> _close() async {
    await _animationController.reverse();
    if (mounted && _overlayController.isShowing) {
      _overlayController.hide();
      setState(() {});
    }
  }

  void _select(T value) {
    if (_overlayController.isShowing) {
      _overlayController.hide();
      _animationController.reset();
      setState(() {});
    }
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final accentColor = Color(settings.accentColor);
    final useBlur = (settings.enableDynamicTheming || settings.keepBackgroundGradient) &&
        !settings.disableBlur &&
        !settings.isBatterySaverActive;

    final selectedItem = widget.items.cast<LooperDropdownItem<T>?>().firstWhere(
          (i) => i?.value == widget.value,
          orElse: () => null,
        );

    final isShowing = _overlayController.isShowing;

    final buttonDecoration = BoxDecoration(
      color: useBlur
          ? (_isHovered
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.07))
          : (_isHovered
              ? const Color(0xFF2C2C30)
              : const Color(0xFF222226)),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: isShowing
            ? accentColor.withValues(alpha: 0.8)
            : (_isHovered
                ? Colors.white.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.12)),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );

    Widget buttonContent = CompositedTransformTarget(
      link: _layerLink,
      child: widget.customTrigger != null
          ? GestureDetector(
              onTap: widget.onChanged != null ? _toggle : null,
              behavior: HitTestBehavior.opaque,
              child: widget.customTrigger!(context, isShowing),
            )
          : MouseRegion(
              cursor: widget.onChanged != null
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: GestureDetector(
                onTap: widget.onChanged != null ? _toggle : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: widget.height,
                  width: widget.width,
                  padding: widget.padding,
                  decoration: buttonDecoration,
                  child: Row(
                    mainAxisSize: widget.width == null ? MainAxisSize.min : MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: selectedItem != null
                            ? DefaultTextStyle(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                child: selectedItem.label,
                              )
                            : Text(
                                widget.placeholder ?? '',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isShowing ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          LucideIcons.chevronDown,
                          color: isShowing ? accentColor : Colors.white70,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );

    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) {
        return Stack(
          children: [
            // Barrier to dismiss on tap outside
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _close,
                child: const SizedBox.expand(),
              ),
            ),
            // Floating Dropdown Menu
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: widget.menuAlignment == Alignment.bottomRight
                  ? Alignment.bottomRight
                  : Alignment.bottomLeft,
              followerAnchor: widget.menuAlignment == Alignment.bottomRight
                  ? Alignment.topRight
                  : Alignment.topLeft,
              offset: const Offset(0, 6),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  alignment: widget.menuAlignment == Alignment.bottomRight
                      ? Alignment.topRight
                      : Alignment.topLeft,
                  child: _DropdownMenuOverlay<T>(
                    items: widget.items,
                    selectedValue: widget.value,
                    accentColor: accentColor,
                    useBlur: useBlur,
                    minWidth: widget.width ?? 160,
                    onSelect: _select,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: buttonContent,
    );
  }
}

class _DropdownMenuOverlay<T> extends StatelessWidget {
  final List<LooperDropdownItem<T>> items;
  final T? selectedValue;
  final Color accentColor;
  final bool useBlur;
  final double minWidth;
  final ValueChanged<T> onSelect;

  const _DropdownMenuOverlay({
    required this.items,
    required this.selectedValue,
    required this.accentColor,
    required this.useBlur,
    required this.minWidth,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);

    final menuBoxDecoration = BoxDecoration(
      color: useBlur
          ? const Color(0xCC18181C)
          : const Color(0xFF222228),
      borderRadius: borderRadius,
      border: Border.all(
        color: Colors.white.withValues(alpha: useBlur ? 0.15 : 0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );

    Widget list = Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth,
          maxWidth: 320,
          maxHeight: 280,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final item in items)
                _DropdownMenuItemTile<T>(
                  item: item,
                  isSelected: item.value == selectedValue,
                  accentColor: accentColor,
                  onTap: () => onSelect(item.value),
                ),
            ],
          ),
        ),
      ),
    );

    return useBlur
        ? ClipRRect(
            borderRadius: borderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: DecoratedBox(
                decoration: menuBoxDecoration,
                child: list,
              ),
            ),
          )
        : DecoratedBox(
            decoration: menuBoxDecoration,
            child: list,
          );
  }
}

class _DropdownMenuItemTile<T> extends StatefulWidget {
  final LooperDropdownItem<T> item;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _DropdownMenuItemTile({
    required this.item,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_DropdownMenuItemTile<T>> createState() => _DropdownMenuItemTileState<T>();
}

class _DropdownMenuItemTileState<T> extends State<_DropdownMenuItemTile<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final item = widget.item;

    final itemBg = isSelected
        ? widget.accentColor.withValues(alpha: 0.18)
        : (_isHovered
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.transparent);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: itemBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.icon != null) ...[
                      Icon(
                        item.icon,
                        size: 16,
                        color: isSelected ? widget.accentColor : Colors.white70,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: isSelected ? widget.accentColor : Colors.white,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        child: item.label,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(
                  LucideIcons.check,
                  size: 15,
                  color: widget.accentColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
