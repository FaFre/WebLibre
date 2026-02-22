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
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sqlite3/sqlite3.dart';

import 'package:uuid/uuid.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;

final filesystem = _Filesystem();

class _Filesystem {
  late final Directory dataDir;
  late final Directory profilesDir;

  late final UuidValue selectedProfile;
  late final Directory selectedProfileDir;
  late final Directory profileDatabasesDir;

  late final String relativeProfilePath;

  Future<List<Directory>> getAvailableProfileDirectories() {
    return profilesDir.list().transform(fs.profileTransformer).toList();
  }

  Future<Profile?> readProfileMetadata(Directory profileDir) {
    return fs.readProfileMetadata(profileDir);
  }

  Directory getProfileDir(UuidValue uuid) {
    return fs.getProfileDir(profilesDir, uuid);
  }

  Future<bool> createNewProfile(Profile profile) {
    return fs.createNewProfile(profilesDir, profile);
  }

  Future<void> updateProfileMetadata(Profile profile) {
    return fs.writeProfileMetadata(getProfileDir(profile.uuidValue), profile);
  }

  Future<void> setStartupProfile(UuidValue profile) {
    return fs.writeStartupProfile(profilesDir, profile, flush: true);
  }

  Future<void> clearMozillaProfileCache(String profileId) {
    return fs.clearMozillaProfileCache(selectedProfileDir, profileId);
  }

  List<String> getMozillaProfileIds(UuidValue uuid) {
    return fs.getMozillaProfileIds(getProfileDir(uuid));
  }

  /// If the old canonical location `{profileDir}/mozilla/` exists as a real
  /// directory and the new location `{profileDir}/files/mozilla/` does not,
  /// rename the former to the latter.
  /// Returns `true` if a migration was performed.
  static Future<bool> _migrateMozillaDirToFiles(Directory profileDir) async {
    final oldDir = Directory(p.join(profileDir.path, 'mozilla'));
    final newDir = Directory(
      p.join(profileDir.path, 'files', 'mozilla'),
    );

    final oldType = await FileSystemEntity.type(
      oldDir.path,
      followLinks: false,
    );

    if (oldType == FileSystemEntityType.directory && !await newDir.exists()) {
      await Directory(
        p.join(profileDir.path, 'files'),
      ).create(recursive: true);
      await oldDir.rename(newDir.path);
      return true;
    }
    return false;
  }

  Future<void> _migrateGeckoCache(Directory profileDir) async {
    final profileIds = fs.getMozillaProfileIds(profileDir);
    final globalCacheDir = Directory(p.join(dataDir.path, 'cache'));

    for (final profileId in profileIds) {
      final oldCache = Directory(p.join(globalCacheDir.path, profileId));
      final newCache = Directory(
        p.join(profileDir.path, 'cache', profileId),
      );

      if (await oldCache.exists() && !await newCache.exists()) {
        try {
          await oldCache.rename(newCache.path);
        } catch (e, s) {
          logger.w(
            'Failed to migrate Gecko cache for $profileId',
            error: e,
            stackTrace: s,
          );
        }
      }
    }
  }

  /// Ensure the top-level `{filesDir}/mozilla` symlink points to the given
  /// profile's `files/mozilla/` directory.  Old versions created this symlink
  /// targeting `{profile}/mozilla` which no longer exists after the migration
  /// moved it to `{profile}/files/mozilla`.  GeckoView's `extensions.json`
  /// stores absolute paths through this symlink, so it must stay valid.
  static Future<void> _linkMozillaDir(
    Directory filesDir,
    Directory profileDir,
  ) async {
    final mozillaDir = Directory(
      p.join(profileDir.path, 'files', 'mozilla'),
    );
    await mozillaDir.create(recursive: true);

    final mozillaPath = p.join(filesDir.path, 'mozilla');

    final currentType = await FileSystemEntity.type(
      mozillaPath,
      followLinks: false,
    );

    switch (currentType) {
      case FileSystemEntityType.notFound:
        break;
      case FileSystemEntityType.link:
        final link = Link(mozillaPath);
        try {
          if (await link.target() == mozillaDir.path) {
            return;
          }
        } on FileSystemException {
          // Replace unreadable or broken links.
        }
        await link.delete();
      default:
        // Move aside any non-link entity (directory, file, etc.)
        final backupPath = p.join(
          filesDir.path,
          'mozilla.backup.${DateTime.now().millisecondsSinceEpoch}',
        );
        if (currentType == FileSystemEntityType.directory) {
          await Directory(mozillaPath).rename(backupPath);
        } else {
          await File(mozillaPath).rename(backupPath);
        }
    }

    await Link(mozillaPath).create(mozillaDir.path);
  }

