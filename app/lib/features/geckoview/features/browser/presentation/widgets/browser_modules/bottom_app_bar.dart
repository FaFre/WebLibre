import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_session.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/domain/providers/web_extensions_state.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/browser_modules/app_bar_title.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/edit_url_dialog.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/extension_badge_icon.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/tabs_action_button.dart';
import 'package:lensai/features/geckoview/features/find_in_page/presentation/controllers/find_in_page_visibility.dart';
import 'package:lensai/features/geckoview/features/readerview/presentation/widgets/reader_button.dart';
import 'package:lensai/presentation/hooks/menu_controller.dart';
import 'package:lensai/presentation/icons/tor_icons.dart';
import 'package:lensai/utils/ui_helper.dart' as ui_helper;
import 'package:share_plus/share_plus.dart';

class BrowserBottomAppBar extends HookConsumerWidget {
  const BrowserBottomAppBar({
    required this.selectedTabId,
    required this.displayedSheet,
  });

  final String? selectedTabId;
  final Sheet? displayedSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addonService = ref.watch(addonServiceProvider);

    final tabMenuController = useMenuController();
    final trippleDotMenuController = useMenuController();

    return BottomAppBar(
      height: AppBar().preferredSize.height,
      padding: EdgeInsets.zero,
      child: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 8.0,
        title:
            (selectedTabId != null && displayedSheet is! ViewTabsSheet)
                ? HookConsumer(
                  builder: (context, ref, child) {
                    final tabState = ref.watch(tabStateProvider(selectedTabId));

                    final dragStartPosition = useRef(Offset.zero);

                    return (tabState != null)
                        ? AppBarTitle(
                          tab: tabState,
                          onTap: () async {
                            await WebPageRoute(
                              url: tabState.url.toString(),
                              $extra: tabState,
                            ).push(context);
                          },
                          onLongPress: () async {
                            final newUrl = await showDialog<Uri?>(
                              context: context,
                              builder:
                                  (context) =>
                                      EditUrlDialog(initialUrl: tabState.url),
                            );

                            if (newUrl != null) {
                              await ref
                                  .read(
                                    tabSessionProvider(tabId: null).notifier,
                                  )
                                  .loadUrl(url: newUrl);
                            }
                          },
                          onHorizontalDragStart: (details) {
                            dragStartPosition.value = details.globalPosition;
                          },
                          onHorizontalDragEnd: (details) async {
                            final distance =
                                dragStartPosition.value -
                                details.globalPosition;

                            if (distance.dx.abs() > 50) {
                              await ref
                                  .read(tabRepositoryProvider.notifier)
                                  .selectPreviousTab();
                            }
                          },
                        )
                        : const SizedBox.shrink();
                  },
                )
                : null,
        actions: [
          if (selectedTabId != null && displayedSheet is! ViewTabsSheet)
            ReaderButton(),
          MenuAnchor(
            controller: tabMenuController,
            builder: (context, controller, child) {
              return child!;
            },
            menuChildren: [
              if (selectedTabId != null) ...[
                MenuItemButton(
                  onPressed: () async {
                    await ref
                        .read(tabRepositoryProvider.notifier)
                        .closeTab(selectedTabId!);
                  },
                  leadingIcon: const Icon(Icons.close),
                  child: const Text('Close Tab'),
                ),
                const Divider(),
              ],
              MenuItemButton(
                onPressed: () async {
                  await const SearchRoute(
                    tabType: TabType.private,
                  ).push(context);
                },
                leadingIcon: const Icon(MdiIcons.tabUnselected),
                child: const Text('Add Private Tab'),
              ),
              MenuItemButton(
                onPressed: () async {
                  await const SearchRoute(
                    tabType: TabType.regular,
                  ).push(context);
                },
                leadingIcon: const Icon(MdiIcons.tabPlus),
                child: const Text('Add Tab'),
              ),
            ],
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
                          icon: ExtensionBadgeIcon(extension),
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
              const Divider(),
              MenuItemButton(
                onPressed: () async {
                  await SettingsRoute().push(context);
                },
                leadingIcon: const Icon(Icons.settings),
                child: const Text('Settings'),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final browserExtensions = ref.watch(
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
                          leadingIcon: ExtensionBadgeIcon(extension),
                          child: Text(extension.title ?? ''),
                        ),
                      ),
                      MenuItemButton(
                        onPressed: () async {
                          await addonService.startAddonManagerActivity();
                        },
                        leadingIcon: const Icon(MdiIcons.puzzleEdit),
                        child: const Text('Addon Manager'),
                      ),
                    ],
                    leadingIcon: const Icon(MdiIcons.puzzle),
                    child: const Text('Addons'),
                  );
                },
              ),
              MenuItemButton(
                onPressed: () async {
                  await TorProxyRoute().push(context);
                },
                leadingIcon: const Icon(TorIcons.onionAlt),
                child: const Text('Tor'),
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
                    final tabState = ref.read(tabStateProvider(selectedTabId));

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
                    final tabState = ref.read(tabStateProvider(selectedTabId));

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
                    ref
                        .read(findInPageVisibilityControllerProvider.notifier)
                        .show();
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
                          child:
                              (history?.canGoBack == true || isLoading)
                                  ? IconButton(
                                    onPressed: () async {
                                      final controller = ref.read(
                                        tabSessionProvider(
                                          tabId: selectedTabId,
                                        ).notifier,
                                      );

                                      if (isLoading) {
                                        await controller.stopLoading();
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
                                          .closeTab(selectedTabId!);
                                      trippleDotMenuController.close();
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                        ),
                        const SizedBox(height: 48, child: VerticalDivider()),
                        Expanded(
                          child: IconButton(
                            onPressed:
                                (history?.canGoForward == true)
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
    );
  }
}
