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
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_reorder_semantics.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

const _tile = ValueKey('tile');

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  /// Pumps one tab at [index] and returns the indexes its actions moved it to.
  Future<List<int>> pumpTab(
    WidgetTester tester, {
    required int index,
    required int count,
    required int columns,
    TextDirection textDirection = TextDirection.ltr,
    bool canReorder = true,
  }) async {
    final moves = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Directionality(
          textDirection: textDirection,
          child: TabReorderSemantics(
            index: index,
            count: count,
            columns: columns,
            onMove: canReorder ? (newIndex) async => moves.add(newIndex) : null,
            child: const SizedBox(
              key: _tile,
              width: 100,
              height: 100,
              child: Text('tab'),
            ),
          ),
        ),
      ),
    );

    return moves;
  }

  List<String> actionLabels(WidgetTester tester) {
    final data = tester.getSemantics(find.byKey(_tile)).getSemanticsData();
    return [
      for (final id in data.customSemanticsActionIds ?? const <int>[])
        CustomSemanticsAction.getAction(id)!.label!,
    ];
  }

  void perform(WidgetTester tester, String label) {
    final node = tester.getSemantics(find.byKey(_tile));
    node.owner!.performAction(
      node.id,
      SemanticsAction.customAction,
      CustomSemanticsAction.getIdentifier(CustomSemanticsAction(label: label)),
    );
  }

  testWidgets('a list offers up and down within its rows', (tester) async {
    final semantics = tester.ensureSemantics();
    final moves = await pumpTab(tester, index: 0, count: 3, columns: 1);

    // The first row cannot move up.
    expect(actionLabels(tester), [l10n.browser_moveTabDown]);

    perform(tester, l10n.browser_moveTabDown);
    expect(moves, [1]);

    semantics.dispose();
  });

  testWidgets('a grid moves by rows and by places', (tester) async {
    final semantics = tester.ensureSemantics();
    final moves = await pumpTab(tester, index: 4, count: 8, columns: 3);

    expect(
      actionLabels(tester),
      unorderedEquals([
        l10n.browser_moveTabUp,
        l10n.browser_moveTabDown,
        l10n.browser_moveTabLeft,
        l10n.browser_moveTabRight,
      ]),
    );

    perform(tester, l10n.browser_moveTabUp);
    perform(tester, l10n.browser_moveTabDown);
    perform(tester, l10n.browser_moveTabLeft);
    perform(tester, l10n.browser_moveTabRight);
    expect(moves, [1, 7, 3, 5]);

    semantics.dispose();
  });

  testWidgets('left and right follow the reading direction', (tester) async {
    final semantics = tester.ensureSemantics();
    final moves = await pumpTab(
      tester,
      index: 4,
      count: 8,
      columns: 3,
      textDirection: TextDirection.rtl,
    );

    perform(tester, l10n.browser_moveTabLeft);
    perform(tester, l10n.browser_moveTabRight);
    expect(moves, [5, 3]);

    semantics.dispose();
  });

  testWidgets('a row past the last one is never offered', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpTab(tester, index: 6, count: 8, columns: 3);

    expect(actionLabels(tester), isNot(contains(l10n.browser_moveTabDown)));

    semantics.dispose();
  });

  testWidgets('no actions while the order cannot change', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpTab(tester, index: 1, count: 3, columns: 1, canReorder: false);

    expect(actionLabels(tester), isEmpty);

    semantics.dispose();
  });
}
