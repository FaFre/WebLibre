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
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/addons/presentation/widgets/pinned_addon_bar.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/providers/restore_complete.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_id.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_bar_buttons.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_toolbar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/toolbar_visibility.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/close_tab_helper.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/tab_view_reorder.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/app_bar_title.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/quick_tab_switcher_accordion.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/quick_tab_switcher_chip.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_context_menu_draggable.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_view_item.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/toolbar_button.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/widgets/reader_button.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/presentation/hooks/scroll_to_active_chip.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

export 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/quick_tab_switcher_chip.dart'
    show QuickTabSwitcherItem;

class BrowserTopAppBar extends StatelessWidget {
  final bool showMainToolbar;
  final bool showContextualToolbar;
  final int quickTabSwitcherRowCount;
  final bool isSmallWebMode;
  final bool enableGestures;

  late final BrowserTabBar _tabBar;
  late final _size = Size.fromHeight(_tabBar.getToolbarHeight());

  BrowserTopAppBar({
    super.key,
    required this.showMainToolbar,
    required this.showContextualToolbar,
    required this.quickTabSwitcherRowCount,
    required this.isSmallWebMode,
    this.enableGestures = true,
  }) {
    _tabBar = BrowserTabBar(
      showMainToolbar: showMainToolbar,
      displayedSheet: null,
      showContextualToolbar: false,
      quickTabSwitcherRowCount: 0,
      isSmallWebMode: isSmallWebMode,
      enableGestures: enableGestures,
      hideMainToolbarButtonsDuplicatedInContextualToolbar:
          showContextualToolbar,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(height: preferredSize.height, child: _tabBar),
    );
  }

  Size get preferredSize => _size;
}

class BrowserBottomAppBar extends StatelessWidget {
  final bool showMainToolbar;
  final bool showContextualToolbar;
  final int quickTabSwitcherRowCount;
  final bool isSmallWebMode;
  final Sheet? displayedSheet;
  final bool enableGestures;

  late final BrowserTabBar _tabBar;
  late final _size = Size.fromHeight(_tabBar.getToolbarHeight());

  BrowserBottomAppBar({
    super.key,
    required this.showMainToolbar,
    required this.displayedSheet,
    required this.showContextualToolbar,
    required this.quickTabSwitcherRowCount,
    required this.isSmallWebMode,
    this.enableGestures = true,
  }) {
    _tabBar = BrowserTabBar(
      displayedSheet: displayedSheet,
      showMainToolbar: showMainToolbar,
      showContextualToolbar: showContextualToolbar,
      quickTabSwitcherRowCount: quickTabSwitcherRowCount,
      isSmallWebMode: isSmallWebMode,
      enableGestures: enableGestures,
      hideMainToolbarButtonsDuplicatedInContextualToolbar:
          showContextualToolbar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Material(
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      // Transparent so the navigation-bar inset region behind this padding is
      // filled by the BrowserSystemBars tint strip (matching the active
      // container color), instead of a fixed surfaceContainer fill.
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SizedBox(height: _size.height, child: _tabBar),
      ),
    );
  }

  Size get preferredSize => _size;
}

class BrowserTabBar extends HookConsumerWidget {
  final bool showMainToolbar;
  final bool showContextualToolbar;
  final int quickTabSwitcherRowCount;
  final Sheet? displayedSheet;
  final bool hideMainToolbarButtonsDuplicatedInContextualToolbar;
  final bool isSmallWebMode;
  final bool enableGestures;

  const BrowserTabBar({
    super.key,
    required this.showMainToolbar,
    required this.displayedSheet,
    required this.showContextualToolbar,
    required this.quickTabSwitcherRowCount,
    required this.isSmallWebMode,
    required this.enableGestures,
    this.hideMainToolbarButtonsDuplicatedInContextualToolbar = false,
  });

  static const contextualToolabarHeight = 54.0;
  static const quickTabSwitcherHeight = 48.0;

