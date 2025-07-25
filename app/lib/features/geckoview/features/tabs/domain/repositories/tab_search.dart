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
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/tab_query_result.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';

part 'tab_search.g.dart';

enum TabSearchPartition { preview, search }

@Riverpod()
class TabSearchRepository extends _$TabSearchRepository {
  Future<void> addQuery(
    String input, {
    int snippetLength = 120,
    String matchPrefix = '***',
    String matchSuffix = '***',
    String ellipsis = '…',
  }) async {
    if (input.isNotEmpty) {
      state = await AsyncValue.guard(() async {
        return (
          query: input,
          results: await ref
              .read(tabDatabaseProvider)
              .tabDao
              .queryTabs(
                matchPrefix: matchPrefix,
                matchSuffix: matchSuffix,
                ellipsis: ellipsis,
                snippetLength: snippetLength,
                searchString: input,
              )
              .get(),
        );
      });
    } else {
      state = const AsyncValue.data(null);
    }
  }

  @override
  Future<({String query, List<TabQueryResult> results})?> build(
    TabSearchPartition partition,
  ) {
    return Future.value();
  }
}
