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
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_toolbar.dart';

List<Widget> buttons(String prefix, int count) => [
  for (var i = 0; i < count; i++)
    IconButton(
      key: ValueKey('$prefix$i'),
      onPressed: () {},
      icon: const Icon(Icons.circle),
    ),
];

Future<void> pumpPanel(WidgetTester tester, Widget toolbar) {
  return tester.pumpWidget(
    MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 256, child: toolbar),
      ),
    ),
  );
}

void main() {
  testWidgets('every configured button stays fully visible', (tester) async {
    await pumpPanel(
      tester,
      ContextualToolbarView(
        wrap: true,
        buttons: buttons('contextual', 6),
        trailing: buttons('main', 2),
      ),
    );

    final keys = [
      for (var i = 0; i < 6; i++) 'contextual$i',
      for (var i = 0; i < 2; i++) 'main$i',
    ];
    final rows = <double>{};
    for (final key in keys) {
      final rect = tester.getRect(find.byKey(ValueKey(key)));
      expect(rect.left, greaterThanOrEqualTo(0), reason: key);
      expect(rect.right, lessThanOrEqualTo(256), reason: key);
      rows.add(rect.top);
    }

    // Eight 48dp buttons cannot share one 256dp row.
    expect(rows.length, greaterThan(1));
  });

  testWidgets('a button that centres itself does not claim a whole row', (
    tester,
  ) async {
    // The tab-count box centres its content in the width it is offered; in a
    // Wrap that was the full panel, pushing it and everything after it onto
    // rows of their own.
    await pumpPanel(
      tester,
      ContextualToolbarView(
        wrap: true,
        buttons: [
          ...buttons('contextual', 2),
          const Center(
            key: ValueKey('centred'),
            child: SizedBox(width: 48, height: 48),
          ),
        ],
        trailing: buttons('main', 1),
      ),
    );

    final centred = tester.getRect(find.byKey(const ValueKey('centred')));
    final first = tester.getRect(find.byKey(const ValueKey('contextual0')));
    final trailing = tester.getRect(find.byKey(const ValueKey('main0')));

    expect(centred.width, 48);
    expect(centred.top, first.top, reason: 'shares the first row');
    expect(trailing.top, first.top, reason: 'so does what follows it');
  });

  testWidgets('spaces a row evenly across the panel', (tester) async {
    await pumpPanel(
      tester,
      ContextualToolbarView(wrap: true, buttons: buttons('contextual', 3)),
    );

    final rects = [
      for (var i = 0; i < 3; i++)
        tester.getRect(find.byKey(ValueKey('contextual$i'))),
    ];
    final gaps = [
      rects[0].left,
      rects[1].left - rects[0].right,
      rects[2].left - rects[1].right,
      256 - rects[2].right,
    ];

    for (final gap in gaps) {
      expect(gap, moreOrLessEquals(gaps.first), reason: 'gaps: $gaps');
    }
    expect(gaps.first, greaterThan(0));
  });

  testWidgets('trailing buttons follow the contextual ones', (tester) async {
    await pumpPanel(
      tester,
      ContextualToolbarView(
        wrap: true,
        buttons: buttons('contextual', 2),
        trailing: buttons('main', 1),
      ),
    );

    expect(
      tester.getRect(find.byKey(const ValueKey('main0'))).left,
      greaterThan(
        tester.getRect(find.byKey(const ValueKey('contextual1'))).left,
      ),
    );
  });

  testWidgets('shows only trailing buttons when none are configured', (
    tester,
  ) async {
    await pumpPanel(
      tester,
      ContextualToolbarView(
        wrap: true,
        buttons: const [],
        trailing: buttons('main', 2),
      ),
    );

    expect(find.byType(IconButton), findsNWidgets(2));
  });

  testWidgets('renders nothing when there is nothing to show', (tester) async {
    await pumpPanel(
      tester,
      const ContextualToolbarView(wrap: true, buttons: []),
    );

    expect(find.byType(Wrap), findsNothing);
  });
}
