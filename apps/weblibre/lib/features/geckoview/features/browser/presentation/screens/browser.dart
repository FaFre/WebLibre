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
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/global_drop.dart';
import 'package:weblibre/core/providers/pointer_device.dart';
import 'package:weblibre/core/providers/window_size_class.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/data/models/drag_data.dart';
import 'package:weblibre/extensions/draggable_scrollable_controller.dart';
import 'package:weblibre/features/app_links/presentation/widgets/app_link_prompt_host.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/controllers/overlay.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_detail_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers/intent.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/proxy_settings_replication.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/side_rail.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/toolbar_visibility.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/keep_tab_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/providers/browser_viewport_toolbar_insets.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/addon_popup_bottom_sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/browser_fab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/browser_sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/browser_system_bars.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/browser_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/draggable_fab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/view_tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_grid_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_list_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_tray_gestures.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_tree_view.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/widgets/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_autofocus.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/keyboard_shortcuts/presentation/widgets/browser_keyboard_shortcuts.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/container_proxy.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_health.dart';
import 'package:weblibre/features/proxy/domain/services/tab_routing.dart';
import 'package:weblibre/features/proxy/presentation/controllers/ensure_proxy_started.dart';
import 'package:weblibre/features/small_web/presentation/controllers/small_web_mode_controller.dart';
import 'package:weblibre/features/small_web/presentation/widgets/small_web_browser_overlay.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/keyed_state.dart';
import 'package:weblibre/presentation/widgets/browser_sheet_surface.dart';
import 'package:weblibre/presentation/widgets/pointer_scrollable_sheet.dart';
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
        controller.forward();
      } else {
        controller.reverse();
      }
      return null;
    }, [visible]);

    final slideAnimation = useMemoized(() {
      final begin = switch (position) {
        TabBarPosition.top => const Offset(0, -1),
        TabBarPosition.bottom => const Offset(0, 1),
        TabBarPosition.left => const Offset(-1, 0),
        TabBarPosition.right => const Offset(1, 0),
      };

      return Tween<Offset>(begin: begin, end: Offset.zero).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOutQuart),
      );
    }, [position]);

    // RepaintBoundary so the (heavy) toolbar content is rasterized once and
    // merely re-composited at a new offset for each frame of the slide, instead
    // of repainting the whole chip row + favicons + menus every animation tick.
    return SlideTransition(
      position: slideAnimation,
      child: RepaintBoundary(child: child),
    );
  }
}

/// Manages scroll-based auto-hide logic and returns the toolbar widget.
/// Whether the main toolbar row should be dropped for the browser home surface.
///
/// Never dropped under [HomeSearchBarPlacement.tabBar]: there the row's own
/// (empty) address field *is* the home surface's search entry, and the pill is
/// the thing that stands down instead. The two are mutually exclusive by
/// construction rather than by two independent settings, because the home
/// surface has no other way into search — a state where both are off is not
/// one the user should be able to reach.
///
/// Under [HomeSearchBarPlacement.top] the row is still held back when there is
/// no contextual toolbar: the tab count and the navigation menu relocate there
/// when it exists, and the main row is their only other home — dropping it
/// without one would leave no way to reach the menu. That leaves the row's
/// address field showing beside the pill, which is redundant but harmless;
/// blanking only the title would strand the pinned add-ons at the right of an
/// empty strip and still reserve [kToolbarHeight].
///
/// A function rather than an inline condition because it is evaluated in two
/// places — where the bar is built and where its height is measured for the
/// browser viewport inset. If those two disagree the browser is inset for a row
/// that is not drawn. For the same reason the placement is passed in already
/// resolved: [BrowserTabBar.getToolbarHeight] runs from the wrappers'
/// constructors, outside the widget tree, where no provider can be read.
bool _suppressMainToolbarForHome({
  required bool showBrowserHome,
  required bool showContextualToolbar,
  required HomeSearchBarPlacement placement,
}) =>
    showBrowserHome &&
    showContextualToolbar &&
    placement != HomeSearchBarPlacement.tabBar;

/// Animation is handled by the parent _AnimatedToolbar wrapper.
class _TabBar extends HookConsumerWidget {
  final bool showMainToolbar;
  final bool showContextualToolbar;
  final int quickTabSwitcherRowCount;
  final Stream<Offset>? pointerMoveEvents;
  final TabBarPosition tabBarPosition;
  final bool isSmallWebMode;
  final bool enableGestures;

  const _TabBar({
    required this.showMainToolbar,
    required this.showContextualToolbar,
    required this.quickTabSwitcherRowCount,
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
        final settings = ref.read(generalSettingsWithDefaultsProvider);
        if (!settings.autoHideTabBar) return;

        final hideDistance = settings.autoHideTabBarDistance.clamp(
          minAutoHideTabBarDistance,
          maxAutoHideTabBarDistance,
        );

        final diff = event.dy;
        if (diff < 0) {
          if (diffAcc.value > 0) {
            diffAcc.value = 0.0;
          }
          diffAcc.value += diff;
          if (diffAcc.value.abs() > hideDistance) {
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
          if (diffAcc.value.abs() > hideDistance * autoHideTabBarShowFraction) {
            resetHiddenState();
          }
        }
      },
    );

    final suppressMainToolbar = _suppressMainToolbarForHome(
      showBrowserHome: ref.watch(shouldShowBrowserHomeProvider),
      showContextualToolbar: showContextualToolbar,
      placement: ref.watch(effectiveHomeSearchBarPlacementProvider),
    );

    final quickTabSwitcherPlacement = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherPlacement,
      ),
    );

    // Return the toolbar widget - parent handles animation.
    // Rail positions are rendered by a dedicated Stack layer, not _TabBar, but
    // are handled here for exhaustiveness/correctness.
    return switch (tabBarPosition) {
      TabBarPosition.top => BrowserTopAppBar(
        displayedSheet: displayedSheet,
        showMainToolbar: showMainToolbar,
        showContextualToolbar: showContextualToolbar,
        quickTabSwitcherRowCount: quickTabSwitcherRowCount,
        quickTabSwitcherPlacement: quickTabSwitcherPlacement,
        isSmallWebMode: isSmallWebMode,
        enableGestures: enableGestures,
        suppressMainToolbar: suppressMainToolbar,
      ),
      TabBarPosition.bottom => BrowserBottomAppBar(
        displayedSheet: displayedSheet,
        showMainToolbar: showMainToolbar,
        showContextualToolbar: showContextualToolbar,
        quickTabSwitcherRowCount: quickTabSwitcherRowCount,
        quickTabSwitcherPlacement: quickTabSwitcherPlacement,
        isSmallWebMode: isSmallWebMode,
        suppressMainToolbar: suppressMainToolbar,
      ),
      TabBarPosition.left || TabBarPosition.right => BrowserSideRail(
        position: tabBarPosition,
        showContextualToolbar: showContextualToolbar,
        quickTabSwitcherRowCount: quickTabSwitcherRowCount,
        isSmallWebMode: isSmallWebMode,
        railWidth: BrowserTabBar.railWidthFor(
          ref.watch(windowSizeClassControllerProvider),
          hasTabList:
              ref.watch(effectiveTabBarStackingModeProvider) !=
              TabBarStackingMode.disabled,
          preferredWidth:
              ref.watch(sideRailDragWidthProvider) ??
              ref.watch(
                generalSettingsWithDefaultsProvider.select(
                  (s) => s.sideRailWidth,
                ),
              ),
          windowWidth: MediaQuery.sizeOf(context).width,
          devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
        ),
        suppressMainToolbar: suppressMainToolbar,
      ),
    };
  }
}

/// Which proxy this tab's traffic needs, so a failed load can offer to start
/// it. Null when the tab connects directly, or while routing is unresolved.
///
/// Read off the acknowledged routing snapshot rather than re-derived from
/// settings and container rows. The snapshot already holds the resolved
/// relation for every scope — private, global, per-container, per-isolation
/// group, and the isolation-context aliases — so this asks the same question
/// the extension answered when it blocked the request. Re-deriving it here is
/// how an isolated tab ended up with no prompt at all while the route that was
/// down was its own.
ProxyConnectionId? _proxyConnectionIdForLoadError(
  WidgetRef ref, {
  required String tabId,
  required String? contextId,
}) {
  final snapshot = ref.read(containerRoutingSnapshotProvider);
  if (snapshot == null) return null;

  final tabState = ref.read(tabStateProvider(tabId));
  // The failing load reports the cookie store it ran under; the tab's own is
  // the fallback for events that carry none.
  final loadContextId = (contextId != null && contextId.isNotEmpty)
      ? contextId
      : tabState?.contextId;

  final relation = effectiveRelationFor(
    snapshot,
    tabRoutingContextId(
      contextId: loadContextId,
      isPrivate: tabState?.tabMode is PrivateTabMode,
    ),
  );

  // Empty is an explicit direct connection: there is nothing to start, and the
  // load failed for some other reason.
  return relation.isEmpty ? null : ProxyConnectionId.decode(relation.first);
}

/// How long a reload after a proxy start waits for the extension to hold the
/// proxy's endpoint. Past it the reload goes ahead anyway: a page left on the
/// error is no better than one that fails again.
const _proxyRoutingInstallTimeout = Duration(seconds: 10);

/// Pause before retrying a load that failed although its proxy was up, so a
/// runtime reload or a tunnel still completing its handshake has passed.
const _proxyRetryDelay = Duration(seconds: 2);

/// A tab whose proxy was up is retried at most once within this window.
const _proxyRetryWindow = Duration(seconds: 30);

