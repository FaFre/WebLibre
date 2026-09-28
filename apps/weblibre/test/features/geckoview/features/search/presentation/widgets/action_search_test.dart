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
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/browser_actions/domain/services/browser_action_dispatcher.dart';
import 'package:weblibre/features/browser_actions/domain/services/browser_action_search.dart';
import 'package:weblibre/features/browser_actions/presentation/utils/browser_action_l10n.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/module_surface_scope.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/action_search.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/features/web_feed/domain/providers.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class _DefaultOrder extends SearchModuleOrder {
  @override
  List<ModuleOrderEntry> build(ModuleSurface surface) =>
      mergeModuleOrderWithDefaults(null, surface.defaultModules);
}

class _NoProfiles extends ProfileRepository {
  @override
  Future<List<Profile>> build() async => const [];
}

final _work = ContainerDataWithCount(
  id: 'work',
  name: 'Work',
  color: Colors.blue,
  orderKey: 'a',
  tabCount: 2,
);

void main() {
  Future<void> pumpActions(
    WidgetTester tester, {
    required ModuleSurface surface,
    ValueNotifier<TextEditingValue>? query,
    void Function(ActionSearchItem item)? onItemSelected,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchModuleOrderProvider(surface).overrideWith(_DefaultOrder.new),
          riverpodDatabaseStorageProvider.overrideWith(
            (ref) => Storage.inMemory(),
          ),
          generalSettingsWithDefaultsProvider.overrideWith(
            (ref) => GeneralSettings.withDefaults(),
          ),
          engineSettingsWithDefaultsProvider.overrideWith(
            (ref) => EngineSettings.withDefaults(),
          ),
          watchContainersWithCountProvider.overrideWith(
            (ref) => Stream.value([_work]),
          ),
          profileRepositoryProvider.overrideWith(_NoProfiles.new),
          feedListProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ModuleSurfaceScope(
              surface: surface,
              pinnedHeaderBackgroundColor: null,
              child: CustomScrollView(
                slivers: [
                  ActionSearch(
                    searchTextListenable: query,
                    pageTabId: null,
                    onItemSelected: onItemSelected ?? (_) {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    // Lets the container stream deliver.
    await tester.pump();
  }

  // Without a tab only browser-wide actions can run; automatic font sizing is
  // on by default, which hides the manual font size actions.
  final browserWide = searchableBrowserActions
      .where((action) => !BrowserActionDispatcher.requiresTab(action))
      .where((action) => action != BrowserAction.resetFontSize)
      .toList();

  testWidgets('the new-tab page previews the full list and pages the rest', (
    tester,
  ) async {
    // Tall enough that the lazily built list lays out every row.
    tester.view.physicalSize = const Size(800, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpActions(tester, surface: ModuleSurface.newTab);

    expect(find.byType(ListTile), findsNWidgets(previewItemsPerModule));

    await tester.tap(find.text('Show all ${browserWide.length}'));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(browserWide.length));
    // The full list is actions only; containers and settings need a query.
    expect(find.text('Work'), findsNothing);
  });

  testWidgets('a search ranks the matching action first', (tester) async {
    final query = ValueNotifier(const TextEditingValue(text: 'settings'));
    addTearDown(query.dispose);

    await pumpActions(tester, surface: ModuleSurface.search, query: query);

    final firstRow = find.byType(ListTile).first;
    expect(
      find.descendant(of: firstRow, matching: find.text('Settings')),
      findsOneWidget,
    );
  });

  testWidgets('a search finds a container by name and switches to it', (
    tester,
  ) async {
    final query = ValueNotifier(const TextEditingValue(text: 'work'));
    addTearDown(query.dispose);
    final selected = <ActionSearchItem>[];

    await pumpActions(
      tester,
      surface: ModuleSurface.search,
      query: query,
      onItemSelected: selected.add,
    );

    await tester.tap(find.text('Work'));

    expect(selected.single, isA<ContainerSearchItem>());
    expect((selected.single as ContainerSearchItem).container.id, 'work');
  });

  testWidgets('a search finds a setting and says where it lives', (
    tester,
  ) async {
    final query = ValueNotifier(
      const TextEditingValue(text: 'suggest from history'),
    );
    addTearDown(query.dispose);
    final selected = <ActionSearchItem>[];

    await pumpActions(
      tester,
      surface: ModuleSurface.search,
      query: query,
      onItemSelected: selected.add,
    );

    expect(find.text('Suggest from history'), findsOneWidget);
    expect(find.textContaining('Settings › Search ›'), findsOneWidget);

    await tester.tap(find.text('Suggest from history'));

    final target = (selected.single as SettingSearchItem).target;
    expect(target.isCategory, isFalse);
    expect(target.title, 'Suggest from history');
  });

  testWidgets('a section synonym finds the settings in that section', (
    tester,
  ) async {
    // "on device search" is a keyword of the Local Search Index section, not
    // of any one setting in it.
    final query = ValueNotifier(
      const TextEditingValue(text: 'on device search'),
    );
    addTearDown(query.dispose);

    await pumpActions(tester, surface: ModuleSurface.search, query: query);

    expect(
      find.textContaining('› Local Search Index'),
      findsWidgets,
      reason: 'rows from the Local Search Index section should match',
    );
  });

  testWidgets('a synonym the action never shows still finds it', (
    tester,
  ) async {
    final query = ValueNotifier(const TextEditingValue(text: 'adblock'));
    addTearDown(query.dispose);

    await pumpActions(tester, surface: ModuleSurface.search, query: query);

    expect(find.text('Filter Lists'), findsOneWidget);
  });

  testWidgets('every offered action has search keywords', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox();
          },
        ),
      ),
    );

    for (final action in searchableBrowserActions) {
      expect(action.keywords(context), isNotEmpty, reason: action.name);
    }
    expect(BrowserAction.addToHomeScreen.keywords(context), contains('pwa'));
  });
}
