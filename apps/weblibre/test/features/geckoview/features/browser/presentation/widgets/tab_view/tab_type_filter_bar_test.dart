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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/misc.dart' show Override;
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_view_filter_options.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_tray_new_tab_fab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_view_header.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// [TabViewFilterController] without persistence, starting at [initial].
class _TestTabViewFilterController extends TabViewFilterController {
  _TestTabViewFilterController(this.initial);

  final TabTypeFilter initial;

  @override
  TabViewFilterOptions build() =>
      TabViewFilterOptions.withDefaults().copyWith(tabTypeFilter: initial);
}

/// [TabsViewModeController] without persistence.
class _TestTabsViewModeController extends TabsViewModeController {
  _TestTabsViewModeController(this.initial);

  final TabsViewMode initial;

  @override
  TabsViewMode build() => initial;
}

/// [SelectedContainer] without persistence: no container selected.
class _TestSelectedContainer extends SelectedContainer {
  @override
  String? build() => null;
}

TabSortKeys _tab(TabMode mode) =>
    TabSortKeys(tabMode: mode, titleOrAuthority: 'tab', url: 'https://a.b');

List<Override> _overrides({
  required List<TabMode> openTabs,
  TabTypeFilter filter = TabTypeFilter.all,
  TabsViewMode viewMode = TabsViewMode.list,
  TabType? selectedTabType,
  TabsTrayScope scope = TabsTrayScope.local,
}) => [
  generalSettingsWithDefaultsProvider.overrideWith(
    (ref) => GeneralSettings.withDefaults().copyWith(
      // The container chips and the AI suggestions button want a database.
      showContainerUi: false,
      enableLocalAiFeatures: false,
    ),
  ),
  effectiveTabsTrayScopeProvider.overrideWith((ref) => scope),
  canManualTabReorderProvider.overrideWith((ref) => true),
  tabViewFilterControllerProvider.overrideWith(
    () => _TestTabViewFilterController(filter),
  ),
  tabsViewModeControllerProvider.overrideWith(
    () => _TestTabsViewModeController(viewMode),
  ),
  selectedContainerProvider.overrideWith(_TestSelectedContainer.new),
  selectedContainerDataProvider.overrideWith((ref) => Stream.value(null)),
  selectedTabTypeProvider.overrideWith((ref) => selectedTabType),
  tabSortKeysProvider.overrideWith(
    (ref) => EquatableValue({
      for (final (index, mode) in openTabs.indexed) 'tab$index': _tab(mode),
    }),
  ),
];

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<ProviderContainer> pumpHeader(
    WidgetTester tester, {
    required List<TabMode> openTabs,
    TabTypeFilter filter = TabTypeFilter.all,
  }) async {
    final scrolledUnder = ValueNotifier(false);
    addTearDown(scrolledUnder.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(openTabs: openTabs, filter: filter),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Material(
            child: TabViewHeader(
              onClose: () {},
              tabsViewMode: TabsViewMode.list,
              scrolledUnder: scrolledUnder,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    return ProviderScope.containerOf(
      tester.element(find.byType(TabViewHeader)),
    );
  }

  testWidgets('stays hidden while every open tab is of one kind', (
    tester,
  ) async {
    await pumpHeader(
      tester,
      openTabs: const [RegularTabMode(), RegularTabMode()],
    );

    expect(find.byType(ChoiceChip), findsNothing);
  });

  testWidgets('switches the kind of tab with one tap', (tester) async {
    final container = await pumpHeader(
      tester,
      openTabs: const [RegularTabMode(), PrivateTabMode()],
    );

    expect(find.byType(ChoiceChip), findsWidgets);

    await tester.tap(find.text(l10n.browser_tabTypeFilterPrivate));
    await tester.pump();

    expect(
      container.read(tabViewFilterControllerProvider).tabTypeFilter,
      TabTypeFilter.privateOnly,
    );
  });

  testWidgets('a filter in force is always on screen', (tester) async {
    await pumpHeader(
      tester,
      openTabs: const [RegularTabMode()],
      filter: TabTypeFilter.privateOnly,
    );

    final privateChip = tester.widget<ChoiceChip>(
      find.ancestor(
        of: find.text(l10n.browser_tabTypeFilterPrivate),
        matching: find.byType(ChoiceChip),
      ),
    );
    expect(privateChip.selected, isTrue);
  });

  group('trayNewTabType', () {
    Future<TabType> newTabType(
      WidgetTester tester, {
      required TabTypeFilter filter,
      TabsViewMode viewMode = TabsViewMode.list,
      TabType? selectedTabType = TabType.regular,
      TabsTrayScope scope = TabsTrayScope.local,
    }) async {
      late TabType result;

      await tester.pumpWidget(
        ProviderScope(
          // A fresh scope per call: overrides do not change on a live one.
          key: UniqueKey(),
          overrides: _overrides(
            openTabs: const [],
            filter: filter,
            viewMode: viewMode,
            selectedTabType: selectedTabType,
            scope: scope,
          ),
          child: Consumer(
            builder: (context, ref, _) {
              result = trayNewTabType(ref);
              return const SizedBox();
            },
          ),
        ),
      );

      return result;
    }

    testWidgets('opens the kind of tab the tray lists', (tester) async {
      expect(
        await newTabType(tester, filter: TabTypeFilter.privateOnly),
        TabType.private,
      );
      expect(
        await newTabType(tester, filter: TabTypeFilter.isolatedOnly),
        TabType.isolated,
      );
    });

    testWidgets('follows the selected tab without a filter', (tester) async {
      expect(
        await newTabType(
          tester,
          filter: TabTypeFilter.all,
          selectedTabType: TabType.private,
        ),
        TabType.private,
      );
    });

    testWidgets('ignores the filter in the tree view, which ignores it too', (
      tester,
    ) async {
      expect(
        await newTabType(
          tester,
          filter: TabTypeFilter.privateOnly,
          viewMode: TabsViewMode.tree,
        ),
        TabType.regular,
      );
    });

    testWidgets('ignores the filter for synced tabs, which hide it', (
      tester,
    ) async {
      expect(
        await newTabType(
          tester,
          filter: TabTypeFilter.privateOnly,
          scope: TabsTrayScope.synced,
        ),
        TabType.regular,
      );
    });
  });
}
