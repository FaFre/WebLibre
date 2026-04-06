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
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/data/models/drag_data.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_menu.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';

/// Chrome-like tab context menu + drag coordination.
///
/// On long press: shows a context menu via [TabMenu].
/// If user moves finger: closes menu, starts drag.
/// If user releases without moving: menu persists.
///
/// For non-reorderable mode: wraps with [LongPressDraggable].
/// For reorderable mode: uses manual long-press timer (drag handled externally).
class TabContextMenuDraggable extends HookConsumerWidget {
  final String tabId;
  final TabDragData? data;
  final Widget child;

  /// Size for the drag feedback widget.
  final Size feedbackSize;

  /// Whether drag is handled externally (reorderable mode).
  /// When true, no [LongPressDraggable] is used; only menu + manual timer.
  final bool externalDrag;

  const TabContextMenuDraggable({
    required this.tabId,
    required this.child,
    required this.feedbackSize,
    this.data,
    this.externalDrag = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuController = useMenuController();
    final isDragMoving = useMemoized(() => ValueNotifier(false));
    final startPosition = useRef(Offset.zero);
    final isDragging = useRef(false);
    final longPressTimer = useRef<Timer?>(null);

    // Clean up ValueNotifier
    useEffect(() => isDragMoving.dispose, [isDragMoving]);

    if (externalDrag) {
      return _buildReorderableMode(
        context,
        menuController: menuController,
        startPosition: startPosition,
        longPressTimer: longPressTimer,
      );
    }

    return _buildDraggableMode(
      context,
      menuController: menuController,
      isDragMoving: isDragMoving,
      startPosition: startPosition,
      isDragging: isDragging,
    );
  }

  Widget _buildTabMenu({
    required MenuController menuController,
    required Widget Function(BuildContext, MenuController, Widget?) builder,
  }) {
    return TabMenu(
      selectedTabId: tabId,
      controller: menuController,
      enableFindInPage: false,
      enableFetchFeeds: false,
      enableDesktopMode: false,
      enableReaderMode: false,
      enableReloadButton: false,
      enableNavigationButtons: false,
      enableAddToHomeScreen: false,
      enableCloseTab: false,
      builder: builder,
    );
  }

  /// Non-reorderable mode: Listener + TabMenu + LongPressDraggable
  Widget _buildDraggableMode(
    BuildContext context, {
    required MenuController menuController,
    required ValueNotifier<bool> isDragMoving,
    required ObjectRef<Offset> startPosition,
    required ObjectRef<bool> isDragging,
  }) {
    return Listener(
      onPointerDown: (event) {
        startPosition.value = event.position;
      },
      onPointerMove: (event) {
        if (isDragging.value &&
            !isDragMoving.value &&
            (event.position - startPosition.value).distance > kTouchSlop) {
          isDragMoving.value = true;
          if (menuController.isOpen) {
            menuController.close();
          }
        }
      },
      onPointerUp: (_) {
        // Reset drag tracking on pointer up (for cases where drag wasn't started)
        isDragging.value = false;
      },
      child: _buildTabMenu(
        menuController: menuController,
        builder: (context, controller, _) {
          return LongPressDraggable<TabDragData>(
            data: data,
            onDragStarted: () {
              isDragging.value = true;
              isDragMoving.value = false;
              menuController.open();
            },
            onDragEnd: (_) {
              isDragging.value = false;
              isDragMoving.value = false;
            },
            onDraggableCanceled: (_, _) {
              isDragging.value = false;
              isDragMoving.value = false;
            },
            feedback: ValueListenableBuilder<bool>(
              valueListenable: isDragMoving,
              builder: (_, moving, feedbackChild) {
                if (!moving) return const SizedBox.shrink();
                return feedbackChild!;
              },
              child: Material(
                color: Colors.transparent,
                child: Transform.scale(
                  scale: 1.05,
                  child: SizedBox(
                    height: feedbackSize.height,
                    width: feedbackSize.width,
                    child: child,
                  ),
                ),
              ),
            ),
            childWhenDragging: ValueListenableBuilder<bool>(
              valueListenable: isDragMoving,
              builder: (_, moving, _) {
                if (!moving) return child;
                return SizedBox(
                  height: feedbackSize.height,
                  width: feedbackSize.width,
                );
              },
            ),
            child: child,
          );
        },
      ),
    );
  }

  /// Reorderable mode: Listener + TabMenu (drag handled externally)
  Widget _buildReorderableMode(
    BuildContext context, {
    required MenuController menuController,
    required ObjectRef<Offset> startPosition,
    required ObjectRef<Timer?> longPressTimer,
  }) {
    return Listener(
      onPointerDown: (event) {
        startPosition.value = event.position;
        longPressTimer.value?.cancel();
        longPressTimer.value = Timer(kLongPressTimeout, () {
          menuController.open();
        });
      },
      onPointerMove: (event) {
        if ((event.position - startPosition.value).distance > kTouchSlop) {
          // User started moving - cancel menu timer and close menu if open
          longPressTimer.value?.cancel();
          longPressTimer.value = null;
          if (menuController.isOpen) {
            menuController.close();
          }
        }
      },
      onPointerUp: (_) {
        longPressTimer.value?.cancel();
        longPressTimer.value = null;
      },
      onPointerCancel: (_) {
        longPressTimer.value?.cancel();
        longPressTimer.value = null;
      },
      child: _buildTabMenu(
        menuController: menuController,
        builder: (context, controller, _) => child,
      ),
    );
  }
}
