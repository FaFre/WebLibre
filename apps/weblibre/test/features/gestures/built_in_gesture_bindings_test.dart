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
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/gestures/data/models/built_in_gesture.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

void main() {
  final defaults = GestureSettings.withDefaults();
  const lastUsed = TabBarSwipeAction.switchLastOpened;
  const ordered = TabBarSwipeAction.navigateOrderedTabs;

  test('defaults keep what the swipes always did', () {
    BrowserAction? binding(BuiltInGesture gesture) =>
        defaults.builtInBinding(gesture, legacyTabBarSwipe: lastUsed);

    expect(
      binding(BuiltInGesture.tabBarSwipeBackward),
      BrowserAction.lastUsedTab,
    );
    expect(
      binding(BuiltInGesture.tabBarSwipeForward),
      BrowserAction.lastUsedTab,
    );
    expect(
      binding(BuiltInGesture.tabBarSwipeOutward),
      BrowserAction.toggleTabBar,
    );
    expect(
      binding(BuiltInGesture.tabBarSwipeInward),
      BrowserAction.showTabView,
    );
    expect(binding(BuiltInGesture.tabSwipeLeft), BrowserAction.closeTab);
    expect(binding(BuiltInGesture.tabSwipeRight), BrowserAction.closeTab);
  });

  test('the old sequential tab bar setting still decides the default', () {
    expect(
      defaults.builtInBinding(
        BuiltInGesture.tabBarSwipeBackward,
        legacyTabBarSwipe: ordered,
      ),
      BrowserAction.previousTab,
    );
    expect(
      defaults.builtInBinding(
        BuiltInGesture.tabBarSwipeForward,
        legacyTabBarSwipe: ordered,
      ),
      BrowserAction.nextTab,
    );
  });

  test('switching a gesture off is stored as null', () {
    final settings = defaults.withBuiltInBinding(
      BuiltInGesture.tabSwipeLeft,
      null,
      legacyTabBarSwipe: lastUsed,
    );

    expect(settings.builtInOverrides, {BuiltInGesture.tabSwipeLeft: null});
    expect(
      settings.builtInBinding(
        BuiltInGesture.tabSwipeLeft,
        legacyTabBarSwipe: lastUsed,
      ),
      isNull,
    );
  });

  test('choosing the default again leaves no override', () {
    final settings = defaults
        .withBuiltInBinding(
          BuiltInGesture.tabSwipeRight,
          BrowserAction.sharePage,
          legacyTabBarSwipe: lastUsed,
        )
        .withBuiltInBinding(
          BuiltInGesture.tabSwipeRight,
          BrowserAction.closeTab,
          legacyTabBarSwipe: lastUsed,
        );

    expect(settings.builtInOverrides, isEmpty);
  });

  test('overrides survive a JSON round trip, switched-off ones included', () {
    final settings = defaults
        .withBuiltInBinding(
          BuiltInGesture.tabSwipeRight,
          BrowserAction.toggleBookmark,
          legacyTabBarSwipe: lastUsed,
        )
        .withBuiltInBinding(
          BuiltInGesture.tabBarSwipeInward,
          null,
          legacyTabBarSwipe: lastUsed,
        );

    final restored = GestureSettings.fromJson(settings.toJson());

    expect(restored.builtInOverrides, {
      BuiltInGesture.tabSwipeRight: BrowserAction.toggleBookmark,
      BuiltInGesture.tabBarSwipeInward: null,
    });
  });

  test('tab swipes only offer actions that work on another tab', () {
    expect(
      BuiltInGesture.tabSwipeLeft.allowedActions,
      BuiltInGesture.tabActions,
    );
    expect(
      BuiltInGesture.tabBarSwipeForward.allowedActions,
      BrowserAction.values,
    );
  });
}
