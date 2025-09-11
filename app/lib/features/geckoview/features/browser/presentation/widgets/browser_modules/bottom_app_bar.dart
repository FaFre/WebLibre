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
import 'package:share_plus/share_plus.dart';
import 'package:weblibre/core/providers/defaults.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/web_extensions_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/app_bar_title.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/extension_badge_icon.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/extension_shortcut_menu.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_creation_menu.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tabs_action_button.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/widgets/reader_button.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/icons/tor_icons.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class BrowserBottomAppBar extends HookConsumerWidget {
  const BrowserBottomAppBar({required this.displayedSheet});

  final Sheet? displayedSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addonService = ref.watch(addonServiceProvider);

    final tabMenuController = useMenuController();
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

    return BottomAppBar(
      height: AppBar().preferredSize.height,
      padding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: () {
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

          if (distance.dx.abs() > 50) {
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
        child: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 8.0,
          backgroundColor: (isPrivateTab && displayedSheet is! ViewTabsSheet)
              ? const Color(0x648000D7)
              : null,
          title: (selectedTabId != null && displayedSheet is! ViewTabsSheet)
              ? const AppBarTitle()
              : null,
          actions: [
            if (selectedTabId != null && displayedSheet is! ViewTabsSheet)
              ReaderButton(),
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
            TabCreationMenu(
              controller: tabMenuController,
              selectedTabId: selectedTabId,
              child: TabsActionButton(
                isActive: displayedSheet is ViewTabsSheet,
                onTap: () {
                  if (displayedSheet case ViewTabsSheet()) {
                    ref.read(bottomSheetControllerProvider.notifier).dismiss();
                  } else {
                    ref
                        .read(bottomSheetControllerProvider.notifier)
                        .show(ViewTabsSheet());
                  }
                },
                onLongPress: () {
                  if (tabMenuController.isOpen) {
                    tabMenuController.close();
                  } else {
                    tabMenuController.open();
                  }
                },
              ),
            ),
            MenuAnchor(
              controller: trippleDotMenuController,
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
                      padding: EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 8.0,
                      ),
                      child: Icon(Icons.more_vert),
                    ),
                  ),
                );
              },
              menuChildren: [
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
                          url: ref.read(docsUriProvider),
                          private: isPrivate,
                          container: const Value(null),
                        );
                  },
                  leadingIcon: const Icon(Icons.help),
                  child: const Text('Help and feedback'),
                ),
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
                    await TorProxyRoute().push(context);
                  },
                  leadingIcon: const Icon(TorIcons.onionAlt),
                  child: const Text('Tor™ Proxy'),
                ),
                const Divider(),
                MenuItemButton(
                  onPressed: () async {
                    await BangCategoriesRoute().push(context);
                  },
                  leadingIcon: const Icon(MdiIcons.exclamationThick),
                  child: const Text('Bangs'),
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
                      final tabState = ref.read(
                        tabStateProvider(selectedTabId),
                      );

                      if (tabState?.url case final Uri url) {
                        await ui_helper.launchUrlFeedback(context, url);
                      }
                    },
                    leadingIcon: const Icon(Icons.open_in_browser),
                    child: const Text('Launch External'),
                  ),
                if (selectedTabId != null)
                  MenuItemButton(
                    onPressed: () async {
                      final tabState = ref.read(
                        tabStateProvider(selectedTabId),
                      );

                      if (tabState?.url case final Uri url) {
                        await SharePlus.instance.share(ShareParams(uri: url));
                      }
                    },
                    leadingIcon: const Icon(Icons.share),
                    child: const Text('Share'),
                  ),
                if (selectedTabId != null) const Divider(),
                if (selectedTabId != null)
                  MenuItemButton(
                    onPressed: () {
                      final tabId = ref.read(selectedTabProvider);
                      if (tabId != null) {
                        ref
                            .read(findInPageControllerProvider(tabId).notifier)
                            .show();
                      }
                    },
                    leadingIcon: const Icon(Icons.search),
                    child: const Text('Find in page'),
                  ),
                if (selectedTabId != null) const Divider(),
                if (selectedTabId != null)
                  MenuItemButton(
                    onPressed: () async {
                      final controller = ref.read(
                        tabSessionProvider(tabId: selectedTabId).notifier,
                      );

                      await controller.reload();
                      trippleDotMenuController.close();
                    },
                    leadingIcon: const Icon(Icons.refresh),
                    child: const Text('Reload'),
                  ),
                if (selectedTabId != null) const Divider(),
                if (selectedTabId != null)
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
                                ? IconButton(
                                    onPressed: () async {
                                      final controller = ref.read(
                                        tabSessionProvider(
                                          tabId: selectedTabId,
                                        ).notifier,
                                      );

                                      final isReaderActive = ref.read(
                                        selectedTabStateProvider.select(
                                          (state) =>
                                              state?.readerableState.active ??
                                              false,
                                        ),
                                      );

                                      if (isLoading) {
                                        await controller.stopLoading();
                                      } else if (isReaderActive) {
                                        await ref
                                            .read(
                                              readerableScreenControllerProvider
                                                  .notifier,
                                            )
                                            .toggleReaderView(false);
                                      } else {
                                        await controller.goBack();
                                      }

                                      trippleDotMenuController.close();
                                    },
                                    icon: const Icon(Icons.arrow_back),
                                  )
                                : IconButton(
                                    onPressed: () async {
                                      await ref
                                          .read(tabRepositoryProvider.notifier)
                                          .closeTab(selectedTabId);

                                      trippleDotMenuController.close();

                                      if (context.mounted) {
                                        ui_helper.showTabUndoClose(
                                          context,
                                          ref
                                              .read(
                                                tabRepositoryProvider.notifier,
                                              )
                                              .undoClose,
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                          ),
                          const SizedBox(height: 48, child: VerticalDivider()),
                          Expanded(
                            child: IconButton(
                              onPressed: (history?.canGoForward == true)
                                  ? () async {
                                      final controller = ref.read(
                                        tabSessionProvider(
                                          tabId: selectedTabId,
                                        ).notifier,
                                      );

                                      await controller.goForward();
                                      trippleDotMenuController.close();
                                    }
                                  : null,
                              icon: const Icon(Icons.arrow_forward),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
