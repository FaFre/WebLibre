/*
 * Copyright (c) 2024-2025 Fabian Freund.
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

import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';

part 'local_authentication.g.dart';

@Riverpod(keepAlive: true)
class LocalAuthenticationService extends _$LocalAuthenticationService {
  final _auth = LocalAuthentication();
  final _cache = <String, (DateTime, ContainerAuthSettings)>{};

  bool _cacheAuth(String authKey) {
    final auth = _cache[authKey];
    if (auth != null && auth.$2.lockTimeout != null) {
      return DateTime.now().difference(auth.$1) < auth.$2.lockTimeout!;
    }

    return false;
  }

  void evictCacheOnBackground() {
    _cache.removeWhere((key, value) => value.$2.lockOnAppBackground);
  }

  Future<bool> authenticate({
    required String authKey,
    required String localizedReason,
    ContainerAuthSettings? settings,
    bool useAuthCache = false,
  }) async {
    try {
      var result = useAuthCache && _cacheAuth(authKey);

      if (!result) {
        result = await _auth.authenticate(localizedReason: localizedReason);
      }

      if (result && settings != null) {
        _cache[authKey] = (DateTime.now(), settings);
      }

      return result;
    } on LocalAuthException catch (e, s) {
      logger.e('Could not authenticate', error: e, stackTrace: s);
      return false;
    }
  }

  @override
  Future<bool> build() {
    return _auth.canCheckBiometrics;
  }
}
