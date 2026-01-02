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
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/global_drop.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/data/models/drag_data.dart';
import 'package:weblibre/extensions/media_query.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/controllers/overlay.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_bar_dismissable.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/browser_fab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/browser_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/view_tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_grid_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_list_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_tree_view.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/widgets/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class _TabBar extends HookConsumerWidget {
  final bool showMainToolbar;
  final bool showContextualToolbar;
  final bool showQuickTabSwitcherBar;
  final ValueNotifier<bool> displayAppBar;
  final ValueNotifier<PersistentBottomSheetController?> sheetController;
  final Stream<Offset>? pointerMoveEvents;
  final TabBarPosition tabBarPosition;

  const _TabBar({
    required this.showMainToolbar,
    required this.showContextualToolbar,
    required this.showQuickTabSwitcherBar,
    required this.displayAppBar,
    required this.sheetController,
    required this.tabBarPosition,
    required this.pointerMoveEvents,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabId = ref.watch(selectedTabProvider);
    final displayedSheet = ref.watch(bottomSheetControllerProvider);

    final tabInFullScreen = ref.watch(
      selectedTabStateProvider.select((value) => value?.isFullScreen ?? false),
    );

    final autoHideTabBar = switch (tabBarPosition) {
      TabBarPosition.top => false,
      TabBarPosition.bottom => ref.watch(
        generalSettingsWithDefaultsProvider.select(
          (value) => value.autoHideTabBar,
        ),
      ),
    };

    final appBarVisible = tabBarPosition == TabBarPosition.top
        ? !ref.watch(tabBarDismissableControllerProvider)
        : useValueListenable(displayAppBar);

    if (!autoHideTabBar) {
      return Visibility(
        visible: !tabInFullScreen && appBarVisible,
        child: switch (tabBarPosition) {
          TabBarPosition.top => BrowserTopAppBar(
            showMainToolbar: showMainToolbar,
            showContextualToolbar: showContextualToolbar,
            showQuickTabSwitcherBar: showQuickTabSwitcherBar,
          ),
          TabBarPosition.bottom => BrowserBottomAppBar(
            displayedSheet: displayedSheet,
            showMainToolbar: showMainToolbar,
            showContextualToolbar: showContextualToolbar,
            showQuickTabSwitcherBar: showQuickTabSwitcherBar,
          ),
        },
      );
    }

    final diffAcc = useRef(0.0);

    void resetHiddenState() {
      if (!ref.read(tabBarDismissableControllerProvider)) {
        displayAppBar.value = true;
      }

      diffAcc.value = 0.0;
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        resetHiddenState();
      });

      return null;
    }, [tabId]);

    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.resumed) {
        resetHiddenState();
      }
    });

    ref.listen(tabStateProvider(tabId).select((value) => value?.isLoading), (
      previous,
      next,
    ) {
      if (next == true) {
        resetHiddenState();
      }
    });

    ref.listen(tabStateProvider(tabId).select((value) => value?.historyState), (
      previous,
      next,
    ) {
      if (next != null && previous != null) {
        if (previous != next) {
          resetHiddenState();
        }
      }
    });

    useOnStreamChange(
      pointerMoveEvents,
      onData: (event) {
        final diff = event.dy;
        if (diff < 0) {
          if (diffAcc.value > 0) {
            diffAcc.value = 0.0;
          }

          diffAcc.value += diff;
          if (diffAcc.value.abs() > kToolbarHeight * 1.5) {
            displayAppBar.value = false;
          }
        } else if (diff > 0) {
          if (diffAcc.value < 0) {
            diffAcc.value = 0.0;
          }

          diffAcc.value += diff;
          if (diffAcc.value.abs() > kToolbarHeight) {
            resetHiddenState();
          }
        }
      },
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 125),
      curve: Curves.easeInOut,
      child: Visibility(
        visible:
            sheetController.value != null ||
            (!tabInFullScreen && appBarVisible),
        maintainState: true,
        child: switch (tabBarPosition) {
          TabBarPosition.top => BrowserTopAppBar(
            showMainToolbar: showMainToolbar,
            showContextualToolbar: showContextualToolbar,
            showQuickTabSwitcherBar: showQuickTabSwitcherBar,
          ),
          TabBarPosition.bottom => BrowserBottomAppBar(
            showMainToolbar: showMainToolbar,
            displayedSheet: displayedSheet,
            showContextualToolbar: showContextualToolbar,
            showQuickTabSwitcherBar: showQuickTabSwitcherBar,
          ),
        },
      ),
    );
  }
}

