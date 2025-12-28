// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

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
            final db = TabDatabase(schema.newConnection());
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
  test('migration from v2 to v3 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    // TODO: Fill these lists
    final oldContainerData = <v2.ContainerData>[];
    final expectedNewContainerData = <v3.ContainerData>[];

    final oldTabData = <v2.TabData>[];
    final expectedNewTabData = <v3.TabData>[];

    final oldTabFtsData = <v2.TabFtsData>[];
    final expectedNewTabFtsData = <v3.TabFtsData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: TabDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.container, oldContainerData);
        batch.insertAll(oldDb.tab, oldTabData);
        batch.insertAll(oldDb.tabFts, oldTabFtsData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewContainerData,
          await newDb.select(newDb.container).get(),
        );
        expect(expectedNewTabData, await newDb.select(newDb.tab).get());
        expect(expectedNewTabFtsData, await newDb.select(newDb.tabFts).get());
      },
    );
  });
}
