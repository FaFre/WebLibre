import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/providers/global_drop.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/data/models/drag_data.dart';
import 'package:lensai/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:lensai/features/geckoview/domain/controllers/overlay_dialog.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_list.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_session.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/domain/providers/web_extensions_state.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/app_bar_title.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/browser_view.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/draggable_scrollable_header.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/edit_url_dialog.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/extension_badge_icon.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/sheets/create_tab.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/sheets/view_tabs.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/tabs_action_button.dart';
import 'package:lensai/features/geckoview/features/find_in_page/presentation/controllers/find_in_page_visibility.dart';
import 'package:lensai/features/geckoview/features/find_in_page/presentation/widgets/find_in_page.dart';
import 'package:lensai/features/geckoview/features/readerview/presentation/widgets/reader_appearance_button.dart';
import 'package:lensai/features/geckoview/features/readerview/presentation/widgets/reader_button.dart';
import 'package:lensai/features/geckoview/features/tabs/features/chat/presentation/widgets/tab_qa_chat.dart';
import 'package:lensai/features/kagi/data/entities/modes.dart';
import 'package:lensai/presentation/hooks/draggable_scrollable_controller.dart';
import 'package:lensai/presentation/hooks/menu_controller.dart';
import 'package:lensai/presentation/hooks/overlay_portal_controller.dart';
import 'package:lensai/presentation/icons/tor_icons.dart';
import 'package:lensai/utils/ui_helper.dart' as ui_helper;
import 'package:share_plus/share_plus.dart';

class BrowserScreen extends HookConsumerWidget {
  const BrowserScreen({super.key});

