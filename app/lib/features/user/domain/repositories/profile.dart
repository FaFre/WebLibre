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

    state = await AsyncValue.guard(_readProfiles);

    return profile;
  }

  Future<void> updateProfileMetadata(Profile profile) async {
    await filesystem.updateProfileMetadata(profile);
    state = await AsyncValue.guard(_readProfiles);
  }

  Future<bool> deleteProfile(String id) async {
    final uuid = UuidValue.withValidation(id);
    if (filesystem.selectedProfile == uuid) {
      return false;
    }

    await filesystem.getProfileDir(uuid).delete(recursive: true);

    state = await AsyncValue.guard(_readProfiles);

    return true;
  }

  @override
  Future<List<Profile>> build() {
    return _readProfiles();
  }
}
