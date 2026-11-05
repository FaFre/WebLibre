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
import 'package:weblibre/features/settings/presentation/widgets/layout_part.dart';

void main() {
  const chipChain = [
    LayoutPart.tabChip,
    LayoutPart.quickTabSwitcher,
    LayoutPart.tabBar,
  ];

  group('nextLayoutPartSelection', () {
    test('the first tap selects the outermost part', () {
      expect(nextLayoutPartSelection(chipChain, null), LayoutPart.tabBar);
    });

    test('a tap inside the selected part goes one level deeper', () {
      expect(
        nextLayoutPartSelection(chipChain, LayoutPart.tabBar),
        LayoutPart.quickTabSwitcher,
      );
      expect(
        nextLayoutPartSelection(chipChain, LayoutPart.quickTabSwitcher),
        LayoutPart.tabChip,
      );
    });

    test('the innermost part stays selected', () {
      expect(
        nextLayoutPartSelection(chipChain, LayoutPart.tabChip),
        LayoutPart.tabChip,
      );
    });

    test('a tap on another part selects its outermost part', () {
      expect(
        nextLayoutPartSelection(const [
          LayoutPart.menu,
          LayoutPart.tabBar,
        ], LayoutPart.contextualToolbar),
        LayoutPart.tabBar,
      );
    });

    test('a tap on the page clears the selection', () {
      expect(nextLayoutPartSelection(const [], LayoutPart.tabBar), isNull);
    });
  });

  test('a part knows the parts around it', () {
    expect(LayoutPart.tabChip.path, [
      LayoutPart.tabBar,
      LayoutPart.quickTabSwitcher,
      LayoutPart.tabChip,
    ]);
  });

  group('layoutPartsNear', () {
    testWidgets('finds the nested parts under a point, innermost first', (
      tester,
    ) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              key: key,
              width: 200,
              height: 100,
              child: const PreviewPartRegion(
                part: LayoutPart.tabBar,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: PreviewPartRegion(
                    part: LayoutPart.quickTabSwitcher,
                    child: SizedBox(width: 100, height: 40),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final box = tester.renderObject<RenderBox>(find.byKey(key));
      expect(layoutPartsNear(box, const Offset(10, 10), slop: 0), [
        LayoutPart.quickTabSwitcher,
        LayoutPart.tabBar,
      ]);
      expect(layoutPartsNear(box, const Offset(150, 80), slop: 0), [
        LayoutPart.tabBar,
      ]);
    });

    testWidgets('reaches a small part within the slop', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              key: key,
              width: 200,
              height: 100,
              child: const Align(
                alignment: Alignment.topLeft,
                child: PreviewPartRegion(
                  part: LayoutPart.menu,
                  child: SizedBox(width: 10, height: 10),
                ),
              ),
            ),
          ),
        ),
      );

      final box = tester.renderObject<RenderBox>(find.byKey(key));
      expect(layoutPartsNear(box, const Offset(20, 5), slop: 0), isEmpty);
      expect(layoutPartsNear(box, const Offset(20, 5), slop: 24), [
        LayoutPart.menu,
      ]);
    });
  });
}
