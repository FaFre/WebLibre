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
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_id.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_bar_buttons.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_toolbar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/toolbar_visibility.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/app_bar_title.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_icon.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_menu.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/toolbar_button.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/widgets/reader_button.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

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

    final quickTabSwitcherMode = settings.effectiveUiQuickTabSwitcherMode();

    final tabBarPosition = settings.tabBarPosition;

    final dragStartPosition = useRef(Offset.zero);

    final showTabTitle = displayedSheet is! ViewTabsSheet;

    final backgroundColor =
        (settings.showContainerUi &&
            containerColor != null &&
            displayedSheet is! ViewTabsSheet)
        ? ContainerColors.forAppBar(containerColor)
        : null;

    return BrowserTabBarView(
      showMainToolbar: showMainToolbar,
      showContextualToolbar: showContextualToolbar,
      showQuickTabSwitcherBar: showQuickTabSwitcherBar,
      displayAppBar: displayAppBar,
      displayQuickTabSwitcher: displayQuickTabSwitcher,
      backgroundColor: backgroundColor,
      title: showTabTitle
          ? settings.tabBarLayout == TabBarLayout.compact
                ? const CompactAppBarTitle()
                : const AppBarTitle()
          : null,
      actions: [
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

    return GestureDetector(
      // Tap handling moved to AppBarTitle for split icon/title behavior
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragEnd: onHorizontalDragEnd,
      onVerticalDragStart: onVerticalDragStart,
      onVerticalDragEnd: onVerticalDragEnd,
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
                backgroundColor:
                    backgroundColor ?? colorScheme.surfaceContainer,
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
    );
  }
}

class QuickTabSwitcherItem with FastEquatable {
  final Color? color;
  final String id;
  final bool isActive;
  final TabMode tabMode;
  final bool isHistory;
  final bool isPinned;
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
  });

  @override
  List<Object?> get hashParameters => [
    color,
    id,
    isActive,
    tabMode,
    isHistory,
    isPinned,
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
    final pinnedTabIds = ref.watch(
      watchPinnedTabIdsProvider.select((value) => value.value),
    );
    final tabStates = ref.watch(
      quickTabSwitcherTabStatesProvider(quickTabSwitcherMode),
    );
    final selectedTabId = ref.watch(selectedTabProvider);
    final historySuggestions = ref
        .watch(quickTabSwitcherHistorySuggestionsProvider(quickTabSwitcherMode))
        .value;
    final availableItems = tabStates.value
        .map<QuickTabSwitcherItem>(
          (state) => QuickTabSwitcherItem(
            color: state.$2?.color,
            id: state.$1.id,
            isActive: state.$1.id == selectedTabId,
            title: state.$1.titleOrAuthority,
            tabMode: state.$1.tabMode,
            isHistory: false,
            isPinned: pinnedTabIds?.contains(state.$1.id) ?? false,
            url: state.$1.url,
            avatar: TabIcon(tabState: state.$1, iconSize: 20),
          ),
        )
        .followedBy(
          (historySuggestions ?? []).map<QuickTabSwitcherItem>((state) {
            final url = Uri.parse(state.url);

            return QuickTabSwitcherItem(
              color: null,
              id: state.url,
              isActive: false,
              title: state.title ?? url.authority,
              tabMode: TabMode.regular,
              isHistory: true,
              isPinned: false,
              url: url,
              avatar: UrlIcon([url], iconSize: 20),
            );
          }),
        )
        .toList();

    final activeItem = availableItems.firstWhere(
      (item) => item.isActive,
      orElse: () => availableItems.first,
    );

    final chipScrollController = useScrollController();

    return QuickTabSwitcherView(
      availableItems: availableItems,
      activeItem: activeItem.isActive ? activeItem : null,
      scrollController: chipScrollController,
      showTitles: showTitles,
      showIsolatedTabUi: showIsolatedTabUi,
      onSelected: (item) async {
        if (!item.isHistory && item.isActive) {
          return;
        }
        if (item.isHistory) {
          await ref
              .read(tabRepositoryProvider.notifier)
              .addTab(url: item.url, tabMode: TabMode.regular, selectTab: true);
        } else {
          await ref.read(tabRepositoryProvider.notifier).selectTab(item.id);
        }
      },
      itemWrapBuilder: (child, item) {
        if (item.isHistory) {
          return child;
        }

        return TabMenu(
          selectedTabId: item.id,
          enableFindInPage: false,
          enableFetchFeeds: false,
          enableDesktopMode: false,
          enableReaderMode: false,
          enableReloadButton: false,
          enableNavigationButtons: false,
          enableAddToHomeScreen: false,
          enablePinTab: effectiveMode == QuickTabSwitcherMode.containerTabs,
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
      },
    );
  }
}

class QuickTabSwitcherView extends StatelessWidget {
  const QuickTabSwitcherView({
    super.key,
    required this.availableItems,
    required this.activeItem,
    required this.scrollController,
    required this.showTitles,
    required this.showIsolatedTabUi,
    required this.onSelected,
    required this.itemWrapBuilder,
  });

  final List<QuickTabSwitcherItem> availableItems;
  final QuickTabSwitcherItem? activeItem;
  final ScrollController scrollController;
  final bool showTitles;
  final bool showIsolatedTabUi;
  final Future<void> Function(QuickTabSwitcherItem item) onSelected;
  final Widget Function(Widget child, QuickTabSwitcherItem item)
  itemWrapBuilder;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    if (availableItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: SizedBox(
        height: 48,
        width: double.maxFinite,
        child:
            SelectableChips<QuickTabSwitcherItem, QuickTabSwitcherItem, String>(
              enableDelete: false,
              sortSelectedFirst: false,
              scrollController: scrollController,
              itemId: (item) => item.id,
              selectedItem: activeItem,
              selectedBorderColor: Theme.of(context).colorScheme.primary,
              labelPadding: (item) =>
                  (!showTitles &&
                      !item.isHistory &&
                      !item.isPinned &&
                      item.tabMode is! PrivateTabMode &&
                      item.tabMode is! IsolatedTabMode)
                  ? EdgeInsets.zero
                  : null,
              itemLabel: (item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.isHistory || showTitles)
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
              },
              itemAvatar: (item) => item.avatar,
              itemBackgroundColor: (item) => item.color != null
                  ? ContainerColors.forChip(item.color!)
                  : null,
              onSelected: onSelected,
              itemWrap: itemWrapBuilder,
              availableItems: availableItems,
            ),
      ),
    );
  }
}
