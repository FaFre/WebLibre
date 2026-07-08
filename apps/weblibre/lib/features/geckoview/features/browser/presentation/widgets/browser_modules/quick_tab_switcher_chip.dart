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

import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_icon.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_menu.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_depth_indicator.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class QuickTabSwitcherItem with FastEquatable {
  final Color? color;
  final bool useCustomColor;
  final String id;
  final bool isActive;
  final TabMode tabMode;
  final bool isHistory;
  final bool isPinned;
  final bool isSandbox;
  final int depth;
  final String title;
  final Uri url;
  final Widget avatar;

  /// True while the tab is only known from the local DB cache and the native
  /// session restore hasn't delivered its state yet. Placeholders cannot be
  /// closed or reordered.
  final bool isPlaceholder;

  QuickTabSwitcherItem({
    required this.color,
    required this.id,
    required this.isActive,
    required this.tabMode,
    required this.isHistory,
    required this.isPinned,
    required this.title,
    required this.url,
    required this.avatar,
    this.useCustomColor = false,
    this.isSandbox = false,
    this.depth = 0,
    this.isPlaceholder = false,
  });

  /// Builds a switcher entry for an open tab. [sandboxSourceUri] is the
  /// canonical source URL when the tab is a sandbox capture (otherwise null),
  /// so the bar shows the real site instead of the loopback capture URL.
  factory QuickTabSwitcherItem.tab(
    TabStateWithContainer state, {
    required String? selectedTabId,
    required Set<String> pinnedTabIds,
    required Map<String, int> tabDepthById,
    required Uri? sandboxSourceUri,
    bool isPlaceholder = false,
  }) {
    final (tab, container) = state;

    return QuickTabSwitcherItem(
      color: container?.color,
      useCustomColor: container?.metadata.useCustomColor ?? false,
      id: tab.id,
      isActive: tab.id == selectedTabId,
      title: sandboxSourceUri != null && tab.title.isEmpty
          ? sandboxSourceUri.authority
          : tab.titleOrAuthority,
      tabMode: tab.tabMode,
      isHistory: false,
      isPinned: pinnedTabIds.contains(tab.id),
      isSandbox: sandboxSourceUri != null,
      depth: tabDepthById[tab.id] ?? 0,
      url: sandboxSourceUri ?? tab.url,
      avatar: TabIcon(tabState: tab, iconSize: 20),
      isPlaceholder: isPlaceholder,
    );
  }

  /// Builds a switcher entry for a history suggestion (shown only when there
  /// are no open tabs in the active mode).
  factory QuickTabSwitcherItem.history({
    required String url,
    required String? title,
  }) {
    final parsedUrl = Uri.parse(url);

    return QuickTabSwitcherItem(
      color: null,
      id: url,
      isActive: false,
      title: title ?? parsedUrl.authority,
      tabMode: TabMode.regular,
      isHistory: true,
      isPinned: false,
      url: parsedUrl,
      avatar: UrlIcon([parsedUrl], iconSize: 20),
    );
  }

  @override
  List<Object?> get hashParameters => [
    color,
    useCustomColor,
    id,
    isActive,
    tabMode,
    isHistory,
    isPinned,
    isSandbox,
    depth,
    title,
    url,
    avatar,
    isPlaceholder,
  ];
}

