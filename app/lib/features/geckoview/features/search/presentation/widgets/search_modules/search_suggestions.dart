import 'package:collection/collection.dart';
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/domain/providers/bangs.dart';
import 'package:lensai/features/bangs/domain/repositories/data.dart';
import 'package:lensai/features/geckoview/features/browser/domain/providers.dart';
import 'package:lensai/features/geckoview/features/search/domain/providers/search_suggestions.dart';
import 'package:lensai/features/geckoview/features/search/presentation/widgets/bang_chips.dart';
import 'package:lensai/presentation/hooks/listenable_callback.dart';
import 'package:nullability/nullability.dart';
import 'package:sliver_tools/sliver_tools.dart';

class SearchTermSuggestions extends HookConsumerWidget {
  final TextEditingController searchTextController;
  final Future<void> Function(String query) submitSearch;
  final BangData? activeBang;

  final bool showHistory;
  final bool showChips;

  const SearchTermSuggestions({
    required this.searchTextController,
    required this.submitSearch,
    required this.activeBang,
    this.showHistory = true,
    this.showChips = true,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchTextIsNotEmpty = useListenableSelector(
      searchTextController,
      () => searchTextController.text.isNotEmpty,
    );

    final searchSuggestions = ref.watch(searchSuggestionsProvider());

    final searchHistory = ref.watch(searchHistoryProvider);

    useListenableCallback(searchTextController, () {
      ref
          .read(searchSuggestionsProvider().notifier)
          .addQuery(searchTextController.text);
    });

    final Widget listSliver;

    if (showHistory &&
        !searchTextIsNotEmpty &&
        (searchHistory.value.isNotEmpty)) {
      final entries = searchHistory.value!;

      listSliver = SliverList.builder(
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
    } else {
      final prioritizedSuggestions = [
        if (searchTextIsNotEmpty) searchTextController.text,
        if (searchSuggestions.valueOrNull != null)
          ...searchSuggestions.valueOrNull!.whereNot(
            (suggestion) => suggestion == searchTextController.text,
          ),
      ];

      listSliver = SliverList.builder(
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

    return MultiSliver(
      children: [
        if (showChips)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Provider',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  BangChips(
                    activeBang: activeBang,
                    onSelected: (bang) {
                      searchTextController.clear();

                      ref
                          .read(selectedBangTriggerProvider().notifier)
                          .setTrigger(bang.trigger);
                    },
                    onDeleted: (bang) async {
                      if (ref.read(selectedBangTriggerProvider()) ==
                          bang.trigger) {
                        ref
                            .read(selectedBangTriggerProvider().notifier)
                            .clearTrigger();
                      } else {
                        final dialogResult = await BangChips.resetBangDialog(
                          context,
                          bang.trigger,
                        );

                        if (dialogResult == true) {
                          await ref
                              .read(bangDataRepositoryProvider.notifier)
                              .resetFrequency(bang.trigger);
                        }
                      }
                    },
                    searchTextController: searchTextController,
                  ),
                ],
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 150),
            child: FadingScroll(
              fadingSize: 25,
              builder: (context, controller) {
                return CustomScrollView(
                  shrinkWrap: true,
                  controller: controller,
                  slivers: [listSliver],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
