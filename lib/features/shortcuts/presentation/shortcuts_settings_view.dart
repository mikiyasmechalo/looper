import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/shortcuts/domain/shortcut_models.dart';
import 'package:looper_player/features/shortcuts/presentation/shortcuts_provider.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/features/shortcuts/presentation/widgets/shortcut_recorder_dialog.dart';
import 'package:looper_player/features/shortcuts/presentation/widgets/shortcuts_cheatsheet_dialog.dart';

class ShortcutsSettingsView extends ConsumerStatefulWidget {
  const ShortcutsSettingsView({super.key});

  @override
  ConsumerState<ShortcutsSettingsView> createState() =>
      _ShortcutsSettingsViewState();
}

class _ShortcutsSettingsViewState
    extends ConsumerState<ShortcutsSettingsView> {
  String _searchQuery = '';
  ShortcutCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    ref.watch(shortcutsProvider);
    final notifier = ref.read(shortcutsProvider.notifier);
    final theme = Theme.of(context);

    final filteredActions = AppShortcutAction.all.where((action) {
      if (_selectedCategory != null && action.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final combo = notifier.getBinding(action);
      return action.title.toLowerCase().contains(q) ||
          action.description.toLowerCase().contains(q) ||
          action.category.label.toLowerCase().contains(q) ||
          (combo != null && combo.displayString.toLowerCase().contains(q));
    }).toList();

    final categories = ShortcutCategory.values.where((cat) {
      return filteredActions.any((a) => a.category == cat);
    }).toList();

    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F0F12) : theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        color: backgroundColor,
        child: SafeArea(
          child: Column(
            children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keyboard Shortcuts',
                          style: AppFonts.jostStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Customize key combinations to your preference',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Cheatsheet Button
                  IconButton(
                    icon: const Icon(LucideIcons.helpCircle, color: Colors.white70),
                    tooltip: 'View Cheatsheet',
                    onPressed: () => showShortcutsCheatsheetDialog(context),
                  ),
                  const SizedBox(width: 4),
                  // Reset All Button
                  TextButton.icon(
                    onPressed: () => _confirmResetAll(context),
                    icon: const Icon(LucideIcons.rotateCcw, size: 16),
                    label: const Text('Reset All'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ref.watch(settingsProvider).enableGlobalHotkeys
                          ? theme.colorScheme.primary.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              LucideIcons.globe,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Global Hotkeys (System-Wide)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Control playback when Looper is minimized or in the background',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Switch(
                            value: ref.watch(settingsProvider).enableGlobalHotkeys,
                            activeColor: theme.colorScheme.primary,
                            onChanged: (v) {
                              HapticFeedback.lightImpact();
                              ref.read(settingsProvider.notifier).updateEnableGlobalHotkeys(v);
                            },
                          ),
                        ],
                      ),
                      if (ref.watch(settingsProvider).enableGlobalHotkeys) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = ShortcutCategory.global;
                                  _searchQuery = '';
                                });
                              },
                              icon: Icon(
                                LucideIcons.slidersHorizontal,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              label: Text(
                                'View & Edit 8 Global Shortcuts',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            // Search Bar & Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Search actions or shortcut keys...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 13.5,
                      ),
                      prefixIcon: const Icon(
                        LucideIcons.search,
                        color: Colors.white38,
                        size: 18,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(LucideIcons.x, size: 16, color: Colors.white38),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.04),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _CategoryChip(
                          label: 'All (${AppShortcutAction.all.length})',
                          isSelected: _selectedCategory == null,
                          onTap: () => setState(() => _selectedCategory = null),
                        ),
                        const SizedBox(width: 8),
                        for (final cat in ShortcutCategory.values) ...[
                          _CategoryChip(
                            label: cat.label,
                            isSelected: _selectedCategory == cat,
                            onTap: () => setState(() => _selectedCategory = cat),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Shortcuts List
            Expanded(
              child: filteredActions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.searchX,
                            size: 40,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No shortcuts found',
                            style: AppFonts.jostStyle(
                              fontSize: 16,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      itemCount: categories.length,
                      itemBuilder: (context, catIdx) {
                        final category = categories[catIdx];
                        final actions = filteredActions
                            .where((a) => a.category == category)
                            .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 10,
                                left: 6,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getCategoryIcon(category),
                                    size: 15,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category.label.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${actions.length}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.025),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Column(
                                children: [
                                  for (int i = 0; i < actions.length; i++) ...[
                                    _ShortcutTile(
                                      action: actions[i],
                                      combo: notifier.getBinding(actions[i]),
                                      isCustomized: notifier.isCustomized(actions[i]),
                                      isLast: i == actions.length - 1,
                                      onEdit: () => _editShortcut(actions[i]),
                                      onReset: () async {
                                        HapticFeedback.lightImpact();
                                        await notifier.resetShortcut(actions[i]);
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  IconData _getCategoryIcon(ShortcutCategory category) {
    switch (category) {
      case ShortcutCategory.global:
        return LucideIcons.globe;
      case ShortcutCategory.playback:
        return LucideIcons.play;
      case ShortcutCategory.seekingAndVolume:
        return LucideIcons.volume2;
      case ShortcutCategory.navigation:
        return LucideIcons.compass;
      case ShortcutCategory.displayAndUi:
        return LucideIcons.layout;
    }
  }

  Future<void> _editShortcut(AppShortcutAction action) async {
    final result = await showShortcutRecorderDialog(
      context: context,
      ref: ref,
      action: action,
    );

    if (result != null) {
      HapticFeedback.mediumImpact();
      if (result.key == LogicalKeyboardKey.abort) {
        // Clear / unbound shortcut
        await ref.read(shortcutsProvider.notifier).setShortcut(action, null);
      } else {
        await ref.read(shortcutsProvider.notifier).setShortcut(action, result);
      }
    }
  }

  Future<void> _confirmResetAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF18181B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        title: Text(
          'Reset all shortcuts?',
          style: AppFonts.jostStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: const Text(
          'This will restore all keyboard shortcut bindings to their original system defaults.',
          style: TextStyle(color: Colors.white70, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Reset All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      await ref.read(shortcutsProvider.notifier).resetAllShortcuts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All shortcuts reset to defaults'),
            backgroundColor: const Color(0xFF27272A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? theme.colorScheme.primary : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final AppShortcutAction action;
  final AppKeyCombo? combo;
  final bool isCustomized;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onReset;

  const _ShortcutTile({
    required this.action,
    required this.combo,
    required this.isCustomized,
    required this.isLast,
    required this.onEdit,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
        ),
        child: Row(
          children: [
            // Title & Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        action.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isCustomized) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Custom',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    action.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Key Chips
            if (combo != null)
              Wrap(
                spacing: 5,
                children: combo!.badgeChips.map((chip) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4.5,
                    ),
                    decoration: BoxDecoration(
                      color: isCustomized
                          ? theme.colorScheme.primary.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCustomized
                            ? theme.colorScheme.primary.withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      chip,
                      style: TextStyle(
                        color: isCustomized
                            ? theme.colorScheme.primary
                            : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.2),
                  ),
                ),
                child: const Text(
                  'Disabled',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            const SizedBox(width: 8),

            // Edit button
            IconButton(
              icon: const Icon(LucideIcons.edit2, size: 16, color: Colors.white60),
              tooltip: 'Edit shortcut',
              onPressed: onEdit,
            ),

            // Reset button (if customized)
            if (isCustomized)
              IconButton(
                icon: const Icon(LucideIcons.rotateCcw, size: 15, color: Colors.white38),
                tooltip: 'Reset to default',
                onPressed: onReset,
              ),
          ],
        ),
      ),
    );
  }
}
