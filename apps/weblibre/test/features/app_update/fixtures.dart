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

import 'package:cryptography/cryptography.dart';
import 'package:weblibre/features/app_update/data/metadata/catalogue_codec.dart';
import 'package:weblibre/features/app_update/data/metadata/catalogue_reader.dart';
import 'package:weblibre/features/app_update/data/metadata/signed_envelope.dart';
import 'package:weblibre/features/app_update/data/metadata/trusted_metadata_keys.dart';
import 'package:weblibre/features/app_update/domain/entities/component_identity.dart';
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';

const packageId = 'eu.weblibre.gecko';

/// A throwaway Ed25519 metadata key, as the updates repository's tool would
/// generate one.
class TestSigningKey {
  TestSigningKey._(this.keyId, this._keyPair, this.trusted);

  final String keyId;
  final SimpleKeyPair _keyPair;
  final TrustedMetadataKey trusted;

  static Future<TestSigningKey> generate(String keyId) async {
    final algorithm = Ed25519();
    final pair = await algorithm.newKeyPair();
    final public = await pair.extractPublicKey();
    return TestSigningKey._(
      keyId,
      pair,
      TrustedMetadataKey(
        keyId: keyId,
        ed25519PublicKeyBase64: base64.encode(public.bytes),
      ),
    );
  }

  Future<String> sign(List<int> message) async {
    final signature = await Ed25519().sign(message, keyPair: _keyPair);
    return base64.encode(signature.bytes);
  }
}

/// Wraps [payload] in a DSSE envelope signed by [keys].
Future<List<int>> envelope(
  Object payload, {
  required List<TestSigningKey> keys,
  String payloadType = cataloguePayloadType,
}) async {
  final bytes = payload is List<int>
      ? payload
      : utf8.encode(jsonEncode(payload));
  final pae = dssePae(payloadType, bytes);
  return utf8.encode(
    jsonEncode({
      'payloadType': payloadType,
      'payload': base64.encode(bytes),
      'signatures': [
        for (final key in keys)
          {'keyid': key.keyId, 'sig': await key.sign(pae)},
      ],
    }),
  );
}

final _defaultIssued = DateTime.utc(2026, 12);

String _sha(int seed) => seed.toRadixString(16).padLeft(64, '0');

/// The digest [releaseJson] gives a GitHub target.
String githubSha(
  int sequence, {
  String abi = 'arm64-v8a',
  bool impeller = false,
}) {
  const digits = {'x86_64': 1, 'armeabi-v7a': 2, 'arm64-v8a': 3};
  return _sha(sequence * 100 + digits[abi]! + (impeller ? 50 : 0));
}

int githubLength(int sequence) => 1000 + sequence;

/// One GitHub target for each ABI, Skia and Impeller, plus a Play target.
Map<String, Object?> releaseJson({
  required int sequence,
  String? appVersion,
  String track = 'stable',
  String security = 'unknown',
  Map<String, Object?>? notes,
  Map<String, Object?>? components,
  int minSdk = 26,
}) {
  final version = appVersion ?? '0.$sequence.0';
  const abis = {'x86_64': 1, 'armeabi-v7a': 2, 'arm64-v8a': 3};
  return {
    'releaseId': 'v$version',
    'appVersion': version,
    'logicalReleaseSequence': sequence,
    'targets': [
      for (final renderer in ['skia', 'impeller'])
        for (final MapEntry(key: abi, value: digit) in abis.entries)
          {
            'id': 'v$version/github/$track/$renderer/$abi',
            'distribution': 'github',
            'track': track,
            'renderer': renderer,
            'abi': abi,
            'versionCode': sequence * 10 + digit,
            'minSdk': minSdk,
            'artifact': {
              'url':
                  'https://github.com/FaFre/WebLibre/releases/download/v$version/app-$track-$abi-release.apk',
              'byteLength': 1000 + sequence,
              'sha256': _sha(
                sequence * 100 + digit + (renderer == 'impeller' ? 50 : 0),
              ),
            },
          },
      {
        'id': 'v$version/play/$track/skia',
        'distribution': 'play',
        'track': track,
        'renderer': 'skia',
        'versionCode': sequence,
        'minSdk': minSdk,
      },
    ],
    'components':
        components ??
        {
          'gecko': {'version': '$sequence.0', 'buildId': '20261124093000'},
          'singbox': {'version': '1.14.4'},
        },
    'security': {'classification': security},
    'releaseNotes': ?notes,
  };
}

Map<String, Object?> catalogueJson({
  int revision = 1,
  DateTime? issuedAt,
  DateTime? expiresAt,
  List<Map<String, Object?>>? releases,
  List<Map<String, Object?>> advisories = const [],
  String scopePackage = packageId,
}) {
  final issued = issuedAt ?? _defaultIssued;
  return {
    'schemaVersion': 1,
    'scope': {'packageId': scopePackage},
    'revision': revision,
    'issuedAt': issued.toIso8601String(),
    'expiresAt': (expiresAt ?? issued.add(const Duration(days: 30)))
        .toIso8601String(),
    'releases': releases ?? [releaseJson(sequence: 43)],
    'advisories': advisories,
  };
}

CatalogueReader readerFor(
  List<TestSigningKey> keys, {
  Set<String> retiredKeyIds = const {},
}) => CatalogueReader(
  verifier: SignedEnvelopeVerifier([
    for (final k in keys) k.trusted,
  ], retiredKeyIds: retiredKeyIds),
  codec: const CatalogueCodec(packageId: packageId),
);

InstalledBuildInfo installedBuild({
  int sequence = 42,
  String abi = 'arm64-v8a',
  ReleaseTrack track = ReleaseTrack.stable,
  Renderer renderer = Renderer.skia,
  Distribution distribution = Distribution.github,
  int? versionCode,
  int sdkInt = 34,
  bool signerTrusted = true,
  bool debugBuild = false,
  DateTime? buildTime,
  String? installerPackage,
  bool installerIsSelf = false,
  bool installerIsSystem = false,
}) {
  const digits = {'x86_64': 1, 'armeabi-v7a': 2, 'arm64-v8a': 3};
  return InstalledBuildInfo(
    packageId: packageId,
    versionCode:
        versionCode ??
        (distribution == Distribution.play
            ? sequence
            : sequence * 10 + digits[abi]!),
    versionName: '0.$sequence.0',
    distribution: distribution,
    track: track,
    renderer: renderer,
    abi: abi,
    debugBuild: debugBuild,
    signerTrusted: signerTrusted,
    installerPackage: installerPackage,
    installerLabel: installerPackage == null
        ? null
        : 'Label of $installerPackage',
    installerIsSystem: installerIsSystem,
    installerIsSelf: installerIsSelf,
    logicalReleaseSequence: sequence,
    buildTime: buildTime ?? DateTime.utc(2026, 11),
    sdkInt: sdkInt,
    components: {
      ComponentId.gecko: ComponentKnown(
        '$sequence.0',
        buildId: '20261024093000',
      ),
      ComponentId.singbox: ComponentKnown('1.14.4'),
    },
  );
}

/// A parsed catalogue, without the envelope.
ReleaseCatalogue catalogue(
  List<Map<String, Object?>> releases, {
  List<Map<String, Object?>> advisories = const [],
}) => const CatalogueCodec(packageId: packageId).decode(
  utf8.encode(
    jsonEncode(catalogueJson(releases: releases, advisories: advisories)),
  ),
);
