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
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/profile_password_dialogs.dart';
import 'package:weblibre/features/user/domain/providers/profile_auth.dart';
import 'package:weblibre/features/user/domain/services/local_authentication.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;

/// [profile] as its `metadata.json` describes it now.
///
/// The [Profile] a screen holds arrived through a route parameter and may
/// predate a lock change. What guards a profile has to come from the profile.
Future<Profile> readCurrentProfileMetadata(Profile profile) async {
  try {
    return await fs.readProfileMetadata(
          filesystem.getProfileDir(profile.uuidValue),
        ) ??
        profile;
  } catch (error, stackTrace) {
    logger.w(
      'Could not re-read profile metadata',
      error: error,
      stackTrace: stackTrace,
    );
    return profile;
  }
}

/// The open profile's unlock, to record when a device prompt succeeds.
///
/// The prompt takes the app out of the foreground, which drops background-mode
/// unlocks; left alone, the profile the user is working in would lock on the
/// resume that ends the very prompt they just passed. A device prompt proves
/// the device lock, so it is recorded again — for a device-locked open profile
/// only. A password-locked one is not proved by it.
///
/// [known] spares a read when the caller already holds fresh metadata for one
/// profile, which may be the open one.
Future<Map<String, AuthSettings>> activeProfileDeviceUnlock([
  Profile? known,
]) async {
  // Before a profile is open (first-run screens) there is nothing to keep
  // unlocked.
  if (!filesystem.isActivated) return const {};
  final activeId = filesystem.selectedProfile;

  Profile? active;
  if (known != null && known.uuidValue == activeId) {
    active = known;
  } else {
    try {
      active = await fs.readProfileMetadata(filesystem.getProfileDir(activeId));
    } catch (error, stackTrace) {
      logger.w(
        'Could not read the open profile for its unlock',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  if (active == null ||
      active.authSettings.lockMethod != ProfileLockMethod.device) {
    return const {};
  }
  return {profileAccessAuthKey(active.id): active.authSettings};
}

/// Asks for whatever unlocks [profile] before an action that could leak or
/// destroy it: a backup, a delete, a restore over it, a change to its lock.
///
/// Never answered from an earlier unlock. Opening the profile a minute ago
/// says nothing about who is holding the phone now, and the action is one the
/// person is about to do deliberately anyway.
///
/// Works for any profile, not only the one this process is serving: the
/// profile list reaches every profile, and that is where a locked one used to
/// be backed up without asking.
///
/// [reason] is the dialog title, and for the device lock the line the system
/// prompt shows.
Future<bool> authorizeProfileAction(
  BuildContext context,
  WidgetRef ref,
  Profile profile, {
  required String reason,
}) async {
  final current = await readCurrentProfileMetadata(profile);
  if (!context.mounted) return false;

  final settings = current.authSettings;

  switch (settings.lockMethod) {
    case ProfileLockMethod.none:
      return true;
    case ProfileLockMethod.device:
      // Fresh: no `useAuthCache`, and the action's own profile is not cached
      // here. What is recorded is the open profile's unlock — see
      // [activeProfileDeviceUnlock].
      final alsoRemember = await activeProfileDeviceUnlock(current);
      return await ref
          .read(localAuthenticationServiceProvider.notifier)
          .authenticate(
            authKey: profileAccessAuthKey(current.id),
            localizedReason: reason,
            alsoRemember: alsoRemember,
          );
    case ProfileLockMethod.password:
      final authService = ref.read(localAuthenticationServiceProvider.notifier);
      return await showProfilePasswordDialog(
        context,
        profileDir: filesystem.getProfileDir(current.uuidValue),
        settings: settings,
        title: reason,
        departureCount: () => authService.departureCount,
      );
  }
}
