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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:weblibre/core/secure_storage/profile_secure_keys.dart';

/// Profile-scoped access to the app-wide secure store.
///
/// Every read and write goes through [profileScopedSecureKey], so two profiles
/// can hold the same logical record without seeing each other's. The enumeration
/// helpers exist for maintenance: backup, restore and delete all need to answer
/// "what does this profile own", and the key is the only place that answer lives.
class ProfileSecureStore {
  ProfileSecureStore({required this.profileId, FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final String profileId;
  final FlutterSecureStorage _storage;

  Future<String?> read(String base) =>
      _storage.read(key: profileScopedSecureKey(base, profileId));

  Future<void> write(String base, String value) => _storage.write(
    key: profileScopedSecureKey(base, profileId),
    value: value,
  );

  Future<void> delete(String base) =>
      _storage.delete(key: profileScopedSecureKey(base, profileId));

  /// Every record this profile owns, keyed by base name.
  Future<Map<String, String>> readAllOwned() async {
    final all = await _storage.readAll();

    return {
      for (final entry in all.entries)
        if (secureKeyBelongsTo(entry.key, profileId))
          baseOfSecureKey(entry.key): entry.value,
    };
  }

  /// Replaces this profile's records with [entries].
  ///
  /// Records absent from [entries] are removed, because a restore has to be able
  /// to represent "this profile had no account" — leaving a stale credential
  /// behind would sign the restored profile into something its archive never
  /// described.
  Future<void> replaceAllOwned(Map<String, String> entries) async {
    await deleteAllOwned();

    for (final entry in entries.entries) {
      await _storage.write(
        key: profileScopedSecureKey(entry.key, profileId),
        value: entry.value,
      );
    }
  }

  Future<void> deleteAllOwned() async {
    final all = await _storage.readAll();

    for (final key in all.keys) {
      if (secureKeyBelongsTo(key, profileId)) {
        await _storage.delete(key: key);
      }
    }
  }
}
