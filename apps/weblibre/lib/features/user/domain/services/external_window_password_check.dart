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
import 'dart:io';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/user/domain/services/profile_password.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;

/// Checks profile passwords for Custom Tab and PWA windows.
///
/// Those windows are native and cannot run the Argon2 check themselves. Going
/// through [ProfilePasswordGate] also means a wrong attempt in a window counts
/// against the same throttle as one on the browser's lock screen.
///
/// Registered before the app has a profile, because native may ask as soon as
/// the engine runs. Until a profile is activated the answer is
/// [ProfilePasswordOutcome.unavailable], and native asks again.
class ExternalWindowPasswordCheck implements ProfileLockFlutterApi {
  /// Where the profile is, while one is active. Replaceable for tests.
  final Directory? Function(String profileId) _profileDir;

  ExternalWindowPasswordCheck({
    Directory? Function(String profileId)? profileDir,
  }) : _profileDir = profileDir ?? _activeProfileDir;

  static Directory? _activeProfileDir(String profileId) {
    if (!filesystem.isActivated) return null;
    // A window serves the profile its process committed, and so does this
    // isolate. Anything else is a question about a profile this isolate has
    // no business unlocking.
    if (filesystem.selectedProfile.uuid != profileId) return null;
    return filesystem.selectedProfileDir;
  }

  static ProfilePasswordReply _reply(
    ProfilePasswordOutcome outcome, [
    Duration? retryAfter,
  ]) => ProfilePasswordReply(
    outcome: outcome,
    retryAfterMs: retryAfter?.inMilliseconds,
  );

  @override
  Future<ProfilePasswordReply> checkProfilePassword(
    String profileId,
    String password,
  ) async {
    final dir = _profileDir(profileId);
    if (dir == null) {
      return filesystem.isActivated
          ? _reply(ProfilePasswordOutcome.failed)
          : _reply(ProfilePasswordOutcome.unavailable);
    }

    try {
      // Read now: the window's idea of the lock may predate a change made in
      // the browser.
      final settings = (await fs.readProfileMetadata(dir))?.authSettings;
      if (settings == null ||
          settings.lockMethod != ProfileLockMethod.password) {
        // The window re-reads the lock when it shows again, and opens if
        // there is none left.
        return _reply(ProfilePasswordOutcome.failed);
      }

      final result = await ProfilePasswordGate(dir).check(settings, password);
      return switch (result) {
        ProfilePasswordAccepted() => _reply(ProfilePasswordOutcome.accepted),
        ProfilePasswordRejected(:final retryAfter) => _reply(
          ProfilePasswordOutcome.rejected,
          retryAfter,
        ),
        ProfilePasswordThrottled(:final retryAfter) => _reply(
          ProfilePasswordOutcome.throttled,
          retryAfter,
        ),
        // The gate never answers this; the window checks for leaving itself.
        ProfilePasswordInterrupted() => _reply(ProfilePasswordOutcome.failed),
      };
    } catch (error, stackTrace) {
      // Most likely the attempt record could not be written. Not a pass.
      logger.e(
        'Profile password check for an external window failed',
        error: error,
        stackTrace: stackTrace,
      );
      return _reply(ProfilePasswordOutcome.failed);
    }
  }
}
