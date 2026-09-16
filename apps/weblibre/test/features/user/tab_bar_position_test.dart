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
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

const phone = WindowSizeClass.compact;
final smallTablet = WindowSizeClass.fromSize(const Size(700, 1000));
final tablet = WindowSizeClass.fromSize(const Size(1280, 800));
final landscapePhone = WindowSizeClass.fromSize(const Size(840, 390));

GeneralSettings settingsWith({
  TabBarPositionSetting? position,
  TabBarStackingMode? stacking,
  bool? showContainerUi,
}) => GeneralSettings.withDefaults(
  tabBarPosition: position,
  tabBarStackingMode: stacking,
  showContainerUi: showContainerUi,
);

void main() {
  group('TabBarPositionSetting', () {
    test('is auto by default', () {
      // New installs decide for themselves. Existing installs are unaffected
      // on a phone, because auto resolves to bottom there -- which is what the
      // old default was.
      expect(
        GeneralSettings.withDefaults().tabBarPosition,
        TabBarPositionSetting.auto,
      );
    });

    test('auto is a bottom bar on a phone', () {
      expect(TabBarPositionSetting.auto.resolve(phone), TabBarPosition.bottom);
    });

    test('auto is a side rail from medium width upwards', () {
      expect(
        TabBarPositionSetting.auto.resolve(smallTablet),
        TabBarPosition.left,
      );
      expect(TabBarPositionSetting.auto.resolve(tablet), TabBarPosition.left);
    });

    test('auto stays a bottom bar on a phone in landscape', () {
      expect(
        TabBarPositionSetting.auto.resolve(landscapePhone),
        TabBarPosition.bottom,
      );
    });

    test('every explicit choice is returned untouched on every window', () {
      const explicit = {
        TabBarPositionSetting.top: TabBarPosition.top,
        TabBarPositionSetting.bottom: TabBarPosition.bottom,
        TabBarPositionSetting.left: TabBarPosition.left,
        TabBarPositionSetting.right: TabBarPosition.right,
      };

      for (final MapEntry(key: setting, value: expected) in explicit.entries) {
        for (final window in [phone, smallTablet, tablet, landscapePhone]) {
          expect(
            setting.resolve(window),
            expected,
            reason: '$setting must survive $window',
          );
        }
      }
    });

    test('every setting resolves to a concrete edge', () {
      // The whole reason the stored and resolved types are separate: nothing
      // downstream may ever be handed an unresolved choice and ask it which
      // way it points.
      for (final setting in TabBarPositionSetting.values) {
        for (final window in [phone, smallTablet, tablet, landscapePhone]) {
          expect(TabBarPosition.values, contains(setting.resolve(window)));
        }
      }
    });

    test('every setting has a label and a description', () {
      for (final setting in TabBarPositionSetting.values) {
        expect(setting.label, isNotEmpty);
        expect(setting.description, isNotEmpty);
      }
    });
  });

  group('persistence compatibility', () {
    // The field was retyped from TabBarPosition to TabBarPositionSetting in
    // place, keeping the same settings key and the same string values, so no
    // migration was needed. This pins that: a value written by a build that
    // predates the split must still load.
    test('values persisted before the split still decode', () {
      const persisted = {
        'top': TabBarPositionSetting.top,
        'bottom': TabBarPositionSetting.bottom,
        'left': TabBarPositionSetting.left,
        'right': TabBarPositionSetting.right,
      };

      for (final MapEntry(key: stored, value: expected) in persisted.entries) {
        expect(
          GeneralSettings.fromJson({'tabBarPosition': stored}).tabBarPosition,
          expected,
          reason: 'stored value "$stored"',
        );
      }
    });

    test('a missing value becomes auto, which is bottom on a phone', () {
      // An install that never touched the setting has no stored row. It gets
      // auto -- and auto is a bottom bar on a phone, so nothing moves for
      // anyone who is not on a large screen.
      final settings = GeneralSettings.fromJson(const {});

      expect(settings.tabBarPosition, TabBarPositionSetting.auto);
      expect(
        settings.effectiveTabBarPosition(window: phone),
        TabBarPosition.bottom,
      );
    });

    test('an unknown value from a newer build degrades to auto', () {
      // Settings sync can hand this build a document written by a newer one.
      // Without unknownEnumValue the generated decoder throws.
      expect(
        GeneralSettings.fromJson({
          'tabBarPosition': 'somethingFromTheFuture',
        }).tabBarPosition,
        TabBarPositionSetting.auto,
      );
    });
  });

  group('effectiveTabBarPosition', () {
    test('an explicit bottom bar stays put on a tablet', () {
      expect(
        settingsWith(
          position: TabBarPositionSetting.bottom,
        ).effectiveTabBarPosition(window: tablet),
        TabBarPosition.bottom,
        reason: 'a user who put the bar somewhere meant it',
      );
    });

    test('the default moves to the rail on a tablet', () {
      expect(
        settingsWith().effectiveTabBarPosition(window: phone),
        TabBarPosition.bottom,
      );
      expect(
        settingsWith().effectiveTabBarPosition(window: tablet),
        TabBarPosition.left,
      );
    });
  });

  group('effectiveTabBarStackingMode', () {
    test('twoLevel survives on a horizontal bar', () {
      expect(
        settingsWith(
          position: TabBarPositionSetting.bottom,
          stacking: TabBarStackingMode.twoLevel,
        ).effectiveTabBarStackingMode(window: phone),
        TabBarStackingMode.twoLevel,
      );
    });

    test('twoLevel degrades on a narrow rail', () {
      // 56dp of width has no room for two stacked chip lists.
      expect(
        settingsWith(
          position: TabBarPositionSetting.left,
          stacking: TabBarStackingMode.twoLevel,
        ).effectiveTabBarStackingMode(window: smallTablet),
        TabBarStackingMode.accordion,
      );
    });

    test('twoLevel survives on a rail wide enough to be a tab panel', () {
      // This is the behaviour change: the degradation is keyed on the rail
      // being narrow, not on it being vertical.
      expect(
        settingsWith(
          position: TabBarPositionSetting.left,
          stacking: TabBarStackingMode.twoLevel,
        ).effectiveTabBarStackingMode(window: tablet),
        TabBarStackingMode.twoLevel,
      );
    });

    test('twoLevel degrades in a short window whatever the position', () {
      // 56 + 54 + 48*2 = 206dp of chrome in a 390dp-tall window.
      expect(
        settingsWith(
          position: TabBarPositionSetting.bottom,
          stacking: TabBarStackingMode.twoLevel,
        ).effectiveTabBarStackingMode(window: landscapePhone),
        TabBarStackingMode.accordion,
      );
    });

    test('container modes still degrade when the container UI is off', () {
      for (final mode in const [
        TabBarStackingMode.containerTabs,
        TabBarStackingMode.accordion,
        TabBarStackingMode.twoLevel,
      ]) {
        expect(
          settingsWith(
            stacking: mode,
            showContainerUi: false,
          ).effectiveTabBarStackingMode(window: tablet),
          TabBarStackingMode.lastUsedTabs,
          reason: '$mode without container UI',
        );
      }
    });

    test('disabled is never resurrected by any window', () {
      for (final window in [phone, smallTablet, tablet, landscapePhone]) {
        expect(
          settingsWith(
            stacking: TabBarStackingMode.disabled,
          ).effectiveTabBarStackingMode(window: window),
          TabBarStackingMode.disabled,
          reason: 'window $window',
        );
      }
    });
  });
}
