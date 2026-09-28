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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

/// Where in the app a [BuiltInGesture] is made.
enum BuiltInGestureSurface { tabBar, tabView }

/// The swipes WebLibre recognizes outside web content, each bound to a
/// [BrowserAction] the user can change or switch off (issue #626).
///
/// Persisted by [name] in `GestureSettings.builtInOverrides`: renaming a value
/// silently drops the user's choice for it.
enum BuiltInGesture {
  /// Leftward along a horizontal bar, upward along the side rail.
  tabBarSwipeBackward(BuiltInGestureSurface.tabBar, Icons.swipe_left_outlined),

  /// Rightward along a horizontal bar, downward along the side rail.
  tabBarSwipeForward(BuiltInGestureSurface.tabBar, Icons.swipe_right_outlined),

  /// Off the screen edge the bar is docked to.
  tabBarSwipeOutward(BuiltInGestureSurface.tabBar, MdiIcons.gestureSwipeDown),

  /// Away from the edge the bar is docked to.
  tabBarSwipeInward(BuiltInGestureSurface.tabBar, MdiIcons.gestureSwipeUp),

  tabSwipeLeft(BuiltInGestureSurface.tabView, MdiIcons.gestureSwipeLeft),
  tabSwipeRight(BuiltInGestureSurface.tabView, MdiIcons.gestureSwipeRight);

  final BuiltInGestureSurface surface;

  /// Pictures the movement itself, not the action it is bound to.
  final IconData icon;

  const BuiltInGesture(this.surface, this.icon);

  /// Whether the action runs on the tab the gesture was made on rather than on
  /// the selected tab, which limits it to [tabActions].
  bool get targetsTab => surface == BuiltInGestureSurface.tabView;

  /// The actions that mean something for a tab other than the selected one:
  /// none of them needs the page to be on screen.
  static const tabActions = [
    BrowserAction.closeTab,
    BrowserAction.toggleBookmark,
    BrowserAction.sharePage,
    BrowserAction.togglePinTab,
    BrowserAction.duplicateTab,
    BrowserAction.moveTabToStart,
    BrowserAction.moveTabToEnd,
  ];

  /// The actions this gesture can be bound to.
  List<BrowserAction> get allowedActions =>
      targetsTab ? tabActions : BrowserAction.values;

  /// What the gesture does until the user changes it.
  ///
  /// The swipes along the bar used to be configured by [TabBarSwipeAction] in
  /// the general settings; that choice still decides their default, so
  /// someone who picked sequential navigation keeps it.
  BrowserAction defaultAction(TabBarSwipeAction legacyTabBarSwipe) =>
      switch (this) {
        tabBarSwipeBackward => switch (legacyTabBarSwipe) {
          TabBarSwipeAction.switchLastOpened => BrowserAction.lastUsedTab,
          TabBarSwipeAction.navigateOrderedTabs => BrowserAction.previousTab,
        },
        tabBarSwipeForward => switch (legacyTabBarSwipe) {
          TabBarSwipeAction.switchLastOpened => BrowserAction.lastUsedTab,
          TabBarSwipeAction.navigateOrderedTabs => BrowserAction.nextTab,
        },
        tabBarSwipeOutward => BrowserAction.toggleTabBar,
        tabBarSwipeInward => BrowserAction.showTabView,
        tabSwipeLeft || tabSwipeRight => BrowserAction.closeTab,
      };
}