/// Visual contract shared by every quick tab switcher render path
/// ([SelectableChips], the reorderable list, and the accordion view).
SelectableChipDecoration<QuickTabSwitcherItem>
buildQuickTabSwitcherChipDecoration(
  BuildContext context, {
  required bool showTitles,
  required int hierarchyGlyphs,
  // On the vertical rail nesting is shown as a corner badge on the favicon (not
  // a leading pill), so a nested chip carries no extra inline width and can use
  // the same zero label padding as a leaf chip instead of overflowing.
  bool isVertical = false,
  bool Function(QuickTabSwitcherItem item)? canDelete,
  // When true, the selected item gets a thicker border in its container's
  // outline color (instead of the usual transparent selected border). The
  // accordion uses this so the active tab stays visible against its
  // container-colored tray while matching the unselected chips' border color.
  bool thickContainerSelectedBorder = false,
}) {
  return SelectableChipDecoration(
    color: (item, isSelected) => switch (item.color) {
      final color? when isSelected => ContainerColors.palette(
        context,
        color,
        useCustomColor: item.useCustomColor,
      ).selectedBackgroundColor,
      final color? => ContainerColors.palette(
        context,
        color,
        useCustomColor: item.useCustomColor,
      ).backgroundColor,
      null => null,
    },
    side: (item, isSelected) => switch (item.color) {
      final color? when isSelected =>
        thickContainerSelectedBorder
            ? BorderSide(
                color: ContainerColors.palette(
                  context,
                  color,
                  useCustomColor: item.useCustomColor,
                ).outlineColor,
                width: 2.0,
              )
            : ContainerColors.palette(
                context,
                color,
                useCustomColor: item.useCustomColor,
              ).selectedBorderSide,
      final color? => ContainerColors.palette(
        context,
        color,
        useCustomColor: item.useCustomColor,
      ).borderSide,
      null => null,
    },
    labelPadding: (item) =>
        (!showTitles &&
            !item.isHistory &&
            !item.isPinned &&
            !item.isSandbox &&
            (item.depth == 0 || hierarchyGlyphs == 0 || isVertical) &&
            item.tabMode is! PrivateTabMode &&
            item.tabMode is! IsolatedTabMode)
        ? EdgeInsets.zero
        : null,
    canDelete: canDelete,
    deleteIcon: (_) => const Icon(Icons.close, size: 18),
  );
}

Widget buildQuickTabSwitcherChipLabel(
  BuildContext context,
  QuickTabSwitcherItem item, {
  required bool isSelected,
  required bool showTitles,
  required bool showIsolatedTabUi,
  required int hierarchyGlyphs,
  required double titleMaxWidth,
  // On the narrow vertical rail the leading depth pill has no room beside the
  // favicon (it clips the icon), so nesting is shown as a compact corner badge
  // overlaid on the favicon instead.
  bool isVertical = false,
}) {
  final appColors = AppColors.of(context);
  final hasTitle = item.isHistory || showTitles;
  final isNested = item.depth > 0 && hierarchyGlyphs > 0;
  final showInlineDepth = isNested && !isVertical;
  final avatar = (isNested && isVertical)
      ? _RailDepthAvatar(depth: item.depth, child: item.avatar)
      : item.avatar;
  final row = Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (showInlineDepth)
        Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: TabDepthIndicator(
            depth: item.depth,
            height: 20.0,
            iconSize: 14.0,
            horizontalPadding: 4.0,
            maxInlineGlyphs: hierarchyGlyphs,
          ),
        ),
      Padding(
        padding: EdgeInsets.only(right: hasTitle ? 6.0 : 0.0),
        child: avatar,
      ),
      if (hasTitle)
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: titleMaxWidth),
          child: Text(item.title),
        ),
      if (showIsolatedTabUi && item.tabMode is IsolatedTabMode)
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(
            MdiIcons.snowflake,
            color: appColors.isolatedTabTeal,
            size: 20,
          ),
        )
      else if (item.tabMode is PrivateTabMode)
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(
            MdiIcons.dominoMask,
            color: appColors.privateTabPurple,
            size: 20,
          ),
        ),
      if (item.isSandbox)
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(
            MdiIcons.archiveLockOutline,
            color: Theme.of(context).colorScheme.tertiary,
            size: 20,
          ),
        ),
      if (item.isPinned)
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(
            MdiIcons.pin,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
      if (item.isHistory)
        const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Icon(MdiIcons.history, size: 20),
        ),
    ],
  );

  return item.color.mapNotNull(
        (color) => DefaultTextStyle.merge(
          style: TextStyle(
            color: isSelected
                ? ContainerColors.palette(
                    context,
                    color,
                    useCustomColor: item.useCustomColor,
                  ).selectedForegroundColor
                : ContainerColors.palette(
                    context,
                    color,
                    useCustomColor: item.useCustomColor,
                  ).foregroundColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
          child: row,
        ),
      ) ??
      row;
}

