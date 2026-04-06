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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/data/models/drag_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// A widget that wraps a tab and enables creating a new container
/// when another tab is dropped onto it.
///
/// When a tab is dragged and dropped onto this widget:
/// 1. Both tab titles are collected
/// 2. An AI-suggested container name is generated
/// 3. User is redirected to container creation screen to confirm/modify settings
/// 4. Both tabs are assigned to the new container if user confirms
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

        final containerRepo = ref.read(containerRepositoryProvider.notifier);
        final newContainer = await containerRepo.createNewContainer();

        if (!context.mounted) return;

        final result = await ContainerCreateRoute(
          containerData: jsonEncode(newContainer.toJson()),
          tabIds: jsonEncode([draggedTabId, targetTabId]),
        ).push<ContainerData?>(context);

        if (result != null) {
          final tabRepo = ref.read(tabDataRepositoryProvider.notifier);
          await tabRepo.assignContainer(draggedTabId, result);
          await tabRepo.assignContainer(targetTabId, result);

          if (context.mounted) {
            showInfoMessage(
              context,
              'Created container "${result.name ?? 'New Container'}"',
            );
          }
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
}
