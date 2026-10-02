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
  group('QuickTabSwitcherPlacement.resolve', () {
    test('auto keeps the layout that predates the setting', () {
      expect(QuickTabSwitcherPlacement.auto.resolve(TabBarPosition.bottom), (
        inTopBar: false,
        order: QuickTabSwitcherOrder.beforeAddressBar,
      ));
      // Top tab bar: the switcher stays in the bottom bar, above the
      // contextual toolbar.
      expect(QuickTabSwitcherPlacement.auto.resolve(TabBarPosition.top), (
        inTopBar: false,
        order: QuickTabSwitcherOrder.beforeAddressBar,
      ));
    });

    test('address bar placements follow a top address bar', () {
      expect(
        QuickTabSwitcherPlacement.aboveAddressBar.resolve(TabBarPosition.top),
        (inTopBar: true, order: QuickTabSwitcherOrder.beforeAddressBar),
      );
      expect(
        QuickTabSwitcherPlacement.belowAddressBar.resolve(TabBarPosition.top),
        (inTopBar: true, order: QuickTabSwitcherOrder.afterAddressBar),
      );
    });

    test('a bottom address bar shares one bar with everything', () {
      expect(
        QuickTabSwitcherPlacement.aboveAddressBar.resolve(
          TabBarPosition.bottom,
        ),
        (inTopBar: false, order: QuickTabSwitcherOrder.beforeAddressBar),
      );
      expect(
        QuickTabSwitcherPlacement.belowAddressBar.resolve(
          TabBarPosition.bottom,
        ),
        (inTopBar: false, order: QuickTabSwitcherOrder.afterAddressBar),
      );
    });

    test('below the contextual toolbar is the bottom edge either way', () {
      for (final position in [TabBarPosition.top, TabBarPosition.bottom]) {
        expect(QuickTabSwitcherPlacement.belowContextualBar.resolve(position), (
          inTopBar: false,
          order: QuickTabSwitcherOrder.afterContextualBar,
        ));
      }
    });
  });

  test('a stored placement survives a JSON round trip', () {
    final settings = GeneralSettings.withDefaults().copyWith(
      quickTabSwitcherPlacement: QuickTabSwitcherPlacement.belowContextualBar,
    );
    final restored = GeneralSettings.fromJson(settings.toJson());

    expect(
      restored.quickTabSwitcherPlacement,
      QuickTabSwitcherPlacement.belowContextualBar,
    );
  });
}
