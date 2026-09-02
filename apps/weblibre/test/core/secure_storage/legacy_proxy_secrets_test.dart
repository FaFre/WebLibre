import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:weblibre/core/secure_storage/legacy_proxy_secrets.dart';

void main() {
  late Directory profileDir;

  setUp(() async {
    profileDir = await Directory.systemTemp.createTemp('weblibre_proxy_own');
  });

  tearDown(() async {
    if (profileDir.existsSync()) {
      await profileDir.delete(recursive: true);
    }
  });

  File userDb() {
    final databases = Directory(p.join(profileDir.path, 'databases'))
      ..createSync(recursive: true);
    return File(p.join(databases.path, 'user.db'));
  }

  void writeProxyRows(List<String> ids) {
    final db = sqlite3.open(userDb().path);
    db.execute('''
      CREATE TABLE proxy_profile (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        config_json TEXT NOT NULL
      )
    ''');
    for (final id in ids) {
      db.execute(
        'INSERT INTO proxy_profile (id, name, type, config_json) '
        "VALUES (?, 'p', 'socks', '{}')",
        [id],
      );
    }
    db.close();
  }

  test('reads the proxy ids this profile owns', () async {
    writeProxyRows(['proxy-1', 'proxy-2']);

    final ownership = await readProxyProfileIds(profileDir);

    expect(ownership.readable, isTrue);
    expect(ownership.proxyProfileIds, {'proxy-1', 'proxy-2'});
  });

  test(
    'a profile with no proxies reads as an empty, complete answer',
    () async {
      writeProxyRows([]);

      final ownership = await readProxyProfileIds(profileDir);

      expect(ownership.readable, isTrue);
      expect(ownership.proxyProfileIds, isEmpty);
    },
  );

  test('no database at all is empty, not unreadable', () async {
    // There can be no proxy rows if the profile never opened its database.
    final ownership = await readProxyProfileIds(profileDir);

    expect(ownership.readable, isTrue);
    expect(ownership.proxyProfileIds, isEmpty);
  });

  test('a database without the table is unreadable, not empty', () async {
    // An older schema. "We could not look" must not be mistaken for "nothing was
    // there" — a caller that deletes on the strength of the second would be
    // acting on an absence it never established.
    final db = sqlite3.open(userDb().path);
    db.execute('CREATE TABLE something_else (id TEXT)');
    db.close();

    final ownership = await readProxyProfileIds(profileDir);

    expect(ownership.readable, isFalse);
    expect(ownership.proxyProfileIds, isEmpty);
  });

  test('a corrupt database is unreadable', () async {
    userDb().writeAsStringSync('this is not a database');

    final ownership = await readProxyProfileIds(profileDir);

    expect(ownership.readable, isFalse);
  });

  test('reading leaves no write-ahead files behind', () async {
    // Read-only, so it cannot run a migration or leave a `-wal` in a tree that
    // is about to be archived or deleted.
    writeProxyRows(['proxy-1']);
    await readProxyProfileIds(profileDir);

    final names = Directory(
      p.join(profileDir.path, 'databases'),
    ).listSync().map((entity) => p.basename(entity.path)).toList();
    expect(names, ['user.db']);
  });
}