  bool get displayAppBar =>
      showMainToolbar &&
      (!showContextualToolbar || displayedSheet is! ViewTabsSheet);

  bool get displayQuickTabSwitcher =>
      quickTabSwitcherRowCount > 0 && displayedSheet is! ViewTabsSheet;

  double getToolbarHeight() {
    var height = 0.0;

    if (displayAppBar) {
      height += kToolbarHeight;
    }

    if (showContextualToolbar) {
      height += contextualToolabarHeight;
    }

    if (displayQuickTabSwitcher) {
      height += quickTabSwitcherHeight * quickTabSwitcherRowCount;
    }

    return height;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTabId = ref.watch(selectedTabProvider);
    final settings = ref.watch(generalSettingsWithDefaultsProvider);

    // Determine which buttons are actually visible in the contextual toolbar
    // so we only hide them from the main toolbar when they're genuinely present there.
    final contextualConfigs = ref
        .watch(effectiveToolbarButtonConfigsProvider)
        .value;

    final tabsCountInContextual =
        hideMainToolbarButtonsDuplicatedInContextualToolbar &&
        contextualConfigs.any(
          (c) => c.buttonId == ToolbarButtonId.tabsCount.name && c.isVisible,
        );

    final menuInContextual =
        hideMainToolbarButtonsDuplicatedInContextualToolbar &&
        contextualConfigs.any(
          (c) =>
              c.buttonId == ToolbarButtonId.navigationMenu.name && c.isVisible,
        );

    final showMainToolbarTabsCount = !isSmallWebMode && !tabsCountInContextual;
    final showMainToolbarNavigationButton =
        !isSmallWebMode && !menuInContextual;

    final containerColor = ref.watch(
      watchTabContainerDataProvider(
        selectedTabId,
      ).select((data) => data.value?.color),
    );
    final containerUseCustomColor = ref.watch(
      watchTabContainerDataProvider(
        selectedTabId,
      ).select((data) => data.value?.metadata.useCustomColor ?? false),
    );

    final stackingMode = settings.effectiveTabBarStackingMode();

    final tabBarPosition = settings.tabBarPosition;

    final dragStartPosition = useRef(Offset.zero);

    final showTabTitle = displayedSheet is! ViewTabsSheet;

    final effectiveContainerColor =
        (settings.showContainerUi &&
            containerColor != null &&
            displayedSheet is! ViewTabsSheet)
        ? containerColor
        : null;
    final effectiveUseCustomColor =
        effectiveContainerColor != null && containerUseCustomColor;
    final effectiveContainerPalette = effectiveContainerColor != null
        ? ContainerColors.palette(
            context,
            effectiveContainerColor,
            useCustomColor: effectiveUseCustomColor,
          )
        : null;

    return BrowserTabBarView(
      showMainToolbar: showMainToolbar,
      showContextualToolbar: showContextualToolbar,
      showQuickTabSwitcherBar: quickTabSwitcherRowCount > 0,
      displayAppBar: displayAppBar,
      displayQuickTabSwitcher: displayQuickTabSwitcher,
      backgroundColor: effectiveContainerPalette?.surfaceColor,
      title: showTabTitle
          ? settings.tabBarLayout == TabBarLayout.compact
                ? CompactAppBarTitle(
                    containerColor: effectiveContainerColor,
                    useCustomColor: effectiveUseCustomColor,
                  )
                : AppBarTitle(
                    containerColor: effectiveContainerColor,
                    useCustomColor: effectiveUseCustomColor,
                  )
          : null,
      actions: [
        const PinnedAddonBar(),
        if (isSmallWebMode)
          ReaderButton(
            buttonBuilder: (isLoading, readerActive, icon) => ToolbarButton(
              onTap: isLoading
                  ? null
                  : () async {
                      await ref
                          .read(readerableScreenControllerProvider.notifier)
                          .toggleReaderView(!readerActive);
                    },
              child: icon,
            ),
          ),
        if (showMainToolbarTabsCount)
          TabsCountButton(
            selectedTabId: selectedTabId,
            displayedSheet: displayedSheet,
            showLongPressMenu: true,
          ),
        if (showMainToolbarNavigationButton)
          NavigationMenuButton(selectedTabId: selectedTabId),
      ],
      quickTabSwitcher: switch (stackingMode) {
        TabBarStackingMode.disabled => const SizedBox.shrink(),
        TabBarStackingMode.lastUsedTabs => const QuickTabSwitcher(
          quickTabSwitcherMode: QuickTabSwitcherMode.lastUsedTabs,
        ),
        TabBarStackingMode.containerTabs => const QuickTabSwitcher(
          quickTabSwitcherMode: QuickTabSwitcherMode.containerTabs,
        ),
        TabBarStackingMode.accordion => const AccordionQuickTabSwitcher(),
        // History fallback only on the MRU row, so empty-state history
        // chips don't show twice.
        TabBarStackingMode.twoLevel => const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuickTabSwitcher(
              quickTabSwitcherMode: QuickTabSwitcherMode.containerTabs,
              enableHistoryFallback: false,
            ),
            QuickTabSwitcher(
              quickTabSwitcherMode: QuickTabSwitcherMode.lastUsedTabs,
            ),
          ],
        ),
      },
      contextualToolbar: ContextualToolbar(
        selectedTabId: selectedTabId,
        displayedSheet: displayedSheet,
      ),
      onHorizontalDragStart: !enableGestures
          ? null
          : (details) {
              dragStartPosition.value = details.globalPosition;
            },
      onHorizontalDragEnd: !enableGestures
          ? null
          : (details) async {
              final distance = dragStartPosition.value - details.globalPosition;

              if (distance.dx.abs() > 50 && distance.dy.abs() < 20) {
                final selectedTab = ref.read(selectedTabProvider);
                final setting = await ref
                    .read(generalSettingsRepositoryProvider.notifier)
                    .fetchSettings();

                if (selectedTab != null) {
                  switch (setting.tabBarSwipeAction) {
                    case TabBarSwipeAction.switchLastOpened:
                      await ref
                          .read(tabRepositoryProvider.notifier)
                          .selectPreviouslyOpenedTab(selectedTab);
                    case TabBarSwipeAction.navigateOrderedTabs:
                      if (distance.dx < 0) {
                        await ref
                            .read(tabRepositoryProvider.notifier)
                            .selectPreviousTab(selectedTab);
                      } else {
                        await ref
                            .read(tabRepositoryProvider.notifier)
                            .selectNextTab(selectedTab);
                      }
                  }
                }
              }
            },
      onVerticalDragStart: !enableGestures
          ? null
          : (details) {
              dragStartPosition.value = details.globalPosition;
            },
      onVerticalDragEnd: !enableGestures
          ? null
          : (details) {
              final distance = dragStartPosition.value - details.globalPosition;

              // Swipe direction for dismiss depends on toolbar position:
              // - Bottom bar: swipe down to dismiss (positive distance.dy)
              // - Top bar: swipe up to dismiss (negative distance.dy)
              const dismissThreshold = kToolbarHeight * 0.5;
              final shouldDismiss = switch (tabBarPosition) {
                TabBarPosition.bottom =>
                  distance.dy.isNegative &&
                      distance.dy.abs() > dismissThreshold,
                TabBarPosition.top =>
                  !distance.dy.isNegative &&
                      distance.dy.abs() > dismissThreshold,
              };
              if (shouldDismiss &&
                  ref.read(bottomSheetControllerProvider) == null) {
                unawaited(HapticFeedback.lightImpact());
                ref
                    .read(
                      toolbarVisibilityControllerProvider(
                        selectedTabId,
                      ).notifier,
                    )
                    .dismiss();
              }
            },
    );
  }
}