class BrowserScreen extends HookConsumerWidget {
  const BrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventService = ref.watch(eventServiceProvider);

    final tabInFullScreen = ref.watch(
      selectedTabStateProvider.select((value) => value?.isFullScreen ?? false),
    );

    final overlayController = useOverlayPortalController();

    final tabBarPosition = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.tabBarPosition,
      ),
    );

    final showContextualToolbar = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.tabBarShowContextualBar,
      ),
    );

    final showQuickTabSwitcherBar = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.tabBarShowQuickTabSwitcherBar,
      ),
    );

    final displayAppBar = useValueNotifier(true);
    final removeTopAppBar = useState(false);

    ref.listen(tabBarDismissableControllerProvider, (previous, next) {
      displayAppBar.value = !next;
      if (tabBarPosition == TabBarPosition.bottom) {
        removeTopAppBar.value = next;
      }
    });

    ref.listen(overlayControllerProvider, (previous, next) {
      if (next != null) {
        overlayController.show();
      } else {
        overlayController.hide();
      }
    });

    useOnStreamChange(
      eventService.longPressEvent,
      onData: (event) async {
        await ContextMenuRoute(
          hitResult: event.hitResult.toJson(),
        ).push(context);
      },
    );

    final themeData = useMemoized(
      () => Theme.of(context).copyWith(
        bottomSheetTheme: BottomSheetThemeData(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width -
                math.max(
                  MediaQuery.of(context).padding.left * 2,
                  MediaQuery.of(context).padding.right * 2,
                ),
          ),
        ),
      ),
      [],
    );

    final sheetController = useState<PersistentBottomSheetController?>(null);

    final pointerMoveEventsController = useStreamController<Offset>();

    return PopScope(
      //We need this for BackButtonListener to work downstream
      //No direct pop result will be handled here
      canPop: false,
      child: Theme(
        data: themeData,
        child: Scaffold(
          extendBodyBehindAppBar: tabInFullScreen,
          bottomSheetScrimBuilder: (_, _) {
            //This causes issues with a non dismissable barrier pushed, we ahve our own barrier and this does seem to have issues when dismissing, so disable it completely
            return null;
          },
          appBar: (tabBarPosition == TabBarPosition.top)
              ? PreferredSize(
                  preferredSize: BrowserTopAppBar(
                    showMainToolbar: true,
                    showContextualToolbar: showContextualToolbar,
                    showQuickTabSwitcherBar: showQuickTabSwitcherBar,
                  ).preferredSize,
                  child: _TabBar(
                    tabBarPosition: TabBarPosition.top,
                    showMainToolbar: true,
                    displayAppBar: displayAppBar,
                    sheetController: sheetController,
                    showContextualToolbar: showContextualToolbar,
                    showQuickTabSwitcherBar: showQuickTabSwitcherBar,
                    pointerMoveEvents: null,
                  ),
                )
              : removeTopAppBar.value
              ? const PreferredSize(
                  preferredSize: Size.zero,
                  child: SizedBox.shrink(),
                )
              : null,
          bottomNavigationBar: _TabBar(
            tabBarPosition: TabBarPosition.bottom,
            displayAppBar: displayAppBar,
            sheetController: sheetController,
            showMainToolbar: tabBarPosition == TabBarPosition.bottom,
            showContextualToolbar: showContextualToolbar,
            showQuickTabSwitcherBar: showQuickTabSwitcherBar,
            pointerMoveEvents: pointerMoveEventsController.stream,
          ),
          body: _Browser(
            overlayController: overlayController,
            sheetController: sheetController,
            displayAppBar: displayAppBar,
            tabInFullScreen: tabInFullScreen,
            pointerMoveEventSink: pointerMoveEventsController.sink,
            bottomAppBarSize: BrowserBottomAppBar(
              showMainToolbar: false,
              showContextualToolbar: showContextualToolbar,
              showQuickTabSwitcherBar: showQuickTabSwitcherBar,
              displayedSheet: null,
            ).preferredSize,
          ),
          floatingActionButton: const BrowserFab(),
        ),
      ),
    );
  }
}

