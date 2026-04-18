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

import 'package:convert/convert.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_util/saf_util_platform_interface.dart';
import 'package:secure_archive/secure_archive.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/domain/providers/backup_directory.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';

part 'user_backup.g.dart';

@Riverpod(keepAlive: true)
class UserBackupService extends _$UserBackupService {
  static final dateFormatter = FixedDateTimeFormatter('YYYY-MM-DD_hhmmss');
  static const _excludedBackupRelativePaths = {'cache'};

  static final _safUtil = SafUtil();
  static final _safStream = SafStream();

  bool _isExcludedBackupPath(String relativePath) {
    final normalizedPath = p.normalize(relativePath);

    for (final excludedPath in _excludedBackupRelativePaths) {
      if (normalizedPath == excludedPath ||
          p.isWithin(excludedPath, normalizedPath)) {
        return true;
      }
    }

    return false;
  }

  Future<void> _copyCuratedBackupSource(
    Directory rootDirectory,
    Directory sourceDirectory,
    Directory targetDirectory,
  ) async {
    await targetDirectory.create(recursive: true);

    await for (final entity in sourceDirectory.list(followLinks: false)) {
      final relativePath = p.relative(entity.path, from: rootDirectory.path);

      if (_isExcludedBackupPath(relativePath)) {
        continue;
      }

      final targetPath = p.join(targetDirectory.path, p.basename(entity.path));

      if (entity is Directory) {
        await _copyCuratedBackupSource(
          rootDirectory,
          entity,
          Directory(targetPath),
        );
      } else if (entity is File) {
        await entity.copy(targetPath);
      } else if (entity is Link) {
        await Link(targetPath).create(await entity.target());
      }
    }
  }

  Future<Directory> _prepareBackupSourceDirectory(
    Directory sourceDirectory, {
    required bool skipCaches,
  }) async {
    if (!skipCaches) {
      return sourceDirectory;
    }

    final tempDirectory = await getTemporaryDirectory();
    final curatedDirectory = Directory(
      p.join(
        tempDirectory.path,
        'backup_source_${DateTime.now().microsecondsSinceEpoch}',
      ),
    );

    try {
      await _copyCuratedBackupSource(
        sourceDirectory,
        sourceDirectory,
        curatedDirectory,
      );
      return curatedDirectory;
    } catch (_) {
      try {
        if (await curatedDirectory.exists()) {
          await curatedDirectory.delete(recursive: true);
        }
      } catch (_) {
        // Ignore cleanup errors for partially copied backup sources.
      }
      rethrow;
    }
  }

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

  Future<bool> createUserBackup(
    Profile profile, {
    required String password,
    required bool integrityCheck,
    required bool skipCaches,
  }) async {
    final dirUri = _requireBackupDirectoryUri();
    final timestamp = dateFormatter.encode(DateTime.now());
    final fileName = 'backup_${profile.name}_$timestamp.weblibre';
    final sourceDirectory = filesystem.getProfileDir(profile.uuidValue);

    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, fileName));
    Directory? curatedSourceDirectory;

    try {
      curatedSourceDirectory = await _prepareBackupSourceDirectory(
        sourceDirectory,
        skipCaches: skipCaches,
      );

      final backup = SecureArchivePack(
        outputFile: tempFile,
        sourceDirectory: curatedSourceDirectory,
        argon2Params: Argon2Params.memoryConstrained(),
      );

      await backup.pack(password, integrityCheck: integrityCheck);

      await _safStream.pasteLocalFile(
        tempFile.path,
        dirUri.toString(),
        fileName,
        'application/octet-stream',
      );

      return true;
    } finally {
      try {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (e, s) {
        logger.w(
          'Failed to cleanup temporary backup file: ${tempFile.path}',
          error: e,
          stackTrace: s,
        );
      }
      if (curatedSourceDirectory != null &&
          curatedSourceDirectory.path != sourceDirectory.path) {
        try {
          if (await curatedSourceDirectory.exists()) {
            await curatedSourceDirectory.delete(recursive: true);
          }
        } catch (e, s) {
          logger.w(
            'Failed to cleanup curated backup directory: ${curatedSourceDirectory.path}',
            error: e,
            stackTrace: s,
          );
        }
      }
    }
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
      await _safStream.copyToLocalFile(backupFileUri.toString(), tempFile.path);

      final backup = SecureArchiveUnpack(
        inputFile: tempFile,
        outputDirectory: outputDirectory,
        argon2Params: Argon2Params.memoryConstrained(),
      );
      final newProfile = await backup.unpack(password).then((_) async {
        final newProfile = Profile.create(name: profileName);
        final newPath = filesystem.getProfileDir(newProfile.uuidValue);

        await outputDirectory.rename(newPath.path);
        await filesystem.updateProfileMetadata(newProfile);
        await filesystem.healProfile(newPath);
        return newProfile;
      });

      ref.invalidate(profileRepositoryProvider);
      return newProfile;
    } finally {
      try {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (e, s) {
        logger.w(
          'Failed to cleanup temporary restore file: ${tempFile.path}',
          error: e,
          stackTrace: s,
        );
      }
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
    Uri backupFileUri, {
    required String password,
    required FutureOr<bool?> Function() confirmOverrideCallback,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, 'restore_temp.weblibre'));

    final outputDirectory = Directory(
      p.join(filesystem.profilesDir.path, 'restore_temp'),
    );

    try {
      await _safStream.copyToLocalFile(backupFileUri.toString(), tempFile.path);

      final backup = SecureArchiveUnpack(
        inputFile: tempFile,
        outputDirectory: outputDirectory,
        argon2Params: Argon2Params.memoryConstrained(),
      );
      await backup.unpack(password).then((_) async {
        final existingProfile = await filesystem.readProfileMetadata(
          outputDirectory,
        );
        if (existingProfile == null) {
          throw Exception('Backup does not contain valid profile metadata');
        }

        if (existingProfile.uuidValue == filesystem.selectedProfile) {
          throw Exception(
            'Unable to override active User, please switch to another User and try again',
          );
        }

        final profileDir = filesystem.getProfileDir(existingProfile.uuidValue);

        if (await profileDir.exists()) {
          final result = await confirmOverrideCallback();

          if (result == true) {
            await profileDir.delete(recursive: true);
            await outputDirectory.rename(profileDir.path);
            await filesystem.healProfile(profileDir);
          }
        } else {
          // Profile doesn't exist yet, just move the restored data into place
          await outputDirectory.rename(profileDir.path);
          await filesystem.healProfile(profileDir);
        }
      });

      ref.invalidate(profileRepositoryProvider);
      return true;
    } finally {
      try {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (e, s) {
        logger.w(
          'Failed to cleanup temporary restore file: ${tempFile.path}',
          error: e,
          stackTrace: s,
        );
      }
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
