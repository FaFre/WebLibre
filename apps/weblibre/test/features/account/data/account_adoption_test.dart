import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/secure_storage/profile_secure_keys.dart';
import 'package:weblibre/core/secure_storage/secure_storage_migration.dart';
import 'package:weblibre/features/account/data/account_adoption.dart';

const _a = '0199a0b1-1111-7111-8111-111111111111';
const _parked = '$accountSecureBaseKey$secureKeyUnattributedSuffix';

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
  }) async => values[key] = value;
}

void main() {
  late _FakeSecureStorage platform;
  late FlutterSecureStorage storage;

  final session = jsonEncode({'email': 'me@example.com', 'syncKey': 'k'});

  setUp(() {
    platform = _FakeSecureStorage();
    FlutterSecureStoragePlatform.instance = platform;
    storage = const FlutterSecureStorage();
  });

  test('a legacy record is offered, named by its address', () async {
    platform.values[accountSecureBaseKey] = session;

    final found = await findUnclaimedAccountRecord(
      profileId: _a,
      storage: storage,
    );

    // Naming it is the point: a choice about a credential the user cannot
    // identify is not a choice.
    expect(found?.label, 'me@example.com');
    expect(found?.storageKey, accountSecureBaseKey);
    expect(found?.isUsable, isTrue);
  });

  test('a record parked by an earlier build is offered too', () async {
    platform.values[_parked] = session;

    final found = await findUnclaimedAccountRecord(
      profileId: _a,
      storage: storage,
    );

    expect(found?.storageKey, _parked);
  });

  test('an unparseable record is still offered, just unnamed', () async {
    // Staying quiet about it would sign the user out for a reason they could
    // never discover.
    platform.values[accountSecureBaseKey] = 'not json';

    final found = await findUnclaimedAccountRecord(
      profileId: _a,
      storage: storage,
    );

    expect(found, isNotNull);
    expect(found!.label, isNotEmpty);
  });

  test('an unparseable record is offered but not as adoptable', () async {
    // `AccountSecureStore.read` parses it with the same call, so filing it under
    // this profile would install a blob the app throws on for the life of the
    // profile. Shown, so the user can clear it; never adopted.
    platform.values[accountSecureBaseKey] = 'not json';

    final found = (await findUnclaimedAccountRecord(
      profileId: _a,
      storage: storage,
    ))!;

    expect(found.isUsable, isFalse);
    await expectLater(
      adoptAccountRecord(found, profileId: _a, storage: storage),
      throwsStateError,
    );
    // And nothing moved: the record is still exactly where it was.
    expect(platform.values[accountSecureBaseKey], 'not json');
    expect(
      platform.values.containsKey(
        profileScopedSecureKey(accountSecureBaseKey, _a),
      ),
      isFalse,
    );
  });

  test('a profile that is already signed in is offered nothing', () async {
    // Adopting here would propose replacing a session the user is using.
    platform.values[accountSecureBaseKey] = session;
    platform.values[profileScopedSecureKey(accountSecureBaseKey, _a)] = 'live';

    expect(
      await findUnclaimedAccountRecord(profileId: _a, storage: storage),
      isNull,
    );
  });

  test('nothing to claim means nothing offered', () async {
    expect(
      await findUnclaimedAccountRecord(profileId: _a, storage: storage),
      isNull,
    );
  });

  test('adopting files it under the profile and stops offering it', () async {
    platform.values[accountSecureBaseKey] = session;
    final found = (await findUnclaimedAccountRecord(
      profileId: _a,
      storage: storage,
    ))!;

    await adoptAccountRecord(found, profileId: _a, storage: storage);

    expect(
      platform.values[profileScopedSecureKey(accountSecureBaseKey, _a)],
      session,
    );
    expect(platform.values.containsKey(accountSecureBaseKey), isFalse);
    expect(
      await findUnclaimedAccountRecord(profileId: _a, storage: storage),
      isNull,
    );
  });

  test('adoption preserves the record byte for byte', () async {
    // Re-filed verbatim rather than round-tripped through a model that may not
    // know every field the session carries.
    const exotic =
        '{"session":{"access_token":"a","refresh_token":"r",'
        '"token_type":"bearer","expires_in":3600},"unknownFutureField":1}';
    platform.values[accountSecureBaseKey] = exotic;

    final found = (await findUnclaimedAccountRecord(
      profileId: _a,
      storage: storage,
    ))!;
    await adoptAccountRecord(found, profileId: _a, storage: storage);

    expect(
      platform.values[profileScopedSecureKey(accountSecureBaseKey, _a)],
      exotic,
    );
  });

  test(
    'adoption refuses to overwrite a sign-in that arrived meanwhile',
    () async {
      // The card can sit on screen indefinitely while the user thinks about it,
      // and a normal sign-in — or a `weblibre://account/callback` — can land in
      // between. The record being answered about is old; the profile's own
      // sign-in would not be.
      platform.values[accountSecureBaseKey] = session;
      final found = (await findUnclaimedAccountRecord(
        profileId: _a,
        storage: storage,
      ))!;

      platform.values[profileScopedSecureKey(accountSecureBaseKey, _a)] =
          'signed-in-since';

      await expectLater(
        adoptAccountRecord(found, profileId: _a, storage: storage),
        throwsStateError,
      );
      expect(
        platform.values[profileScopedSecureKey(accountSecureBaseKey, _a)],
        'signed-in-since',
      );
      // And the offered record is left where it was, not half-moved.
      expect(platform.values[accountSecureBaseKey], session);
    },
  );

  test('discarding removes it', () async {
    platform.values[accountSecureBaseKey] = session;
    final found = (await findUnclaimedAccountRecord(
      profileId: _a,
      storage: storage,
    ))!;

    await discardAccountRecord(found, storage: storage);

    expect(platform.values, isEmpty);
  });
}
