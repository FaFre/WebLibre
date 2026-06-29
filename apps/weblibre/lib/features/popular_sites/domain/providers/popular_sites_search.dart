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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/popular_sites/data/database/definitions.drift.dart';
import 'package:weblibre/features/popular_sites/domain/repositories/popular_sites.dart';

part 'popular_sites_search.g.dart';

/// Holds the current popular-domain prefix completions for the omnibar
/// "Popular Sites" module. Mirrors the bookmark/tab search-result notifiers:
/// the widget watches the state list and pushes new queries through [search].
@Riverpod()
class PopularSitesSearchResults extends _$PopularSitesSearchResults {
  Future<void> search(String query, {int limit = 8}) async {
    if (query.trim().isEmpty) {
      state = const [];
      return;
    }

    final results = await ref
        .read(popularSitesRepositoryProvider.notifier)
        .searchByPrefix(query, limit: limit);

    if (!ref.mounted) return;
    state = results;
  }

  @override
  List<Site> build() {
    return const [];
  }
}