/// Favicon with a compact nesting badge overlaid on its bottom-right corner,
/// used on the vertical side rail where the inline [TabDepthIndicator] pill
/// would clip the favicon. The badge shows a subdirectory-arrow glyph for a
/// direct child and the depth number for deeper nesting.
class _RailDepthAvatar extends StatelessWidget {
  final int depth;
  final Widget child;

  const _RailDepthAvatar({required this.depth, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Keep the exact 20px footprint of a plain favicon so a nested chip stays
    // the same width as a leaf chip on the narrow rail; the badge is anchored
    // inside the horizontal bounds (only the vertical corner is allowed to
    // bleed, where there's ample room) so it never widens the chip.
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: child),
          Positioned(
            right: -3,
            bottom: -5,
            child: Container(
              constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                border: Border.all(color: scheme.surfaceContainer, width: 1.0),
              ),
              child: Center(
                child: depth > 1
                    ? Text(
                        '$depth',
                        style: TextStyle(
                          fontSize: 9,
                          height: 1.0,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSecondaryContainer,
                        ),
                      )
                    : Icon(
                        MdiIcons.subdirectoryArrowRight,
                        size: 10,
                        color: scheme.onSecondaryContainer,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// FilterChip matching [SelectableChips]' visual contract, used by render
/// paths that can't go through [SelectableChips] itself (the reorderable
/// list and the accordion view). Stateless wrapper so a parent
/// `ReorderableListView` can attach its drag-handle gesture recognizer.
class QuickTabSwitcherChip extends StatelessWidget {
  final QuickTabSwitcherItem item;
  final bool isSelected;
  final Color selectedBorderColor;
  final SelectableChipDecoration<QuickTabSwitcherItem> decoration;
  final Widget label;
  final Future<void> Function() onTap;
  final Future<void> Function()? onDelete;

  /// Outer spacing around the chip. Defaults to the standard inter-chip gap;
  /// render paths that manage their own spacing (e.g. the accordion tray)
  /// pass [EdgeInsets.zero].
  final EdgeInsetsGeometry padding;

  const QuickTabSwitcherChip({
    super.key,
    required this.item,
    required this.isSelected,
    required this.selectedBorderColor,
    required this.decoration,
    required this.label,
    required this.onTap,
    this.onDelete,
    this.padding = const EdgeInsets.only(right: 8.0, top: 4.0),
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = decoration.color?.call(item, isSelected);
    final side =
        decoration.side?.call(item, isSelected) ??
        (isSelected
            ? BorderSide(color: selectedBorderColor, width: 2.0)
            : null);
    final labelPadding = decoration.labelPadding?.call(item);

    return Padding(
      padding: padding,
      child: FilterChip(
        color: itemColor != null ? WidgetStatePropertyAll(itemColor) : null,
        selected: false,
        showCheckmark: false,
        labelPadding: labelPadding,
        onSelected: (_) {
          unawaited(onTap());
        },
        deleteIcon: decoration.deleteIcon?.call(item),
        onDeleted: onDelete != null
            ? () {
                unawaited(onDelete!());
              }
            : null,
        label: label,
        side: side,
      ),
    );
  }
}

/// Wraps a tab chip in the long-press [TabMenu] used across switcher views.
Widget wrapQuickTabSwitcherChipWithMenu({
  required String itemId,
  required bool enabled,
  required bool enablePinTab,
  required Widget child,
}) {
  if (!enabled) {
    return child;
  }

  return TabMenu(
    selectedTabId: itemId,
    enableFindInPage: false,
    enableFetchFeeds: false,
    enableDesktopMode: false,
    enableReaderMode: false,
    enableReloadButton: false,
    enableNavigationButtons: false,
    enableAddToHomeScreen: false,
    enablePinTab: enablePinTab,
    builder: (context, controller, _) {
      return InkWell(
        onLongPress: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
        child: child,
      );
    },
  );
}
