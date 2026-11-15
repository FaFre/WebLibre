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
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/app_update/data/metadata/catalogue_codec.dart';
import 'package:weblibre/features/app_update/data/metadata/catalogue_reader.dart';
import 'package:weblibre/features/app_update/data/metadata/freshness_guard.dart';
import 'package:weblibre/features/app_update/data/metadata/signed_envelope.dart';
import 'package:weblibre/features/app_update/data/metadata/trusted_metadata_keys.dart';
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/services/artifact_selector.dart';

import '../fixtures.dart';

/// Catalogues produced by the updates repository's
/// `tools/update_catalogue.py` (FaFre/weblibre-updates), signed with a test
/// key, so the app and the tool are checked against each other (plan 9.2).
/// Regenerate them with the tool when its output format changes.
const _fixtures = 'test/features/app_update/data/fixtures/tool';

final _toolTestKey = TrustedMetadataKey(
  keyId: 'wl-meta-test',
  ed25519PublicKeyBase64: 'cg9H/Nx2SrlwxHLgJOMlvyXkCWYb2HjUYoHT+F/LWSU=',
);

Future<AcceptedCatalogue> _read(
  List<int> bytes,
  String packageId, {
  List<TrustedMetadataKey>? keys,
}) => CatalogueReader(
  verifier: SignedEnvelopeVerifier(keys ?? [_toolTestKey]),
  codec: CatalogueCodec(packageId: packageId),
).read(bytes);

void main() {
  test('the stable catalogue verifies and decodes', () async {
    final accepted = await _read(
      File('$_fixtures/eu.weblibre.gecko.catalogue.json').readAsBytesSync(),
      'eu.weblibre.gecko',
    );
    final c = accepted.catalogue;
    expect(c.revision, 1);
    expect(c.issuedAt, DateTime.utc(2026, 12, 1, 6));
    expect(c.expiresAt, DateTime.utc(2026, 12, 31, 6));
    expect(c.releases.map((r) => r.releaseId), ['v0.50.0', 'v0.49.0']);

    final newest = c.releases.first;
    expect(newest.logicalReleaseSequence, 47);
    expect(newest.security, SecurityClassification.fixesIncluded);
    expect(newest.targets, hasLength(7));
    expect(
      newest.releaseNotes.url,
      Uri.parse('https://github.com/FaFre/WebLibre/releases/tag/v0.50.0'),
    );
    expect(newest.releaseNotes.summary, {
      'en': '- New layout editor\n- Fixes',
      'de': '- Neuer Layout-Editor\n- Fehlerbehebungen',
    });

    expect(c.advisories.single.id, 'WL-2026-001');
    expect(c.advisories.single.severity, AdvisorySeverity.high);
    expect(c.advisories.single.introducedInSequence, 31);
    expect(c.advisories.single.fixedInSequence, 47);

    // The GitHub selector finds this build's target in it.
    final selection = const ArtifactSelector().selectGithub(
      c,
      installedBuild(),
    );
    expect(selection, isA<TargetSelected>());
    final target = (selection as TargetSelected).target;
    expect(target.id, 'v0.50.0/github/stable/skia/arm64-v8a');
    expect(target.versionCode, 473);
    expect(target.artifact!.url.path, startsWith('/FaFre/WebLibre/'));

    // And it is fresh for a build made before it was issued.
    expect(
      FreshnessGuard(buildTime: DateTime.utc(2026, 11, 30)).check(
        candidate: accepted,
        accepted: null,
        deviceNow: DateTime.utc(2026, 12, 2),
      ),
      isNull,
    );
  });

  test(
    'the alpha catalogue verifies and is for the alpha package only',
    () async {
      final bytes = File(
        '$_fixtures/eu.weblibre.gecko.alpha.catalogue.json',
      ).readAsBytesSync();
      final accepted = await _read(bytes, 'eu.weblibre.gecko.alpha');
      final release = accepted.catalogue.releases.single;
      expect(release.releaseId, 'v0.51.0-alpha-1');
      expect(release.targets.map((t) => t.track).toSet(), {ReleaseTrack.alpha});
      expect(
        release.targets.any((t) => t.distribution == Distribution.play),
        isFalse,
      );

      await expectLater(_read(bytes, 'eu.weblibre.gecko'), throwsA(anything));
    },
  );

  test('a catalogue signed by an untrusted key is rejected', () async {
    await expectLater(
      _read(
        File('$_fixtures/eu.weblibre.gecko.catalogue.json').readAsBytesSync(),
        'eu.weblibre.gecko',
        keys: productionMetadataKeys,
      ),
      throwsA(anything),
    );
  });

  test('no compiled key ID is also listed as retired', () {
    // A trusted ID in the retired list would turn a damaged stored copy
    // signed by it into a fresh start.
    expect(
      productionMetadataKeys
          .map((k) => k.keyId)
          .toSet()
          .intersection(retiredMetadataKeyIds),
      isEmpty,
    );
  });

  // The offline key's recovery drill (plan 5.4): a catalogue re-signed with
  // the offline key alone must verify against the keys this build compiles.
  //   WEBLIBRE_DRILL_CATALOGUE=/path/drill.json flutter test <this file>
  final drill = Platform.environment['WEBLIBRE_DRILL_CATALOGUE'];
  test(
    'drill: the given catalogue verifies against the compiled keys',
    () async {
      final bytes = File(drill!).readAsBytesSync();
      final envelope = await SignedEnvelopeVerifier(
        productionMetadataKeys,
      ).verify(bytes);
      // ignore: avoid_print
      print('verified by ${envelope.keyIds}');
      final packageId = drill.contains('alpha')
          ? 'eu.weblibre.gecko.alpha'
          : 'eu.weblibre.gecko';
      await _read(bytes, packageId, keys: productionMetadataKeys);
    },
    skip: drill == null ? 'set WEBLIBRE_DRILL_CATALOGUE to run' : false,
  );
}
