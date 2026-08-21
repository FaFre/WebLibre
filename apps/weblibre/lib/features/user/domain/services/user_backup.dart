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
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_util/saf_util_platform_interface.dart';
import 'package:secure_archive/secure_archive.dart';
import 'package:weblibre/core/copy/profile_copy.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/maintenance/clone_participant_policy.dart';
import 'package:weblibre/core/maintenance/saf_archive_target.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/core/startup/startup_config_store.dart';
import 'package:weblibre/core/uuid.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/domain/providers/backup_directory.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;

part 'user_backup.g.dart';

@Riverpod(keepAlive: true)
class UserBackupService extends _$UserBackupService {
  static final _safUtil = SafUtil();
  static final _safStream = SafStream();

  Uri _requireBackupDirectoryUri() {
    final uri = ref.read(backupDirectoryUriProvider);
    if (uri == null) {
      throw Exception('No backup directory configured');
    }
    return uri;
  }

  Future<List<SafDocumentFile>> getBackupList(Uri dirUri) async {
    final files = await _safUtil.list(dirUri.toString());
    return files
        .where((f) => !f.isDir && f.name.endsWith('.weblibre'))
        .toList();
  }

  /// Queues a backup of [profile] and arms the restart that will run it.
  ///
  /// The backup itself deliberately does not happen here. A consistent archive
  /// needs the profile to have no writers, and this process is the writer — it
  /// has the databases open and the engine running. So the task is recorded
  /// durably, the process restarts, and the next one runs it under a maintenance
  /// lease before it opens anything.
  ///
  /// The SAF target travels in the task record because it normally lives in
  /// profile settings, which the maintenance process cannot read. The password
  /// deliberately does not: it is asked for again on the maintenance screen.
  Future<MaintenanceTask> queueBackup(
    Profile profile, {
    required bool integrityCheck,
  }) async {
    final dirUri = _requireBackupDirectoryUri();

    final task = MaintenanceTask.create(
      id: uuid.v4(),
      action: MaintenanceAction.backup,
      profileId: profile.uuidValue.uuid,
      profileName: profile.name,
      createdAt: DateTime.now().toUtc(),
      targetTreeUri: dirUri.toString(),
      integrityCheck: integrityCheck,
    );

    await StartupConfigStore(filesystem.startupPaths).enqueueTask(task);

    final armed = await GeckoProfileService().armProfileRestart(
      reason: 'maintenanceBackup',
    );
    if (!armed) {
      // Leaving the task queued would reserve maintenance on the next start with
      // nothing having asked for it.
      await StartupConfigStore(filesystem.startupPaths).removeTask(task.id);
      throw Exception(restartCouldNotBeScheduled);
    }

    return task;
  }

  Future<Profile> restoreAndCreateNew(
    Uri backupFileUri, {
    required String profileName,
    required String password,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, 'restore_temp.weblibre'));

    final outputDirectory = Directory(
      p.join(filesystem.profilesDir.path, 'restore_temp'),
    );

