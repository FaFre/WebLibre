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
import 'package:material_ui/material_ui.dart' as mui show ColorScheme;
import 'package:weblibre/core/design/dynamic_color_scheme.dart';

const _seed = Color(0xFF6750A4);

void main() {
  group('MaterialUiColorSchemeConversion', () {
    // Both libraries derive `fromSeed` from the same tonal algorithm, so a
    // faithful conversion of one must equal the other's output. ColorScheme's
    // `==` compares every role.
    for (final brightness in Brightness.values) {
      test('carries every role over for a ${brightness.name} seed scheme', () {
        final converted = mui.ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: brightness,
        ).toFlutterColorScheme();
        final expected = ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: brightness,
        );

        // The deprecated `surfaceVariant` is deliberately not carried over and
        // falls back to `surface`, so pin the expected side to that.
        // ignore: deprecated_member_use
        expect(converted, expected.copyWith(surfaceVariant: converted.surface));
      });
    }

    // `shadow` and `scrim` are both black in a seeded scheme, and `surfaceTint`
    // equals `primary`, so swapping them would go unnoticed above.
    test('keeps roles that seeded schemes leave indistinguishable apart', () {
      const shadow = Color(0xFFAA0000);
      const scrim = Color(0xFF00AA00);
      const surfaceTint = Color(0xFF0000AA);

      final converted = mui.ColorScheme.fromSeed(seedColor: _seed)
          .copyWith(shadow: shadow, scrim: scrim, surfaceTint: surfaceTint)
          .toFlutterColorScheme();

      expect(converted.shadow, shadow);
      expect(converted.scrim, scrim);
      expect(converted.surfaceTint, surfaceTint);
    });
  });
}
