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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/small_web/presentation/widgets/small_web_browser_overlay.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

/// What one bar of the browser chrome holds, and so how tall it is.
///
/// Built only by [BrowserChromeLayout.resolve]. The bar that is drawn and the
/// height the page is inset by both come from the same spec, so they cannot
/// disagree.
class BrowserBarSpec with FastEquatable {
  /// The edge the tab bar is docked to, as the layout resolved it: the side
  /// of a rail, and for the horizontal bars the top or bottom edge the address
  /// bar is on. Small web pins it to the top whatever the setting says.
  ///
  /// The bar takes its axis, title and swipe directions from this rather than
  /// from the tab bar position setting, which the layout may have overridden.
  final TabBarPosition position;

  /// Whether the address bar row belongs to this bar.
  final bool showMainToolbar;

  /// Whether the contextual toolbar row is drawn in this bar.
  final bool showContextualToolbar;

  /// Quick tab switcher rows drawn in this bar.
  final int quickTabSwitcherRowCount;

  /// Where the switcher rows sit in a horizontal bar. Ignored by the rails.
  final QuickTabSwitcherOrder quickTabSwitcherOrder;

  /// Drops the address bar row on the home surface; see
  /// [BrowserTabBar.suppressMainToolbar].
  final bool suppressMainToolbar;

  /// Whether a contextual toolbar exists anywhere, so the address bar row
  /// leaves out the buttons it already carries.
  final bool hideMainToolbarButtonsDuplicatedInContextualToolbar;

  final bool isSmallWebMode;
  final bool enableGestures;

  BrowserBarSpec({
    required this.position,
    required this.showMainToolbar,
    required this.showContextualToolbar,
    required this.quickTabSwitcherRowCount,
    required this.suppressMainToolbar,
    required this.hideMainToolbarButtonsDuplicatedInContextualToolbar,
    this.quickTabSwitcherOrder = QuickTabSwitcherOrder.beforeAddressBar,
    this.isSmallWebMode = false,
    this.enableGestures = true,
  });

  bool get displayAppBar => showMainToolbar && !suppressMainToolbar;

  /// The bar's height, without the system safe area.
  double get height => BrowserTabBar.heightFor(
    displayAppBar: displayAppBar,
    showContextualToolbar: showContextualToolbar,
    quickTabSwitcherRowCount: quickTabSwitcherRowCount,
  );

  @override
  List<Object?> get hashParameters => [
    position,
    showMainToolbar,
    showContextualToolbar,
    quickTabSwitcherRowCount,
    quickTabSwitcherOrder,
    suppressMainToolbar,
    hideMainToolbarButtonsDuplicatedInContextualToolbar,
    isSmallWebMode,
    enableGestures,
  ];
}

/// Where the browser puts its chrome, decided from settings and the window
/// alone.
///
/// The one place this is worked out. The browser screen insets the page and
/// draws its bars from it, and the Toolbar & Layout preview draws the same
/// bars from it, so the preview cannot show a layout the browser would not.
///
/// Pure on purpose: the browser builds it from the providers it watches, the
/// preview from a settings value and a window it may only be imagining.
class BrowserChromeLayout with FastEquatable {
  /// The edge the tab bar is docked to.
  final TabBarPosition position;

  /// Whether the contextual toolbar is shown at all.
  final bool showContextualToolbar;

  /// Whether the address bar row is dropped for the home surface.
  final bool suppressMainToolbar;

  /// Where the home surface's search entry goes, resolved for the window.
  /// Never [HomeSearchBarPlacement.auto].
  final HomeSearchBarPlacement homeSearchBarPlacement;

  /// Whether the horizontal bar hides while the page scrolls.
  final bool autoHide;

  /// Small web replaces the bottom bar with its own overlay.
  final bool isSmallWeb;

  /// Content width of the side rail, for the window (computed even when the
  /// bar is horizontal, where nothing uses it).
  final double railWidth;

  /// Whether the side rail carries its resize handle.
  final bool railResizable;

  /// Whether the side rail slides in over the page instead of beside it.
  final bool railOverlay;

  /// The bar at the top edge: present only while the tab bar is there.
  final BrowserBarSpec? topBar;