class _Browser extends HookConsumerWidget {
  Duration get _backButtonPressTimeout => const Duration(seconds: 2);

  final OverlayPortalController overlayController;
  final ValueNotifier<PersistentBottomSheetController?> sheetController;
  final ValueNotifier<bool> displayAppBar;
  final StreamSink<Offset> pointerMoveEventSink;
  final Size bottomAppBarSize;

  final bool tabInFullScreen;

  const _Browser({
    required this.overlayController,
    required this.sheetController,
    required this.displayAppBar,
    required this.tabInFullScreen,
    required this.pointerMoveEventSink,
    required this.bottomAppBarSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastBackButtonPress = useRef<DateTime?>(null);

    final overlayBuilder = ref.watch(overlayControllerProvider);

    ref.listen(bottomSheetControllerProvider, (previous, next) {
      if (!context.mounted) {
        logger.e('Cannot show sheet, context not mounted');
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          logger.e('Cannot show sheet, context not mounted (post frame)');
          return;
        }

        // Close existing sheet
        if (sheetController.value != null) {
          try {
            final existingController = sheetController.value!;
            sheetController.value = null;
            existingController.close();
          } catch (e) {
            logger.e('Error closing existing sheet', error: e);
          }
        }

        // Show new sheet
        if (next != null) {
          try {
            final relativeSafeArea = MediaQuery.of(context).relativeSafeArea();

            final controller = Scaffold.of(context).showBottomSheet((context) {
              logger.i(
                'Building bottom sheet, relativeSafeArea: $relativeSafeArea, mounted: ${context.mounted}',
              );

              bool dismissOnThreshold(
                DraggableScrollableNotification notification,
              ) {
                if (notification.extent <= 0.1) {
                  logger.i('Dismissing sheet, reached min extend');
                  ref
                      .read(bottomSheetControllerProvider.notifier)
                      .requestDismiss();
                  return true;
                }
                return false;
              }

              final sheet = switch (next) {
                ViewTabsSheet() =>
                  NotificationListener<DraggableScrollableNotification>(
                    key: UniqueKey(),
                    onNotification: dismissOnThreshold,
                    child: _ViewTabsSheet(maxChildSize: relativeSafeArea),
                  ),
                final EditUrlSheet parameter =>
                  NotificationListener<DraggableScrollableNotification>(
                    key: UniqueKey(),
                    onNotification: dismissOnThreshold,
                    child: _ViewUrlSheet(
                      initialTabState: parameter.tabState,
                      maxChildSize: relativeSafeArea,
                      bottomAppBarSize: bottomAppBarSize,
                    ),
                  ),
              };

              return sheet;
            });

            unawaited(
              controller.closed.whenComplete(() {
                ref.read(bottomSheetControllerProvider.notifier).closed(next);
              }),
            );

            sheetController.value = controller;
          } catch (e) {
            debugPrint('Failed to show bottom sheet: $e');
          }
        }
      });
    });

