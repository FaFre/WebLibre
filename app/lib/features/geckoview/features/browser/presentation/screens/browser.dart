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
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/draggable_fab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/navigation_drawer.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/view_tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_grid_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_list_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_tree_view.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/widgets/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Callback for toolbar animation progress updates.
/// [progress] is 0.0 when hidden, 1.0 when fully visible.
/// [heightPx] is the toolbar height in pixels.
typedef ToolbarAnimationCallback =
    void Function(double progress, double heightPx);

/// Animated toolbar that slides in/out without changing layout constraints.
/// Uses SlideTransition to animate visual transform while maintaining
/// constant intrinsic size for layout purposes.
class _AnimatedToolbar extends HookWidget {
  final bool visible;
  final TabBarPosition position;
  final Widget child;
  final double toolbarHeight;
  final ToolbarAnimationCallback? onAnimationProgress;

  static const _kAnimationDuration = Duration(milliseconds: 250);

  const _AnimatedToolbar({
    required this.visible,
    required this.position,
    required this.child,
    required this.toolbarHeight,
    // ignore: unused_element_parameter
    this.onAnimationProgress,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: _kAnimationDuration,
      initialValue: visible ? 1.0 : 0.0,
    );

    // Listen to animation changes and report progress
    useEffect(() {
      if (onAnimationProgress == null) return null;

      void listener() {
        onAnimationProgress?.call(controller.value, toolbarHeight);
      }

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [onAnimationProgress, toolbarHeight]);

    useEffect(() {
      if (visible) {
        unawaited(controller.forward());
      } else {
        unawaited(controller.reverse());
      }
      return null;
    }, [visible]);

    final slideAnimation = useMemoized(() {
      final begin = position == TabBarPosition.top
          ? const Offset(0, -1)
          : const Offset(0, 1);

      return Tween<Offset>(begin: begin, end: Offset.zero).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOutQuart),
      );
    }, [position]);

    return SlideTransition(position: slideAnimation, child: child);
  }
}

/// Manages scroll-based auto-hide logic and returns the toolbar widget.
/// Animation is handled by the parent _AnimatedToolbar wrapper.
class _TabBar extends HookConsumerWidget {
  final bool showMainToolbar;
  final bool showContextualToolbar;
  final bool showQuickTabSwitcherBar;
  final ValueNotifier<bool> displayAppBar;
  final Stream<Offset>? pointerMoveEvents;
  final TabBarPosition tabBarPosition;

  const _TabBar({
    required this.showMainToolbar,
    required this.showContextualToolbar,
    required this.showQuickTabSwitcherBar,
    required this.displayAppBar,
    required this.tabBarPosition,
    required this.pointerMoveEvents,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabId = ref.watch(selectedTabProvider);
    final displayedSheet = ref.watch(bottomSheetControllerProvider);

    final autoHideTabBar = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.autoHideTabBar,
      ),
    );

    // Auto-hide scroll detection hooks (run unconditionally per hook rules)
    final diffAcc = useRef(0.0);

    void resetHiddenState() {
      if (!ref.read(tabBarDismissableControllerProvider)) {
        displayAppBar.value = true;
      }
      diffAcc.value = 0.0;
    }

    useEffect(() {
      if (!autoHideTabBar) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        resetHiddenState();
      });
      return null;
    }, [tabId, autoHideTabBar]);

    useOnAppLifecycleStateChange((previous, current) {
      if (!ref.read(generalSettingsWithDefaultsProvider).autoHideTabBar) return;
      if (current == AppLifecycleState.resumed) {
        resetHiddenState();
      }
    });

    ref.listen(tabStateProvider(tabId).select((value) => value?.isLoading), (
      previous,
      next,
    ) {
      if (!ref.read(generalSettingsWithDefaultsProvider).autoHideTabBar) return;
      if (next == true) {
        resetHiddenState();
      }
    });

    ref.listen(tabStateProvider(tabId).select((value) => value?.historyState), (
      previous,
      next,
    ) {
      if (!ref.read(generalSettingsWithDefaultsProvider).autoHideTabBar) return;
      if (next != null && previous != null) {
        if (previous != next) {
          resetHiddenState();
        }
      }
    });

    useOnStreamChange(
      pointerMoveEvents,
      onData: (event) {
        if (!ref.read(generalSettingsWithDefaultsProvider).autoHideTabBar) {
          return;
        }
        // Don't apply auto-hide when toolbar is manually dismissed
        if (ref.read(tabBarDismissableControllerProvider)) {
          return;
        }

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

    // Return the toolbar widget - parent handles animation
    return switch (tabBarPosition) {
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
    };
  }
}

class BrowserScreen extends HookConsumerWidget {
  const BrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventService = ref.watch(eventServiceProvider);
    final viewportService = ref.watch(viewportServiceProvider);

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

