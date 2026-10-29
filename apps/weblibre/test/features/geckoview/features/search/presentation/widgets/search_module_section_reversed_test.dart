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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/module_surface_scope.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class _FixedOrder extends SearchModuleOrder {
  @override
  List<ModuleOrderEntry> build(ModuleSurface surface) => [
    ModuleOrderEntry(type: SearchModuleType.bookmarks, visible: true),
    ModuleOrderEntry(type: SearchModuleType.combinedHistory, visible: true),
  ];
}

Widget _section(String title, SearchModuleType type, {bool card = false}) {
  return SearchModuleSection(
    title: title,
    moduleType: type,
    totalCount: 2,
    card: card,
    contentSliverBuilder: ({required isCollapsed, required visibleCount}) => [
      if (!isCollapsed)
        SliverList.builder(
          itemCount: visibleCount,
          itemBuilder: (context, index) =>
              SizedBox(height: 40, child: Text('$title row $index')),
        ),
    ],
  );
}

void main() {
  Future<void> pumpSurface(
    WidgetTester tester, {
    required bool reversed,
    bool card = false,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchModuleOrderProvider(
            ModuleSurface.search,
          ).overrideWith(_FixedOrder.new),
          riverpodDatabaseStorageProvider.overrideWith(
            (ref) => Storage.inMemory(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ModuleSurfaceScope(
              surface: ModuleSurface.search,
              pinnedHeaderBackgroundColor: Colors.white,
              reversed: reversed,
              child: CustomScrollView(
                reverse: reversed,
                slivers: [
                  _section('first', SearchModuleType.bookmarks, card: card),
                  _section('second', SearchModuleType.combinedHistory),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double top(WidgetTester tester, String text) =>
      tester.getTopLeft(find.text(text)).dy;

  group('reversed surface', () {
    testWidgets('puts the first section and its best row at the bottom', (
      tester,
    ) async {
      await pumpSurface(tester, reversed: true);

      // The first module is the one next to a field below the list.
      expect(top(tester, 'first row 0'), greaterThan(top(tester, 'SECOND')));
      // Within a section the first row is the one nearest the field.
      expect(
        top(tester, 'first row 0'),
        greaterThan(top(tester, 'first row 1')),
      );
    });

    testWidgets('keeps each header above its own rows', (tester) async {
      await pumpSurface(tester, reversed: true);

      expect(top(tester, 'FIRST'), lessThan(top(tester, 'first row 1')));
      expect(top(tester, 'SECOND'), lessThan(top(tester, 'second row 1')));
      // ...and below the rows of the section above it.
      expect(top(tester, 'FIRST'), greaterThan(top(tester, 'second row 0')));
    });

    testWidgets('does not pin headers', (tester) async {
      await pumpSurface(tester, reversed: true);

      // A pinned sliver sticks to the leading edge, which here is the bottom.
      expect(find.byType(SliverPinnedHeader), findsNothing);
    });

    testWidgets('keeps a card header above its rows', (tester) async {
      await pumpSurface(tester, reversed: true, card: true);

      expect(top(tester, 'first'), lessThan(top(tester, 'first row 1')));
      expect(
        top(tester, 'first row 0'),
        greaterThan(top(tester, 'first row 1')),
      );
    });
  });

  testWidgets('a normal surface keeps the top-down layout and pinning', (
    tester,
  ) async {
    await pumpSurface(tester, reversed: false);

    expect(top(tester, 'FIRST'), lessThan(top(tester, 'first row 0')));
    expect(top(tester, 'first row 0'), lessThan(top(tester, 'first row 1')));
    expect(top(tester, 'first row 1'), lessThan(top(tester, 'SECOND')));
    expect(find.byType(SliverPinnedHeader), findsNWidgets(2));
  });
}
