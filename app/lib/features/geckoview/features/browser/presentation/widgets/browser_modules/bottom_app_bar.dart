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

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/readerable.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_bar_dismissable.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/app_bar_title.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/extension_shortcut_menu.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/menu_item_buttons.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/navigation_buttons.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_creation_menu.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_menu.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tabs_action_button.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/toolbar_button.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/widgets/reader_button.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class BrowserTopAppBar extends HookConsumerWidget {
  final bool showMainToolbar;
  final bool showContextualToolbar;
  final bool showQuickTabSwitcherBar;

  late final BrowserTabBar _tabBar;
  late final _size = Size.fromHeight(_tabBar.getToolbarHeight());

  BrowserTopAppBar({
    required this.showMainToolbar,
    required this.showContextualToolbar,
    required this.showQuickTabSwitcherBar,
  }) {
    _tabBar = BrowserTabBar(
      showMainToolbar: showMainToolbar,
      displayedSheet: null,
      showContextualToolbar: false,
      showQuickTabSwitcherBar: false,
      showMainToolbarNavigationButton: !showContextualToolbar,
      showMainToolbarTabsCount: !showContextualToolbar,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SizedBox(height: preferredSize.height, child: _tabBar),
    );
  }

  Size get preferredSize => _size;
}

class BrowserBottomAppBar extends HookConsumerWidget {
  final bool showMainToolbar;
  final bool showContextualToolbar;
  final bool showQuickTabSwitcherBar;
  final Sheet? displayedSheet;

  late final BrowserTabBar _tabBar;
  late final _size = Size.fromHeight(_tabBar.getToolbarHeight());

  BrowserBottomAppBar({
    required this.showMainToolbar,
    required this.displayedSheet,
    required this.showContextualToolbar,
    required this.showQuickTabSwitcherBar,
  }) {
    _tabBar = BrowserTabBar(
      displayedSheet: displayedSheet,
      showMainToolbar: showMainToolbar,
      showContextualToolbar: showContextualToolbar,
      showQuickTabSwitcherBar: showQuickTabSwitcherBar,
      showMainToolbarNavigationButton: !showContextualToolbar,
      showMainToolbarTabsCount: !showContextualToolbar,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Material(
      elevation: 3.0,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      color: Theme.of(context).colorScheme.surfaceContainer,
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

  final bool showMainToolbarTabsCount;
  final bool showMainToolbarNavigationButton;

  const BrowserTabBar({
    required this.showMainToolbar,
    required this.displayedSheet,
    required this.showContextualToolbar,
    required this.showQuickTabSwitcherBar,
    required this.showMainToolbarTabsCount,
    required this.showMainToolbarNavigationButton,
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
    final extensionMenuController = useMenuController();
    final trippleDotMenuController = useMenuController();

    final selectedTabId = ref.watch(selectedTabProvider);

    final containerColor = ref.watch(
      watchTabContainerDataProvider(
        selectedTabId,
      ).select((data) => data.value?.color),
    );

    final showExtensionShortcut = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.showExtensionShortcut,
      ),
    );

    final quickTabSwitcherMode = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.quickTabSwitcherMode,
      ),
    );

    final tabBarPosition = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.tabBarPosition,
      ),
    );

    final dragStartPosition = useRef(Offset.zero);

    final toolbarHeight = useMemoized(() => getToolbarHeight());

    return GestureDetector(
      // Tap handling moved to AppBarTitle for split icon/title behavior
      onHorizontalDragStart: (details) {
        dragStartPosition.value = details.globalPosition;
      },
      onHorizontalDragEnd: (details) async {
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
        } else if (distance.dx.abs() < 15) {
          // Swipe direction for dismiss depends on toolbar position:
          // - Bottom bar: swipe down to dismiss (distance.dy negative or small positive)
          // - Top bar: swipe up to dismiss (distance.dy positive or small negative)
          final dismissThreshold = toolbarHeight * 0.75;
          final shouldDismiss = switch (tabBarPosition) {
            TabBarPosition.bottom => distance.dy < dismissThreshold,
            TabBarPosition.top => distance.dy > -dismissThreshold,
          };
          if (shouldDismiss &&
              ref.read(bottomSheetControllerProvider) == null) {
            ref.read(tabBarDismissableControllerProvider.notifier).dismiss();
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showQuickTabSwitcherBar)
            Visibility(
              visible: displayQuickTabSwitcher,
              maintainState: true,
              child: QuickTabSwitcher(
                quickTabSwitcherMode: quickTabSwitcherMode,
              ),
            ),
          if (showMainToolbar)
            Visibility(
              visible: displayAppBar,
              maintainState: true,
              child: AppBar(
                primary: false,
                automaticallyImplyLeading: false,
                titleSpacing: 0.0,
                leadingWidth: 40.0,
                toolbarHeight: kToolbarHeight,
                backgroundColor:
                    (containerColor != null && displayedSheet is! ViewTabsSheet)
                    ? ContainerColors.forAppBar(containerColor)
                    : null,
                leading: showMainToolbarNavigationButton
                    ? NavigationMenuButton(selectedTabId: selectedTabId)
                    : null,
                title:
                    (selectedTabId != null && displayedSheet is! ViewTabsSheet)
                    ? const AppBarTitle()
                    : null,
                actions: [
                  if (selectedTabId != null && displayedSheet is! ViewTabsSheet)
                    Consumer(
                      builder: (context, ref, child) {
                        final tabBarReaderView = ref.watch(
                          generalSettingsWithDefaultsProvider.select(
                            (value) => value.tabBarReaderView,
                          ),
                        );

                        final readerabilityStateActive = ref.watch(
                          selectedTabStateProvider.select(
                            (state) =>
                                (state?.readerableState ??
                                        ReaderableState.$default())
                                    .active,
                          ),
                        );

                        return Visibility(
                          visible: tabBarReaderView || readerabilityStateActive,
                          child: ReaderButton(
                            buttonBuilder: (isLoading, readerActive, icon) =>
                                ToolbarButton(
                                  onTap: isLoading
                                      ? null
                                      : () async {
                                          await ref
                                              .read(
                                                readerableScreenControllerProvider
                                                    .notifier,
                                              )
                                              .toggleReaderView(!readerActive);
                                        },
                                  child: icon,
                                ),
                          ),
                        );
                      },
                    ),
                  if (showExtensionShortcut)
                    ExtensionShortcutMenu(
                      controller: extensionMenuController,
                      child: ToolbarButton(
                        onTap: () {
                          if (extensionMenuController.isOpen) {
                            extensionMenuController.close();
                          } else {
                            extensionMenuController.open();
                          }
                        },
                        child: const Icon(MdiIcons.puzzle),
                      ),
                    ),
                  if (showMainToolbarTabsCount)
                    TabsCountButton(
                      selectedTabId: selectedTabId,
                      displayedSheet: displayedSheet,
                      showLongPressMenu: true,
                    ),
                  if (selectedTabId != null && !showContextualToolbar)
                    TabMenu(
                      controller: trippleDotMenuController,
                      selectedTabId: selectedTabId,
                      builder: (context, controller, child) {
                        return ToolbarButton(
                          onTap: () {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          },
                          child: const Icon(MdiIcons.dotsVertical),
                        );
                      },
                    ),
                ],
              ),
            ),
          if (showContextualToolbar)
            ContextualToolbar(
              selectedTabId: selectedTabId,
              displayedSheet: displayedSheet,
            ),
        ],
      ),
    );
  }
}

