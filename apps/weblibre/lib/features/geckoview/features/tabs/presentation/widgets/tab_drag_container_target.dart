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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/global_drop.dart';
import 'package:weblibre/data/models/drag_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';

class TabDragContainerTarget extends HookConsumerWidget {
  final ContainerData? container;
  final Widget child;

  const TabDragContainerTarget({
    super.key,
    required this.container,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayController = useOverlayPortalController();

    return DragTarget<TabDragData>(
      onMove: (details) {
        ref
            .read(willAcceptDropProvider.notifier)
            .setData(ContainerDropData(details.data.tabId));

        overlayController.show();
      },
      onLeave: (data) {
        ref.read(willAcceptDropProvider.notifier).clear();

        overlayController.hide();
      },
      onAcceptWithDetails: (details) async {
        ref.read(willAcceptDropProvider.notifier).clear();
        overlayController.hide();

        if (container != null) {
          await ref
              .read(tabDataRepositoryProvider.notifier)
              .assignContainer(details.data.tabId, container!);
        } else {
          await ref
              .read(tabDataRepositoryProvider.notifier)
              .unassignContainer(details.data.tabId);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final renderBox = context.findRenderObject() as RenderBox?;
        final position = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

        return OverlayPortal(
          controller: overlayController,
          overlayChildBuilder: (context) => Positioned(
            top: position.dy,
            left: position.dx,
            child: IgnorePointer(
              child: Transform.scale(scale: 1.1, child: child),
            ),
          ),
          child: Consumer(
            child: child,
            builder: (context, ref, child) {
              final dragTabId = ref.watch(willAcceptDropProvider);

              return Opacity(
                opacity: (dragTabId == null) ? 1.0 : 0.0,
                child: child,
              );
            },
          ),
        );
      },
    );
  }
}