  /// Remove path-sensitive Gecko caches that may contain stale absolute paths.
  /// Gecko regenerates these on next startup.
  static Future<void> _healGeckoStartupCaches(Directory profileDir) async {
    final profileIds = fs.getMozillaProfileIds(profileDir);

    for (final profileId in profileIds) {
      final mozProfileDir = Directory(
        p.join(profileDir.path, 'files', 'mozilla', profileId),
      );
      if (!await mozProfileDir.exists()) continue;

      // addonStartup.json.lz4 caches absolute addon paths
      final addonStartup = File(
        p.join(mozProfileDir.path, 'addonStartup.json.lz4'),
      );
      if (await addonStartup.exists()) {
        try {
          await addonStartup.delete();
          logger.i('Cleared addonStartup.json.lz4 for $profileId');
        } catch (e, s) {
          logger.w(
            'Failed to clear addonStartup.json.lz4 for $profileId',
            error: e,
            stackTrace: s,
          );
        }
      }

      // startupCache may contain stale path references
      final startupCache = Directory(
        p.join(mozProfileDir.path, 'startupCache'),
      );
      if (await startupCache.exists()) {
        try {
          await startupCache.delete(recursive: true);
          logger.i('Cleared startupCache for $profileId');
        } catch (e, s) {
          logger.w(
            'Failed to clear startupCache for $profileId',
            error: e,
            stackTrace: s,
          );
        }
      }
    }
  }

  /// Rewrite absolute paths in `extensions.json` that still reference the
  /// old pre-migration layout (`{filesDir}/mozilla/…`).  After migration the
  /// real location is `{filesDir}/weblibre_profiles/profile-…/files/mozilla/…`
  /// and the top-level symlink bridges the two, but fixing the stored paths
  /// removes the permanent dependency on the symlink.
  /// Returns `true` if any paths were rewritten.
  static Future<bool> _migrateExtensionPaths(
    Directory filesDir,
    Directory profileDir,
  ) async {
    final profileIds = fs.getMozillaProfileIds(profileDir);
    // Pattern: /data/user/0/eu.weblibre.gecko/files/mozilla/
    // Should become: /data/user/0/eu.weblibre.gecko/files/weblibre_profiles/profile-…/files/mozilla/
    final oldPrefix = '${filesDir.path}/mozilla/';
    final newPrefix = '${profileDir.path}/files/mozilla/';

    if (oldPrefix == newPrefix) return false;

    var migrated = false;

    for (final profileId in profileIds) {
      final extensionsFile = File(
        p.join(
          profileDir.path,
          'files',
          'mozilla',
          profileId,
          'extensions.json',
        ),
      );

      if (!await extensionsFile.exists()) continue;

      try {
        final content = await extensionsFile.readAsString();
        if (!content.contains(oldPrefix)) continue;

        final json = jsonDecode(content);
        var changed = false;

        if (json is Map<String, dynamic> && json['addons'] is List) {
          for (final addon in json['addons'] as List) {
            if (addon is! Map<String, dynamic>) continue;

            final path = addon['path'];
            if (path is String && path.startsWith(oldPrefix)) {
              addon['path'] = path.replaceFirst(oldPrefix, newPrefix);
              changed = true;
            }

            final rootURI = addon['rootURI'];
            if (rootURI is String && rootURI.contains(oldPrefix)) {
              addon['rootURI'] = rootURI.replaceFirst(oldPrefix, newPrefix);
              changed = true;
            }
          }
        }

        if (changed) {
          await extensionsFile.writeAsString(
            jsonEncode(json),
            flush: true,
          );
          logger.i('Migrated extension paths in $profileId/extensions.json');
          migrated = true;
        }
      } catch (e, s) {
        logger.w(
          'Failed to migrate extension paths for $profileId',
          error: e,
          stackTrace: s,
        );
      }
    }

    return migrated;
  }

  /// Run all post-migration healing for a profile directory.
  /// Called during init for the active profile and after backup restore.
  Future<void> healProfile(Directory profileDir) async {
    final filesDir = profilesDir.parent;
    final dirMigrated = await _migrateMozillaDirToFiles(profileDir);
    await _migrateGeckoCache(profileDir);
    final pathsMigrated = await _migrateExtensionPaths(filesDir, profileDir);

    // Only update the global symlink for the currently active profile —
    // restoring a non-active profile must not repoint it.
    final isActiveProfile = profileDir.path == selectedProfileDir.path;
    if (isActiveProfile) {
      await _linkMozillaDir(filesDir, profileDir);
    }

    // Only clear Gecko startup caches when a path migration actually happened,
    // to avoid a recurring startup performance penalty.
    if (dirMigrated || pathsMigrated) {
      await _healGeckoStartupCaches(profileDir);
    }
  }

