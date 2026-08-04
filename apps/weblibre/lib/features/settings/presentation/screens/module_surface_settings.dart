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
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

/// Reorders and toggles the sections of one [ModuleSurface].
///
/// One screen serves every surface — the surface only decides which saved list
/// is edited — mirroring how `ContextualToolbarSettingsScreen` serves both
/// toolbars.
class ModuleSurfaceSettingsScreen extends HookConsumerWidget {
  final ModuleSurface surface;
  final String title;

  const ModuleSurfaceSettingsScreen({
    super.key,
    this.surface = ModuleSurface.home,
    this.title = 'Customize Home',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(searchModuleOrderProvider(surface));
    final notifier = ref.read(searchModuleOrderProvider(surface).notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsCustomScrollScaffold(
      title: title,
      actions: [
        MenuAnchor(
          menuChildren: [
            MenuItemButton(
              onPressed: notifier.resetToDefaults,
              child: const Text('Reset to Defaults'),
            ),
          ],
          builder: (context, controller, child) => IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () =>
                controller.isOpen ? controller.close() : controller.open(),
          ),
        ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'Drag to reorder. Switch a section off to hide it here without '
              'affecting the other page.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        SliverReorderableList(
          itemCount: entries.length,
          onReorderItem: notifier.reorder,
          itemBuilder: (context, index) {
            final entry = entries[index];

            return Material(
              key: ValueKey(entry.type),
              color: Colors.transparent,
              child: ListTile(
                title: Text(
                  entry.type.label,
                  style: TextStyle(
                    color: entry.visible ? null : colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch.adaptive(
                      value: entry.visible,
                      onChanged: (_) => notifier.toggleVisibility(entry.type),
                    ),
                    const SizedBox(width: 8),
                    ReorderableDragStartListener(
                      index: index,
                      child: Icon(
                        Icons.drag_handle,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
