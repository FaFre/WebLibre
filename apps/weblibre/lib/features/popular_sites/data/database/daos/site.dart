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
import 'package:drift/drift.dart';
import 'package:weblibre/features/popular_sites/data/database/daos/site.drift.dart';
import 'package:weblibre/features/popular_sites/data/database/database.dart';
import 'package:weblibre/features/popular_sites/data/database/definitions.drift.dart';

@DriftAccessor()
class SiteDao extends DatabaseAccessor<SitesDatabase> with $SiteDaoMixin {
  SiteDao(super.db);

  /// Popular-domain prefix completions for the omnibar, ordered by Tranco
  /// popularity (densely re-ranked at build time, so `rank` is a contiguous
  /// 1..N order). [prefix] is matched case-insensitively against the start of
  /// the registrable domain.
  ///
  /// LIKE metacharacters (`%`, `_`, and the `\` escape char itself) in the
  /// user input are escaped so they match literally rather than acting as
  /// wildcards — see the `ESCAPE '\'` clause on `searchSitesByPrefix`.
  Selectable<Site> searchByPrefix(String prefix, {int limit = 8}) {
    final escaped = prefix
        .trim()
        .toLowerCase()
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');

    return db.definitionsDrift.searchSitesByPrefix(
      pattern: '$escaped%',
      limit: limit,
    );
  }
}
