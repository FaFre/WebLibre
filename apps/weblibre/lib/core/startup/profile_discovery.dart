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
import 'package:uuid/uuid_value.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;

/// Canonical on-disk name for a profile directory: `profile-` followed by the
/// lowercase, hyphenated UUID and nothing else.
String canonicalProfileDirName(UuidValue uuid) =>
    '${fs.profileDirPrefix}${uuid.uuid}';

/// Parses a directory *base name* back into a profile UUID.
///
/// Returns `null` unless the name is exactly canonical. A name that merely
/// parses as a UUID after normalisation (uppercase, braces, no dashes) is
/// rejected on purpose: two spellings of one UUID would otherwise be two
/// profile directories that both claim the same identity.
UuidValue? parseCanonicalProfileDirName(String name) {
  if (!name.startsWith(fs.profileDirPrefix)) return null;

  final raw = name.substring(fs.profileDirPrefix.length);
  final UuidValue uuid;
  try {
    uuid = UuidValue.withValidation(raw);
  } on FormatException {
    return null;
  }

  return uuid.uuid == raw ? uuid : null;
}

/// Why a profile directory was excluded from the candidate set.
enum ProfileDefect {
  /// Directory name is not exactly `profile-<lowercase uuid>`.
  nonCanonicalName,

  /// `metadata.json` is missing.
  missingMetadata,

  /// `metadata.json` is unreadable or not valid profile JSON.
  unreadableMetadata,

  /// `metadata.json` claims a different UUID than the directory name.
  metadataUuidMismatch,
}

class DamagedProfile {
  const DamagedProfile({required this.path, required this.defect, this.detail});

  final String path;
  final ProfileDefect defect;
  final String? detail;

  @override
  String toString() =>
      '${p.basename(path)}: ${defect.name}${detail == null ? '' : ' ($detail)'}';
}

class DiscoveredProfile {
  const DiscoveredProfile({
    required this.uuid,
    required this.directory,
    required this.metadata,
  });

  final UuidValue uuid;
  final Directory directory;
  final Profile metadata;

  String get name => metadata.name;
}

/// The validated view of the profiles root. Nothing here has opened a profile
/// database or written to a profile directory.
class ProfileDiscovery {
  const ProfileDiscovery({required this.profiles, required this.damaged});

  static const empty = ProfileDiscovery(profiles: [], damaged: []);

  /// Valid profiles, sorted by canonical UUID. `Profile.getNewProfileId()`
  /// returns a time-ordered UUIDv7, so this is also creation order.
  final List<DiscoveredProfile> profiles;
  final List<DamagedProfile> damaged;

  bool get isEmpty => profiles.isEmpty;

  DiscoveredProfile? byId(UuidValue uuid) {
    for (final profile in profiles) {
      if (profile.uuid == uuid) return profile;
    }
    return null;
  }

  bool contains(UuidValue uuid) => byId(uuid) != null;
}

/// Enumerates and validates the profiles root.
///
/// A damaged profile is skipped and logged; it never aborts the scan, because
/// one unreadable `metadata.json` must not make the picker — or the fallback
/// candidate — unavailable for every other profile.
Future<ProfileDiscovery> discoverProfiles(Directory profilesDir) async {
  if (!await profilesDir.exists()) {
    return ProfileDiscovery.empty;
  }

  final candidates = <Directory>[];
  await for (final entity in profilesDir.list(followLinks: false)) {
    if (entity is Directory &&
        p.basename(entity.path).startsWith(fs.profileDirPrefix)) {
      candidates.add(entity);
    }
  }

  // Concurrently: each inspection is an independent `exists` + read + parse, and
  // [_inspect] reports a defect by returning one rather than throwing, so there
  // is no failure here for `Future.wait` to abandon the other profiles over.
  final inspected = await Future.wait(candidates.map(_inspect));

  final profiles = <DiscoveredProfile>[];
  final damaged = <DamagedProfile>[];
  for (final result in inspected) {
    switch (result) {
      case DiscoveredProfile():
        profiles.add(result);
      case DamagedProfile():
        damaged.add(result);
    }
  }

  profiles.sort((a, b) => a.uuid.uuid.compareTo(b.uuid.uuid));

  for (final entry in damaged) {
    logger.w('Skipping damaged profile $entry');
  }

  return ProfileDiscovery(
    profiles: List.unmodifiable(profiles),
    damaged: List.unmodifiable(damaged),
  );
}

/// Whether a damaged profile can be rebuilt from what is left on disk.
///
/// The directory name is the authority. `profile-<uuid>` is canonical by the
/// time a defect is recorded at all, so for a missing or unreadable
/// `metadata.json` the profile's identity is not actually in doubt — only its
/// name and settings are, and both are recoverable by the user.
///
/// A UUID *mismatch* is the opposite case and stays unrepairable: two claims of
/// identity, and choosing the directory's would hand one profile's data to
/// another profile's id. A non-canonical name has no authoritative uuid to
/// rebuild from.
bool isRepairableDefect(ProfileDefect defect) => switch (defect) {
  ProfileDefect.missingMetadata || ProfileDefect.unreadableMetadata => true,
  ProfileDefect.nonCanonicalName || ProfileDefect.metadataUuidMismatch => false,
};

