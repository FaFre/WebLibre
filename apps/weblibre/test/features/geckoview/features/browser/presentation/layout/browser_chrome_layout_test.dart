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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/layout/browser_chrome_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/small_web/presentation/widgets/small_web_browser_overlay.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

const _contextual = BrowserTabBar.contextualToolabarHeight;
const _row = BrowserTabBar.quickTabSwitcherHeight;

final _tablet = WindowSizeClass.fromSize(const Size(1280, 800));

BrowserChromeLayout _resolve({
  TabBarPosition position = TabBarPosition.bottom,
  WindowSizeClass window = WindowSizeClass.compact,
  double windowWidth = 392,
  bool contextual = true,
  int rows = 1,
  bool hasTabList = true,
  QuickTabSwitcherPlacement placement = QuickTabSwitcherPlacement.auto,
  bool home = false,
  HomeSearchBarPlacement homePlacement = HomeSearchBarPlacement.top,
  bool autoHide = true,
  bool railAutoHide = false,
  bool cursorInUse = false,
  double sideRailWidth = defaultSideRailWidth,
  bool smallWeb = false,
}) => BrowserChromeLayout.resolve(
  position: position,
  window: window,
  windowWidth: windowWidth,
  contextualToolbarEnabled: contextual,
  quickTabSwitcherRowCount: rows,
  hasTabList: hasTabList,
  quickTabSwitcherPlacement: placement,
  showBrowserHome: home,
  homeSearchBarPlacement: homePlacement,
  autoHideTabBar: autoHide,
  sideRailAutoHide: railAutoHide,
  sideRailWidth: sideRailWidth,
  cursorInUse: cursorInUse,
  isSmallWeb: smallWeb,
);