class BrowserTabBarView extends StatelessWidget {
  const BrowserTabBarView({
    super.key,
    required this.showMainToolbar,
    required this.showContextualToolbar,
    required this.showQuickTabSwitcherBar,
    required this.displayAppBar,
    required this.displayQuickTabSwitcher,
    required this.backgroundColor,
    required this.title,
    required this.actions,
    required this.quickTabSwitcher,
    required this.contextualToolbar,
    this.onHorizontalDragStart,
    this.onHorizontalDragEnd,
    this.onVerticalDragStart,
    this.onVerticalDragEnd,
  });

  final bool showMainToolbar;
  final bool showContextualToolbar;
  final bool showQuickTabSwitcherBar;
  final bool displayAppBar;
  final bool displayQuickTabSwitcher;
  final Color? backgroundColor;
  final Widget? title;
  final List<Widget> actions;
  final Widget quickTabSwitcher;
  final Widget contextualToolbar;
  final GestureDragStartCallback? onHorizontalDragStart;
  final GestureDragEndCallback? onHorizontalDragEnd;
  final GestureDragStartCallback? onVerticalDragStart;
  final GestureDragEndCallback? onVerticalDragEnd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.surfaceContainer;

    return GestureDetector(
      // Tap handling moved to AppBarTitle for split icon/title behavior
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragEnd: onHorizontalDragEnd,
      onVerticalDragStart: onVerticalDragStart,
      onVerticalDragEnd: onVerticalDragEnd,
      child: ColoredBox(
        color: effectiveBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showQuickTabSwitcherBar)
              Visibility(
                visible: displayQuickTabSwitcher,
                maintainState: true,
                child: quickTabSwitcher,
              ),
            if (showMainToolbar)
              Visibility(
                visible: displayAppBar,
                maintainState: true,
                child: AppBar(
                  primary: false,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  scrolledUnderElevation: 0,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  titleSpacing: 0.0,
                  leadingWidth: 40.0,
                  toolbarHeight: kToolbarHeight,
                  title: title,
                  actions: actions,
                ),
              ),
            if (showContextualToolbar) contextualToolbar,
          ],
        ),
      ),
    );
  }
}

