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

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sqlite3/sqlite3.dart';

import 'package:uuid/uuid.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/startup/maintenance_scanner.dart';
import 'package:weblibre/core/startup/profile_discovery.dart' as discovery;
import 'package:weblibre/core/startup/startup_config_store.dart';
import 'package:weblibre/core/startup/startup_paths.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;

/// Any `files/mozilla/` prefix belonging to a *different* profile, or to the
/// pre-multi-profile layout.
///
/// The second alternative is the original migration case: `{filesDir}/mozilla`
/// used to be a real directory and is now a symlink into the active profile.
/// The first is the one a restore needs — see [healExtensionPaths].
RegExp _foreignMozillaPrefix(Directory filesDir) => RegExp(
  '${RegExp.escape(filesDir.path)}/'
  '(?:${RegExp.escape(fs.profilesDirName)}/${RegExp.escape(fs.profileDirPrefix)}'
  '[0-9a-fA-F-]{36}/files/mozilla/|mozilla/)',
);

/// Re-points absolute paths in `extensions.json` at the profile they now live
/// in. Returns `true` if any were rewritten.
///
/// Two cases, one rule. The original one is the pre-multi-profile layout:
/// `{filesDir}/mozilla/…` became `{profile}/files/mozilla/…`, with a symlink
/// bridging them, and rewriting removes the permanent dependency on that
/// symlink.
///
/// The second is a restore, and it is why this matches *any* profile's prefix
/// rather than only the legacy one. Gecko stores absolute add-on paths, and
/// healing rewrites them to the real profile directory on first activation —
/// so an archive taken afterwards carries `…/profile-<sourceUuid>/…` inside
/// `extensions.json`. Installing that tree under a different uuid — always
/// true for a restore into a new user, and possible for a replace since
/// `bindStagingToTarget` re-addresses the tree — used to leave every add-on
/// pointing into the profile the backup came from: loading another user's
/// extension files if that profile still exists, and loading nothing if it
/// does not.
///
/// The rewrite is what makes [_healGeckoStartupCaches] run for a restored
/// profile, which matters as much: `addonStartup.json.lz4` and `startupCache`
/// travel inside the archive and cache the same stale absolute paths.
Future<bool> healExtensionPaths(
  Directory filesDir,
  Directory profileDir,
) async {
  final profileIds = fs.getMozillaProfileIds(profileDir);
  final foreign = _foreignMozillaPrefix(filesDir);
  final newPrefix = '${profileDir.path}/files/mozilla/';

  /// Returns null when [value] already addresses this profile.
  String? rewrite(Object? value) {
    if (value is! String) return null;
    final healed = value.replaceAll(foreign, newPrefix);
    return healed == value ? null : healed;
  }

  var migrated = false;

  for (final profileId in profileIds) {
    final extensionsFile = File(
      p.join(profileDir.path, 'files', 'mozilla', profileId, 'extensions.json'),
    );

    if (!await extensionsFile.exists()) continue;

    try {
      final content = await extensionsFile.readAsString();
      // Cheap reject: a file already addressed to this profile still matches
      // [foreign] but rewrites to itself, and decoding plus re-encoding it on
      // every launch would churn the file for nothing. Scanning the raw string
      // for a prefix that is *not* ours settles that without a `jsonDecode`.
      final hasForeignPrefix = foreign
          .allMatches(content)
          .any((match) => match.group(0) != newPrefix);
      if (!hasForeignPrefix) continue;

      final json = jsonDecode(content);
      var changed = false;

      if (json is Map<String, dynamic> && json['addons'] is List) {
        for (final addon in json['addons'] as List) {
          if (addon is! Map<String, dynamic>) continue;

          for (final key in const ['path', 'rootURI']) {
            final healed = rewrite(addon[key]);
            if (healed != null) {
              addon[key] = healed;
              changed = true;
            }
          }
        }
      }

      if (changed) {
        await extensionsFile.writeAsString(jsonEncode(json), flush: true);
        logger.i('Re-pointed extension paths in $profileId/extensions.json');
        migrated = true;
      }
    } catch (e, s) {
      logger.w(
        'Failed to heal extension paths for $profileId',
        error: e,
        stackTrace: s,
      );
    }
  }

  return migrated;
}

final filesystem = _Filesystem();

class _Filesystem {
  // Profile-independent state, resolved by [initializeGlobalPaths]. Nullable
  // backing fields rather than `late final` so a second call is a no-op instead
  // of a reassignment error, and so tests can point the singleton at a fresh
  // temp tree between cases.
  Directory? _dataDir;
  Directory? _tempDir;
  StartupPaths? _startupPaths;