typedef _QuickTabItem = ({
  Color? color,
  String id,
  bool isPrivate,
  bool isHistory,
  String title,
  Uri url,
  TabState? tabState,
});

class ContextualToolbar extends HookConsumerWidget {
  const ContextualToolbar({
    super.key,
    required this.selectedTabId,
    required this.displayedSheet,
  });

  final String? selectedTabId;
  final Sheet? displayedSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabStateProvider(selectedTabId));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        NavigationMenuButton(selectedTabId: selectedTabId),
        if (tabState?.historyState.canGoBack == true ||
            tabState?.isLoading == true)
          NavigateBackButton(
            selectedTabId: selectedTabId,
            isLoading: tabState?.isLoading ?? false,
          )
        else
          IconButton(
            onPressed: () async {
              await BookmarkListRoute(
                entryGuid: BookmarkRoot.root.id,
              ).push(context);
            },
            icon: const Icon(MdiIcons.bookmarkMultiple),
          ),
        if (tabState?.historyState.canGoForward == true)
          NavigateForwardButton(selectedTabId: selectedTabId)
        else
          ShareMenuButton(selectedTabId: selectedTabId),
        const AddTabButton(),
        TabsCountButton(
          selectedTabId: selectedTabId,
          displayedSheet: displayedSheet,
          showLongPressMenu: false,
        ),
        if (selectedTabId != null)
          TabMenu(
            controller: useMenuController(),
            selectedTabId: selectedTabId!,
            enableNavigationButtons: false,
            builder: (context, controller, child) {
              return ToolbarButton(
                onTap: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                child: const Icon(MdiIcons.dotsVertical),
              );
            },
          ),
      ],
    );
  }
}

class QuickTabSwitcher extends HookConsumerWidget {
  final QuickTabSwitcherMode quickTabSwitcherMode;