    final autoHideTabBar = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.autoHideTabBar,
      ),
    );

    final displayAppBar = useValueNotifier(true);

    ref.listen(tabBarDismissableControllerProvider, (previous, next) {
      displayAppBar.value = !next;
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

    final pointerMoveEventsController = useStreamController<Offset>();

    // Watch sheet state for rendering in Stack
    final displayedSheet = ref.watch(bottomSheetControllerProvider);
    final sheetDisplayed = displayedSheet != null;

    // Compute visibility states for toolbars
    final appBarVisible = useValueListenable(displayAppBar);

    // Toolbar is visible when: sheet is shown OR (not fullscreen AND app bar visible)
    // appBarVisible reflects both scroll-based auto-hide and swipe dismiss state
    final topToolbarVisible =
        sheetDisplayed || (!tabInFullScreen && appBarVisible);
    final bottomToolbarVisible =
        sheetDisplayed || (!tabInFullScreen && appBarVisible);

    // Calculate relative safe area for sheet max size
    final relativeSafeArea = MediaQuery.of(context).relativeSafeArea();
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    // Calculate bottom toolbar size for FAB and sheet positioning
    // Pass actual displayedSheet to get correct height when ViewTabsSheet hides main toolbar
    final bottomAppBarContentSize = BrowserBottomAppBar(
      showMainToolbar: tabBarPosition == TabBarPosition.bottom,
      showContextualToolbar: showContextualToolbar,
      showQuickTabSwitcherBar: showQuickTabSwitcherBar,
      displayedSheet: displayedSheet,
    ).preferredSize;
    // Total height includes safe area padding
    final bottomAppBarTotalHeight =
        bottomAppBarContentSize.height + bottomSafeArea;

    // When auto-hide is disabled, constrain browser to not extend behind toolbar
    // (unless toolbar is manually dismissed via swipe gesture)
    final browserBottomOffset = (!autoHideTabBar && bottomToolbarVisible)
        ? bottomAppBarTotalHeight
        : 0.0;

    // Calculate top toolbar size for browser offset
    final topSafeArea = MediaQuery.of(context).padding.top;
    final topAppBarContentSize = BrowserTopAppBar(
      showMainToolbar: tabBarPosition == TabBarPosition.top,
      showContextualToolbar: showContextualToolbar,
      showQuickTabSwitcherBar: showQuickTabSwitcherBar,
    ).preferredSize;
    final topAppBarTotalHeight = topAppBarContentSize.height + topSafeArea;

    // For top bar: always constrain browser below toolbar when visible
    // (unlike bottom bar which only constrains when auto-hide is disabled)
    // This ensures top-of-page content is always accessible
    final browserTopOffset =
        (tabBarPosition == TabBarPosition.top && topToolbarVisible)
        ? topAppBarTotalHeight
        : 0.0;

    // Get pixel ratio for converting logical pixels to physical pixels
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Watch find-in-page visibility for the selected tab
    final selectedTabId = ref.watch(selectedTabProvider);
    final findInPageVisible =
        selectedTabId != null &&
        ref.watch(
          findInPageControllerProvider(
            selectedTabId,
          ).select((state) => state.visible),
        );

    // Find in page widget height from the widget constant
    final findInPageHeight = findInPageVisible
        ? FindInPageWidget.findInPageHeight
        : 0.0;

    // Set up GeckoView dynamic toolbar height
    // This tells GeckoView the maximum toolbar space so it can adjust viewport
    final baseToolbarHeight = bottomToolbarVisible
        ? bottomAppBarTotalHeight
        : 0.0;
    final totalToolbarHeight = findInPageVisible
        ? baseToolbarHeight + findInPageHeight
        : baseToolbarHeight;
    final toolbarHeightPx = (totalToolbarHeight * pixelRatio).round();

    useEffect(() {
      final lastKeyboardEvent = viewportService.keyboardEvents.valueOrNull;

      if (lastKeyboardEvent == null || !lastKeyboardEvent.isVisible) {
        unawaited(viewportService.setDynamicToolbarMaxHeight(toolbarHeightPx));
      }

      return null;
    }, [toolbarHeightPx]);

    // Listen to keyboard visibility changes from native
    useOnStreamChange(
      viewportService.keyboardEvents,
      onData: (event) {
        if (event.isVisible && event.heightPx > 0) {
          // When keyboard is visible, notify GeckoView to adjust viewport
          // This uses the native API to handle keyboard without Flutter resize
          // If find-in-page is also visible, add its height to the keyboard height
          final findInPageHeightPx = findInPageVisible
              ? (FindInPageWidget.findInPageHeight * pixelRatio).round()
              : 0;
          unawaited(
            viewportService.setDynamicToolbarMaxHeight(
              event.heightPx + findInPageHeightPx,
            ),
          );
        }
      },
    );

    // Theme with dynamic snackbar margin to position above bottom toolbar
    final themeData = Theme.of(context).copyWith(
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
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        insetPadding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom:
              (bottomToolbarVisible ? bottomAppBarContentSize.height + 8 : 16) +
              (findInPageVisible ? findInPageHeight : 0),
        ),
      ),
    );

    return PopScope(
      //We need this for BackButtonListener to work downstream
      //No direct pop result will be handled here
      canPop: false,
      child: Theme(
        data: themeData,
        child: Scaffold(
          // Minimal scaffold - only for Material overlay support (SnackBars)
          resizeToAvoidBottomInset: false,
          endDrawer: const BrowserNavigationDrawer(),
          endDrawerEnableOpenDragGesture: false,
          body: Stack(
            children: [
              // Layer 0: Browser content
              // Position changes instantly (no animation) to avoid jarring native view resize
              // The toolbar itself animates, providing visual continuity
              Positioned(
                left: 0,
                right: 0,
                top: browserTopOffset,
                bottom: browserBottomOffset,
                child: _Browser(
                  overlayController: overlayController,
                  displayAppBar: displayAppBar,
                  tabInFullScreen: tabInFullScreen,
                  pointerMoveEventSink: pointerMoveEventsController.sink,
                  sheetDisplayed: sheetDisplayed,
                  hasTopBarOffset: browserTopOffset > 0,
                ),
              ),

              // Layer 1: Sheet (when displayed) - positioned above toolbar
              if (sheetDisplayed)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: bottomAppBarTotalHeight,
                  child: _SheetContainer(
                    displayedSheet: displayedSheet,
                    relativeSafeArea: relativeSafeArea,
                    bottomAppBarHeight: bottomAppBarTotalHeight,
                  ),
                ),

              // Layer 2: Bottom Toolbar (overlay, slides in/out)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _AnimatedToolbar(
                  position: TabBarPosition.bottom,
                  visible: bottomToolbarVisible,
                  toolbarHeight: bottomAppBarTotalHeight,
                  child: _TabBar(
                    tabBarPosition: TabBarPosition.bottom,
                    displayAppBar: displayAppBar,
                    showMainToolbar: tabBarPosition == TabBarPosition.bottom,
                    showContextualToolbar: showContextualToolbar,
                    showQuickTabSwitcherBar: showQuickTabSwitcherBar,
                    // Only subscribe to scroll events when this is the active position
                    pointerMoveEvents: tabBarPosition == TabBarPosition.bottom
                        ? pointerMoveEventsController.stream
                        : null,
                  ),
                ),
              ),

              // Layer 3: Top Toolbar (overlay, slides in/out) - only when position is top
              if (tabBarPosition == TabBarPosition.top)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: _AnimatedToolbar(
                    position: TabBarPosition.top,
                    visible: topToolbarVisible,
                    toolbarHeight: topAppBarTotalHeight,
                    child: _TabBar(
                      tabBarPosition: TabBarPosition.top,
                      showMainToolbar: true,
                      displayAppBar: displayAppBar,
                      showContextualToolbar: showContextualToolbar,
                      showQuickTabSwitcherBar: showQuickTabSwitcherBar,
                      pointerMoveEvents: pointerMoveEventsController.stream,
                    ),
                  ),
                ),

              // Layer 4: FAB (draggable via long press)
              DraggableFab(
                bottomToolbarVisible: bottomToolbarVisible,
                bottomAppBarHeight: bottomAppBarTotalHeight,
                bottomSafeArea: bottomSafeArea,
                child: const BrowserFab(),
              ),

              // Layer 5: Page load progress indicator (animates with toolbar visibility)
              AnimatedPositioned(
                duration: _AnimatedToolbar._kAnimationDuration,
                curve: Curves.easeInOutQuart,
                left: 0,
                right: 0,
                top: tabBarPosition == TabBarPosition.top && topToolbarVisible
                    ? topAppBarTotalHeight
                    : null,
                bottom:
                    tabBarPosition == TabBarPosition.bottom &&
                        bottomToolbarVisible
                    ? bottomAppBarTotalHeight
                    : tabBarPosition == TabBarPosition.bottom
                    ? 0
                    : null,
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

              // Layer 6: Find in Page widget (above toolbar or keyboard, whichever is higher)
              AnimatedPositioned(
                duration: _AnimatedToolbar._kAnimationDuration,
                curve: Curves.easeInOutQuart,
                left: 0,
                right: 0,
                bottom: math.max(
                  bottomToolbarVisible
                      ? bottomAppBarTotalHeight
                      : bottomSafeArea,
                  MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final tabId = ref.watch(selectedTabProvider);
                    if (tabId == null) {
                      return const SizedBox.shrink();
                    }
                    return FindInPageWidget(key: ValueKey(tabId), tabId: tabId);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Container widget for bottom sheets - renders in Stack for proper layering.
class _SheetContainer extends HookConsumerWidget {
  final Sheet displayedSheet;
  final double relativeSafeArea;
  final double bottomAppBarHeight;

  const _SheetContainer({
    required this.displayedSheet,
    required this.relativeSafeArea,
    required this.bottomAppBarHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    bool dismissOnThreshold(DraggableScrollableNotification notification) {
      if (notification.extent <= 0.1) {
        logger.i('Dismissing sheet, reached min extend');
        ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
        return true;
      }
      return false;
    }

    return GestureDetector(
      onTap: () {
        // Dismiss sheet when tapping outside
        ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
      },
      child: ColoredBox(
        color: colorScheme.scrim.withValues(alpha: 0.5),
        child: GestureDetector(
          onTap: () {}, // Prevent tap from propagating to parent
          child: Align(
            alignment: Alignment.bottomCenter,
            child: switch (displayedSheet) {
              ViewTabsSheet() =>
                NotificationListener<DraggableScrollableNotification>(
                  onNotification: dismissOnThreshold,
                  child: _ViewTabsSheet(maxChildSize: relativeSafeArea),
                ),
              final SiteSettingsSheet parameter =>
                NotificationListener<DraggableScrollableNotification>(
                  onNotification: dismissOnThreshold,
                  child: _SiteSettingsSheet(
                    initialTabState: parameter.tabState,
                    maxChildSize: relativeSafeArea,
                    bottomAppBarHeight: bottomAppBarHeight,
                  ),
                ),
            },
          ),
        ),
      ),
    );
  }
}

class _Browser extends HookConsumerWidget {
  Duration get _backButtonPressTimeout => const Duration(seconds: 2);

  final OverlayPortalController overlayController;
  final ValueNotifier<bool> displayAppBar;
  final StreamSink<Offset> pointerMoveEventSink;
  final bool tabInFullScreen;
  final bool sheetDisplayed;
  final bool hasTopBarOffset;

  const _Browser({
    required this.overlayController,
    required this.displayAppBar,
    required this.tabInFullScreen,
    required this.pointerMoveEventSink,
    required this.sheetDisplayed,
    required this.hasTopBarOffset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doubleBackCloseTab = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.doubleBackCloseTab),
    );

    final lastBackButtonPress = useRef<DateTime?>(null);

    final overlayBuilder = ref.watch(overlayControllerProvider);

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
            onPointerDown: sheetDisplayed
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

                // Handle double back to close (if enabled)
                if (doubleBackCloseTab) {
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
                }

                return true;
              },
              child: _BrowserView(
                isFullscreen: tabInFullScreen,
                pointerMoveEventSink: pointerMoveEventSink,
                hasTopBarOffset: hasTopBarOffset,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BrowserView extends StatelessWidget {
  final bool isFullscreen;
  final StreamSink<Offset>? pointerMoveEventSink;
  final bool hasTopBarOffset;

  const _BrowserView({
    required this.isFullscreen,
    required this.hasTopBarOffset,
    this.pointerMoveEventSink,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Disable top SafeArea when top bar handles it (has offset applied)
      top: !isFullscreen && !hasTopBarOffset,
      right: !isFullscreen,
      // Bottom SafeArea is handled by the overlay toolbar (BottomAppBar)
      bottom: false,
      left: !isFullscreen,
      child: Stack(
        children: [BrowserView(pointerMoveEventSink: pointerMoveEventSink)],
      ),
    );
  }
}

class _SiteSettingsSheet extends HookConsumerWidget {
  final double maxChildSize;
  final TabState initialTabState;
  final double bottomAppBarHeight;

  static const initialHeight = 0.8;

  const _SiteSettingsSheet({
    required this.initialTabState,
    required this.bottomAppBarHeight,
    this.maxChildSize = 1.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draggableScrollableController = useDraggableScrollableController();

    void handleClearSiteDataExpansion(bool isExpanded) {
      if (isExpanded) {
        unawaited(
          draggableScrollableController.animateTo(
            1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.decelerate,
          ),
        );
      }
    }

    return DraggableScrollableSheet(
      controller: draggableScrollableController,
      expand: false,
      initialChildSize: initialHeight,
      minChildSize: 0.1,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) {
        return Material(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          clipBehavior: Clip.antiAlias,
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
            bottomAppBarHeight: bottomAppBarHeight,
            onClearSiteDataExpandedChanged: handleClearSiteDataExpansion,
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
        return Material(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          clipBehavior: Clip.antiAlias,
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
