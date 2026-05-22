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
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';

class SearchQueryChips extends StatelessWidget {
  final List<String> queries;
  final bool showHistory;
  final int visibleCount;
  final TextEditingController searchTextController;
  final Future<void> Function(String query) submitSearch;
  final Future<void> Function(String query)? onDeleteHistory;

  const SearchQueryChips({
    required this.queries,
    required this.showHistory,
    required this.visibleCount,
    required this.searchTextController,
    required this.submitSearch,
    this.onDeleteHistory,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (queries.isEmpty || visibleCount == 0) {
      return const SizedBox.shrink();
    }

    final visibleQueries = queries.take(visibleCount).toList();
    final showExpandedLayout = visibleCount >= queries.length;

    if (showExpandedLayout) {
      return Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 8.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            for (final query in visibleQueries)
              _SearchQueryChip(
                query: query,
                showHistory: showHistory,
                searchTextController: searchTextController,
                submitSearch: submitSearch,
                onDeleteHistory: onDeleteHistory,
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 8.0),
      child: SizedBox(
        height: 44,
        child: FadingScroll(
          fadingSize: 15,
          builder: (context, controller) {
            return ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              itemCount: visibleQueries.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) => _SearchQueryChip(
                query: visibleQueries[index],
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

class _SearchQueryChip extends StatelessWidget {
  final String query;
  final bool showHistory;
  final TextEditingController searchTextController;
  final Future<void> Function(String query) submitSearch;
  final Future<void> Function(String query)? onDeleteHistory;

  const _SearchQueryChip({
    required this.query,
    required this.showHistory,
    required this.searchTextController,
    required this.submitSearch,
    required this.onDeleteHistory,
  });

  void _fillField() {
    // Set the controller's value (not just `.text`) so the caret lands at
    // the end of the inserted query — bare `.text =` resets the selection
    // to offset 0, which feels broken when the user immediately tries to
    // continue typing.
    searchTextController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tap submits the query, long-press only fills the field so the user
    // can edit it before submitting. The GestureDetector and InputChip's
    // own tap detector both end up in Flutter's gesture arena: after
    // kLongPressTimeout the long-press wins and the tap is cancelled, so
    // a single long-press never double-fires the submit. A quick tap
    // resolves to onPressed before the long-press timer expires.
    return GestureDetector(
      onLongPress: _fillField,
      child: InputChip(
        avatar: Icon(showHistory ? Icons.history : Icons.search),
        label: Text(query),
        onPressed: () async {
          _fillField();
          await submitSearch(query);
        },
        onDeleted: showHistory && onDeleteHistory != null
            ? () => onDeleteHistory!(query)
            : null,
      ),
    );
  }
}
