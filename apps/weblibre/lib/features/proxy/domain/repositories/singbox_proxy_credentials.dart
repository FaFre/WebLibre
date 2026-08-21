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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/secure_storage/profile_secure_store.dart';
import 'package:weblibre/core/secure_storage/secure_storage_migration.dart';

part 'singbox_proxy_credentials.g.dart';

@Riverpod(keepAlive: true)
class SingboxProxyCredentialsRepository
    extends _$SingboxProxyCredentialsRepository {
  /// Scoped to the *user* profile as well as the proxy profile.
  ///
  /// `profileId` here is a proxy profile, whose row lives in the user profile's
  /// own database — so the record has an owner even though the key never said
  /// so. Naming it makes a deleted user profile's credentials collectable
  /// instead of orphaned in the app-wide store forever.
  ProfileSecureStore get _store => ProfileSecureStore(
    profileId: filesystem.selectedProfile.uuid,
    storage: const FlutterSecureStorage(),
  );

  String _secretKey(String proxyProfileId) =>
      '$proxySecretKeyPrefix$proxyProfileId';

  Future<String?> readSecretJson(String profileId) {
    return _store.read(_secretKey(profileId));
  }

  Future<void> writeSecretJson(String profileId, String? secretJson) async {
    if (secretJson == null || secretJson.trim().isEmpty) {
      await deleteSecretJson(profileId);
      return;
    }

    await _store.write(_secretKey(profileId), secretJson);
  }

  Future<void> deleteSecretJson(String profileId) {
    return _store.delete(_secretKey(profileId));
  }

  @override
  void build() {
    return;
  }
}
