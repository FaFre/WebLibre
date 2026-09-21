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

import 'package:fading_scroll/fading_scroll.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers/restore_complete.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_list_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/accordion_expansion.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/accordion_drop.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/close_tab_helper.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/tab_view_reorder.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/quick_tab_switcher_chip.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/container_menu.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_context_menu_draggable.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_view_item.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart'
    as tab_data;
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_chip_content.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/presentation/hooks/scroll_to_active_chip.dart';
import 'package:weblibre/presentation/widgets/inline_count_badge.dart';
import 'package:weblibre/presentation/widgets/reorderable_hold_drag.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Accordion stacking mode for the quick tab switcher bar: every available
/// container renders as a header, and an expanded group's tabs appear inline
/// right after its header.
///
/// Tapping a header only expands or collapses its group; it never selects the
/// container. Selecting one of the group's tabs does that, as it does
/// everywhere. See [AccordionExpansion] for which groups are open: several at
/// once on a wide side panel, one at a time in a single row or narrow rail.
class AccordionQuickTabSwitcher extends HookConsumerWidget {
  const AccordionQuickTabSwitcher({
    super.key,
    this.axis = Axis.horizontal,
    this.railWidth = BrowserTabBar.compactRailWidth,
  });

  /// Direction the accordion flows. Vertical for the side rail.
  final Axis axis;

  /// Width of the rail this accordion is rendered in, when [axis] is vertical.
  ///
  /// The accordion carries its own copy of the rail's width guards because it
  /// is a separate widget from [QuickTabSwitcherView] with its own chip
  /// layout; both have to widen together or accordion stacking would stay
  /// icon-only inside a 256dp panel.
  final double railWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVertical = axis == Axis.vertical;
    final isWideRail = isVertical && BrowserTabBar.isWideRailWidth(railWidth);
    final scrollController = useScrollController();
    final activeChipKey = useRef(GlobalKey());
    final isUserScrolling = useRef(false);
    final userScrollTimer = useRef<Timer?>(null);

    useEffect(() {
      return userScrollTimer.value?.cancel;
    }, []);

