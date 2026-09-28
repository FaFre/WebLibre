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
import 'package:weblibre/features/geckoview/features/search/domain/entities/search_source_policy.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';

const _historyModules = {
  SearchModuleType.history,
  SearchModuleType.localHistory,
  SearchModuleType.combinedHistory,
};

void main() {
  group('SearchSourcePolicy.resolve', () {
    test('a regular search uses every source', () {
      final policy = SearchSourcePolicy.resolve(
        privateMode: false,
        privateSearchSuggestionsEnabled: false,
      );

      expect(policy.remoteSuggestions, isTrue);
      expect(policy.savedHistory, isTrue);
      expect(SearchModuleType.values.every(policy.allowsModule), isTrue);
    });

    test('by default a private search uses neither remote suggestions nor '
        'saved history', () {
      final policy = SearchSourcePolicy.resolve(
        privateMode: true,
        privateSearchSuggestionsEnabled: false,
      );

      expect(policy.remoteSuggestions, isFalse);
      expect(policy.savedHistory, isFalse);
    });

    test('opting in gives a private search the regular sources', () {
      final policy = SearchSourcePolicy.resolve(
        privateMode: true,
        privateSearchSuggestionsEnabled: true,
      );

      expect(policy.remoteSuggestions, isTrue);
      expect(policy.savedHistory, isTrue);
    });
  });

  group('SearchSourcePolicy.allowsModule', () {
    final policy = SearchSourcePolicy.resolve(
      privateMode: true,
      privateSearchSuggestionsEnabled: false,
    );

    test('drops every history module without saved history', () {
      for (final module in _historyModules) {
        expect(policy.allowsModule(module), isFalse, reason: module.name);
      }
    });

    test('keeps tabs, bookmarks, popular sites and suggestions', () {
      for (final module in SearchModuleType.values) {
        if (_historyModules.contains(module)) continue;
        expect(policy.allowsModule(module), isTrue, reason: module.name);
      }
    });
  });
}
