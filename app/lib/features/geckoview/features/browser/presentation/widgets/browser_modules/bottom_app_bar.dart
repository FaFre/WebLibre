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

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/readerable.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/web_extensions_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_bar_dismissable.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/app_bar_title.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/extension_badge_icon.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/extension_shortcut_menu.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/menu_item_buttons.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_creation_menu.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_menu.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tabs_action_button.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/widgets/reader_button.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/icons/tor_icons.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

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
    return BottomAppBar(
      height: _size.height,
      padding: EdgeInsets.zero,
      child: _tabBar,
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
    final isPrivateTab = ref.watch(
      selectedTabStateProvider.select((state) => state?.isPrivate ?? false),
    );

    final showExtensionShortcut = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.showExtensionShortcut,
      ),
    );

    final dragStartPosition = useRef(Offset.zero);

    final toolbarHeight = useMemoized(() => getToolbarHeight());

    return GestureDetector(
      onTap: () {
        if (displayedSheet case EditUrlSheet()) {
          ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
          return;
        }

        final tabState = ref.read(selectedTabStateProvider);

        if (tabState != null) {
          ref
              .read(bottomSheetControllerProvider.notifier)
              .show(EditUrlSheet(tabState: tabState));
        }
      },
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
        } else if (distance.dy < (toolbarHeight / 3) &&
            distance.dx.abs() < 15) {
          ref.read(tabBarDismissableControllerProvider.notifier).dismiss();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showQuickTabSwitcherBar)
            Visibility(
              visible: displayQuickTabSwitcher,
              maintainState: true,
              child: QuickTabSwitcher(),
            ),
          if (showMainToolbar)
            Visibility(
              visible: displayAppBar,
              maintainState: true,
              child: AppBar(
                automaticallyImplyLeading: false,
                titleSpacing: 8.0,
                backgroundColor:
                    (isPrivateTab && displayedSheet is! ViewTabsSheet)
                    ? const Color(0x648000D7)
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
                                InkWell(
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
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15.0,
                                      horizontal: 8.0,
                                    ),
                                    child: icon,
                                  ),
                                ),
                          ),
                        );
                      },
                    ),
                  if (showExtensionShortcut)
                    ExtensionShortcutMenu(
                      controller: extensionMenuController,
                      child: IconButton(
                        onPressed: () {
                          if (extensionMenuController.isOpen) {
                            extensionMenuController.close();
                          } else {
                            extensionMenuController.open();
                          }
                        },
                        icon: const Icon(MdiIcons.puzzle),
                      ),
                    ),
                  if (selectedTabId != null)
                    TabMenu(
                      controller: trippleDotMenuController,
                      selectedTabId: selectedTabId,
                      child: InkWell(
                        onTap: () {
                          if (trippleDotMenuController.isOpen) {
                            trippleDotMenuController.close();
                          } else {
                            trippleDotMenuController.open();
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 15.0,
                          ),
                          child: Icon(MdiIcons.dotsVertical),
                        ),
                      ),
                    ),
                  if (showMainToolbarTabsCount)
                    TabsCountButton(
                      selectedTabId: selectedTabId,
                      displayedSheet: displayedSheet,
                      showLongPressMenu: true,
                    ),
                  if (showMainToolbarNavigationButton)
                    NavigationMenuButton(
                      selectedTabId: selectedTabId,
                      showNavigationButtons: true,
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
        if (tabState?.historyState.canGoBack == true)
          NavigateBackButton(
            selectedTabId: selectedTabId,
            isLoading: tabState?.isLoading ?? false,
          )
        else
          IconButton(
            onPressed: () async {
              await BookmarkListRoute(
                entryGuid: BookmarkRoot.mobile.id,
              ).push(context);
            },
            icon: const Icon(MdiIcons.bookmarkMultiple),
          ),
        if (tabState?.historyState.canGoForward == true)
          NavigateForwardButton(selectedTabId: selectedTabId)
        else
          ShareMenuButton(selectedTabId: selectedTabId),
        AddTabButton(),
        TabsCountButton(
          selectedTabId: selectedTabId,
          displayedSheet: displayedSheet,
          showLongPressMenu: false,
        ),
        NavigationMenuButton(
          selectedTabId: selectedTabId,
          showNavigationButtons: false,
        ),
      ],
    );
  }
}

