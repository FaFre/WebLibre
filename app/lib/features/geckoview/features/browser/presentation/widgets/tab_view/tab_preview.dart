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
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_icon.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/domain/entities/find_in_page_state.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/widgets/safe_raw_image.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

Future<bool> _confirmIsolatedTabCloseIfNeeded(
  BuildContext context,
  WidgetRef ref,
  String tabId,
) async {
  final allStates = ref.read(tabStatesProvider);
  final tabState = allStates[tabId];
  final contextId = tabState?.isolationContextId;

  if (contextId == null) return true;

  final groupCount = allStates.values
      .where((state) => state.isolationContextId == contextId)
      .length;

  if (groupCount > 1) return true;
  if (!context.mounted) return false;

  return ui_helper.confirmIsolatedTabClose(context);
}

class GridTabItemContainer extends StatelessWidget {
  final bool isActive;
  final TabMode tabMode;
  final Widget? child;

  const GridTabItemContainer({
    required this.isActive,
    required this.tabMode,
    this.child,
    super.key,
  });

  static const borderRadius = BorderRadius.all(Radius.circular(12.0));

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = AppColors.of(context);

    final bgColor = switch (tabMode) {
      PrivateTabMode() => appColors.privateTabBackground.withAlpha(80),
      IsolatedTabMode() => appColors.isolatedTabBackground.withAlpha(80),
      RegularTabMode() => colorScheme.surfaceContainerHigh,
    };

    final borderWidth = isActive ? 4.0 : 3.0;
    final innerRadius = BorderRadius.all(Radius.circular(12.0 - borderWidth));

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive
              ? colorScheme.primary
              : colorScheme.outline.withAlpha(40),
          width: borderWidth,
        ),
        borderRadius: borderRadius,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(60),
                  blurRadius: 8.0,
                  spreadRadius: 1.0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: colorScheme.surface,
        borderRadius: innerRadius,
        clipBehavior: Clip.antiAlias,
        child: Material(color: bgColor, child: child),
      ),
    );
  }
}

class GridTabPreview extends HookConsumerWidget {
  final String tabId;
  final bool isActive;

  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onDelete;
  final void Function(String host)? onDeleteAll;

  final bool showPinBadge;

  final Widget? trailingChild;

