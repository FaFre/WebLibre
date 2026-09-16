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
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

/// A window wide and tall enough for the side rail to become a tab panel.
const expandedWindow = WindowSizeClass(
  width: WindowWidthClass.expanded,
  height: WindowHeightClass.medium,
);

/// A window wide enough for a rail but too narrow to widen it.
const mediumWindow = WindowSizeClass(
  width: WindowWidthClass.medium,
  height: WindowHeightClass.medium,
);

void main() {
  group('effectiveHomeSearchBarPlacement', () {
    GeneralSettings settingsWith({
      HomeSearchBarPlacement? placement,
      required TabBarPositionSetting position,
    }) => GeneralSettings.withDefaults(
      homeSearchBarPlacement: placement,
      tabBarPosition: position,
    );

    test('defaults to auto', () {
      expect(
        GeneralSettings.withDefaults().homeSearchBarPlacement,
        HomeSearchBarPlacement.auto,
      );
    });

    test('auto follows a bottom tab bar into the tab bar', () {
      expect(
        settingsWith(
          position: TabBarPositionSetting.bottom,
        ).effectiveHomeSearchBarPlacement(window: WindowSizeClass.compact),
        HomeSearchBarPlacement.tabBar,
      );
    });

    test('auto resolves to the pill for every other tab bar position', () {
      for (final position in const [
        TabBarPositionSetting.top,
        TabBarPositionSetting.left,
        TabBarPositionSetting.right,
      ]) {
        expect(
          settingsWith(
            position: position,
          ).effectiveHomeSearchBarPlacement(window: WindowSizeClass.compact),
          HomeSearchBarPlacement.top,
          reason: 'tab bar at $position',
        );
      }
    });

    test('an explicit choice wins over the tab bar position', () {
      expect(
        settingsWith(
          placement: HomeSearchBarPlacement.top,
          position: TabBarPositionSetting.bottom,
        ).effectiveHomeSearchBarPlacement(window: WindowSizeClass.compact),
        HomeSearchBarPlacement.top,
      );
      expect(
        settingsWith(
          placement: HomeSearchBarPlacement.tabBar,
          position: TabBarPositionSetting.top,
        ).effectiveHomeSearchBarPlacement(window: WindowSizeClass.compact),
        HomeSearchBarPlacement.tabBar,
      );
    });

    // The home surface has no address field of its own: the pill and the tab
    // bar's field are the only two entries into search, and exactly one of them
    // has to be present. A resolution that returned auto would leave callers
    // deciding for themselves, which is how both end up off.
    test('never resolves to auto', () {
      for (final placement in HomeSearchBarPlacement.values) {
        for (final position in TabBarPositionSetting.values) {
          for (final window in const [
            WindowSizeClass.compact,
            mediumWindow,
            expandedWindow,
          ]) {
            expect(
              settingsWith(
                placement: placement,
                position: position,
              ).effectiveHomeSearchBarPlacement(window: window),
              isNot(HomeSearchBarPlacement.auto),
              reason: '$placement at $position in $window',
            );
          }
        }
      }
    });

    // The placement resolves against the tab bar's *resolved* position, so an
    // auto tab bar that becomes a rail on a large screen has to move the
    // search entry to the pill -- the rail's address field is rotated 90
    // degrees and is a poor thing to hand someone as their only search entry.
    test('auto placement follows an auto tab bar onto the rail', () {
      final settings = settingsWith(position: TabBarPositionSetting.auto);

      expect(
        settings.effectiveHomeSearchBarPlacement(
          window: WindowSizeClass.compact,
        ),
        HomeSearchBarPlacement.tabBar,
        reason: 'auto is a bottom bar on a phone, which keeps the field',
      );
      expect(
        settings.effectiveHomeSearchBarPlacement(window: expandedWindow),
        HomeSearchBarPlacement.top,
        reason: 'auto is a rail on a tablet, so the pill takes over',
      );
    });
  });
}
