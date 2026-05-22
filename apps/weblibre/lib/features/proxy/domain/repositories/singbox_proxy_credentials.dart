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

part 'singbox_proxy_credentials.g.dart';

@Riverpod(keepAlive: true)
class SingboxProxyCredentialsRepository
    extends _$SingboxProxyCredentialsRepository {
  static const _storage = FlutterSecureStorage();

  String _secretKey(String profileId) => 'singbox_proxy.secret.$profileId';

  Future<String?> readSecretJson(String profileId) {
    return _storage.read(key: _secretKey(profileId));
  }

  Future<void> writeSecretJson(String profileId, String? secretJson) async {
    if (secretJson == null || secretJson.trim().isEmpty) {
      await deleteSecretJson(profileId);
      return;
    }

    await _storage.write(key: _secretKey(profileId), value: secretJson);
  }

  Future<void> deleteSecretJson(String profileId) {
    return _storage.delete(key: _secretKey(profileId));
  }

  @override
  void build() {
    return;
  }
}
