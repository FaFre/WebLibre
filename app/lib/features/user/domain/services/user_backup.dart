/*
 * Copyright (c) 2024-2025 Fabian Freund.
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

import 'package:convert/convert.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:secure_archive/secure_archive.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';

part 'user_backup.g.dart';

@Riverpod(keepAlive: true)
class UserBackupService extends _$UserBackupService {
  static final dateFormatter = FixedDateTimeFormatter('YYYY-MM-DD_hhmmss');

  Future<Directory> getBackupDirectory() async {
    return Directory(
      p.join(
        await getExternalStorageDirectory().then(
          (dir) => Directory(
            dir!.path.replaceFirst('/data/', '/media/'),
          ).parent.path,
        ),
        'Backup',
      ),
    );
  }

  Stream<File> getBackupListStream() async* {
    final backupDirectory = await getBackupDirectory();

    await for (final entity in backupDirectory.list(recursive: true)) {
      if (entity is File) {
        yield entity;
      }
    }
  }

  Future<bool> createUserBackup(
    Profile profile, {
    required String password,
    required bool integrityCheck,
  }) async {
    final timestamp = dateFormatter.encode(DateTime.now());

    final outputFile = File(
      p.join(
        await getBackupDirectory().then((dir) => dir.path),
        'backup_${profile.name}_$timestamp.weblibre',
      ),
    );

    await outputFile.parent.create(recursive: true);

    final backup = SecureArchivePack(
      outputFile: outputFile,
      sourceDirectory: filesystem.getProfileDir(profile.uuidValue),
      argon2Params: Argon2Params.memoryConstrained(),
    );

    await backup.pack(password, integrityCheck: integrityCheck);

    return true;
  }

  Future<bool> restoreAndCreateNew(
    File backupFile, {
    required String profileName,
    required String password,
  }) async {
    final outputDirectory = Directory(
      p.join(filesystem.profilesDir.path, p.basename(backupFile.path)),
    );

    try {
      final backup = SecureArchiveUnpack(
        inputFile: backupFile,
        outputDirectory: outputDirectory,
        argon2Params: Argon2Params.memoryConstrained(),
      );
      await backup.unpack(password).then((_) async {
        final newProfile = Profile.create(name: profileName);
        final newPath = filesystem.getProfileDir(newProfile.uuidValue);

        await outputDirectory.rename(newPath.path);
        await filesystem.updateProfileMetadata(newProfile);
      });

      ref.invalidate(profileRepositoryProvider);
      return true;
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

  Future<bool> restoreAndCreateOrOverride(
    File backupFile, {
    required String password,
    required FutureOr<bool?> Function() confirmOverrideCallback,
  }) async {
    final outputDirectory = Directory(
      p.join(filesystem.profilesDir.path, p.basename(backupFile.path)),
    );

    try {
      final backup = SecureArchiveUnpack(
        inputFile: backupFile,
        outputDirectory: outputDirectory,
        argon2Params: Argon2Params.memoryConstrained(),
      );
      await backup.unpack(password).then((_) async {
        final existingProfile = await filesystem.readProfileMetadata(
          outputDirectory,
        );
        if (existingProfile != null) {
          if (existingProfile.uuidValue == filesystem.selectedProfile) {
            throw Exception(
              'Unable to override active User, please switch to another User and try again',
            );
          }

          final profileDir = filesystem.getProfileDir(
            existingProfile.uuidValue,
          );

          if (await profileDir.exists()) {
            final result = await confirmOverrideCallback();

            if (result == true) {
              await profileDir.delete(recursive: true);
              await outputDirectory.rename(profileDir.path);
            }
          }
        }
      });

      ref.invalidate(profileRepositoryProvider);
      return true;
    } finally {
      await outputDirectory.delete(recursive: true);
    }
  }

  @override
  void build() {}
}