  const GridTabPreview({
    required this.tabId,
    required this.isActive,
    this.onTap,
    this.onDoubleTap,
    this.onDelete,
    this.onDeleteAll,
    this.showPinBadge = false,
    this.trailingChild,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appColors = AppColors.of(context);

    final tabState =
        ref.watch(
          tabStateWithFallbackProvider(
            tabId,
          ).select((asyncValue) => asyncValue.value),
        ) ??
        TabState.$default(tabId);

    final extendedDeleteMenuController = useMenuController();

    // ignore: avoid_bool_literals_in_conditional_expressions
    final isPinned = showPinBadge
        ? ref.watch(
            watchPinnedTabIdsProvider.select(
              (v) => v.value?.contains(tabId) ?? false,
            ),
          )
        : false;

    final modeTextColor = switch (tabState.tabMode) {
      PrivateTabMode() => appColors.privateTabForeground,
      IsolatedTabMode() => appColors.isolatedTabForeground,
      RegularTabMode() => null,
    };

    final subtitleColor = switch (tabState.tabMode) {
      PrivateTabMode() => Color.lerp(
        appColors.privateTabPurple,
        Colors.white,
        0.4,
      )!,
      IsolatedTabMode() => Color.lerp(
        appColors.isolatedTabTeal,
        Colors.white,
        0.4,
      )!,
      RegularTabMode() => colorScheme.onSurfaceVariant,
    };

    final (modeBadgeIcon, modeBadgeColor) = switch (tabState.tabMode) {
      PrivateTabMode() => (MdiIcons.dominoMask, appColors.privateTabPurple),
      IsolatedTabMode() => (MdiIcons.snowflake, appColors.isolatedTabTeal),
      RegularTabMode() => (null, null),
    };

    return GridTabItemContainer(
      isActive: isActive,
      tabMode: tabState.tabMode,
      child: InkWell(
        borderRadius: GridTabItemContainer.borderRadius,
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: Column(
          children: [
            // Thumbnail or icon area
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (tabState.thumbnail != null &&
                      !tabState.thumbnail!.isDisposed)
                    RepaintBoundary(
                      child: SafeRawImage(
                        image: tabState.thumbnail,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Center(child: TabIcon(tabState: tabState, iconSize: 48)),
                  // Close button overlay
                  if (onDelete != null || onDeleteAll != null)
                    Positioned(
                      top: 6.0,
                      right: 6.0,
                      child: MenuAnchor(
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
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: Material(
                            color: colorScheme.surfaceContainerHighest
                                .withAlpha(200),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            child: InkWell(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              onTap: onDelete,
                              onLongPress: onDeleteAll != null
                                  ? () {
                                      if (extendedDeleteMenuController.isOpen) {
                                        extendedDeleteMenuController.close();
                                      } else {
                                        extendedDeleteMenuController.open();
                                      }
                                    }
                                  : null,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (trailingChild != null || isPinned)
                    Positioned(
                      top: 6.0,
                      left: 6.0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (trailingChild != null) trailingChild!,
                          if (isPinned)
                            Padding(
                              padding: EdgeInsets.only(
                                left: trailingChild != null ? 4.0 : 0,
                              ),
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: Material(
                                  color: colorScheme.surfaceContainerHighest
                                      .withAlpha(200),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  child: InkWell(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    onTap: () async {
                                      await ref
                                          .read(
                                            tabDataRepositoryProvider.notifier,
                                          )
                                          .setPinned(tabId, pinned: false);

                                      if (context.mounted) {
                                        ui_helper.showInfoMessage(
                                          context,
                                          'Tab unpinned',
                                          action: SnackBarAction(
                                            label: 'Undo',
                                            onPressed: () async {
                                              await ref
                                                  .read(
                                                    tabDataRepositoryProvider
                                                        .notifier,
                                                  )
                                                  .setPinned(
                                                    tabId,
                                                    pinned: true,
                                                  );
                                            },
                                          ),
                                        );
                                      }
                                    },
                                    child: Icon(
                                      MdiIcons.pin,
                                      size: 16,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Bottom info band
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(120),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tabState.titleOrAuthority,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: modeTextColor,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Row(
                    children: [
                      TabIcon(tabState: tabState, iconSize: 14.0),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tabState.url.authority,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: subtitleColor,
                          ),
                        ),
                      ),
                      if (modeBadgeIcon != null) ...[
                        const SizedBox(width: 4),
                        Icon(modeBadgeIcon, color: modeBadgeColor, size: 14),
                      ],
                    ],
                  ),
                ],
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
  final VoidCallback? onDelete;
  final void Function(String host)? onDeleteAll;

  final bool showPinBadge;

  final Widget? trailingChild;

  const ListTabPreview({
    required this.tabId,
    required this.isActive,
    this.onTap,
    this.onDelete,
    this.onDeleteAll,
    this.showPinBadge = false,
    this.trailingChild,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appColors = AppColors.of(context);

    final tabState =
        ref.watch(
          tabStateWithFallbackProvider(
            tabId,
          ).select((asyncValue) => asyncValue.value),
        ) ??
        TabState.$default(tabId);

    final tabListShowFavicons = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabListShowFavicons),
    );

    final extendedDeleteMenuController = useMenuController();

    // ignore: avoid_bool_literals_in_conditional_expressions
    final isPinned = showPinBadge
        ? ref.watch(
            watchPinnedTabIdsProvider.select(
              (v) => v.value?.contains(tabId) ?? false,
            ),
          )
        : false;

    final leadingWidget = switch ((tabListShowFavicons, tabState.thumbnail)) {
      (false, final thumbnail?) when !thumbnail.isDisposed => ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        child: RepaintBoundary(
          child: SafeRawImage(image: thumbnail, fit: BoxFit.fitHeight),
        ),
      ),
      _ => TabIcon(tabState: tabState, iconSize: 32),
    };

    final listBgColor = switch (tabState.tabMode) {
      PrivateTabMode() => appColors.privateTabBackground.withAlpha(80),
      IsolatedTabMode() => appColors.isolatedTabBackground.withAlpha(80),
      RegularTabMode() when isActive => colorScheme.primary.withAlpha(20),
      RegularTabMode() => Colors.transparent,
    };
    final listTextColor = switch (tabState.tabMode) {
      PrivateTabMode() => appColors.privateTabForeground,
      IsolatedTabMode() => appColors.isolatedTabForeground,
      RegularTabMode() => null,
    };
    final (modeBadgeIcon, modeBadgeColor) = switch (tabState.tabMode) {
      PrivateTabMode() => (MdiIcons.dominoMask, appColors.privateTabPurple),
      IsolatedTabMode() => (MdiIcons.snowflake, appColors.isolatedTabTeal),
      RegularTabMode() => (null, null),
    };

    final subtitleColor = switch (tabState.tabMode) {
      PrivateTabMode() => Color.lerp(
        appColors.privateTabPurple,
        Colors.white,
        0.4,
      )!,
      IsolatedTabMode() => Color.lerp(
        appColors.isolatedTabTeal,
        Colors.white,
        0.4,
      )!,
      RegularTabMode() => colorScheme.onSurfaceVariant,
    };

    const borderRadius = BorderRadius.all(Radius.circular(12.0));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: listBgColor,
        borderRadius: borderRadius,
        border: isActive
            ? Border(left: BorderSide(color: colorScheme.primary, width: 4.0))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 10.0, bottom: 10.0),
            child: Row(
              children: [
                leadingWidget,
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tabState.titleOrAuthority,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: listTextColor,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      Row(
                        children: [
                          if (isPinned) ...[
                            Icon(
                              MdiIcons.pin,
                              color: colorScheme.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                          ],
                          if (modeBadgeIcon != null) ...[
                            Icon(
                              modeBadgeIcon,
                              color: modeBadgeColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: UriBreadcrumb(
                              uri: tabState.url,
                              style: textTheme.bodySmall?.copyWith(
                                color: subtitleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ?trailingChild,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SyncedListTabPreview extends StatelessWidget {
  const SyncedListTabPreview({
    super.key,
    required this.title,
    required this.url,
    required this.deviceName,
    required this.onTap,
  });

  final String title;
  final Uri url;
  final String deviceName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.only(left: 8, right: 6),
      leading: UrlIcon([url], iconSize: 20),
      title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.devices, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  deviceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          UriBreadcrumb(uri: url),
        ],
      ),
      trailing: const Icon(Icons.open_in_new),
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
          if (!await _confirmIsolatedTabCloseIfNeeded(context, ref, tabId)) {
            draggedDistance.value = 0.0;
            return;
          }

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
          showPinBadge: true,
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
          onDelete: () async {
            onBeforeDelete?.call();

            if (!await _confirmIsolatedTabCloseIfNeeded(context, ref, tabId)) {
              return;
            }

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
          if (!await _confirmIsolatedTabCloseIfNeeded(context, ref, tabId)) {
            draggedDistance.value = 0.0;
            return;
          }

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
          showPinBadge: true,
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
          onDelete: () async {
            onBeforeDelete?.call();

            if (!await _confirmIsolatedTabCloseIfNeeded(context, ref, tabId)) {
              return;
            }

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
        trailingChild: SizedBox(
          width: 28,
          height: 28,
          child: Material(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withAlpha(200),
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            child: const Icon(MdiIcons.creation, size: 16),
          ),
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
