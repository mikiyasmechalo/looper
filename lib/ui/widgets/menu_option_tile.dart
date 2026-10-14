import 'package:flutter/material.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MenuOptionTile extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  const MenuOptionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    this.textColor,
    required this.onTap,
  });

  @override
  State<MenuOptionTile> createState() => _MenuOptionTileState();
}

class _MenuOptionTileState extends State<MenuOptionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = widget.textColor ?? Colors.white;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: _isHovered
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            hoverColor: Colors.transparent,
            splashColor: Colors.white.withValues(alpha: 0.16),
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    size: 22,
                    color: _isHovered
                        ? widget.iconColor
                        : widget.iconColor.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: AppFonts.jostStyle(
                        color: _isHovered
                            ? effectiveTextColor
                            : effectiveTextColor.withValues(alpha: 0.88),
                        fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOutCubic,
                    offset: _isHovered ? const Offset(0.15, 0) : Offset.zero,
                    child: Icon(
                      LucideIcons.chevronRight,
                      color: _isHovered
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
