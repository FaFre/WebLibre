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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/gestures/data/models/gesture_stroke.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/gestures/presentation/widgets/gesture_binding_editor.dart';
import 'package:weblibre/features/gestures/presentation/widgets/gesture_stroke_view.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

/// Lists the configured gesture → action bindings, grouped by action category,
/// and lets the user add, edit and remove them.
class GestureBindingsScreen extends HookConsumerWidget {
  const GestureBindingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gestureSettingsWithDefaultsProvider);

    Future<void> upsertBinding(
      ({GestureStroke stroke, BrowserAction action}) result, {
      String? replacedKey,
    }) async {
      await ref
          .read(gestureSettingsRepositoryProvider.notifier)
          .updateSettings(
            (current) => current.withBinding(
              result.stroke.key,
              result.action,
              replacedKey: replacedKey,
            ),
          );
    }

    Future<void> removeBinding(String key) async {
      await ref
          .read(gestureSettingsRepositoryProvider.notifier)
          .updateSettings((current) => current.withBindingRemoved(key));
    }

    Future<void> restoreDefaults() async {
      final confirmed = await showDialog<bool>(
        context: context,
        anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
        builder: (context) => AlertDialog(
          title: const Text('Restore default gestures?'),
          content: const Text(
            'Every gesture goes back to its default action. Your changes are '
            'lost.',
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
      if (confirmed == true) {
        await ref
            .read(gestureSettingsRepositoryProvider.notifier)
            .updateSettings((current) => current.withBindingsReset());
      }
    }

    // Group bindings by their action's category, preserving category order.
    final byCategory =
        <BrowserActionCategory, List<MapEntry<String, BrowserAction>>>{};
    for (final entry in settings.bindings.entries) {
      byCategory.putIfAbsent(entry.value.category, () => []).add(entry);
    }
    for (final entries in byCategory.values) {
      entries.sort((a, b) => a.value.title.compareTo(b.value.title));
    }

    return SettingsCustomScrollScaffold(
      title: 'Gesture bindings',
      actions: [
        if (settings.hasCustomBindings)
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Restore default gestures',
            onPressed: restoreDefaults,
          ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add gesture'),
        onPressed: () async {
          final result = await showGestureBindingEditor(
            context,
            existingBindings: settings.bindings,
            maxFingers: settings.maxFingers,
          );
          if (result != null) {
            await upsertBinding(result);
          }
        },
      ),
      slivers: [
        if (settings.bindings.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('No gestures assigned yet.')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            sliver: SliverList.list(
              children: [
                for (final category in BrowserActionCategory.values)
                  if (byCategory[category] case final entries?
                      when entries.isNotEmpty)
                    _GestureBindingGroup(
                      title: category.label,
                      children: [
                        for (final binding in entries)
                          _GestureBindingTile(
                            gestureKey: binding.key,
                            action: binding.value,
                            onEdit: () async {
                              final result = await showGestureBindingEditor(
                                context,
                                initialStroke: GestureStroke.fromKey(
                                  binding.key,
                                ),
                                initialAction: binding.value,
                                existingBindings: settings.bindings,
                                maxFingers: settings.maxFingers,
                              );
                              if (result != null) {
                                await upsertBinding(
                                  result,
                                  replacedKey: binding.key,
                                );
                              }
                            },
                            onRemove: () => removeBinding(binding.key),
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

/// A category heading followed by a filled card grouping its binding tiles,
/// matching the visual language of the other settings screens.
class _GestureBindingGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _GestureBindingGroup({required this.title, required this.children});

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

class _GestureBindingTile extends StatelessWidget {
  final String gestureKey;
  final BrowserAction action;
  final Future<void> Function() onEdit;
  final Future<void> Function() onRemove;

  const _GestureBindingTile({
    required this.gestureKey,
    required this.action,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final stroke = GestureStroke.fromKey(gestureKey);

    return ListTile(
      leading: Icon(action.icon),
      title: Text(action.title),
      subtitle: GestureStrokeView(stroke: stroke),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Remove',
        onPressed: () => onRemove(),
      ),
      onTap: () => onEdit(),
    );
  }
}