  Future<void> _setupSqliteCache() async {
    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await path_provider.getTemporaryDirectory()).path;
    // We can't access /tmp on Android, which sqlite3 would try by default.
    // Explicitly tell it about the correct temporary directory.
    sqlite3.tempDirectory = cachebase;
  }

  Future<void> _copyDirectory(
    Directory source,
    Directory destination,
    bool Function(FileSystemEntity e) filter,
  ) async {
    // Create destination directory
    await destination.create(recursive: true);

    // List all contents
    await for (final entity in source.list().where(filter)) {
      final newPath = p.join(destination.path, p.basename(entity.path));

      if (entity is Directory) {
        // Recursively copy subdirectory
        await _copyDirectory(entity, Directory(newPath), filter);
      } else if (entity is File) {
        // Copy file
        await entity.copy(newPath);
      } else if (entity is Link) {
        // Copy link
        await Link(newPath).create(await entity.target());
      }
    }
  }

  Future<void> init() async {
    final filesDir = await path_provider.getApplicationSupportDirectory();

    dataDir = filesDir.parent;

    profilesDir = Directory(p.join(filesDir.path, fs.profilesDirName));
    await profilesDir.create();

    final selectedProfile = await fs.selectStartupProfile(profilesDir);
    if (selectedProfile == null) {
      final defaultProfile = Profile.create(name: 'Default');
      if (!await fs.createNewProfile(profilesDir, defaultProfile)) {
        throw Exception('Unable to create default profile');
      }

      this.selectedProfile = defaultProfile.uuidValue;
      await fs.writeStartupProfile(profilesDir, defaultProfile.uuidValue);

      final mozillaDir = Directory(p.join(filesDir.path, 'mozilla'));
      if (await mozillaDir.exists()) {
        final type = await FileSystemEntity.type(mozillaDir.path);
        if (type != FileSystemEntityType.link) {
          await _migrate(defaultProfile, mozillaDir, filesDir);
        }
      }
    } else {
      this.selectedProfile = selectedProfile;
    }

    relativeProfilePath = p.join(
      fs.profilesDirName,
      '${fs.profileDirPrefix}${this.selectedProfile.uuid}',
    );
    selectedProfileDir = Directory(p.join(filesDir.path, relativeProfilePath));
    await selectedProfileDir.create();

    profileDatabasesDir = Directory(
      p.join(selectedProfileDir.path, 'databases'),
    );
    await profileDatabasesDir.create();

    await healProfile(selectedProfileDir);
    await _setupSqliteCache();
  }

  Future<void> _migrate(
    Profile defaultProfile,
    Directory mozillaDir,
    Directory filesDir,
  ) async {
    final profileDir = getProfileDir(defaultProfile.uuidValue);

    final newMozillaDir = Directory(
      p.join(profileDir.path, 'files', 'mozilla'),
    );
    await newMozillaDir.create(recursive: true);
    await mozillaDir.rename(newMozillaDir.path);

    await _copyDirectory(
      filesDir,
      Directory(p.join(profileDir.path, 'files')),
      (e) => e is! Directory || p.basename(e.path) != fs.profilesDirName,
    );

    final profileDatabasesDir = Directory(p.join(profileDir.path, 'databases'));

    await _copyDirectory(
      Directory(p.join(dataDir.path, 'databases')),
      profileDatabasesDir,
      (e) => true,
    );

    final dbFolder = await path_provider.getApplicationDocumentsDirectory();

    final bangDb = File(p.join(dbFolder.path, 'bang3.db'));
    await bangDb.copy(p.join(profileDatabasesDir.path, 'bang.db'));
    final feedDb = File(p.join(dbFolder.path, 'feed.db'));
    await feedDb.copy(p.join(profileDatabasesDir.path, 'feed.db'));
    final tabDb = File(p.join(dbFolder.path, 'tab2.db'));
    await tabDb.copy(p.join(profileDatabasesDir.path, 'tab.db'));
    final userDb = File(p.join(dbFolder.path, 'user.db'));
    await userDb.copy(p.join(profileDatabasesDir.path, 'user.db'));
  }
}