  /// The bar at the bottom edge: absent for a side rail and in small web.
  final BrowserBarSpec? bottomBar;

  /// The side rail: present only while the tab bar is docked to a side.
  final BrowserBarSpec? rail;

  BrowserChromeLayout._({
    required this.position,
    required this.showContextualToolbar,
    required this.suppressMainToolbar,
    required this.homeSearchBarPlacement,
    required this.autoHide,
    required this.isSmallWeb,
    required this.railWidth,
    required this.railResizable,
    required this.railOverlay,
    required this.topBar,
    required this.bottomBar,
    required this.rail,
  });

  /// Resolves the layout from inputs the caller has already read.
  ///
  /// [position] is the tab bar position resolved for the window, [hasTabList]
  /// whether the effective stacking mode shows a tab list at all.
  /// [quickTabSwitcherRowCount] is the number of switcher rows that have
  /// something in them, which only live tab data can tell.
  ///
  /// [cursorInUse] and [autoHideTabBar] are only consulted where they matter,
  /// so a caller that watches them may watch them only there.
  factory BrowserChromeLayout.resolve({
    required TabBarPosition position,
    required WindowSizeClass window,
    required double windowWidth,
    required bool contextualToolbarEnabled,
    required int quickTabSwitcherRowCount,
    required bool hasTabList,
    required QuickTabSwitcherPlacement quickTabSwitcherPlacement,
    required bool showBrowserHome,
    required HomeSearchBarPlacement homeSearchBarPlacement,
    required bool autoHideTabBar,
    required bool sideRailAutoHide,
    required double sideRailWidth,
    required bool cursorInUse,
    double? sideRailDragWidth,
    double? devicePixelRatio,
    bool isSmallWeb = false,
  }) {
    final effectivePosition = isSmallWeb ? TabBarPosition.top : position;
    final showContextualToolbar = !isSmallWeb && contextualToolbarEnabled;
    final rowCount = isSmallWeb ? 0 : quickTabSwitcherRowCount;
    final isRail = effectivePosition.isVertical;

    final suppressMainToolbar = suppressMainToolbarForHome(
      showBrowserHome: showBrowserHome,
      showContextualToolbar: showContextualToolbar,
      placement: homeSearchBarPlacement,
    );

    final railWidth = BrowserTabBar.railWidthFor(
      window,
      hasTabList: hasTabList,
      // A resize in progress wins over the saved width, so the panel and the
      // page follow the handle while it moves.
      preferredWidth: sideRailDragWidth ?? sideRailWidth,
      windowWidth: windowWidth,
      devicePixelRatio: devicePixelRatio,
    );

    BrowserBarSpec? topBar;
    BrowserBarSpec? bottomBar;
    BrowserBarSpec? rail;

    if (isRail) {
      rail = BrowserBarSpec(
        position: effectivePosition,
        showMainToolbar: true,
        showContextualToolbar: showContextualToolbar,
        quickTabSwitcherRowCount: rowCount,
        suppressMainToolbar: suppressMainToolbar,
        hideMainToolbarButtonsDuplicatedInContextualToolbar:
            showContextualToolbar,
      );
    } else {
      final addressBarOnTop = effectivePosition == TabBarPosition.top;

      if (addressBarOnTop) {
        // The switcher only joins the address bar up here; otherwise it
        // belongs to the bottom bar.
        final switcher = quickTabSwitcherPlacement.resolve(TabBarPosition.top);
        topBar = BrowserBarSpec(
          position: effectivePosition,
          showMainToolbar: true,
          // The contextual toolbar always stays at the bottom edge.
          showContextualToolbar: false,
          quickTabSwitcherRowCount: switcher.inTopBar ? rowCount : 0,
          quickTabSwitcherOrder: switcher.order,
          suppressMainToolbar: suppressMainToolbar,
          hideMainToolbarButtonsDuplicatedInContextualToolbar:
              showContextualToolbar,
          isSmallWebMode: isSmallWeb,
          enableGestures: !isSmallWeb,
        );
      }

      if (!isSmallWeb) {
        final switcher = quickTabSwitcherPlacement.resolve(
          addressBarOnTop ? TabBarPosition.top : TabBarPosition.bottom,
        );
        bottomBar = BrowserBarSpec(
          position: effectivePosition,
          showMainToolbar: !addressBarOnTop,
          showContextualToolbar: showContextualToolbar,
          quickTabSwitcherRowCount: switcher.inTopBar ? 0 : rowCount,
          quickTabSwitcherOrder: switcher.order,
          suppressMainToolbar: suppressMainToolbar,
          hideMainToolbarButtonsDuplicatedInContextualToolbar:
              showContextualToolbar,
        );
      }
    }

    return BrowserChromeLayout._(
      position: effectivePosition,
      showContextualToolbar: showContextualToolbar,
      suppressMainToolbar: suppressMainToolbar,
      homeSearchBarPlacement: homeSearchBarPlacement,
      // Auto-hide is not supported on the rail, nor for small web's bars.
      autoHide: !isSmallWeb && effectivePosition.isHorizontal && autoHideTabBar,
      isSmallWeb: isSmallWeb,
      railWidth: railWidth,
      railResizable:
          isRail && BrowserTabBar.canResizeRail(window, hasTabList: hasTabList),
      // Gated on the cursor being the input in use: only the cursor can reveal
      // an auto-hiding rail, so the moment the user touches the screen the
      // rail goes back beside the page, where touch can reach it.
      railOverlay: isRail && sideRailAutoHide && cursorInUse,
      topBar: topBar,
      bottomBar: bottomBar,
      rail: rail,
    );
  }

