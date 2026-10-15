import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/database/riverpod_storage.dart';

void main() {
  late UserDatabase db;

  setUp(() {
    db = UserDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
        },
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  const options = StorageOptions();

  test('reads from the database until preloaded', () async {
    await RiverpodStorage(db).write('key', 'saved', options);

    final storage = RiverpodStorage(db);
    final read = storage.read('key');

    expect(read, isA<Future<PersistedData<String>?>>());
    expect((await read)?.data, 'saved');
  });

  test('answers synchronously once preloaded', () async {
    await RiverpodStorage(db).write('key', 'saved', options);

    final storage = RiverpodStorage(db);
    await storage.preload();

    // Synchronous is the point: `persist()` then applies the value inside the
    // provider's first build, so the default never reaches a frame (#665).
    final read = storage.read('key');
    expect(read, isNot(isA<Future<Object?>>()));
    expect((read as PersistedData<String>?)?.data, 'saved');
    expect(storage.read('missing'), isNull);
  });

  test('a write made while preloading is not lost', () async {
    await RiverpodStorage(db).write('written', 'old', options);
    await RiverpodStorage(db).write('deleted', 'old', options);

    final storage = RiverpodStorage(db);
    final preload = storage.preload();

    // Queued behind the preload's query, so its result cannot contain them.
    unawaited(storage.write('written', 'new', options));
    unawaited(storage.delete('deleted'));

    await preload;

    expect((storage.read('written') as PersistedData<String>?)?.data, 'new');
    expect(storage.read('deleted'), isNull);
  });

  test('writes reach the database as well as memory', () async {
    final storage = RiverpodStorage(db);
    await storage.preload();

    await storage.write(
      'key',
      'value',
      const StorageOptions(cacheTime: StorageCacheTime(Duration(days: 7))),
    );

    final cached = storage.read('key') as PersistedData<String>?;
    expect(cached?.data, 'value');
    expect(cached?.expireAt, isNotNull);

    final fresh = RiverpodStorage(db);
    expect((await fresh.read('key'))?.data, 'value');

    await storage.delete('key');
    expect(storage.read('key'), isNull);
    expect(await fresh.read('key'), isNull);
  });
}
