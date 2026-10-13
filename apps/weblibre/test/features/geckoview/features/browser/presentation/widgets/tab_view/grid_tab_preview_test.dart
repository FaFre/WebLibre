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
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_detail_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_preview.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

const _tabId = 'tab';
const _tileKey = ValueKey('tile');

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<List<String>> pumpTile(
    WidgetTester tester, {
    bool isActive = false,
  }) async {
    final calls = <String>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tabStateWithFallbackProvider(
            _tabId,
          ).overrideWith((ref) => Future.value(TabState.$default(_tabId))),
          tabThumbnailProvider(_tabId).overrideWithValue(null),
          sandboxSourceUriForTabProvider(tabId: _tabId).overrideWithValue(null),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                key: _tileKey,
                width: 160,
                height: 220,
                child: GridTabPreview(
                  tabId: _tabId,
                  isActive: isActive,
                  onTap: () => calls.add('open'),
                  onDelete: () => calls.add('close'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    return calls;
  }

  testWidgets('the close button takes a tap next to its icon', (tester) async {
    final calls = await pumpTile(tester);
    final tile = tester.getRect(find.byKey(_tileKey));

    // Outside the 28dp icon (6dp from the corner), inside the 48dp target.
    await tester.tapAt(tile.topRight + const Offset(-40, 40));
    await tester.pump();

    expect(calls, ['close']);
  });

  testWidgets('a tap well inside the tile still opens the tab', (tester) async {
    final calls = await pumpTile(tester);
    final tile = tester.getRect(find.byKey(_tileKey));

    await tester.tapAt(tile.topRight + const Offset(-60, 60));
    await tester.pump();

    expect(calls, ['open']);
  });

  testWidgets('screen readers hear what the button does and which tab is '
      'active', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpTile(tester, isActive: true);

    expect(
      tester.getSemantics(find.bySemanticsLabel(l10n.browser_tooltipCloseTab)),
      isSemantics(isButton: true, hasTapAction: true),
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.selected == true,
      ),
      findsOneWidget,
    );

    semantics.dispose();
  });
}
