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
enum BuiltInGestureSurface {
  tabBar('Tab Bar Swipes', 'Swipes on the tab bar or the side rail'),
  tabView('Tab View Swipes', 'Swipes on a tab in the tab list or grid');

  final String title;
  final String description;

  const BuiltInGestureSurface(this.title, this.description);
}

/// The swipes WebLibre recognizes outside web content, each bound to a
/// [BrowserAction] the user can change or switch off (issue #626).
///
/// Persisted by [name] in `GestureSettings.builtInOverrides`: renaming a value
/// silently drops the user's choice for it.
enum BuiltInGesture {
  /// Leftward along a horizontal bar, upward along the side rail.
  tabBarSwipeBackward(
    BuiltInGestureSurface.tabBar,
    Icons.swipe_left_outlined,
    'Swipe left along the bar',
    'Also triggers up on the side rail',
  ),

  /// Rightward along a horizontal bar, downward along the side rail.
  tabBarSwipeForward(
    BuiltInGestureSurface.tabBar,
    Icons.swipe_right_outlined,
    'Swipe right along the bar',
    'Also triggers down on the side rail',
  ),

  /// Off the screen edge the bar is docked to.
  tabBarSwipeOutward(
    BuiltInGestureSurface.tabBar,
    MdiIcons.gestureSwipeDown,
    'Swipe toward the screen edge',
    'Down on a bottom bar, up on a top bar, sideways off a rail',
  ),

  /// Away from the edge the bar is docked to.
  tabBarSwipeInward(
    BuiltInGestureSurface.tabBar,
    MdiIcons.gestureSwipeUp,
    'Swipe away from the screen edge',
    'Up on a bottom bar, down on a top bar, sideways into the page on a rail',
  ),

  tabSwipeLeft(
    BuiltInGestureSurface.tabView,
    MdiIcons.gestureSwipeLeft,
    'Swipe a tab left',
    'Acts on the swiped tab, not the open one',
  ),
  tabSwipeRight(
    BuiltInGestureSurface.tabView,
    MdiIcons.gestureSwipeRight,
    'Swipe a tab right',
    'Acts on the swiped tab, not the open one',
  );

  final BuiltInGestureSurface surface;

  /// Pictures the movement itself, not the action it is bound to.
  final IconData icon;
  final String title;
  final String description;

  const BuiltInGesture(this.surface, this.icon, this.title, this.description);

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
