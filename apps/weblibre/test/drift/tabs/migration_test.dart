// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'generated/schema.dart';

import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v15.dart' as v15;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper(), setup: registerUrlFunctions);
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
  test(
    'migration from v15 to v16 rewrites a shared URL to the kept tab',
    () async {
      final schema = await verifier.schemaAt(15);

      // Same URL open in an excluded container and in a normal one, with the
      // excluded tab newest — so v15 left *its* content in the index. The v16
      // DELETE spares this row (the normal tab still holds the URL), so only the
      // re-INSERT half can scrub the excluded tab's title and content out.
      final oldDb = v15.DatabaseAtV15(schema.newConnection());
      await oldDb.customStatement(
        'INSERT INTO local_index_setting ("key", value) '
        "VALUES ('enabled', 1), ('index_private', 0)",
      );
      await oldDb.customStatement(
        'INSERT INTO container (id, color, order_key, is_pinned, metadata) '
        "VALUES ('excluded', 0, 'a', 0, '{\"excludeFromHistory\":true}')",
      );
      await oldDb.customStatement(
        'INSERT INTO container (id, color, order_key, is_pinned, metadata) '
        "VALUES ('recorded', 0, 'b', 0, '{}')",
      );
      await oldDb.customStatement(
        'INSERT INTO tab (id, source, container_id, order_key, url, title, '
        'extracted_content_plain, timestamp) '
        "VALUES ('kept', 2, 'recorded', 'a', 'https://example.com/shared', "
        "'Public title', 'public body', 1)",
      );
      await oldDb.customStatement(
        'INSERT INTO tab (id, source, container_id, order_key, url, title, '
        'extracted_content_plain, timestamp) '
        "VALUES ('secret', 2, 'excluded', 'b', 'https://example.com/shared', "
        "'SECRET title', 'secret body', 2)",
      );

      final seeded = await oldDb
          .customSelect('SELECT title FROM history')
          .getSingle();
      expect(
        seeded.read<String>('title'),
        'SECRET title',
        reason: 'v15 let the excluded tab win the shared URL',
      );
      await oldDb.close();

      final db = TabDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, 16);

      final row = await db
          .customSelect('SELECT title, extracted_content_plain FROM history')
          .getSingle();
      expect(row.read<String>('title'), 'Public title');
      expect(row.read<String>('extracted_content_plain'), 'public body');

      final ftsHits = await db
          .customSelect(
            "SELECT COUNT(*) AS c FROM history_fts WHERE history_fts MATCH 'secret'",
          )
          .getSingle();
      expect(
        ftsHits.read<int>('c'),
        0,
        reason: 'the excluded content must be gone from the FTS index too',
      );

      await db.close();
    },
  );

  test('migration from v15 to v16 evicts excluded pages from the index', () async {
    final schema = await verifier.schemaAt(15);

    // v15 indexed excluded-from-history containers like any other, so seed the
    // rows the old triggers would have produced.
    final oldDb = v15.DatabaseAtV15(schema.newConnection());
    await oldDb.customStatement(
      'INSERT INTO local_index_setting ("key", value) '
      "VALUES ('enabled', 1), ('index_private', 0)",
    );
    for (final (id, excludeFromHistory) in [
      ('excluded', true),
      ('recorded', false),
    ]) {
      await oldDb.customStatement(
        'INSERT INTO container (id, color, order_key, is_pinned, metadata) '
        'VALUES (?, 0, ?, 0, ?)',
        [id, id, '{"excludeFromHistory":$excludeFromHistory}'],
      );
      await oldDb.customStatement(
        'INSERT INTO tab (id, source, container_id, order_key, url, timestamp) '
        'VALUES (?, 2, ?, ?, ?, 1)',
        ['$id-tab', id, '$id-tab', 'https://example.com/$id'],
      );
    }

    final seeded = await oldDb
        .customSelect(
          'SELECT url_canonical FROM history ORDER BY url_canonical',
        )
        .get();
    expect(
      [for (final row in seeded) row.read<String>('url_canonical')],
      ['https://example.com/excluded', 'https://example.com/recorded'],
      reason: 'v15 indexed both containers',
    );
    await oldDb.close();

    final db = TabDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 16);

    final remaining = await db
        .customSelect(
          'SELECT url_canonical FROM history ORDER BY url_canonical',
        )
        .get();
    expect(
      [for (final row in remaining) row.read<String>('url_canonical')],
      ['https://example.com/recorded'],
      reason: 'the excluded container is evicted, the other one is kept',
    );

    await db.close();
  });

  test('migration from v15 to v16 leaves a disabled index empty', () async {
    final schema = await verifier.schemaAt(15);

    // Local search index off, so v15 indexed nothing. The v16 re-INSERT reads
    // straight from `tab`, so without the `enabled` gate it would populate the
    // index for a user who turned it off.
    final oldDb = v15.DatabaseAtV15(schema.newConnection());
    await oldDb.customStatement(
      'INSERT INTO local_index_setting ("key", value) '
      "VALUES ('enabled', 0), ('index_private', 0)",
    );
    await oldDb.customStatement(
      'INSERT INTO container (id, color, order_key, is_pinned, metadata) '
      "VALUES ('excluded', 0, 'a', 0, '{\"excludeFromHistory\":true}')",
    );
    await oldDb.customStatement(
      'INSERT INTO container (id, color, order_key, is_pinned, metadata) '
      "VALUES ('recorded', 0, 'b', 0, '{}')",
    );
    await oldDb.customStatement(
      'INSERT INTO tab (id, source, container_id, order_key, url, title, '
      'extracted_content_plain, timestamp) '
      "VALUES ('kept', 2, 'recorded', 'a', 'https://example.com/shared', "
      "'Public title', 'public body', 1)",
    );
    await oldDb.customStatement(
      'INSERT INTO tab (id, source, container_id, order_key, url, title, '
      'extracted_content_plain, timestamp) '
      "VALUES ('secret', 2, 'excluded', 'b', 'https://example.com/shared', "
      "'SECRET title', 'secret body', 2)",
    );

    final seeded = await oldDb
        .customSelect('SELECT COUNT(*) AS c FROM history')
        .getSingle();
    expect(seeded.read<int>('c'), 0, reason: 'v15 indexed nothing while off');
    await oldDb.close();

    final db = TabDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 16);

    final rows = await db
        .customSelect('SELECT COUNT(*) AS c FROM history')
        .getSingle();
    expect(
      rows.read<int>('c'),
      0,
      reason: 'the migration must not index for a user who opted out',
    );

    await db.close();
  });

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