class QuickTabSwitcher extends HookConsumerWidget {
  final QuickTabSwitcherMode quickTabSwitcherMode;

  /// Whether the row falls back to history suggestion chips when it has no
  /// open tabs. Disabled for the top row in two-level stacking so history
  /// chips don't show twice.
  final bool enableHistoryFallback;

  const QuickTabSwitcher({
    super.key,
    required this.quickTabSwitcherMode,
    this.enableHistoryFallback = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showIsolatedTabUi = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.showIsolatedTabUi),
    );
    final showTitles = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherShowTitles,
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
    final tabBarDirection = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarDirection),
    );
    final tabStates = ref.watch(
      quickTabSwitcherTabStatesProvider(quickTabSwitcherMode),
    );
    final selectedTabId = ref.watch(selectedTabProvider);
    final historySuggestions = enableHistoryFallback
        ? ref
              .watch(
                quickTabSwitcherHistorySuggestionsProvider(
                  quickTabSwitcherMode,
                ),
              )
              .value
        : null;
    final sandboxCaptureMap =
        ref.watch(sandboxCaptureMapProvider).value ?? const {};
    // Reorder is only meaningful when the bar renders the user's actual tab
    // order (containerTabs). Other modes (lastUsedTabs / MRU) sort by recency,
    // so dragging would just snap back on the next tab switch.
    final canManualReorder = ref.watch(canManualTabReorderProvider);
    final sortPinnedFirst = ref.watch(
      tabViewFilterControllerProvider.select((v) => v.sortPinnedFirst),
    );
    final hierarchyGlyphs = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherHierarchyGlyphs,
      ),
    );
    final showHierarchicalTabs = hierarchyGlyphs > 0;
    final selectedContainerId = ref.watch(selectedContainerProvider);
    final hierarchyContainerId =
        quickTabSwitcherMode == QuickTabSwitcherMode.containerTabs
        ? selectedContainerId
        : null;

    final tabDepthById = ref
        .watch(
          groupedTabListItemsProvider(containerId: hierarchyContainerId).select(
            (value) {
              return EquatableValue(<String, int>{
                if (showHierarchicalTabs)
                  for (final item in value.value)
                    if (item is TabListChildItem) item.tabId: item.depth,
              });
            },
          ),
        )
        .value;

    final pinnedTabIds = ref.watch(
      watchPinnedTabIdsProvider.select(
        (value) => value.value ?? const <String>{},
      ),
    );
    final restoreComplete = ref.watch(browserRestoreCompleteProvider);
    final nativeTabIds = ref
        .watch(
          tabStatesProvider.select(
            (states) => EquatableValue(states.keys.toSet()),
          ),
        )
        .value;
    final tabItems = tabStates.value
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
    // Reorder is disabled while placeholders are present: the engine doesn't
    // know those tabs yet, so a reorder couldn't be applied consistently.
    final reorderEnabled =
        quickTabSwitcherMode == QuickTabSwitcherMode.containerTabs &&
        canManualReorder &&
        !tabItems.any((item) => item.isPlaceholder);
    final historyItems = (historySuggestions ?? [])
        .map(
          (visit) =>
              QuickTabSwitcherItem.history(url: visit.url, title: visit.title),
        )
        .toList();
    final availableItems = [...tabItems, ...historyItems];

    final activeItem = availableItems.isEmpty
        ? null
        : availableItems.firstWhere(
            (item) => item.isActive,
            orElse: () => availableItems.first,
          );

    final chipScrollController = useScrollController();
    final activeItemKey = useRef(GlobalKey());
    final isUserScrolling = useRef(false);
    final userScrollTimer = useRef<Timer?>(null);
    final scrollKey = PageStorageKey(
      'quick_tab_switcher_${quickTabSwitcherMode.name}',
    );

    useEffect(() {
      return userScrollTimer.value?.cancel;
    }, []);

    // Keep the active chip centered when the selection or ordering changes,
    // even if it is far outside the lazily-built range.
    useScrollToActiveChip<String>(
      controller: chipScrollController,
      activeChipKey: activeItemKey.value,
      activeId: (activeItem?.isActive ?? false) ? activeItem?.id : null,
      orderedIds: [for (final item in availableItems) item.id],
      isUserScrolling: () => isUserScrolling.value,
    );

    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        if (notification.direction != ScrollDirection.idle) {
          isUserScrolling.value = true;
          userScrollTimer.value?.cancel();
          userScrollTimer.value = Timer(const Duration(milliseconds: 1500), () {
            isUserScrolling.value = false;
          });
        } else {
          userScrollTimer.value?.cancel();
          userScrollTimer.value = Timer(const Duration(milliseconds: 1500), () {
            isUserScrolling.value = false;
          });
        }

        return false;
      },
      child: QuickTabSwitcherView(
        availableItems: availableItems,
        reorderableItemCount: reorderEnabled ? tabItems.length : 0,
        activeItem: (activeItem?.isActive ?? false) ? activeItem : null,
        scrollController: chipScrollController,
        scrollKey: scrollKey,
        activeItemKey: activeItemKey.value,
        showTitles: showTitles,
        showIsolatedTabUi: showIsolatedTabUi,
        hierarchyGlyphs: hierarchyGlyphs,
        titleMaxWidth: titleMaxWidth,
        showCloseButtonOnAllTabs: showCloseButtonOnAllTabs,
        enablePinTabInMenu:
            quickTabSwitcherMode == QuickTabSwitcherMode.containerTabs,
        onCloseItem: (item) =>
            closeTabWithConfirmationAndUndo(context, ref, item.id),
        onSelected: (item) async {
          if (!item.isHistory && item.isActive) {
            return;
          }
          if (item.isHistory) {
            await ref
                .read(tabRepositoryProvider.notifier)
                .addTab(
                  url: item.url,
                  tabMode: TabMode.regular,
                  selectTab: true,
                );
          } else {
            await ref.read(tabRepositoryProvider.notifier).selectTab(item.id);
          }
        },
        onReorderItem: !reorderEnabled
            ? null
            : (oldIndex, newIndex) async {
                if (oldIndex >= tabItems.length || newIndex > tabItems.length) {
                  return;
                }
                final visibleItems = [
                  for (final item in tabItems)
                    TabViewItem.standalone(tabId: item.id),
                ];
                final result = buildTabViewReorderResult(
                  visibleItems: visibleItems,
                  treeRows: const [],
                  collapsedGroups: const {},
                  pinnedTabIds: pinnedTabIds,
                  oldIndex: oldIndex,
                  newIndex: newIndex,
                  tabListDirection: tabBarDirection,
                  hierarchical: false,
                  sortPinnedFirst: sortPinnedFirst,
                );
                if (result == null) {
                  if (context.mounted) {
                    ui_helper.showInfoMessage(
                      context,
                      'Tab cannot be moved here',
                    );
                  }
                  return;
                }
                await ref
                    .read(tabDataRepositoryProvider.notifier)
                    .reorderTabs(
                      movingTabIds: result.movingTabIds,
                      previousTabId: result.previousTabId,
                      nextTabId: result.nextTabId,
                      parentChange: result.parentChange,
                    );
              },
      ),
    );
  }
}