    try {
      final newProfile = await withArchiveFromSaf(
        sourceUri: backupFileUri,
        local: tempFile,
        safStream: _safStream,
        use: (archive) async {
          // The extractor refuses a target directory that already exists, so a
          // previous attempt that died before its cleanup would otherwise make
          // every later restore fail. Nothing of value can be in here: it is a
          // scratch path that only ever holds a half-unpacked archive.
          if (await outputDirectory.exists()) {
            await outputDirectory.delete(recursive: true);
          }

          await SecureArchiveUnpack(
            inputFile: archive,
            outputDirectory: outputDirectory,
            argon2Params: Argon2Params.memoryConstrained(),
          ).unpack(password);

          final newProfile = Profile.create(name: profileName);
          final newPath = filesystem.getProfileDir(newProfile.uuidValue);

          // Before the tree becomes a profile. The archive carries a
          // `weblibre_participants/` payload describing the profile it was taken
          // *from* — including its account session and proxy credentials as
          // plain JSON — and a clone is a different profile that must not
          // inherit it. See [applyCloneParticipantPolicy] for what a future
          // build could keep.
          await applyCloneParticipantPolicy(outputDirectory);

          // Addressed to its new id *before* the rename, never after. The
          // archive's own `metadata.json` names the profile it was taken from,
          // so a tree that reaches `profile-<newId>` still carrying it is in the
          // one state discovery refuses to list or repair —
          // `metadataUuidMismatch` — and a process killed between the two steps
          // left that permanently: a full profile directory, intact on disk and
          // invisible to the picker, the candidate resolver and the profile
          // list. Writing first makes the rename the single commit point, so an
          // interruption leaves a scratch directory instead.
          await fs.writeProfileMetadata(outputDirectory, newProfile);

          await outputDirectory.rename(newPath.path);
          await filesystem.healProfile(newPath);
          return newProfile;
        },
      );

      ref.invalidate(profileRepositoryProvider);
      return newProfile;
    } finally {
      try {
        if (await outputDirectory.exists()) {
          await outputDirectory.delete(recursive: true);
        }
      } catch (e, s) {
        logger.w(
          'Failed to cleanup temporary backup directory: ${outputDirectory.path}',
          error: e,
          stackTrace: s,
        );
      }
    }
  }

  /// Queues a journaled restore over [profile] and arms the restart that runs it.
  ///
  /// The archive is not opened here and the password is not asked for here. Both
  /// happen in the maintenance process, which is the only one entitled to replace
  /// a profile's contents — and, because it has never opened the profile, the only
  /// one that can do it to the *currently active* profile at all. The old inline
  /// path could not: it deleted the target directory and renamed staging into
  /// place, so a crash between those two steps destroyed the profile with no
  /// record that anything had been in flight.
  /// [adoptArchiveName] renames the target to whatever the archive calls itself.
  /// Only the first-run restore sets it: elsewhere the user picked an existing
  /// user to overwrite and did not ask to rename it.
  Future<MaintenanceTask> queueRestoreOver(
    Profile profile, {
    required Uri sourceFileUri,
    bool adoptArchiveName = false,
  }) async {
    final task = MaintenanceTask.create(
      id: uuid.v4(),
      action: MaintenanceAction.restoreOver,
      profileId: profile.uuidValue.uuid,
      profileName: profile.name,
      createdAt: DateTime.now().toUtc(),
      sourceFileUri: sourceFileUri.toString(),
      adoptArchiveName: adoptArchiveName,
    );

    final store = StartupConfigStore(filesystem.startupPaths);
    await store.enqueueTask(task);

    if (!await GeckoProfileService().armProfileRestart(
      reason: 'maintenanceRestore',
    )) {
      await store.removeTask(task.id);
      throw Exception(restartCouldNotBeScheduled);
    }

    return task;
  }

  Future<int> migrateOldBackups(Uri newDirUri) async {
    try {
      final oldDir = Directory(
        p.join(
          await getExternalStorageDirectory().then(
            (dir) => Directory(
              dir!.path.replaceFirst('/data/', '/media/'),
            ).parent.path,
          ),
          'Backup',
        ),
      );

      if (!await oldDir.exists()) return 0;

      var count = 0;
      await for (final entity in oldDir.list()) {
        if (entity is File && entity.path.endsWith('.weblibre')) {
          try {
            await _safStream.pasteLocalFile(
              entity.path,
              newDirUri.toString(),
              p.basename(entity.path),
              'application/octet-stream',
            );
            await entity.delete();
            count++;
          } catch (e, s) {
            logger.w(
              'Failed to migrate backup: ${entity.path}',
              error: e,
              stackTrace: s,
            );
          }
        }
      }

      // Clean up old directory if empty
      if (await oldDir.list().isEmpty) {
        await oldDir.delete();
      }

      return count;
    } catch (e, s) {
      logger.w('Failed to migrate old backups', error: e, stackTrace: s);
      return 0;
    }
  }

  @override
  void build() {}
}
