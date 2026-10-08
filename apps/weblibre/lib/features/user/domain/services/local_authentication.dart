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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';

part 'local_authentication.g.dart';

/// Keys of the form `profile_access::<profile id>` are unlocks of a profile.
const profileAccessAuthKeyPrefix = 'profile_access::';

/// Why a device prompt did not pass, when there is something to tell the
/// person. A prompt they closed themselves needs no explanation.
enum DeviceAuthFailure {
  /// No screen lock is set up, so the device has nothing to check against.
  noScreenLock,

  /// Too many wrong attempts; the system refuses for a while.
  lockedOut,

  /// The prompt could not run.
  unavailable,
}

/// How a device prompt ended.
sealed class DeviceAuthResult {
  const DeviceAuthResult();

  bool get passed => this is DeviceAuthPassed;
}

final class DeviceAuthPassed extends DeviceAuthResult {
  const DeviceAuthPassed();
}

/// Closed by the person, by the system (the app left the screen), or never
/// shown because there was no window or another prompt was up. Nothing to
/// explain.
final class DeviceAuthDeclined extends DeviceAuthResult {
  const DeviceAuthDeclined();
}

final class DeviceAuthFailed extends DeviceAuthResult {
  final DeviceAuthFailure failure;

  const DeviceAuthFailed(this.failure);
}

