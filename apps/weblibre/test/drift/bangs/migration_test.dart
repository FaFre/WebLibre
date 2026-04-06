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

// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:weblibre/features/bangs/data/database/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = BangDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // The following template shows how to write tests ensuring your migrations
  // preserve existing data.
  // Testing this can be useful for migrations that change existing columns
  // (e.g. by alterating their type or constraints). Migrations that only add
  // tables or columns typically don't need these advanced tests. For more
  // information, see https://drift.simonbinder.eu/migrations/tests/#verifying-data-integrity
  // TODO: This generated template shows how these tests could be written. Adopt
  // it to your own needs when testing migrations with data integrity.
  test('migration from v1 to v2 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    // TODO: Fill these lists
    final oldBangData = <v1.BangData>[];
    final expectedNewBangData = <v2.BangData>[];

    final oldBangSyncData = <v1.BangSyncData>[];
    final expectedNewBangSyncData = <v2.BangSyncData>[];

    final oldBangFrequencyData = <v1.BangFrequencyData>[];
    final expectedNewBangFrequencyData = <v2.BangFrequencyData>[];

    final oldBangHistoryData = <v1.BangHistoryData>[];
    final expectedNewBangHistoryData = <v2.BangHistoryData>[];

    final oldBangFtsData = <v1.BangFtsData>[];
    final expectedNewBangFtsData = <v2.BangFtsData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: BangDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.bang, oldBangData);
        batch.insertAll(oldDb.bangSync, oldBangSyncData);
        batch.insertAll(oldDb.bangFrequency, oldBangFrequencyData);
        batch.insertAll(oldDb.bangHistory, oldBangHistoryData);
        batch.insertAll(oldDb.bangFts, oldBangFtsData);
      },
      validateItems: (newDb) async {
        expect(expectedNewBangData, await newDb.select(newDb.bang).get());
        expect(
          expectedNewBangSyncData,
          await newDb.select(newDb.bangSync).get(),
        );
        expect(
          expectedNewBangFrequencyData,
          await newDb.select(newDb.bangFrequency).get(),
        );
        expect(
          expectedNewBangHistoryData,
          await newDb.select(newDb.bangHistory).get(),
        );
        expect(expectedNewBangFtsData, await newDb.select(newDb.bangFts).get());
      },
    );
  });
}
