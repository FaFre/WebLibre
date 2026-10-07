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

import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';

part 'local_authentication.g.dart';

@Riverpod(keepAlive: true)
class LocalAuthenticationService extends _$LocalAuthenticationService {
  final _auth = LocalAuthentication();
  final _cache = <String, (DateTime, AuthSettings)>{};

  /// System prompts this service has raised and that have not answered yet.
  int _promptsInFlight = 0;
  Completer<void>? _promptsSettled;

  int _departures = 0;

  /// How many times the app has left the foreground since this service
  /// started — every lifecycle change that drops background-mode unlocks.
  ///
  /// That includes a plain `inactive` (notification shade, recents) unless
  /// this service's own prompt caused it: the auto-lock policy treats it as
  /// leaving, so a check running across it must not undo the eviction.
  ///
  /// A check that takes time — a profile password runs Argon2 — compares this
  /// before and after. A change means the person may have walked away before
  /// the answer arrived, and an unlock or authorization that lands while
  /// nobody is looking must not take effect.
  int get departureCount => _departures;

  /// Tracked here rather than by a screen: the lock screen, the profile list
  /// and dialogs need it too, and the browser view is mounted on none of them.
  void _onLifecycleChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        return;
      case AppLifecycleState.inactive:
        evictCacheOnBackground(leftForeground: false);
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        evictCacheOnBackground(leftForeground: true);
    }
  }

  /// Drops background-mode unlocks because the app left the foreground.
  ///
  /// [leftForeground] is false for `inactive`, which is also what the app
  /// becomes while this service's own system prompt covers it. Evicting then
  /// would lock the open profile because the user was busy proving who they
  /// are. A real departure (`hidden`, `paused`) always evicts.
  ///
  /// Every eviction also counts as a departure ([departureCount]), so the two
  /// cannot disagree about what "left the app" means.
  void evictCacheOnBackground({required bool leftForeground}) {
    if (!leftForeground && _promptsInFlight > 0) return;

    _departures++;

    _cache.removeWhere(
      (key, value) => value.$2.autoLockMode == AutoLockMode.background,
    );
  }

  /// Completes once no system prompt is showing.
  ///
  /// The resume that follows a prompt and the prompt's own answer arrive in
  /// no guaranteed order. Checking the cache before the answer is in would
  /// lock a profile the user just unlocked.
  Future<void> promptsSettled() => _promptsSettled?.future ?? Future.value();

  bool isCached(String authKey) {
    final auth = _cache[authKey];

    if (auth == null) return false;
    if (auth.$2.autoLockMode == AutoLockMode.timeout) {
      return DateTime.now().difference(auth.$1) < auth.$2.timeout;
    }

    // Background mode cache stays valid until app background eviction.
    // Startup mode cache is never evicted, so it stays valid for the whole
    // process lifetime.
    return true;
  }

  /// Records an unlock proved some other way, so auto-lock treats it like one
  /// from the device prompt.
  void remember(String authKey, AuthSettings settings) {
    _cache[authKey] = (DateTime.now(), settings);
  }

  /// Drops a remembered unlock, so the next check asks again.
  void forget(String authKey) {
    _cache.remove(authKey);
  }

  /// Asks the device prompt, or answers from the cache when [useAuthCache].
  ///
  /// On success, [authKey] is remembered under [settings] when given, and so
  /// is every entry of [alsoRemember]. Both are recorded before the prompt
  /// counts as settled, so a resume check waiting in [promptsSettled] sees
  /// them.
  Future<bool> authenticate({
    required String authKey,
    required String localizedReason,
    AuthSettings? settings,
    bool useAuthCache = false,
    Map<String, AuthSettings> alsoRemember = const {},
  }) async {
    if (useAuthCache && isCached(authKey)) {
      if (settings != null) remember(authKey, settings);
      return true;
    }

    if (_promptsInFlight++ == 0) {
      _promptsSettled = Completer<void>();
    }

    try {
      final success = await _auth.authenticate(
        localizedReason: localizedReason,
      );

      if (success) {
        if (settings != null) remember(authKey, settings);
        alsoRemember.forEach(remember);
      }

      return success;
    } on LocalAuthException catch (e, s) {
      logger.e('Could not authenticate', error: e, stackTrace: s);
      return false;
    } finally {
      if (--_promptsInFlight == 0) {
        _promptsSettled?.complete();
        _promptsSettled = null;
      }
    }
  }

  @override
  Future<bool> build() {
    final lifecycle = AppLifecycleListener(onStateChange: _onLifecycleChanged);
    ref.onDispose(lifecycle.dispose);

    return _auth.canCheckBiometrics;
  }
}
