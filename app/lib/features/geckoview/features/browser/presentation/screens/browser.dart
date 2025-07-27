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
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/global_drop.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/data/models/drag_data.dart';
import 'package:weblibre/extensions/media_query.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/controllers/overlay.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tree_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/browser_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/draggable_scrollable_header.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/view_tabs.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/widgets/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/widgets/reader_appearance_button.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class BrowserScreen extends HookConsumerWidget {
  Duration get _backButtonPressTimeout => const Duration(seconds: 2);

  const BrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventService = ref.watch(eventServiceProvider);

    final displayedSheet = ref.watch(bottomSheetControllerProvider);
    final displayedOverlay = ref.watch(overlayControllerProvider);

    final lastBackButtonPress = useRef<DateTime?>(null);

    final overlayController = useOverlayPortalController();

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
        await ContextMenuRoute(event.hitResult.toJson()).push(context);
      },
    );

    return PopScope(
      //We need this for BackButtonListener to work downstream
      //No direct pop result will be handled here
      canPop: false,
      child: Theme(
        data: Theme.of(context).copyWith(
          bottomSheetTheme: BottomSheetThemeData(
            //Remove M3 default of 640p
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
                child: BrowserBottomAppBar(displayedSheet: displayedSheet),
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
              ref.read(willAcceptDropProvider.notifier).clear();
              await ref
                  .read(tabRepositoryProvider.notifier)
                  .closeTab(details.data.tabId);
            },
            builder: (context, _, _) {
              return OverlayPortal(
                controller: overlayController,
                overlayChildBuilder: (context) {
                  return displayedOverlay!;
                },
                child: Listener(
                  onPointerDown: (displayedSheet != null)
                      ? (_) {
                          ref
                              .read(bottomSheetControllerProvider.notifier)
                              .dismiss();
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

                      if (displayedSheet != null) {
                        ref
                            .read(bottomSheetControllerProvider.notifier)
                            .dismiss();
                        return true;
                      }

                      if (displayedOverlay != null) {
                        ref.read(overlayControllerProvider.notifier).dismiss();
                        return true;
                      }

                      if (tabState?.isFullScreen == true) {
                        await ref
                            .read(selectedTabSessionNotifierProvider)
                            .exitFullscreen();
                        return true;
                      }

                      if (tabState?.isLoading == true) {
                        lastBackButtonPress.value = null;

                        final controller = ref.read(
                          selectedTabSessionNotifierProvider,
                        );

                        await controller.stopLoading();
                        return true;
                      } else if (tabState?.historyState.canGoBack == true) {
                        lastBackButtonPress.value = null;

                        final controller = ref.read(
                          selectedTabSessionNotifierProvider,
                        );

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
                          DateTime.now().difference(
                                lastBackButtonPress.value!,
                              ) <
                              _backButtonPressTimeout) {
                        lastBackButtonPress.value = null;

                        if (tabState != null && tabCount > 1) {
                          await ref
                              .read(tabRepositoryProvider.notifier)
                              .closeTab(tabState.id);
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
                    child: _BrowserView(displayedSheet: displayedSheet),
                  ),
                ),
              );
            },
          ),
          floatingActionButton: ReaderAppearanceButton(),
          bottomSheet: (displayedSheet != null)
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
                    ViewTabsSheet() => _ViewTabsSheet(
                      key: ValueKey(displayedSheet),
                      maxChildSize: MediaQuery.of(context).relativeSafeArea(),
                    ),
                    final TabQaChatSheet parameter => _QaSheet(
                      key: ValueKey(displayedSheet),
                      maxChildSize: MediaQuery.of(context).relativeSafeArea(),
                      chatId: parameter.chatId,
                    ),
                  },
                )
              : null,
        ),
      ),
    );
  }
}

class _BrowserView extends StatelessWidget {
  const _BrowserView({required this.displayedSheet});

  final Sheet? displayedSheet;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
        if (displayedSheet != null)
          ModalBarrier(
            color: Theme.of(context).dialogTheme.barrierColor ?? Colors.black54,
          ),
      ],
    );
  }
}

class _QaSheet extends HookConsumerWidget {
  final String chatId;
  final double maxChildSize;

  const _QaSheet({super.key, required this.chatId, this.maxChildSize = 1.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draggableScrollableController = useDraggableScrollableController();

    return DraggableScrollableSheet(
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
                        margin: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ViewTabsSheet extends HookConsumerWidget {
  final double maxChildSize;

  const _ViewTabsSheet({super.key, this.maxChildSize = 1.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draggableScrollableController = useDraggableScrollableController();

    final treeModeEnabled = ref.watch(treeViewControllerProvider);

    return DraggableScrollableSheet(
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
          child: treeModeEnabled
              ? ViewTabTreesSheetWidget(
                  sheetScrollController: scrollController,
                  onClose: () {
                    ref.read(bottomSheetControllerProvider.notifier).dismiss();
                  },
                )
              : ViewTabsSheetWidget(
                  sheetScrollController: scrollController,
                  draggableScrollableController: draggableScrollableController,
                  onClose: () {
                    ref.read(bottomSheetControllerProvider.notifier).dismiss();
                  },
                ),
        );
      },
    );
  }
}
