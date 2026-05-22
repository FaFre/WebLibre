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
import 'dart:typed_data';

import 'package:search_client/search_client.dart';
import 'package:weblibre/features/user/data/database/daos/search_tokens.dart';

/// Drift-backed [TokenStash]. The optional [issuerKeyVersion] is only used
/// by [add], and only the issuance controller is supposed to call that.
/// Read-only consumers (the search session: reserve / commit / release /
/// count / clear) can leave it null; calling [add] on a stash constructed
/// without a key version is a programmer error and throws.
class DriftTokenStash implements TokenStash {
  final SearchTokensDao dao;
  final String? issuerKeyVersion;

  DriftTokenStash(this.dao, {this.issuerKeyVersion});

  @override
  Future<void> add(List<Uint8List> tokens) {
    final version = issuerKeyVersion;
    if (version == null) {
      throw StateError(
        'DriftTokenStash.add called without an issuerKeyVersion — '
        'construct a stash with the version returned by '
        'IssuanceClient.fetchPublicKey() before issuing tokens.',
      );
    }
    return dao.addTokens(tokens, issuerKeyVersion: version);
  }

  @override
  Future<ReservedStashToken?> reserveOne() async {
    final reserved = await dao.reserveOne();
    if (reserved == null) return null;
    return ReservedStashToken(id: reserved.id, token: reserved.token);
  }

  @override
  Future<void> commitReserved(int id) => dao.commitReserved(id);

  @override
  Future<void> releaseReserved(int id) => dao.releaseReserved(id);

  @override
  Future<Uint8List?> takeOne() async {
    final reserved = await reserveOne();
    if (reserved == null) return null;
    await commitReserved(reserved.id);
    return reserved.token;
  }

  @override
  Future<int> count() => dao.count();

  @override
  Future<void> clear() async {
    await dao.clear();
  }
}
