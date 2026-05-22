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
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
  static const _storageKey = 'account_auth_data';

  final FlutterSecureStorage _storage;

  AccountSecureStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<AccountPersistedData> read() async {
    final json = await _storage.read(key: _storageKey);
    if (json == null) return AccountPersistedData();
    return AccountPersistedData.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  Future<void> write(AccountPersistedData data) {
    return _storage.write(key: _storageKey, value: jsonEncode(data.toJson()));
  }

  Future<void> clear() {
    return _storage.delete(key: _storageKey);
  }
}

@Riverpod(keepAlive: true)
AccountSecureStore accountSecureStore(Ref ref) => AccountSecureStore();
