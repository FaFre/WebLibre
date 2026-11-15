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
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/features/app_update/data/metadata/trusted_metadata_keys.dart';

part 'signed_envelope.g.dart';

/// The only payload type this client accepts.
const cataloguePayloadType =
    'application/vnd.weblibre.update-catalogue.v1+json';

/// Envelopes larger than this are rejected before parsing (5.1).
const maxEnvelopeBytes = 256 * 1024;

/// More signature entries than this are rejected before any is verified.
/// The updates repository signs with this year's key pair, two at most even
/// across a key rollover; the cap only keeps an unsigned list from making the
/// client verify thousands of copies of one signature.
const maxEnvelopeSignatures = 8;

class EnvelopeRejected implements Exception {
  const EnvelopeRejected(this.reason, {this.retiredSigner = false});

  final String reason;

  /// Well formed, and every signature names a key a release has retired
  /// ([SignedEnvelopeVerifier.retiredKeyIds]). The metadata keys are per
  /// year, so a stored envelope can outlive its key in a later build; that is
  /// not damage. Any other key ID, and a known key that fails to verify,
  /// never set this: a damaged key ID must not read as a retired one (6.2).
  final bool retiredSigner;

  @override
  String toString() => 'EnvelopeRejected: $reason';
}

/// A DSSE envelope whose signature verified (D11).
class VerifiedEnvelope {
  const VerifiedEnvelope({
    required this.payloadType,
    required this.payload,
    required this.keyIds,
  });

  final String payloadType;

  /// The exact signed bytes.
  final Uint8List payload;

  /// The trusted keys that signed it.
  final List<String> keyIds;
}

/// A DSSE envelope as it arrives: nothing in it is trusted yet.
@JsonSerializable(createToJson: false, checked: true)
class DsseEnvelope {
  const DsseEnvelope({
    required this.payloadType,
    required this.payload,
    required this.signatures,
  });

  factory DsseEnvelope.fromJson(Map<String, dynamic> json) =>
      _$DsseEnvelopeFromJson(json);

  final String payloadType;

  /// Base64 of the signed bytes.
  final String payload;
  final List<DsseSignature> signatures;
}

@JsonSerializable(createToJson: false, checked: true)
class DsseSignature {
  const DsseSignature({required this.keyid, required this.sig});

  factory DsseSignature.fromJson(Map<String, dynamic> json) =>
      _$DsseSignatureFromJson(json);

  final String keyid;

  /// Base64 of the signature.
  final String sig;
}

/// The DSSE pre-authentication encoding: what the signature covers.
Uint8List dssePae(String payloadType, List<int> payload) {
  final type = utf8.encode(payloadType);
  final builder = BytesBuilder(copy: false)
    ..add(utf8.encode('DSSEv1 ${type.length} '))
    ..add(type)
    ..add(utf8.encode(' ${payload.length} '))
    ..add(payload);
  return builder.toBytes();
}

/// Verifies a signed envelope (5.1). In order: size limit, parse of the
/// envelope, known payload type, at least one signature by a compiled trusted
/// key. Only then is the payload handed out, still unparsed.
class SignedEnvelopeVerifier {
  SignedEnvelopeVerifier(
    this.trustedKeys, {
    this.retiredKeyIds = const {},
    Ed25519? algorithm,
  }) : _ed25519 = algorithm ?? Ed25519();

  final List<TrustedMetadataKey> trustedKeys;

  /// Key IDs earlier builds trusted and this one doesn't (5.4 rotation).
  /// Nothing they signed verifies; they only tell a retired signer apart
  /// from an unknown one ([EnvelopeRejected.retiredSigner]).
  final Set<String> retiredKeyIds;
  final Ed25519 _ed25519;

  Future<VerifiedEnvelope> verify(List<int> envelopeBytes) async {
    if (envelopeBytes.length > maxEnvelopeBytes) {
      throw const EnvelopeRejected('envelope too large');
    }

    final DsseEnvelope envelope;
    try {
      final json = jsonDecode(utf8.decode(envelopeBytes));
      if (json is! Map<String, dynamic>) {
        throw const EnvelopeRejected('envelope is not an object');
      }
      envelope = DsseEnvelope.fromJson(json);
    } on FormatException catch (e) {
      throw EnvelopeRejected('malformed envelope: ${e.message}');
    } on CheckedFromJsonException catch (e) {
      throw EnvelopeRejected('malformed envelope: ${e.className}.${e.key}');
    }

    final signatures = envelope.signatures;
    if (envelope.payloadType != cataloguePayloadType) {
      throw const EnvelopeRejected('unknown payloadType');
    }
    if (signatures.isEmpty) throw const EnvelopeRejected('no signatures');
    if (signatures.length > maxEnvelopeSignatures) {
      throw const EnvelopeRejected('too many signatures');
    }

    final payload = _canonicalBase64(envelope.payload, 'payload');
    final message = dssePae(envelope.payloadType, payload);

    final verifiedBy = <String>[];
    // Each trusted key is tried once, so verification is bounded by the
    // compiled keys whatever the envelope repeats.
    final tried = <String>{};
    var knownKeyTried = false;
    var onlyRetired = true;
    for (final DsseSignature(keyid: keyId, :sig) in signatures) {
      final signature = _canonicalBase64(sig, 'signature');
      if (signature.length != 64) {
        throw const EnvelopeRejected('signature of the wrong length');
      }
      if (!retiredKeyIds.contains(keyId)) onlyRetired = false;

      final key = trustedKeys.where((k) => k.keyId == keyId).firstOrNull;
      if (key == null) continue; // Unknown key IDs are ignored, not trusted.
      knownKeyTried = true;
      if (!tried.add(keyId)) continue;

      final ok = await _ed25519.verify(
        message,
        signature: Signature(
          signature,
          publicKey: SimplePublicKey(key.publicKey, type: KeyPairType.ed25519),
        ),
      );
      if (ok) verifiedBy.add(keyId);
    }

    if (verifiedBy.isEmpty) {
      throw EnvelopeRejected(
        knownKeyTried
            ? 'no valid signature by a trusted key'
            : 'no signature by a trusted key',
        retiredSigner: !knownKeyTried && onlyRetired,
      );
    }

    return VerifiedEnvelope(
      payloadType: envelope.payloadType,
      payload: payload,
      keyIds: verifiedBy,
    );
  }

  /// Standard base64 with padding, and only its one canonical spelling: any
  /// other encoding of the same bytes is rejected.
  static Uint8List _canonicalBase64(String text, String what) {
    final Uint8List bytes;
    try {
      bytes = base64.decode(text);
    } on FormatException {
      throw EnvelopeRejected('$what is not base64');
    }
    if (base64.encode(bytes) != text) {
      throw EnvelopeRejected('$what is not canonical base64');
    }
    return bytes;
  }
}
