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

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/app_update/data/metadata/freshness_guard.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';

AcceptedCatalogue catalogue({
  required int revision,
  required DateTime issuedAt,
  DateTime? expiresAt,
  String digest = 'd',
}) => AcceptedCatalogue(
  catalogue: ReleaseCatalogue(
    packageId: 'eu.weblibre.gecko',
    revision: revision,
    issuedAt: issuedAt,
    expiresAt: expiresAt ?? issuedAt.add(const Duration(days: 30)),
    releases: const [],
    advisories: const [],
  ),
  payloadDigest: '$digest$revision',
  envelopeBytes: Uint8List(0),
);

void main() {
  final buildTime = DateTime.utc(2026, 11);
  final guard = FreshnessGuard(buildTime: buildTime);

  UpdateFailureKind? check(
    AcceptedCatalogue candidate,
    AcceptedCatalogue? accepted,
    DateTime now,
  ) => guard
      .check(candidate: candidate, accepted: accepted, deviceNow: now)
      ?.kind;

  final dec1 = DateTime.utc(2026, 12);

  test('a fresh catalogue on a fresh installation is accepted', () {
    expect(check(catalogue(revision: 1, issuedAt: dec1), null, dec1), isNull);
  });

  test('a lower revision is a rollback, whatever the clock says', () {
    final accepted = catalogue(revision: 11, issuedAt: dec1);
    final replay = catalogue(revision: 10, issuedAt: dec1);
    expect(check(replay, accepted, dec1), UpdateFailureKind.metadataRollback);
    expect(
      check(replay, accepted, DateTime.utc(2020)),
      UpdateFailureKind.metadataRollback,
    );
  });

  test('the same revision with another payload is a rollback', () {
    final accepted = catalogue(revision: 11, issuedAt: dec1);
    final other = catalogue(revision: 11, issuedAt: dec1, digest: 'other');
    expect(check(other, accepted, dec1), UpdateFailureKind.metadataRollback);
    expect(check(accepted, accepted, dec1), isNull);
  });

  test(
    'a catalogue older than this very build is not accepted, and retryable',
    () {
      // Normal right after a release, until the next one is signed: never a
      // rollback, which would offer no Retry.
      final old = catalogue(revision: 1, issuedAt: DateTime.utc(2026, 10, 20));
      expect(check(old, null, dec1), UpdateFailureKind.metadataPredatesBuild);
      expect(UpdateFailureKind.metadataPredatesBuild.retryable, isTrue);
    },
  );

  test('issued in the far future of the device clock is clockSuspect', () {
    final future = catalogue(revision: 1, issuedAt: DateTime.utc(2026, 12, 5));
    expect(check(future, null, dec1), UpdateFailureKind.clockSuspect);
  });

  test('expired beyond the slack is metadataExpired', () {
    final c = catalogue(revision: 1, issuedAt: dec1);
    expect(
      check(c, null, dec1.add(const Duration(days: 30, hours: 23))),
      isNull,
    );
    expect(
      check(c, null, dec1.add(const Duration(days: 31, hours: 1))),
      UpdateFailureKind.metadataExpired,
    );
  });

  test('clock forward then corrected recovers with nothing persisted', () {
    final c = catalogue(revision: 1, issuedAt: dec1);
    // 2036: fresh catalogues look expired while the clock is wrong.
    expect(
      check(c, null, DateTime.utc(2036)),
      UpdateFailureKind.metadataExpired,
    );
    // Nothing about that moment was stored: the corrected clock accepts it.
    expect(check(c, null, dec1.add(const Duration(days: 1))), isNull);
  });

  test('a clock set back cannot revive what expired before the floor', () {
    final old = catalogue(revision: 5, issuedAt: dec1);
    final newest = catalogue(revision: 9, issuedAt: DateTime.utc(2027, 3));
    // The device claims December 2026, but signed time says March 2027.
    expect(
      check(old, newest, dec1),
      UpdateFailureKind.metadataRollback, // lower revision anyway
    );
    expect(guard.effectiveNow(dec1, newest), DateTime.utc(2027, 3));
    // Set back to between the floor and real time, the newest accepted
    // catalogue stays usable: that delays updates, it authorizes nothing new.
    expect(check(newest, newest, DateTime.utc(2027, 3, 2)), isNull);
    // Set back before the floor: the clock is suspect.
    expect(
      check(newest, newest, DateTime.utc(2026, 1)),
      UpdateFailureKind.clockSuspect,
    );
  });

  test('effectiveNow never goes below the build time', () {
    expect(guard.effectiveNow(DateTime.utc(2001), null), buildTime);
  });
}
