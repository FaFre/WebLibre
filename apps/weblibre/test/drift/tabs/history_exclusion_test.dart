import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';

void main() {
  late TabDatabase db;

  setUp(() async {
    db = TabDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
          registerUrlFunctions(database);
        },
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('reports every tab, flagging the ones in excluded containers', () async {
    await _insertContainer(db, 'excluded', excludeFromHistory: true);
    await _insertContainer(db, 'recorded', excludeFromHistory: false);
    await _insertTab(db, id: 'excluded-tab', containerId: 'excluded');
    await _insertTab(db, id: 'recorded-tab', containerId: 'recorded');
    await _insertTab(db, id: 'uncontained-tab', containerId: null);

    final rows = await db.tabDao.historyExclusionTabs().get();

    expect(
      {for (final row in rows) row.tabId: row.excluded != 0},
      {
        'excluded-tab': true,
        'recorded-tab': false,
        // An uncontained tab has no container to opt it out.
        'uncontained-tab': false,
      },
    );
  });

  test('excludes a container without cookie isolation', () async {
    // The invariant this replaced tied exclude-from-history to a Gecko
    // contextId, which left plain containers unable to use the setting at all.
    await _insertContainer(
      db,
      'no-isolation',
      excludeFromHistory: true,
      contextualIdentity: null,
    );
    await _insertTab(db, id: 'tab', containerId: 'no-isolation');

    final rows = await db.tabDao.historyExclusionTabs().get();

    expect(rows.single.excluded, isNot(0));
    expect(await db.containerDao.excludedHistoryContextIds().get(), isEmpty);
  });

  test('reports contextIds of excluded cookie-isolated containers', () async {
    await _insertContainer(
      db,
      'isolated-excluded',
      excludeFromHistory: true,
      contextualIdentity: 'context-a',
    );
    await _insertContainer(
      db,
      'isolated-recorded',
      excludeFromHistory: false,
      contextualIdentity: 'context-b',
    );

    expect(await db.containerDao.excludedHistoryContextIds().get(), [
      'context-a',
    ]);
  });

  test('keeps excluded containers out of the local search index', () async {
    await db.customStatement(
      'INSERT INTO local_index_setting ("key", value) '
      "VALUES ('enabled', 1), ('index_private', 0)",
    );
    await _insertContainer(db, 'excluded', excludeFromHistory: true);
    await _insertContainer(db, 'recorded', excludeFromHistory: false);

    await _insertTab(db, id: 'recorded-tab', containerId: 'recorded');
    expect(await _indexedHosts(db), ['example.com']);

    await _insertTab(db, id: 'excluded-tab', containerId: 'excluded');
    expect(await _indexedHosts(db), ['example.com']);

    // Only the recorded tab's page is indexed; the excluded one never enters.
    final canonicals = await _indexedCanonicals(db);
    expect(canonicals, ['https://example.com/recorded-tab']);
  });

  test('turning the flag on evicts already indexed pages', () async {
    await db.customStatement(
      'INSERT INTO local_index_setting ("key", value) '
      "VALUES ('enabled', 1), ('index_private', 0)",
    );
    await _insertContainer(db, 'container', excludeFromHistory: false);
    await _insertTab(db, id: 'tab', containerId: 'container');

    expect(await _indexedCanonicals(db), ['https://example.com/tab']);

    await db.customStatement('UPDATE container SET metadata = ? WHERE id = ?', [
      '{"excludeFromHistory":true}',
      'container',
    ]);

    expect(await _indexedCanonicals(db), isEmpty);
  });

  test('follows a tab moved between containers', () async {
    await _insertContainer(db, 'excluded', excludeFromHistory: true);
    await _insertContainer(db, 'recorded', excludeFromHistory: false);
    await _insertTab(db, id: 'tab', containerId: 'recorded');

    expect((await db.tabDao.historyExclusionTabs().get()).single.excluded, 0);

    await db.customStatement(
      "UPDATE tab SET container_id = 'excluded' WHERE id = 'tab'",
    );

    expect(
      (await db.tabDao.historyExclusionTabs().get()).single.excluded,
      isNot(0),
    );
  });
}

Future<List<String?>> _indexedHosts(TabDatabase db) async {
  final rows = await db
      .customSelect(
        'SELECT url_host FROM history ORDER BY url_canonical',
        readsFrom: {db.history},
      )
      .get();

  return [for (final row in rows) row.read<String?>('url_host')];
}

Future<List<String?>> _indexedCanonicals(TabDatabase db) async {
  final rows = await db
      .customSelect(
        'SELECT url_canonical FROM history ORDER BY url_canonical',
        readsFrom: {db.history},
      )
      .get();

  return [for (final row in rows) row.read<String?>('url_canonical')];
}

Future<void> _insertContainer(
  TabDatabase db,
  String id, {
  required bool excludeFromHistory,
  String? contextualIdentity,
}) {
  final metadata = contextualIdentity == null
      ? '{"excludeFromHistory":$excludeFromHistory}'
      : '{"excludeFromHistory":$excludeFromHistory,'
            '"contextualIdentity":"$contextualIdentity"}';

  return db.customStatement(
    'INSERT INTO container (id, color, order_key, is_pinned, metadata) '
    'VALUES (?, 0, ?, 0, ?)',
    [id, id, metadata],
  );
}

Future<void> _insertTab(
  TabDatabase db, {
  required String id,
  required String? containerId,
}) {
  return db.customStatement(
    'INSERT INTO tab (id, source, container_id, order_key, url, timestamp) '
    'VALUES (?, 2, ?, ?, ?, 1)',
    [id, containerId, id, 'https://example.com/$id'],
  );
}
