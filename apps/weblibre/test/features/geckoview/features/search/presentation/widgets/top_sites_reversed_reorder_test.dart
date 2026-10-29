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
import 'package:weblibre/domain/services/generic_website.dart';
import 'package:weblibre/features/geckoview/domain/entities/browser_icon.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/empty_state_content.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/top_sites_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/module_surface_scope.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/entities/top_site_item.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/entities/top_site_source.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/providers.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class _FixedOrder extends SearchModuleOrder {
  @override
  List<ModuleOrderEntry> build(ModuleSurface surface) => [
    ModuleOrderEntry(type: SearchModuleType.topSites, visible: true),
  ];
}

/// The tiles ask for favicons; none are needed to tell where a tile sits.
class _NoIcons extends GenericWebsiteService {
  @override
  void build() {}

  @override
  Future<BrowserIcon?> getUrlIcon(
    List<Uri> urlList, {
    bool cacheOnly = false,
  }) async => null;

  @override
  Future<void> refreshIconIfStale(Uri url) async {}
}

/// Six shortcuts — two rows of four in a phone-wide grid — and two
/// suggestions.
final _sites = [
  for (var i = 0; i < 6; i++)
    TopSiteItem(
      id: 'p$i',
      title: 'pinned $i',
      url: Uri.parse('about:pinned$i'),
      source: TopSiteSource.pinned,
    ),
  for (var i = 0; i < 2; i++)
    TopSiteItem(
      title: 'suggested $i',
      url: Uri.parse('about:suggested$i'),
      source: TopSiteSource.history,
    ),
];

void main() {
  Future<void> pumpSurface(WidgetTester tester, {required bool reversed}) {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchModuleOrderProvider(
            ModuleSurface.newTab,
          ).overrideWith(_FixedOrder.new),
          riverpodDatabaseStorageProvider.overrideWith(
            (ref) => Storage.inMemory(),
          ),
          topSiteListProvider(
            limit: searchEmptyTopSitesLimit,
          ).overrideWith((ref) => Stream.value(_sites)),
          genericWebsiteServiceProvider.overrideWith(_NoIcons.new),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ModuleSurfaceScope(
              surface: ModuleSurface.newTab,
              pinnedHeaderBackgroundColor: null,
              reversed: reversed,
              child: CustomScrollView(
                reverse: reversed,
                slivers: [TopSitesSection(onUriSelected: (_) {})],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Each tile's row, counted from the top of the screen. The two modes space
  /// their grids differently, so the tests compare rows rather than pixels.
  Map<String, int> rowsOf(WidgetTester tester) {
    final tops = {
      for (final site in _sites)
        site.title: tester.getTopLeft(find.text(site.title)).dy.roundToDouble(),
    };
    final rows = tops.values.toSet().toList()..sort();
    return tops.map((title, top) => MapEntry(title, rows.indexOf(top)));
  }

  Future<void> toggleReorder(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.swap_vert));
    await tester.pumpAndSettle();
  }

  for (final reversed in [false, true]) {
    testWidgets('reorder mode keeps every tile in its row '
        '(${reversed ? 'reversed' : 'normal'} surface)', (tester) async {
      await pumpSurface(tester, reversed: reversed);
      await tester.pumpAndSettle();

      final normal = rowsOf(tester);
      // The layout this guards: shortcuts nearest the field, suggestions
      // after them.
      final firstRow = reversed
          ? normal.values.reduce((a, b) => a > b ? a : b)
          : 0;
      expect(normal['pinned 0'], firstRow);
      expect(
        (normal['pinned 4']! - normal['pinned 0']!).sign,
        reversed ? -1 : 1,
      );

      await toggleReorder(tester);
      final arranging = rowsOf(tester);

      for (final site in _sites.where((s) => s.isPersisted)) {
        expect(
          (arranging[site.title]! - arranging['pinned 0']!).sign,
          (normal[site.title]! - normal['pinned 0']!).sign,
          reason: '${site.title} changed rows relative to pinned 0',
        );
      }
      // Suggestions stay on the far side of the shortcuts.
      expect(
        (arranging['suggested 0']! - arranging['pinned 0']!).sign,
        reversed ? -1 : 1,
      );

      await toggleReorder(tester);
      expect(rowsOf(tester), normal);
    });
  }
}
