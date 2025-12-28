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
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_suggestions.dart';
import 'package:weblibre/presentation/hooks/listenable_callback.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

class FixedSearchTermSuggestions extends HookConsumerWidget {
  final TextEditingController searchTextController;
  final Future<void> Function(String query) submitSearch;
  final BangData? activeBang;
  final int limit;

  const FixedSearchTermSuggestions({
    required this.searchTextController,
    required this.submitSearch,
    required this.activeBang,
    required this.limit,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSuggestableText = useListenableSelector(searchTextController, () {
      if (searchTextController.text.isNotEmpty) {
        final hasSupportedScheme =
            uri_parser
                .tryParseUrl(searchTextController.text)
                .mapNotNull((uri) => uri.hasSupportedScheme) ??
            false;

        return !hasSupportedScheme;
      }

      return false;
    });

    final searchSuggestions = ref.watch(searchSuggestionsProvider());

    useListenableCallback(searchTextController, () {
      if (ref.exists(searchSuggestionsProvider())) {
        ref
            .read(searchSuggestionsProvider().notifier)
            .addQuery(searchTextController.text);
      }
    });

    final prioritizedSuggestions = isSuggestableText
        ? [
            searchTextController.text,
            if (searchSuggestions.value != null)
              ...searchSuggestions.value!
                  .whereNot(
                    (suggestion) => suggestion == searchTextController.text,
                  )
                  .take(limit),
          ]
        : <String>[];

    return Wrap(
      spacing: 8.0,
      children: prioritizedSuggestions.map((query) {
        return InkWell(
          onLongPress: () {
            searchTextController.text = query;
          },
          child: InputChip(
            // avatar: const Icon(Icons.search),
            label: Text(query),
            onSelected: (value) async {
              if (value) {
                await submitSearch(query);
              }
            },
          ),
        );
      }).toList(),
    );
  }
}
