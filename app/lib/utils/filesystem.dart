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
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid_value.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/extensions/iterable.dart';

const profilesDirName = 'weblibre_profiles';
const profileDirPrefix = 'profile-';

const _startupProfileFileName = 'current_profile';
const _metadataFile = 'metadata.json';

final profileTransformer =
    StreamTransformer<FileSystemEntity, Directory>.fromHandlers(
      handleData: (entity, sink) {
        if (entity is Directory &&
            p.basename(entity.path).startsWith(profileDirPrefix)) {
          sink.add(entity);
        }
      },
    );

final profileMozillaDirectoryTransformer =
    StreamTransformer<Directory, Directory>.fromHandlers(
      handleData: (entity, sink) {
        final mozillaDir = Directory(p.join(entity.path, 'mozilla'));

        if (mozillaDir.existsSync()) {
          for (final entity in mozillaDir.listSync()) {
            if (entity is Directory) {
              final profile = p.basename(entity.path);
              if (profile.endsWith('.default')) {
                sink.add(entity);
              }
            }
          }
        }
      },
    );

Future<List<Directory>> getAvailableProfileDirectories(Directory profilesDir) {
  return profilesDir.list().transform(profileTransformer).toList();
}

Future<void> clearMozillaProfileCache(String profileId) async {
  final cacheDir = await getApplicationCacheDirectory();
  final mozillaCacheDir = Directory(p.join(cacheDir.path, profileId));

  if (await mozillaCacheDir.exists()) {
    await mozillaCacheDir.delete(recursive: true);
  }
}

Future<List<Directory>> getProfilesWithDuplicateMozillaProfiles(
  Directory profilesDir,
) async {
  final mozillaProfileDirs = await profilesDir
      .list()
      .transform(profileTransformer)
      .transform(profileMozillaDirectoryTransformer)
      .toList();

  final duplicates = mozillaProfileDirs
      .map((dir) => p.basename(dir.path))
      .findDuplicates()
      .toSet();

  return mozillaProfileDirs
      .where((dir) => duplicates.contains(p.basename(dir.path)))
      .toList();
}

Future<UuidValue?> readStartupProfile(Directory dir) async {
  final file = File(p.join(dir.path, _startupProfileFileName));

  if (await file.exists()) {
    final contents = await file.readAsString();
    try {
      return UuidValue.withValidation(contents);
    } catch (e, s) {
      logger.e('Could not parse profile', error: e, stackTrace: s);
    }
  }

  return null;
}

Future<void> writeStartupProfile(
  Directory dir,
  UuidValue profile, {
  bool flush = false,
}) async {
  final file = File(p.join(dir.path, _startupProfileFileName));
  await file.writeAsString(profile.uuid, flush: flush);
}

Future<UuidValue?> selectStartupProfile(Directory profilesDir) async {
  var startupProfile = await readStartupProfile(profilesDir);
  final availableProfiles = await getAvailableProfileDirectories(profilesDir);

  if (startupProfile == null) {
    final sortedDirs = await sortByAccessTime(availableProfiles);

    for (final dir in sortedDirs) {
      try {
        startupProfile = extractDirectoryUuid(dir);
        await writeStartupProfile(profilesDir, startupProfile);

        break;
      } catch (e, s) {
        logger.w('Could not parse profile folder', error: e, stackTrace: s);
      }
    }
  }

  return startupProfile;
}

UuidValue extractDirectoryUuid(Directory dir) => UuidValue.withValidation(
  p.basename(dir.path).substring(profileDirPrefix.length),
);

Directory getProfileDir(Directory profilesDir, UuidValue profileUuid) {
  return Directory(
    p.join(profilesDir.path, '$profileDirPrefix${profileUuid.uuid}'),
  );
}

Future<Profile?> readProfileMetadata(Directory profileDir) async {
  final file = File(p.join(profileDir.path, _metadataFile));
  if (!await file.exists()) {
    return null;
  }

  final content = await file.readAsString();
  return Profile.fromJson(jsonDecode(content) as Map<String, dynamic>);
}

Future<void> writeProfileMetadata(Directory profileDir, Profile profile) async {
  final file = File(p.join(profileDir.path, _metadataFile));
  await file.writeAsString(jsonEncode(profile.toJson()), flush: true);
}

Future<bool> createNewProfile(Directory profilesDir, Profile profile) async {
  final profileDir = getProfileDir(profilesDir, profile.uuidValue);

  if (await profileDir.exists()) {
    return false;
  }
  await profileDir.create();
  await writeProfileMetadata(profileDir, profile);

  return true;
}

Future<List<Directory>> sortByAccessTime(
  List<Directory> dirs, {
  bool descending = true,
}) async {
  final dirsWithStats = await Future.wait(
    dirs.map((dir) async {
      final stat = await dir.stat();
      return (dir: dir, accessed: stat.accessed);
    }),
  );

  dirsWithStats.sort((a, b) {
    final comparison = a.accessed.compareTo(b.accessed);
    return descending ? -comparison : comparison;
  });

  return dirsWithStats.map((record) => record.dir).toList();
}
