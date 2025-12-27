/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_icon.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/domain/entities/find_in_page_state.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class GridTabItemContainer extends StatelessWidget {
  final bool isActive;
  final bool isPrivate;
  final Widget? child;

  const GridTabItemContainer({
    required this.isActive,
    required this.isPrivate,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive ? colorScheme.primary : colorScheme.outline,
          width: isActive ? 2.0 : 1.0,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Material(
        color: isPrivate
            ? const Color(0xFF25003E)
            : colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(14.0)),
        child: child,
      ),
    );
  }
}

class GridTabPreview extends HookConsumerWidget {
  final String tabId;
  final bool isActive;

  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final void Function(String host)? onDeleteAll;

  final Widget? trailingChild;

  const GridTabPreview({
    required this.tabId,
    required this.isActive,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onDelete,
    this.onDeleteAll,
    this.trailingChild,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabStateProvider(tabId));
    if (tabState == null) {
      return const SizedBox.shrink();
    }

    final extendedDeleteMenuController = useMenuController();

    return GridTabItemContainer(
      isActive: isActive,
      isPrivate: tabState.isPrivate,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(14.0)),
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6.0, top: 2.0),
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      tabState.titleOrAuthority,
                      maxLines: 2,
                      style: tabState.isPrivate
                          ? const TextStyle(color: Colors.white)
                          : null,
                    ),
                  ),
                ),
                if (onDelete != null || onDeleteAll != null)
                  MenuAnchor(
                    controller: extendedDeleteMenuController,
                    builder: (context, controller, child) {
                      return child!;
                    },
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () {
                          onDeleteAll?.call(tabState.url.host);
                        },

                        leadingIcon: const Icon(MdiIcons.closeBoxMultiple),
                        child: Text('Close all from ${tabState.url.host}'),
                      ),
                    ],
                    child: IconButton(
                      visualDensity: const VisualDensity(
                        horizontal: -4.0,
                        vertical: -4.0,
                      ),
                      onPressed: onDelete,
                      onLongPress: onDeleteAll != null
                          ? () {
                              if (extendedDeleteMenuController.isOpen) {
                                extendedDeleteMenuController.close();
                              } else {
                                extendedDeleteMenuController.open();
                              }
                            }
                          : null,
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ?trailingChild,
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 6.0),
                TabIcon(tabState: tabState),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                    tabState.url.authority,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tabState.isPrivate ? Colors.white : null,
                    ),
                  ),
                ),
                if (tabState.isPrivate) ...[
                  const SizedBox(width: 6.0),
                  const SizedBox(
                    height: 16,
                    width: 24,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          top: -4,
                          child: Icon(
                            MdiIcons.dominoMask,
                            color: Color(0xFF8000D7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(width: 8.0),
              ],
            ),
            const SizedBox(height: 6),
            if (tabState.thumbnail != null)
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14.0),
                    bottomRight: Radius.circular(14.0),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: RepaintBoundary(
                      child: RawImage(
                        image: tabState.thumbnail!.value,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ListTabPreview extends HookConsumerWidget {
  final String tabId;
  final bool isActive;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final void Function(String host)? onDeleteAll;

  final Widget? trailingChild;

  const ListTabPreview({
    required this.tabId,
    required this.isActive,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onDeleteAll,
    this.trailingChild,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final tabState = ref.watch(tabStateProvider(tabId));
    if (tabState == null) {
      return const SizedBox.shrink();
    }

    final extendedDeleteMenuController = useMenuController();

    return Container(
      decoration: BoxDecoration(
        color: tabState.isPrivate ? const Color(0xFF25003E) : null,
        border: isActive ? Border.all(color: colorScheme.primary) : null,
        // borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListTile(
              key: ValueKey(tabState.id),
              onTap: onTap,
              onLongPress: onLongPress,
              contentPadding: const EdgeInsets.only(left: 4),
              leading: (tabState.thumbnail != null)
                  ? RepaintBoundary(
                      child: RawImage(
                        image: tabState.thumbnail!.value,
                        fit: BoxFit.fitHeight,
                      ),
                    )
                  : TabIcon(tabState: tabState, iconSize: 32),
              title: Text(
                overflow: TextOverflow.ellipsis,
                tabState.titleOrAuthority,
                maxLines: 2,
                style: tabState.isPrivate
                    ? const TextStyle(color: Colors.white)
                    : null,
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: UriBreadcrumb(
                      uri: tabState.url,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tabState.isPrivate ? Colors.white : null,
                      ),
                    ),
                  ),
                  if (tabState.isPrivate) ...[
                    const SizedBox(width: 6.0),
                    const SizedBox(
                      height: 16,
                      width: 24,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            top: -4,
                            child: Icon(
                              MdiIcons.dominoMask,
                              color: Color(0xFF8000D7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onDelete != null || onDeleteAll != null)
                MenuAnchor(
                  controller: extendedDeleteMenuController,
                  builder: (context, controller, child) {
                    return child!;
                  },
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () {
                        onDeleteAll?.call(tabState.url.host);
                      },

                      leadingIcon: const Icon(MdiIcons.closeBoxMultiple),
                      child: Text('Close all from ${tabState.url.host}'),
                    ),
                  ],
                  child: IconButton(
                    onPressed: onDelete,
                    onLongPress: onDeleteAll != null
                        ? () {
                            if (extendedDeleteMenuController.isOpen) {
                              extendedDeleteMenuController.close();
                            } else {
                              extendedDeleteMenuController.open();
                            }
                          }
                        : null,
                    icon: const Icon(Icons.close),
                  ),
                ),
              ?trailingChild,
            ],
          ),
        ],
      ),
    );
  }
}

class SingleGridTabPreview extends HookConsumerWidget {
  final String tabId;
  final String? activeTabId;
  final String? sourceSearchQuery;
  final double deleteThreshold;

  final void Function() onClose;
  final void Function()? onBeforeDelete;

  const SingleGridTabPreview({
    required this.tabId,
    required this.activeTabId,
    required this.onClose,
    required this.sourceSearchQuery,
    this.deleteThreshold = 100,
    this.onBeforeDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTabState = ref.watch(
      tabStateProvider(tabId).select((value) => value != null),
    );

    if (!hasTabState) {
      return const SizedBox.shrink();
    }

    final dragStartPosition = useRef(Offset.zero);
    final draggedDistance = useState(0.0);

    return GestureDetector(
      onHorizontalDragStart: (details) {
        dragStartPosition.value = details.globalPosition;
        draggedDistance.value = 0.0;
      },
      onHorizontalDragUpdate: (details) {
        final cappedDistance = math.min(
          (dragStartPosition.value - details.globalPosition).dx.abs(),
          deleteThreshold,
        );

        draggedDistance.value = cappedDistance;
      },
      onHorizontalDragEnd: (details) async {
        if (draggedDistance.value >= deleteThreshold) {
          await ref.read(tabRepositoryProvider.notifier).closeTab(tabId);

          if (context.mounted) {
            ui_helper.showTabUndoClose(
              context,
              ref.read(tabRepositoryProvider.notifier).undoClose,
            );
          }
        }

        draggedDistance.value = 0.0;
      },
      child: Opacity(
        opacity: 1.0 - draggedDistance.value / deleteThreshold,
        child: GridTabPreview(
          tabId: tabId,
          isActive: tabId == activeTabId,
          onTap: () async {
            if (tabId != activeTabId) {
              //Close first to avoid rebuilds
              onClose();
              await ref.read(tabRepositoryProvider.notifier).selectTab(tabId);
              if (sourceSearchQuery.isNotEmpty &&
                  ref.read(findInPageControllerProvider(tabId)) ==
                      FindInPageState.hidden()) {
                await ref
                    .read(findInPageControllerProvider(tabId).notifier)
                    .findAll(text: sourceSearchQuery!);
              }
            } else {
              onClose();
            }
          },
          onDeleteAll: (host) async {
            final containerId = await ref
                .read(tabDataRepositoryProvider.notifier)
                .getTabContainerId(tabId);

            final count = await ref
                .read(tabDataRepositoryProvider.notifier)
                .closeAllTabsByHost(containerId, host);

            if (context.mounted) {
              ui_helper.showTabUndoClose(
                context,
                ref.read(tabRepositoryProvider.notifier).undoClose,
                count: count,
              );
            }
          },
          // onDoubleTap: () {
          //   ref.read(overlayDialogControllerProvider.notifier).show(
          //         TabActionDialog(
          //           initialTab: tab,
          //           onDismiss:
          //               ref.read(overlayDialogControllerProvider.notifier).dismiss,
          //         ),
          //       );
          // },
          onDelete: () async {
            onBeforeDelete?.call();

            await ref.read(tabRepositoryProvider.notifier).closeTab(tabId);

            if (context.mounted) {
              ui_helper.showTabUndoClose(
                context,
                ref.read(tabRepositoryProvider.notifier).undoClose,
              );
            }
          },
        ),
      ),
    );
  }
}

class SingleListTabPreview extends HookConsumerWidget {
  final String tabId;
  final String? activeTabId;
  final String? sourceSearchQuery;
  final double deleteThreshold;

  final void Function() onClose;
  final void Function()? onBeforeDelete;

  const SingleListTabPreview({
    required this.tabId,
    required this.activeTabId,
    required this.onClose,
    required this.sourceSearchQuery,
    this.deleteThreshold = 100,
    this.onBeforeDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTabState = ref.watch(
      tabStateProvider(tabId).select((value) => value != null),
    );

    if (!hasTabState) {
      return const SizedBox.shrink();
    }

    final dragStartPosition = useRef(Offset.zero);
    final draggedDistance = useState(0.0);

    return GestureDetector(
      onHorizontalDragStart: (details) {
        dragStartPosition.value = details.globalPosition;
        draggedDistance.value = 0.0;
      },
      onHorizontalDragUpdate: (details) {
        final cappedDistance = math.min(
          (dragStartPosition.value - details.globalPosition).dx.abs(),
          deleteThreshold,
        );

        draggedDistance.value = cappedDistance;
      },
      onHorizontalDragEnd: (details) async {
        if (draggedDistance.value >= deleteThreshold) {
          await ref.read(tabRepositoryProvider.notifier).closeTab(tabId);

          if (context.mounted) {
            ui_helper.showTabUndoClose(
              context,
              ref.read(tabRepositoryProvider.notifier).undoClose,
            );
          }
        }

        draggedDistance.value = 0.0;
      },
      child: Opacity(
        opacity: 1.0 - draggedDistance.value / deleteThreshold,
        child: ListTabPreview(
          tabId: tabId,
          isActive: tabId == activeTabId,
          onTap: () async {
            if (tabId != activeTabId) {
              //Close first to avoid rebuilds
              onClose();
              await ref.read(tabRepositoryProvider.notifier).selectTab(tabId);
              if (sourceSearchQuery.isNotEmpty &&
                  ref.read(findInPageControllerProvider(tabId)) ==
                      FindInPageState.hidden()) {
                await ref
                    .read(findInPageControllerProvider(tabId).notifier)
                    .findAll(text: sourceSearchQuery!);
              }
            } else {
              onClose();
            }
          },
          onDeleteAll: (host) async {
            final containerId = await ref
                .read(tabDataRepositoryProvider.notifier)
                .getTabContainerId(tabId);

            final count = await ref
                .read(tabDataRepositoryProvider.notifier)
                .closeAllTabsByHost(containerId, host);

            if (context.mounted) {
              ui_helper.showTabUndoClose(
                context,
                ref.read(tabRepositoryProvider.notifier).undoClose,
                count: count,
              );
            }
          },
          // onDoubleTap: () {
          //   ref.read(overlayDialogControllerProvider.notifier).show(
          //         TabActionDialog(
          //           initialTab: tab,
          //           onDismiss:
          //               ref.read(overlayDialogControllerProvider.notifier).dismiss,
          //         ),
          //       );
          // },
          onDelete: () async {
            onBeforeDelete?.call();

            await ref.read(tabRepositoryProvider.notifier).closeTab(tabId);

            if (context.mounted) {
              ui_helper.showTabUndoClose(
                context,
                ref.read(tabRepositoryProvider.notifier).undoClose,
              );
            }
          },
        ),
      ),
    );
  }
}

class SuggestedSingleGridTabPreview extends StatelessWidget {
  final String tabId;

  final String? activeTabId;

  final void Function()? onTap;

  const SuggestedSingleGridTabPreview({
    required this.tabId,
    required this.activeTabId,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: GridTabPreview(
        tabId: tabId,
        isActive: tabId == activeTabId,
        onTap: onTap,
        trailingChild: const IconButton(
          visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0),
          icon: Icon(MdiIcons.creation),
          onPressed: null,
        ),
      ),
    );
  }
}

class SuggestedSingleListTabPreview extends StatelessWidget {
  final String tabId;

  final String? activeTabId;

  final void Function()? onTap;

  const SuggestedSingleListTabPreview({
    required this.tabId,
    required this.activeTabId,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: ListTabPreview(
        tabId: tabId,
        isActive: tabId == activeTabId,
        onTap: onTap,
        trailingChild: const IconButton(
          visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0),
          icon: Icon(MdiIcons.creation),
          onPressed: null,
        ),
      ),
    );
  }
}