class QuickTabSwitcher extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabStates = ref.watch(fifoTabStatesProvider);
    final historyAsync = useCachedFuture(() {
      if (tabStates.value.length <= 1) {
        return ref
            .read(historyRepositoryProvider.notifier)
            .getVisitsPaginated(count: 25);
      }

      return Future.value(<VisitInfo>[]);
    }, [tabStates.value.length <= 1]);

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
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      MdiIcons.dominoMask,
                      color: Color(0xFF8000D7),
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
          itemAvatar: (item) => UrlIcon([item.url], iconSize: 16),
          itemBackgroundColor: (item) => item.color?.withValues(alpha: 0.5),
          onSelected: (item) async {
            final animation = chipScrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
            );
            if (item.isHistory) {
              await ref
                  .read(tabRepositoryProvider.notifier)
                  .addTab(url: item.url, private: false);
            } else {
              await ref.read(tabRepositoryProvider.notifier).selectTab(item.id);
            }
            await animation;
          },
          availableItems: tabStates.value
              .map(
                (state) => (
                  id: state.$1.id,
                  title: state.$1.titleOrAuthority,
                  isPrivate: state.$1.isPrivate,
                  isHistory: false,
                  url: state.$1.url,
                  color: state.$2?.color,
                ),
              )
              .skip(1)
              .followedBy(
                (historyAsync.data ?? []).map((state) {
                  final url = Uri.parse(state.url);

                  return (
                    id: state.url,
                    title: state.title ?? url.authority,
                    isPrivate: false,
                    isHistory: true,
                    url: url,
                    color: null,
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
        LaunchExternalMenuItemButton(selectedTabId: selectedTabId),
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

class NavigationMenuButton extends HookConsumerWidget {
  final String? selectedTabId;
  final bool showNavigationButtons;

  const NavigationMenuButton({
    super.key,
    required this.selectedTabId,
    required this.showNavigationButtons,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addonService = ref.watch(addonServiceProvider);

    final hamburgerMenuController = useMenuController();

    return MenuAnchor(
      controller: hamburgerMenuController,
      builder: (context, controller, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: InkWell(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0),
              child: Icon(Icons.menu),
            ),
          ),
        );
      },
      menuChildren: [
        MenuItemButton(
          onPressed: () async {
            await const SelectProfileRoute().push(context);
          },
          leadingIcon: const Icon(Icons.person),
          child: Consumer(
            builder: (context, ref, child) {
              final profile = ref.watch(selectedProfileProvider);
              return Text(profile.value?.name ?? 'User');
            },
          ),
        ),
        const Divider(),
        Consumer(
          builder: (context, childRef, child) {
            final pageExtensions = childRef.watch(
              webExtensionsStateProvider(
                WebExtensionActionType.page,
              ).select((value) => value.values.toList()),
            );

            return Wrap(
              alignment: WrapAlignment.center,
              children: [
                ...pageExtensions.map(
                  (extension) => IconButton(
                    onPressed: () async {
                      //Use parents .ref because after onPressed this consumer gets disposed already
                      await addonService.invokeAddonAction(
                        extension.extensionId,
                        WebExtensionActionType.page,
                      );
                    },
                    icon: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: ExtensionBadgeIcon(extension),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        MenuItemButton(
          onPressed: () async {
            await AboutRoute().push(context);
          },
          leadingIcon: const Icon(Icons.info),
          child: const Text('About'),
        ),
        // MenuItemButton(
        //   onPressed: () async {
        //     final isPrivate =
        //         ref
        //             .read(generalSettingsWithDefaultsProvider)
        //             .defaultCreateTabType ==
        //         TabType.private;

        //     await ref
        //         .read(tabRepositoryProvider.notifier)
        //         .addTab(
        //           url: ref.read(docsUriProvider),
        //           private: isPrivate,
        //           container: const Value(null),
        //         );
        //   },
        //   leadingIcon: const Icon(Icons.help),
        //   child: const Text('Help and feedback'),
        // ),
        const Divider(),
        MenuItemButton(
          onPressed: () async {
            await SettingsRoute().push(context);
          },
          leadingIcon: const Icon(Icons.settings),
          child: const Text('Settings'),
        ),
        Consumer(
          builder: (context, childRef, child) {
            final browserExtensions = childRef.watch(
              webExtensionsStateProvider(
                WebExtensionActionType.browser,
              ).select((value) => value.values.toList()),
            );

            return SubmenuButton(
              menuChildren: [
                ...browserExtensions.map(
                  (extension) => MenuItemButton(
                    onPressed: () async {
                      //Use parents .ref because after onPressed this consumer gets disposed already
                      await addonService.invokeAddonAction(
                        extension.extensionId,
                        WebExtensionActionType.browser,
                      );
                    },
                    leadingIcon: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: ExtensionBadgeIcon(extension),
                    ),
                    child: Text(extension.title ?? ''),
                  ),
                ),
                MenuItemButton(
                  onPressed: () async {
                    await addonService.startAddonManagerActivity();
                  },
                  leadingIcon: const Icon(MdiIcons.puzzleEdit),
                  child: const Text('Manage Extension'),
                ),
                MenuItemButton(
                  onPressed: () async {
                    final isPrivate =
                        ref
                            .read(generalSettingsWithDefaultsProvider)
                            .defaultCreateTabType ==
                        TabType.private;

                    await ref
                        .read(tabRepositoryProvider.notifier)
                        .addTab(
                          url: Uri.parse('https://addons.mozilla.org'),
                          private: isPrivate,
                          container: const Value(null),
                        );
                  },
                  leadingIcon: const Icon(MdiIcons.puzzlePlus),
                  child: const Text('Get Extensions'),
                ),
              ],
              leadingIcon: const Icon(MdiIcons.puzzle),
              child: const Text('Extensions'),
            );
          },
        ),
        MenuItemButton(
          onPressed: () async {
            await const TorProxyRoute().push(context);
          },
          leadingIcon: const Icon(TorIcons.onionAlt),
          child: Consumer(
            child: const Text('Tor™ Proxy'),
            builder: (context, ref, child) {
              final torConnected = ref.watch(
                torProxyServiceProvider.select((value) => value.value != null),
              );

              return Badge(
                isLabelVisible: torConnected,
                backgroundColor: const Color(0xFF68B030),
                child: child,
              );
            },
          ),
        ),
        const Divider(),
        MenuItemButton(
          onPressed: () async {
            await const HistoryRoute().push(context);
          },
          leadingIcon: const Icon(Icons.history),
          child: const Text('History'),
        ),
        MenuItemButton(
          onPressed: () async {
            await BookmarkListRoute(
              entryGuid: BookmarkRoot.mobile.id,
            ).push(context);
          },
          leadingIcon: const Icon(MdiIcons.bookmarkMultiple),
          child: const Text('Bookmarks'),
        ),
        MenuItemButton(
          onPressed: () async {
            await const BangMenuRoute().push(context);
          },
          leadingIcon: const Icon(MdiIcons.exclamationThick),
          child: const Text('Bangs'),
        ),
        MenuItemButton(
          onPressed: () async {
            await const ContainerListRoute().push(context);
          },
          leadingIcon: const Icon(MdiIcons.folder),
          child: const Text('Containers'),
        ),
        MenuItemButton(
          onPressed: () async {
            await context.push(FeedListRoute().location);
          },
          leadingIcon: const Icon(Icons.rss_feed),
          child: const Text('Feeds'),
        ),
        const Divider(),
        if (selectedTabId != null)
          MenuItemButton(
            onPressed: () async {
              final controller = ref.read(
                tabSessionProvider(tabId: selectedTabId).notifier,
              );

              await controller.reload();
              hamburgerMenuController.close();
            },
            leadingIcon: const Icon(Icons.refresh),
            child: const Text('Reload'),
          ),
        if (selectedTabId != null) const Divider(),
        if (selectedTabId != null && showNavigationButtons)
          Consumer(
            builder: (context, ref, child) {
              final history = ref.watch(
                tabStateProvider(
                  selectedTabId,
                ).select((value) => value?.historyState),
              );

              final isLoading = ref.watch(
                selectedTabStateProvider.select(
                  (state) => state?.isLoading ?? false,
                ),
              );

              return Row(
                children: [
                  Expanded(
                    child: (history?.canGoBack == true || isLoading)
                        ? NavigateBackButton(
                            selectedTabId: selectedTabId,
                            isLoading: isLoading,
                            menuControllerToClose: hamburgerMenuController,
                          )
                        : IconButton(
                            onPressed: () async {
                              await ref
                                  .read(tabRepositoryProvider.notifier)
                                  .closeTab(selectedTabId!);

                              hamburgerMenuController.close();

                              if (context.mounted) {
                                ui_helper.showTabUndoClose(
                                  context,
                                  ref
                                      .read(tabRepositoryProvider.notifier)
                                      .undoClose,
                                );
                              }
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                  const SizedBox(height: 48, child: VerticalDivider()),
                  Expanded(
                    child: NavigateForwardButton(
                      selectedTabId: selectedTabId,
                      menuControllerToClose: hamburgerMenuController,
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class NavigateForwardButton extends HookConsumerWidget {
  const NavigateForwardButton({
    super.key,
    required this.selectedTabId,
    this.menuControllerToClose,
  });

  final String? selectedTabId;
  final MenuController? menuControllerToClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        final controller = ref.read(
          tabSessionProvider(tabId: selectedTabId).notifier,
        );

        await controller.goForward();
        menuControllerToClose?.close();
      },
      icon: const Icon(Icons.arrow_forward),
    );
  }
}

class NavigateBackButton extends HookConsumerWidget {
  const NavigateBackButton({
    super.key,
    required this.selectedTabId,
    required this.isLoading,
    this.menuControllerToClose,
  });

  final String? selectedTabId;
  final bool isLoading;
  final MenuController? menuControllerToClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        final controller = ref.read(
          tabSessionProvider(tabId: selectedTabId).notifier,
        );

        final isReaderActive = ref.read(
          selectedTabStateProvider.select(
            (state) => state?.readerableState.active ?? false,
          ),
        );

        if (isLoading) {
          await controller.stopLoading();
        } else if (isReaderActive) {
          await ref
              .read(readerableScreenControllerProvider.notifier)
              .toggleReaderView(false);
        } else {
          await controller.goBack();
        }

        menuControllerToClose?.close();
      },
      icon: const Icon(Icons.arrow_back),
    );
  }
}

class AddTabButton extends HookConsumerWidget {
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
        icon: const Icon(Icons.add),
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