/// Error pages for a request the proxy itself refused or could not be reached
/// for. Every other type the engine reports here is a connection failure that
/// names no proxy — "Unable to connect", a timeout, a reset, an unknown host —
/// and through a proxy that is up, those are as likely the site's as the
/// tunnel's.
const _proxyErrorTypes = {
  'ERROR_PROXY_CONNECTION_REFUSED',
  'ERROR_UNKNOWN_PROXY_HOST',
};

/// The error pages that count against the health of a proxy that is up: the
/// ones a tunnel that carries nothing produces. sing-box answers a dial it
/// cannot complete with a SOCKS failure, which Gecko shows as the proxy
/// refusing, unless Gecko's own timeout runs out first.
///
/// An unknown host cannot come from the tunnel — the proxy resolves names,
/// and its failure to is a refusal too — and a refused, reset or interrupted
/// connection is what a site that is down, or a reload of the runtime closing
/// connections, produces just as well.
const _proxyHealthErrorTypes = {
  'ERROR_PROXY_CONNECTION_REFUSED',
  'ERROR_UNKNOWN_PROXY_HOST',
  'ERROR_NET_TIMEOUT',
};

typedef _PendingProxyLoadError = ({
  String? contextId,
  String errorType,
  String? url,
});

class _BrowserScaffoldTheme extends ConsumerWidget {
  final String? selectedTabId;
  final bool isSmallWebActive;
  final bool tabInFullScreen;
  final bool sheetDisplayed;
  final Size bottomAppBarContentSize;
  final bool findInPageVisible;
  final double findInPageHeight;
  final Widget child;

  const _BrowserScaffoldTheme({
    required this.selectedTabId,
    required this.isSmallWebActive,
    required this.tabInFullScreen,
    required this.sheetDisplayed,
    required this.bottomAppBarContentSize,
    required this.findInPageVisible,
    required this.findInPageHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolbarState = isSmallWebActive
        ? ToolbarVisibility.visible
        : ref.watch(toolbarVisibilityControllerProvider(selectedTabId));
    // A sheet covers the bottom bar and the find bar, so a snackbar over the
    // sheet keeps clear of the window's bottom edge only.
    final bottomToolbarVisible =
        !sheetDisplayed &&
        !tabInFullScreen &&
        (isSmallWebActive || toolbarState == ToolbarVisibility.visible);
    final findInPageShown = !sheetDisplayed && findInPageVisible;
    final bottomInset =
        (bottomToolbarVisible ? bottomAppBarContentSize.height : 0.0) +
        8 +
        (findInPageShown ? findInPageHeight : 0.0);

    final theme = Theme.of(context);

    // The width a sheet may span here. Material's own default caps sheets at
    // 640, and every route *outside* the browser already gets that; this
    // override exists to defeat it so a sheet spans a phone edge to edge.
    // Above compact width that is no longer what anyone wants, so the override
    // stops at the same cap Material would have applied.
    final padding = MediaQuery.paddingOf(context);
    final safeAreaWidth =
        MediaQuery.sizeOf(context).width -
        math.max(padding.left * 2, padding.right * 2);
    final sheetMaxWidth = math.min(
      safeAreaWidth,
      ref.watch(windowSizeClassControllerProvider).sheetMaxWidth,
    );

    return Theme(
      data: theme.copyWith(
        bottomSheetTheme: theme.bottomSheetTheme.copyWith(
          constraints: BoxConstraints(maxWidth: sheetMaxWidth),
        ),
        snackBarTheme: theme.snackBarTheme.copyWith(
          behavior: SnackBarBehavior.floating,
          insetPadding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: bottomInset,
          ),
        ),
      ),
      child: child,
    );
  }
}

/// Computes auto-hide toolbar visibility for [selectedTabId] and animates
/// [child] in/out via [_AnimatedToolbar]. Shared by the bottom, top and side
/// rail toolbar layers so the (identical) visibility logic isn't duplicated
/// across ad-hoc `Consumer` closures.
///
/// An open sheet changes nothing here: it covers the toolbars like any modal
/// bottom sheet, so a hidden toolbar stays hidden under it rather than sliding
/// in beneath the scrim.
class _ToolbarVisibilityAnimator extends ConsumerWidget {
  final TabBarPosition position;
  final String? selectedTabId;
  final bool tabInFullScreen;
  final Widget child;

  const _ToolbarVisibilityAnimator({
    required this.position,
    required this.selectedTabId,
    required this.tabInFullScreen,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolbarState = ref.watch(
      toolbarVisibilityControllerProvider(selectedTabId),
    );
    final visible =
        !tabInFullScreen && toolbarState == ToolbarVisibility.visible;

    return _AnimatedToolbar(position: position, visible: visible, child: child);
  }
}

/// Layer 0: browser content, positioned around the (possibly auto-hidden)
/// toolbars/rail.
class _BrowserContentPositioned extends ConsumerWidget {
  final OverlayPortalController overlayController;
  final StreamController<Offset> pointerMoveEventsController;
  final String? selectedTabId;
  final bool tabInFullScreen;
  final TabBarPosition tabBarPosition;
  final bool autoHideTabBar;
  final bool isRail;
  final bool isSmallWebActive;
  final double sideRailTotalWidth;
  final double topAppBarTotalHeight;
  final double bottomAppBarTotalHeight;

  /// Height of the screen the soft keyboard (and the find-in-page bar above it)
  /// takes from the bottom edge, measured from the window's bottom.
  ///
  /// Applied as a real bottom offset so the engine view — and with it Gecko's
  /// visual viewport — actually shrinks to the visible area. See the note on
  /// `keyboardViewportInset` in [BrowserScreen].
  final double keyboardViewportInset;

  const _BrowserContentPositioned({
    required this.overlayController,
    required this.pointerMoveEventsController,
    required this.selectedTabId,
    required this.tabInFullScreen,
    required this.tabBarPosition,
    required this.autoHideTabBar,
    required this.isRail,
    required this.isSmallWebActive,
    required this.sideRailTotalWidth,
    required this.topAppBarTotalHeight,
    required this.bottomAppBarTotalHeight,
    required this.keyboardViewportInset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolbarState = ref.watch(
      toolbarVisibilityControllerProvider(selectedTabId),
    );
    // An open sheet deliberately changes nothing here. It is painted over the
    // browser, so letting it change the toolbar state here would move the
    // Positioned that wraps the platform view — a native re-layout, and under
    // hybrid composition a surface recreation, in the same frame as the
    // sheet's slide-in. The geometry the page sees stays frozen while a sheet
    // is up.
    final toolbarVisible =
        !tabInFullScreen && toolbarState == ToolbarVisibility.visible;

    // When auto-hide is disabled, constrain browser above toolbar
    // (unless toolbar is manually dismissed via swipe gesture).
    // Gated to horizontal positions so the rail (which forces
    // auto-hide off) doesn't reserve a phantom bottom inset.
    //
    // Both this and the keyboard inset are measured from the window's bottom
    // edge, so the browser clears whichever reaches higher — the keyboard is
    // drawn over the toolbar, not stacked on it.
    final bottomOffset = math.max(
      (tabBarPosition.isHorizontal && !autoHideTabBar && toolbarVisible)
          ? bottomAppBarTotalHeight
          : 0.0,
      keyboardViewportInset,
    );

    // For top bar: constrain browser below toolbar when visible
    // to ensure top-of-page content is always accessible
    final topOffset = (tabBarPosition == TabBarPosition.top && toolbarVisible)
        ? topAppBarTotalHeight
        : 0.0;

    // Side rail: inset the browser by the rail width on the docked
    // edge whenever the rail is visible (no auto-hide, so this is
    // a plain content offset — the rail slides out on dismiss).
    final leftOffset = (tabBarPosition == TabBarPosition.left && toolbarVisible)
        ? sideRailTotalWidth
        : 0.0;
    final rightOffset =
        (tabBarPosition == TabBarPosition.right && toolbarVisible)
        ? sideRailTotalWidth
        : 0.0;

    // The page stops above the navigation bar unless something else holds the
    // bottom edge: a bar that doesn't auto-hide, the keyboard, fullscreen, or
    // small web's bar. That includes an auto-hiding bar, shown or hidden: the
    // bar slides over the page, and Gecko's dynamic toolbar covers only its
    // content (see `autoHideOverlapHeight` in [BrowserScreen]). Running the
    // page down to the window's edge instead left its end under the
    // navigation bar strip once the bar hid, out of reach.
    //
    // An open sheet is likewise left out here: toggling the safe-area padding
    // on sheet open/close would resize the platform view for content the sheet
    // covers anyway.
    final applyBottomSafeArea =
        bottomOffset == 0 && !tabInFullScreen && !isSmallWebActive;

    return Positioned(
      left: leftOffset,
      right: rightOffset,
      top: topOffset,
      bottom: bottomOffset,
      child: _Browser(
        overlayController: overlayController,
        tabInFullScreen: tabInFullScreen,
        pointerMoveEventSink: autoHideTabBar
            ? pointerMoveEventsController.sink
            : null,
        hasTopBarOffset: topOffset > 0,
        hasLeftBarOffset: leftOffset > 0,
        hasRightBarOffset: rightOffset > 0,
        applyBottomSafeArea: applyBottomSafeArea,
      ),
    );
  }
}

/// Layer 2: bottom toolbar (or the small-web discovery overlay in its place).
class _BottomToolbarLayer extends StatelessWidget {
  final bool tabInFullScreen;
  final bool isSmallWebActive;
  final TabBarPosition tabBarPosition;
  final bool showContextualToolbar;
  final int quickTabSwitcherRowCount;
  final String? selectedTabId;
  final StreamController<Offset> pointerMoveEventsController;

