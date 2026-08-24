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
import 'package:weblibre/features/user/data/models/general_settings.dart';

void main() {
  group('effectiveHomeSearchBarPlacement', () {
    GeneralSettings settingsWith({
      HomeSearchBarPlacement? placement,
      required TabBarPosition position,
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
          position: TabBarPosition.bottom,
        ).effectiveHomeSearchBarPlacement(),
        HomeSearchBarPlacement.tabBar,
      );
    });

    test('auto resolves to the pill for every other tab bar position', () {
      for (final position in const [
        TabBarPosition.top,
        TabBarPosition.left,
        TabBarPosition.right,
      ]) {
        expect(
          settingsWith(position: position).effectiveHomeSearchBarPlacement(),
          HomeSearchBarPlacement.top,
          reason: 'tab bar at $position',
        );
      }
    });

    test('an explicit choice wins over the tab bar position', () {
      expect(
        settingsWith(
          placement: HomeSearchBarPlacement.top,
          position: TabBarPosition.bottom,
        ).effectiveHomeSearchBarPlacement(),
        HomeSearchBarPlacement.top,
      );
      expect(
        settingsWith(
          placement: HomeSearchBarPlacement.tabBar,
          position: TabBarPosition.top,
        ).effectiveHomeSearchBarPlacement(),
        HomeSearchBarPlacement.tabBar,
      );
    });

    // The home surface has no address field of its own: the pill and the tab
    // bar's field are the only two entries into search, and exactly one of them
    // has to be present. A resolution that returned auto would leave callers
    // deciding for themselves, which is how both end up off.
    test('never resolves to auto', () {
      for (final placement in HomeSearchBarPlacement.values) {
        for (final position in TabBarPosition.values) {
          expect(
            settingsWith(
              placement: placement,
              position: position,
            ).effectiveHomeSearchBarPlacement(),
            isNot(HomeSearchBarPlacement.auto),
          );
        }
      }
    });
  });
}
