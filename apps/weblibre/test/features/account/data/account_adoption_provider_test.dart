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

import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/core/secure_storage/profile_secure_keys.dart';
import 'package:weblibre/core/secure_storage/secure_storage_migration.dart';
import 'package:weblibre/features/account/data/account_adoption.dart';
import 'package:weblibre/features/account/data/account_adoption_provider.dart';
import 'package:weblibre/features/account/data/account_secure_store.dart';
import 'package:weblibre/features/account/data/models/account_auth_state.dart';
import 'package:weblibre/features/account/domain/repositories/account_auth.dart';

const _a = '0199a0b1-1111-7111-8111-111111111111';

/// Every call goes through a real async gap, which is the whole point.
///
/// The defect this file guards was a lifecycle one: the notifier was
/// auto-disposed, the tile only ever `read` it, and Riverpod disposes such an
/// element at the end of the next event loop — so the very first `await` inside
/// the operation outlived the `ref` that the rest of it depended on. A fake that
/// completes synchronously would never reproduce it.
class _SlowSecureStorage extends FlutterSecureStoragePlatform {
  final Map<String, String> values = {};

  Future<T> _slowly<T>(T Function() action) =>
      Future.delayed(const Duration(milliseconds: 10), action);

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) => _slowly(() => values.containsKey(key));

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) => _slowly(() => values.remove(key));

  @override
  Future<void> deleteAll({required Map<String, String> options}) =>
      _slowly(values.clear);

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) => _slowly(() => values[key]);

  @override
  Future<Map<String, String>> readAll({required Map<String, String> options}) =>
      _slowly(() => Map.of(values));

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) => _slowly(() => values[key] = value);
}

void main() {
  late _SlowSecureStorage platform;

  // No session, so restoring the adopted record needs no network: the point here
  // is the plumbing between the button and the store, not the sign-in.
  final record = jsonEncode({
    'email': 'me@example.com',
    'userId': 'user-1',
    'syncKey': 'k',
  });

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    platform = _SlowSecureStorage();
    FlutterSecureStoragePlatform.instance = platform;
  });

  ProviderContainer container() {
    final container = ProviderContainer(
      overrides: [
        adoptingProfileIdProvider.overrideWithValue(_a),
        accountSecureStoreProvider.overrideWithValue(
          AccountSecureStore(profileId: _a),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<UnclaimedAccountRecord> offered(ProviderContainer ref) async {
    final found = await ref.read(unclaimedAccountRecordProvider.future);
    return found!;
  }

  test('adopting from a bare read still finishes the whole operation', () async {
    // The reported bug, exactly: the tile calls this through
    // `ref.read(...notifier)` and holds no subscription of its own. Every step
    // after the first await used to run against a disposed ref, so the record
    // moved and nothing else did — a button that appeared to do nothing.
    platform.values[accountSecureBaseKey] = record;

    final ref = container();
    final unclaimed = await offered(ref);

    await ref.read(accountAdoptionProvider.notifier).adopt(unclaimed);

    expect(
      ref.read(accountAdoptionProvider),
      isA<AsyncData<void>>(),
      reason: 'the operation reported success rather than throwing off-stack',
    );
    expect(
      platform.values[profileScopedSecureKey(accountSecureBaseKey, _a)],
      record,
    );
    expect(platform.values.containsKey(accountSecureBaseKey), isFalse);
  });

  test('the card stops being offered once the record is claimed', () async {
    platform.values[accountSecureBaseKey] = record;

    final ref = container();
    final unclaimed = await offered(ref);
    await ref.read(accountAdoptionProvider.notifier).adopt(unclaimed);

    expect(await ref.read(unclaimedAccountRecordProvider.future), isNull);
  });

  test('the account state is re-read, not left stale', () async {
    platform.values[accountSecureBaseKey] = record;

    final ref = container();
    // Built before the adoption, so it holds the pre-adoption answer — which is
    // what the settings screen is showing while the card is on it: this profile
    // owns nothing, so it knows nothing.
    final before = await ref.read(accountAuthRepositoryProvider.future);
    expect(before.status, AccountAuthStatus.signedOut);
    expect(before.email, isNull);
    expect(before.syncKey, isNull);

    await ref.read(accountAdoptionProvider.notifier).adopt(await offered(ref));

    // Re-read, not left stale. The record carries no session, so this is still
    // signed out — but it is now *this profile's* record, identity and sync key
    // included, which is what tells the user who to sign back in as.
    final after = await ref.read(accountAuthRepositoryProvider.future);
    expect(after.status, AccountAuthStatus.signedOut);
    expect(after.email, 'me@example.com');
    expect(
      after.syncKey,
      'k',
      reason: 'the sync key survives a record with no usable session',
    );
  });

  test('a second tap while the first is in flight is ignored', () async {
    platform.values[accountSecureBaseKey] = record;

    final ref = container();
    final unclaimed = await offered(ref);

    final first = ref.read(accountAdoptionProvider.notifier).adopt(unclaimed);
    final second = ref.read(accountAdoptionProvider.notifier).adopt(unclaimed);
    await Future.wait([first, second]);

    // The second call would otherwise re-run `adoptAccountRecord` against a key
    // the first one has already deleted.
    expect(ref.read(accountAdoptionProvider), isA<AsyncData<void>>());
    expect(
      platform.values[profileScopedSecureKey(accountSecureBaseKey, _a)],
      record,
    );
  });

  test('discarding reports failure instead of throwing off-stack', () async {
    // An unreadable record is offered for removal only; adopting it is refused,
    // and the refusal has to arrive as state the tile can render.
    platform.values[accountSecureBaseKey] = 'not json';

    final ref = container();
    final unclaimed = await offered(ref);
    expect(unclaimed.isUsable, isFalse);

    await ref.read(accountAdoptionProvider.notifier).adopt(unclaimed);
    expect(ref.read(accountAdoptionProvider), isA<AsyncError<void>>());

    await ref.read(accountAdoptionProvider.notifier).discard(unclaimed);
    expect(ref.read(accountAdoptionProvider), isA<AsyncData<void>>());
    expect(platform.values, isEmpty);
  });
}
