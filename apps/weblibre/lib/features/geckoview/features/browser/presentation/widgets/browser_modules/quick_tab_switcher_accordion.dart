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
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/close_tab_helper.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/quick_tab_switcher_chip.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_chip_content.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/presentation/hooks/scroll_to_active_chip.dart';
import 'package:weblibre/presentation/widgets/inline_count_badge.dart';

/// Accordion stacking mode for the quick tab switcher bar: every available
/// container renders as a header chip and the selected container is
/// "expanded" — its tabs appear inline right after its header. Tapping
/// another header selects that container, collapsing the previous group.
class AccordionQuickTabSwitcher extends HookConsumerWidget {
  const AccordionQuickTabSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final activeChipKey = useRef(GlobalKey());
    final isUserScrolling = useRef(false);
    final userScrollTimer = useRef<Timer?>(null);

    useEffect(() {
      return userScrollTimer.value?.cancel;
    }, []);

    final showTitles = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherShowTitles,
      ),
    );
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
    final showCloseButtonOnAllTabs = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherShowCloseButtonOnAllTabs,
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

    final expandedTabStates = ref.watch(
      selectedContainerTabStatesWithContainerProvider,
    );
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
    final tabDepthById = ref
        .watch(
          groupedTabListItemsProvider(containerId: selectedContainerId).select((
            value,
          ) {
            return EquatableValue(<String, int>{
              if (hierarchyGlyphs > 0)
                for (final item in value.value)
                  if (item is TabListChildItem) item.tabId: item.depth,
            });
          }),
        )
        .value;

    final expandedItems = expandedTabStates.value
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

    final decoration = buildQuickTabSwitcherChipDecoration(
      context,
      showTitles: showTitles,
      hierarchyGlyphs: hierarchyGlyphs,
      // The tray is painted in the container color, so the active tab's normal
      // (transparent) selected border would blend in; give it a thicker border
      // in the container's outline color instead.
      thickContainerSelectedBorder: true,
    );

    Future<void> selectContainer(String? containerId) async {
      if (containerId != null) {
        await ref
            .read(selectedContainerProvider.notifier)
            .setContainerId(containerId);
      } else {
        ref.read(selectedContainerProvider.notifier).clearContainer();
      }
    }

    Widget buildTabChip(QuickTabSwitcherItem item) {
      final isSelected = item.isActive;
      final canClose =
          !item.isPlaceholder && (showCloseButtonOnAllTabs || item.isActive);

      final chip = QuickTabSwitcherChip(
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

      return wrapQuickTabSwitcherChipWithMenu(
        itemId: item.id,
        enabled: !item.isPlaceholder,
        enablePinTab: true,
        child: chip,
      );
    }

    final showUnassignedGroup =
        unassignedTabCount > 0 || selectedContainerId == null;

    final entries = <_AccordionEntry>[
      if (showUnassignedGroup)
        _AccordionEntry.header(
          container: null,
          tabCount: unassignedTabCount,
          isExpanded: selectedContainerId == null,
        ),
      if (selectedContainerId == null)
        ...expandedItems.map(_AccordionEntry.tab),
      for (final container in containers) ...[
        _AccordionEntry.header(
          container: container,
          tabCount: container.tabCount ?? 0,
          isExpanded: container.id == selectedContainerId,
        ),
        if (container.id == selectedContainerId)
          ...expandedItems.map(_AccordionEntry.tab),
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

    // The expanded group's tray is filled with the container's color so the
    // whole group reads as "this container". The unassigned group has no color
    // and falls back to a neutral surface.
    ContainerDataWithCount? expandedContainer;
    for (final container in containers) {
      if (container.id == selectedContainerId) {
        expandedContainer = container;
        break;
      }
    }
    final scheme = Theme.of(context).colorScheme;
    final trayPalette = expandedContainer != null
        ? ContainerColors.palette(
            context,
            expandedContainer.color,
            useCustomColor: expandedContainer.metadata.useCustomColor,
          )
        : null;
    final trayFill = trayPalette?.containerColor ?? scheme.surfaceContainerHigh;

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
      // Hold the 48px row slot; the bar visibility is decided upstream by
      // quickTabSwitcherRowCountProvider.
      return const SizedBox(height: 48);
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
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SizedBox(
          height: 48,
          width: double.maxFinite,
          child: FadingScroll(
            controller: scrollController,
            fadingSize: 15,
            builder: (context, controller) {
              return ListView.builder(
                key: const PageStorageKey('quick_tab_switcher_accordion'),
                controller: controller,
                scrollDirection: Axis.horizontal,
                scrollCacheExtent: const ScrollCacheExtent.pixels(500),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final child = switch (entry) {
                    _AccordionHeaderEntry() => _AccordionHeaderChip(
                      entry: entry,
                      onSelected: () => selectContainer(entry.container?.id),
                    ),
                    _AccordionTabEntry(:final item) => buildTabChip(item),
                  };

                  return KeyedSubtree(
                    key: entry.id == activeEntryId
                        ? activeChipKey.value
                        : ValueKey(entry.id),
                    child: _TraySlice(
                      position: trayPositions[index],
                      fill: trayFill,
                      child: child,
                    ),
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

  const _AccordionHeaderChip({required this.entry, required this.onSelected});

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

    return FilterChip(
      avatar: container != null
          ? buildContainerChipAvatar(context, container, true)
          : Icon(MdiIcons.folderHidden, color: nullForeground),
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
      // Same fill regardless of selection — the tray (added when expanded)
      // is what signals the active container, not a header recolor.
      color: WidgetStatePropertyAll(fill),
      selected: false,
      showCheckmark: false,
      onSelected: (value) {
        if (value) {
          onSelected();
        }
      },
      side: BorderSide(width: 2, color: fill),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(width: 2, color: fill),
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

  const _TraySlice({
    required this.position,
    required this.fill,
    required this.child,
  });

  /// Corner radius of the chips, matched by the tray so it hugs the first and
  /// last chip's edges exactly.
  static const Radius _radius = Radius.circular(8.0);

  @override
  Widget build(BuildContext context) {
    if (position == _TrayPosition.none) {
      // Standalone container header: regular inter-chip spacing, vertically
      // centered to line up with the tray slices.
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 2.0, 8.0, 2.0),
        child: child,
      );
    }

    final borderRadius = switch (position) {
      _TrayPosition.solo => const BorderRadius.all(_radius),
      _TrayPosition.start => const BorderRadius.horizontal(left: _radius),
      _TrayPosition.end => const BorderRadius.horizontal(right: _radius),
      _TrayPosition.middle || _TrayPosition.none => BorderRadius.zero,
    };

    final isRightEdge =
        position == _TrayPosition.end || position == _TrayPosition.solo;

    return Padding(
      padding: EdgeInsets.only(
        top: 2.0,
        bottom: 2.0,
        // Transparent gap after the tray so a following standalone header
        // doesn't butt up against the rounded right edge.
        right: isRightEdge ? 8.0 : 0.0,
      ),
      child: SizedBox(
        height: 44.0,
        child: Container(
          decoration: BoxDecoration(color: fill, borderRadius: borderRadius),
          // A small inset on every side so the first/last chip get the same
          // breathing room from the tray edge as the inter-chip seam gaps.
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Center(child: child),
        ),
      ),
    );
  }
}
