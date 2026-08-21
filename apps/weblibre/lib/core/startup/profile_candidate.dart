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

import 'package:uuid/uuid_value.dart';
import 'package:weblibre/core/startup/profile_discovery.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;

/// Where a candidate came from. Purely diagnostic; the decision itself is
/// [resolveProfileCandidate].
enum ProfileCandidateSource {
  /// `current_profile` named a profile that still validates.
  currentProfile,

  /// `current_profile` was missing, unparseable, or named a profile that no
  /// longer validates, so the oldest profile was used.
  oldestProfile,

  /// There is no valid profile at all; this is first run, or every profile is
  /// damaged.
  none,
}

class ProfileCandidate {
  const ProfileCandidate(this.uuid, this.source);

  static const absent = ProfileCandidate(null, ProfileCandidateSource.none);

  final UuidValue? uuid;
  final ProfileCandidateSource source;

  bool get isPresent => uuid != null;
}

/// The single, deterministic candidate rule, mirrored by Kotlin's
/// `ProfileCandidateResolver`:
///
/// 1. use a valid `current_profile`;
/// 2. otherwise use the lexicographically smallest canonical profile UUID;
/// 3. otherwise there is no candidate.
///
/// This function is pure and never writes `current_profile`. Only native
/// commitment persists a profile.
///
/// Rule 2 is not only deterministic but also the sensible product default:
/// `Profile.getNewProfileId()` returns a time-ordered UUIDv7, so lexicographic
/// order is creation order and the fallback picks the oldest profile — normally
/// `Default`. Filesystem access time is deliberately not used; ties and
/// `relatime`-style mount behaviour are not stable enough for arbitration, and
/// Kotlin could not reproduce it.
ProfileCandidate resolveProfileCandidate({
  required UuidValue? currentProfile,
  required List<UuidValue> validProfiles,
}) {
  if (currentProfile != null && validProfiles.contains(currentProfile)) {
    return ProfileCandidate(
      currentProfile,
      ProfileCandidateSource.currentProfile,
    );
  }

  if (validProfiles.isEmpty) {
    return ProfileCandidate.absent;
  }

  final oldest = validProfiles
      .map((uuid) => uuid.uuid)
      .reduce((a, b) => a.compareTo(b) <= 0 ? a : b);

  return ProfileCandidate(
    UuidValue.fromString(oldest),
    ProfileCandidateSource.oldestProfile,
  );
}

/// Convenience overload over a [ProfileDiscovery].
ProfileCandidate resolveCandidateFrom(
  ProfileDiscovery discovery,
  UuidValue? currentProfile,
) {
  return resolveProfileCandidate(
    currentProfile: currentProfile,
    validProfiles: discovery.profiles
        .map((profile) => profile.uuid)
        .toList(growable: false),
  );
}

/// Reads `current_profile` without repairing or rewriting it.
///
/// A missing or damaged file is simply reported as `null`; healing it is native
/// commitment's job.
Future<UuidValue?> readCurrentProfile(Directory profilesDir) =>
    fs.readStartupProfile(profilesDir);

/// Read-only candidate resolution against a real profiles root.
Future<ProfileCandidate> resolveCandidateOnDisk(Directory profilesDir) async {
  final discovery = await discoverProfiles(profilesDir);
  return resolveCandidateFrom(discovery, await readCurrentProfile(profilesDir));
}
