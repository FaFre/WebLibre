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
import 'package:exceptions/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/module_surface_scope.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_term_suggestions_section.dart';
import 'package:weblibre/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Stands in for a remote provider (Brave, DuckDuckGo, ...) and records every
/// query that would have left the device.
class _RecordingProvider implements ISearchSuggestionProvider {
  final queries = <String>[];

  @override
  Future<Result<List<String>>> getSuggestions(String query) async {
    queries.add(query);
    return Result.success(['$query from remote']);
  }
}

class _FixedOrder extends SearchModuleOrder {
  @override
  List<ModuleOrderEntry> build(ModuleSurface surface) => [
    ModuleOrderEntry(type: SearchModuleType.searchSuggestions, visible: true),
  ];
}

void main() {
  Future<void> pumpSection(
    WidgetTester tester, {
    required _RecordingProvider remote,
    required TextEditingController controller,
    required bool fetchRemoteSuggestions,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          defaultSearchSuggestionsProvider.overrideWithValue(remote),
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
              pinnedHeaderBackgroundColor: null,
              child: CustomScrollView(
                slivers: [
                  SearchTermSuggestionsSection(
                    searchTextController: controller,
                    submitSearch: (_) async {},
                    fetchRemoteSuggestions: fetchRemoteSuggestions,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('a private search never reaches the remote provider', (
    tester,
  ) async {
    final remote = _RecordingProvider();
    final controller = TextEditingController(text: 'secret');
    addTearDown(controller.dispose);

    await pumpSection(
      tester,
      remote: remote,
      controller: controller,
      fetchRemoteSuggestions: false,
    );
    await tester.pump(const Duration(milliseconds: 300));

    controller.text = 'secret plans';
    await tester.pump(const Duration(milliseconds: 300));

    expect(remote.queries, isEmpty);
    // The typed text is still offered as a search.
    expect(find.text('secret plans'), findsOneWidget);
  });

  testWidgets('a regular search asks the remote provider', (tester) async {
    final remote = _RecordingProvider();
    final controller = TextEditingController(text: 'weather');
    addTearDown(controller.dispose);

    await pumpSection(
      tester,
      remote: remote,
      controller: controller,
      fetchRemoteSuggestions: true,
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(remote.queries, ['weather']);
    expect(find.text('weather from remote'), findsOneWidget);
  });
}
