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
import 'package:flutter/foundation.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/services/local_authentication.dart';
import 'package:weblibre/features/user/domain/services/profile_password.dart';

part 'profile_auth.g.dart';

String profileAccessAuthKey(String profileId) =>
    '$profileAccessAuthKeyPrefix$profileId';

@Riverpod(keepAlive: true)
class ProfileAuthState extends _$ProfileAuthState {
  bool _bootstrapped = false;

  Future<void> bootstrapFromProfile() async {
    if (_bootstrapped) return;

    final profile = await ref.read(selectedProfileProvider.future);
    if (!ref.mounted) return;

    _bootstrapped = true;

    if (!profile.authSettings.authenticationRequired) {
      _unlock();
    }
  }

  /// Unlocks with the device prompt.
  ///
  /// [localizedReason] is the line the system unlock prompt shows, passed in
  /// by the widget that asks so it follows the UI language.
  ///
  /// Refuses a password-locked profile without prompting: the device prompt
  /// proves only that someone can unlock the phone, which is exactly what a
  /// profile password is there to not accept.
  Future<DeviceAuthResult> authenticate({
    required String localizedTitle,
    required String localizedReason,
  }) async {
    final profile = await ref.read(selectedProfileProvider.future);
    if (!ref.mounted) return const DeviceAuthDeclined();

    switch (profile.authSettings.lockMethod) {
      case ProfileLockMethod.none:
        _unlock();
        return const DeviceAuthPassed();
      case ProfileLockMethod.password:
        return const DeviceAuthDeclined();
      case ProfileLockMethod.device:
        break;
    }

    final result = await ref
        .read(localAuthenticationServiceProvider.notifier)
        .authenticate(
          authKey: profileAccessAuthKey(profile.id),
          localizedTitle: localizedTitle,
          localizedReason: localizedReason,
          settings: profile.authSettings,
          useAuthCache: true,
        );

    if (!ref.mounted) return const DeviceAuthDeclined();

    state = result.passed;
    return result;
  }

  /// Unlocks a password-locked profile with [password].
  Future<ProfilePasswordCheck> unlockWithPassword(String password) async {
    final profile = await ref.read(selectedProfileProvider.future);
    if (!ref.mounted) return const ProfilePasswordRejected();

    if (profile.authSettings.lockMethod != ProfileLockMethod.password) {
      return const ProfilePasswordRejected();
    }

    final authService = ref.read(localAuthenticationServiceProvider.notifier);
    final departuresBefore = authService.departureCount;

    final result = await ProfilePasswordGate(
      filesystem.getProfileDir(profile.uuidValue),
    ).check(profile.authSettings, password);

    if (!ref.mounted) return result;
    if (result is! ProfilePasswordAccepted) return result;

    // Argon2 takes long enough to press Home in the middle of it. An unlock
    // that lands while the app is away would greet whoever opens it next with
    // an open profile, whatever its auto-lock says.
    if (authService.departureCount != departuresBefore) {
      return const ProfilePasswordInterrupted();
    }

    authService.remember(
      profileAccessAuthKey(profile.id),
      profile.authSettings,
    );
    _unlock();
    return result;
  }

  /// Opens the profile when a Custom Tab or PWA window unlocked it, and the
  /// auto-lock settings let that unlock hold here too.
  ///
  /// Only timeout and until-restart unlocks are shared, and the window's is
  /// checked against this profile's settings as they are now. Returns whether
  /// the profile is open.
  Future<bool> adoptSharedUnlock() async {
    if (state) return true;

    final profile = await ref.read(selectedProfileProvider.future);
    if (!ref.mounted) return false;

    final settings = profile.authSettings;
    if (!settings.authenticationRequired) return false;

    final SharedProfileUnlock? shared;
    try {
      shared = await GeckoProfileService().getSharedProfileUnlock(profile.id);
    } catch (error, stackTrace) {
      logger.w(
        'Could not read a shared profile unlock',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
    if (!ref.mounted || shared == null || state) return state;

    final age = Duration(milliseconds: shared.ageMs);
    final holds = switch (settings.autoLockMode) {
      AutoLockMode.startup => shared.mode == SharedUnlockMode.startup,
      AutoLockMode.timeout =>
        shared.mode == SharedUnlockMode.timeout && age < settings.timeout,
      AutoLockMode.background => false,
    };
    if (!holds) return false;

    ref
        .read(localAuthenticationServiceProvider.notifier)
        .remember(
          profileAccessAuthKey(profile.id),
          settings,
          unlockedAt: DateTime.now().subtract(age),
        );
    _unlock();
    return true;
  }

  Future<void> revalidateAfterResume() async {
    if (!state) return;

    // A resume caused by this app's own prompt closing must not be judged
    // before the prompt's answer is recorded.
    await ref
        .read(localAuthenticationServiceProvider.notifier)
        .promptsSettled();
    if (!ref.mounted || !state) return;

    final profile = await ref.read(selectedProfileProvider.future);
    if (!ref.mounted || !profile.authSettings.authenticationRequired) return;

    final cached = ref
        .read(localAuthenticationServiceProvider.notifier)
        .isCached(profileAccessAuthKey(profile.id));

    if (!cached && ref.mounted) {
      _lock();
    }
  }

  void _lock() {
    state = false;
  }

  void _unlock() {
    state = true;
  }

  @override
  bool build() {
    return false;
  }
}

@Riverpod(keepAlive: true)
Raw<ProfileAuthNotifier> profileAuthNotifier(Ref ref) {
  final notifier = ProfileAuthNotifier();

  ref.listen<bool>(profileAuthStateProvider, (_, _) {
    notifier.notify();
  });

  ref.onDispose(notifier.dispose);

  return notifier;
}

class ProfileAuthNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
