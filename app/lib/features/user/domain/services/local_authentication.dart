import 'dart:async';

import 'package:flutter/services.dart';
import 'package:lensai/core/logger.dart';
import 'package:lensai/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    } on PlatformException catch (e, s) {
      logger.e('Could not authenticate', error: e, stackTrace: s);
      return false;
    }
  }

  @override
  Future<bool> build() {
    return _auth.canCheckBiometrics;
  }
}
