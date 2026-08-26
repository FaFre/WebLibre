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
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/secure_storage/profile_secure_store.dart';
import 'package:weblibre/core/secure_storage/secure_storage_migration.dart';
import 'package:weblibre/features/account/data/models/account_persisted_data.dart';

part 'account_secure_store.g.dart';

/// Encapsulates persistence of [AccountPersistedData] in
/// `flutter_secure_storage`. Kept as a thin wrapper so the auth repository
/// stays focused on state-machine logic and can be exercised with a fake
/// store in tests.
///
/// Storage holds the Supabase refresh token, the end-to-end sync key, and
/// the in-flight PKCE verifier — all sensitive. We rely on the default
/// Android backend, which (as of flutter_secure_storage v10) uses a custom
/// AES-GCM cipher with a Keystore-wrapped key per-app; the older
/// `encryptedSharedPreferences` option was deprecated when Google
/// deprecated the Jetpack Security library, with automatic migration on
/// first read.
class AccountSecureStore {
  /// Scoped to the profile, not the app.
  ///
  /// It used to be a single bare `account_auth_data` record, which meant one
  /// account session — refresh token, e2e sync key and all — was shared by every
  /// profile on the device: signing in on one signed in on all of them. Secure
  /// storage has no notion of a profile, so the key is the only thing that can
  /// carry the boundary.
  final ProfileSecureStore _store;

  AccountSecureStore({required String profileId, FlutterSecureStorage? storage})
    : _store = ProfileSecureStore(profileId: profileId, storage: storage);

  /// Serialises [update] so two read-modify-writes cannot interleave.
  ///
  /// The record is one JSON blob holding independent things — the session, the
  /// sync key, the in-flight PKCE verifier — and every writer had to read the
  /// whole blob, change its own field and write the whole blob back. Those
  /// writers are not all user-driven: the Supabase client's own refresh timer
  /// fires `_persistSessionRefresh` whenever it likes, so a token refresh landing
  /// between another writer's read and write silently reverted that writer's
  /// field, or was itself reverted — a refreshed token thrown away, which is a
  /// sign-out the next time the app starts.
  Future<void> _writeQueue = Future<void>.value();

  Future<AccountPersistedData> read() async {
    // Deliberately *not* guarded: a platform failure (a Keystore that is
    // temporarily unavailable, a channel error) is not an empty account, and
    // treating it as one would let the very next write replace a live session
    // with a blank record. It propagates, and the caller retries.
    final json = await _store.read(accountSecureBaseKey);
    if (json == null) return AccountPersistedData();

    try {
      return AccountPersistedData.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } catch (error, stackTrace) {
      // Content that does not decode, on the other hand, is unusable by
      // definition — nothing in the app can turn it back into a session. Letting
      // it throw took the whole account screen with it ("Failed to load
      // account"), from which there is no way back to a sign-in button. An empty
      // record leaves the user somewhere they can act.
      logger.w(
        'Stored account record could not be decoded; treating it as empty',
        error: error,
        stackTrace: stackTrace,
      );
      return AccountPersistedData();
    }
  }

  Future<void> write(AccountPersistedData data) {
    return _store.write(accountSecureBaseKey, jsonEncode(data.toJson()));
  }

  /// Read, transform, write — with no other writer able to slip in between.
  ///
  /// Every partial mutation of the record should go through this rather than
  /// through [read] followed by [write].
  Future<AccountPersistedData> update(
    AccountPersistedData Function(AccountPersistedData current) transform,
  ) {
    return _enqueue(() async {
      final next = transform(await read());
      await write(next);
      return next;
    });
  }

  Future<void> clear() {
    return _enqueue(() => _store.delete(accountSecureBaseKey));
  }

  /// Drops the session and any in-flight sign-in, keeping who the account is and
  /// the end-to-end sync key.
  ///
  /// The distinction the old blanket [clear] did not make. A refresh token that
  /// the server no longer honours says nothing about the sync key, which is not
  /// a session artefact but the thing that decrypts the user's snapshots — and
  /// it is the identity, kept here alongside it, that later lets a re-sign-in
  /// prove the key still belongs to the same account.
  Future<void> clearSession() {
    return _enqueue(() async {
      final data = await read();
      await write(
        AccountPersistedData(
          userId: data.userId,
          email: data.email,
          displayName: data.displayName,
          syncKey: data.syncKey,
        ),
      );
    });
  }

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final result = _writeQueue.then((_) => action());
    // The queue must not inherit the failure, or one failed write would poison
    // every later one.
    _writeQueue = result.then((_) {}, onError: (_) {});
    return result;
  }
}

@Riverpod(keepAlive: true)
AccountSecureStore accountSecureStore(Ref ref) =>
    AccountSecureStore(profileId: filesystem.selectedProfile.uuid);
