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
import 'package:collection/collection.dart';
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/domain/repositories/data.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_suggestions_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/smart_bang_selector.dart';

class FullSearchTermSuggestions extends HookConsumerWidget {
  final TextEditingController searchTextController;
  final Future<void> Function(String query) submitSearch;
  final BangData? activeBang;

  /// The domain to scope site-specific bangs to.
  /// When null, only global bangs are shown (new tab mode).
  final String? domain;

  const FullSearchTermSuggestions({
    required this.searchTextController,
    required this.submitSearch,
    required this.activeBang,
    this.domain,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchText = useListenableSelector(
      searchTextController,
      () => searchTextController.text,
    );
    final searchTextIsNotEmpty = searchText.isNotEmpty;

    final searchSuggestions = ref.watch(searchSuggestionsProvider());
    final searchHistory = ref.watch(searchHistoryProvider);
    final expanded = ref.watch(searchSuggestionsExpandedProvider);

    useOnListenableChange(searchTextController, () {
      ref
          .read(searchSuggestionsProvider().notifier)
          .addQuery(searchTextController.text);
    });

    final showHistory =
        !searchTextIsNotEmpty && (searchHistory.value.isNotEmpty);

    final suggestionQueries = useMemoized(
      () => showHistory
          ? searchHistory.value!.map((e) => e.searchQuery).toList()
          : [
              if (searchTextIsNotEmpty) searchText,
              if (searchSuggestions.value != null)
                ...searchSuggestions.value!.whereNot((s) => s == searchText),
            ],
      [showHistory, searchText, searchHistory.value, searchSuggestions.value],
    );

    return MultiSliver(
      children: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: SmartBangSelector(
              domain: domain,
              searchTextController: searchTextController,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SuggestionsContent(
                  expanded: expanded,
                  queries: suggestionQueries,
                  showHistory: showHistory,
                  searchTextController: searchTextController,
                  submitSearch: submitSearch,
                  onDeleteHistory: (query) => ref
                      .read(bangDataRepositoryProvider.notifier)
                      .removeSearchEntry(query),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: IconButton(
                  onPressed: ref
                      .read(searchSuggestionsExpandedProvider.notifier)
                      .toggle,
                  icon: Icon(expanded ? Icons.unfold_less : Icons.unfold_more),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuggestionsContent extends StatelessWidget {
  final bool expanded;
  final List<String> queries;
  final bool showHistory;
  final TextEditingController searchTextController;
  final Future<void> Function(String query) submitSearch;
  final Future<void> Function(String query) onDeleteHistory;

  const _SuggestionsContent({
    required this.expanded,
    required this.queries,
    required this.showHistory,
    required this.searchTextController,
    required this.submitSearch,
    required this.onDeleteHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 150),
          child: FadingScroll(
            fadingSize: 25,
            builder: (context, controller) {
              return CustomScrollView(
                shrinkWrap: true,
                controller: controller,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Wrap(
                        spacing: 8.0,
                        children: [
                          for (final query in queries)
                            _SuggestionChip(
                              query: query,
                              showHistory: showHistory,
                              searchTextController: searchTextController,
                              submitSearch: submitSearch,
                              onDeleteHistory: onDeleteHistory,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
      child: SizedBox(
        height: 44,
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              itemCount: queries.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) => _SuggestionChip(
                query: queries[index],
                showHistory: showHistory,
                searchTextController: searchTextController,
                submitSearch: submitSearch,
                onDeleteHistory: onDeleteHistory,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String query;
  final bool showHistory;
  final TextEditingController searchTextController;
  final Future<void> Function(String query) submitSearch;
  final Future<void> Function(String query) onDeleteHistory;

  const _SuggestionChip({
    required this.query,
    required this.showHistory,
    required this.searchTextController,
    required this.submitSearch,
    required this.onDeleteHistory,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () => searchTextController.text = query,
      child: InputChip(
        avatar: Icon(showHistory ? Icons.history : Icons.search),
        label: Text(query),
        onSelected: (value) async {
          if (value) await submitSearch(query);
        },
        onDeleted: showHistory ? () => onDeleteHistory(query) : null,
      ),
    );
  }
}
