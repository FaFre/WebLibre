import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/bangs/domain/providers/bangs.dart';
import 'package:lensai/features/bangs/domain/repositories/data.dart';
import 'package:lensai/features/search/domain/providers/search_suggestions.dart';

class SearchSuggestionList extends HookConsumerWidget {
  final TextEditingController searchTextController;
  final Future<void> Function(String query) submitSearch;
  final bool showHistory;

  const SearchSuggestionList({
    required this.searchTextController,
    required this.submitSearch,
    this.showHistory = true,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useListenableSelector(
      searchTextController,
      () => searchTextController.text.isNotEmpty,
    );

    final suggestions = useStream(ref.watch(searchSuggestionsProvider()));

    final searchHistory = ref.watch(searchHistoryProvider);

    final searchText = searchTextController.text;

    if (showHistory &&
        (!searchText.isNotEmpty || !suggestions.hasData) &&
        (searchHistory.value?.isNotEmpty ?? false)) {
      final entries = searchHistory.value!;

      return SliverList.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final query = entries[index].searchQuery;

          return ListTile(
            leading: const Icon(Icons.history),
            title: Text(query),
            onLongPress: () {
              searchTextController.text = query;
            },
            onTap: () async {
              await submitSearch(query);
            },
            trailing: IconButton(
              onPressed: () async {
                await ref
                    .read(bangDataRepositoryProvider.notifier)
                    .removeSearchEntry(query);
              },
              icon: const Icon(Icons.close),
            ),
          );
        },
      );
    }

    final prioritizedSuggestions = [
      if (searchText.isNotEmpty) searchText,
      if (suggestions.data != null)
        ...suggestions.data!.whereNot((suggestion) => suggestion == searchText),
    ];

    return SliverList.builder(
      itemCount: prioritizedSuggestions.length,
      itemBuilder: (context, index) {
        final suggestion = prioritizedSuggestions[index];

        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(suggestion),
          onLongPress: () {
            searchTextController.text = suggestion;
          },
          onTap: () async {
            await submitSearch(suggestion);
          },
        );
      },
    );
  }
}
