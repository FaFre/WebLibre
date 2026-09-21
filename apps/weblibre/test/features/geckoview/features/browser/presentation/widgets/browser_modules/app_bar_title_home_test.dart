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
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/providers/site_settings_badge_provider.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/app_bar_title.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';

/// The address field on the browser home surface.
///
/// Home is drawn over the selected tab instead of being a tab of its own, so a
/// tab stays selected the whole time it shows. Addressing that tab anyway put
/// the covered page's URL in the pill of a screen that is not showing it, and
/// handed the same URL to the search screen as the text to edit (#623).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tab = TabState.$default(
    'tab',
  ).copyWith(url: Uri.parse('https://www.openstreetmap.org/about'));

  Future<void> pumpTitle(
    WidgetTester tester, {
    required bool showBrowserHome,
    required Widget title,
  }) {
    // The favicon beside the address reads the icon cache, which is the one
    // thing on this row that wants a real database.
    final db = UserDatabase(
      NativeDatabase.memory(setup: registerLexorankFunctions),
    );
    addTearDown(db.close);

    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDatabaseProvider.overrideWith((ref) => db),
          selectedTabStateProvider.overrideWithValue(tab),
          selectedTabTypeProvider.overrideWithValue(TabType.regular),
          generalSettingsWithDefaultsProvider.overrideWith(
            (ref) => GeneralSettings.withDefaults(),
          ),
          shouldShowBrowserHomeProvider.overrideWithValue(showBrowserHome),
          // The pill, not the tab bar, so the field stays a plain label: the
          // search tools it grows otherwise are platform-channel buttons.
          effectiveHomeSearchBarPlacementProvider.overrideWithValue(
            HomeSearchBarPlacement.top,
          ),
          isTabTunneledProvider.overrideWith(
            (ref, tabId) => Future.value(false),
          ),
          showSiteSettingsBadgeProvider.overrideWith(
            (ref) => Future.value(SiteSettingsBadgeState.hidden),
          ),
          sandboxSourceUriForTabProvider.overrideWith((ref, tabId) => null),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Center(child: SizedBox(width: 360, child: title)),
          ),
        ),
      ),
    );
  }

  for (final (name, title) in <(String, Widget)>[
    ('compact', const CompactAppBarTitle()),
    ('regular', const AppBarTitle()),
  ]) {
    group('the $name address field', () {
      testWidgets('shows the selected tab while that tab is on screen', (
        tester,
      ) async {
        await pumpTitle(tester, showBrowserHome: false, title: title);
        await tester.pump();

        expect(find.byType(UriBreadcrumb), findsOneWidget);
        expect(find.text('Search or enter URL'), findsNothing);
      });

      testWidgets('offers a search instead while home covers that tab', (
        tester,
      ) async {
        await pumpTitle(tester, showBrowserHome: true, title: title);
        await tester.pump();

        expect(
          find.byType(UriBreadcrumb),
          findsNothing,
          reason: 'the covered page is not what this screen is showing',
        );
        expect(find.text('Search or enter URL'), findsOneWidget);
      });
    });
  }

  group('the rail address field', () {
    testWidgets('shows the selected tab while that tab is on screen', (
      tester,
    ) async {
      await pumpTitle(
        tester,
        showBrowserHome: false,
        title: const SizedBox(
          width: 64,
          height: 400,
          child: RailAppBarTitle(quarterTurns: 3),
        ),
      );
      await tester.pump();

      expect(find.byType(UriBreadcrumb), findsOneWidget);
    });

    testWidgets('offers a search instead while home covers that tab', (
      tester,
    ) async {
      await pumpTitle(
        tester,
        showBrowserHome: true,
        title: const SizedBox(
          width: 64,
          height: 400,
          child: RailAppBarTitle(quarterTurns: 3),
        ),
      );
      await tester.pump();

      expect(find.byType(UriBreadcrumb), findsNothing);
    });
  });
}
