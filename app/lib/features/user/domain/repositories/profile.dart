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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:weblibre/core/filesystem.dart';

import 'package:weblibre/domain/entities/profile.dart';

part 'profile.g.dart';

@Riverpod(keepAlive: true)
class ProfileRepository extends _$ProfileRepository {
  Future<List<Profile>> _readProfiles() {
    return filesystem.getAvailableProfileDirectories().then((dirs) async {
      final profiles = await Future.wait(
        dirs.map(filesystem.readProfileMetadata),
      );
      return profiles.nonNulls.toList();
    });
  }

  Future<void> switchProfile(String id) async {
    await filesystem.setStartupProfile(UuidValue.withValidation(id));
  }

  Future<Profile> createProfile({required String name}) async {
    final profile = Profile.create(name: name);
    if (!await filesystem.createNewProfile(profile)) {
      throw Exception('Could not create profile');
    }

    ref.invalidateSelf();

    return profile;
  }

  Future<void> updateProfileMetadata(Profile profile) async {
    await filesystem.updateProfileMetadata(profile);
    ref.invalidateSelf();
  }

  Future<bool> deleteProfile(String id) async {
    final uuid = UuidValue.withValidation(id);
    if (filesystem.selectedProfile == uuid) {
      return false;
    }

    // Clean up Mozilla cache directories before deleting the profile
    final mozillaProfileIds = filesystem.getMozillaProfileIds(uuid);
    for (final profileId in mozillaProfileIds) {
      await filesystem.clearMozillaProfileCache(profileId);
    }

    await filesystem.getProfileDir(uuid).delete(recursive: true);

    ref.invalidateSelf();

    return true;
  }

  @override
  Future<List<Profile>> build() {
    return _readProfiles();
  }
}