  bool get isGlobalPathsReady => _startupPaths != null;

  Directory get dataDir => _require(_dataDir, 'dataDir', _globalHint);
  Directory get tempDir => _require(_tempDir, 'tempDir', _globalHint);
  StartupPaths get startupPaths =>
      _require(_startupPaths, 'startupPaths', _globalHint);
  Directory get profilesDir => startupPaths.profilesDir;

  // Profile-bound state, set by [activate] and only after the native arbiter
  // committed the process to this profile. Guarded rather than `late final` so
  // reading one early is a described error instead of a bare
  // LateInitializationError, and so a second activation is caught as the rebind
  // it would be.
  UuidValue? _selectedProfile;
  Directory? _selectedProfileDir;
  Directory? _profileDatabasesDir;
  String? _relativeProfilePath;

  bool get isActivated => _selectedProfile != null;

  UuidValue get selectedProfile =>
      _require(_selectedProfile, 'selectedProfile', _profileHint);
  Directory get selectedProfileDir =>
      _require(_selectedProfileDir, 'selectedProfileDir', _profileHint);
  Directory get profileDatabasesDir =>
      _require(_profileDatabasesDir, 'profileDatabasesDir', _profileHint);
  String get relativeProfilePath =>
      _require(_relativeProfilePath, 'relativeProfilePath', _profileHint);

  static const _globalHint =
      'filesystem.initializeGlobalPaths() has not completed';
  static const _profileHint =
      'no profile is activated; the process has not committed one yet';

  static T _require<T>(T? value, String name, String hint) {
    if (value == null) {
      throw StateError('$name read but $hint');
    }
    return value;
  }

