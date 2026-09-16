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
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/quick_tab_switcher_chip.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

const _title = 'A page title long enough to need more than a chip';
const _avatarKey = ValueKey('avatar');

QuickTabSwitcherItem item({int depth = 0, bool isHistory = false}) =>
    QuickTabSwitcherItem(
      color: null,
      id: 'tab',
      isActive: true,
      tabMode: TabMode.regular,
      isHistory: isHistory,
      isPinned: false,
      title: _title,
      url: Uri.parse('https://example.org'),
      avatar: const SizedBox(key: _avatarKey),
      depth: depth,
    );

Future<void> pumpRow(
  WidgetTester tester, {
  double width = 300,
  int depth = 0,
  int hierarchyGlyphs = 3,
  bool showTitles = true,
  bool isHistory = false,
  VoidCallback? onTap,
  VoidCallback? onDelete,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: QuickTabSwitcherRow(
              item: item(depth: depth, isHistory: isHistory),
              isSelected: true,
              showIsolatedTabUi: false,
              showTitles: showTitles,
              hierarchyGlyphs: hierarchyGlyphs,
              onTap: onTap ?? () {},
              onDelete: onDelete,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('gives the title the width the panel has', (tester) async {
    await pumpRow(tester, width: 300);
    final narrow = tester.getSize(find.text(_title)).width;

    await pumpRow(tester, width: 460);
    final wide = tester.getSize(find.text(_title)).width;

    // The chip caps titles at a fixed width; a row must not.
    expect(narrow, greaterThan(defaultQuickTabSwitcherTitleWidth));
    expect(wide, greaterThan(narrow));
  });

  testWidgets('spans the panel width', (tester) async {
    await pumpRow(tester, width: 300);

    expect(tester.getSize(find.byType(QuickTabSwitcherRow)).width, 300);
  });

  testWidgets('hides the title when titles are switched off', (tester) async {
    await pumpRow(tester, showTitles: false, onDelete: () {});

    expect(find.text(_title), findsNothing);
    // Still a full-width row, with the close button at its far edge.
    expect(tester.getSize(find.byType(QuickTabSwitcherRow)).width, 300);
    expect(tester.getTopRight(find.byIcon(Icons.close)).dx, greaterThan(250));
  });

  testWidgets('a history suggestion keeps its title', (tester) async {
    await pumpRow(tester, showTitles: false, isHistory: true);

    expect(find.text(_title), findsOneWidget);
  });

  testWidgets('shows a close button only when it can close', (tester) async {
    await pumpRow(tester);
    expect(find.byIcon(Icons.close), findsNothing);

    await pumpRow(tester, onDelete: () {});
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('closing does not also select', (tester) async {
    var tapped = 0;
    var deleted = 0;
    await pumpRow(tester, onTap: () => tapped++, onDelete: () => deleted++);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(deleted, 1);
    expect(tapped, 0);
  });

  testWidgets('tapping the row selects it', (tester) async {
    var tapped = 0;
    await pumpRow(tester, onTap: () => tapped++);

    await tester.tap(find.text(_title));
    await tester.pumpAndSettle();

    expect(tapped, 1);
  });

  group('nesting', () {
    Future<double> avatarLeft(
      WidgetTester tester, {
      required int depth,
      int hierarchyGlyphs = 3,
    }) async {
      await pumpRow(tester, depth: depth, hierarchyGlyphs: hierarchyGlyphs);
      return tester.getTopLeft(find.byKey(_avatarKey)).dx;
    }

    testWidgets('indents by depth', (tester) async {
      final root = await avatarLeft(tester, depth: 0);
      final nested = await avatarLeft(tester, depth: 2);

      expect(nested - root, 2 * QuickTabSwitcherRow.indentPerLevel);
    });

    testWidgets('stops indenting at the configured depth', (tester) async {
      final capped = await avatarLeft(tester, depth: 3, hierarchyGlyphs: 1);
      final root = await avatarLeft(tester, depth: 0, hierarchyGlyphs: 1);

      expect(capped - root, QuickTabSwitcherRow.indentPerLevel);
    });

    testWidgets('does not indent when nesting is hidden', (tester) async {
      final root = await avatarLeft(tester, depth: 0, hierarchyGlyphs: 0);
      final nested = await avatarLeft(tester, depth: 3, hierarchyGlyphs: 0);

      expect(nested, root);
    });
  });
}
