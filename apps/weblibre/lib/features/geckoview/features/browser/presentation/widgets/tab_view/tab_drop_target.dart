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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/data/models/drag_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/utils/ui_helper.dart';

enum _TabDropAction { createContainer, assignParent }

/// A widget that wraps a tab and offers tab relationship actions when another
/// tab is dropped onto it.
///
/// When a tab is dragged and dropped onto this widget:
/// 1. The user chooses whether to create a container or assign a parent.
/// 2. Container creation redirects to the container creation screen.
/// 3. Parent assignment makes the target tab the parent of the dragged tab.
class TabDropTarget extends HookConsumerWidget {
  /// The tab entity that serves as the drop target
  final String targetTabId;

  /// The widget to display (typically the tab preview)
  final Widget child;

  /// Whether drag-and-drop to create containers is enabled
  final bool enabled;

  const TabDropTarget({
    required this.targetTabId,
    required this.child,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled) {
      return child;
    }

    return DragTarget<TabDragData>(
      onWillAcceptWithDetails: (details) {
        // Only accept if dragging a different tab
        return details.data.tabId != targetTabId;
      },
      onAcceptWithDetails: (details) async {
        final draggedTabId = details.data.tabId;

        final action = await showModalBottomSheet<_TabDropAction>(
          context: context,
          showDragHandle: true,
          builder: (context) => const _TabDropActionSheet(),
        );

        if (action == null || !context.mounted) return;

        switch (action) {
          case _TabDropAction.createContainer:
            await _createContainerForTabs(
              context: context,
              ref: ref,
              draggedTabId: draggedTabId,
              targetTabId: targetTabId,
            );
          case _TabDropAction.assignParent:
            await _assignParentTab(
              context: context,
              ref: ref,
              draggedTabId: draggedTabId,
              targetTabId: targetTabId,
            );
        }
      },
      builder: (context, candidateData, rejectedData) {
        if (candidateData.isEmpty) return child;

        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        );
      },
    );
  }

  Future<void> _createContainerForTabs({
    required BuildContext context,
    required WidgetRef ref,
    required String draggedTabId,
    required String targetTabId,
  }) async {
    final containerRepo = ref.read(containerRepositoryProvider.notifier);
    final tabRepo = ref.read(tabDataRepositoryProvider.notifier);
    final newContainer = await containerRepo.createNewContainer();

    if (!context.mounted) return;

    final result = await ContainerCreateRoute(
      containerData: jsonEncode(newContainer.toJson()),
      tabIds: jsonEncode([draggedTabId, targetTabId]),
    ).push<ContainerData?>(context);

    if (result != null) {
      await tabRepo.assignContainer(draggedTabId, result);
      await tabRepo.assignContainer(targetTabId, result);

      if (context.mounted) {
        showInfoMessage(
          context,
          'Created container "${result.name ?? 'New Container'}"',
        );
      }
    }
  }

  Future<void> _assignParentTab({
    required BuildContext context,
    required WidgetRef ref,
    required String draggedTabId,
    required String targetTabId,
  }) async {
    final didAssign = await ref
        .read(tabDataRepositoryProvider.notifier)
        .setTabParent(tabId: draggedTabId, newParentId: targetTabId);

    if (!context.mounted) return;

    if (didAssign) {
      showInfoMessage(context, 'Assigned parent tab');
    } else {
      showErrorMessage(context, 'Could not assign parent tab');
    }
  }
}

class _TabDropActionSheet extends StatelessWidget {
  const _TabDropActionSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Drop tab onto tab'),
            subtitle: Text('Choose how these tabs should be related.'),
          ),
          ListTile(
            leading: const Icon(MdiIcons.folderPlus),
            title: const Text('Create container'),
            subtitle: const Text('Create a new container with both tabs.'),
            onTap: () =>
                Navigator.of(context).pop(_TabDropAction.createContainer),
          ),
          ListTile(
            leading: const Icon(MdiIcons.fileTree),
            title: const Text('Assign new parent'),
            subtitle: const Text('Make the dropped-on tab the parent.'),
            onTap: () => Navigator.of(context).pop(_TabDropAction.assignParent),
          ),
        ],
      ),
    );
  }
}