  /// Test seam: forgets all resolved state so a new temp tree can be installed.
  /// Never call from production code.
  @visibleForTesting
  void resetForTest() {
    _dataDir = null;
    _tempDir = null;
    _startupPaths = null;
    _selectedProfile = null;
    _selectedProfileDir = null;
    _profileDatabasesDir = null;
    _relativeProfilePath = null;
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
    final newDir = Directory(p.join(profileDir.path, 'files', 'mozilla'));

    final oldType = await FileSystemEntity.type(
      oldDir.path,
      followLinks: false,
    );

    if (oldType == FileSystemEntityType.directory && !await newDir.exists()) {
      await Directory(p.join(profileDir.path, 'files')).create(recursive: true);
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
      final newCache = Directory(p.join(profileDir.path, 'cache', profileId));

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
    final mozillaDir = Directory(p.join(profileDir.path, 'files', 'mozilla'));
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

  /// Run all post-migration healing for a profile directory.
  /// Called during init for the active profile and after backup restore.
  Future<void> healProfile(Directory profileDir) async {
    final filesDir = profilesDir.parent;
    final dirMigrated = await _migrateMozillaDirToFiles(profileDir);
    await _migrateGeckoCache(profileDir);
    final pathsMigrated = await healExtensionPaths(filesDir, profileDir);

    // Only update the global symlink for the currently active profile —
    // restoring a non-active profile must not repoint it. The activation guard
    // matters as much as the path comparison: maintenance heals profiles this
    // process has deliberately not bound, and asking which profile is active
    // there would throw rather than answer "none of them".
    final isActiveProfile =
        isActivated && profileDir.path == selectedProfileDir.path;
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
    final tempDir = await path_provider.getTemporaryDirectory();
    _tempDir = tempDir;
    final cachebase = tempDir.path;
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

  /// Profile-independent startup work.
  ///
  /// Resolves the app directories and creates the profiles root and the
  /// maintenance workspace. It deliberately does not enumerate, create, read
  /// metadata from, repair, or migrate a profile directory — none of that is
  /// legal until the process has decided which profile it is on, and maintenance
  /// may mean it never does.
  Future<void> initializeGlobalPaths() async {
    if (isGlobalPathsReady) return;

    final filesDir = await path_provider.getApplicationSupportDirectory();
    final paths = StartupPaths(filesDir);
    await paths.ensureGlobalDirectories();

    _dataDir = filesDir.parent;
    _startupPaths = paths;

    await _setupSqliteCache();
  }

  /// Whether durable evidence says a profile maintenance operation owns this
  /// process.
  ///
  /// Read from the same files Kotlin's `MaintenanceReservation` reads, and
  /// deliberately independent of `startup_config.json` alone: a corrupt or lost
  /// task list must not be able to release the reservation, because it is the
  /// journals and restore workspaces that prove an operation was in flight.
  ///
  /// Until the arbitration Pigeon API lands (plan phase 5), this is Dart's own
  /// read rather than a query to the native arbiter. The shared fixtures under
  /// `packages/flutter_mozilla_components/test_fixtures/startup/` are what keep
  /// the two answers identical.
  Future<MaintenanceReservation> resolveMaintenanceReservation() async {
    await initializeGlobalPaths();

    final config = await StartupConfigStore(startupPaths).read();
    final scan = await MaintenanceScanner(startupPaths).scan();

    return MaintenanceReservation.resolve(config, scan);
  }

  /// Profile enumeration and first-run profile creation.
  ///
  /// Requires the caller to hold a native selection or maintenance lease.
  /// That lease is the only window in which reading, creating, or migrating a
  /// profile directory is legal, because it is the only time nothing else in
  /// the process can commit underneath the caller. The id is a parameter rather
  /// than an assumption so the precondition cannot be forgotten at a call site;
  /// validating it is native's job, since native is the only holder of the
  /// authoritative state.
  ///
  /// This never writes `current_profile`. The native commit does, and writing it
  /// from here would let a process that never committed change what the next one
  /// boots.
  Future<discovery.ProfileDiscovery> discoverProfiles(String leaseId) async {
    if (leaseId.isEmpty) {
      throw ArgumentError.value(
        leaseId,
        'leaseId',
        'profile discovery requires a native startup lease',
      );
    }

    var found = await discovery.discoverProfiles(profilesDir);

    // Rebuilt before the list is judged empty, and before a fresh `Default`
    // could be created beside data the user still has. A profile whose
    // `metadata.json` was truncated by a crash on a build before that write
    // became atomic is otherwise skipped forever, with its whole directory
    // intact and unreachable. Only defects whose identity is not in doubt are
    // touched — see [discovery.repairDamagedProfiles].
    if (found.damaged.any(
      (entry) => discovery.isRepairableDefect(entry.defect),
    )) {
      if (await discovery.repairDamagedProfiles(found) > 0) {
        found = await discovery.discoverProfiles(profilesDir);
      }
    }

    if (found.profiles.isNotEmpty) {
      return found;
    }

    // First run, or every profile is damaged beyond rebuilding. Create the one
    // the caller will commit; it stays uncommitted until native says otherwise,
    // so a crash here leaves an unreferenced directory rather than a half-bound
    // process.
    final defaultProfile = Profile.create(name: 'Default');
    if (!await fs.createNewProfile(profilesDir, defaultProfile)) {
      throw Exception('Unable to create default profile');
    }

    await _migrateLegacyMozillaDir(defaultProfile);

    return discovery.discoverProfiles(profilesDir);
  }

  /// Moves a pre-multi-profile `files/mozilla` tree into the first profile.
  ///
  /// Only ever runs for a freshly created `Default`: once any profile exists the
  /// global directory is a symlink into it, and re-running would move a live
  /// profile's data out from under it.
  Future<void> _migrateLegacyMozillaDir(Profile defaultProfile) async {
    final filesDir = startupPaths.filesDir;
    final mozillaDir = Directory(p.join(filesDir.path, 'mozilla'));
    if (!await mozillaDir.exists()) return;
    if (await FileSystemEntity.type(mozillaDir.path) ==
        FileSystemEntityType.link) {
      return;
    }

    await _migrate(defaultProfile, mozillaDir, filesDir);
  }

  /// Binds this process to [profileId] and does the profile-bound setup.
  ///
  /// Legal only after the native arbiter committed the same profile. The
  /// rebind guard is not defensive programming: the Gecko runtime is bound once
  /// per process and cannot be re-pointed, so a second activation would leave
  /// Dart and Gecko reading different profiles with no way to reconcile them.
  Future<void> activate(UuidValue profileId) async {
    final active = _selectedProfile;
    if (active != null) {
      if (active == profileId) return;
      throw StateError(
        'Refusing to rebind this process from $active to $profileId; the '
        'process profile is immutable and switching requires a restart',
      );
    }

    final relativePath = p.join(
      fs.profilesDirName,
      '${fs.profileDirPrefix}${profileId.uuid}',
    );
    final profileDir = Directory(
      p.join(startupPaths.filesDir.path, relativePath),
    );
    await profileDir.create(recursive: true);

    final databasesDir = Directory(p.join(profileDir.path, 'databases'));
    await databasesDir.create();

    _selectedProfile = profileId;
    _relativeProfilePath = relativePath;
    _selectedProfileDir = profileDir;
    _profileDatabasesDir = databasesDir;

    await healProfile(profileDir);
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
