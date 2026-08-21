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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/secure_storage/profile_secure_keys.dart';
import 'package:weblibre/core/secure_storage/profile_secure_store.dart';
import 'package:weblibre/core/secure_storage/secure_storage_migration.dart';

const _a = '0199a0b1-1111-7111-8111-111111111111';
const _b = '0199a0b1-2222-7222-8222-222222222222';
const _proxyOfA = '3f1c2b7a-1111-4111-8111-aaaaaaaaaaaa';
const _proxyOfB = '3f1c2b7a-2222-4222-8222-bbbbbbbbbbbb';

/// In-memory stand-in for the platform channel.
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
  }) async {
    values.remove(key);
  }

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    values.clear();
  }

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

  setUp(() {
    platform = _FakeSecureStorage();
    FlutterSecureStoragePlatform.instance = platform;
    storage = const FlutterSecureStorage();
  });

  Future<SecureStorageMigrationResult> migrate({
    String profileId = _a,
    Set<String> owned = const {},
  }) => migrateUnqualifiedSecureRecords(
    profileId: profileId,
    ownedProxyProfileIds: owned,
    storage: storage,
  );

  group('secure storage migration', () {
    test('reports the account record without attributing it', () async {
      // No profile database holds account state, so there is no evidence of who
      // owns this. Handing it to whichever profile boots first would freeze the
      // leak in place rather than fix it.
      platform.values[accountSecureBaseKey] = 'session';

      final result = await migrate();

      expect(result.parkedAccountRecord, isTrue);
    });

    test('the account record is left exactly where it was', () async {
      // Renaming it is not free. Moving it to an `@unattributed` key made it
      // unreadable to any build that had not learned the new name, so a user who
      // went back a version was signed out with their session filed under
      // something that version had never heard of.
      platform.values[accountSecureBaseKey] = 'session';

      await migrate();

      expect(platform.values[accountSecureBaseKey], 'session');
      expect(
        platform.values.containsKey(
          '$accountSecureBaseKey$secureKeyUnattributedSuffix',
        ),
        isFalse,
      );
    });

    test('the unclaimed account record is not readable by any profile', () async {
      platform.values[accountSecureBaseKey] = 'session';
      await migrate();

      final storeA = ProfileSecureStore(profileId: _a, storage: storage);
      final storeB = ProfileSecureStore(profileId: _b, storage: storage);

      expect(await storeA.read(accountSecureBaseKey), isNull);
      expect(await storeB.read(accountSecureBaseKey), isNull);
    });

    test('nothing is destroyed', () async {
      platform.values[accountSecureBaseKey] = 'session';

      await migrate();

      expect(platform.values.values, contains('session'));
    });

    test('a record parked by an earlier build is left alone too', () async {
      // Someone who ran an earlier revision of this branch already has the
      // record under the parked key. Both shapes have to stay claimable.
      platform.values['$accountSecureBaseKey$secureKeyUnattributedSuffix'] =
          'session';

      await migrate();

      expect(
        platform.values['$accountSecureBaseKey$secureKeyUnattributedSuffix'],
        'session',
      );
    });

    test('claims a proxy secret this profile actually owns', () async {
      platform.values['$proxySecretKeyPrefix$_proxyOfA'] = 'secret-a';

      final result = await migrate(owned: {_proxyOfA});

      expect(result.claimedProxySecrets, 1);
      final store = ProfileSecureStore(profileId: _a, storage: storage);
      expect(
        await store.read('$proxySecretKeyPrefix$_proxyOfA'),
        'secret-a',
      );
      expect(
        platform.values.containsKey('$proxySecretKeyPrefix$_proxyOfA'),
        isFalse,
      );
    });

    test("leaves another profile's proxy secret alone", () async {
      // The ownership test is the proxy profile row in this profile's database.
      // Without it, the first profile to launch would collect every profile's
      // proxy credentials.
      platform.values['$proxySecretKeyPrefix$_proxyOfB'] = 'secret-b';

      final result = await migrate(owned: {_proxyOfA});

      expect(result.claimedProxySecrets, 0);
      expect(result.leftForOtherProfiles, 1);
      expect(platform.values['$proxySecretKeyPrefix$_proxyOfB'], 'secret-b');
    });

    test('the other profile claims it when it runs', () async {
      platform.values['$proxySecretKeyPrefix$_proxyOfB'] = 'secret-b';

      await migrate(profileId: _a, owned: {_proxyOfA});
      final result = await migrate(profileId: _b, owned: {_proxyOfB});

      expect(result.claimedProxySecrets, 1);
      final store = ProfileSecureStore(profileId: _b, storage: storage);
      expect(await store.read('$proxySecretKeyPrefix$_proxyOfB'), 'secret-b');
    });

    test('is a no-op the second time', () async {
      // Exactly-once without a marker: the records it moves are the records it
      // consumes.
      platform.values[accountSecureBaseKey] = 'session';
      platform.values['$proxySecretKeyPrefix$_proxyOfA'] = 'secret-a';

      await migrate(owned: {_proxyOfA});
      final before = Map.of(platform.values);
      final second = await migrate(owned: {_proxyOfA});

      expect(second.changedAnything, isFalse);
      expect(platform.values, before);
    });

    test('leaves already-qualified records untouched', () async {
      final key = profileScopedSecureKey(accountSecureBaseKey, _a);
      platform.values[key] = 'session';

      final result = await migrate();

      expect(result.changedAnything, isFalse);
      expect(platform.values[key], 'session');
    });
  });

  group('profile secure store', () {
    test('sees only its own records', () async {
      final storeA = ProfileSecureStore(profileId: _a, storage: storage);
      final storeB = ProfileSecureStore(profileId: _b, storage: storage);

      await storeA.write(accountSecureBaseKey, 'a-session');
      await storeB.write(accountSecureBaseKey, 'b-session');

      expect(await storeA.read(accountSecureBaseKey), 'a-session');
      expect(await storeB.read(accountSecureBaseKey), 'b-session');
      expect(await storeA.readAllOwned(), {accountSecureBaseKey: 'a-session'});
    });

    test('deleting a profile leaves the others intact', () async {
      // What the delete participant relies on.
      final storeA = ProfileSecureStore(profileId: _a, storage: storage);
      final storeB = ProfileSecureStore(profileId: _b, storage: storage);
      await storeA.write(accountSecureBaseKey, 'a-session');
      await storeB.write(accountSecureBaseKey, 'b-session');

      await storeA.deleteAllOwned();

      expect(await storeA.readAllOwned(), isEmpty);
      expect(await storeB.read(accountSecureBaseKey), 'b-session');
    });

    test('replacing removes records the snapshot did not carry', () async {
      // A restore has to be able to represent "this profile had no account";
      // leaving the old credential would sign it into something the archive
      // never described.
      final store = ProfileSecureStore(profileId: _a, storage: storage);
      await store.write(accountSecureBaseKey, 'stale');
      await store.write('$proxySecretKeyPrefix$_proxyOfA', 'secret');

      await store.replaceAllOwned({'$proxySecretKeyPrefix$_proxyOfA': 'secret'});

      expect(await store.read(accountSecureBaseKey), isNull);
      expect(await store.read('$proxySecretKeyPrefix$_proxyOfA'), 'secret');
    });

    test('a parked record is not owned by anyone', () async {
      platform.values['$accountSecureBaseKey$secureKeyUnattributedSuffix'] = 'x';

      final store = ProfileSecureStore(profileId: _a, storage: storage);

      expect(await store.readAllOwned(), isEmpty);
    });
  });
}