    final showTitlesSetting = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherShowTitles,
      ),
    );
    // Titles can't fit a *narrow* vertical rail; force icon-only chips there.
    // A rail wide enough to be a tab panel has room for them.
    final showTitles = (!isVertical || isWideRail) && showTitlesSetting;
    final showIsolatedTabUi = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.showIsolatedTabUi),
    );
    final hierarchyGlyphs = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherHierarchyGlyphs,
      ),
    );
    final titleMaxWidth = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherTitleWidth,
      ),
    );
    final closeButtonMode = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherCloseButtonMode,
      ),
    );

    final containers =
        ref.watch(
          watchContainersWithCountProvider.select((value) => value.value),
        ) ??
        const <ContainerDataWithCount>[];
    final selectedContainerId = ref.watch(selectedContainerProvider);
    final selectedTabId = ref.watch(selectedTabProvider);

    final unassignedTabCount = ref.watch(
      containerTabCountProvider(
        // ignore: provider_parameters
        ContainerFilterById(containerId: null),
      ).select((value) => value.value ?? 0),
    );

    // A side panel has the height to show several groups open at once; a
    // single row or a narrow rail does not.
    final expandedIds = ref
        .watch(accordionExpansionControllerProvider)
        .displayed(multiple: isWideRail);
    final pinnedTabIds = ref.watch(
      watchPinnedTabIdsProvider.select(
        (value) => value.value ?? const <String>{},
      ),
    );
    final sandboxCaptureMap =
        ref.watch(sandboxCaptureMapProvider).value ?? const {};
    final restoreComplete = ref.watch(browserRestoreCompleteProvider);
    final nativeTabIds = ref
        .watch(
          tabStatesProvider.select(
            (states) => EquatableValue(states.keys.toSet()),
          ),
        )
        .value;

    // A filter or search in the tab view makes the order a drop lands in
    // ambiguous, and tabs still restoring are unknown to the engine, so either
    // switches dragging off.
    final canManualReorder = ref.watch(canManualTabReorderProvider);
    final canReorder = canManualReorder && restoreComplete;
    final tabBarDirection = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarDirection),
    );
    final sortPinnedFirst = ref.watch(
      tabViewFilterControllerProvider.select((v) => v.sortPinnedFirst),
    );

    /// The tabs of an expanded group. Only called for groups shown open, so
    /// collapsed containers subscribe to nothing.
    List<QuickTabSwitcherItem> itemsFor(String? containerId) {
      final tabStates = ref.watch(
        containerTabStatesWithContainerProvider(containerId),
      );
      final tabDepthById = ref
          .watch(
            groupedTabListItemsProvider(
              containerId: containerId,
              scope: TabListScope.presentation,
            ).select((value) {
              return EquatableValue(<String, int>{
                if (hierarchyGlyphs > 0)
                  for (final item in value.value)
                    if (item is TabListChildItem) item.tabId: item.depth,
              });
            }),
          )
          .value;

      return tabStates.value
          .map(
            (state) => QuickTabSwitcherItem.tab(
              state,
              selectedTabId: selectedTabId,
              pinnedTabIds: pinnedTabIds,
              tabDepthById: tabDepthById,
              sandboxSourceUri: parseSandboxSource(
                sandboxCaptureMap[state.$1.id],
              ),
              isPlaceholder:
                  !restoreComplete && !nativeTabIds.contains(state.$1.id),
            ),
          )
          .toList();
    }

    final decoration = buildQuickTabSwitcherChipDecoration(
      context,
      showTitles: showTitles,
      hierarchyGlyphs: hierarchyGlyphs,
      isVertical: isVertical,
      // The tray is painted in the container color, so the active tab's normal
      // (transparent) selected border would blend in; give it a thicker border
      // in the container's outline color instead.
      thickContainerSelectedBorder: true,
    );

    void toggleGroup(String? containerId) {
      ref
          .read(accordionExpansionControllerProvider.notifier)
          .toggle(containerId, multiple: isWideRail);
    }

    Widget buildTabContent(QuickTabSwitcherItem item) {
      final isSelected = item.isActive;
      // The narrow rail can't fit a close button beside the icon-only chip; it
      // overflows (and the active tab's thick border makes it worse). Closing
      // stays available via the long-press menu. A wide rail has the room.
      final canClose =
          (!isVertical || isWideRail) &&
          !item.isPlaceholder &&
          closeButtonMode.showsFor(isActive: item.isActive);

      if (isWideRail) {
        return QuickTabSwitcherRow(
          item: item,
          isSelected: isSelected,
          showIsolatedTabUi: showIsolatedTabUi,
          showTitles: showTitles,
          hierarchyGlyphs: hierarchyGlyphs,
          onTap: () {
            if (!item.isActive) {
              unawaited(
                ref.read(tabRepositoryProvider.notifier).selectTab(item.id),
              );
            }
          },
          onDelete: canClose
              ? () => unawaited(
                  closeTabWithConfirmationAndUndo(context, ref, item.id),
                )
              : null,
        );
      }

      return QuickTabSwitcherChip(
        item: item,
        isSelected: isSelected,
        selectedBorderColor: Theme.of(context).colorScheme.primary,
        decoration: decoration,
        label: buildQuickTabSwitcherChipLabel(
          context,
          item,
          isSelected: isSelected,
          showTitles: showTitles,
          showIsolatedTabUi: showIsolatedTabUi,
          hierarchyGlyphs: hierarchyGlyphs,
          titleMaxWidth: titleMaxWidth,
          isVertical: isVertical,
        ),
        // Spacing inside the expanded group is owned by the surrounding tray
        // slice so the slices abut into one continuous background.
        padding: EdgeInsets.zero,
        onTap: () async {
          if (item.isActive) {
            return;
          }
          await ref.read(tabRepositoryProvider.notifier).selectTab(item.id);
        },
        onDelete: canClose
            ? () => closeTabWithConfirmationAndUndo(context, ref, item.id)
            : null,
      );
    }

    Widget buildTabEntry(QuickTabSwitcherItem item, int index) {
      final content = buildTabContent(item);

      // Not backed by an engine session yet: no menu and nothing to move.
      if (item.isPlaceholder) return content;

      if (canReorder) {
        // Long press opens the menu, long press and move picks the tab up —
        // the same contract as the tab list and the container tabs row.
        return ReorderableHoldDragListener(
          index: index,
          child: TabContextMenuDraggable(
            tabId: item.id,
            feedbackSize: Size.zero,
            externalDrag: true,
            enableCloseTab: true,
            child: content,
          ),
        );
      }

      // Without a drag recognizer the long press has to claim the gesture
      // itself, or the tab would also be selected when the finger lifts off the
      // menu it just opened.
      final withMenu = wrapQuickTabSwitcherChipWithMenu(
        itemId: item.id,
        enabled: true,
        enablePinTab: true,
        child: content,
      );
      return canManualReorder
          ? withMenu
          : HoldDragDisabledHint(
              message: tabReorderBlockedMessage,
              child: withMenu,
            );
    }

    final showUnassignedGroup =
        unassignedTabCount > 0 ||
        selectedContainerId == null ||
        expandedIds.contains(null);

    final entries = <_AccordionEntry>[
      if (showUnassignedGroup) ...[
        _AccordionEntry.header(
          container: null,
          tabCount: unassignedTabCount,
          isExpanded: expandedIds.contains(null),
        ),
        if (expandedIds.contains(null))
          ...itemsFor(null).map(_AccordionEntry.tab),
      ],
      for (final container in containers) ...[
        _AccordionEntry.header(
          container: container,
          tabCount: container.tabCount ?? 0,
          isExpanded: expandedIds.contains(container.id),
        ),
        if (expandedIds.contains(container.id))
          ...itemsFor(container.id).map(_AccordionEntry.tab),
      ],
    ];

    // The expanded container header plus its tabs form one contiguous run that
    // is wrapped in a shared "tray" background so the group reads as a unit and
    // its members are visually distinct from the standalone container headers.
    // Each entry only knows which slice of that tray it paints; the slices abut
    // into one continuous rounded surface.
    final trayPositions = <_TrayPosition>[
      for (var i = 0; i < entries.length; i++)
        switch (entries[i]) {
          _AccordionHeaderEntry(:final isExpanded) =>
            !isExpanded
                ? _TrayPosition.none
                : (i + 1 < entries.length &&
                          entries[i + 1] is _AccordionTabEntry
                      ? _TrayPosition.start
                      : _TrayPosition.solo),
          _AccordionTabEntry() =>
            (i + 1 >= entries.length || entries[i + 1] is _AccordionHeaderEntry)
                ? _TrayPosition.end
                : _TrayPosition.middle,
        },
    ];

    // Each expanded group's tray is filled with its container's color so the
    // whole group reads as "this container". The unassigned group has no color
    // and falls back to a neutral surface. Several groups can be open, so the
    // fill is worked out per entry from the header it belongs to.
    final scheme = Theme.of(context).colorScheme;
    final trayFills = <Color>[];
    var groupFill = scheme.surfaceContainerHigh;
    for (final entry in entries) {
      if (entry is _AccordionHeaderEntry) {
        final container = entry.container;
        groupFill = container != null
            ? ContainerColors.palette(
                context,
                container.color,
                useCustomColor: container.metadata.useCustomColor,
              ).containerColor
            : scheme.surfaceContainerHigh;
      }
      trayFills.add(groupFill);
    }

    // The chip to keep centered: the active tab when it is part of the
    // expanded group, otherwise the expanded container header as a fallback.
    final activeTabEntryId = 'tab-$selectedTabId';
    final hasActiveTab = entries.any((entry) => entry.id == activeTabEntryId);
    String? expandedHeaderId;
    for (final entry in entries) {
      if (entry is _AccordionHeaderEntry && entry.isExpanded) {
        expandedHeaderId = entry.id;
        break;
      }
    }
    final activeEntryId = hasActiveTab ? activeTabEntryId : expandedHeaderId;

    // The entry list only implies each tab's group by position; a drop needs it
    // spelled out.
    final slots = <AccordionSlot>[];
    String? slotGroup;
    for (final entry in entries) {
      switch (entry) {
        case _AccordionHeaderEntry(:final container):
          slotGroup = container?.id;
          slots.add(AccordionHeaderSlot(slotGroup));
        case _AccordionTabEntry(:final item):
          slots.add(AccordionTabSlot(item.id, containerId: slotGroup));
      }
    }

    // Read up front: a drop rebuilds this widget, and moving a tab into another
    // container can unmount the entry it was dragged from before the awaits
    // below return.
    final tabData = ref.read(tab_data.tabDataRepositoryProvider.notifier);

    void showCannotMove() {
      if (context.mounted) {
        ui_helper.showInfoMessage(context, 'Tab cannot be moved here');
      }
    }

    Future<void> reorderWithin(List<String> tabIds, int from, int to) async {
      final result = buildTabViewReorderResult(
        visibleItems: [
          for (final tabId in tabIds) TabViewItem.standalone(tabId: tabId),
        ],
        treeRows: const [],
        collapsedGroups: const {},
        pinnedTabIds: pinnedTabIds,
        oldIndex: from,
        newIndex: to,
        tabListDirection: tabBarDirection,
        hierarchical: false,
        sortPinnedFirst: sortPinnedFirst,
      );
      if (result == null) {
        showCannotMove();
        return;
      }

      await tabData.reorderTabs(
        movingTabIds: result.movingTabIds,
        previousTabId: result.previousTabId,
        nextTabId: result.nextTabId,
        parentChange: result.parentChange,
      );
    }

    Future<void> handleDrop(int oldIndex, int newIndex) async {
      switch (resolveAccordionDrop(
        slots,
        oldIndex: oldIndex,
        newIndex: newIndex,
      )) {
        case null:
          showCannotMove();

        case final AccordionReorderDrop drop:
          if (drop.isNoop) return;
          await reorderWithin(drop.groupTabIds, drop.oldIndex, drop.newIndex);

        case final AccordionMoveDrop drop:
          final targetId = drop.targetContainerId;
          if (targetId == null) {
            await tabData.unassignContainer(drop.tabId);
          } else {
            ContainerDataWithCount? target;
            for (final container in containers) {
              if (container.id == targetId) {
                target = container;
                break;
              }
            }
            if (target == null) return;
            await tabData.assignContainer(drop.tabId, target);
          }

          // A move that keeps the Gecko context keeps the tab, and it can be
          // put where it was dropped. One that changes the context replaces
          // the tab with a new one, placed by the repository; the old row then
          // still names the old container, and there is nothing to position.
          final moved = await tabData.getTabDataById(drop.tabId);
          if (moved?.containerId != targetId) return;

          await reorderWithin(
            [...drop.groupTabIds, drop.tabId],
            drop.groupTabIds.length,
            drop.index,
          );
      }
    }

    // Keep the active chip (or expanded header fallback) centered when the
    // selection or ordering changes, unless the user is scrolling themselves.
    useScrollToActiveChip<String>(
      controller: scrollController,
      activeChipKey: activeChipKey.value,
      activeId: activeEntryId,
      orderedIds: [for (final entry in entries) entry.id],
      isUserScrolling: () => isUserScrolling.value,
    );

    if (entries.isEmpty) {
      // Hold the slot; the bar visibility is decided upstream by
      // quickTabSwitcherRowCountProvider.
      return isVertical
          ? SizedBox(width: railWidth)
          : const SizedBox(height: 48);
    }

    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        userScrollTimer.value?.cancel();
        isUserScrolling.value = true;
        userScrollTimer.value = Timer(const Duration(milliseconds: 1500), () {
          isUserScrolling.value = false;
        });
        return false;
      },
      child: Padding(
        padding: isVertical
            ? const EdgeInsets.symmetric(vertical: 4.0)
            : const EdgeInsets.symmetric(horizontal: 4.0),
        child: SizedBox(
          height: isVertical ? double.maxFinite : 48,
          width: isVertical ? railWidth : double.maxFinite,
          child: FadingScroll(
            controller: scrollController,
            fadingSize: 15,
            builder: (context, controller) {
              return ReorderableListView.builder(
                key: const PageStorageKey('quick_tab_switcher_accordion'),
                scrollController: controller,
                scrollDirection: axis,
                // Tabs carry their own hold-to-drag listener; headers carry
                // none, so they stay put while tabs move past them.
                buildDefaultDragHandles: false,
                scrollCacheExtent: const ScrollCacheExtent.pixels(500),
                itemCount: entries.length,
                onReorderItem: (oldIndex, newIndex) =>
                    unawaited(handleDrop(oldIndex, newIndex)),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final child = switch (entry) {
                    // Long-pressing a container header opens the same
                    // [ContainerMenu] as the container chip in the tab view.
                    // The unassigned pseudo-group gets the reduced variant:
                    // it has no container row to edit, pin or delete.
                    _AccordionHeaderEntry() => ContainerMenu(
                      container: entry.container,
                      scopeContainerId: entry.container?.id,
                      enableNewTab: true,
                      enablePin: entry.container != null,
                      enableAssignedSites: entry.container != null,
                      enableEdit: entry.container != null,
                      enableDelete: entry.container != null,
                      builder: (context, controller, _) => _AccordionHeaderChip(
                        entry: entry,
                        // The narrow rail can't fit the container title;
                        // show the container icon avatar + count badge only.
                        // A wide rail can.
                        showTitle: !isVertical || isWideRail,
                        fullWidth: isWideRail,
                        onSelected: () => toggleGroup(entry.container?.id),
                        onLongPress: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                      ),
                    ),
                    _AccordionTabEntry(:final item) => buildTabEntry(
                      item,
                      index,
                    ),
                  };

                  final slice = _TraySlice(
                    position: trayPositions[index],
                    fill: trayFills[index],
                    axis: axis,
                    fullWidth: isWideRail,
                    child: child,
                  );

                  // A reorderable list needs a stable key on the item itself,
                  // so the active entry's scroll-to key goes one level down.
                  return KeyedSubtree(
                    key: ValueKey(entry.id),
                    child: entry.id == activeEntryId
                        ? KeyedSubtree(key: activeChipKey.value, child: slice)
                        : slice,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

sealed class _AccordionEntry {
  const _AccordionEntry();

  factory _AccordionEntry.header({
    required ContainerDataWithCount? container,
    required int tabCount,
    required bool isExpanded,
  }) = _AccordionHeaderEntry;

  factory _AccordionEntry.tab(QuickTabSwitcherItem item) = _AccordionTabEntry;

  String get id;
}

/// A container group header chip; [container] is null for the pseudo-group
/// of tabs without a container.
class _AccordionHeaderEntry extends _AccordionEntry {
  final ContainerDataWithCount? container;
  final int tabCount;
  final bool isExpanded;

  const _AccordionHeaderEntry({
    required this.container,
    required this.tabCount,
    required this.isExpanded,
  });

  @override
  String get id => 'container-${container?.id}';
}

class _AccordionTabEntry extends _AccordionEntry {
  final QuickTabSwitcherItem item;

  const _AccordionTabEntry(this.item);

  @override
  String get id => 'tab-${item.id}';
}

/// Container group header, rendered as a solid container-colored box. The fill
/// is the same whether the container is selected (expanded) or not — selection
/// only adds the surrounding tray and the inline tabs, it never recolors the
/// header chip itself.
class _AccordionHeaderChip extends StatelessWidget {
  final _AccordionHeaderEntry entry;
  final VoidCallback onSelected;

  /// Opens the container's context menu.
  final VoidCallback? onLongPress;

  /// When false (e.g. the narrow vertical rail) the container title is hidden
  /// and only the icon avatar + count badge are shown, so the chip fits.
  final bool showTitle;

  /// Renders a full-width row for a side panel instead of a chip.
  final bool fullWidth;

  const _AccordionHeaderChip({
    required this.entry,
    required this.onSelected,
    this.onLongPress,
    this.showTitle = true,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final container = entry.container;

    // The header content sits on the container color, so it always uses the
    // on-container foreground.
    final Color fill;
    final Color nullForeground;
    final Color badgeBackground;
    final Color badgeForeground;

    if (container != null) {
      final palette = ContainerColors.palette(
        context,
        container.color,
        useCustomColor: container.metadata.useCustomColor,
      );
      fill = palette.containerColor;
      nullForeground = palette.onContainerColor;
      badgeBackground = palette.badgeBackgroundColor;
      badgeForeground = palette.badgeForegroundColor;
    } else {
      fill = scheme.surfaceContainerHigh;
      nullForeground = scheme.onSurfaceVariant;
      badgeBackground = scheme.secondaryContainer;
      badgeForeground = scheme.onSecondaryContainer;
    }

    final countBadge = entry.tabCount > 0
        ? InlineCountBadge(
            count: entry.tabCount,
            backgroundColor: badgeBackground,
            foregroundColor: badgeForeground,
          )
        : null;

    final iconAvatar = container != null
        ? buildContainerChipAvatar(context, container, true)
        : Icon(MdiIcons.folderHidden, color: nullForeground);

    // Same fill regardless of selection — the tray (added when expanded)
    // is what signals the active container, not a header recolor.
    final side = BorderSide(width: 2, color: fill);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
      side: side,
    );

    // FilterChip has no long-press of its own, so an outer InkWell claims the
    // gesture without interfering with the tap-to-select FilterChip beneath.
    Widget wrapLongPress(Widget chip) {
      if (onLongPress == null) {
        return chip;
      }
      return InkWell(
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8.0),
        child: chip,
      );
    }

    if (fullWidth) {
      return Material(
        color: fill,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onSelected,
          onLongPress: onLongPress,
          child: SizedBox(
            height: 44.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  if (iconAvatar != null) ...[
                    iconAvatar,
                    const SizedBox(width: 12.0),
                  ],
                  Expanded(
                    child: container != null
                        ? Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: buildContainerChipLabel(
                              context,
                              container,
                              true,
                              trailing: countBadge,
                            ),
                          )
                        : Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Unassigned',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: nullForeground),
                                ),
                              ),
                              if (countBadge != null) ...[
                                const SizedBox(width: 6.0),
                                countBadge,
                              ],
                            ],
                          ),
                  ),
                  Icon(
                    entry.isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: nullForeground,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!showTitle) {
      // Narrow rail: no room for the avatar slot + title + trailing badge side
      // by side (the badge gets clipped). Stack the container icon over the
      // count badge inside the label instead, dropping the avatar slot.
      return wrapLongPress(
        FilterChip(
          labelPadding: EdgeInsets.zero,
          label: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ?iconAvatar,
              if (countBadge != null) ...[
                if (iconAvatar != null) const SizedBox(height: 4),
                // Multi-digit counts can exceed the narrow rail's fixed 48px chip
                // width; scale the badge down to fit instead of overflowing.
                FittedBox(fit: BoxFit.scaleDown, child: countBadge),
              ],
            ],
          ),
          color: WidgetStatePropertyAll(fill),
          selected: false,
          showCheckmark: false,
          onSelected: (value) {
            if (value) {
              onSelected();
            }
          },
          side: side,
          shape: shape,
        ),
      );
    }

    return wrapLongPress(
      FilterChip(
        avatar: iconAvatar,
        label: container != null
            ? buildContainerChipLabel(
                context,
                container,
                true,
                trailing: countBadge,
              )
            : SizedBox(
                height: 20,
                child: Center(
                  child:
                      countBadge ??
                      DefaultTextStyle.merge(
                        style: TextStyle(color: nullForeground),
                        child: const SizedBox.shrink(),
                      ),
                ),
              ),
        color: WidgetStatePropertyAll(fill),
        selected: false,
        showCheckmark: false,
        onSelected: (value) {
          if (value) {
            onSelected();
          }
        },
        side: side,
        shape: shape,
      ),
    );
  }
}

/// Where a chip sits within the expanded container's tray, controlling which
/// rounded corners and edge padding its [_TraySlice] paints. [none] is a
/// standalone (collapsed) header that carries no tray.
enum _TrayPosition { none, solo, start, middle, end }

/// One slice of the shared tray behind an expanded group's chips. Adjacent
/// slices abut with matching height and seam padding so their fill merges into
/// a single continuous rounded, container-colored surface spanning the header
/// and its tabs.
class _TraySlice extends StatelessWidget {
  final _TrayPosition position;
  final Color fill;
  final Widget child;
  final Axis axis;

  /// Spans the side panel's width instead of hugging a 44dp chip column.
  final bool fullWidth;

  const _TraySlice({
    required this.position,
    required this.fill,
    required this.child,
    this.axis = Axis.horizontal,
    this.fullWidth = false,
  });

  /// Corner radius of the chips, matched by the tray so it hugs the first and
  /// last chip's edges exactly.
  static const Radius _radius = Radius.circular(8.0);

  @override
  Widget build(BuildContext context) {
    final isVertical = axis == Axis.vertical;

    if (isVertical && fullWidth) {
      // The panel's inset, shared with the toolbar-and-address block above the
      // list so the two line up; see [BrowserTabBar.panelInset].
      const inset = BrowserTabBar.panelInset;

      if (position == _TrayPosition.none) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(inset, 0.0, inset, 4.0),
          child: child,
        );
      }

      final isTrailingEdge =
          position == _TrayPosition.end || position == _TrayPosition.solo;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          inset,
          0.0,
          inset,
          isTrailingEdge ? 4.0 : 0.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: switch (position) {
              _TrayPosition.solo => const BorderRadius.all(_radius),
              _TrayPosition.start => const BorderRadius.vertical(top: _radius),
              _TrayPosition.end => const BorderRadius.vertical(bottom: _radius),
              _TrayPosition.middle || _TrayPosition.none => BorderRadius.zero,
            },
          ),
          padding: EdgeInsets.only(bottom: isTrailingEdge ? 4.0 : 0.0),
          child: child,
        ),
      );
    }

    if (position == _TrayPosition.none) {
      // Standalone container header: regular inter-chip spacing, centered
      // on the cross axis to line up with the tray slices.
      return Padding(
        padding: isVertical
            ? const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0)
            : const EdgeInsets.fromLTRB(0.0, 2.0, 8.0, 2.0),
        child: child,
      );
    }

    final borderRadius = switch ((position, isVertical)) {
      (_TrayPosition.solo, _) => const BorderRadius.all(_radius),
      (_TrayPosition.start, false) => const BorderRadius.horizontal(
        left: _radius,
      ),
      (_TrayPosition.end, false) => const BorderRadius.horizontal(
        right: _radius,
      ),
      (_TrayPosition.start, true) => const BorderRadius.vertical(top: _radius),
      (_TrayPosition.end, true) => const BorderRadius.vertical(bottom: _radius),
      (_TrayPosition.middle, _) || (_TrayPosition.none, _) => BorderRadius.zero,
    };

    final isTrailingEdge =
        position == _TrayPosition.end || position == _TrayPosition.solo;

    return Padding(
      // Transparent gap after the tray so a following standalone header
      // doesn't butt up against the rounded trailing edge.
      padding: isVertical
          ? EdgeInsets.only(
              left: 2.0,
              right: 2.0,
              bottom: isTrailingEdge ? 8.0 : 0.0,
            )
          : EdgeInsets.only(
              top: 2.0,
              bottom: 2.0,
              right: isTrailingEdge ? 8.0 : 0.0,
            ),
      child: SizedBox(
        height: isVertical ? null : 44.0,
        width: isVertical ? 44.0 : null,
        child: Container(
          decoration: BoxDecoration(color: fill, borderRadius: borderRadius),
          // A small inset so the first/last chip get the same breathing room
          // from the tray edge as the inter-chip seam gaps.
          padding: isVertical
              ? const EdgeInsets.symmetric(vertical: 4.0)
              : const EdgeInsets.symmetric(horizontal: 4.0),
          child: Center(child: child),
        ),
      ),
    );
  }
}