/// Rebuilds `metadata.json` for damaged profiles whose identity is not in doubt.
///
/// Without this a profile whose metadata was truncated — by a crash during a
/// rename on a build before the write became atomic — is skipped by discovery
/// forever. Its whole directory is intact and unreachable, and if it was the only
/// profile, startup goes on to create a fresh `Default` beside it and the user
/// concludes everything is gone.
///
/// **The recovered profile comes back unlocked**, because its auth settings were
/// in the file that cannot be read. That is a deliberate choice between two bad
/// options: failing closed would put a biometric gate on a profile whose owner
/// may have nothing enrolled, locking them out of their own data permanently,
/// and the gate is a UI lock over data this app does not encrypt at rest —
/// so failing open weakens something weaker than it looks, while failing closed
/// can be unrecoverable. The name says the profile was recovered so the state is
/// visible rather than silent.
///
/// Writes, so it must hold a lease — call it from [FileSystem.discoverProfiles]
/// and nowhere else. Returns the number of profiles rebuilt.
Future<int> repairDamagedProfiles(ProfileDiscovery found) async {
  var repaired = 0;

  for (final entry in found.damaged) {
    if (!isRepairableDefect(entry.defect)) {
      logger.w('Leaving ${p.basename(entry.path)} alone: ${entry.defect.name}');
      continue;
    }

    final directory = Directory(entry.path);
    final uuid = parseCanonicalProfileDirName(p.basename(entry.path));
    if (uuid == null || !directory.existsSync()) continue;

    try {
      await fs.writeProfileMetadata(
        directory,
        Profile(
          id: uuid.uuid,
          name: recoveredProfileName(uuid),
          authSettings: AuthSettings.withDefaults(),
        ),
      );
      repaired++;
      logger.i('Rebuilt metadata for ${p.basename(entry.path)}');
    } catch (error, stackTrace) {
      // One profile that cannot be rebuilt must not stop the others, and it is
      // no worse off than before: it stays skipped.
      logger.w(
        'Could not rebuild metadata for ${p.basename(entry.path)}',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  return repaired;
}

/// Names a rebuilt profile so the user can tell it apart and rename it.
///
/// The uuid fragment is there because more than one profile can be recovered in
/// the same pass, and "Recovered profile" three times over is not a list anyone
/// can act on.
///
/// From the **end** of the uuid, for the same reason `profileLabels` takes its
/// fragment from there: `Profile.getNewProfileId()` returns a UUIDv7, whose
/// leading characters are a millisecond timestamp — constant across every
/// profile created in the same minute, which is exactly the set a single
/// recovery pass tends to cover. The tail is the random part.
///
/// No brackets: `validateProfileName` rejects them, and a name the app wrote
/// that the app's own edit screen refuses to save is a dead end the user cannot
/// see the cause of.
String recoveredProfileName(UuidValue uuid) {
  final id = uuid.uuid;
  return 'Recovered profile ${id.substring(id.length - 8)}';
}

/// Classifies one candidate directory, never throwing.
///
/// Returns the [DiscoveredProfile] it describes, or the [DamagedProfile] saying
/// why it could not be one. Reporting a defect as a value rather than an
/// exception is what lets [discoverProfiles] inspect every candidate at once:
/// one unreadable `metadata.json` must not make the picker unavailable for the
/// rest.
Future<Object> _inspect(Directory dir) async {
  final uuid = parseCanonicalProfileDirName(p.basename(dir.path));
  if (uuid == null) {
    return DamagedProfile(
      path: dir.path,
      defect: ProfileDefect.nonCanonicalName,
    );
  }

  final Profile metadata;
  try {
    final read = await fs.readProfileMetadata(dir);
    if (read == null) {
      return DamagedProfile(
        path: dir.path,
        defect: ProfileDefect.missingMetadata,
      );
    }
    metadata = read;
  } catch (e) {
    return DamagedProfile(
      path: dir.path,
      defect: ProfileDefect.unreadableMetadata,
      detail: e.toString(),
    );
  }

  final UuidValue metadataUuid;
  try {
    metadataUuid = UuidValue.withValidation(metadata.id);
  } on FormatException catch (e) {
    return DamagedProfile(
      path: dir.path,
      defect: ProfileDefect.unreadableMetadata,
      detail: e.toString(),
    );
  }

  if (metadataUuid != uuid) {
    return DamagedProfile(
      path: dir.path,
      defect: ProfileDefect.metadataUuidMismatch,
      detail: metadata.id,
    );
  }

  return DiscoveredProfile(uuid: uuid, directory: dir, metadata: metadata);
}
