import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/shortcuts/domain/shortcut_models.dart';
import 'package:looper_player/features/shortcuts/presentation/shortcuts_provider.dart';

Future<AppKeyCombo?> showShortcutRecorderDialog({
  required BuildContext context,
  required WidgetRef ref,
  required AppShortcutAction action,
}) async {
  return showDialog<AppKeyCombo?>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ShortcutRecorderDialog(action: action),
  );
}

class _ShortcutRecorderDialog extends ConsumerStatefulWidget {
  final AppShortcutAction action;
  const _ShortcutRecorderDialog({required this.action});

  @override
  ConsumerState<_ShortcutRecorderDialog> createState() =>
      _ShortcutRecorderDialogState();
}

class _ShortcutRecorderDialogState
    extends ConsumerState<_ShortcutRecorderDialog> {
  AppKeyCombo? _recordedCombo;
  final bool _listening = true;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
    super.dispose();
  }

  bool _onKeyEvent(KeyEvent event) {
    if (!_listening) return false;
    if (event is! KeyDownEvent) return false;

    final key = event.logicalKey;

    // Ignore standalone modifier keypresses until a primary key is pressed
    if (key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight) {
      return false;
    }

    final isCtrl = HardwareKeyboard.instance.isControlPressed;
    final isAlt = HardwareKeyboard.instance.isAltPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;
    final isMeta = HardwareKeyboard.instance.isMetaPressed;

    setState(() {
      _recordedCombo = AppKeyCombo(
        key: key,
        isCtrl: isCtrl,
        isAlt: isAlt,
        isShift: isShift,
        isMeta: isMeta,
      );
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = ref.read(shortcutsProvider.notifier);
    final conflictAction = _recordedCombo != null
        ? notifier.checkConflict(widget.action, _recordedCombo!)
        : null;

    return Dialog(
      backgroundColor: const Color(0xFF18181B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.keyboard,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Record Shortcut',
                          style: AppFonts.jostStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.action.title,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recording Canvas / Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _recordedCombo != null
                        ? theme.colorScheme.primary.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.12),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    if (_recordedCombo == null) ...[
                      const Icon(
                        LucideIcons.radio,
                        size: 32,
                        color: Colors.white38,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Press the desired key combination...',
                        style: AppFonts.jostStyle(
                          fontSize: 14.5,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Modifiers like Ctrl, Alt, Shift are supported',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ] else ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (int i = 0; i < _recordedCombo!.badgeChips.length; i++) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                _recordedCombo!.badgeChips[i],
                                style: AppFonts.jostStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            if (i < _recordedCombo!.badgeChips.length - 1)
                              const Text(
                                '+',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Press another key combination to change',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Conflict Warning
              if (conflictAction != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.alertTriangle,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Currently used by "${conflictAction.title}". Saving will reassign it.',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Actions Row
              Row(
                children: [
                  // Clear / Disable shortcut button
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(const _ClearShortcutToken());
                    },
                    icon: const Icon(LucideIcons.ban, size: 16),
                    label: const Text('Clear Shortcut'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _recordedCombo != null
                        ? () {
                            if (conflictAction != null) {
                              // Clear the conflicting action
                              ref
                                  .read(shortcutsProvider.notifier)
                                  .setShortcut(conflictAction, null);
                            }
                            Navigator.of(context).pop(_recordedCombo);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClearShortcutToken extends AppKeyCombo {
  const _ClearShortcutToken()
      : super(key: LogicalKeyboardKey.abort);
}
