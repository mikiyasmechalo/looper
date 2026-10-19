import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/core/providers.dart';
import 'package:looper_player/features/search/presentation/search_view.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/shortcuts/presentation/shortcuts_provider.dart';

class KeyboardHandler extends ConsumerStatefulWidget {
  final Widget child;
  const KeyboardHandler({super.key, required this.child});

  @override
  ConsumerState<KeyboardHandler> createState() => _KeyboardHandlerState();
}

class _KeyboardHandlerState extends ConsumerState<KeyboardHandler> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _isEditing() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null) return false;

    // Direct check against our search focus node
    if (focus == ref.read(searchFocusNodeProvider)) return true;

    // Walk up the focus context to find any text-editing widget.
    // This covers TextFields inside dialogs, bottom sheets, and overlays
    // where the debug label alone isn't reliable.
    final context = focus.context;
    if (context != null) {
      // The focused widget itself is an EditableText (most common case)
      if (context.widget is EditableText) return true;

      // Check ancestors — covers cases where the focus node belongs to a
      // wrapper but the actual editable is a parent/child in the same subtree
      bool found = false;
      context.visitAncestorElements((element) {
        if (element.widget is EditableText || element.widget is TextField) {
          found = true;
          return false; // stop walking
        }
        return true;
      });
      if (found) return true;
    }

    // Fallback: debug label heuristic
    final label = focus.debugLabel?.toLowerCase() ?? '';
    return label.contains('editabletext') ||
        label.contains('textfield') ||
        label.contains('searchfocusnode') ||
        focus.context?.widget is EditableText;
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;

    final key = event.logicalKey;
    final nav = ref.read(appNavigationProvider.notifier);

    // Escape key: clear search, exit search view, close popups, collapse player or go back
    if (key == LogicalKeyboardKey.escape) {
      final query = ref.read(searchQueryProvider);
      if (query.isNotEmpty) {
        ref.read(searchQueryProvider.notifier).state = '';
      }
      if (FocusManager.instance.primaryFocus != null) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
      final navState = ref.read(appNavigationProvider);
      if (navState.activeItem == NavItem.search) {
        nav.goBack();
        return true;
      }
      if (navState.isPlayerExpanded) {
        nav.setPlayerExpansion(false);
        return true;
      }
      if (rootNavigatorKey.currentState?.canPop() == true) {
        rootNavigatorKey.currentState?.pop();
        return true;
      }
      if (navState.history.isNotEmpty || navState.activeItem != NavItem.home) {
        nav.goBack();
        return true;
      }
      return true;
    }

    // Never intercept system/hardware volume or mute keys (let OS handle master volume)
    if (key == LogicalKeyboardKey.audioVolumeUp ||
        key == LogicalKeyboardKey.audioVolumeDown ||
        key == LogicalKeyboardKey.audioVolumeMute) {
      return false;
    }

    // If we're typing, ignore all playback shortcuts so they can reach the text field
    if (_isEditing()) {
      return false; // Let it bubble to TextField
    }

    // Dynamic Customizable Shortcuts
    final handled = ref.read(shortcutsProvider.notifier).handleKeyEvent(event, ref);
    if (handled) return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      child: widget.child,
    );
  }
}
