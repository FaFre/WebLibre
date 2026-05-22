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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_query_chips.dart';
import 'package:weblibre/presentation/hooks/on_listenable_change_selector.dart';

class SearchTermSuggestionsSection extends HookConsumerWidget {
  final TextEditingController searchTextController;
  final Future<void> Function(String query) submitSearch;

  const SearchTermSuggestionsSection({
    required this.searchTextController,
    required this.submitSearch,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchText = useListenableSelector(
      searchTextController,
      () => searchTextController.text,
    );
    final searchSuggestions = ref.watch(
      searchSuggestionsProvider().select((value) => value.value ?? const []),
    );

    useOnListenableChangeSelector(
      searchTextController,
      () => searchTextController.text,
      () {
        ref
            .read(searchSuggestionsProvider().notifier)
            .addQuery(searchTextController.text);
      },
    );

    final queries = [
      if (searchText.isNotEmpty) searchText,
      ...searchSuggestions.where((suggestion) => suggestion != searchText),
    ];

    return SearchModuleSection(
      title: 'Suggestions',
      moduleType: SearchModuleType.searchSuggestions,
      totalCount: queries.length,
      contentSliverBuilder:
          ({required bool isCollapsed, required int visibleCount}) => [
            SliverToBoxAdapter(
              child: SearchQueryChips(
                queries: queries,
                showHistory: false,
                visibleCount: visibleCount,
                searchTextController: searchTextController,
                submitSearch: submitSearch,
              ),
            ),
          ],
    );
  }
}
