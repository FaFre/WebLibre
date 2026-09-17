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
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/user/data/providers.dart';

void main() {
  group('display state storage', () {
    test('round-trips through the persisted name', () {
      for (final state in SearchModuleDisplayState.values) {
        expect(parseSearchModuleDisplayState(state.name), state);
      }
    });

    test('an unknown persisted state falls back to the default', () {
      expect(
        parseSearchModuleDisplayState('aStateThatWasRemoved'),
        SearchModuleDisplayState.preview,
      );
      expect(
        parseSearchModuleDisplayState(null),
        SearchModuleDisplayState.preview,
      );
    });

    test('surface and module both key the storage', () {
      final home = searchModuleDisplayStateKey(
        ModuleSurface.home,
        SearchModuleType.topSites,
      );

      expect(
        home,
        isNot(
          searchModuleDisplayStateKey(
            ModuleSurface.newTab,
            SearchModuleType.topSites,
          ),
        ),
        reason: 'the same module on two surfaces is configured separately',
      );
      expect(
        home,
        isNot(
          searchModuleDisplayStateKey(
            ModuleSurface.home,
            SearchModuleType.recentTabs,
          ),
        ),
      );
      expect(
        home,
        startsWith(ModuleSurface.home.key),
        reason: "the surface's shipped storage key must stay the prefix",
      );
    });
  });

  group('SearchModuleDisplayStateController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          riverpodDatabaseStorageProvider.overrideWith(
            (ref) => Storage.inMemory(),
          ),
        ],
      );
      addTearDown(container.dispose);
    });

    SearchModuleDisplayStateController controllerFor(
      SearchModuleType module, {
      ModuleSurface surface = ModuleSurface.home,
    }) => container.read(
      searchModuleDisplayStateControllerProvider(surface, module).notifier,
    );

    SearchModuleDisplayState stateOf(
      SearchModuleType module, {
      ModuleSurface surface = ModuleSurface.home,
    }) => container.read(
      searchModuleDisplayStateControllerProvider(surface, module),
    );

    test('starts in preview', () {
      expect(
        stateOf(SearchModuleType.topSites),
        SearchModuleDisplayState.preview,
      );
    });

    test('expanding one surface leaves the other alone', () {
      controllerFor(SearchModuleType.topSites).toggleExpansion();

      expect(
        stateOf(SearchModuleType.topSites),
        SearchModuleDisplayState.expanded,
      );
      expect(
        stateOf(SearchModuleType.topSites, surface: ModuleSurface.newTab),
        SearchModuleDisplayState.preview,
      );
    });

    test('an expanded module comes back expanded on the next run', () async {
      // The point of the feature: one shared storage, two containers standing
      // in for two app runs.
      final Storage<String, String> storage = Storage.inMemory();
      final overrides = [
        riverpodDatabaseStorageProvider.overrideWith((ref) => storage),
      ];

      final firstRun = ProviderContainer(overrides: overrides);
      firstRun
          .read(
            searchModuleDisplayStateControllerProvider(
              ModuleSurface.home,
              SearchModuleType.topSites,
            ).notifier,
          )
          .toggleExpansion();
      await pumpEventQueue();
      firstRun.dispose();

      final secondRun = ProviderContainer(overrides: overrides);
      addTearDown(secondRun.dispose);

      final provider = searchModuleDisplayStateControllerProvider(
        ModuleSurface.home,
        SearchModuleType.topSites,
      );
      // Reading starts the decode; it lands a turn or two later.
      secondRun.read(provider);
      await pumpEventQueue();

      expect(secondRun.read(provider), SearchModuleDisplayState.expanded);
    });

    test('the search screen keeps its two surfaces apart', () async {
      // The search screen is newTab before anything is typed and search after,
      // so the same section can be expanded in one state and not the other.
      final Storage<String, String> storage = Storage.inMemory();
      final overrides = [
        riverpodDatabaseStorageProvider.overrideWith((ref) => storage),
      ];

      final firstRun = ProviderContainer(overrides: overrides);
      firstRun
          .read(
            searchModuleDisplayStateControllerProvider(
              ModuleSurface.search,
              SearchModuleType.combinedHistory,
            ).notifier,
          )
          .toggleExpansion();
      await pumpEventQueue();
      firstRun.dispose();

      final secondRun = ProviderContainer(overrides: overrides);
      addTearDown(secondRun.dispose);

      final typed = searchModuleDisplayStateControllerProvider(
        ModuleSurface.search,
        SearchModuleType.combinedHistory,
      );
      final untyped = searchModuleDisplayStateControllerProvider(
        ModuleSurface.newTab,
        SearchModuleType.topSites,
      );
      secondRun
        ..read(typed)
        ..read(untyped);
      await pumpEventQueue();

      expect(secondRun.read(typed), SearchModuleDisplayState.expanded);
      expect(secondRun.read(untyped), SearchModuleDisplayState.preview);
    });

    test('resetting to defaults puts every module on the surface back', () {
      controllerFor(SearchModuleType.topSites).toggleExpansion();
      controllerFor(SearchModuleType.recentTabs).toggleCollapse();
      controllerFor(
        SearchModuleType.topSites,
        surface: ModuleSurface.newTab,
      ).toggleExpansion();

      container
          .read(searchModuleOrderProvider(ModuleSurface.home).notifier)
          .resetToDefaults();

      expect(
        stateOf(SearchModuleType.topSites),
        SearchModuleDisplayState.preview,
      );
      expect(
        stateOf(SearchModuleType.recentTabs),
        SearchModuleDisplayState.preview,
      );
      expect(
        stateOf(SearchModuleType.topSites, surface: ModuleSurface.newTab),
        SearchModuleDisplayState.expanded,
        reason: 'resetting one surface must not reset another',
      );
    });
  });
}
