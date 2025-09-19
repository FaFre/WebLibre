/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/bang_chips.dart';
import 'package:weblibre/presentation/hooks/listenable_callback.dart';

class FullSearchTermSuggestions extends HookConsumerWidget {
  final TextEditingController searchTextController;
  final Future<void> Function(String query) submitSearch;
  final BangData? activeBang;

  const FullSearchTermSuggestions({
    required this.searchTextController,
    required this.submitSearch,
    required this.activeBang,
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

    if (!searchTextIsNotEmpty && (searchHistory.value.isNotEmpty)) {
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
        if (searchSuggestions.value != null)
          ...searchSuggestions.value!.whereNot(
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
