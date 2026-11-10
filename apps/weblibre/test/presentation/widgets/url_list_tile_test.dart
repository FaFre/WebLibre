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
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/presentation/widgets/url_list_tile.dart';

const _title = 'Example page';
const _containerColor = Color(0xFF2196F3);
const _width = 400.0;

void main() {
  Future<void> pumpTile(
    WidgetTester tester, {
    bool framed = true,
    bool selected = false,
    Color? containerColor,
  }) async {
    final theme = ThemeData();
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: _width,
              child: UrlListTile(
                title: _title,
                uri: Uri.parse('https://example.org/path'),
                // A stand-in favicon: the real one looks icons up through
                // providers this test does not need.
                leading: const SizedBox.square(dimension: UrlListTile.iconSize),
                containerColor: containerColor,
                framed: framed,
                selected: selected,
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container frame(WidgetTester tester) => tester.widget<Container>(
    // The closest Container around the ink is the tile's frame.
    find
        .ancestor(of: find.byType(InkWell), matching: find.byType(Container))
        .first,
  );

  BoxDecoration decoration(WidgetTester tester) =>
      frame(tester).decoration! as BoxDecoration;

  Rect tileRect(WidgetTester tester) =>
      tester.getRect(find.byType(UrlListTile));

  Rect inkRect(WidgetTester tester) => tester.getRect(find.byType(InkWell));

  bool announcedSelected(WidgetTester tester) => tester
      .widgetList<Semantics>(
        find.ancestor(of: find.text(_title), matching: find.byType(Semantics)),
      )
      .any((semantics) => semantics.properties.selected == true);

  group('framed (default)', () {
    testWidgets('is a card of its own: margin, rounded corners and the '
        "container's outline", (tester) async {
      await pumpTile(tester, containerColor: _containerColor);

      expect(
        frame(tester).margin,
        const EdgeInsets.symmetric(vertical: 3.0, horizontal: 4.0),
      );
      expect(decoration(tester).borderRadius, isNot(BorderRadius.zero));
      expect(decoration(tester).border, isNotNull);
    });

    testWidgets('outside a container it has no outline', (tester) async {
      await pumpTile(tester);

      expect(decoration(tester).border, isNull);
      expect(decoration(tester).color, isNull);
    });
  });

  group('unframed', () {
    testWidgets('fills its slot edge to edge, square, without an outline '
        "but with the container's surface", (tester) async {
      await pumpTile(tester, framed: false, containerColor: _containerColor);

      expect(inkRect(tester), tileRect(tester));
      expect(decoration(tester).borderRadius, BorderRadius.zero);
      expect(decoration(tester).border, isNull);
      expect(decoration(tester).color, isNotNull);
    });

    testWidgets("the container badge reaches the slot's right edge", (
      tester,
    ) async {
      await pumpTile(tester, framed: false, containerColor: _containerColor);

      final badge = tester.getRect(
        find
            .ancestor(of: find.byType(Icon), matching: find.byType(Container))
            .first,
      );
      final tile = tileRect(tester);
      expect(badge.right, tile.right);
      expect(badge.height, tile.height);
    });
  });

  group('selected', () {
    for (final framed in [true, false]) {
      final variant = framed ? 'framed' : 'unframed';

      testWidgets('is highlighted with surfaceContainerHighest ($variant)', (
        tester,
      ) async {
        await pumpTile(tester, framed: framed, selected: true);

        expect(
          decoration(tester).color,
          ThemeData().colorScheme.surfaceContainerHighest,
        );
        expect(announcedSelected(tester), isTrue);
      });

      testWidgets('in a container, is highlighted with the tinted step up '
          'from its surface ($variant)', (tester) async {
        await pumpTile(tester, framed: framed, containerColor: _containerColor);
        final unselected = decoration(tester).color;

        await pumpTile(
          tester,
          framed: framed,
          selected: true,
          containerColor: _containerColor,
        );

        final palette = ContainerColors.palette(
          tester.element(find.byType(UrlListTile)),
          _containerColor,
        );
        expect(unselected, palette.surfaceColor);
        expect(decoration(tester).color, palette.surfaceHighColor);
        expect(palette.surfaceHighColor, isNot(palette.surfaceColor));
        expect(announcedSelected(tester), isTrue);
      });
    }

    testWidgets('selecting does not move the content', (tester) async {
      await pumpTile(tester, framed: false);
      final before = tester.getRect(find.text(_title));

      await pumpTile(tester, framed: false, selected: true);

      expect(tester.getRect(find.text(_title)), before);
    });

    testWidgets('unselected rows have no highlight and do not claim a selected '
        'state', (tester) async {
      await pumpTile(tester, framed: false);

      expect(decoration(tester).color, isNull);
      expect(
        tester
            .widgetList<Semantics>(
              find.ancestor(
                of: find.text(_title),
                matching: find.byType(Semantics),
              ),
            )
            .map((semantics) => semantics.properties.selected),
        isNot(contains(false)),
      );
    });
  });
}