    return DragTarget<TabDragData>(
      onMove: (details) {
        ref
            .read(willAcceptDropProvider.notifier)
            .setData(DeleteDropData(details.data.tabId));
      },
      onLeave: (data) {
        ref.read(willAcceptDropProvider.notifier).clear();
      },
      onAcceptWithDetails: (details) async {
        ref.read(willAcceptDropProvider.notifier).clear();
        await ref
            .read(tabRepositoryProvider.notifier)
            .closeTab(details.data.tabId);

        if (context.mounted) {
          ui_helper.showTabUndoClose(
            context,
            ref.read(tabRepositoryProvider.notifier).undoClose,
          );
        }
      },
      builder: (context, _, _) {
        return OverlayPortal(
          controller: overlayController,
          overlayChildBuilder: (context) {
            return overlayBuilder!.call(context);
          },
          child: Listener(
            onPointerDown: sheetController.value != null
                ? (_) {
                    ref
                        .read(bottomSheetControllerProvider.notifier)
                        .requestDismiss();
                  }
                : null,
            child: BackButtonListener(
              onBackButtonPressed: () async {
                final tabState = ref.read(selectedTabStateProvider);

                final tabCount = ref.read(
                  tabListProvider.select((tabs) => tabs.value.length),
                );

                //Don't do anything if a child route is active
                if (GoRouterState.of(context).topRoute?.name !=
                    BrowserRoute.name) {
                  return false;
                }

                if (ref.read(bottomSheetControllerProvider) != null) {
                  ref
                      .read(bottomSheetControllerProvider.notifier)
                      .requestDismiss();
                  return true;
                }

                if (overlayBuilder != null) {
                  ref.read(overlayControllerProvider.notifier).dismiss();
                  return true;
                }

                if (tabState?.isFullScreen == true) {
                  await ref.read(selectedTabSessionProvider).exitFullscreen();
                  return true;
                }

                //Make sure app bar is visible
                if (!ref.read(tabBarDismissableControllerProvider)) {
                  displayAppBar.value = true;
                }

                if (tabState?.isLoading == true) {
                  lastBackButtonPress.value = null;

                  final controller = ref.read(selectedTabSessionProvider);

                  await controller.stopLoading();
                  return true;
                } else if (tabState?.readerableState.active == true) {
                  lastBackButtonPress.value = null;

                  await ref
                      .read(readerableScreenControllerProvider.notifier)
                      .toggleReaderView(false);

                  return true;
                } else if (tabState?.historyState.canGoBack == true) {
                  lastBackButtonPress.value = null;

                  final controller = ref.read(selectedTabSessionProvider);

                  await controller.goBack();
                  return true;
                }

                //Go router has routes to go back to
                if (context.canPop()) {
                  return true;
                }

                if (ref
                    .read(tabRepositoryProvider.notifier)
                    .hasLaunchedFromIntent(tabState?.id)) {
                  //Mark back as unhandled and navigator will pop
                  await SystemNavigator.pop();
                  return false;
                }

                if (lastBackButtonPress.value != null &&
                    DateTime.now().difference(lastBackButtonPress.value!) <
                        _backButtonPressTimeout) {
                  lastBackButtonPress.value = null;

                  if (tabState != null && tabCount > 1) {
                    await ref
                        .read(tabRepositoryProvider.notifier)
                        .closeTab(tabState.id);

                    if (context.mounted) {
                      ui_helper.showTabUndoClose(
                        context,
                        ref.read(tabRepositoryProvider.notifier).undoClose,
                      );
                    }

                    return true;
                  } else {
                    //Mark back as unhandled and navigator will pop
                    await SystemNavigator.pop();
                    return false;
                  }
                } else {
                  lastBackButtonPress.value = DateTime.now();
                  ui_helper.showTabBackButtonMessage(
                    context,
                    tabCount,
                    _backButtonPressTimeout,
                  );

                  return true;
                }
              },
              child: _BrowserView(
                sheetDisplayed: sheetController.value != null,
                isFullscreen: tabInFullScreen,
                pointerMoveEventSink: pointerMoveEventSink,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BrowserView extends StatelessWidget {
  final bool sheetDisplayed;
  final bool isFullscreen;
  final StreamSink<Offset>? pointerMoveEventSink;

  const _BrowserView({
    required this.sheetDisplayed,
    required this.isFullscreen,
    this.pointerMoveEventSink,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          top: !isFullscreen,
          right: !isFullscreen,
          bottom: !isFullscreen,
          left: !isFullscreen,
          child: Stack(
            children: [
              BrowserView(pointerMoveEventSink: pointerMoveEventSink),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Consumer(
                  builder: (context, ref, child) {
                    final value = ref.watch(
                      selectedTabStateProvider.select((state) {
                        if (state?.isLoading == true) {
                          return state?.progress ?? 100;
                        }

                        //When not loading we assumed finished
                        return 100;
                      }),
                    );

                    return Visibility(
                      visible: value < 100,
                      child: LinearProgressIndicator(value: value / 100),
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
                                  state?.progress != null &&
                                  state!.progress < 100)
                              ? 4.0
                              : 0.0,
                        ),
                      ),
                    );

                    final tabId = ref.watch(selectedTabProvider);
                    if (tabId == null) {
                      return const SizedBox.shrink();
                    }

                    return FindInPageWidget(tabId: tabId, padding: value);
                  },
                ),
              ),
            ],
          ),
        ),
        if (sheetDisplayed)
          ModalBarrier(
            color: Theme.of(context).dialogTheme.barrierColor ?? Colors.black54,
          ),
      ],
    );
  }
}

class _ViewUrlSheet extends HookConsumerWidget {
  final double maxChildSize;
  final TabState initialTabState;
  final Size bottomAppBarSize;

