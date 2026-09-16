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
import 'package:weblibre/presentation/widgets/reorderable_hold_drag.dart';

const _message = 'Clear the filter to reorder';

Future<TestGesture> pumpAndPress(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: HoldDragDisabledHint(
            message: _message,
            child: SizedBox(width: 100, height: 100, child: Text('tab')),
          ),
        ),
      ),
    ),
  );
  return tester.startGesture(tester.getCenter(find.text('tab')));
}

void main() {
  testWidgets('explains a hold-and-drag that cannot reorder', (tester) async {
    final gesture = await pumpAndPress(tester);
    await tester.pump(kItemLongPressDelay + const Duration(milliseconds: 50));
    await gesture.moveBy(const Offset(0, 40));
    await tester.pump();
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(_message), findsOneWidget);
  });

  testWidgets('says nothing for a plain long press', (tester) async {
    final gesture = await pumpAndPress(tester);
    await tester.pump(kItemLongPressDelay + const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(_message), findsNothing);
  });

  testWidgets('says nothing for a scroll that starts on the item', (
    tester,
  ) async {
    final gesture = await pumpAndPress(tester);
    await gesture.moveBy(const Offset(0, 40));
    await tester.pump(kItemLongPressDelay + const Duration(milliseconds: 50));
    await gesture.moveBy(const Offset(0, 40));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(_message), findsNothing);
  });

  testWidgets('explains once per gesture', (tester) async {
    final gesture = await pumpAndPress(tester);
    await tester.pump(kItemLongPressDelay + const Duration(milliseconds: 50));
    for (var i = 0; i < 5; i++) {
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
    }
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(_message), findsOneWidget);
  });
}
