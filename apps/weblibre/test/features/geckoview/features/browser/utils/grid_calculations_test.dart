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
import 'package:weblibre/features/geckoview/features/browser/utils/grid_calculations.dart';

int columnsFor(double width) => calculateCrossAxisItemCount(
  screenWidth: width,
  horizontalPadding: 4.0,
  crossAxisSpacing: 8.0,
);

void main() {
  group('calculateCrossAxisItemCount', () {
    test('packs columns at roughly 180dp each', () {
      expect(columnsFor(412), 2, reason: 'phone portrait');
      expect(columnsFor(600), 3);
      expect(columnsFor(840), 4);
    });

    test('never returns zero columns', () {
      // A width-capped sheet on a narrow window, or a tray beside a rail, can
      // hand this less than one tile's worth. A zero column count makes the
      // grid delegate throw.
      for (final width in [0.0, 1.0, 50.0, 100.0, 179.0]) {
        expect(
          columnsFor(width),
          greaterThanOrEqualTo(1),
          reason: 'width $width',
        );
      }
    });

    test('stops adding columns on very wide windows', () {
      // Unclamped, 1800dp would pack ten columns and a "preview" would be a
      // tenth of a desktop window wide.
      expect(columnsFor(1800), lessThanOrEqualTo(6));
      expect(columnsFor(4000), lessThanOrEqualTo(6));
    });

    test('is monotonic in width', () {
      var previous = 0;
      for (var width = 100.0; width <= 2400; width += 20) {
        final columns = columnsFor(width);
        expect(
          columns,
          greaterThanOrEqualTo(previous),
          reason: 'columns shrank going from a narrower window to $width',
        );
        previous = columns;
      }
    });

    test('a rail-inset tray gets fewer columns than the whole window', () {
      // The bug this guards: the call sites used to pass the *window* width,
      // so a tray inside a capped sheet beside a 256dp rail counted columns it
      // did not have room for.
      const window = 1280.0;
      const trayWidth = 640.0 - 256.0;

      expect(columnsFor(trayWidth), lessThan(columnsFor(window)));
    });
  });

  group('calculateItemSize', () {
    test('divides the available width evenly between columns', () {
      final size = calculateItemSize(
        screenWidth: 800,
        childAspectRatio: 0.75,
        horizontalPadding: 4.0,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        crossAxisCount: 4,
      );

      // 800 - 8 padding - 24 spacing = 768, over 4 columns.
      expect(size.width, 192);
      expect(size.height, 192 / 0.75 + 8);
    });
  });

  group('centeringInset', () {
    test('is zero while the content still fits', () {
      expect(centeringInset(400, maxWidth: ContentWidth.list), 0);
      expect(centeringInset(720, maxWidth: ContentWidth.list), 0);
    });

    test('centres the content once the window is wider', () {
      expect(centeringInset(1120, maxWidth: ContentWidth.list), 200);
    });

    test('leaves every compact window untouched at the list width', () {
      // The settings scaffolds centre against ContentWidth.list, and callers
      // add this to the padding they already had. A non-zero value anywhere
      // below the medium breakpoint would silently re-pad every settings
      // screen on a phone.
      for (final width in [320.0, 360.0, 412.0, 480.0, 599.0]) {
        expect(
          centeringInset(width, maxWidth: ContentWidth.list),
          0,
          reason: 'width $width',
        );
      }
    });

    test('starts insetting form content before list content', () {
      // Forms are capped narrower than lists, so a window can be wide enough
      // to centre a form while a list still fills it.
      expect(centeringInset(599, maxWidth: ContentWidth.form), greaterThan(0));
      expect(centeringInset(599, maxWidth: ContentWidth.list), 0);
    });
  });
}
