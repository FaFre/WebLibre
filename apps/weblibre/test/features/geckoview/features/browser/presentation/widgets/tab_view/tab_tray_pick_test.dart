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
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_detail_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_pick_request.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_view_filter_options.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_picker_rows.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_tray_rows.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_list_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_tray_pick.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// [TabViewFilterController] without persistence.
class _TestTabViewFilterController extends TabViewFilterController {
  @override
  TabViewFilterOptions build() => TabViewFilterOptions.withDefaults();
}

/// [SelectedContainer] without persistence: no container selected.
class _TestSelectedContainer extends SelectedContainer {
  @override
  String? build() => null;
}

/// The open tabs: per container, in order, with their kind.
final _modes = <String, TabMode>{
  'a': TabMode.regular,
  'b': TabMode.regular,
  'i': TabMode.isolated('ctx'),
  'p': TabMode.private,
  'w': TabMode.regular,
};
const _containers = <String?, List<String>>{
  null: ['a', 'b', 'i', 'p'],
  'work': ['w'],
};

String _title(String tabId) => 'Tab $tabId';

final _work = ContainerDataWithCount(
  id: 'work',
  name: 'Work',
  color: Colors.blue,
  orderKey: 'a',
  tabCount: 1,
);

void main() {
  group('tabPickerOffers', () {
    test('only the kind asked for, and of the given privacy', () {
      bool offers(TabMode mode, TabTypeFilter filter, {bool private = false}) =>
          tabPickerOffers(mode, privateTabs: private, typeFilter: filter);

      expect(offers(TabMode.regular, TabTypeFilter.all), isTrue);
      expect(offers(TabMode.isolated('x'), TabTypeFilter.all), isTrue);
      expect(offers(TabMode.private, TabTypeFilter.all), isFalse);
      expect(offers(TabMode.regular, TabTypeFilter.isolatedOnly), isFalse);
      expect(offers(TabMode.private, TabTypeFilter.all, private: true), isTrue);
      expect(
        offers(TabMode.regular, TabTypeFilter.all, private: true),
        isFalse,
      );
      expect(
        tabPickerOffers(
          null,
          privateTabs: false,
          typeFilter: TabTypeFilter.all,
        ),
        isFalse,
      );
    });
  });

  group('the tab tray as a picker', () {
    late List<String> picked;
    late int newTabs;
    late ProviderContainer container;

    Future<void> pumpPicker(WidgetTester tester) async {
      picked = [];
      newTabs = 0;
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(800, 900);
      addTearDown(tester.view.reset);

      container = ProviderContainer(
        overrides: [
          generalSettingsWithDefaultsProvider.overrideWith(
            (ref) => GeneralSettings.withDefaults().copyWith(
              enableLocalAiFeatures: false,
            ),
          ),
          effectiveTabsTrayScopeProvider.overrideWith(
            // Left on synced by the last tray: the picker lists local tabs
            // all the same.
            (ref) => TabsTrayScope.synced,
          ),
          tabViewFilterControllerProvider.overrideWith(
            _TestTabViewFilterController.new,
          ),
          selectedContainerProvider.overrideWith(_TestSelectedContainer.new),
          selectedContainerDataProvider.overrideWith(
            (ref) => Stream.value(null),
          ),
          matchSortedContainersWithCountProvider.overrideWith(
            (ref, searchText) => AsyncData([_work]),
          ),
          // The Unassigned chip's count.
          unassignedTabCountProvider.overrideWith((ref, args) => 4),
          syncIsAuthenticatedProvider.overrideWith((ref) => false),
          syncedTabsTotalCountProvider.overrideWith((ref) => Future.value(0)),
          tabTraySearchActiveProvider.overrideWith((ref) => false),
          tabSortKeysProvider.overrideWith(
            (ref) => EquatableValue({
              for (final MapEntry(:key, :value) in _modes.entries)
                key: TabSortKeys(
                  tabMode: value,
                  titleOrAuthority: _title(key),
                  url: '',
                ),
            }),
          ),
          visibleTabListItemsProvider.overrideWith(
            (ref, args) => EquatableValue([
              for (final tabId
                  in _containers[args.containerId] ?? const <String>[])
                TabListStandaloneItem(
                  tabId: tabId,
                  orderKey: tabId,
                  containerId: args.containerId,
                ),
            ]),
          ),
          tabStateWithFallbackProvider.overrideWith(
            (ref, tabId) => Future.value(
              TabState.$default(tabId).copyWith(title: _title(tabId)),
            ),
          ),
          tabThumbnailProvider.overrideWith((ref, tabId) => null),
          sandboxSourceUriForTabProvider.overrideWith((ref, tabId) => null),
        ],
      );
      addTearDown(container.dispose);

      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Material(
              child: TabTrayPickScope(
                request: TabPickRequest(
                  title: 'Pick a page',
                  privateTabs: false,
                  excludedTabIds: const {'a'},
                  initialContainer: null,
                  onPicked: picked.add,
                  onNewTab: () => newTabs++,
                ),
                child: ViewTabListWidget(
                  scrollController: scrollController,
                  tabsReorderable: false,
                  showNewTabFab: true,
                  onClose: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('lists the tabs it offers under its title, and a tap picks '
        'one', (tester) async {
      await pumpPicker(tester);

      expect(find.text('Pick a page'), findsOneWidget);
      // Not the excluded tab, nor a private one beside regular tabs.
      expect(find.text(_title('a')), findsNothing);
      expect(find.text(_title('p')), findsNothing);
      expect(find.text(_title('b')), findsOneWidget);
      expect(find.text(_title('i')), findsOneWidget);

      await tester.tap(find.text(_title('b')));
      await tester.pump();
      expect(picked, ['b']);
    });

    testWidgets("its type filter is its own: the tray's saved filter stays", (
      tester,
    ) async {
      await pumpPicker(tester);

      final l10n = lookupAppLocalizations(const Locale('en'));
      // No private chip: private tabs cannot be picked here.
      expect(
        find.widgetWithText(ChoiceChip, l10n.browser_tabTypeFilterPrivate),
        findsNothing,
      );
      await tester.tap(
        find.widgetWithText(ChoiceChip, l10n.browser_tabTypeFilterIsolated),
      );
      await tester.pumpAndSettle();

      expect(find.text(_title('b')), findsNothing);
      expect(find.text(_title('i')), findsOneWidget);
      expect(
        container.read(tabViewFilterControllerProvider).tabTypeFilter,
        TabTypeFilter.all,
      );
    });

    testWidgets("its container is its own: the browser's container stays", (
      tester,
    ) async {
      await pumpPicker(tester);

      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();

      expect(find.text(_title('w')), findsOneWidget);
      expect(find.text(_title('b')), findsNothing);
      expect(container.read(selectedContainerProvider), isNull);
    });

    testWidgets('the new-tab button asks the request for a new tab', (
      tester,
    ) async {
      await pumpPicker(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(newTabs, 1);
      expect(picked, isEmpty);
    });
  });
}