  const _ViewUrlSheet({
    required this.initialTabState,
    required this.bottomAppBarSize,
    this.maxChildSize = 1.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draggableScrollableController = useDraggableScrollableController();

    final initialHeight = 172.0 / MediaQuery.of(context).size.height;

    return DraggableScrollableSheet(
      controller: draggableScrollableController,
      expand: false,
      initialChildSize: initialHeight,
      minChildSize: 0.1,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: ViewTabSheetWidget(
            initialTabState: initialTabState,
            sheetScrollController: scrollController,
            draggableScrollableController: draggableScrollableController,
            onClose: () {
              final tabViewBottomSheet = ref
                  .read(generalSettingsWithDefaultsProvider)
                  .tabViewBottomSheet;

              if (tabViewBottomSheet) {
                ref
                    .read(bottomSheetControllerProvider.notifier)
                    .requestDismiss();
              } else {
                const BrowserRoute().go(context);
              }
            },
            initialHeight: initialHeight,
            bottomAppBarHeight: bottomAppBarSize.height,
          ),
        );
      },
    );
  }
}

class _ViewTabsSheet extends HookConsumerWidget {
  final double maxChildSize;

  const _ViewTabsSheet({this.maxChildSize = 1.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsViewMode = ref.watch(tabsViewModeControllerProvider);
    final tabsReorderable = ref.watch(tabsReorderableControllerProvider);

    final draggableScrollableController = useDraggableScrollableController(
      keys: [tabsReorderable],
    );

    return DraggableScrollableSheet(
      key: ValueKey(tabsReorderable),
      controller: draggableScrollableController,
      expand: false,
      minChildSize: 0.1,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: switch (tabsViewMode) {
            TabsViewMode.list => ViewTabListWidget(
              scrollController: scrollController,
              showNewTabFab: true,
              tabsReorderable: tabsReorderable,
              draggableScrollableController: draggableScrollableController,
              onClose: () {
                ref
                    .read(bottomSheetControllerProvider.notifier)
                    .requestDismiss();
              },
            ),
            TabsViewMode.grid => ViewTabGridWidget(
              scrollController: scrollController,
              showNewTabFab: true,
              tabsReorderable: tabsReorderable,
              draggableScrollableController: draggableScrollableController,
              onClose: () {
                ref
                    .read(bottomSheetControllerProvider.notifier)
                    .requestDismiss();
              },
            ),
            TabsViewMode.tree => ViewTabTreesWidget(
              scrollController: scrollController,
              showNewTabFab: true,
              onClose: () {
                ref
                    .read(bottomSheetControllerProvider.notifier)
                    .requestDismiss();
              },
            ),
          },
        );
      },
    );
  }
}