/// What a device prompt that threw [error] means for the person.
///
/// `local_auth` reports every outcome but a pass as an exception, a closed
/// prompt included. Biometric-only codes mean nothing is set up at all: the
/// prompt also accepts the screen lock, so it only fails on them without one.
DeviceAuthResult deviceAuthResultOf(LocalAuthException error) {
  return switch (error.code) {
    LocalAuthExceptionCode.noCredentialsSet ||
    LocalAuthExceptionCode.noBiometricsEnrolled ||
    LocalAuthExceptionCode.noBiometricHardware => const DeviceAuthFailed(
      DeviceAuthFailure.noScreenLock,
    ),
    LocalAuthExceptionCode.temporaryLockout ||
    LocalAuthExceptionCode.biometricLockout => const DeviceAuthFailed(
      DeviceAuthFailure.lockedOut,
    ),
    LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable ||
    LocalAuthExceptionCode.deviceError ||
    LocalAuthExceptionCode.unknownError => const DeviceAuthFailed(
      DeviceAuthFailure.unavailable,
    ),
    LocalAuthExceptionCode.userCanceled ||
    LocalAuthExceptionCode.systemCanceled ||
    LocalAuthExceptionCode.timeout ||
    LocalAuthExceptionCode.userRequestedFallback ||
    LocalAuthExceptionCode.uiUnavailable ||
    LocalAuthExceptionCode.authInProgress => const DeviceAuthDeclined(),
  };
}

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
  /// A check that takes time — a profile password runs Argon2 — compares this
  /// before and after. A change means the person may have walked away before
  /// the answer arrived, and an unlock or authorization that lands while
  /// nobody is looking must not take effect.
  int get departureCount => _departures;

  /// Tracked here rather than by a screen: the lock screen, the profile list
  /// and dialogs need it too, and the browser view is mounted on none of them.
  ///
  /// Leaving is the app going out of sight (`hidden`, then `paused`). A plain
  /// `inactive` is not: the window only lost focus, to the notification
  /// shade, a permission dialog, the share sheet, another window in split
  /// screen or this service's own prompt, and the person never left. It is
  /// what Custom Tab and PWA windows count too (`ProfileUnlockRegistry`).
  void _onLifecycleChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
        return;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        evictCacheOnBackground();
    }
  }

  /// Drops background-mode unlocks because the app left the foreground.
  ///
  /// Every eviction also counts as a departure ([departureCount]), so the two
  /// cannot disagree about what "left the app" means.
  void evictCacheOnBackground() {
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
  ///
  /// [unlockedAt] backdates an unlock adopted from elsewhere, so its timeout
  /// runs from when it was really made.
  void remember(String authKey, AuthSettings settings, {DateTime? unlockedAt}) {
    final at = unlockedAt ?? DateTime.now();
    _cache[authKey] = (at, settings);
    _shareProfileUnlock(authKey, settings, at);
  }

  /// Drops a remembered unlock, so the next check asks again.
  void forget(String authKey) {
    _cache.remove(authKey);
    _shareProfileUnlock(authKey, null, null);
  }

  /// Hands an unlock of a profile to its Custom Tab and PWA windows, or takes
  /// it back.
  ///
  /// Only timeout and until-restart unlocks are shared. A background-mode one
  /// ends when the browser leaves the foreground, and opening a window always
  /// does that. Recording one, or forgetting, clears the unlock shared with
  /// the windows: the browser's settings no longer let them share it. A
  /// window's own background-mode unlock is not the browser's to clear.
  ///
  /// Native keeps only the profile its process serves, so the unlocks of other
  /// profiles that authorizing an action records go nowhere.
  void _shareProfileUnlock(
    String authKey,
    AuthSettings? settings,
    DateTime? unlockedAt,
  ) {
    if (!authKey.startsWith(profileAccessAuthKeyPrefix)) return;
    final profileId = authKey.substring(profileAccessAuthKeyPrefix.length);

    final mode = (settings == null || !settings.authenticationRequired)
        ? null
        : switch (settings.autoLockMode) {
            AutoLockMode.timeout => SharedUnlockMode.timeout,
            AutoLockMode.startup => SharedUnlockMode.startup,
            AutoLockMode.background => null,
          };

    final profiles = GeckoProfileService();
    final update = mode == null
        ? profiles.clearSharedProfileUnlock(profileId)
        : profiles.recordSharedProfileUnlock(
            profileId,
            mode: mode,
            timeout: settings!.timeout,
            age: DateTime.now().difference(unlockedAt ?? DateTime.now()),
          );

    // The windows ask again when it did not arrive; the browser's own lock
    // does not depend on it.
    unawaited(
      update.catchError((Object error, StackTrace stackTrace) {
        logger.w(
          'Could not share a profile unlock with external windows',
          error: error,
          stackTrace: stackTrace,
        );
      }),
    );
  }

  /// Asks the device prompt, or answers from the cache when [useAuthCache].
  ///
  /// [localizedTitle] heads the system prompt and [localizedReason] says what
  /// it is for. Both are needed: `local_auth`'s own title and hint are
  /// English whatever the app's language.
  ///
  /// On success, [authKey] is remembered under [settings] when given, and so
  /// is every entry of [alsoRemember]. Both are recorded before the prompt
  /// counts as settled, so a resume check waiting in [promptsSettled] sees
  /// them.
  Future<DeviceAuthResult> authenticate({
    required String authKey,
    required String localizedTitle,
    required String localizedReason,
    AuthSettings? settings,
    bool useAuthCache = false,
    Map<String, AuthSettings> alsoRemember = const {},
  }) async {
    if (useAuthCache && isCached(authKey)) {
      if (settings != null) remember(authKey, settings);
      return const DeviceAuthPassed();
    }

    if (_promptsInFlight++ == 0) {
      _promptsSettled = Completer<void>();
    }

    try {
      final success = await _auth.authenticate(
        localizedReason: localizedReason,
        authMessages: [
          AndroidAuthMessages(
            signInTitle: localizedTitle,
            // Empty hides the line; the reason below already says what for.
            signInHint: '',
          ),
        ],
      );

      if (!success) return const DeviceAuthDeclined();

      if (settings != null) remember(authKey, settings);
      alsoRemember.forEach(remember);
      return const DeviceAuthPassed();
    } on LocalAuthException catch (e, s) {
      final result = deviceAuthResultOf(e);
      if (result is DeviceAuthFailed) {
        logger.e('Could not authenticate', error: e, stackTrace: s);
      }
      return result;
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