  const _BottomToolbarLayer({
    required this.tabInFullScreen,
    required this.isSmallWebActive,
    required this.tabBarPosition,
    required this.showContextualToolbar,
    required this.quickTabSwitcherRowCount,
    required this.selectedTabId,
    required this.pointerMoveEventsController,
  });

  @override
  Widget build(BuildContext context) {
    if (isSmallWebActive) {
      return _AnimatedToolbar(
        position: TabBarPosition.bottom,
        visible: !tabInFullScreen,
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainer,
          elevation: 3,
          child: const SmallWebBrowserOverlay(),
        ),
      );
    }

    // _TabBar is passed via `child` so it is built once and reused across
    // toolbar show/hide toggles inside _ToolbarVisibilityAnimator.
    return _ToolbarVisibilityAnimator(
      position: TabBarPosition.bottom,
      selectedTabId: selectedTabId,
      tabInFullScreen: tabInFullScreen,
      child: _TabBar(
        tabBarPosition: TabBarPosition.bottom,
        showMainToolbar: tabBarPosition == TabBarPosition.bottom,
        showContextualToolbar: showContextualToolbar,
        quickTabSwitcherRowCount: quickTabSwitcherRowCount,
        isSmallWebMode: false,
        pointerMoveEvents: tabBarPosition == TabBarPosition.bottom
            ? pointerMoveEventsController.stream
            : null,
      ),
    );
  }
}

/// Layer 3: top toolbar (only rendered when the tab bar position is top).
class _TopToolbarLayer extends StatelessWidget {
  final bool tabInFullScreen;
  final bool isSmallWebActive;
  final bool showContextualToolbar;
  final int quickTabSwitcherRowCount;
  final String? selectedTabId;
  final StreamController<Offset> pointerMoveEventsController;

  const _TopToolbarLayer({
    required this.tabInFullScreen,
    required this.isSmallWebActive,
    required this.showContextualToolbar,
    required this.quickTabSwitcherRowCount,
    required this.selectedTabId,
    required this.pointerMoveEventsController,
  });

  @override
  Widget build(BuildContext context) {
    return _ToolbarVisibilityAnimator(
      position: TabBarPosition.top,
      selectedTabId: selectedTabId,
      tabInFullScreen: tabInFullScreen,
      child: _TabBar(
        tabBarPosition: TabBarPosition.top,
        showMainToolbar: true,
        showContextualToolbar: showContextualToolbar,
        quickTabSwitcherRowCount: quickTabSwitcherRowCount,
        isSmallWebMode: isSmallWebActive,
        enableGestures: !isSmallWebActive,
        pointerMoveEvents: isSmallWebActive
            ? null
            : pointerMoveEventsController.stream,
      ),
    );
  }
}

/// Layer 3b: vertical side rail (left/right).
class _SideRailToolbarLayer extends StatelessWidget {
  final bool tabInFullScreen;
  final TabBarPosition tabBarPosition;

  /// Resolved by [BrowserScreen] so the rail is drawn at exactly the width the
  /// browser content was inset for.
  final double railWidth;
  final bool showContextualToolbar;
  final int quickTabSwitcherRowCount;
  final String? selectedTabId;

  /// Resolved by the caller, as for the horizontal bars: the rail is built here
  /// rather than by [_TabBar], so without this the home surface would keep the
  /// main toolbar row only in the rail positions.
  final bool suppressMainToolbar;

  /// Whether the rail shows its resize handle.
  final bool resizable;

  /// Whether the rail auto-hides over the page instead of sitting beside it.
  final bool overlay;

  const _SideRailToolbarLayer({
    required this.tabInFullScreen,
    required this.tabBarPosition,
    required this.railWidth,
    required this.resizable,
    required this.overlay,
    required this.showContextualToolbar,
    required this.quickTabSwitcherRowCount,
    required this.selectedTabId,
    required this.suppressMainToolbar,
  });

  @override
  Widget build(BuildContext context) {
    final rail = BrowserSideRail(
      position: tabBarPosition,
      showContextualToolbar: showContextualToolbar,
      quickTabSwitcherRowCount: quickTabSwitcherRowCount,
      isSmallWebMode: false,
      railWidth: railWidth,
      suppressMainToolbar: suppressMainToolbar,
      resizable: resizable,
    );

    if (overlay) {
      return _SideRailOverlayAnimator(
        position: tabBarPosition,
        selectedTabId: selectedTabId,
        tabInFullScreen: tabInFullScreen,
        child: rail,
      );
    }

    return _ToolbarVisibilityAnimator(
      position: tabBarPosition,
      selectedTabId: selectedTabId,
      tabInFullScreen: tabInFullScreen,
      child: rail,
    );
  }
}

/// Slides an auto-hiding side rail in and out over the page.
///
/// Unlike [_ToolbarVisibilityAnimator] an open sheet does not force it into
/// view: the sheet spans the page under it, and a panel the user did not ask
/// for would cover part of the sheet.
class _SideRailOverlayAnimator extends ConsumerWidget {
  final TabBarPosition position;
  final String? selectedTabId;
  final bool tabInFullScreen;
  final Widget child;

  const _SideRailOverlayAnimator({
    required this.position,
    required this.selectedTabId,
    required this.tabInFullScreen,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revealed = ref.watch(sideRailRevealedProvider);
    // A rail dismissed by swipe stays dismissed; the cursor does not override
    // it.
    final toolbarVisible =
        ref.watch(toolbarVisibilityControllerProvider(selectedTabId)) ==
        ToolbarVisibility.visible;

    return _AnimatedToolbar(
      position: position,
      visible: revealed && toolbarVisible && !tabInFullScreen,
      child: DecoratedBox(
        decoration: BoxDecoration(boxShadow: kElevationToShadow[3]),
        child: child,
      ),
    );
  }
}

/// Reveals the auto-hiding side rail when the cursor reaches its window edge,
/// and hides it again once the cursor has rested on the page.
///
/// Hides on hovering the page rather than on leaving the rail. Anything the
/// rail opens — a tab menu, a container menu — is drawn above this region, so
/// while the cursor is over it the region hears nothing and the rail stays;
/// leaving the rail by itself would collapse it under an open menu.
///
/// Translucent to hit testing: the web page under it still receives the
/// cursor and the wheel, and the native pointer router still names the page as
/// the target.
class _SideRailRevealRegion extends HookConsumerWidget {
  final bool railOnLeft;

  /// How long the cursor rests on the page before the rail hides, so a cursor
  /// that overshoots the panel edge does not collapse it.
  static const _hideDelay = Duration(milliseconds: 400);

  const _SideRailRevealRegion({required this.railOnLeft});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideTimer = useRef<Timer?>(null);

    void cancelHide() {
      hideTimer.value?.cancel();
      hideTimer.value = null;
    }

    useEffect(() => cancelHide, const []);

    return MouseRegion(
      opaque: false,
      hitTestBehavior: HitTestBehavior.translucent,
      onHover: (event) {
        final notifier = ref.read(sideRailRevealedProvider.notifier);

        if (!ref.read(sideRailRevealedProvider)) {
          final width = context.size?.width;
          if (width != null &&
              isAtSideRailEdge(
                dx: event.localPosition.dx,
                width: width,
                railOnLeft: railOnLeft,
              )) {
            notifier.reveal();
          }
          return;
        }

        hideTimer.value ??= Timer(_hideDelay, () {
          hideTimer.value = null;
          notifier.hide();
        });
      },
      // Over the rail, a menu, or out of the window: not resting on the page.
      onExit: (_) => cancelHide(),
    );
  }
}

/// Layer 4: draggable FAB, positioned clear of the toolbar/rail.
class _FabPositioner extends ConsumerWidget {
  final String? selectedTabId;
  final bool tabInFullScreen;
  final TabBarPosition tabBarPosition;
  final double bottomAppBarTotalHeight;
  final double bottomSafeArea;
  final double sideRailTotalWidth;
  final Widget child;

  const _FabPositioner({
    required this.selectedTabId,
    required this.tabInFullScreen,
    required this.tabBarPosition,
    required this.bottomAppBarTotalHeight,
    required this.bottomSafeArea,
    required this.sideRailTotalWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolbarState = ref.watch(
      toolbarVisibilityControllerProvider(selectedTabId),
    );
    final visible =
        !tabInFullScreen && toolbarState == ToolbarVisibility.visible;

    return DraggableFab(
      bottomToolbarVisible: visible,
      bottomAppBarHeight: bottomAppBarTotalHeight,
      bottomSafeArea: bottomSafeArea,
      leftReservedWidth: (tabBarPosition == TabBarPosition.left && visible)
          ? sideRailTotalWidth
          : 0.0,
      rightReservedWidth: (tabBarPosition == TabBarPosition.right && visible)
          ? sideRailTotalWidth
          : 0.0,
      child: child,
    );
  }
}

/// How far an overlay spanning the window's width (the progress line, the find
/// bar, the app-link banner) keeps from each side: clear of the rail where it
/// is docked and showing, and always of the side insets, like the tab bars
/// themselves. In landscape those hold the navigation bar's buttons or a
/// display cutout.
({double left, double right}) _overlaySideInsets(
  BuildContext context, {
  required TabBarPosition tabBarPosition,
  required bool toolbarVisible,
  required double sideRailTotalWidth,
}) {
  final padding = MediaQuery.paddingOf(context);
  return (
    left: math.max(
      padding.left,
      tabBarPosition == TabBarPosition.left && toolbarVisible
          ? sideRailTotalWidth
          : 0.0,
    ),
    right: math.max(
      padding.right,
      tabBarPosition == TabBarPosition.right && toolbarVisible
          ? sideRailTotalWidth
          : 0.0,
    ),
  );
}

/// Layer 5: page load progress indicator, animated with toolbar visibility.
/// Split into a positioner (reacts to toolbar visibility) and a content
/// widget (reacts to load progress) so the two independent watches don't
/// force each other to rebuild.
class _ProgressIndicatorPositioner extends ConsumerWidget {
  final String? selectedTabId;
  final bool tabInFullScreen;
  final TabBarPosition tabBarPosition;
  final bool isRail;
  final double sideRailTotalWidth;
  final double topSafeArea;
  final double topAppBarTotalHeight;
  final double bottomAppBarTotalHeight;
  final Widget child;

