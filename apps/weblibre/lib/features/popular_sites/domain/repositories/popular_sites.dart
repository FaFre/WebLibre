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
import 'package:weblibre/features/popular_sites/data/providers.dart';

part 'popular_sites.g.dart';

@Riverpod(keepAlive: true)
class PopularSitesRepository extends _$PopularSitesRepository {
  /// Popular registrable domains whose start matches [prefix], ordered by
  /// popularity. Returns empty for a blank prefix so the omnibar suggestion
  /// module stays quiet until the user types.
  Future<List<Site>> searchByPrefix(String prefix, {int limit = 8}) {
    if (prefix.trim().isEmpty) {
      return Future.value(const []);
    }

    return ref
        .read(sitesDatabaseProvider)
        .siteDao
        .searchByPrefix(prefix, limit: limit)
        .get();
  }

  @override
  void build() {}
}