  /// [resolve], reading every setting the browser's providers read from
  /// [settings] directly.
  ///
  /// For a caller that has a settings value rather than providers: the
  /// Toolbar & Layout preview, drawing a window that may not be this one.
  factory BrowserChromeLayout.fromSettings(
    GeneralSettings settings, {
    required WindowSizeClass window,
    required double windowWidth,
    required int quickTabSwitcherRowCount,
    bool showBrowserHome = false,
    bool cursorInUse = false,
    double? sideRailDragWidth,
  }) => BrowserChromeLayout.resolve(
    position: settings.effectiveTabBarPosition(window: window),
    window: window,
    windowWidth: windowWidth,
    contextualToolbarEnabled: settings.tabBarShowContextualBar,
    quickTabSwitcherRowCount: quickTabSwitcherRowCount,
    hasTabList:
        settings.effectiveTabBarStackingMode(
          window: window,
          sideRailWidthOverride: sideRailDragWidth,
        ) !=
        TabBarStackingMode.disabled,
    quickTabSwitcherPlacement: settings.quickTabSwitcherPlacement,
    showBrowserHome: showBrowserHome,
    homeSearchBarPlacement: settings.effectiveHomeSearchBarPlacement(
      window: window,
    ),
    autoHideTabBar: settings.autoHideTabBar,
    sideRailAutoHide: settings.sideRailAutoHide,
    sideRailWidth: settings.sideRailWidth,
    cursorInUse: cursorInUse,
    sideRailDragWidth: sideRailDragWidth,
  );

  bool get isRail => position.isVertical;

  /// Height of the top bar's content, without the system safe area.
  double get topBarHeight => topBar?.height ?? 0.0;

  /// Height of the bottom bar's content (or small web's overlay), without the
  /// system safe area.
  double get bottomBarHeight {
    if (isSmallWeb) return SmallWebBrowserOverlay.barHeight;
    return bottomBar?.height ?? 0.0;
  }

  /// Width the page gives up to the side rail, without the system safe area.
  /// Nothing for a rail that slides in over the page.
  double get sideRailReservedWidth => isRail && !railOverlay ? railWidth : 0.0;

  @override
  List<Object?> get hashParameters => [
    position,
    showContextualToolbar,
    suppressMainToolbar,
    homeSearchBarPlacement,
    autoHide,
    isSmallWeb,
    railWidth,
    railResizable,
    railOverlay,
    topBar,
    bottomBar,
    rail,
  ];
}

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
/// empty strip and still reserve `kToolbarHeight`.
bool suppressMainToolbarForHome({
  required bool showBrowserHome,
  required bool showContextualToolbar,
  required HomeSearchBarPlacement placement,
}) =>
    showBrowserHome &&
    showContextualToolbar &&
    placement != HomeSearchBarPlacement.tabBar;
