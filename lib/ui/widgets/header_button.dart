import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/app_icons.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HeaderButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final bool isDynamic;

  const HeaderButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.label,
    this.isDynamic = false,
  });

  @override
  State<HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<HeaderButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final baseBg = const Color.fromARGB(
      255,
      53,
      53,
      53,
    ).withValues(alpha: widget.isDynamic ? 0.3 : 0.1);

    final hoverBg = Colors.white.withValues(alpha: widget.isDynamic ? 0.22 : 0.14);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          height: 55.s,
          padding: EdgeInsets.symmetric(horizontal: 20.s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: _isHovered ? hoverBg : baseBg,
            border: Border.all(
              color: _isHovered
                  ? Colors.white.withValues(alpha: 0.28)
                  : Colors.white10.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            clipBehavior: Clip.hardEdge,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon == LucideIcons.arrowLeft)
                  SvgPicture.asset(
                    AppIcons.back,
                    width: AppIcons.headerIcon.s,
                    height: AppIcons.headerIcon.s,
                    colorFilter: ColorFilter.mode(
                      _isHovered ? Colors.white : Colors.white.withValues(alpha: 0.88),
                      BlendMode.srcIn,
                    ),
                  )
                else
                  Icon(
                    widget.icon,
                    size: AppIcons.headerIcon.s,
                    color: _isHovered ? Colors.white : Colors.white.withValues(alpha: 0.88),
                  ),
                SizedBox(width: 10.s),
                Flexible(
                  child: Text(
                    widget.label,
                    style: AppFonts.jostStyle(
                      color: _isHovered ? Colors.white : Colors.white.withValues(alpha: 0.88),
                      fontSize: 14.ts,
                      fontWeight: _isHovered ? FontWeight.w500 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
