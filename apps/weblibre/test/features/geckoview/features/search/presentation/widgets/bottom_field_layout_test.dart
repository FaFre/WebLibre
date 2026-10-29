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
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/bottom_field_layout.dart';

void main() {
  Future<void> pumpLayout(WidgetTester tester, {required double height}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: height,
            child: BottomFieldLayout(
              body: ListView(
                children: const [SizedBox(height: 40, child: Text('row'))],
              ),
              footer: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 56, child: Text('clipboard')),
                  SizedBox(height: 56, child: Text('toolbar')),
                  SizedBox(height: 58, child: Text('field')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'a tall window gives the footer its height and the body the rest',
    (tester) async {
      await pumpLayout(tester, height: 500);

      expect(tester.takeException(), isNull);
      expect(tester.getBottomLeft(find.text('field')).dy, 500);
      expect(tester.getTopLeft(find.text('clipboard')).dy, 500 - 170);
      expect(tester.getSize(find.byType(ListView)).height, 500 - 170);
    },
  );

  testWidgets('a window too short for the footer keeps the field in view', (
    tester,
  ) async {
    // Split screen with the keyboard up: less room than the footer needs.
    await pumpLayout(tester, height: 100);

    // Overflowing would report an exception and push the field out of the
    // window, behind the keyboard.
    expect(tester.takeException(), isNull);
    final field = tester.getRect(find.text('field'));
    expect(field.bottom, 100);
    expect(field.top, greaterThanOrEqualTo(0));
    expect(tester.getSize(find.byType(ListView)).height, 0);
  });
}
