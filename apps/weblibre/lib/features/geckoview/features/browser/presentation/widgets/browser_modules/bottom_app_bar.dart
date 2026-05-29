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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/features/addons/presentation/widgets/pinned_addon_bar.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_id.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_bar_buttons.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_toolbar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/toolbar_visibility.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/tab_view_reorder.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/app_bar_title.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_icon.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_menu.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_context_menu_draggable.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_depth_indicator.dart';
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
import 'package:weblibre/presentation/widgets/selectable_chips.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class BrowserTopAppBar extends StatelessWidget {
  final bool showMainToolbar;
  final bool showContextualToolbar;
  final bool showQuickTabSwitcherBar;
  final bool isSmallWebMode;
  final bool enableGestures;

  late final BrowserTabBar _tabBar;
  late final _size = Size.fromHeight(_tabBar.getToolbarHeight());

  BrowserTopAppBar({
    super.key,
    required this.showMainToolbar,
    required this.showContextualToolbar,
    required this.showQuickTabSwitcherBar,
    required this.isSmallWebMode,
    this.enableGestures = true,
  }) {
    _tabBar = BrowserTabBar(
      showMainToolbar: showMainToolbar,
      displayedSheet: null,
      showContextualToolbar: false,
      showQuickTabSwitcherBar: false,
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
  final bool showQuickTabSwitcherBar;
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
    required this.showQuickTabSwitcherBar,
    required this.isSmallWebMode,
    this.enableGestures = true,
  }) {
    _tabBar = BrowserTabBar(
      displayedSheet: displayedSheet,
      showMainToolbar: showMainToolbar,
      showContextualToolbar: showContextualToolbar,
      showQuickTabSwitcherBar: showQuickTabSwitcherBar,
      isSmallWebMode: isSmallWebMode,
      enableGestures: enableGestures,
      hideMainToolbarButtonsDuplicatedInContextualToolbar:
          showContextualToolbar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      color: colorScheme.surfaceContainer,
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
  final bool showQuickTabSwitcherBar;
  final Sheet? displayedSheet;
  final bool hideMainToolbarButtonsDuplicatedInContextualToolbar;
  final bool isSmallWebMode;
  final bool enableGestures;

  const BrowserTabBar({
    super.key,
    required this.showMainToolbar,
    required this.displayedSheet,
    required this.showContextualToolbar,
    required this.showQuickTabSwitcherBar,
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
      showQuickTabSwitcherBar && displayedSheet is! ViewTabsSheet;

  double getToolbarHeight() {
    var height = 0.0;

    if (displayAppBar) {
      height += kToolbarHeight;
    }

    if (showContextualToolbar) {
      height += contextualToolabarHeight;
    }

    if (displayQuickTabSwitcher) {
      height += quickTabSwitcherHeight;
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

    final quickTabSwitcherMode = settings.effectiveUiQuickTabSwitcherMode();

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
      showQuickTabSwitcherBar: showQuickTabSwitcherBar,
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
      quickTabSwitcher: QuickTabSwitcher(
        quickTabSwitcherMode: quickTabSwitcherMode,
      ),
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
  ];
}

class QuickTabSwitcher extends HookConsumerWidget {
  final QuickTabSwitcherMode quickTabSwitcherMode;

  const QuickTabSwitcher({super.key, required this.quickTabSwitcherMode});

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
    final effectiveMode = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.effectiveUiQuickTabSwitcherMode(),
      ),
    );
    final tabBarDirection = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarDirection),
    );
    final tabStates = ref.watch(
      quickTabSwitcherTabStatesProvider(quickTabSwitcherMode),
    );
    final selectedTabId = ref.watch(selectedTabProvider);
    final historySuggestions = ref
        .watch(quickTabSwitcherHistorySuggestionsProvider(quickTabSwitcherMode))
        .value;
    final sandboxCaptureMap =
        ref.watch(sandboxCaptureMapProvider).value ?? const {};
    // Reorder is only meaningful when the bar renders the user's actual tab
    // order (containerTabs). Other modes (lastUsedTabs / MRU) sort by recency,
    // so dragging would just snap back on the next tab switch.
    final canManualReorder = ref.watch(canManualTabReorderProvider);
    final sortPinnedFirst = ref.watch(
      tabViewFilterControllerProvider.select((v) => v.sortPinnedFirst),
    );
    final showHierarchicalTabs = ref.watch(
      tabViewFilterControllerProvider.select((v) => v.showHierarchicalTabs),
    );
    final selectedContainerId = ref.watch(selectedContainerProvider);
    final hierarchyContainerId =
        effectiveMode == QuickTabSwitcherMode.containerTabs
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
    final reorderEnabled =
        effectiveMode == QuickTabSwitcherMode.containerTabs && canManualReorder;
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
          ),
        )
        .toList();
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
    final didRunInitialAutoScroll = useRef(false);
    final scrollKey = PageStorageKey(
      'quick_tab_switcher_${quickTabSwitcherMode.name}',
    );

    useEffect(() {
      return userScrollTimer.value?.cancel;
    }, []);

    useEffect(() {
      if (isUserScrolling.value) return null;

      final isInitialAutoScroll = !didRunInitialAutoScroll.value;
      didRunInitialAutoScroll.value = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isInitialAutoScroll &&
            chipScrollController.hasClients &&
            chipScrollController.offset != 0) {
          return;
        }

        final context = activeItemKey.value.currentContext;
        if (context != null) {
          unawaited(
            Scrollable.ensureVisible(
              context,
              alignment: 0.5,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            ),
          );
        } else if (chipScrollController.hasClients) {
          final activeIndex = availableItems.indexWhere(
            (item) => item.id == selectedTabId,
          );
          if (activeIndex < 0) return;

          final totalItems = availableItems.length;
          final maxExtent = chipScrollController.position.maxScrollExtent;
          if (totalItems > 0 && maxExtent > 0) {
            chipScrollController.jumpTo(
              (activeIndex / totalItems * maxExtent).clamp(0.0, maxExtent),
            );

            WidgetsBinding.instance.addPostFrameCallback((_) {
              final retryContext = activeItemKey.value.currentContext;
              if (retryContext != null) {
                unawaited(
                  Scrollable.ensureVisible(
                    retryContext,
                    alignment: 0.5,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  ),
                );
              }
            });
          }
        }
      });

      return null;
    }, [selectedTabId]);

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
        enablePinTabInMenu: effectiveMode == QuickTabSwitcherMode.containerTabs,
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
    required this.enablePinTabInMenu,
    required this.onSelected,
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
  final bool enablePinTabInMenu;
  final Future<void> Function(QuickTabSwitcherItem item) onSelected;

  /// When non-null, the first [reorderableItemCount] items are rendered as a
  /// horizontal `ReorderableListView` driven by this callback. Otherwise the
  /// view falls back to the non-reorderable `SelectableChips` layout.
  final void Function(int oldIndex, int newIndex)? onReorderItem;

  /// Items at indices `< reorderableItemCount` are reorderable; items at
  /// or after are appended as a static trailing row (e.g. history hints).
  final int reorderableItemCount;

  bool get _reorderEnabled => onReorderItem != null && reorderableItemCount > 0;

  @override
  Widget build(BuildContext context) {
    if (availableItems.isEmpty) {
      return const SizedBox.shrink();
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
      enableDelete: false,
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
      itemWrap: (child, item) =>
          item.isHistory ? child : _wrapWithMenu(itemId: item.id, child: child),
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
        final chip = _ReorderableSwitcherChip(
          item: item,
          isSelected: isSelected,
          showTitles: showTitles,
          showIsolatedTabUi: showIsolatedTabUi,
          selectedBorderColor: Theme.of(context).colorScheme.primary,
          decoration: _chipDecoration(context),
          label: _chipLabel(context, item, isSelected),
          onTap: () => onSelected(item),
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

  Widget _wrapWithMenu({required String itemId, required Widget child}) {
    return TabMenu(
      selectedTabId: itemId,
      enableFindInPage: false,
      enableFetchFeeds: false,
      enableDesktopMode: false,
      enableReaderMode: false,
      enableReloadButton: false,
      enableNavigationButtons: false,
      enableAddToHomeScreen: false,
      enablePinTab: enablePinTabInMenu,
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

  SelectableChipDecoration<QuickTabSwitcherItem> _chipDecoration(
    BuildContext context,
  ) {
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
        final color? when isSelected => ContainerColors.palette(
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
              item.depth == 0 &&
              item.tabMode is! PrivateTabMode &&
              item.tabMode is! IsolatedTabMode)
          ? EdgeInsets.zero
          : null,
    );
  }

  Widget _chipLabel(
    BuildContext context,
    QuickTabSwitcherItem item,
    bool isSelected,
  ) {
    final appColors = AppColors.of(context);
    final hasTitle = item.isHistory || showTitles;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.depth > 0)
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: TabDepthIndicator(
              depth: item.depth,
              height: 24.0,
              iconSize: 14.0,
              horizontalPadding: 4.0,
            ),
          ),
        Padding(
          padding: EdgeInsets.only(right: hasTitle ? 6.0 : 0.0),
          child: item.avatar,
        ),
        if (hasTitle)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 64),
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
}

/// FilterChip matching `SelectableChips`' visual contract, used in the
/// reorderable render path. Stateless wrapper so the parent
/// `ReorderableListView` can attach its drag-handle gesture recognizer.
class _ReorderableSwitcherChip extends StatelessWidget {
  final QuickTabSwitcherItem item;
  final bool isSelected;
  final bool showTitles;
  final bool showIsolatedTabUi;
  final Color selectedBorderColor;
  final SelectableChipDecoration<QuickTabSwitcherItem> decoration;
  final Widget label;
  final Future<void> Function() onTap;

  const _ReorderableSwitcherChip({
    required this.item,
    required this.isSelected,
    required this.showTitles,
    required this.showIsolatedTabUi,
    required this.selectedBorderColor,
    required this.decoration,
    required this.label,
    required this.onTap,
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
      padding: const EdgeInsets.only(right: 8.0, top: 4.0),
      child: FilterChip(
        color: itemColor != null ? WidgetStatePropertyAll(itemColor) : null,
        selected: false,
        showCheckmark: false,
        labelPadding: labelPadding,
        onSelected: (_) {
          unawaited(onTap());
        },
        label: label,
        side: side,
      ),
    );
  }
}