class QuickTabSwitcherView extends StatelessWidget {
  const QuickTabSwitcherView({
    super.key,
    required this.availableItems,
    required this.activeItem,
    required this.scrollController,
    this.scrollKey,
    this.activeItemKey,
    required this.showTitles,
    required this.showIsolatedTabUi,
    this.hierarchyGlyphs = defaultQuickTabSwitcherHierarchyGlyphs,
    this.titleMaxWidth = defaultQuickTabSwitcherTitleWidth,
    this.showCloseButtonOnAllTabs = false,
    required this.enablePinTabInMenu,
    required this.onSelected,
    this.onCloseItem,
    this.onReorderItem,
    this.reorderableItemCount = 0,
  });

  final List<QuickTabSwitcherItem> availableItems;
  final QuickTabSwitcherItem? activeItem;
  final ScrollController scrollController;
  final Key? scrollKey;
  final GlobalKey? activeItemKey;
  final bool showTitles;
  final bool showIsolatedTabUi;

  /// Max inline chevron glyphs on a chip's depth indicator before collapsing
  /// into an icon + count badge. A value of 0 hides the indicator entirely.
  final int hierarchyGlyphs;

  /// Max width of a chip's title text.
  final double titleMaxWidth;

  /// Whether every tab chip shows a close button. The active tab's chip
  /// always shows one when [onCloseItem] is set.
  final bool showCloseButtonOnAllTabs;

