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
import 'package:weblibre/features/search_credits/data/token_stash.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'search_token_stash_repository.g.dart';

/// Read-only-shaped stash for the search session: only reserve / commit /
/// release / count / take / clear are safe to call. The issuance controller
/// constructs its own stash with the freshly-fetched `key.version` before
/// calling `stash.add` so token rows are tagged with the exact key the
/// issuer signed against — see [searchTokenIssuanceControllerProvider].
@Riverpod(keepAlive: true)
DriftTokenStash searchTokenStash(Ref ref) {
  final db = ref.watch(userDatabaseProvider);
  return DriftTokenStash(db.searchTokensDao);
}

@Riverpod(keepAlive: true)
Stream<int> searchTokenStashCount(Ref ref) {
  final db = ref.watch(userDatabaseProvider);
  return db.searchTokensDao.watchCount();
}