  const _ProgressIndicatorPositioner({
    required this.selectedTabId,
    required this.tabInFullScreen,
    required this.tabBarPosition,
    required this.isRail,
    required this.sideRailTotalWidth,
    required this.topSafeArea,
    required this.topAppBarTotalHeight,
    required this.bottomAppBarTotalHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final toolbarState = ref.watch(
      toolbarVisibilityControllerProvider(selectedTabId),
    );
    final visible =
        !tabInFullScreen && toolbarState == ToolbarVisibility.visible;
    final sideInsets = _overlaySideInsets(
      context,
      tabBarPosition: tabBarPosition,
      toolbarVisible: visible,
      sideRailTotalWidth: sideRailTotalWidth,
    );

    return AnimatedPositioned(
      duration: disableAnimations
          ? Duration.zero
          : _AnimatedToolbar._kAnimationDuration,
      curve: Curves.easeInOutQuart,
      // Rail insets track the rail's visibility so overlays
      // reclaim the space when it is swiped away.
      left: sideInsets.left,
      right: sideInsets.right,
      // On the rail there is no top/bottom bar; pin the progress
      // line to the top of the content area.
      top: isRail
          ? topSafeArea
          : tabBarPosition == TabBarPosition.top && visible
          ? topAppBarTotalHeight
          : null,
      bottom: isRail
          ? null
          : tabBarPosition == TabBarPosition.bottom && visible
          ? bottomAppBarTotalHeight
          : tabBarPosition == TabBarPosition.bottom
          ? 0
          : null,
      child: child,
    );
  }
}

class _ProgressIndicatorBar extends ConsumerWidget {
  const _ProgressIndicatorBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabId = ref.watch(selectedTabProvider);
    final isLoading = ref.watch(
      tabStateProvider(tabId).select((state) => state?.isLoading == true),
    );

    //When not loading we assumed finished
    final value = isLoading ? ref.watch(tabProgressProvider(tabId)) : 100;

    return Visibility(
      visible: value < 100,
      child: LinearProgressIndicator(value: value / 100),
    );
  }
}

/// Layer 6: find-in-page widget, positioned above the toolbar/keyboard.
/// Same positioner/content split rationale as the progress indicator above.
class _FindInPagePositioner extends ConsumerWidget {
  final String? selectedTabId;
  final bool tabInFullScreen;
  final TabBarPosition tabBarPosition;
  final bool isRail;
  final double sideRailTotalWidth;
  final double bottomSafeArea;
  final double bottomAppBarTotalHeight;
  final Widget child;

  const _FindInPagePositioner({
    required this.selectedTabId,
    required this.tabInFullScreen,
    required this.tabBarPosition,
    required this.isRail,
    required this.sideRailTotalWidth,
    required this.bottomSafeArea,
    required this.bottomAppBarTotalHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final toolbarState = ref.watch(
      toolbarVisibilityControllerProvider(selectedTabId),
    );
    final visible =
        !tabInFullScreen && toolbarState == ToolbarVisibility.visible;
    final sideInsets = _overlaySideInsets(
      context,
      tabBarPosition: tabBarPosition,
      toolbarVisible: visible,
      sideRailTotalWidth: sideRailTotalWidth,
    );
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPositioned(
      // Animated as the toolbar slides in and out. Not while the keyboard is
      // up: it reports a new inset on every frame of its own slide, and each
      // would restart the animation from wherever the bar is, so the bar would
      // trail behind the keyboard and only catch up once it stopped.
      duration: disableAnimations || keyboardInset > 0
          ? Duration.zero
          : _AnimatedToolbar._kAnimationDuration,
      curve: Curves.easeInOutQuart,
      left: sideInsets.left,
      right: sideInsets.right,
      bottom: math.max(
        isRail
            ? bottomSafeArea
            : (visible ? bottomAppBarTotalHeight : bottomSafeArea),
        keyboardInset,
      ),
      child: child,
    );
  }
}

class _FindInPageContent extends ConsumerWidget {
  const _FindInPageContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabId = ref.watch(selectedTabProvider);
    if (tabId == null) {
      return const SizedBox.shrink();
    }
    return FindInPageWidget(key: ValueKey(tabId), tabId: tabId);
  }
}

/// Layer 7: app-link prompt banner (§2.6). Anchored above the bottom app
/// bar / keyboard exactly like find-in-page, so it is never hidden behind
/// the toolbar. Custom Tab sessions are prompted natively instead; this is
/// the browser-tab surface only.
class _AppLinkPromptLayer extends ConsumerWidget {
  final String? selectedTabId;
  final bool tabInFullScreen;
  final TabBarPosition tabBarPosition;
  final bool isRail;
  final double sideRailTotalWidth;
  final double bottomSafeArea;
  final double bottomAppBarTotalHeight;