  final bool enablePinTabInMenu;
  final Future<void> Function(QuickTabSwitcherItem item) onSelected;

  /// Close handler backing the chips' close buttons. When null no close
  /// buttons are shown at all.
  final Future<void> Function(QuickTabSwitcherItem item)? onCloseItem;

  /// When non-null, the first [reorderableItemCount] items are rendered as a
  /// horizontal `ReorderableListView` driven by this callback. Otherwise the
  /// view falls back to the non-reorderable `SelectableChips` layout.
  final void Function(int oldIndex, int newIndex)? onReorderItem;

  /// Items at indices `< reorderableItemCount` are reorderable; items at
  /// or after are appended as a static trailing row (e.g. history hints).
  final int reorderableItemCount;

  bool get _reorderEnabled => onReorderItem != null && reorderableItemCount > 0;

  /// Whether [item]'s chip shows a close button.
  bool _canShowCloseButton(QuickTabSwitcherItem item) =>
      onCloseItem != null &&
      !item.isHistory &&
      !item.isPlaceholder &&
      (showCloseButtonOnAllTabs || item.isActive);

  @override
  Widget build(BuildContext context) {
    if (availableItems.isEmpty) {
      // Hold the 48px row slot: in two-level stacking an empty row must not
      // collapse, since the toolbar height already accounts for both rows.
      return const SizedBox(height: 48);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: SizedBox(
        height: 48,
        width: double.maxFinite,
        child: _reorderEnabled
            ? _buildReorderableList(context)
            : _buildSelectableChips(context),
      ),
    );
  }

