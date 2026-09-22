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
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/resolved_toolbar_button.dart';

void main() {
  late List<String> events;

  setUp(() => events = []);

  Future<void> pumpButton(
    WidgetTester tester, {
    bool withOwnLongPress = true,
    String? tooltip,
    bool ignorePointer = false,
  }) {
    Widget button = IconButton(
      tooltip: tooltip,
      onPressed: () => events.add('tap'),
      onLongPress: withOwnLongPress ? () => events.add('own') : null,
      icon: const Icon(Icons.arrow_back),
    );
    if (ignorePointer) button = IgnorePointer(child: button);

    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ToolbarLongPressOverride(
              onLongPress: () => events.add('override'),
              child: button,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('beats the button\'s own long press', (tester) async {
    await pumpButton(tester);

    await tester.longPress(find.byType(IconButton));

    expect(events, ['override']);
  });

  testWidgets('beats a tooltip', (tester) async {
    await pumpButton(tester, withOwnLongPress: false, tooltip: 'Back');

    await tester.longPress(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(events, ['override']);
    expect(find.text('Back'), findsNothing);
  });

  testWidgets('leaves a tap to the button', (tester) async {
    await pumpButton(tester);

    await tester.tap(find.byType(IconButton));

    expect(events, ['tap']);
  });

  testWidgets('fires on a greyed-out button', (tester) async {
    await pumpButton(tester, ignorePointer: true);

    await tester.longPress(find.byType(IconButton));
    await tester.tap(find.byType(IconButton));

    expect(events, ['override']);
  });
}
