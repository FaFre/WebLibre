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
import 'package:collection/collection.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:weblibre/core/copy/profile_copy.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/core/startup/profile_discovery.dart';
import 'package:weblibre/core/startup/startup_config_store.dart';
import 'package:weblibre/core/uuid.dart' as ids;
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/web_push/domain/providers.dart';

part 'profile.g.dart';

@Riverpod(keepAlive: true)
class ProfileRepository extends _$ProfileRepository {
  /// The profiles this app may offer, read the same way startup reads them.
  ///
  /// Through [discoverProfiles] rather than by mapping metadata over the
  /// directory listing, for two reasons. One damaged `metadata.json` used to
  /// reject the whole `Future.wait` and take every other profile down with it —
  /// the list, the restore screen, the delete flow and the restart handler all
  /// failed together over one truncated file. And a profile whose metadata
  /// claims a different uuid than its directory is skipped here exactly as
  /// startup skips it, so the two never disagree about what exists: every id
  /// this list hands to a destructive operation is the id of the directory that
  /// operation will act on.
  ///
  /// Read-only. Repairing damaged profiles is a write and belongs to the leased
  /// path in [FileSystem.discoverProfiles].
  Future<List<Profile>> _readProfiles() async {
    final found = await discoverProfiles(filesystem.profilesDir);
    return [for (final profile in found.profiles) profile.metadata];
  }

  /// Arms a restart onto [id]. The switch itself happens in the next process.
  ///
  /// The order is the point. Nothing about the target is written before the
  /// restart is durably armed, so an interruption anywhere here leaves this
  /// process still serving the profile it always served — never a disk that says
  /// B while a live process serves A.
  ///
  /// Throws when the restart could not be armed, and nothing has changed.
  Future<void> switchProfile(String id) async {
    final profileId = UuidValue.withValidation(id).uuid;

    final armed = await GeckoProfileService().armProfileRestart(
      targetProfileId: profileId,
      reason: 'profileSwitch',
    );
    if (!armed) {
      throw Exception('Could not arm a restart onto $profileId');
    }

    // Past this point the process is terminal, so a push failure is logged
    // rather than propagated: refusing to continue would strand a process that
    // has already given up its ability to serve anything.
    try {
      await ref.read(pushServiceProvider).suspendPushForRestart();
    } catch (error, stackTrace) {
      logger.w(
        'Could not quiesce push before restart',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Profile> createProfile({
    required String name,
    AuthSettings? authSettings,
  }) async {
    final profile = Profile.create(name: name, authSettings: authSettings);
    if (!await filesystem.createNewProfile(profile)) {
      throw Exception('Could not create profile');
    }

    ref.invalidateSelf();

    return profile;
  }

  Future<void> updateProfileMetadata(Profile profile) async {
    await filesystem.updateProfileMetadata(profile);
    ref.invalidateSelf();
  }

  /// Queues a journaled delete and arms the restart that will run it.
  ///
  /// The directory is no longer removed here. A profile's state is not only its
  /// directory — scheduled jobs, native preferences, shortcuts and credentials
  /// live elsewhere — so deletion needs an ownership snapshot taken before
  /// anything is removed, and a journal that survives a crash mid-way. Both need
  /// a maintenance lease, which this process cannot hold while it is running the
  /// browser.
  ///
  /// Returns false when there is nothing to delete — the active profile, or an
  /// id the list no longer has. Throws when the task was queued but the restart
  /// could not be armed, which is a different situation and reads differently to
  /// the user: nothing is pending and retrying is safe. Both are handled at the
  /// call site, the way [switchProfile]'s are.
  Future<bool> deleteProfile(String id) async {
    final uuid = UuidValue.withValidation(id);
    if (filesystem.selectedProfile == uuid) {
      return false;
    }

    final profiles = await future;
    final profile = profiles.firstWhereOrNull(
      (entry) => entry.uuidValue == uuid,
    );
    if (profile == null) {
      // The list can be behind the disk: the profile may already be gone, or its
      // metadata damaged enough that discovery skips it. Reported as "not
      // deleted" rather than thrown, because there is nothing to retry — the
      // work was never queued and the user has no move that would change it.
      logger.w('No profile $uuid to delete');
      return false;
    }

    final task = MaintenanceTask.create(
      id: ids.uuid.v4(),
      action: MaintenanceAction.delete,
      profileId: uuid.uuid,
      profileName: profile.name,
      createdAt: DateTime.now().toUtc(),
    );

    final store = StartupConfigStore(filesystem.startupPaths);
    await store.enqueueTask(task);

    if (!await GeckoProfileService().armProfileRestart(
      reason: 'maintenanceDelete',
    )) {
      await store.removeTask(task.id);
      throw Exception(restartCouldNotBeScheduled);
    }

    return true;
  }

  @override
  Future<List<Profile>> build() {
    return _readProfiles();
  }
}
