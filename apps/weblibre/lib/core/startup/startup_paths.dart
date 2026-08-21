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

import 'package:path/path.dart' as p;
import 'package:weblibre/utils/filesystem.dart' as fs;

/// Global, profile-independent locations that have to be readable before any
/// profile database is opened.
///
/// Every name here is duplicated in Kotlin's `StartupPaths` object; the two
/// must stay in sync, and `startup_config_parity_test.dart` plus
/// `StartupConfigParityTest.kt` read the same fixtures to prove they do.
class StartupPaths {
  const StartupPaths(this.filesDir);

  /// `getApplicationSupportDirectory()`, i.e. `<data>/files`.
  final Directory filesDir;

  /// Global startup configuration. Lives next to `current_profile` inside the
  /// profiles root so a single directory carries all pre-profile state.
  static const startupConfigFileName = 'startup_config.json';

  /// Maintenance workspace. Deliberately outside the `profile-` namespace so
  /// profile enumeration can never mistake an artifact for a profile.
  static const maintenanceDirName = 'weblibre_maintenance';
  static const maintenanceIncomingDirName = 'incoming';
  static const maintenanceOutgoingDirName = 'outgoing';
  static const maintenanceRestoreDirName = 'restore';
  static const maintenanceJournalsDirName = 'journals';

  /// Where an interrupted replace's `old` tree goes when it cannot be put back.
  ///
  /// Deliberately a sibling of `restore` rather than anything inside it: neither
  /// scanner looks here, so a tree parked in it ends the maintenance reservation
  /// exactly as deleting it would — without throwing the user's profile away.
  static const maintenanceOrphanedDirName = 'orphaned';

  static const restartDirName = 'weblibre_restart';
  static const restartRequestFileName = 'request.json';
  static const restartAuthorizationFileName = 'authorization.json';

  /// Account handoff ledger. Global because a callback can arrive before any
  /// profile is committed, and the record is what says which profile started
  /// the sign-in.
  static const accountDirName = 'weblibre_account';
  static const accountHandoffFileName = 'handoff.json';

  static const startupIntentsDirName = 'weblibre_startup_intents';
  static const startupIntentQueueFileName = 'queue.json';
  static const startupIntentPayloadsDirName = 'payloads';

  Directory get profilesDir =>
      Directory(p.join(filesDir.path, fs.profilesDirName));

  File get startupConfigFile =>
      File(p.join(profilesDir.path, startupConfigFileName));

  File get currentProfileFile =>
      File(p.join(profilesDir.path, fs.startupProfileFileName));

  /// The on-disk home of [profileId].
  Directory profileDir(String profileId) =>
      profileDirIn(profilesDir, profileId);

  Directory get maintenanceDir =>
      Directory(p.join(filesDir.path, maintenanceDirName));

  Directory get maintenanceIncomingDir =>
      Directory(p.join(maintenanceDir.path, maintenanceIncomingDirName));

  Directory get maintenanceOutgoingDir =>
      Directory(p.join(maintenanceDir.path, maintenanceOutgoingDirName));

  Directory get maintenanceRestoreDir =>
      Directory(p.join(maintenanceDir.path, maintenanceRestoreDirName));

  Directory get maintenanceJournalsDir =>
      Directory(p.join(maintenanceDir.path, maintenanceJournalsDirName));

  Directory get maintenanceOrphanedDir =>
      Directory(p.join(maintenanceDir.path, maintenanceOrphanedDirName));

  /// The parking place for a task's unidentifiable `old` tree. Keyed by task, so
  /// the log line that names the task is enough to find the data again.
  Directory orphanedProfileDir(String taskId) =>
      Directory(p.join(maintenanceOrphanedDir.path, taskId));

  Directory restoreWorkspaceDir(String taskId) =>
      Directory(p.join(maintenanceRestoreDir.path, taskId));

  Directory restoreStagingDir(String taskId) =>
      Directory(p.join(restoreWorkspaceDir(taskId).path, 'staging'));

  Directory restoreOldDir(String taskId) =>
      Directory(p.join(restoreWorkspaceDir(taskId).path, 'old'));

  /// Participant rollback data for a restore.
  ///
  /// A *sibling* of `staging` and `old`, deliberately: it has to survive both the
  /// staged tree being renamed into place and the old tree being put back, and it
  /// is the one thing a rollback still needs after both of those have happened.
  Directory restoreParticipantsDir(String taskId) =>
      Directory(p.join(restoreWorkspaceDir(taskId).path, 'participants'));

  File journalFile(String taskId) =>
      File(p.join(maintenanceJournalsDir.path, '$taskId.json'));

  File get accountHandoffFile =>
      File(p.join(filesDir.path, accountDirName, accountHandoffFileName));

  Directory get restartDir => Directory(p.join(filesDir.path, restartDirName));

  File get restartRequestFile =>
      File(p.join(restartDir.path, restartRequestFileName));

  /// Proof that a restart-into-profile request came from this app.
  ///
  /// Beside the restart request because it belongs to the same protocol, but a
  /// separate file: native writes it when the user answers the profile-mismatch
  /// dialog, minutes before any restart is armed, and this side consumes it.
  File get restartAuthorizationFile =>
      File(p.join(restartDir.path, restartAuthorizationFileName));

  Directory get startupIntentsDir =>
      Directory(p.join(filesDir.path, startupIntentsDirName));

  File get startupIntentQueueFile =>
      File(p.join(startupIntentsDir.path, startupIntentQueueFileName));

  Directory get startupIntentPayloadsDir =>
      Directory(p.join(startupIntentsDir.path, startupIntentPayloadsDirName));

  Directory startupIntentPayloadDir(String entryId) =>
      Directory(p.join(startupIntentPayloadsDir.path, entryId));

  /// Create the workspace directories that scanners and writers assume exist.
  /// Safe to call on every start; it touches nothing inside a profile.
  Future<void> ensureGlobalDirectories() async {
    await profilesDir.create(recursive: true);
    await maintenanceIncomingDir.create(recursive: true);
    await maintenanceOutgoingDir.create(recursive: true);
    await maintenanceRestoreDir.create(recursive: true);
    await maintenanceJournalsDir.create(recursive: true);
  }
}

/// The on-disk home of [profileId] under [profilesDir].
///
/// The canonical spelling of this join, for the callers that hold a profiles
/// root but not a whole [StartupPaths]. Native derives the same name in
/// `StartupPaths.profileDir`; a directory that does not match it is not
/// discoverable by either side.
Directory profileDirIn(Directory profilesDir, String profileId) =>
    Directory(p.join(profilesDir.path, '${fs.profileDirPrefix}$profileId'));
