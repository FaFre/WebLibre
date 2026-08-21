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
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid_value.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/entities/profile.dart';

const profilesDirName = 'weblibre_profiles';
const profileDirPrefix = 'profile-';

const startupProfileFileName = 'current_profile';
const profileMetadataFileName = 'metadata.json';

Future<void> clearMozillaProfileCache(
  Directory profileDir,
  String profileId,
) async {
  final cacheDir = Directory(p.join(profileDir.path, 'cache'));
  final mozillaCacheDir = Directory(p.join(cacheDir.path, profileId));

  if (await mozillaCacheDir.exists()) {
    await mozillaCacheDir.delete(recursive: true);
  }
}

/// Returns the list of Mozilla profile IDs (`.default` directory names)
/// inside the given profile directory's `files/mozilla/` subdirectory.
List<String> getMozillaProfileIds(Directory profileDir) {
  final mozillaDir = Directory(p.join(profileDir.path, 'files', 'mozilla'));
  if (!mozillaDir.existsSync()) return [];

  return mozillaDir
      .listSync()
      .whereType<Directory>()
      .map((dir) => p.basename(dir.path))
      .where((name) => name.endsWith('.default'))
      .toList();
}

Future<UuidValue?> readStartupProfile(Directory dir) async {
  final file = File(p.join(dir.path, startupProfileFileName));

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

/// Writes `current_profile`.
///
/// Native owns this file: it is written by the commit that binds a process to a
/// profile, and a Dart-side write would let a process that never committed
/// decide what the next one boots. Kept only so tests can stage the file the way
/// native leaves it.
@visibleForTesting
Future<void> writeStartupProfile(
  Directory dir,
  UuidValue profile, {
  bool flush = false,
}) async {
  final file = File(p.join(dir.path, startupProfileFileName));
  await file.writeAsString(profile.uuid, flush: flush);
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
  final file = File(p.join(profileDir.path, profileMetadataFileName));
  if (!await file.exists()) {
    return null;
  }

  final content = await file.readAsString();
  return Profile.fromJson(jsonDecode(content) as Map<String, dynamic>);
}

/// Writes `metadata.json` atomically.
///
/// A plain `writeAsString` truncates first, so a crash or power loss during a
/// rename left a zero-length or half-written file — and profile discovery treats
/// unreadable metadata as a *damaged* profile and skips it entirely. The
/// directory and all its data survive, but the profile stops existing as far as
/// the picker, the candidate resolver and the profile list are concerned, and
/// startup goes on to create a fresh `Default` alongside it.
///
/// Temp-then-rename, matching how every other durable record on this path is
/// written (see `AtomicJsonFile`). Not reusing that helper only because it is
/// typed to `Map<String, Object?>` documents under the startup paths, while this
/// file lives in the profile tree and is the one thing that must be readable
/// before any of that machinery is reachable.
Future<void> writeProfileMetadata(Directory profileDir, Profile profile) async {
  final file = File(p.join(profileDir.path, profileMetadataFileName));
  final temp = File('${file.path}.tmp');

  try {
    await temp.writeAsString(jsonEncode(profile.toJson()), flush: true);
    await temp.rename(file.path);
  } catch (_) {
    if (temp.existsSync()) {
      try {
        await temp.delete();
      } catch (_) {
        // A stray `.tmp` is inert: discovery matches the exact file name.
      }
    }
    rethrow;
  }
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