void main() {
  group('horizontal bars', () {
    test('a bottom tab bar holds every row in the bottom bar', () {
      final layout = _resolve();

      expect(layout.topBar, isNull);
      expect(layout.rail, isNull);
      final bar = layout.bottomBar!;
      expect(bar.showMainToolbar, isTrue);
      expect(bar.showContextualToolbar, isTrue);
      expect(bar.quickTabSwitcherRowCount, 1);
      expect(bar.quickTabSwitcherOrder, QuickTabSwitcherOrder.beforeAddressBar);
      expect(layout.bottomBarHeight, kToolbarHeight + _contextual + _row);
      expect(layout.topBarHeight, 0);
    });

    test('a top tab bar leaves the contextual bar and, on auto, the switcher '
        'at the bottom', () {
      final layout = _resolve(position: TabBarPosition.top);

      final top = layout.topBar!;
      expect(top.showMainToolbar, isTrue);
      expect(top.showContextualToolbar, isFalse);
      expect(top.quickTabSwitcherRowCount, 0);
      expect(layout.topBarHeight, kToolbarHeight);

      final bottom = layout.bottomBar!;
      expect(bottom.showMainToolbar, isFalse);
      expect(bottom.showContextualToolbar, isTrue);
      expect(bottom.quickTabSwitcherRowCount, 1);
      expect(layout.bottomBarHeight, _contextual + _row);
    });

    test(
      'a switcher placed next to a top address bar moves to the top bar',
      () {
        for (final (placement, order) in [
          (
            QuickTabSwitcherPlacement.aboveAddressBar,
            QuickTabSwitcherOrder.beforeAddressBar,
          ),
          (
            QuickTabSwitcherPlacement.belowAddressBar,
            QuickTabSwitcherOrder.afterAddressBar,
          ),
        ]) {
          final layout = _resolve(
            position: TabBarPosition.top,
            placement: placement,
          );

          expect(
            layout.topBar!.quickTabSwitcherRowCount,
            1,
            reason: '$placement',
          );
          expect(layout.topBar!.quickTabSwitcherOrder, order);
          expect(layout.bottomBar!.quickTabSwitcherRowCount, 0);
          expect(layout.topBarHeight, kToolbarHeight + _row);
          expect(layout.bottomBarHeight, _contextual);
        }
      },
    );

    test('below the contextual bar stays in the bottom bar, last', () {
      final layout = _resolve(
        placement: QuickTabSwitcherPlacement.belowContextualBar,
      );

      expect(
        layout.bottomBar!.quickTabSwitcherOrder,
        QuickTabSwitcherOrder.afterContextualBar,
      );
    });

    test('two stacked rows count twice', () {
      expect(
        _resolve(rows: 2).bottomBarHeight,
        kToolbarHeight + _contextual + 2 * _row,
      );
      expect(_resolve(rows: 0).bottomBarHeight, kToolbarHeight + _contextual);
    });

    test('without a contextual bar the address row keeps its buttons', () {
      final layout = _resolve(contextual: false);

      expect(layout.showContextualToolbar, isFalse);
      expect(
        layout.bottomBar!.hideMainToolbarButtonsDuplicatedInContextualToolbar,
        isFalse,
      );
      expect(layout.bottomBarHeight, kToolbarHeight + _row);
    });

    test('auto-hide follows the setting', () {
      expect(_resolve().autoHide, isTrue);
      expect(_resolve(autoHide: false).autoHide, isFalse);
    });
  });

  group('home surface', () {
    test('drops the address row when the pill and a contextual bar exist', () {
      final layout = _resolve(home: true);

      expect(layout.suppressMainToolbar, isTrue);
      expect(layout.bottomBar!.displayAppBar, isFalse);
      expect(layout.bottomBarHeight, _contextual + _row);
    });

    test('keeps it when the address field is the home search entry', () {
      final layout = _resolve(
        home: true,
        homePlacement: HomeSearchBarPlacement.tabBar,
      );

      expect(layout.suppressMainToolbar, isFalse);
    });

    test('keeps it without a contextual bar, the menu has no other home', () {
      expect(
        _resolve(home: true, contextual: false).suppressMainToolbar,
        isFalse,
      );
    });
  });

  group('side rail', () {
    test('tells the rail which side it is docked to', () {
      expect(
        _resolve(position: TabBarPosition.right).rail!.position,
        TabBarPosition.right,
      );
    });

    test('holds every row and reserves its width', () {
      final layout = _resolve(position: TabBarPosition.left);

      expect(layout.isRail, isTrue);
      expect(layout.topBar, isNull);
      expect(layout.bottomBar, isNull);
      expect(layout.rail!.showMainToolbar, isTrue);
      expect(layout.rail!.showContextualToolbar, isTrue);
      expect(layout.rail!.quickTabSwitcherRowCount, 1);
      expect(layout.bottomBarHeight, 0);
      expect(layout.railWidth, BrowserTabBar.compactRailWidth);
      expect(layout.sideRailReservedWidth, BrowserTabBar.compactRailWidth);
    });

    test('never auto-hides with the page', () {
      expect(_resolve(position: TabBarPosition.right).autoHide, isFalse);
    });

    test('is a resizable panel only in a large window with a tab list', () {
      final panel = _resolve(
        position: TabBarPosition.left,
        window: _tablet,
        windowWidth: 1280,
      );
      expect(panel.railResizable, isTrue);
      expect(panel.railWidth, defaultSideRailWidth);

      final noTabs = _resolve(
        position: TabBarPosition.left,
        window: _tablet,
        windowWidth: 1280,
        hasTabList: false,
      );
      expect(noTabs.railResizable, isFalse);
      expect(noTabs.railWidth, BrowserTabBar.mediumRailWidth);

      expect(_resolve(position: TabBarPosition.left).railResizable, isFalse);
    });

    test('slides over the page only while auto-hiding under a cursor', () {
      final overlay = _resolve(
        position: TabBarPosition.left,
        railAutoHide: true,
        cursorInUse: true,
      );
      expect(overlay.railOverlay, isTrue);
      expect(overlay.sideRailReservedWidth, 0);

      expect(
        _resolve(position: TabBarPosition.left, railAutoHide: true).railOverlay,
        isFalse,
      );
      expect(
        _resolve(railAutoHide: true, cursorInUse: true).railOverlay,
        isFalse,
        reason: 'a horizontal bar is never an overlay rail',
      );
    });
  });

  group('small web', () {
    test('forces the top bar and swaps the bottom bar for its overlay', () {
      final layout = _resolve(position: TabBarPosition.left, smallWeb: true);

      expect(layout.position, TabBarPosition.top);
      expect(layout.showContextualToolbar, isFalse);
      expect(layout.autoHide, isFalse);
      expect(layout.bottomBar, isNull);
      expect(layout.bottomBarHeight, SmallWebBrowserOverlay.barHeight);

      final top = layout.topBar!;
      // The bar draws itself for the edge it is really on, not for the
      // left rail the setting asks for.
      expect(top.position, TabBarPosition.top);
      expect(top.isSmallWebMode, isTrue);
      expect(top.enableGestures, isFalse);
      expect(top.quickTabSwitcherRowCount, 0);
      expect(layout.topBarHeight, kToolbarHeight);
    });
  });

  group('fromSettings', () {
    test('resolves as the browser does from the same settings', () {
      for (final (window, width) in [
        (WindowSizeClass.compact, 392.0),
        (_tablet, 1280.0),
      ]) {
        final settings = GeneralSettings.withDefaults();
        final fromSettings = BrowserChromeLayout.fromSettings(
          settings,
          window: window,
          windowWidth: width,
          quickTabSwitcherRowCount: 1,
        );
        final resolved = _resolve(
          position: settings.effectiveTabBarPosition(window: window),
          window: window,
          windowWidth: width,
          contextual: settings.tabBarShowContextualBar,
          hasTabList:
              settings.effectiveTabBarStackingMode(window: window) !=
              TabBarStackingMode.disabled,
          placement: settings.quickTabSwitcherPlacement,
          homePlacement: settings.effectiveHomeSearchBarPlacement(
            window: window,
          ),
          autoHide: settings.autoHideTabBar,
          railAutoHide: settings.sideRailAutoHide,
          sideRailWidth: settings.sideRailWidth,
        );

        expect(fromSettings, resolved, reason: '$window');
      }
    });
  });

  group('bar widgets', () {
    test('report the height of the spec they draw', () {
      final layout = _resolve(position: TabBarPosition.top);

      expect(
        BrowserTopAppBar(bar: layout.topBar!).preferredSize.height,
        layout.topBarHeight,
      );
      expect(
        BrowserBottomAppBar(bar: layout.bottomBar!).preferredSize.height,
        layout.bottomBarHeight,
      );
    });
  });
}
