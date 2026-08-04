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
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';

ModuleOrderEntry _entry(SearchModuleType type, {bool visible = true}) =>
    ModuleOrderEntry(type: type, visible: visible);

List<SearchModuleType> _types(List<ModuleOrderEntry> entries) =>
    entries.map((e) => e.type).toList();

void main() {
  group('mergeModuleOrderWithDefaults', () {
    test('uses the defaults verbatim when nothing is persisted', () {
      const defaults = <ModuleSurfaceDefault>[
        (type: SearchModuleType.recentSearches, visible: true),
        (type: SearchModuleType.topSites, visible: true),
      ];

      final merged = mergeModuleOrderWithDefaults(null, defaults);

      expect(_types(merged), defaults.map((d) => d.type).toList());
      expect(merged.every((e) => e.visible), isTrue);
    });

    test('preserves a reordered persisted list', () {
      const defaults = <ModuleSurfaceDefault>[
        (type: SearchModuleType.recentSearches, visible: true),
        (type: SearchModuleType.frequentBangs, visible: true),
        (type: SearchModuleType.topSites, visible: true),
      ];
      final persisted = [
        _entry(SearchModuleType.topSites),
        _entry(SearchModuleType.recentSearches),
        _entry(SearchModuleType.frequentBangs),
      ];

      final merged = mergeModuleOrderWithDefaults(persisted, defaults);

      expect(_types(merged), _types(persisted));
    });

    test('preserves persisted visibility', () {
      const defaults = <ModuleSurfaceDefault>[
        (type: SearchModuleType.recentSearches, visible: true),
        (type: SearchModuleType.topSites, visible: true),
      ];
      final persisted = [
        _entry(SearchModuleType.recentSearches, visible: false),
        _entry(SearchModuleType.topSites),
      ];

      final merged = mergeModuleOrderWithDefaults(persisted, defaults);

      expect(merged[0].visible, isFalse);
      expect(merged[1].visible, isTrue);
    });

    test('drops persisted modules that are no longer offered', () {
      const defaults = <ModuleSurfaceDefault>[
        (type: SearchModuleType.topSites, visible: true),
      ];
      final persisted = [
        _entry(SearchModuleType.recentSearches),
        _entry(SearchModuleType.topSites),
      ];

      final merged = mergeModuleOrderWithDefaults(persisted, defaults);

      expect(_types(merged), [SearchModuleType.topSites]);
    });

    test('inserts a new default at its position, not at the tail', () {
      const defaults = <ModuleSurfaceDefault>[
        (type: SearchModuleType.recentSearches, visible: true),
        (
          type: SearchModuleType.frequentBangs,
          visible: true,
        ), // newly introduced, in the middle
        (type: SearchModuleType.topSites, visible: true),
      ];
      final persisted = [
        _entry(SearchModuleType.recentSearches),
        _entry(SearchModuleType.topSites),
      ];

      final merged = mergeModuleOrderWithDefaults(persisted, defaults);

      expect(_types(merged), [
        SearchModuleType.recentSearches,
        SearchModuleType.frequentBangs,
        SearchModuleType.topSites,
      ]);
    });

    test('a new default keeps its own visibility instead of forcing on', () {
      // This is what lets a module be offered on a surface without switching it
      // on for everyone who already customised that surface.
      const defaults = <ModuleSurfaceDefault>[
        (type: SearchModuleType.topSites, visible: true),
        (type: SearchModuleType.quote, visible: false),
      ];
      final persisted = [_entry(SearchModuleType.topSites)];

      final merged = mergeModuleOrderWithDefaults(persisted, defaults);

      expect(
        merged.firstWhere((e) => e.type == SearchModuleType.quote).visible,
        isFalse,
      );
    });

    test('clamps the insert position when the persisted list is shorter', () {
      const defaults = <ModuleSurfaceDefault>[
        (type: SearchModuleType.recentSearches, visible: true),
        (type: SearchModuleType.frequentBangs, visible: true),
        (type: SearchModuleType.topSites, visible: true),
        (
          type: SearchModuleType.containers,
          visible: true,
        ), // index 3, beyond the persisted length
      ];
      final persisted = [_entry(SearchModuleType.recentSearches)];

      final merged = mergeModuleOrderWithDefaults(persisted, defaults);

      expect(
        merged.map((e) => e.type).toSet(),
        defaults.map((d) => d.type).toSet(),
      );
      expect(merged, hasLength(defaults.length));
    });

    test('is idempotent', () {
      const defaults = <ModuleSurfaceDefault>[
        (type: SearchModuleType.recentSearches, visible: true),
        (type: SearchModuleType.frequentBangs, visible: true),
        (type: SearchModuleType.topSites, visible: true),
      ];
      final persisted = [
        _entry(SearchModuleType.topSites, visible: false),
        _entry(SearchModuleType.recentSearches),
      ];

      final once = mergeModuleOrderWithDefaults(persisted, defaults);
      final twice = mergeModuleOrderWithDefaults(once, defaults);

      expect(twice, once);
    });
  });

  group('persisted payload compatibility', () {
    // The storage key and the on-disk shape are a compatibility contract: the
    // empty-state order has shipped to users under this exact key, encoded by
    // ModuleOrderEntry.toJson. Changing either silently resets their layout.
    test('the empty-state order keeps its shipped storage key', () {
      expect(ModuleSurface.newTab.key, 'EmptyStateModuleOrder');
    });

    test('a real shipped payload round-trips unchanged', () {
      // Captured from the shape SearchModuleOrder.build writes today: a user
      // who moved Shortcuts to the top and hid History Highlights.
      const payload =
          '[{"type":"topSites","visible":true},'
          '{"type":"recentSearches","visible":true},'
          '{"type":"frequentBangs","visible":true},'
          '{"type":"recentArticles","visible":true},'
          '{"type":"recentTabs","visible":true},'
          '{"type":"recentHistory","visible":true},'
          '{"type":"historyHighlights","visible":false},'
          '{"type":"containers","visible":true}]';

      final decoded = (jsonDecode(payload) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(ModuleOrderEntry.fromJson)
          .toList();

      final merged = mergeModuleOrderWithDefaults(
        decoded,
        ModuleSurface.newTab.defaultModules,
      );

      // Everything the user saved survives, in their order, untouched...
      expect(
        merged.where((e) => decoded.any((d) => d.type == e.type)).toList(),
        decoded,
        reason: 'a saved layout must survive the surface rename untouched',
      );
      expect(_types(merged).first, SearchModuleType.topSites);
      expect(
        merged
            .firstWhere((e) => e.type == SearchModuleType.historyHighlights)
            .visible,
        isFalse,
      );

      // ...and modules added since then appear without switching themselves on.
      final added = merged.where((e) => !decoded.any((d) => d.type == e.type));
      expect(
        added.every((e) => !e.visible),
        isTrue,
        reason: 'a module added to a shipped surface must default to off',
      );
    });

    test('unparseable entries are skipped rather than poisoning the list', () {
      // Mirrors the try/catch in SearchModuleOrder.build's decode: an entry
      // naming a module that no longer exists must not discard the whole order.
      const payload =
          '[{"type":"topSites","visible":true},'
          '{"type":"aModuleThatWasRemoved","visible":true}]';

      final decoded = (jsonDecode(payload) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((e) {
            try {
              return ModuleOrderEntry.fromJson(e);
            } catch (_) {
              return null;
            }
          })
          .whereType<ModuleOrderEntry>()
          .toList();

      expect(_types(decoded), [SearchModuleType.topSites]);
    });
  });
}
