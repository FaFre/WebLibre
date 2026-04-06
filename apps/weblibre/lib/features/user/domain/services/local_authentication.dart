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

import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';

part 'local_authentication.g.dart';

@Riverpod(keepAlive: true)
class LocalAuthenticationService extends _$LocalAuthenticationService {
  final _auth = LocalAuthentication();
  final _cache = <String, (DateTime, AuthSettings)>{};

  void evictCacheOnBackground() {
    _cache.removeWhere(
      (key, value) => value.$2.autoLockMode == AutoLockMode.background,
    );
  }

  bool isCached(String authKey) {
    final auth = _cache[authKey];

    if (auth == null) return false;
    if (auth.$2.autoLockMode == AutoLockMode.timeout) {
      return DateTime.now().difference(auth.$1) < auth.$2.timeout;
    }

    // Background mode cache stays valid until app background eviction.
    return true;
  }

  Future<bool> authenticate({
    required String authKey,
    required String localizedReason,
    AuthSettings? settings,
    bool useAuthCache = false,
  }) async {
    try {
      final useCache = useAuthCache && isCached(authKey);
      final success =
          useCache ||
          await _auth.authenticate(localizedReason: localizedReason);

      if (success && settings != null) {
        _cache[authKey] = (DateTime.now(), settings);
      }

      return success;
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