  const _AppLinkPromptLayer({
    required this.selectedTabId,
    required this.tabInFullScreen,
    required this.tabBarPosition,
    required this.isRail,
    required this.sideRailTotalWidth,
    required this.bottomSafeArea,
    required this.bottomAppBarTotalHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolbarState = ref.watch(
      toolbarVisibilityControllerProvider(selectedTabId),
    );
    final visible =
        !tabInFullScreen && toolbarState == ToolbarVisibility.visible;
    final sideInsets = _overlaySideInsets(
      context,
      tabBarPosition: tabBarPosition,
      toolbarVisible: visible,
      sideRailTotalWidth: sideRailTotalWidth,
    );

    return Positioned(
      left: sideInsets.left,
      right: sideInsets.right,
      bottom: math.max(
        isRail
            ? bottomSafeArea
            : (visible ? bottomAppBarTotalHeight : bottomSafeArea),
        MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: const AppLinkPromptHost(),
    );
  }
}

/// Keeps the startup spinner up while [StartupLaunchCover] is raised.
///
/// Drawn exactly like the loading screen `MainApp` shows before initialization
/// completes, so the two read as one wait rather than a spinner, the home
/// surface, and then the page.
class _StartupLaunchCoverLayer extends ConsumerWidget {
  const _StartupLaunchCoverLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(startupLaunchCoverProvider)) {
      return const SizedBox.shrink();
    }

    // Absorbs input: the home surface it hides would otherwise still take
    // taps.
    return const AbsorbPointer(
      child: Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

class BrowserScreen extends HookConsumerWidget {
  const BrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventService = ref.watch(eventServiceProvider);
    final viewportService = ref.watch(viewportServiceProvider);
    final activeProxyPromptKeys = useRef(<String>{});
    final pendingProxyLoadErrors = useRef(<String, _PendingProxyLoadError>{});
    final pendingProxyLoadErrorWatches = useRef(
      <String, ProviderSubscription<bool>>{},
    );
    useEffect(
      () => () {
        for (final watch in pendingProxyLoadErrorWatches.value.values) {
          watch.close();
        }
        pendingProxyLoadErrorWatches.value.clear();
      },
      const [],
    );

    _PendingProxyLoadError? takeQueuedProxyLoadError(String tabId) {
      pendingProxyLoadErrorWatches.value.remove(tabId)?.close();
      return pendingProxyLoadErrors.value.remove(tabId);
    }

    /// Defers [error] until [tabId] is shown — unless the tab loads again
    /// first. A queued error skips [concernsProxy] when it is handled, so it
    /// must not outlive the load it is about: a tab the engine or the page
    /// has since loaded again, in the background, is no longer sitting on
    /// that failure, and reloading it would only throw the new page away.
    void queueProxyLoadError(String tabId, _PendingProxyLoadError error) {
      pendingProxyLoadErrors.value[tabId] = error;
      pendingProxyLoadErrorWatches.value[tabId] ??= ref.listenManual(
        tabStateProvider(tabId).select((state) => state?.isLoading ?? false),
        (previous, isLoading) {
          if (isLoading) takeQueuedProxyLoadError(tabId);
        },
      );
    }

    final proxyRetriedAt = useRef(<String, DateTime>{});
    final selectedTabIdForProxyPrompt = ref.watch(selectedTabProvider);

    /// The encoded id of the proxy that carried the tab's traffic, if one did.
    ///
    /// Only while the extension was routing through that proxy: a load that
    /// failed because the proxy was not up, or before routing was installed,
    /// says nothing about whether its tunnel works.
    String? carryingProxyId({
      required String tabId,
      required String? contextId,
    }) {
      final proxyConnectionId = _proxyConnectionIdForLoadError(
        ref,
        tabId: tabId,
        contextId: contextId,
      );
      if (proxyConnectionId == null) return null;

      final encodedProxyId = proxyConnectionId.encode();
      final carriedByProxy = ref
          .read(proxySettingsReplicationProvider.notifier)
          .installedSatisfies(
            (snapshot) => snapshot.proxyEndpoint(encodedProxyId) != null,
          );
      return carriedByProxy ? encodedProxyId : null;
    }

    /// Counts a failed load against the proxy that carried it, if one did.
    void recordProxyTrafficFailure({
      required String tabId,
      required String? contextId,
      required String? url,
      required String errorType,
    }) {
      if (!_proxyHealthErrorTypes.contains(errorType)) return;

      final encodedProxyId = carryingProxyId(
        tabId: tabId,
        contextId: contextId,
      );
      if (encodedProxyId == null) return;

      ref
          .read(proxyTrafficHealthProvider.notifier)
          .recordFailedLoad(
            encodedProxyId,
            host: url == null ? null : Uri.tryParse(url)?.host,
          );
    }

    /// Whether a failed load is this screen's business at all.
    ///
    /// Native reports every connection failure, for every tab, because only
    /// the app knows how a tab is routed. One that names no proxy matters only
    /// when the tab's proxy is not up — it went down, or the runtime is
    /// restarting it — which is something starting it can fix. In a tab that
    /// connects directly, or through a proxy that is up, it is as likely the
    /// site or a mistyped address, and reloading would only repeat it; through
    /// a proxy it already counts against the proxy's health.
    bool concernsProxy({
      required String tabId,
      required String? contextId,
      required String errorType,
    }) {
      if (_proxyErrorTypes.contains(errorType)) return true;

      final routedThrough = _proxyConnectionIdForLoadError(
        ref,
        tabId: tabId,
        contextId: contextId,
      );
      return routedThrough != null &&
          ref
                  .read(containerRoutingSnapshotProvider)
                  ?.proxyEndpoint(routedThrough.encode()) ==
              null;
    }

    /// [concernsProxyDecided] is set for an error from the queue: each one
    /// passed [concernsProxy] when it was queued, in the routing its load
    /// failed in. Asked again once the tab is shown, a proxy that has come
    /// back since says the error is not its business, and the tab stays on
    /// the error page. The queue drops an error once its tab loads again
    /// ([queueProxyLoadError]), so the answer is still about the page shown.
    Future<void> handleProxyLoadError({
      required String tabId,
      required String? contextId,
      required String? url,
      required String errorType,
      bool concernsProxyDecided = false,
    }) async {
      final promptKey = '$tabId:${url ?? errorType}';
      if (!activeProxyPromptKeys.value.add(promptKey)) return;

      // Set once this tab starts a load of its own while the waits below run.
      // The unattended reload is only ever meant to get a tab past the load
      // that failed in the routing-install window; a tab that has started
      // loading again since — because the user retried, or because the engine
      // did — is no longer sitting on that failure, and reloading it would
      // throw away the page and the scroll position they now have.
      var tabReloadedMeanwhile = false;
      final tabLoadSubscription = ref.listenManual(
        tabStateProvider(tabId).select((state) => state?.isLoading ?? false),
        (previous, isLoading) {
          if (isLoading) tabReloadedMeanwhile = true;
        },
      );

      try {
        // Every wait below can run for seconds, and the user may navigate
        // in the meantime; checked here so no path reloads over that.
        Future<void> reloadTab() async {
          if (!context.mounted ||
              tabReloadedMeanwhile ||
              ref.read(selectedTabProvider) != tabId) {
            return;
          }
          await ref.read(tabSessionProvider(tabId: tabId).notifier).reload();
        }

        if (!concernsProxyDecided &&
            !concernsProxy(
              tabId: tabId,
              contextId: contextId,
              errorType: errorType,
            )) {
          return;
        }

        // The extension blocks *every* request until routing is installed, so a
        // load that lands in that window fails this way whether or not the tab
        // routes through a proxy at all — which is what a cold start, and the
        // first navigation of one, most often is. Wait the install out and
        // reload, instead of leaving a page the user has to retry by hand.
        final containerProxy = ref.read(
          containerProxyRepositoryProvider.notifier,
        );
        final routingWasPending = !await containerProxy.isRoutingReady();
        // Every read past this point goes through `ref`, which throws once the
        // screen is gone — and the throw is swallowed by the catch below, so
        // the recovery would be lost silently rather than loudly.
        if (!context.mounted) return;

        if (routingWasPending) {
          final routingReady = await containerProxy.waitUntilRoutingReady();
          // Routing that never arrives is a broken browser, not a proxy that
          // needs starting: there is no snapshot to say what this tab needs, so
          // the error page stands and the repair loop keeps retrying behind it.
          if (!routingReady || !context.mounted) return;
        }

        final proxyConnectionId = _proxyConnectionIdForLoadError(
          ref,
          tabId: tabId,
          contextId: contextId,
        );

        if (proxyConnectionId == null) {
          // Nothing to start — this context connects directly, so the block was
          // the install window itself and it is over.
          if (routingWasPending) await reloadTab();
          return;
        }

        // Starting a proxy asks the user about *a tab*, and the wait above can
        // run for seconds. If they have moved on since, hand the error back to
        // the queue that defers it until this tab is on screen again — the same
        // route an error for an unselected tab takes in the first place —
        // instead of prompting over whatever they are looking at now.
        if (ref.read(selectedTabProvider) != tabId) {
          if (!tabReloadedMeanwhile) {
            queueProxyLoadError(tabId, (
              contextId: contextId,
              errorType: errorType,
              url: url,
            ));
          }
          return;
        }

        final encodedProxyId = proxyConnectionId.encode();
        // An endpoint in the routing means the proxy was up when this load
        // failed, so the failure is not one starting it can fix: the tunnel
        // behind the endpoint is not carrying traffic, or the load fell into a
        // reload of the runtime. Read before the start below can change it.
        final proxyWasUp =
            ref
                .read(containerRoutingSnapshotProvider)
                ?.proxyEndpoint(encodedProxyId) !=
            null;

        final isProxyStarted = await ensureProxyStartedForConnection(
          context,
          ref,
          proxyConnectionId,
        );
        if (!isProxyStarted || !context.mounted) return;

        if (proxyWasUp) {
          // One retry, not one per failure. Each reload of a page whose proxy
          // cannot carry it fails again and lands back here, and reloading on
          // every one of those kept the tab reloading for as long as the
          // tunnel stayed down.
          final now = DateTime.now();
          final lastRetry = proxyRetriedAt.value[tabId];
          if (lastRetry != null &&
              now.difference(lastRetry) < _proxyRetryWindow) {
            return;
          }
          proxyRetriedAt.value[tabId] = now;

          await Future<void>.delayed(_proxyRetryDelay);
          if (!context.mounted || tabReloadedMeanwhile) return;
        }

        // A start that returned has an endpoint in the routing the app
        // computes, not yet in the routing the extension enforces. Reloading
        // before that lands sends the page into the snapshot that just
        // blocked it, and it fails again (issue #672).
        final installed = await ref
            .read(proxySettingsReplicationProvider.notifier)
            .waitUntilProxyInstalled(
              encodedProxyId,
              timeout: _proxyRoutingInstallTimeout,
            );
        if (!context.mounted) return;
        if (!installed) {
          logger.w(
            'Routing for $encodedProxyId was not installed in time; '
            'reloading anyway',
          );
        }

        await reloadTab();
      } catch (error, stackTrace) {
        logger.e(
          'Failed to handle proxy load error',
          error: error,
          stackTrace: stackTrace,
        );
      } finally {
        tabLoadSubscription.close();
        activeProxyPromptKeys.value.remove(promptKey);
      }
    }

    useEffect(() {
      final tabId = selectedTabIdForProxyPrompt;
      if (tabId == null) return null;

      final pending = takeQueuedProxyLoadError(tabId);
      if (pending == null) return null;

      unawaited(
        handleProxyLoadError(
          tabId: tabId,
          contextId: pending.contextId,
          url: pending.url,
          errorType: pending.errorType,
          concernsProxyDecided: true,
        ),
      );
      return null;
    }, [selectedTabIdForProxyPrompt]);

    useOnStreamChange(
      eventService.proxyLoadErrorEvents,
      onData: (event) async {
        final selectedTabId = ref.read(selectedTabProvider);
        // A session with no tab in the store is engine traffic of its own.
        // Only an error that names the proxy is still put down to the selected
        // tab; any other — a timeout, a reset — is as likely that session's
        // site, and says nothing about the selected tab or its proxy.
        final tabId =
            event.tabId ??
            (_proxyErrorTypes.contains(event.errorType) ? selectedTabId : null);
        if (tabId == null) return;

        // On arrival rather than when handled: an error for a tab in the
        // background waits until the tab is shown, but it is evidence about the
        // proxy now. Only for the tab it came from: the selected tab's proxy
        // did not necessarily carry a tabless session's load.
        if (event.tabId != null) {
          recordProxyTrafficFailure(
            tabId: tabId,
            contextId: event.contextId,
            url: event.url,
            errorType: event.errorType,
          );
        }

        if (tabId != selectedTabId) {
          // Decided now, while the routing is the one the load failed in: by
          // the time the tab is shown it may say something else, and a direct
          // tab's mistyped address would sit in the queue until then.
          if (!concernsProxy(
            tabId: tabId,
            contextId: event.contextId,
            errorType: event.errorType,
          )) {
            return;
          }
          queueProxyLoadError(tabId, (
            contextId: event.contextId,
            errorType: event.errorType,
            url: event.url,
          ));
          return;
        }

        await handleProxyLoadError(
          tabId: tabId,
          contextId: event.contextId,
          url: event.url,
          errorType: event.errorType,
        );
      },
    );

    // A page that turned secure finished a TLS handshake with its site, so
    // traffic got through the proxy carrying it — the positive evidence that
    // keeps a mistyped address and a site that is down from adding up to a
    // proxy that is not responding.
    useOnStreamChange(
      eventService.securityInfoEvents,
      onData: (event) {
        if (!event.securityInfo.secure) return;

        final encodedProxyId = carryingProxyId(
          tabId: event.tabId,
          contextId: null,
        );
        if (encodedProxyId == null) return;

        ref
            .read(proxyTrafficHealthProvider.notifier)
            .recordSuccessfulLoad(encodedProxyId);
      },
    );

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
        : ref.watch(effectiveTabBarPositionProvider);

    final showContextualToolbar =
        !isSmallWebActive &&
        ref.watch(
          generalSettingsWithDefaultsProvider.select(
            (value) => value.tabBarShowContextualBar,
          ),
        );

    final quickTabSwitcherRowCount = isSmallWebActive
        ? 0
        : ref.watch(quickTabSwitcherRowCountProvider).value ?? 0;
    // Must match what _TabBar resolves, or the browser is inset for a
    // switcher row drawn in the other bar.
    final quickTabSwitcherPlacement = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherPlacement,
      ),
    );

    // Vertical side rail (left/right). Auto-hide is not supported on the rail;
    // it is reserved via a plain content offset and dismissed only by gesture.
    final isRail = tabBarPosition.isVertical;

    // Resolved once here and threaded down, rather than read again inside the
    // rail: this same number insets the browser content, and a rail drawn at a
    // different width than the one reserved would either overlap the page or
    // leave a gap beside it.
    final window = ref.watch(windowSizeClassControllerProvider);
    final hasTabList =
        ref.watch(effectiveTabBarStackingModeProvider) !=
        TabBarStackingMode.disabled;
    final canResizeRail =
        isRail && BrowserTabBar.canResizeRail(window, hasTabList: hasTabList);
    final railWidth = BrowserTabBar.railWidthFor(
      window,
      hasTabList: hasTabList,
      // A resize in progress wins over the saved width, so the panel and the
      // page follow the handle while it moves.
      preferredWidth:
          ref.watch(sideRailDragWidthProvider) ??
          ref.watch(
            generalSettingsWithDefaultsProvider.select((s) => s.sideRailWidth),
          ),
      windowWidth: MediaQuery.sizeOf(context).width,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    );

    // The auto-hiding rail slides in over the page instead of sitting beside
    // it, so the page keeps its full width and never reflows on reveal. Gated
    // on the cursor being the input in use: only the cursor can reveal it, so
    // the moment the user touches the screen the rail goes back beside the
    // page, where touch can reach it.
    final railOverlay =
        isRail &&
        ref.watch(
          generalSettingsWithDefaultsProvider.select((s) => s.sideRailAutoHide),
        ) &&
        ref.watch(cursorInUseProvider);

    final autoHideTabBar =
        !isSmallWebActive &&
        tabBarPosition.isHorizontal &&
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
    useOnStreamChange(
      addonService.openAddonSettingsStream,
      onData: (addonId) async {
        await AddonInternalSettingsRoute(addonId: addonId).push<void>(context);
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

    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;

    // Must match what _TabBar resolves, or the browser is inset for a toolbar
    // row that is not drawn.
    final suppressMainToolbarForHome = _suppressMainToolbarForHome(
      showBrowserHome: ref.watch(shouldShowBrowserHomeProvider),
      showContextualToolbar: showContextualToolbar,
      placement: ref.watch(effectiveHomeSearchBarPlacementProvider),
    );

    // Calculate bottom toolbar size for the page inset and the FAB. A sheet
    // covers the bars and never changes their size, so the page's viewport
    // stays put while one opens: resizing the Gecko viewport would cost a page
    // reflow plus, under hybrid composition, a native surface recreation, all
    // in the same frame as the sheet's slide-in.
    final Size bottomAppBarContentSize;
    if (isSmallWebActive) {
      bottomAppBarContentSize = const Size.fromHeight(
        SmallWebBrowserOverlay.barHeight,
      );
    } else if (isRail) {
      // The rail occupies a side, not the bottom; no bottom bar is rendered.
      bottomAppBarContentSize = Size.zero;
    } else {
      bottomAppBarContentSize = BrowserBottomAppBar(
        showMainToolbar: tabBarPosition == TabBarPosition.bottom,
        showContextualToolbar: showContextualToolbar,
        quickTabSwitcherRowCount: quickTabSwitcherRowCount,
        quickTabSwitcherPlacement: quickTabSwitcherPlacement,
        isSmallWebMode: false,
        suppressMainToolbar: suppressMainToolbarForHome,
      ).preferredSize;
    }
    // Total height includes safe area padding
    final bottomAppBarTotalHeight =
        bottomAppBarContentSize.height + bottomSafeArea;

    // Side rail width reservation (vertical positions only): the content width
    // plus the system safe-area inset on the rail's outer edge. Nothing is
    // reserved for a rail that overlays the page.
    final horizontalSafeArea = switch (tabBarPosition) {
      TabBarPosition.left => MediaQuery.paddingOf(context).left,
      TabBarPosition.right => MediaQuery.paddingOf(context).right,
      _ => 0.0,
    };
    final sideRailTotalWidth = isRail && !railOverlay
        ? railWidth + horizontalSafeArea
        : 0.0;

    // Calculate top toolbar size for browser offset and progress indicator
    final topSafeArea = MediaQuery.paddingOf(context).top;
    final topAppBarContentSize = BrowserTopAppBar(
      showMainToolbar: tabBarPosition == TabBarPosition.top,
      showContextualToolbar: showContextualToolbar,
      quickTabSwitcherRowCount: quickTabSwitcherRowCount,
      quickTabSwitcherPlacement: quickTabSwitcherPlacement,
      isSmallWebMode: isSmallWebActive,
      enableGestures: !isSmallWebActive,
      suppressMainToolbar: suppressMainToolbarForHome,
    ).preferredSize;
    final topAppBarTotalHeight = topAppBarContentSize.height + topSafeArea;

    // Get pixel ratio for converting logical pixels to physical pixels
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final bottomSystemInsetPx =
        (MediaQuery.viewPaddingOf(context).bottom * pixelRatio).round();

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

    // Track dismissed state without triggering full rebuild on every
    // hide/show. Updated via ref.listen below and synced on tab switch.
    final toolbarDismissed = useKeyedState(
      ref.read(toolbarVisibilityControllerProvider(selectedTabId)) ==
          ToolbarVisibility.dismissed,
      [selectedTabId],
    );

    // How much of the page an auto-hiding bottom bar covers while it shows.
    // The page ends above the navigation bar (`_BrowserContentPositioned`), so
    // that is the bar's content, not the padding it keeps over the navigation
    // bar. Small web's bar never hides, and the page runs under it padding
    // included.
    final autoHideOverlapHeight = isSmallWebActive
        ? bottomAppBarTotalHeight
        : bottomAppBarContentSize.height;

    final autoHideToolbarHeight = switch (tabBarPosition) {
      // Gecko's dynamic toolbar value is consumed as a bottom inset by Dart and
      // native UI. The top toolbar itself is positioned with Flutter's topOffset.
      TabBarPosition.top || TabBarPosition.bottom => autoHideOverlapHeight,
      TabBarPosition.left || TabBarPosition.right => 0.0,
    };

    final stableToolbarHeight =
        autoHideTabBar && !toolbarDismissed.value && !tabInFullScreen
        ? autoHideToolbarHeight
        : 0.0;
    final stableToolbarHeightPx = (stableToolbarHeight * pixelRatio).round();

    final keyboardHeightPx = useState<int?>(null);

    useOnStreamChange(
      viewportService.keyboardEvents,
      onData: (event) {
        if (!event.isAnimating) {
          final nextKeyboardHeightPx = event.isVisible
              ? event.heightPx + bottomSystemInsetPx
              : null;
          if (keyboardHeightPx.value != nextKeyboardHeightPx) {
            keyboardHeightPx.value = nextKeyboardHeightPx;
          }
        }
      },
    );

    final keyboardVisible = keyboardHeightPx.value != null;

    // How far up from the window's bottom edge the browser has to stop while
    // the soft keyboard is up (plus the find-in-page bar, which is drawn over
    // the page just above it).
    //
    // This is a real inset on the platform view, not a dynamic-toolbar height.
    // Gecko sizes the visual viewport from the view it is given and treats a
    // dynamic toolbar as chrome that scrolls away, so describing the keyboard
    // as one leaves the last `keyboardHeight` pixels of every document
    // unreachable — and leaves Gecko believing a focused input behind the
    // keyboard is already on screen, so it never scrolls it into view. Shrink
    // the view instead, which is what a plain `adjustResize` window would do
    // and what GeckoView's own keyboard handling (`onKeyboardHeight`, fed from
    // the window insets) expects. See
    // https://github.com/FaFre/WebLibre/issues/502.
    //
    // A sheet is excluded: it covers the page, so a keyboard opened for a field
    // *in the sheet* has nothing to make room for, and resizing the platform
    // view under it would cost a reflow and a native surface recreation in the
    // same frame as the sheet's animation.
    final keyboardApplies = keyboardVisible && !sheetDisplayed;
    final keyboardViewportInset = keyboardApplies
        ? (keyboardHeightPx.value! / pixelRatio) + findInPageHeight
        : 0.0;

    // While the keyboard is up the bottom bar sits behind it, not over the
    // page, so there is no dynamic toolbar overlapping the (now shorter) view.
    final effectiveToolbarHeightPx = keyboardApplies
        ? 0
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

      // Dynamic toolbar clipping is bottom-inset-only; top toolbar layout is
      // handled by Flutter's topOffset instead of Gecko's bottom inset channel.
      // When visible/dismissed or overridden by keyboard/loading: no clipping.
      final hiddenToolbarClippingPx = switch (tabBarPosition) {
        TabBarPosition.top ||
        TabBarPosition.bottom => -(autoHideOverlapHeight * pixelRatio).round(),
        TabBarPosition.left || TabBarPosition.right => 0,
      };
      final targetClippingPx =
          autoHideTabBar &&
              !dismissed &&
              !effectiveVisible &&
              !keyboardVisible &&
              !tabIsLoading &&
              !tabInFullScreen
          ? hiddenToolbarClippingPx
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
        autoHideOverlapHeight,
        pixelRatio,
        selectedTabId,
        tabBarPosition,
      ],
    );

    final screen = PopScope(
      //We need this for BackButtonListener to work downstream
      //No direct pop result will be handled here
      canPop: false,
      child: _BrowserScaffoldTheme(
        selectedTabId: selectedTabId,
        isSmallWebActive: isSmallWebActive,
        tabInFullScreen: tabInFullScreen,
        sheetDisplayed: sheetDisplayed,
        bottomAppBarContentSize: bottomAppBarContentSize,
        findInPageVisible: findInPageVisible,
        findInPageHeight: findInPageHeight,
        child: Scaffold(
          // Minimal scaffold - only for Material overlay support (SnackBars)
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // Layer 0: Browser content
              // Position changes instantly (no animation) to avoid jarring native view resize
              // The toolbar itself animates, providing visual continuity
              _BrowserContentPositioned(
                overlayController: overlayController,
                pointerMoveEventsController: pointerMoveEventsController,
                selectedTabId: selectedTabId,
                tabInFullScreen: tabInFullScreen,
                tabBarPosition: tabBarPosition,
                autoHideTabBar: autoHideTabBar,
                isRail: isRail,
                isSmallWebActive: isSmallWebActive,
                sideRailTotalWidth: sideRailTotalWidth,
                topAppBarTotalHeight: topAppBarTotalHeight,
                bottomAppBarTotalHeight: bottomAppBarTotalHeight,
                keyboardViewportInset: keyboardViewportInset,
              ),

              // Layer 0.5: System bar tint — fills the status-bar/nav-bar
              // inset regions with the active container color (or the tab bar
              // surface fallback) and drives the system bar icon brightness.
              // Sits above the browser content but below the toolbars, so the
              // tab bar's transparent safe-area padding reveals the bottom
              // strip and the top toolbar's SafeArea reveals the top strip.
              if (!tabInFullScreen)
                Positioned.fill(
                  child: BrowserSystemBars(
                    topInset: topSafeArea,
                    bottomInset: bottomSafeArea,
                  ),
                ),

              // Layer 0.6: cursor tracking for the auto-hiding side rail. Below
              // everything else Flutter draws, so it only hears the cursor
              // while it is over the page itself.
              if (railOverlay && !tabInFullScreen)
                Positioned.fill(
                  child: _SideRailRevealRegion(
                    railOnLeft: tabBarPosition == TabBarPosition.left,
                  ),
                ),

              // Layer 2: Bottom Toolbar (overlay, slides in/out)
              // In small web mode, show the discovery overlay instead.
              // Skipped entirely for the side rail (Layer 3b below).
              if (!isRail)
                Positioned(
                  // Clear of the side insets, as the top bar is through its
                  // SafeArea: in landscape a navigation bar of buttons moves
                  // to the side, and the bar's ends would sit under it.
                  left: MediaQuery.paddingOf(context).left,
                  right: MediaQuery.paddingOf(context).right,
                  bottom: 0,
                  child: _BottomToolbarLayer(
                    tabInFullScreen: tabInFullScreen,
                    isSmallWebActive: isSmallWebActive,
                    tabBarPosition: tabBarPosition,
                    showContextualToolbar: showContextualToolbar,
                    quickTabSwitcherRowCount: quickTabSwitcherRowCount,
                    selectedTabId: selectedTabId,
                    pointerMoveEventsController: pointerMoveEventsController,
                  ),
                ),

              // Layer 3: Top Toolbar (overlay, slides in/out) - only when position is top
              if (tabBarPosition == TabBarPosition.top)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: _TopToolbarLayer(
                    tabInFullScreen: tabInFullScreen,
                    isSmallWebActive: isSmallWebActive,
                    showContextualToolbar: showContextualToolbar,
                    quickTabSwitcherRowCount: quickTabSwitcherRowCount,
                    selectedTabId: selectedTabId,
                    pointerMoveEventsController: pointerMoveEventsController,
                  ),
                ),

              // Layer 3b: Side rail (vertical, left/right). No auto-hide; it
              // slides horizontally out of view only on manual dismiss.
              if (isRail)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: tabBarPosition == TabBarPosition.left ? 0 : null,
                  right: tabBarPosition == TabBarPosition.right ? 0 : null,
                  child: _SideRailToolbarLayer(
                    tabInFullScreen: tabInFullScreen,
                    tabBarPosition: tabBarPosition,
                    railWidth: railWidth,
                    resizable: canResizeRail,
                    overlay: railOverlay,
                    showContextualToolbar: showContextualToolbar,
                    quickTabSwitcherRowCount: quickTabSwitcherRowCount,
                    selectedTabId: selectedTabId,
                    suppressMainToolbar: suppressMainToolbarForHome,
                  ),
                ),

              // Layer 4: FAB (draggable via long press)
              _FabPositioner(
                selectedTabId: selectedTabId,
                tabInFullScreen: tabInFullScreen,
                tabBarPosition: tabBarPosition,
                bottomAppBarTotalHeight: bottomAppBarTotalHeight,
                bottomSafeArea: bottomSafeArea,
                sideRailTotalWidth: sideRailTotalWidth,
                child: const BrowserFab(),
              ),

              // Layer 5: Page load progress indicator (animates with toolbar visibility)
              _ProgressIndicatorPositioner(
                selectedTabId: selectedTabId,
                tabInFullScreen: tabInFullScreen,
                tabBarPosition: tabBarPosition,
                isRail: isRail,
                sideRailTotalWidth: sideRailTotalWidth,
                topSafeArea: topSafeArea,
                topAppBarTotalHeight: topAppBarTotalHeight,
                bottomAppBarTotalHeight: bottomAppBarTotalHeight,
                child: const _ProgressIndicatorBar(),
              ),

              // Layer 6: Find in Page widget (above toolbar or keyboard, whichever is higher)
              _FindInPagePositioner(
                selectedTabId: selectedTabId,
                tabInFullScreen: tabInFullScreen,
                tabBarPosition: tabBarPosition,
                isRail: isRail,
                sideRailTotalWidth: sideRailTotalWidth,
                bottomSafeArea: bottomSafeArea,
                bottomAppBarTotalHeight: bottomAppBarTotalHeight,
                child: const _FindInPageContent(),
              ),

              // Layer 7: App-link prompt banner (§2.6). Anchored above the bottom app
              // bar / keyboard exactly like find-in-page, so it is never hidden behind
              // the toolbar. Custom Tab sessions are prompted natively instead; this is
              // the browser-tab surface only.
              _AppLinkPromptLayer(
                selectedTabId: selectedTabId,
                tabInFullScreen: tabInFullScreen,
                tabBarPosition: tabBarPosition,
                isRail: isRail,
                sideRailTotalWidth: sideRailTotalWidth,
                bottomSafeArea: bottomSafeArea,
                bottomAppBarTotalHeight: bottomAppBarTotalHeight,
              ),

              // Layer 8: Sheet (when displayed). A modal bottom sheet, so it
              // spans the window above all of the browser's chrome: its scrim
              // dims the toolbars too, and the sheet itself reaches behind
              // the system bars.
              if (sheetDisplayed)
                Positioned.fill(
                  child: _SheetContainer(displayedSheet: displayedSheet),
                ),

              // Layer 9: the startup spinner, while a cold start is still
              // opening the link it was launched for. Above everything, so
              // the home surface underneath never shows (#612); dialogs are
              // routes of their own and still appear over it.
              const Positioned.fill(child: _StartupLaunchCoverLayer()),
            ],
          ),
        ),
      ),
    );

    // The sheet is modal: nothing it covers takes a shortcut.
    return BrowserKeyboardShortcutScope(
      enabled: !sheetDisplayed,
      child: screen,
    );
  }
}