  double _realtiveSafeArea(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return 1.0 - (mediaQuery.padding.top / mediaQuery.size.height);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Init here to avoid dispose errors of menu items when called
    final addonService = ref.watch(addonServiceProvider);

    final displayedSheet = ref.watch(bottomSheetControllerProvider);
    final displayedOverlayDialog = ref.watch(overlayDialogControllerProvider);

    final selectedTabId = ref.watch(
      selectedTabStateProvider.select((value) => value?.id),
    );

    final trippleDotMenuController = useMenuController();
    final tabMenuController = useMenuController();

    final lastBackButtonPress = useRef<DateTime?>(null);

    final overlayController = useOverlayPortalController();

    final activeKagiTool = useValueNotifier<KagiTool?>(null, [displayedSheet]);

    ref.listen(overlayDialogControllerProvider, (previous, next) {
      if (next != null) {
        overlayController.show();
      } else {
        overlayController.hide();
      }
    });

    // ref.listen(
    //   generalSettingsRepositoryProvider
    //       .select((value) => value.valueOrNull?.kagiSession),
    //   (previous, next) async {
    //     if (next != null && next.isNotEmpty) {
    //       await ref
    //           .read(kagiSessionServiceProvider.notifier)
    //           .setKagiSession(next);
    //     }
    //   },
    // );

    return PopScope(
      //We need this for BackButtonListener to work downstream
      //No direct pop result will be handled here
      canPop: false,
      child: Scaffold(
        bottomNavigationBar: Consumer(
          builder: (context, ref, child) {
            final tabInFullScreen = ref.watch(
              selectedTabStateProvider.select(
                (value) => value?.isFullScreen ?? false,
              ),
            );

            return Visibility(
              visible: !tabInFullScreen,
              child: BottomAppBar(
                height: AppBar().preferredSize.height,
                padding: EdgeInsets.zero,
                child: AppBar(
                  automaticallyImplyLeading: false,
                  titleSpacing: 8.0,
                  title:
                      (selectedTabId != null &&
                              displayedSheet is! ViewTabsSheet)
                          ? Consumer(
                            builder: (context, ref, child) {
                              final tabState = ref.watch(
                                tabStateProvider(selectedTabId),
                              );

                              return (tabState != null)
                                  ? AppBarTitle(
                                    tab: tabState,
                                    onTap: () async {
                                      await context.push(
                                        WebPageRoute(
                                          url: tabState.url.toString(),
                                        ).location,
                                        extra: tabState,
                                      );
                                    },
                                    onDoubleTap: () async {
                                      final newUrl = await showDialog<Uri?>(
                                        context: context,
                                        builder:
                                            (context) => EditUrlDialog(
                                              initialUrl: tabState.url,
                                            ),
                                      );

                                      if (newUrl != null) {
                                        await ref
                                            .read(
                                              tabSessionProvider(
                                                tabId: null,
                                              ).notifier,
                                            )
                                            .loadUrl(url: newUrl);
                                      }
                                    },
                                  )
                                  : const SizedBox.shrink();
                            },
                          )
                          : HookBuilder(
                            builder: (context) {
                              // final activeTool = useListenableSelector(
                              //   activeKagiTool,
                              //   () {
                              //     if (displayedSheet is CreateTabSheetWidget) {
                              //       return null;
                              //     }

                              //     return activeKagiTool.value;
                              //   },
                              // );

                              return Row(
                                children: [
                                  // IconButton(
                                  //   color: (activeTool == KagiTool.search)
                                  //       ? Theme.of(context).colorScheme.primary
                                  //       : null,
                                  //   onPressed: () async {
                                  //     // ref
                                  //     //     .read(createTabStreamProvider.notifier)
                                  //     //     .createTab(
                                  //     //       CreateTabSheet(
                                  //     //         preferredTool: KagiTool.search,
                                  //     //       ),
                                  //     //     );
                                  //     await context
                                  //         .push(const SearchRoute().location);
                                  //   },
                                  //   icon: Icon(KagiTool.search.icon),
                                  // ),
                                  // IconButton(
                                  //   color: (activeTool == KagiTool.summarizer)
                                  //       ? Theme.of(context).colorScheme.primary
                                  //       : null,
                                  //   onPressed: () {
                                  //     ref
                                  //         .read(createTabStreamProvider.notifier)
                                  //         .createTab(
                                  //           CreateTabSheet(
                                  //             preferredTool: KagiTool.summarizer,
                                  //           ),
                                  //         );
                                  //   },
                                  //   icon: Icon(KagiTool.summarizer.icon),
                                  // ),
                                  // if (showEarlyAccessFeatures)
                                  //   IconButton(
                                  //     color: (activeTool == KagiTool.assistant)
                                  //         ? Theme.of(context).colorScheme.primary
                                  //         : null,
                                  //     onPressed: () {
                                  //       ref
                                  //           .read(
                                  //             createTabStreamProvider.notifier,
                                  //           )
                                  //           .createTab(
                                  //             CreateTabSheet(
                                  //               preferredTool: KagiTool.assistant,
                                  //             ),
                                  //           );
                                  //     },
                                  //     icon: Icon(KagiTool.assistant.icon),
                                  //   ),
                                ],
                              );
                            },
                          ),
                  actions: [
                    if (selectedTabId != null &&
                        displayedSheet is! ViewTabsSheet)
                      ReaderButton(),
                    // if (quickAction != null)
                    //   InkWell(
                    //     onTap: () async {
                    //       var tab = CreateTabSheet(
                    //         preferredTool: quickAction,
                    //       );

                    //       if (quickActionVoice) {
                    //         final completer = Completer<String>();

                    //         final isServiceAvailable =
                    //             await SpeechToTextGoogleDialog.getInstance()
                    //                 .showGoogleDialog(
                    //           onTextReceived: (data) {
                    //             completer.complete(data.toString());
                    //           },
                    //           // locale: "en-US",
                    //         );

                    //         if (!isServiceAvailable) {
                    //           if (context.mounted) {
                    //             ui_helper.showErrorMessage(
                    //               context,
                    //               'Service is not available',
                    //             );
                    //           }
                    //         }

                    //         tab = CreateTabSheet(
                    //           preferredTool: quickAction,
                    //           content: await completer.future,
                    //         );
                    //       }

                    //       ref
                    //           .read(createTabStreamProvider.notifier)
                    //           .createTab(tab);
                    //     },
                    //     child: Padding(
                    //       padding: const EdgeInsets.symmetric(
                    //         vertical: 15.0,
                    //         horizontal: 8.0,
                    //       ),
                    //       child: Icon(
                    //         quickActionVoice ? Icons.mic : quickAction.icon,
                    //       ),
                    //     ),
                    //   ),
                    MenuAnchor(
                      controller: tabMenuController,
                      builder: (context, controller, child) {
                        return child!;
                      },
                      menuChildren: [
                        if (selectedTabId != null)
                          MenuItemButton(
                            onPressed: () async {
                              await ref
                                  .read(tabRepositoryProvider.notifier)
                                  .closeTab(selectedTabId);
                            },
                            leadingIcon: const Icon(Icons.close),
                            child: const Text('Close Tab'),
                          ),
                        MenuItemButton(
                          onPressed: () async {
                            await context.push(const SearchRoute().location);
                          },
                          leadingIcon: const Icon(Icons.add),
                          child: const Text('Add Tab'),
                        ),
                      ],
                      child: TabsActionButton(
                        isActive: displayedSheet is ViewTabsSheet,
                        onTap: () {
                          if (displayedSheet case ViewTabsSheet()) {
                            ref
                                .read(bottomSheetControllerProvider.notifier)
                                .dismiss();
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
                            await context.push(AboutRoute().location);
                          },
                          leadingIcon: const Icon(Icons.info),
                          child: const Text('About'),
                        ),
                        const Divider(),
                        MenuItemButton(
                          onPressed: () async {
                            await context.push(SettingsRoute().location);
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
                                    await addonService
                                        .startAddonManagerActivity();
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
                            await context.push(TorProxyRoute().location);
                          },
                          leadingIcon: const Icon(TorIcons.onionAlt),
                          child: const Text('Tor'),
                        ),
                        const Divider(),
                        MenuItemButton(
                          onPressed: () async {
                            await context.push(BangCategoriesRoute().location);
                          },
                          leadingIcon: const Icon(MdiIcons.exclamationThick),
                          child: const Text('Bangs'),
                        ),
                        // if (showEarlyAccessFeatures)
                        //   MenuItemButton(
                        //     onPressed: () async {
                        //       await context
                        //           .push(ChatArchiveListRoute().location);
                        //     },
                        //     leadingIcon: const Icon(MdiIcons.archive),
                        //     child: const Text('Chat Archive'),
                        //   ),
                        // const Divider(),
                        // if (showEarlyAccessFeatures)
                        //   MenuItemButton(
                        //     onPressed: () {
                        //       ref
                        //           .read(createTabStreamProvider.notifier)
                        //           .createTab(
                        //             CreateTabSheet(
                        //               preferredTool: KagiTool.assistant,
                        //             ),
                        //           );
                        //     },
                        //     leadingIcon: Icon(KagiTool.assistant.icon),
                        //     child: const Text('Assistant'),
                        //   ),
                        // MenuItemButton(
                        //   onPressed: () {
                        //     ref
                        //         .read(createTabStreamProvider.notifier)
                        //         .createTab(
                        //           CreateTabSheet(
                        //             preferredTool: KagiTool.summarizer,
                        //           ),
                        //         );
                        //   },
                        //   leadingIcon: Icon(KagiTool.summarizer.icon),
                        //   child: const Text('Summarizer'),
                        // ),
                        // MenuItemButton(
                        //   onPressed: () {
                        //     ref
                        //         .read(createTabStreamProvider.notifier)
                        //         .createTab(
                        //           CreateTabSheet(
                        //             preferredTool: KagiTool.search,
                        //           ),
                        //         );
                        //   },
                        //   leadingIcon: Icon(KagiTool.search.icon),
                        //   child: const Text('Search'),
                        // ),
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
                                await Share.shareUri(url);
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
                                  .read(
                                    findInPageVisibilityControllerProvider
                                        .notifier,
                                  )
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
                                tabSessionProvider(
                                  tabId: selectedTabId,
                                ).notifier,
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

                              return Row(
                                children: [
                                  Expanded(
                                    child:
                                        (history?.canGoBack == true)
                                            ? IconButton(
                                              onPressed: () async {
                                                final controller = ref.read(
                                                  tabSessionProvider(
                                                    tabId: selectedTabId,
                                                  ).notifier,
                                                );

                                                await controller.goBack();
                                                trippleDotMenuController
                                                    .close();
                                              },
                                              icon: const Icon(
                                                Icons.arrow_back,
                                              ),
                                            )
                                            : IconButton(
                                              onPressed: () async {
                                                await ref
                                                    .read(
                                                      tabRepositoryProvider
                                                          .notifier,
                                                    )
                                                    .closeTab(selectedTabId);
                                                trippleDotMenuController
                                                    .close();
                                              },
                                              icon: const Icon(Icons.close),
                                            ),
                                  ),
                                  const SizedBox(
                                    height: 48,
                                    child: VerticalDivider(),
                                  ),
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
                                                trippleDotMenuController
                                                    .close();
                                              }
                                              : null,
                                      icon: const Icon(Icons.arrow_forward),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        MenuItemButton(
                          onPressed: () async {
                            await context.push(UserAuthRoute().location);
                          },
                          leadingIcon: const Icon(Icons.info),
                          child: const Text('Auth'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        body: DragTarget<TabDragData>(
          onMove: (details) {
            ref
                .read(willAcceptDropProvider.notifier)
                .setData(DeleteDropData(details.data.tabId));
          },
          onLeave: (data) {
            ref.read(willAcceptDropProvider.notifier).clear();
          },
          onAcceptWithDetails: (details) async {
            await ref
                .read(tabRepositoryProvider.notifier)
                .closeTab(details.data.tabId);
          },
          builder: (context, _, __) {
            return OverlayPortal(
              controller: overlayController,
              overlayChildBuilder: (context) {
                return displayedOverlayDialog!;
              },
              child: Listener(
                onPointerDown:
                    (displayedSheet != null)
                        ? (_) {
                          ref
                              .read(bottomSheetControllerProvider.notifier)
                              .dismiss();
                        }
                        : null,
                child: HookConsumer(
                  builder: (context, ref, child) {
                    return BackButtonListener(
                      onBackButtonPressed: () async {
                        final tabState =
                            (selectedTabId != null)
                                ? ref.read(tabStateProvider(selectedTabId))
                                : null;

                        final tabCount = ref.read(
                          tabListProvider.select((tabs) => tabs.length),
                        );

                        //Don't do anything if a child route is active
                        if (GoRouterState.of(context).topRoute?.path !=
                            BrowserRoute().location) {
                          return false;
                        }

                        if (displayedSheet != null) {
                          ref
                              .read(bottomSheetControllerProvider.notifier)
                              .dismiss();
                          return true;
                        }

                        if (displayedOverlayDialog != null) {
                          ref
                              .read(overlayDialogControllerProvider.notifier)
                              .dismiss();
                          return true;
                        }

                        if (tabState?.isFullScreen == true) {
                          await ref
                              .read(selectedTabSessionNotifierProvider)
                              .exitFullscreen();
                          return true;
                        }

                        if (tabState?.historyState.canGoBack == true) {
                          lastBackButtonPress.value = null;

                          final controller = ref.read(
                            tabSessionProvider(tabId: selectedTabId).notifier,
                          );

                          await controller.goBack();
                          return true;
                        }

                        if (lastBackButtonPress.value != null &&
                            DateTime.now().difference(
                                  lastBackButtonPress.value!,
                                ) <
                                const Duration(seconds: 2)) {
                          lastBackButtonPress.value = null;

                          if (tabState != null && tabCount > 1) {
                            await ref
                                .read(tabRepositoryProvider.notifier)
                                .closeTab(tabState.id);
                            return true;
                          } else {
                            //Mark back as unhandled and navigator will pop
                            return false;
                          }
                        } else {
                          lastBackButtonPress.value = DateTime.now();
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              SnackBar(
                                content:
                                    (tabCount > 1)
                                        ? const Text(
                                          'Please click BACK again to close current tab',
                                        )
                                        : const Text(
                                          'Please click BACK again to exit app',
                                        ),
                              ),
                            );

                          return true;
                        }
                      },
                      child: Stack(
                        children: [
                          SafeArea(
                            child: Stack(
                              children: [
                                const BrowserView(),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final value = ref.watch(
                                        selectedTabStateProvider.select((
                                          state,
                                        ) {
                                          if (state?.isLoading == true) {
                                            return state?.progress ?? 100;
                                          }

                                          //When not loading we assumed finished
                                          return 100;
                                        }),
                                      );

                                      return Visibility(
                                        visible: value < 100,
                                        child: LinearProgressIndicator(
                                          value: value / 100,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final value = ref.watch(
                                        selectedTabStateProvider.select(
                                          (state) => EdgeInsets.only(
                                            bottom:
                                                (state?.isLoading == true &&
                                                        state?.progress !=
                                                            null &&
                                                        state!.progress < 100)
                                                    ? 4.0
                                                    : 0.0,
                                          ),
                                        ),
                                      );

                                      return FindInPageWidget(padding: value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (displayedSheet != null)
                            ModalBarrier(
                              color:
                                  Theme.of(context).dialogTheme.barrierColor ??
                                  Colors.black54,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        floatingActionButton: ReaderAppearanceButton(),
        bottomSheet:
            (displayedSheet != null)
                ? NotificationListener<DraggableScrollableNotification>(
                  onNotification: (notification) {
                    if (notification.extent <= 0.1) {
                      ref
                          .read(bottomSheetControllerProvider.notifier)
                          .dismiss();
                      return true;
                    } else {
                      ref
                          .read(bottomSheetExtendProvider.notifier)
                          .add(notification.extent);
                    }

                    return false;
                  },
                  child: switch (displayedSheet) {
                    ViewTabsSheet() => HookBuilder(
                      builder: (localContext) {
                        final draggableScrollableController =
                            useDraggableScrollableController();

                        return DraggableScrollableSheet(
                          key: ValueKey(displayedSheet),
                          controller: draggableScrollableController,
                          expand: false,
                          minChildSize: 0.1,
                          maxChildSize: _realtiveSafeArea(context),
                          builder: (context, scrollController) {
                            return ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(28),
                                topRight: Radius.circular(28),
                              ),
                              child: ViewTabsSheetWidget(
                                sheetScrollController: scrollController,
                                draggableScrollableController:
                                    draggableScrollableController,
                                onClose: () {
                                  ref
                                      .read(
                                        bottomSheetControllerProvider.notifier,
                                      )
                                      .dismiss();
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                    final CreateTabSheet parameter => DraggableScrollableSheet(
                      key: ValueKey(displayedSheet),
                      expand: false,
                      initialChildSize: 0.8,
                      minChildSize: 0.1,
                      maxChildSize: _realtiveSafeArea(context),
                      builder: (context, scrollController) {
                        return SingleChildScrollView(
                          controller: scrollController,
                          child: CreateTabSheetWidget(
                            key: ValueKey(parameter),
                            parameter: parameter,
                            onSubmit: (url) async {
                              await ref
                                  .read(tabRepositoryProvider.notifier)
                                  .addTab(url: url);

                              ref
                                  .read(bottomSheetControllerProvider.notifier)
                                  .dismiss();
                            },
                            onActiveToolChanged: (tool) {
                              activeKagiTool.value = tool;
                            },
                          ),
                        );
                      },
                    ),
                    final TabQaChatSheet parameter => HookBuilder(
                      builder: (localContext) {
                        final draggableScrollableController =
                            useDraggableScrollableController();

                        return DraggableScrollableSheet(
                          key: ValueKey(displayedSheet),
                          controller: draggableScrollableController,
                          expand: false,
                          minChildSize: 0.1,
                          maxChildSize: _realtiveSafeArea(context),
                          builder: (context, scrollController) {
                            return ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(28),
                                topRight: Radius.circular(28),
                              ),
                              child: Column(
                                children: [
                                  DraggableScrollableHeader(
                                    controller: draggableScrollableController,
                                    child: Material(
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Center(
                                          child: Container(
                                            width: 40,
                                            height: 4,
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 16.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TabQaChat(
                                      chatId: parameter.chatId,
                                      scrollController: scrollController,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  },
                )
                : null,
      ),
    );
  }
}
