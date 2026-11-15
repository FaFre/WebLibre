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
import 'dart:convert';

import 'package:fast_equatable/fast_equatable.dart';

/// A compiled metadata verification key (plan 5.4).
class TrustedMetadataKey with FastEquatable {
  TrustedMetadataKey({
    required this.keyId,
    required this.ed25519PublicKeyBase64,
  });

  final String keyId;

  /// The raw 32-byte Ed25519 public key, standard base64.
  final String ed25519PublicKeyBase64;

  List<int> get publicKey => base64.decode(ed25519PublicKeyBase64);

  @override
  List<Object?> get hashParameters => [keyId, ed25519PublicKeyBase64];
}

/// The metadata keys this build trusts. A downloaded key is never trusted;
/// this set changes only with an app release (5.4).
///
/// Two entries from day one: `wl-meta-<year>a`, online in the updates
/// repository's protected `update-metadata` environment, and `wl-meta-<year>b`,
/// the offline backup. Both are generated with the updates repository's
/// `tools/update_catalogue.py keygen` (Phase 0, gate G2); only their public
/// halves belong here.
///
/// With no key compiled in, a GitHub build has no updater at all
/// ([DistributionPolicy.derive]), rather than one that fails every check.
final productionMetadataKeys = <TrustedMetadataKey>[
  TrustedMetadataKey(
    keyId: 'wl-meta-2026a',
    ed25519PublicKeyBase64: 'rsqyLwxJh8BN5pu/kEtuhIHoI8G1ISn56Q/TfGTlouI=',
  ),
  TrustedMetadataKey(
    keyId: 'wl-meta-2026b',
    ed25519PublicKeyBase64: 'VN4clGJMIE/hvOY3QiOfvPhqmgJrs0aWlSgK2Y5oKiA=',
  ),
];

/// Key IDs that earlier builds trusted and this one no longer does (5.4
/// rotation). A stored catalogue signed only by these is no evidence, and the
/// build-time floor applies instead (6.1): a key leaves
/// [productionMetadataKeys] only in a release later than every catalogue it
/// signed alone, so that floor is already higher. A stored copy signed by any
/// other unknown key ID is damage, never absence (6.2).
///
/// When a release drops a key from [productionMetadataKeys], its ID moves
/// here and stays. The two lists never share an ID.
const retiredMetadataKeyIds = <String>{};