/// Shows [displayedSheet] in a [BrowserSheetHost].
class _SheetContainer extends ConsumerWidget {
  final Sheet displayedSheet;

  const _SheetContainer({required this.displayedSheet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrowserSheetHost(
      sheet: switch (displayedSheet) {
        ViewTabsSheet() => const _ViewTabsSheet(),
        final SiteSettingsSheet parameter => _SiteSettingsSheet(
          initialTabState: parameter.tabState,
        ),
      },
      onDismiss: () {
        ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
      },
    );
  }
}

class _Browser extends HookConsumerWidget {
  Duration get _backButtonPressTimeout => const Duration(seconds: 2);

  final OverlayPortalController overlayController;
  final StreamSink<Offset>? pointerMoveEventSink;
  final bool tabInFullScreen;
  final bool hasTopBarOffset;
  final bool hasLeftBarOffset;
  final bool hasRightBarOffset;
  final bool applyBottomSafeArea;

  const _Browser({
    required this.overlayController,
    required this.tabInFullScreen,
    required this.pointerMoveEventSink,
    required this.hasTopBarOffset,
    required this.hasLeftBarOffset,
    required this.hasRightBarOffset,
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

      return await ui_helper.confirmIsolatedTabClose(context);
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
            // The OverlayPortal lifecycle is driven by ref.listen above, but
            // OverlayPortal can call this builder one extra frame after
            // dismiss() set the provider back to null (esp. on rebuilds
            // triggered by unrelated state changes). Render an empty box
            // instead of force-unwrapping a null builder.
            return overlayBuilder?.call(context) ?? const SizedBox.shrink();
          },
          child: BackButtonListener(
            onBackButtonPressed: () async {
              final tabState = ref.read(selectedTabStateProvider);
              final onBackBehavior = ref
                  .read(tabRepositoryProvider.notifier)
                  .backBehaviorFor(tabState?.id);

              //Don't do anything if a child route is active
              if (GoRouterState.of(context).topRoute?.name !=
                  BrowserRoute.name) {
                return false;
              }

              // Dismiss modal routes (e.g. showModalBottomSheet).
              // maybePop rather than pop: this listener runs ahead of the
              // navigator, so popping outright would skip the PopScope of
              // whatever is on top — a modal that handles back itself (the
              // menu sheet's arrangement UI, a dialog that blocks back while
              // it works) would be closed instead of being asked. Either way
              // the gesture belongs to that modal, so it counts as handled.
              final rootNavigator = Navigator.of(context, rootNavigator: true);
              if (rootNavigator.canPop()) {
                await rootNavigator.maybePop();
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

              // Arranging the home page's sections is a mode on top of the
              // home page, not a route, so back has to leave it here — the
              // browser's own back would otherwise navigate the tab (or
              // close it) out from under a user who was only reordering.
              // The search screen's surfaces answer back themselves; this
              // listener never runs while that screen is on top.
              if (ref.read(searchReorderModeProvider(ModuleSurface.home))) {
                ref
                    .read(
                      searchReorderModeProvider(ModuleSurface.home).notifier,
                    )
                    .deactivate();
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
              } else if (ref
                  .read(tabHistoryStateProvider(tabState?.id))
                  .canGoBack) {
                lastBackButtonPress.value = null;

                final controller = ref.read(selectedTabSessionProvider);

                await controller.goBack();
                return true;
              }

              if (onBackBehavior case ReturnToBrowserHomeTabBackBehavior()) {
                // Answered here rather than through the keep-or-close
                // question below: home is a layer over the selected tab, so
                // going back to it costs the user nothing and asking would be
                // about a tab they are not leaving.
                //
                // Only while the tab is what's on screen. Once home is
                // showing, back belongs to the double-back handling further
                // down — that is what leaves the app, and re-requesting home
                // from here would swallow every press instead.
                if (!ref.read(shouldShowBrowserHomeProvider)) {
                  lastBackButtonPress.value = null;

                  ref.read(forceBrowserHomeProvider.notifier).request();
                  return true;
                }
              } else if (onBackBehavior != null) {
                if (!context.mounted) return false;

                final keep = await showKeepTabDialog(context);
                if (keep == null) {
                  return true;
                }

                if (keep) {
                  if (tabState == null) {
                    return true;
                  }
                  ref
                      .read(tabRepositoryProvider.notifier)
                      .clearBackBehavior(tabState.id);
                } else if (tabState != null) {
                  if (!await confirmIsolatedTabCloseIfNeeded(tabState.id)) {
                    return true;
                  }

                  await ref
                      .read(tabRepositoryProvider.notifier)
                      .closeTab(tabState.id);
                }

                if (!context.mounted) return true;

                switch (onBackBehavior) {
                  case BackgroundAppTabBackBehavior():
                    await moveToBackground();
                  case ReturnToSearchTabBackBehavior(:final tabType):
                    ref
                        .read(searchAutofocusSuppressionProvider.notifier)
                        .suppressNext();
                    await SearchRoute(tabType: tabType).push(context);
                  case ReturnToBrowserHomeTabBackBehavior():
                    // Never prompts, so it never reaches this block.
                    break;
                }

                return true;
              }

              //Go router has routes to go back to
              if (context.canPop()) {
                return true;
              }

              // Handle double back to close (if enabled)
              if (doubleBackCloseTab) {
                // A tab is only closed when that lands somewhere the user
                // came from: another tab of the container on screen, or the
                // tab's opener, which may live in another container (#530).
                // Closing a container's last tab otherwise selects a tab of
                // some other container, so repeated presses emptied every
                // container in turn (#616); leaving the app is the end of
                // the line instead. On home no tab is on screen, so there is
                // nothing to close either.
                var canCloseTab = false;
                if (tabState != null &&
                    !ref.read(shouldShowBrowserHomeProvider)) {
                  final containerId = await ref
                      .read(tabDataRepositoryProvider.notifier)
                      .getTabContainerId(tabState.id);
                  if (!context.mounted) return true;

                  final containerTabIds = await ref
                      .read(containerRepositoryProvider.notifier)
                      .getContainerTabIds(containerId);
                  if (!context.mounted) return true;

                  // Rows of closed tabs are only deleted once the engine's
                  // tab list sync catches up, so the stored ids alone can
                  // still count a tab that is already gone.
                  final liveTabIds = ref.read(tabListProvider).value.toSet();
                  final containerTabCount = containerTabIds
                      .where(liveTabIds.contains)
                      .length;

                  canCloseTab =
                      containerTabCount > 1 ||
                      await ref
                          .read(tabRepositoryProvider.notifier)
                          .hasOpenAncestor(tabState.id);
                  if (!context.mounted) return true;

                  // The lookups above yield, so another back press, a tab
                  // switch or a route may have come in between. The answer
                  // describes the tab that was on screen when they started;
                  // act on it only if that is still what the user sees, and
                  // otherwise let this press go.
                  if (ref.read(selectedTabProvider) != tabState.id ||
                      ref.read(shouldShowBrowserHomeProvider) ||
                      GoRouterState.of(context).topRoute?.name !=
                          BrowserRoute.name ||
                      Navigator.of(context, rootNavigator: true).canPop()) {
                    return true;
                  }
                }

                if (lastBackButtonPress.value != null &&
                    DateTime.now().difference(lastBackButtonPress.value!) <
                        _backButtonPressTimeout) {
                  lastBackButtonPress.value = null;

                  if (tabState != null && canCloseTab) {
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
                    canCloseTab,
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
              hasLeftBarOffset: hasLeftBarOffset,
              hasRightBarOffset: hasRightBarOffset,
              applyBottomSafeArea: applyBottomSafeArea,
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
  final bool hasLeftBarOffset;
  final bool hasRightBarOffset;
  final bool applyBottomSafeArea;

  const _BrowserView({
    required this.isFullscreen,
    required this.hasTopBarOffset,
    required this.hasLeftBarOffset,
    required this.hasRightBarOffset,
    required this.applyBottomSafeArea,
    this.pointerMoveEventSink,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Disable top SafeArea when top bar handles it (has offset applied)
      top: !isFullscreen && !hasTopBarOffset,
      // Disable a side's SafeArea when the rail on that edge already consumed
      // the inset via the content offset.
      right: !isFullscreen && !hasRightBarOffset,
      // See `applyBottomSafeArea` in [_BrowserContentPositioned].
      bottom: applyBottomSafeArea,
      // The navigation bar's height, also while the keyboard covers it: a
      // keyboard opened for a field in a sheet leaves the page where it is,
      // and the inset dropping to 0 under it would grow the page view.
      maintainBottomViewPadding: true,
      left: !isFullscreen && !hasLeftBarOffset,
      child: Stack(
        children: [BrowserView(pointerMoveEventSink: pointerMoveEventSink)],
      ),
    );
  }
}

class _SiteSettingsSheet extends HookConsumerWidget {
  final TabState initialTabState;

  static const initialHeight = 0.8;

  const _SiteSettingsSheet({required this.initialTabState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final draggableScrollableController = useDraggableScrollableController();

    void handleSectionExpansion(bool isExpanded) {
      if (isExpanded) {
        unawaited(
          draggableScrollableController.moveTo(
            1.0,
            disableAnimations: disableAnimations,
          ),
        );
      }
    }

    return PointerScrollableSheet(
      controller: draggableScrollableController,
      expand: false,
      initialChildSize: initialHeight,
      minChildSize: 0.1,
      builder: (context, scrollController) {
        return BrowserSheetSurface(
          // The browser's own sheets keep their color from before they were
          // modal.
          color: Theme.of(context).canvasColor,
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
            onSectionExpandedChanged: handleSectionExpansion,
          ),
        );
      },
    );
  }
}

class _ViewTabsSheet extends HookConsumerWidget {
  /// Matches [DraggableScrollableSheet]'s default.
  static const initialHeight = 0.5;

  const _ViewTabsSheet();

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
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    // The search field opens in the header, at the top of the tray, and takes
    // the keyboard with it. The tray's content stays above the keyboard, and
    // at its initial height that leaves next to no room for the header and
    // the results. Searching expands the tray, which puts the field at the
    // top of the window and the results between it and the keyboard.
    ref.listen(tabViewSearchModeControllerProvider, (previous, searching) {
      if (!searching || !draggableScrollableController.isAttached) return;

      unawaited(
        draggableScrollableController.moveTo(
          1.0,
          disableAnimations: disableAnimations,
        ),
      );
    });

    return PointerScrollableSheet(
      key: ValueKey(tabsReorderable),
      controller: draggableScrollableController,
      expand: false,
      initialChildSize: initialHeight,
      minChildSize: 0.1,
      builder: (context, scrollController) {
        return BrowserSheetSurface(
          // As in [_SiteSettingsSheet].
          color: Theme.of(context).canvasColor,
          // The header and the action bar run behind the system bars, so the
          // bars take their colors (#651).
          extendBehindSystemBars: true,
          child: TabTrayGestures(
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
                draggableScrollableController: draggableScrollableController,
                showNewTabFab: true,
                onClose: () {
                  ref
                      .read(bottomSheetControllerProvider.notifier)
                      .requestDismiss();
                },
              ),
            },
          ),
        );
      },
    );
  }
}
