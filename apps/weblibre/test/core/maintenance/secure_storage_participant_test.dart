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
 */
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:weblibre/core/maintenance/maintenance_participant.dart';
import 'package:weblibre/core/maintenance/secure_storage_participant.dart';
import 'package:weblibre/core/secure_storage/profile_secure_store.dart';
import 'package:weblibre/core/secure_storage/secure_storage_migration.dart';

const _a = '0199a0b1-1111-7111-8111-111111111111';
const _b = '0199a0b1-2222-7222-8222-222222222222';

class _FakeSecureStorage extends FlutterSecureStoragePlatform {
  final Map<String, String> values = {};

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => values.containsKey(key);

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async => values.remove(key);

  @override
  Future<void> deleteAll({required Map<String, String> options}) async =>
      values.clear();

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async => values[key];

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => Map.of(values);

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    values[key] = value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeSecureStorage platform;
  late FlutterSecureStorage storage;
  late Directory root;
  late Directory staged;
  late Directory rollback;
  late SecureStorageParticipant participant;

  setUp(() {
    platform = _FakeSecureStorage();
    FlutterSecureStoragePlatform.instance = platform;
    storage = const FlutterSecureStorage();
    root = Directory.systemTemp.createTempSync('weblibre_secure_participant');
    staged = Directory(p.join(root.path, 'staged'))..createSync(recursive: true);
    rollback = Directory(p.join(root.path, 'rollback'))
      ..createSync(recursive: true);
    participant = SecureStorageParticipant(storage: storage);
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  MaintenanceParticipantContext contextFor(
    MaintenanceOperationKind kind, {
    String profileId = _a,
    Directory? profileDir,
  }) => MaintenanceParticipantContext(
    taskId: 'task-1',
    profileId: profileId,
    kind: kind,
    stagedDir: staged,
    rollbackDir: rollback,
    profileDir: profileDir,
  );

  /// A profile tree with a `user.db` naming [proxyIds] as its proxy profiles.
  Directory profileTreeWith(List<String> proxyIds) {
    final dir = Directory(p.join(root.path, 'profile'))
      ..createSync(recursive: true);
    final databases = Directory(p.join(dir.path, 'databases'))
      ..createSync(recursive: true);

    final db = sqlite3.open(p.join(databases.path, 'user.db'));
    db.execute('CREATE TABLE proxy_profile (id TEXT NOT NULL PRIMARY KEY)');
    for (final id in proxyIds) {
      db.execute('INSERT INTO proxy_profile (id) VALUES (?)', [id]);
    }
    db.close();

    return dir;
  }

  ProfileSecureStore storeFor(String profileId) =>
      ProfileSecureStore(profileId: profileId, storage: storage);

  group('secure storage participant', () {
    test('a backup snapshot restores the profile it came from', () async {
      await storeFor(_a).write(accountSecureBaseKey, 'a-session');

      await participant.prepare(contextFor(MaintenanceOperationKind.backup));

      // The profile is wiped between the backup and the restore, as a
      // restore-over would do.
      await storeFor(_a).deleteAllOwned();

      final restore = contextFor(MaintenanceOperationKind.restore);
      await participant.prepare(restore);
      await participant.apply(restore);
      await participant.verify(restore);

      expect(await storeFor(_a).read(accountSecureBaseKey), 'a-session');
    });

    test('a restore leaves other profiles alone', () async {
      await storeFor(_a).write(accountSecureBaseKey, 'a-session');
      await storeFor(_b).write(accountSecureBaseKey, 'b-session');

      await participant.prepare(contextFor(MaintenanceOperationKind.backup));
      final restore = contextFor(MaintenanceOperationKind.restore);
      await participant.prepare(restore);
      await participant.apply(restore);

      expect(await storeFor(_b).read(accountSecureBaseKey), 'b-session');
    });

    test('an archive with no snapshot leaves credentials alone', () async {
      // Such an archive predates this participant. Wiping would sign the profile
      // out of an account the archive never described.
      await storeFor(_a).write(accountSecureBaseKey, 'a-session');

      final restore = contextFor(MaintenanceOperationKind.restore);
      await participant.prepare(restore);
      await participant.apply(restore);
      await participant.verify(restore);

      expect(await storeFor(_a).read(accountSecureBaseKey), 'a-session');
    });

    test('rollback puts the live credentials back', () async {
      await storeFor(_a).write(accountSecureBaseKey, 'live');

      final restore = contextFor(MaintenanceOperationKind.restore);
      await participant.prepare(restore);

      // The archive carried a different session, and apply installed it.
      final archived = File(
        p.join(staged.path, participant.id, 'secure_storage.json'),
      );
      await archived.parent.create(recursive: true);
      await archived.writeAsString('{"$accountSecureBaseKey":"from-archive"}');
      await participant.apply(restore);
      expect(await storeFor(_a).read(accountSecureBaseKey), 'from-archive');

      await participant.rollback(restore);

      expect(await storeFor(_a).read(accountSecureBaseKey), 'live');
    });

    test('rollback data does not live in the tree a restore replaces', () async {
      // The undo file must survive the staged tree being renamed over the
      // profile, so it belongs in the rollback workspace.
      await storeFor(_a).write(accountSecureBaseKey, 'live');

      await participant.prepare(contextFor(MaintenanceOperationKind.restore));

      expect(
        File(
          p.join(rollback.path, participant.id, 'secure_storage.rollback.json'),
        ).existsSync(),
        isTrue,
      );
      expect(
        Directory(p.join(staged.path, participant.id)).existsSync(),
        isFalse,
      );
    });

    test("delete removes only the target profile's credentials", () async {
      await storeFor(_a).write(accountSecureBaseKey, 'a-session');
      await storeFor(_b).write(accountSecureBaseKey, 'b-session');

      final delete = contextFor(MaintenanceOperationKind.delete);
      await participant.prepare(delete);
      await participant.apply(delete);
      await participant.verify(delete);

      expect(await storeFor(_a).readAllOwned(), isEmpty);
      expect(await storeFor(_b).read(accountSecureBaseKey), 'b-session');
    });

    test('a delete that left something behind fails verification', () async {
      await storeFor(_a).write(accountSecureBaseKey, 'a-session');

      final delete = contextFor(MaintenanceOperationKind.delete);
      await participant.prepare(delete);
      // apply deliberately skipped

      expect(() => participant.verify(delete), throwsStateError);
    });

    test('finalize drops the undo data', () async {
      final delete = contextFor(MaintenanceOperationKind.delete);
      await storeFor(_a).write(accountSecureBaseKey, 'a-session');
      await participant.prepare(delete);

      await participant.finalizeWork(delete);

      expect(
        File(
          p.join(rollback.path, participant.id, 'secure_storage.rollback.json'),
        ).existsSync(),
        isFalse,
      );
    });

    test('a profile with nothing stored is a valid empty capture', () async {
      final backup = contextFor(MaintenanceOperationKind.backup);

      await participant.prepare(backup);

      expect(
        File(p.join(staged.path, participant.id, 'secure_storage.json'))
            .readAsStringSync(),
        '{}',
      );
    });
  });

  group('records this profile owns but never claimed', () {
    // `migrateUnqualifiedSecureRecords` only ever runs for the profile a process
    // activated. A profile backed up or deleted before it was ever opened on
    // this build still has its proxy credentials under unqualified keys, which
    // the `@p:` enumeration cannot see — so they were left out of archives and
    // orphaned on delete.

    test('a backup archives them under their owned key', () async {
      platform.values['${proxySecretKeyPrefix}proxy-1'] = 'secret-1';
      final tree = profileTreeWith(['proxy-1']);

      await participant.prepare(
        contextFor(MaintenanceOperationKind.backup, profileDir: tree),
      );

      final snapshot = File(
        p.join(staged.path, 'secureStorage', 'secure_storage.json'),
      ).readAsStringSync();
      // Stored under the base name, so restoring the archive installs it
      // properly attributed rather than back into the legacy slot.
      expect(snapshot, contains('${proxySecretKeyPrefix}proxy-1'));
      expect(snapshot, contains('secret-1'));
    });

    test('a delete removes them', () async {
      platform.values['${proxySecretKeyPrefix}proxy-1'] = 'secret-1';
      final tree = profileTreeWith(['proxy-1']);

      final context = contextFor(
        MaintenanceOperationKind.delete,
        profileDir: tree,
      );
      await participant.prepare(context);
      await participant.apply(context);

      expect(platform.values, isEmpty);
    });

    test("another profile's legacy secret is left alone", () async {
      // Ownership is a lookup, never a guess: this profile's database does not
      // name proxy-2, so proxy-2 is not its business.
      platform.values['${proxySecretKeyPrefix}proxy-1'] = 'mine';
      platform.values['${proxySecretKeyPrefix}proxy-2'] = 'theirs';
      final tree = profileTreeWith(['proxy-1']);

      final context = contextFor(
        MaintenanceOperationKind.delete,
        profileDir: tree,
      );
      await participant.prepare(context);
      await participant.apply(context);

      expect(platform.values['${proxySecretKeyPrefix}proxy-2'], 'theirs');
    });

    test('an unreadable database claims and deletes nothing', () async {
      // "Could not look" is not "nothing was there". Deleting on the strength of
      // the second would destroy credentials whose ownership was never
      // established.
      platform.values['${proxySecretKeyPrefix}proxy-1'] = 'secret-1';
      final tree = Directory(p.join(root.path, 'broken'))
        ..createSync(recursive: true);
      Directory(p.join(tree.path, 'databases')).createSync();
      File(p.join(tree.path, 'databases', 'user.db'))
          .writeAsStringSync('not a database');

      final context = contextFor(
        MaintenanceOperationKind.delete,
        profileDir: tree,
      );
      await participant.prepare(context);
      await participant.apply(context);

      expect(platform.values['${proxySecretKeyPrefix}proxy-1'], 'secret-1');
    });

    test('no profile tree means nothing is claimed', () async {
      platform.values['${proxySecretKeyPrefix}proxy-1'] = 'secret-1';

      final context = contextFor(MaintenanceOperationKind.delete);
      await participant.prepare(context);
      await participant.apply(context);

      expect(platform.values['${proxySecretKeyPrefix}proxy-1'], 'secret-1');
    });
  
    test('a live scoped record is never overwritten by a stale legacy one', () async {
      // Both can exist: the migration writes the scoped key and *then* deletes
      // the legacy one, so a process that died between those steps leaves both
      // behind. A secret changed since then is current under the scoped key and
      // stale under the legacy one.
      platform.values['${proxySecretKeyPrefix}proxy-1'] = 'stale';
      await storeFor(_a).write('${proxySecretKeyPrefix}proxy-1', 'current');
      final tree = profileTreeWith(['proxy-1']);

      await participant.prepare(
        contextFor(MaintenanceOperationKind.backup, profileDir: tree),
      );

      final snapshot = jsonDecode(
        File(
          p.join(staged.path, 'secureStorage', 'secure_storage.json'),
        ).readAsStringSync(),
      ) as Map<String, dynamic>;

      // The scoped record is what ProfileSecureStore reads, so it is the live
      // value by definition.
      expect(snapshot['${proxySecretKeyPrefix}proxy-1'], 'current');
    });

    test('a legacy record still fills a gap the scoped keys do not cover', () async {
      platform.values['${proxySecretKeyPrefix}proxy-1'] = 'only-copy';
      final tree = profileTreeWith(['proxy-1']);

      await participant.prepare(
        contextFor(MaintenanceOperationKind.backup, profileDir: tree),
      );

      final snapshot = jsonDecode(
        File(
          p.join(staged.path, 'secureStorage', 'secure_storage.json'),
        ).readAsStringSync(),
      ) as Map<String, dynamic>;

      expect(snapshot['${proxySecretKeyPrefix}proxy-1'], 'only-copy');
    });
  });
}
