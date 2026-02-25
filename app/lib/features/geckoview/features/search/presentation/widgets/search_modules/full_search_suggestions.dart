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
    final searchTextIsNotEmpty = useListenableSelector(
      searchTextController,
      () => searchTextController.text.isNotEmpty,
    );

    final searchSuggestions = ref.watch(searchSuggestionsProvider());
    final searchHistory = ref.watch(searchHistoryProvider);
    final expanded = ref.watch(searchSuggestionsExpandedProvider);

    useOnListenableChange(searchTextController, () {
      ref
          .read(searchSuggestionsProvider().notifier)
          .addQuery(searchTextController.text);
    });

    Widget buildSuggestionChip(
      String query, {
      Widget? avatar,
      Future<void> Function()? onDelete,
    }) {
      return InkWell(
        onLongPress: () {
          searchTextController.text = query;
        },
        child: InputChip(
          avatar: avatar ?? const Icon(Icons.search),
          label: Text(query),
          onSelected: (value) async {
            if (value) {
              await submitSearch(query);
            }
          },
          onDeleted: onDelete == null
              ? null
              : () async {
                  await onDelete();
                },
        ),
      );
    }

    final List<Widget> suggestionChips;

    if (!searchTextIsNotEmpty && (searchHistory.value.isNotEmpty)) {
      final entries = searchHistory.value!;

      suggestionChips = entries.map((entry) {
        final query = entry.searchQuery;

        return buildSuggestionChip(
          query,
          avatar: const Icon(Icons.history),
          onDelete: () async {
            await ref
                .read(bangDataRepositoryProvider.notifier)
                .removeSearchEntry(query);
          },
        );
      }).toList();
    } else {
      final prioritizedSuggestions = [
        if (searchTextIsNotEmpty) searchTextController.text,
        if (searchSuggestions.value != null)
          ...searchSuggestions.value!.whereNot(
            (suggestion) => suggestion == searchTextController.text,
          ),
      ];

      suggestionChips = prioritizedSuggestions.map((query) {
        return buildSuggestionChip(query);
      }).toList();
    }

    final toggleButton = IconButton(
      onPressed: () {
        ref.read(searchSuggestionsExpandedProvider.notifier).toggle();
      },
      icon: Icon(expanded ? Icons.unfold_less : Icons.unfold_more),
    );

    final suggestionsContent = expanded
        ? Padding(
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
                          child: Wrap(spacing: 8.0, children: suggestionChips),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
            child: SizedBox(
              height: 44,
              child: FadingScroll(
                fadingSize: 25,
                builder: (context, controller) {
                  return ListView.separated(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    itemCount: suggestionChips.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) => suggestionChips[index],
                  );
                },
              ),
            ),
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
              Expanded(child: suggestionsContent),
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: toggleButton,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