  const QuickTabSwitcher({required this.quickTabSwitcherMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = AppColors.of(context);
    final selectedTabId = ref.watch(selectedTabProvider);

    final tabStates = (switch (quickTabSwitcherMode) {
      QuickTabSwitcherMode.lastUsedTabs => ref.watch(fifoTabStatesProvider),
      QuickTabSwitcherMode.containerTabs => ref.watch(
        selectedContainerTabStatesWithContainerProvider,
      ),
    }).value.where((state) => state.$1.id != selectedTabId).toList();

    final historyAsync = useCachedFuture(() {
      if (tabStates.isEmpty) {
        return ref
            .read(historyRepositoryProvider.notifier)
            .getVisitsPaginated(count: 25);
      }

      return Future.value(<VisitInfo>[]);
    }, [tabStates.isEmpty]);

    final chipScrollController = useScrollController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: SizedBox(
        height: 48,
        width: double.maxFinite,
        child: SelectableChips<_QuickTabItem, _QuickTabItem, String>(
          enableDelete: false,
          scrollController: chipScrollController,
          itemId: (item) => item.id,
          itemLabel: (item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 64),
                  child: Text(item.title),
                ),
                if (item.isPrivate)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      MdiIcons.dominoMask,
                      color: appColors.privateTabPurple,
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
          itemAvatar: (item) =>
              item.tabState?.icon.mapNotNull(
                (icon) => icon.value.mapNotNull(
                  (image) => RawImage(image: image, height: 24, width: 24),
                ),
              ) ??
              UrlIcon([item.url], iconSize: 16),
          itemBackgroundColor: (item) =>
              item.color != null ? ContainerColors.forChip(item.color!) : null,
          onSelected: (item) async {
            final animation = chipScrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
            );
            if (item.isHistory) {
              await ref
                  .read(tabRepositoryProvider.notifier)
                  .addTab(url: item.url, private: false, selectTab: true);
            } else {
              await ref.read(tabRepositoryProvider.notifier).selectTab(item.id);
            }
            await animation;
          },
          itemWrap: (child, item) {
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
          availableItems: tabStates
              .map<_QuickTabItem>(
                (state) => (
                  id: state.$1.id,
                  title: state.$1.titleOrAuthority,
                  isPrivate: state.$1.isPrivate,
                  isHistory: false,
                  url: state.$1.url,
                  color: state.$2?.color,
                  tabState: state.$1,
                ),
              )
              .followedBy(
                (historyAsync.data ?? []).map<_QuickTabItem>((state) {
                  final url = Uri.parse(state.url);

                  return (
                    id: state.url,
                    title: state.title ?? url.authority,
                    isPrivate: false,
                    isHistory: true,
                    url: url,
                    color: null,
                    tabState: null,
                  );
                }),
              ),
        ),
      ),
    );
  }
}

class ShareMenuButton extends HookConsumerWidget {
  final String? selectedTabId;

  const ShareMenuButton({super.key, required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuController = useMenuController();

    return MenuAnchor(
      controller: menuController,
      menuChildren: [
        CopyAddressMenuItemButton(selectedTabId: selectedTabId),
        OpenInAppMenuItemButton(selectedTabId: selectedTabId),
        ShareScreenshotMenuItemButton(selectedTabId: selectedTabId),
        ShareMenuItemButton(selectedTabId: selectedTabId),
        ShowQrCodeMenuItemButton(selectedTabId: selectedTabId),
      ],
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.share),
        );
      },
    );
  }
}

class NavigationMenuButton extends StatelessWidget {
  final String? selectedTabId;

  const NavigationMenuButton({super.key, required this.selectedTabId});

  @override
  Widget build(BuildContext context) {
    return ToolbarButton(
      onTap: () {
        Scaffold.of(context).openEndDrawer();
      },
      child: const Icon(Icons.menu),
    );
  }
}

class AddTabButton extends HookConsumerWidget {
  const AddTabButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabMenuController = useMenuController();

    return TabCreationMenu(
      controller: tabMenuController,
      child: IconButton(
        onPressed: () async {
          final settings = ref.read(generalSettingsWithDefaultsProvider);

          await SearchRoute(
            tabType:
                ref.read(selectedTabTypeProvider) ??
                settings.defaultCreateTabType,
          ).push(context);

          if (context.mounted) {
            const BrowserRoute().go(context);
          }
        },
        icon: const Icon(MdiIcons.tabPlus),
        onLongPress: () {
          if (tabMenuController.isOpen) {
            tabMenuController.close();
          } else {
            tabMenuController.open();
          }
        },
      ),
    );
  }
}

class TabsCountButton extends HookConsumerWidget {
  const TabsCountButton({
    super.key,
    required this.selectedTabId,
    required this.displayedSheet,
    required this.showLongPressMenu,
  });

  final String? selectedTabId;
  final Sheet? displayedSheet;
  final bool showLongPressMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabMenuController = useMenuController();

    return TabCreationMenu(
      controller: tabMenuController,
      child: TabsActionButton(
        isActive: displayedSheet is ViewTabsSheet,
        onTap: () async {
          final tabViewBottomSheet = ref
              .read(generalSettingsWithDefaultsProvider)
              .tabViewBottomSheet;

          if (tabViewBottomSheet) {
            if (displayedSheet case ViewTabsSheet()) {
              ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
            } else {
              ref
                  .read(bottomSheetControllerProvider.notifier)
                  .show(ViewTabsSheet());
            }
          } else {
            await const TabViewRoute().push(context);
          }
        },
        onLongPress: showLongPressMenu
            ? () {
                if (tabMenuController.isOpen) {
                  tabMenuController.close();
                } else {
                  tabMenuController.open();
                }
              }
            : null,
      ),
    );
  }
}
