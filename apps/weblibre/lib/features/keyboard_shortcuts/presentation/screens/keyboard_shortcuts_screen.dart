/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/key_chord.dart';
import 'package:weblibre/features/keyboard_shortcuts/domain/repositories/keyboard_shortcut_settings.dart';
import 'package:weblibre/features/keyboard_shortcuts/presentation/dialogs/key_chord_recorder_dialog.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

/// Lists every browser action with the key combinations that run it, grouped
/// by category, and lets the user add, change, remove and reset them.
class KeyboardShortcutsScreen extends HookConsumerWidget {
  const KeyboardShortcutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(keyboardShortcutSettingsRepositoryProvider);
    final repository = ref.read(
      keyboardShortcutSettingsRepositoryProvider.notifier,
    );
    final search = useSettingsSearch();
    final colorScheme = Theme.of(context).colorScheme;

    Future<void> record(BrowserAction action, {KeyChord? replacing}) async {
      final chord = await showKeyChordRecorderDialog(
        context,
        action: action,
        settings: settings,
        replacing: replacing,
      );
      if (chord == null) return;

      if (replacing == null) {
        repository.addChord(action, chord);
      } else {
        repository.replaceChord(action, replacing, chord);
      }
    }

    Future<void> restoreDefaults() async {
      final confirmed = await showDialog<bool>(
        context: context,
        anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
        builder: (context) => AlertDialog(
          title: const Text('Restore default shortcuts?'),
          content: const Text(
            'Every action goes back to its Firefox default keys. Your changes '
            'are lost.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Restore'),
            ),
          ],
        ),
      );
      if (confirmed == true) repository.resetAll();
    }

    final query = search.normalizedQuery;
    bool matches(BrowserAction action) =>
        query.isEmpty ||
        action.title.toLowerCase().contains(query) ||
        action.description.toLowerCase().contains(query) ||
        action.category.label.toLowerCase().contains(query) ||
        settings
            .chordsFor(action)
            .any((chord) => chord.label.toLowerCase().contains(query));

    final byCategory = <BrowserActionCategory, List<BrowserAction>>{};
    for (final action in BrowserAction.values.where(matches)) {
      byCategory.putIfAbsent(action.category, () => []).add(action);
    }

    return SettingsCustomScrollScaffold(
      title: 'Keyboard Shortcuts',
      searchController: settings.enabled ? search.controller : null,
      searchHintText: 'Search actions or keys',
      actions: [
        if (settings.enabled && settings.hasCustomizations)
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Restore default shortcuts',
            onPressed: restoreDefaults,
          ),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Card.filled(
              margin: EdgeInsets.zero,
              color: colorScheme.primaryContainer,
              clipBehavior: Clip.antiAlias,
              child: SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                secondary: Icon(
                  MdiIcons.keyboardOutline,
                  color: colorScheme.onPrimaryContainer,
                ),
                title: Text(
                  'Enable Keyboard Shortcuts',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Browser actions on a hardware keyboard, even while a page '
                  'has focus',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
                value: settings.enabled,
                onChanged: repository.setEnabled,
              ),
            ),
          ),
        ),
        if (settings.enabled)
          if (byCategory.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No matching actions.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              sliver: SliverList.list(
                children: [
                  for (final category in BrowserActionCategory.values)
                    if (byCategory[category] case final actions?)
                      _ShortcutGroup(
                        title: category.label,
                        children: [
                          for (final action in actions)
                            _ShortcutTile(
                              action: action,
                              chords: settings.chordsFor(action),
                              customized: settings.isCustomized(action),
                              onAdd: () => record(action),
                              onChange: (chord) =>
                                  record(action, replacing: chord),
                              onRemove: (chord) =>
                                  repository.removeChord(action, chord),
                              onReset: () => repository.resetAction(action),
                            ),
                        ],
                      ),
                ],
              ),
            ),
      ],
    );
  }
}

/// A category heading followed by a filled card of its action tiles, like the
/// gesture bindings list.
class _ShortcutGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ShortcutGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Card.filled(
            margin: EdgeInsets.zero,
            color: theme.colorScheme.surfaceContainer,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final BrowserAction action;
  final List<KeyChord> chords;
  final bool customized;
  final VoidCallback onAdd;
  final ValueChanged<KeyChord> onChange;
  final ValueChanged<KeyChord> onRemove;
  final VoidCallback onReset;

  const _ShortcutTile({
    required this.action,
    required this.chords,
    required this.customized,
    required this.onAdd,
    required this.onChange,
    required this.onRemove,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(action.icon),
      title: Text(action.title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: chords.isEmpty
            ? Text(
                'No shortcut',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final chord in chords)
                    InputChip(
                      label: Text(chord.label),
                      tooltip: 'Change',
                      onPressed: () => onChange(chord),
                      onDeleted: () => onRemove(chord),
                      deleteButtonTooltipMessage: 'Remove ${chord.label}',
                    ),
                ],
              ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (customized)
            IconButton(
              icon: const Icon(Icons.restart_alt),
              tooltip: 'Reset to default',
              onPressed: onReset,
            ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add shortcut',
            onPressed: onAdd,
          ),
        ],
      ),
      onTap: onAdd,
    );
  }
}
