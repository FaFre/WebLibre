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
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/toolbar_visibility.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/keep_tab_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/providers/browser_viewport_toolbar_insets.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/addon_popup_bottom_sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/browser_fab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/browser_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/draggable_fab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/view_tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_grid_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_list_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_tree_view.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/widgets/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/small_web/presentation/controllers/small_web_mode_controller.dart';
import 'package:weblibre/features/small_web/presentation/widgets/small_web_browser_overlay.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/move_to_background.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class _AnimatedToolbar extends HookWidget {
  final bool visible;
  final TabBarPosition position;
  final Widget child;

  static const _kAnimationDuration = Duration(milliseconds: 250);

  const _AnimatedToolbar({
    required this.visible,
    required this.position,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    final controller = useAnimationController(
      duration: disableAnimations ? Duration.zero : _kAnimationDuration,
      initialValue: visible ? 1.0 : 0.0,
    );

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
  final Stream<Offset>? pointerMoveEvents;
  final TabBarPosition tabBarPosition;
  final bool isSmallWebMode;
  final bool enableGestures;

  const _TabBar({
    required this.showMainToolbar,
    required this.showContextualToolbar,
    required this.showQuickTabSwitcherBar,
    required this.tabBarPosition,
    required this.pointerMoveEvents,
    required this.isSmallWebMode,
    this.enableGestures = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabId = ref.watch(selectedTabProvider);
    final displayedSheet = ref.watch(bottomSheetControllerProvider);

    // Auto-hide scroll detection hooks (run unconditionally per hook rules)
    final diffAcc = useRef(0.0);

    // Reset scroll accumulator on tab switch
    useEffect(() {
      diffAcc.value = 0.0;
      return null;
    }, [tabId]);

    // Reset scroll accumulator when controller shows toolbar
    // (covers: loading start, navigation, showToolbarAsExpanded, forceShow)
    ref.listen(toolbarVisibilityControllerProvider(tabId), (previous, next) {
      if (next == ToolbarVisibility.visible && previous != next) {
        diffAcc.value = 0.0;
      }
    });

    void resetHiddenState() {
      ref
          .read(
            toolbarVisibilityControllerProvider(
              ref.read(selectedTabProvider),
            ).notifier,
          )
          .show();
      diffAcc.value = 0.0;
    }

    useOnAppLifecycleStateChange((previous, current) {
      if (!ref.read(generalSettingsWithDefaultsProvider).autoHideTabBar) return;
      if (current == AppLifecycleState.resumed) {
        resetHiddenState();
      }
    });

    useOnStreamChange(
      pointerMoveEvents,
      onData: (event) {
        final autoHide = ref
            .read(generalSettingsWithDefaultsProvider)
            .autoHideTabBar;
        if (!autoHide) return;

        final diff = event.dy;
        if (diff < 0) {
          if (diffAcc.value > 0) {
            diffAcc.value = 0.0;
          }
          diffAcc.value += diff;
          if (diffAcc.value.abs() > kToolbarHeight * 1.5) {
            ref
                .read(
                  toolbarVisibilityControllerProvider(
                    ref.read(selectedTabProvider),
                  ).notifier,
                )
                .requestHide();
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
        isSmallWebMode: isSmallWebMode,
        enableGestures: enableGestures,
      ),
      TabBarPosition.bottom => BrowserBottomAppBar(
        displayedSheet: displayedSheet,
        showMainToolbar: showMainToolbar,
        showContextualToolbar: showContextualToolbar,
        showQuickTabSwitcherBar: showQuickTabSwitcherBar,
        isSmallWebMode: isSmallWebMode,
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
    final tabIsLoading = ref.watch(
      selectedTabStateProvider.select((value) => value?.isLoading ?? false),
    );

    final overlayController = useOverlayPortalController();

    final isSmallWebActive = ref.watch(
      smallWebModeControllerProvider.select((value) => value != null),
    );

    final tabBarPosition = isSmallWebActive
        ? TabBarPosition.top
        : ref.watch(
            generalSettingsWithDefaultsProvider.select(
              (value) => value.tabBarPosition,
            ),
          );

    final showContextualToolbar =
        !isSmallWebActive &&
        ref.watch(
          generalSettingsWithDefaultsProvider.select(
            (value) => value.tabBarShowContextualBar,
          ),
        );

    final showQuickTabSwitcherBar =
        !isSmallWebActive &&
        ref.watch(
          generalSettingsWithDefaultsProvider.select(
            (value) => value.tabBarShowQuickTabSwitcherBar,
          ),
        );
    final quickTabSwitcherMode = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.effectiveUiQuickTabSwitcherMode(),
      ),
    );
    final quickTabSwitcherHasResults = ref.watch(
      quickTabSwitcherHasResultsProvider(quickTabSwitcherMode),
    );
    final displayQuickTabSwitcherBar =
        showQuickTabSwitcherBar && (quickTabSwitcherHasResults.value ?? false);

    final autoHideTabBar =
        !isSmallWebActive &&
        ref.watch(
          generalSettingsWithDefaultsProvider.select(
            (value) => value.autoHideTabBar,
          ),
        );

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

    final addonService = ref.watch(addonServiceProvider);
    useOnStreamChange(
      addonService.popupStream,
      onData: (event) async {
        await showAddonPopupBottomSheet(
          context,
          extensionId: event.extensionId,
          extensionName: event.extensionName,
        );
      },
    );

    useOnAppLifecycleStateChange((previous, current) {
      switch (current) {
        case AppLifecycleState.resumed:
          if (current != AppLifecycleState.resumed) {
            return;
          }

          if (!ref.read(syncIsAuthenticatedProvider)) {
            return;
          }

          unawaited(() async {
            try {
              final openedTabs = await ref
                  .read(syncRepositoryProvider.notifier)
                  .pollIncomingTabsAndOpen();

              if (openedTabs > 0 && context.mounted) {
                ui_helper.showOpenedTabsFromAnotherDeviceMessage(
                  context,
                  openedTabs,
                );
              }
            } catch (e, s) {
              logger.e(
                'Failed polling incoming sync tabs on resume',
                error: e,
                stackTrace: s,
              );
            }
          }());
        case AppLifecycleState.detached:
        case AppLifecycleState.inactive:
        case AppLifecycleState.hidden:
        case AppLifecycleState.paused:
      }
    });

    final pointerMoveEventsController = useStreamController<Offset>();

    // Watch sheet state for rendering in Stack
    final displayedSheet = ref.watch(bottomSheetControllerProvider);
    final sheetDisplayed = displayedSheet != null;

    // Track selected tab. Toolbar visibility is watched in scoped Consumer
    // widgets below to avoid rebuilding the entire BrowserScreen on every
    // hide/show cycle during scrolling.
    final selectedTabId = ref.watch(selectedTabProvider);

    // Calculate relative safe area for sheet max size
    final relativeSafeArea = MediaQuery.of(context).relativeSafeArea();
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    // Calculate bottom toolbar size for FAB and sheet positioning
    final Size bottomAppBarContentSize;
    if (isSmallWebActive) {
      bottomAppBarContentSize = const Size.fromHeight(
        SmallWebBrowserOverlay.barHeight,
      );
    } else {
      // Pass actual displayedSheet to get correct height when ViewTabsSheet hides main toolbar
      bottomAppBarContentSize = BrowserBottomAppBar(
        showMainToolbar: tabBarPosition == TabBarPosition.bottom,
        showContextualToolbar: showContextualToolbar,
        showQuickTabSwitcherBar: displayQuickTabSwitcherBar,
        isSmallWebMode: false,
        displayedSheet: displayedSheet,
      ).preferredSize;
    }
    // Total height includes safe area padding
    final bottomAppBarTotalHeight =
        bottomAppBarContentSize.height + bottomSafeArea;

    // Calculate top toolbar size for browser offset and progress indicator
    final topSafeArea = MediaQuery.of(context).padding.top;
    final topAppBarContentSize = BrowserTopAppBar(
      showMainToolbar: tabBarPosition == TabBarPosition.top,
      showContextualToolbar: showContextualToolbar,
      showQuickTabSwitcherBar: displayQuickTabSwitcherBar,
      isSmallWebMode: isSmallWebActive,
      enableGestures: !isSmallWebActive,
    ).preferredSize;
    final topAppBarTotalHeight = topAppBarContentSize.height + topSafeArea;

    // Get pixel ratio for converting logical pixels to physical pixels
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Watch find-in-page visibility for the selected tab
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
    final findInPageHeightPx = (findInPageHeight * pixelRatio).round();

    // Track dismissed state without triggering full rebuild on every
    // hide/show. Updated via ref.listen below and synced on tab switch.
    final toolbarDismissed = useState(false);

    // Sync dismissed state when selected tab changes
    useEffect(() {
      toolbarDismissed.value =
          ref.read(toolbarVisibilityControllerProvider(selectedTabId)) ==
          ToolbarVisibility.dismissed;
      return null;
    }, [selectedTabId]);

    final stableToolbarHeight =
        autoHideTabBar && !toolbarDismissed.value && !tabInFullScreen
        ? bottomAppBarTotalHeight
        : 0.0;
    final stableToolbarHeightPx = (stableToolbarHeight * pixelRatio).round();

    // Compute toolbar visibility for keyboard inset math.
    // Uses ref.watch via the toolbarDismissed useState to avoid
    // subscribing to every hide/show toggle.
    final toolbarVisibleForLayout =
        sheetDisplayed || (!tabInFullScreen && !toolbarDismissed.value);

    final keyboardHeightPx = useState<int?>(null);

    useOnStreamChange(
      viewportService.keyboardEvents,
      onData: (event) {
        if (!event.isAnimating) {
          final nextKeyboardHeight = event.isVisible ? event.heightPx : null;
          if (keyboardHeightPx.value != nextKeyboardHeight) {
            keyboardHeightPx.value = nextKeyboardHeight;
          }
        }
      },
    );

    final keyboardVisible = keyboardHeightPx.value != null;

    final bottomLayoutReservedPx = (!autoHideTabBar && toolbarVisibleForLayout)
        ? (bottomAppBarTotalHeight * pixelRatio).round()
        : 0;
    final keyboardViewportHeightPx = keyboardVisible
        ? math.max(0, keyboardHeightPx.value! - bottomLayoutReservedPx)
        : 0;

    final effectiveToolbarHeightPx = keyboardVisible
        ? keyboardViewportHeightPx + findInPageHeightPx
        : stableToolbarHeightPx;

    final lastToolbarMaxHeightPx = useRef<int?>(null);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(browserViewportToolbarInsetsControllerProvider.notifier)
            .reset();
      });

      return null;
    }, []);

    useEffect(() {
      if (lastToolbarMaxHeightPx.value != effectiveToolbarHeightPx) {
        lastToolbarMaxHeightPx.value = effectiveToolbarHeightPx;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(browserViewportToolbarInsetsControllerProvider.notifier)
              .setDynamicToolbarMaxHeight(effectiveToolbarHeightPx);
        });

        unawaited(
          viewportService.setDynamicToolbarMaxHeight(effectiveToolbarHeightPx),
        );
      }
      return null;
    }, [effectiveToolbarHeightPx]);

    // Track last clipping value to avoid redundant platform channel calls.
    // Clipping is set once when visibility changes (before animation starts),
    // rather than on every animation frame, to avoid platform channel spam.
    final lastClippingPx = useRef(0);

    void updateClipping() {
      final toolbarState = ref.read(
        toolbarVisibilityControllerProvider(selectedTabId),
      );
      final effectiveVisible = toolbarState == ToolbarVisibility.visible;
      final dismissed = toolbarState == ToolbarVisibility.dismissed;

      // When hidden: clip from bottom by toolbar height so GeckoView
      // can compute its layout while Flutter animates.
      // When visible/dismissed or overridden by keyboard/loading: no clipping.
      final targetClippingPx =
          autoHideTabBar &&
              !dismissed &&
              !effectiveVisible &&
              !keyboardVisible &&
              !tabIsLoading &&
              !tabInFullScreen
          ? -(bottomAppBarTotalHeight * pixelRatio).round()
          : 0;

      if (targetClippingPx != lastClippingPx.value) {
        lastClippingPx.value = targetClippingPx;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(browserViewportToolbarInsetsControllerProvider.notifier)
              .setVerticalClipping(targetClippingPx);
        });

        unawaited(viewportService.setVerticalClipping(targetClippingPx));
      }
    }

    // Update clipping when toolbar visibility changes (does NOT trigger
    // full rebuild). Also tracks dismissed state via useState so that
    // stableToolbarHeight / effectiveToolbarHeightPx stay correct.
    ref.listen(toolbarVisibilityControllerProvider(selectedTabId), (
      previous,
      next,
    ) {
      updateClipping();

      // Update dismissed state — triggers a targeted rebuild only when
      // the dismissed flag actually changes (not on every hide/show).
      final isDismissed = next == ToolbarVisibility.dismissed;
      if (toolbarDismissed.value != isDismissed) {
        toolbarDismissed.value = isDismissed;
      }
    });

    // Update clipping when other relevant state changes
    useEffect(
      () {
        updateClipping();
        return null;
      },
      [
        autoHideTabBar,
        keyboardVisible,
        tabIsLoading,
        tabInFullScreen,
        bottomAppBarTotalHeight,
        pixelRatio,
        selectedTabId,
      ],
    );

    // Theme with dynamic snackbar margin to position above bottom toolbar
    final themeData = Theme.of(context).copyWith(
      bottomSheetTheme: Theme.of(context).bottomSheetTheme.copyWith(
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
              bottomAppBarContentSize.height +
              8 +
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
          body: Stack(
            children: [
              // Layer 0: Browser content
              // Position changes instantly (no animation) to avoid jarring native view resize
              // The toolbar itself animates, providing visual continuity
              Consumer(
                builder: (context, ref, child) {
                  final toolbarState = ref.watch(
                    toolbarVisibilityControllerProvider(selectedTabId),
                  );
                  final toolbarVisible =
                      sheetDisplayed ||
                      (!tabInFullScreen &&
                          toolbarState == ToolbarVisibility.visible);

                  // When auto-hide is disabled, constrain browser above toolbar
                  // (unless toolbar is manually dismissed via swipe gesture)
                  final bottomOffset = (!autoHideTabBar && toolbarVisible)
                      ? bottomAppBarTotalHeight
                      : 0.0;

                  // For top bar: constrain browser below toolbar when visible
                  // to ensure top-of-page content is always accessible
                  final topOffset =
                      (tabBarPosition == TabBarPosition.top && toolbarVisible)
                      ? topAppBarTotalHeight
                      : 0.0;

                  // Only fall back to the system bottom inset when the bottom
                  // toolbar was explicitly dismissed. The normal auto-hide
                  // hidden state is still handled by GeckoView's dynamic
                  // toolbar/clipping logic.
                  final applyBottomSafeArea =
                      !tabInFullScreen &&
                      !isSmallWebActive &&
                      !sheetDisplayed &&
                      bottomOffset == 0 &&
                      toolbarState == ToolbarVisibility.dismissed;

                  return Positioned(
                    left: 0,
                    right: 0,
                    top: topOffset,
                    bottom: bottomOffset,
                    child: _Browser(
                      overlayController: overlayController,
                      tabInFullScreen: tabInFullScreen,
                      pointerMoveEventSink: autoHideTabBar
                          ? pointerMoveEventsController.sink
                          : null,
                      sheetDisplayed: sheetDisplayed,
                      hasTopBarOffset: topOffset > 0,
                      applyBottomSafeArea: applyBottomSafeArea,
                    ),
                  );
                },
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
              // In small web mode, show the discovery overlay instead
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: isSmallWebActive
                    ? _AnimatedToolbar(
                        position: TabBarPosition.bottom,
                        visible: !tabInFullScreen,
                        child: Material(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          elevation: 3,
                          child: const SmallWebBrowserOverlay(),
                        ),
                      )
                    : Consumer(
                        builder: (context, ref, _) {
                          final toolbarState = ref.watch(
                            toolbarVisibilityControllerProvider(selectedTabId),
                          );
                          final visible =
                              sheetDisplayed ||
                              (!tabInFullScreen &&
                                  toolbarState == ToolbarVisibility.visible);
                          return _AnimatedToolbar(
                            position: TabBarPosition.bottom,
                            visible: visible,
                            child: _TabBar(
                              tabBarPosition: TabBarPosition.bottom,
                              showMainToolbar:
                                  tabBarPosition == TabBarPosition.bottom,
                              showContextualToolbar: showContextualToolbar,
                              showQuickTabSwitcherBar:
                                  displayQuickTabSwitcherBar,
                              isSmallWebMode: false,
                              pointerMoveEvents:
                                  tabBarPosition == TabBarPosition.bottom
                                  ? pointerMoveEventsController.stream
                                  : null,
                            ),
                          );
                        },
                      ),
              ),

              // Layer 3: Top Toolbar (overlay, slides in/out) - only when position is top
              if (tabBarPosition == TabBarPosition.top)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final toolbarState = ref.watch(
                        toolbarVisibilityControllerProvider(selectedTabId),
                      );
                      final visible =
                          sheetDisplayed ||
                          (!tabInFullScreen &&
                              toolbarState == ToolbarVisibility.visible);
                      return _AnimatedToolbar(
                        position: TabBarPosition.top,
                        visible: visible,
                        child: _TabBar(
                          tabBarPosition: TabBarPosition.top,
                          showMainToolbar: true,
                          showContextualToolbar: showContextualToolbar,
                          showQuickTabSwitcherBar: displayQuickTabSwitcherBar,
                          isSmallWebMode: isSmallWebActive,
                          enableGestures: !isSmallWebActive,
                          pointerMoveEvents: isSmallWebActive
                              ? null
                              : pointerMoveEventsController.stream,
                        ),
                      );
                    },
                  ),
                ),

              // Layer 4: FAB (draggable via long press)
              Consumer(
                builder: (context, ref, child) {
                  final toolbarState = ref.watch(
                    toolbarVisibilityControllerProvider(selectedTabId),
                  );
                  final visible =
                      sheetDisplayed ||
                      (!tabInFullScreen &&
                          toolbarState == ToolbarVisibility.visible);
                  return DraggableFab(
                    bottomToolbarVisible: visible,
                    bottomAppBarHeight: bottomAppBarTotalHeight,
                    bottomSafeArea: bottomSafeArea,
                    child: child!,
                  );
                },
                child: const BrowserFab(),
              ),

              // Layer 5: Page load progress indicator (animates with toolbar visibility)
              Consumer(
                builder: (context, ref, child) {
                  final disableAnimations = MediaQuery.disableAnimationsOf(
                    context,
                  );
                  final toolbarState = ref.watch(
                    toolbarVisibilityControllerProvider(selectedTabId),
                  );
                  final visible =
                      sheetDisplayed ||
                      (!tabInFullScreen &&
                          toolbarState == ToolbarVisibility.visible);
                  return AnimatedPositioned(
                    duration: disableAnimations
                        ? Duration.zero
                        : _AnimatedToolbar._kAnimationDuration,
                    curve: Curves.easeInOutQuart,
                    left: 0,
                    right: 0,
                    top: tabBarPosition == TabBarPosition.top && visible
                        ? topAppBarTotalHeight
                        : null,
                    bottom: tabBarPosition == TabBarPosition.bottom && visible
                        ? bottomAppBarTotalHeight
                        : tabBarPosition == TabBarPosition.bottom
                        ? 0
                        : null,
                    child: child!,
                  );
                },
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
              Consumer(
                builder: (context, ref, child) {
                  final disableAnimations = MediaQuery.disableAnimationsOf(
                    context,
                  );
                  final toolbarState = ref.watch(
                    toolbarVisibilityControllerProvider(selectedTabId),
                  );
                  final visible =
                      sheetDisplayed ||
                      (!tabInFullScreen &&
                          toolbarState == ToolbarVisibility.visible);
                  return AnimatedPositioned(
                    duration: disableAnimations
                        ? Duration.zero
                        : _AnimatedToolbar._kAnimationDuration,
                    curve: Curves.easeInOutQuart,
                    left: 0,
                    right: 0,
                    bottom: math.max(
                      visible ? bottomAppBarTotalHeight : bottomSafeArea,
                      MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: child!,
                  );
                },
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
    final modalBarrierColor =
        Theme.of(context).bottomSheetTheme.modalBarrierColor ??
        colorScheme.scrim.withValues(alpha: 0.5);

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
        color: modalBarrierColor,
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
  final StreamSink<Offset>? pointerMoveEventSink;
  final bool tabInFullScreen;
  final bool sheetDisplayed;
  final bool hasTopBarOffset;
  final bool applyBottomSafeArea;

  const _Browser({
    required this.overlayController,
    required this.tabInFullScreen,
    required this.pointerMoveEventSink,
    required this.sheetDisplayed,
    required this.hasTopBarOffset,
    required this.applyBottomSafeArea,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doubleBackCloseTab = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.doubleBackCloseTab),
    );

    final lastBackButtonPress = useRef<DateTime?>(null);

    final overlayBuilder = ref.watch(overlayControllerProvider);

    Future<bool> confirmIsolatedTabCloseIfNeeded(String tabId) async {
      final allStates = ref.read(tabStatesProvider);
      final tabState = allStates[tabId];
      final contextId = tabState?.isolationContextId;

      if (contextId == null) return true;

      final groupCount = allStates.values
          .where((state) => state.isolationContextId == contextId)
          .length;

      if (groupCount > 1 || !context.mounted) return groupCount > 1;

      return ui_helper.confirmIsolatedTabClose(context);
    }

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
        if (!await confirmIsolatedTabCloseIfNeeded(details.data.tabId)) {
          return;
        }

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

                // Dismiss modal routes (e.g. showModalBottomSheet)
                final rootNavigator = Navigator.of(
                  context,
                  rootNavigator: true,
                );
                if (rootNavigator.canPop()) {
                  rootNavigator.pop();
                  return true;
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
                final tabId = ref.read(selectedTabProvider);
                ref
                    .read(toolbarVisibilityControllerProvider(tabId).notifier)
                    .show();

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
                  if (!context.mounted) return false;

                  final keep = await showKeepTabDialog(context);
                  if (keep == true) {
                    ref
                        .read(tabRepositoryProvider.notifier)
                        .clearLaunchedFromIntent(tabState!.id);

                    await moveToBackground();
                    return true;
                  }

                  if (tabState != null) {
                    if (!await confirmIsolatedTabCloseIfNeeded(tabState.id)) {
                      return true;
                    }

                    await ref
                        .read(tabRepositoryProvider.notifier)
                        .closeTab(tabState.id);
                  }

                  await moveToBackground();
                  return true;
                }

                // Handle double back to close (if enabled)
                if (doubleBackCloseTab) {
                  if (lastBackButtonPress.value != null &&
                      DateTime.now().difference(lastBackButtonPress.value!) <
                          _backButtonPressTimeout) {
                    lastBackButtonPress.value = null;

                    if (tabState != null && tabCount > 1) {
                      if (!await confirmIsolatedTabCloseIfNeeded(tabState.id)) {
                        return true;
                      }

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
                      await moveToBackground();
                      return true;
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
                applyBottomSafeArea: applyBottomSafeArea,
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
  final bool applyBottomSafeArea;

  const _BrowserView({
    required this.isFullscreen,
    required this.hasTopBarOffset,
    required this.applyBottomSafeArea,
    this.pointerMoveEventSink,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Disable top SafeArea when top bar handles it (has offset applied)
      top: !isFullscreen && !hasTopBarOffset,
      right: !isFullscreen,
      // Apply bottom SafeArea only when no toolbar/overlay is rendered at the
      // bottom (and not in fullscreen). Otherwise the toolbar handles its own
      // safe-area inset and the platform view extends behind it.
      bottom: applyBottomSafeArea,
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
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final draggableScrollableController = useDraggableScrollableController();

    void handleClearSiteDataExpansion(bool isExpanded) {
      if (isExpanded) {
        if (disableAnimations) {
          draggableScrollableController.jumpTo(1.0);
        } else {
          unawaited(
            draggableScrollableController.animateTo(
              1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.decelerate,
            ),
          );
        }
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

    final isSyncedScope = ref.watch(
      effectiveTabsTrayScopeProvider.select(
        (scope) => scope == TabsTrayScope.synced,
      ),
    );

    final effectiveTabsViewMode = isSyncedScope
        ? TabsViewMode.list
        : tabsViewMode;

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
          child: switch (effectiveTabsViewMode) {
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