  Widget _buildSelectableChips(BuildContext context) {
    return SelectableChips<QuickTabSwitcherItem, QuickTabSwitcherItem, String>(
      enableDelete: onCloseItem != null,
      sortSelectedFirst: false,
      maxCount: null,
      scrollController: scrollController,
      scrollKey: scrollKey,
      activeItemKey: activeItemKey,
      cacheExtent: 500,
      itemId: (item) => item.id,
      selectedItem: activeItem,
      selectedBorderColor: Theme.of(context).colorScheme.primary,
      decoration: _chipDecoration(context),
      itemLabel: (item) => _chipLabel(context, item, activeItem?.id == item.id),
      onSelected: onSelected,
      onDeleted: (item) {
        unawaited(onCloseItem?.call(item));
      },
      itemWrap: (child, item) =>
          item.isHistory ? child : _wrapWithMenu(item: item, child: child),
      availableItems: availableItems,
    );
  }

  Widget _buildReorderableList(BuildContext context) {
    // History suggestions only appear when there are no tab items
    // (see quickTabSwitcherHistorySuggestionsProvider), so reorder mode
    // is mutually exclusive with the history trailing row in practice.
    // Defensively cap the reorderable range anyway.
    final reorderableCount = reorderableItemCount.clamp(
      0,
      availableItems.length,
    );

    return ReorderableListView.builder(
      key: scrollKey,
      scrollController: scrollController,
      scrollDirection: Axis.horizontal,
      buildDefaultDragHandles: true,
      scrollCacheExtent: const ScrollCacheExtent.pixels(500),
      itemCount: reorderableCount,
      itemBuilder: (context, index) {
        final item = availableItems[index];
        final isSelected = activeItem?.id == item.id;
        final chip = QuickTabSwitcherChip(
          item: item,
          isSelected: isSelected,
          selectedBorderColor: Theme.of(context).colorScheme.primary,
          decoration: _chipDecoration(context),
          label: _chipLabel(context, item, isSelected),
          onTap: () => onSelected(item),
          onDelete: _canShowCloseButton(item) ? () => onCloseItem!(item) : null,
        );
        final keyedForActive = isSelected && activeItemKey != null
            ? KeyedSubtree(key: activeItemKey, child: chip)
            : chip;
        return KeyedSubtree(
          key: ValueKey(item.id),
          child: TabContextMenuDraggable(
            tabId: item.id,
            externalDrag: true,
            enableCloseTab: true,
            feedbackSize: Size.zero,
            child: keyedForActive,
          ),
        );
      },
      onReorderItem: onReorderItem,
    );
  }

  Widget _wrapWithMenu({
    required QuickTabSwitcherItem item,
    required Widget child,
  }) {
    return wrapQuickTabSwitcherChipWithMenu(
      itemId: item.id,
      enabled: !item.isPlaceholder,
      enablePinTab: enablePinTabInMenu,
      child: child,
    );
  }

  SelectableChipDecoration<QuickTabSwitcherItem> _chipDecoration(
    BuildContext context,
  ) {
    return buildQuickTabSwitcherChipDecoration(
      context,
      showTitles: showTitles,
      hierarchyGlyphs: hierarchyGlyphs,
      canDelete: _canShowCloseButton,
    );
  }

  Widget _chipLabel(
    BuildContext context,
    QuickTabSwitcherItem item,
    bool isSelected,
  ) {
    return buildQuickTabSwitcherChipLabel(
      context,
      item,
      isSelected: isSelected,
      showTitles: showTitles,
      showIsolatedTabUi: showIsolatedTabUi,
      hierarchyGlyphs: hierarchyGlyphs,
      titleMaxWidth: titleMaxWidth,
    );
  }
}
