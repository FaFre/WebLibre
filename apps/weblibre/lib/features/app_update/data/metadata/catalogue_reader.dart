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

import 'package:crypto/crypto.dart';
import 'package:weblibre/features/app_update/data/metadata/catalogue_codec.dart';
import 'package:weblibre/features/app_update/data/metadata/signed_envelope.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';

/// The envelope is well formed but signed only by keys a release has retired
/// (see [EnvelopeRejected.retiredSigner]). To a download it is
/// `metadataInvalid` like any other rejection; the accepted-catalogue store
/// tells it apart, because a stored copy signed by a retired key is no longer
/// evidence, not damage.
// No fields of its own: equality is UpdateFailure's, and the type differs.
// ignore: missing_override_of_must_be_overridden
class CatalogueSignerRetired extends UpdateFailure {
  CatalogueSignerRetired([String? detail])
    : super(UpdateFailureKind.metadataInvalid, detail);
}

/// Envelope bytes → verified, parsed catalogue. Used for network downloads
/// and for the stored copies alike, so both pass exactly the same checks.
class CatalogueReader {
  const CatalogueReader({required this.verifier, required this.codec});

  final SignedEnvelopeVerifier verifier;
  final CatalogueCodec codec;

  /// Throws [UpdateFailure] for anything that doesn't verify or parse:
  /// `metadataClientTooOld` for a schema newer than this build reads,
  /// [CatalogueSignerRetired] for an envelope only retired keys signed, and
  /// `metadataInvalid` otherwise.
  Future<AcceptedCatalogue> read(List<int> envelopeBytes) async {
    try {
      final envelope = await verifier.verify(envelopeBytes);
      final catalogue = codec.decode(envelope.payload);
      return AcceptedCatalogue(
        catalogue: catalogue,
        payloadDigest: sha256.convert(envelope.payload).toString(),
        envelopeBytes: Uint8List.fromList(envelopeBytes).asUnmodifiableView(),
      );
    } on EnvelopeRejected catch (e) {
      if (e.retiredSigner) throw CatalogueSignerRetired(e.reason);
      throw UpdateFailure(UpdateFailureKind.metadataInvalid, e.reason);
    } on CatalogueInvalid catch (e) {
      throw UpdateFailure(
        e.clientTooOld
            ? UpdateFailureKind.metadataClientTooOld
            : UpdateFailureKind.metadataInvalid,
        e.reason,
      );
    }
  }
}
