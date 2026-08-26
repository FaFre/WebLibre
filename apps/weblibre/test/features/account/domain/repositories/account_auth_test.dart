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
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:riverpod/riverpod.dart';
import 'package:supabase/supabase.dart';
import 'package:weblibre/core/secure_storage/profile_secure_keys.dart';
import 'package:weblibre/core/secure_storage/secure_storage_migration.dart';
import 'package:weblibre/features/account/data/account_secure_store.dart';
import 'package:weblibre/features/account/data/models/account_auth_state.dart';
import 'package:weblibre/features/account/data/models/account_persisted_data.dart';
import 'package:weblibre/features/account/data/models/persisted_session.dart';
import 'package:weblibre/features/account/domain/repositories/account_auth.dart';
import 'package:weblibre/features/proxy/domain/services/routed_http_client.dart';

const _a = '0199a0b1-1111-7111-8111-111111111111';
const _key = '$accountSecureBaseKey$secureKeyProfileSeparator$_a';

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

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    platform = _FakeSecureStorage();
    FlutterSecureStoragePlatform.instance = platform;
  });

  ProviderContainer containerWith(http.Client client) {
    final container = ProviderContainer(
      overrides: [
        accountSecureStoreProvider.overrideWithValue(
          AccountSecureStore(profileId: _a),
        ),
        routedHttpClientProvider.overrideWithValue(client),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Every token request is refused the way a revoked or long-expired refresh
  /// token is refused. That is the shape a restored backup arrives in.
  http.Client refusesEveryToken() => MockClient(
    (request) async => http.Response(
      jsonEncode({
        'error': 'invalid_grant',
        'error_description': 'Invalid Refresh Token',
      }),
      400,
      headers: {'content-type': 'application/json'},
    ),
  );

  /// A working sign-in: the handoff redeem hands back a session, and the token
  /// endpoint honours the refresh token it carries.
  http.Client signsIn({
    required String userId,
    required String email,
    String? accountUserId,
    String handoffRefreshToken = 'refresh',
    String? rotatedRefreshToken,
    String? refreshedUserId,
  }) {
    Map<String, dynamic> sessionWith(String refreshToken, String id) => {
      'access_token': 'access',
      'token_type': 'bearer',
      'expires_in': 3600,
      'refresh_token': refreshToken,
      'user': {
        'id': id,
        'aud': 'authenticated',
        'role': 'authenticated',
        'email': email,
        'app_metadata': <String, dynamic>{},
        'user_metadata': <String, dynamic>{'display_name': 'Me'},
        'created_at': '2026-01-01T00:00:00Z',
      },
    };

    return MockClient((request) async {
      if (request.url.path.contains('handoff-redeem')) {
        return http.Response(
          jsonEncode({
            'session': sessionWith(handoffRefreshToken, userId),
            'account': {
              'user_id': accountUserId ?? userId,
              'email': email,
              'display_name': 'Me',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      // The token endpoint. A real GoTrue with rotation on hands back a *new*
      // refresh token here and retires the one it was given.
      return http.Response(
        jsonEncode(
          sessionWith(
            rotatedRefreshToken ?? handoffRefreshToken,
            refreshedUserId ?? userId,
          ),
        ),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
  }

  void storeRecord(AccountPersistedData data) {
    platform.values[_key] = jsonEncode(data.toJson());
  }

  AccountPersistedData readRecord() => AccountPersistedData.fromJson(
    jsonDecode(platform.values[_key]!) as Map<String, dynamic>,
  );

  test('a revoked session does not take the sync key with it', () async {
    // The data-loss case. Restoring a backup old enough that its refresh token
    // has been rotated away used to end in `_store.clear()`, which deleted the
    // end-to-end sync key along with the session — and the sync key is not a
    // session artefact, it is what decrypts the user's snapshots.
    storeRecord(
      AccountPersistedData(
        session: PersistedSession(
          accessToken: 'stale',
          refreshToken: 'revoked',
          tokenType: 'bearer',
          expiresIn: 3600,
        ),
        userId: 'user-1',
        email: 'me@example.com',
        pendingCodeVerifier: 'left-over',
        syncKey: 'the-key',
      ),
    );

    final ref = containerWith(refusesEveryToken());
    final state = await ref.read(accountAuthRepositoryProvider.future);

    expect(state.status, AccountAuthStatus.error);
    // Ours, not the server's "Invalid Refresh Token" — which said nothing about
    // what to do, least of all that the sync key survived.
    expect(state.lastError, contains('Sign in again'));
    expect(state.lastError, contains('sync key'));
    expect(state.email, 'me@example.com');

    final stored = readRecord();
    expect(stored.syncKey, 'the-key');
    expect(stored.userId, 'user-1');
    expect(stored.email, 'me@example.com');
    // The session and the in-flight sign-in are what a revoked token invalidates
    // — and they are all it invalidates.
    expect(stored.session, isNull);
    expect(stored.pendingCodeVerifier, isNull);
  });

  test('the identity survives so the user is told who to sign in as', () async {
    storeRecord(
      AccountPersistedData(
        userId: 'user-1',
        email: 'me@example.com',
        syncKey: 'the-key',
      ),
    );

    final ref = containerWith(refusesEveryToken());
    final state = await ref.read(accountAuthRepositoryProvider.future);

    expect(state.status, AccountAuthStatus.signedOut);
    expect(state.email, 'me@example.com');
    expect(state.syncKey, 'the-key');
  });

  test('a record that will not decode does not break the screen', () async {
    // It used to throw out of `build`, which put the whole account screen into
    // "Failed to load account" — a dead end with no route back to a sign-in
    // button.
    platform.values[_key] = 'not json';

    final ref = containerWith(refusesEveryToken());
    final state = await ref.read(accountAuthRepositoryProvider.future);

    expect(state.status, AccountAuthStatus.signedOut);
  });

  test('a sync key with no recorded owner is not kept', () async {
    // Missing identity is not proof of ownership. No path in the app writes a
    // key without the id it was derived under, so a record like this was
    // hand-made, damaged, or restored from somewhere else — and the key is
    // re-derivable from the account password, so the safe answer costs one
    // prompt.
    storeRecord(
      AccountPersistedData(syncKey: 'unowned', pendingCodeVerifier: 'verifier'),
    );

    final ref = containerWith(signsIn(userId: 'user-1', email: 'me@x.test'));
    await ref.read(accountAuthRepositoryProvider.future);
    await ref
        .read(accountAuthRepositoryProvider.notifier)
        .handleHandoffCode('code');

    expect(readRecord().syncKey, isNull);
  });

  test('a session revoked mid-run keeps the key, a sign-out does not', () async {
    // Two paths reach the same Supabase `signedOut` event and they mean opposite
    // things. The client emits it when a refresh is definitively rejected — a
    // token revoked, a password changed on another device — which is not the
    // user asking to leave, and used to run the same blanket clear that the
    // startup path was fixed to stop doing.
    storeRecord(
      AccountPersistedData(
        session: PersistedSession(
          accessToken: 'a',
          refreshToken: 'r',
          tokenType: 'bearer',
          expiresIn: 3600,
        ),
        userId: 'user-1',
        email: 'me@x.test',
        syncKey: 'the-key',
      ),
    );

    final ref = containerWith(signsIn(userId: 'user-1', email: 'me@x.test'));
    final signedIn = await ref.read(accountAuthRepositoryProvider.future);
    expect(signedIn.status, AccountAuthStatus.signedIn);

    // Straight at the client, so this arrives the way an involuntary revocation
    // does rather than through the repository's own sign-out.
    await signedIn.client!.auth.signOut(scope: SignOutScope.local);
    await pumpEventQueue();

    expect(readRecord().syncKey, 'the-key');
    expect(readRecord().userId, 'user-1');
    expect(readRecord().session, isNull);

    final after = ref.read(accountAuthRepositoryProvider).value!;
    expect(after.status, AccountAuthStatus.error);
    expect(after.syncKey, 'the-key');
  });

  test('a deliberate sign-out still forgets everything', () async {
    storeRecord(
      AccountPersistedData(
        session: PersistedSession(
          accessToken: 'a',
          refreshToken: 'r',
          tokenType: 'bearer',
          expiresIn: 3600,
        ),
        userId: 'user-1',
        email: 'me@x.test',
        syncKey: 'the-key',
      ),
    );

    final ref = containerWith(signsIn(userId: 'user-1', email: 'me@x.test'));
    await ref.read(accountAuthRepositoryProvider.future);

    await ref.read(accountAuthRepositoryProvider.notifier).signOut();
    await pumpEventQueue();

    // Including the sync key: keeping the e2e key of an account the user chose
    // to leave is worse than making them re-enter their password. The listener
    // must not race this and put the identity back.
    expect(platform.values.containsKey(_key), isFalse);
    expect(
      ref.read(accountAuthRepositoryProvider).value!.status,
      AccountAuthStatus.signedOut,
    );
  });

  test('the rotated refresh token is stored, not the spent one', () async {
    // `setSession` with no access token *is* a refresh call: it spends the
    // handoff token and the server issues a replacement. Persisting the redeem
    // response's token instead stored one that was already dead — the run kept
    // working, because the live client holds the real one, and the next cold
    // start restored with a revoked token and signed the user out of an account
    // they had just signed into.
    storeRecord(AccountPersistedData(pendingCodeVerifier: 'verifier'));

    final ref = containerWith(
      signsIn(
        userId: 'user-1',
        email: 'me@x.test',
        handoffRefreshToken: 'spent-by-the-refresh',
        rotatedRefreshToken: 'the-live-one',
      ),
    );
    await ref.read(accountAuthRepositoryProvider.future);
    await ref
        .read(accountAuthRepositoryProvider.notifier)
        .handleHandoffCode('code');

    expect(
      ref.read(accountAuthRepositoryProvider).value!.status,
      AccountAuthStatus.signedIn,
    );
    expect(readRecord().session!.refreshToken, 'the-live-one');
  });

  test('a refreshed session for another user is refused', () async {
    // Both halves of the redeem response agree, so the earlier check passes;
    // only comparing against the session the auth server actually authenticated
    // catches this. That session is what gets stored and what the sync key is
    // bound to, so it is the one that has to be right.
    storeRecord(
      AccountPersistedData(
        userId: 'user-1',
        syncKey: 'user-1-key',
        pendingCodeVerifier: 'verifier',
      ),
    );

    final ref = containerWith(
      signsIn(
        userId: 'user-2',
        email: 'other@x.test',
        refreshedUserId: 'somebody-else',
      ),
    );
    await ref.read(accountAuthRepositoryProvider.future);
    await ref
        .read(accountAuthRepositoryProvider.notifier)
        .handleHandoffCode('code');

    expect(
      ref.read(accountAuthRepositoryProvider).value!.status,
      AccountAuthStatus.error,
    );
    // Refused before the write, so the record is untouched.
    expect(readRecord().userId, 'user-1');
    expect(readRecord().syncKey, 'user-1-key');
    expect(readRecord().session, isNull);
  });

  test('a redeem naming two different users is refused', () async {
    // The response describes the same sign-in twice. If the halves disagree, one
    // decided what was stored and the other what the screen said — with the sync
    // key bound to whichever the storage path happened to pick.
    storeRecord(
      AccountPersistedData(
        userId: 'user-1',
        syncKey: 'user-1-key',
        pendingCodeVerifier: 'verifier',
      ),
    );

    final ref = containerWith(
      signsIn(userId: 'user-1', email: 'me@x.test', accountUserId: 'user-9'),
    );
    await ref.read(accountAuthRepositoryProvider.future);
    await ref
        .read(accountAuthRepositoryProvider.notifier)
        .handleHandoffCode('code');

    final state = ref.read(accountAuthRepositoryProvider).value!;
    expect(state.status, AccountAuthStatus.error);
    // Refused before anything was written, so the record is untouched.
    expect(readRecord().userId, 'user-1');
    expect(readRecord().session, isNull);
  });

  test('a sync key is only kept for the account it was issued to', () async {
    // Reauthenticating as somebody else must not carry the previous account's
    // encryption key across: snapshots written under the new account would then
    // be readable with a key the old account also holds.
    storeRecord(
      AccountPersistedData(
        userId: 'user-1',
        syncKey: 'user-1-key',
        pendingCodeVerifier: 'verifier',
      ),
    );

    final ref = containerWith(signsIn(userId: 'user-2', email: 'other@x.test'));
    await ref.read(accountAuthRepositoryProvider.future);
    await ref
        .read(accountAuthRepositoryProvider.notifier)
        .handleHandoffCode('code');

    final state = ref.read(accountAuthRepositoryProvider).value!;
    expect(state.status, AccountAuthStatus.signedIn);
    expect(state.syncKey, isNull);
    expect(readRecord().syncKey, isNull);
    expect(readRecord().userId, 'user-2');
  });

  test('a sync key is kept when the same account signs back in', () async {
    // The everyday case, and the reason the key is not simply dropped on every
    // re-authentication: an expired token should not cost the user their
    // password prompt.
    storeRecord(
      AccountPersistedData(
        userId: 'user-1',
        syncKey: 'user-1-key',
        pendingCodeVerifier: 'verifier',
      ),
    );

    final ref = containerWith(signsIn(userId: 'user-1', email: 'me@x.test'));
    await ref.read(accountAuthRepositoryProvider.future);
    await ref
        .read(accountAuthRepositoryProvider.notifier)
        .handleHandoffCode('code');

    final state = ref.read(accountAuthRepositoryProvider).value!;
    expect(state.status, AccountAuthStatus.signedIn);
    expect(state.syncKey, 'user-1-key');
    expect(readRecord().syncKey, 'user-1-key');
    expect(readRecord().pendingCodeVerifier, isNull);
  });

  test('concurrent record writes do not overwrite each other', () async {
    // The Supabase client refreshes tokens on its own schedule, so a
    // read-modify-write of the record races with anything the user is doing.
    // Serialised writes are what stop one field's update from reverting
    // another's.
    storeRecord(
      AccountPersistedData(userId: 'user-1', pendingCodeVerifier: 'verifier'),
    );

    final ref = containerWith(signsIn(userId: 'user-1', email: 'me@x.test'));
    final repository = ref.read(accountAuthRepositoryProvider.notifier);
    await ref.read(accountAuthRepositoryProvider.future);

    await Future.wait([
      repository.setSyncKey('the-key'),
      repository.handleHandoffCode('code'),
    ]);

    final stored = readRecord();
    expect(stored.syncKey, 'the-key');
    expect(stored.email, 'me@x.test');
  });
}
