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

import 'package:clock/clock.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/services/local_authentication.dart';
import 'package:weblibre/features/user/domain/services/profile_password.dart';

part 'profile_auth.g.dart';

String profileAccessAuthKey(String profileId) =>
    '$profileAccessAuthKeyPrefix$profileId';

/// Hands the native lock cover to a Flutter engine that is just starting.
///
/// The cover and its arming are process-wide, and an engine before this one
/// may have left both behind, with a window covered and nobody left to lift
/// it. Nothing of a profile is on this engine's screen: it shows the startup
/// screens first (the picker, maintenance, a halt with Retry and Close), and
/// the app after them starts at the lock screen. So the cover is disarmed
/// until [ProfileAuthState] arms it, and a leftover one is lifted once this
/// engine's first frame is on screen; a halt or the picker is never hidden
/// behind it. A cover this engine put up after arming it is its returns' to
/// lift, and native leaves it alone.
Future<void> resetBrowserLockCoverForNewEngine() async {
  final profiles = GeckoProfileService();
  try {
    await profiles.disarmBrowserLockCoverForNewEngine();
    await WidgetsBinding.instance.waitUntilFirstFrameRasterized;
    await profiles.liftLeftoverBrowserLockCover();
  } catch (error, stackTrace) {
    logger.w(
      'Could not reset the browser lock cover',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Whether the profile is open in the browser.
///
/// The lock is decided when the app leaves and again at the first sign of it
/// coming back, not once it is in front: Flutter reports `resumed` only when
/// the window has focus, which can be half a second after it is on screen,
/// and it draws meanwhile. Deciding on leaving means the first frame drawn on
/// the way back is already the lock screen. What the window and the system
/// show before that frame, native covers (`BrowserLockCover`): this arms it
/// while the profile is open and a lock applies on some return, and lifts it
/// once the decision is drawn.
@Riverpod(keepAlive: true)
class ProfileAuthState extends _$ProfileAuthState {
  bool _bootstrapped = false;

  /// The departure whose cover a locked return lifts once the lock screen is
  /// drawn; see [_onReturn].
  int? _lockedReturn;

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

    _setOpen(result.passed);
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
          unlockedAt: clock.now().subtract(age),
        );
    _unlock();
    return true;
  }

  /// Locks the profile when its unlock no longer holds, or cannot be checked.
  Future<void> _revalidate() async {
    if (!state) return;

    try {
      // A resume caused by this app's own prompt closing must not be judged
      // before the prompt's answer is recorded. Awaiting is also what puts
      // this after the eviction `LocalAuthenticationService` runs in the same
      // lifecycle change, whichever listener was called first.
      await ref
          .read(localAuthenticationServiceProvider.notifier)
          .promptsSettled();
      if (!ref.mounted || !state) return;

      final profile = await _profileToJudgeBy();
      if (!ref.mounted || !profile.authSettings.authenticationRequired) return;

      final cached = ref
          .read(localAuthenticationServiceProvider.notifier)
          .isCached(profileAccessAuthKey(profile.id));

      if (!cached && ref.mounted) {
        _lock();
      }
    } catch (error, stackTrace) {
      // An unlock that cannot be confirmed does not hold.
      logger.e(
        'Could not check the profile unlock; locking',
        error: error,
        stackTrace: stackTrace,
      );
      if (ref.mounted) _lock();
    }
  }

  /// The profile whose lock settings the unlock is judged by: as stored now,
  /// or as last read when reading it fails.
  ///
  /// A failed read says nothing about the lock. Locking on it alone would
  /// lock a profile that has none, and the lock screen, reading the same
  /// profile, could not unlock it. The profile is open, so it was read to
  /// open it.
  Future<Profile> _profileToJudgeBy() async {
    try {
      return await ref.read(selectedProfileProvider.future);
    } catch (error, stackTrace) {
      final lastRead = ref.mounted
          ? ref.read(selectedProfileProvider).value
          : null;
      if (lastRead == null) rethrow;

      logger.w(
        'Could not read the profile; judging its unlock by the settings '
        'last read',
        error: error,
        stackTrace: stackTrace,
      );
      return lastRead;
    }
  }

  /// The app is coming back: decides, then lifts the native cover once the
  /// decision is on screen.
  ///
  /// The cover waits for the decision however long it takes. A prompt this
  /// app raised holds it until the prompt answers: the cover cannot tell
  /// whether that prompt still hides the browser, and an unlock that ran out
  /// meanwhile must not show.
  ///
  /// Runs on `onShow` and on `onResume`: an activity that comes back to an
  /// engine kept from a window that was closed reports `detached → resumed`,
  /// never `hidden → inactive`.
  ///
  /// The release names the departure the window was back from when this
  /// started, asked of native before deciding. Leaving again before it
  /// arrives makes it a release for an older departure, which native ignores:
  /// the newer cover waits for the decision of the return that follows. Asked
  /// first, so the decision cannot predate the departure it is applied to.
  ///
  /// Both callbacks run it on a return from leaving. The second run reaches
  /// the same decision, or a lock that came due in between, and native
  /// ignores a release for a cover that is already gone or already waited
  /// for. It is not skipped per departure: a resume without a departure (the
  /// notification shade) must still apply a timeout that ran out.
  Future<void> _onReturn() async {
    final departure = await _currentDeparture();
    if (!ref.mounted) return;

    await _revalidate();
    // Out of sight again by the time native answered: the next return
    // decides for that departure. Unreadable: the decision above stands, and
    // the cover, with nothing to name it by, stays until the next return.
    if (!ref.mounted || departure == null) return;

    if (state) {
      // Still open: the cover hides this same open profile, nothing older.
      await _releaseCover(departure, afterFreshFrame: false);
      return;
    }

    // Locked: the cover hides the browser as it was left, so it stays until
    // a frame built since is on screen. Native confirms that: it has Flutter
    // draw on a new surface and waits for the report of the first frame
    // drawn there (`BrowserLockCover.release`). That frame must not be one
    // built before this decision, so the release waits until none is left to
    // draw. The redirect to the lock screen is synchronous (go_router
    // completes a synchronous redirect with a `SynchronousFuture`), so every
    // frame built from here shows it, and by the third the ones before are
    // drawn or discarded: the engine starts building a frame only while fewer
    // than two built ones wait for the raster thread (`Animator::BeginFrame`
    // asks the depth-2 `FramePipeline` for a slot, and `Pipeline::Consume`
    // frees one only once its frame is done with).
    //
    // An unlock from here on releases this departure itself ([_setOpen]).
    _lockedReturn = departure;
    await SchedulerBinding.instance.endOfFrame;
    await SchedulerBinding.instance.endOfFrame;
    await SchedulerBinding.instance.endOfFrame;
    if (!ref.mounted || _lockedReturn != departure) return;

    await _releaseCover(departure, afterFreshFrame: true);
  }

  /// The departure the window is back from, or null while it is out of sight
  /// or when native cannot be asked.
  Future<int?> _currentDeparture() async {
    try {
      return await GeckoProfileService().currentBrowserLockCoverDeparture();
    } catch (error, stackTrace) {
      logger.w(
        'Could not read the browser lock cover departure',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> _releaseCover(
    int departure, {
    required bool afterFreshFrame,
  }) async {
    try {
      await GeckoProfileService().releaseBrowserLockCover(
        departure,
        afterFreshFrame: afterFreshFrame,
      );
    } catch (error, stackTrace) {
      logger.w(
        'Could not lift the browser lock cover',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Arms the native cover while the profile is open and a lock applies on
  /// some return: on leaving, and in the system's screenshot of the window.
  /// An until-restart lock never applies again in this process.
  ///
  /// The settings are the ones last read, so the arming goes out with the
  /// change that calls for it, ahead of the frame that shows the browser:
  /// leaving straight after an unlock finds the cover armed. Every unlock has
  /// just read them; only without any does this wait for them.
  Future<void> _syncCover() async {
    var settings = ref.read(selectedProfileProvider).value?.authSettings;
    if (settings == null) {
      try {
        settings = (await ref.read(
          selectedProfileProvider.future,
        )).authSettings;
      } catch (error, stackTrace) {
        logger.w(
          'Could not read the lock settings for the browser lock cover',
          error: error,
          stackTrace: stackTrace,
        );
        return;
      }
      if (!ref.mounted) return;
    }

    final armed =
        state &&
        settings.authenticationRequired &&
        settings.autoLockMode != AutoLockMode.startup;

    try {
      await GeckoProfileService().setBrowserLockCover(armed: armed);
    } catch (error, stackTrace) {
      logger.w(
        'Could not arm the browser lock cover',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _setOpen(bool open) {
    state = open;
    unawaited(_syncCover());

    // Unlocked while a locked return waits for the lock screen to be drawn.
    // The window now shows the open profile, which the cover need not hide,
    // and which that wait could never see the end of: the browser draws
    // through Flutter's image view, which the release waits to go. The
    // decision for that departure is now "open".
    final lockedReturn = _lockedReturn;
    if (open && lockedReturn != null) {
      _lockedReturn = null;
      unawaited(_releaseCover(lockedReturn, afterFreshFrame: false));
    }
  }

  void _lock() => _setOpen(false);

  void _unlock() => _setOpen(true);

  @override
  bool build() {
    final lifecycle = AppLifecycleListener(
      // Leaving: a profile that locks on leaving locks now, while nothing is
      // drawn. A locked return still waiting is over: native ignores a
      // release for a departure before this one.
      onHide: () {
        _lockedReturn = null;
        unawaited(_revalidate());
      },
      onShow: () => unawaited(_onReturn()),
      // Also back from the notification shade, split-screen focus or this
      // app's own prompt, none of which is leaving: a timeout may have run
      // out. The cover is not up then, and lifting it does nothing.
      onResume: () => unawaited(_onReturn()),
    );
    ref.onDispose(lifecycle.dispose);

    // Editing the lock of the open profile changes whether leaving covers it.
    ref.listen(
      selectedProfileProvider.select((profile) => profile.value?.authSettings),
      (_, _) => unawaited(_syncCover()),
    );

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
