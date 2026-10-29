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

/// Wide enough that an automatic tab bar becomes a side rail.
const expandedWindow = WindowSizeClass(
  width: WindowWidthClass.expanded,
  height: WindowHeightClass.medium,
);

void main() {
  group('effectiveSearchFieldPlacement', () {
    GeneralSettings settingsWith({
      SearchFieldPlacement? placement,
      required TabBarPositionSetting position,
    }) => GeneralSettings.withDefaults(
      searchFieldPlacement: placement,
      tabBarPosition: position,
    );

    test('defaults to following the tab bar', () {
      expect(
        GeneralSettings.withDefaults().searchFieldPlacement,
        SearchFieldPlacement.auto,
      );
    });

    test('follow puts the field at the bottom under a bottom tab bar', () {
      expect(
        settingsWith(
          position: TabBarPositionSetting.bottom,
        ).effectiveSearchFieldPlacement(window: WindowSizeClass.compact),
        SearchFieldPlacement.bottom,
      );
    });

    test('follow puts the field at the top for every other tab bar', () {
      for (final position in const [
        TabBarPositionSetting.top,
        TabBarPositionSetting.left,
        TabBarPositionSetting.right,
      ]) {
        expect(
          settingsWith(
            position: position,
          ).effectiveSearchFieldPlacement(window: WindowSizeClass.compact),
          SearchFieldPlacement.top,
          reason: 'tab bar at $position',
        );
      }
    });

    test('follow tracks an automatic tab bar onto the side rail', () {
      final settings = settingsWith(position: TabBarPositionSetting.auto);

      expect(
        settings.effectiveSearchFieldPlacement(window: WindowSizeClass.compact),
        SearchFieldPlacement.bottom,
      );
      expect(
        settings.effectiveSearchFieldPlacement(window: expandedWindow),
        SearchFieldPlacement.top,
      );
    });

    test('an explicit choice wins over the tab bar position', () {
      expect(
        settingsWith(
          placement: SearchFieldPlacement.top,
          position: TabBarPositionSetting.bottom,
        ).effectiveSearchFieldPlacement(window: WindowSizeClass.compact),
        SearchFieldPlacement.top,
      );
      expect(
        settingsWith(
          placement: SearchFieldPlacement.bottom,
          position: TabBarPositionSetting.left,
        ).effectiveSearchFieldPlacement(window: expandedWindow),
        SearchFieldPlacement.bottom,
      );
    });

    test('an unknown stored value falls back to following the tab bar', () {
      final json = GeneralSettings.withDefaults().toJson()
        ..['searchFieldPlacement'] = 'sideways';

      expect(
        GeneralSettings.fromJson(json).searchFieldPlacement,
        SearchFieldPlacement.auto,
      );
    });
  });
}
