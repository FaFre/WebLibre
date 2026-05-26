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

    await db.customStatement(
      'INSERT INTO local_index_setting ("key", value) '
      "VALUES ('enabled', 1), ('index_private', 0)",
    );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'container exclude flag re-evaluates existing tab history rows',
    () async {
      await _insertContainer(db, 'container', excludeFromIndex: false);
      await _insertTab(
        db,
        id: 'tab',
        containerId: 'container',
        url: 'https://example.com/page',
        title: 'Visible title',
      );

      expect(await _historyTitles(db), ['Visible title']);

      await _updateContainerExclude(db, 'container', excludeFromIndex: true);

      expect(await _historyTitles(db), isEmpty);

      await _updateContainerExclude(db, 'container', excludeFromIndex: false);

      expect(await _historyTitles(db), ['Visible title']);
    },
  );

  test('tab container assignment re-evaluates existing history rows', () async {
    await _insertContainer(db, 'allowed', excludeFromIndex: false);
    await _insertContainer(db, 'excluded', excludeFromIndex: true);
    await _insertTab(
      db,
      id: 'tab',
      containerId: 'excluded',
      url: 'https://example.com/moved',
      title: 'Moved title',
    );

    expect(await _historyTitles(db), isEmpty);

    await db.customStatement(
      "UPDATE tab SET container_id = 'allowed' WHERE id = 'tab'",
    );

    expect(await _historyTitles(db), ['Moved title']);

    await db.customStatement(
      "UPDATE tab SET container_id = 'excluded' WHERE id = 'tab'",
    );

    expect(await _historyTitles(db), isEmpty);
  });

  test(
    'excluding one container preserves duplicate URLs from allowed tabs',
    () async {
      await _insertContainer(db, 'allowed', excludeFromIndex: false);
      await _insertContainer(db, 'excluded', excludeFromIndex: false);
      await _insertTab(
        db,
        id: 'allowed-tab',
        containerId: 'allowed',
        url: 'https://example.com/shared',
        title: 'Allowed title',
        timestamp: 1,
      );
      await _insertTab(
        db,
        id: 'excluded-tab',
        containerId: 'excluded',
        url: 'https://example.com/shared',
        title: 'Excluded title',
        timestamp: 2,
      );

      expect(await _historyTitles(db), ['Excluded title']);

      await _updateContainerExclude(db, 'excluded', excludeFromIndex: true);

      expect(await _historyTitles(db), ['Allowed title']);
    },
  );

  test(
    'container exclude re-evaluation refreshes recency for same-hash duplicate URLs',
    () async {
      await _insertContainer(db, 'allowed', excludeFromIndex: false);
      await _insertContainer(db, 'later-excluded', excludeFromIndex: false);
      await _insertTab(
        db,
        id: 'later-excluded-tab',
        containerId: 'later-excluded',
        url: 'https://example.com/same-hash',
        title: 'Shared title',
        timestamp: 1,
      );
      await _insertTab(
        db,
        id: 'allowed-tab',
        containerId: 'allowed',
        url: 'https://example.com/same-hash',
        title: 'Shared title',
        timestamp: 2,
      );

      await _setAllHistoryObservedAt(db, 1);
      expect(await _historyObservedAt(db), 1);

      await _updateContainerExclude(
        db,
        'later-excluded',
        excludeFromIndex: true,
      );

      expect(await _historyTitles(db), ['Shared title']);
      expect(await _historyObservedAt(db), greaterThan(1));
    },
  );

  test(
    'container move re-evaluation refreshes recency for same-hash duplicate URLs',
    () async {
      await _insertContainer(db, 'allowed-a', excludeFromIndex: false);
      await _insertContainer(db, 'allowed-b', excludeFromIndex: false);
      await _insertContainer(db, 'excluded', excludeFromIndex: true);
      await _insertTab(
        db,
        id: 'moving-tab',
        containerId: 'allowed-a',
        url: 'https://example.com/move-same-hash',
        title: 'Shared move title',
        timestamp: 1,
      );
      await _insertTab(
        db,
        id: 'fallback-tab',
        containerId: 'allowed-b',
        url: 'https://example.com/move-same-hash',
        title: 'Shared move title',
        timestamp: 2,
      );

      await _setAllHistoryObservedAt(db, 1);
      expect(await _historyObservedAt(db), 1);

      await db.customStatement(
        "UPDATE tab SET container_id = 'excluded' WHERE id = 'moving-tab'",
      );

      expect(await _historyTitles(db), ['Shared move title']);
      expect(await _historyObservedAt(db), greaterThan(1));
    },
  );
}

Future<void> _insertContainer(
  TabDatabase db,
  String id, {
  required bool excludeFromIndex,
}) {
  return db.customStatement(
    'INSERT INTO container (id, color, order_key, is_pinned, metadata) '
    "VALUES (?, 0, ?, 0, ?)",
    [id, id, '{"excludeFromIndex":$excludeFromIndex}'],
  );
}

Future<void> _updateContainerExclude(
  TabDatabase db,
  String id, {
  required bool excludeFromIndex,
}) {
  return db.customStatement('UPDATE container SET metadata = ? WHERE id = ?', [
    '{"excludeFromIndex":$excludeFromIndex}',
    id,
  ]);
}

Future<void> _insertTab(
  TabDatabase db, {
  required String id,
  required String containerId,
  required String url,
  required String title,
  int timestamp = 1,
}) {
  return db.customStatement(
    'INSERT INTO tab (id, source, container_id, order_key, url, title, '
    'extracted_content_plain, full_content_plain, timestamp) '
    'VALUES (?, 2, ?, ?, ?, ?, ?, ?, ?)',
    [
      id,
      containerId,
      id,
      url,
      title,
      '$title extracted content',
      '$title full content',
      timestamp,
    ],
  );
}

Future<List<String?>> _historyTitles(TabDatabase db) async {
  final rows = await db
      .customSelect(
        'SELECT title FROM history ORDER BY url_canonical',
        readsFrom: {db.history},
      )
      .get();

  return [for (final row in rows) row.read<String?>('title')];
}

Future<void> _setAllHistoryObservedAt(TabDatabase db, int observedAt) {
  return db.customStatement('UPDATE history SET observed_at = ?', [observedAt]);
}

Future<int?> _historyObservedAt(TabDatabase db) async {
  final row = await db
      .customSelect(
        'SELECT CAST(observed_at AS INTEGER) AS observed_at '
        'FROM history '
        'ORDER BY url_canonical '
        'LIMIT 1',
        readsFrom: {db.history},
      )
      .getSingleOrNull();

  return row?.read<int>('observed_at');
}
