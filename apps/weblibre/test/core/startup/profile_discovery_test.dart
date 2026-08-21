import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid_value.dart';
import 'package:weblibre/core/startup/profile_candidate.dart';
import 'package:weblibre/core/startup/profile_discovery.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;

const _oldest = '0199a0b1-1111-7111-8111-111111111111';
const _middle = '0199a0b1-2222-7222-8222-222222222222';
const _newest = '0199a0b1-3333-7333-8333-333333333333';

void main() {
  late Directory profilesDir;

  setUp(() async {
    profilesDir = await Directory.systemTemp.createTemp('weblibre_profiles');
  });

  tearDown(() async {
    if (profilesDir.existsSync()) {
      await profilesDir.delete(recursive: true);
    }
  });

  Future<Directory> writeProfile(
    String id, {
    String name = 'Profile',
    String? dirName,
    String? metadataId,
    String? rawMetadata,
    bool metadata = true,
  }) async {
    final dir = Directory(
      p.join(profilesDir.path, dirName ?? '${fs.profileDirPrefix}$id'),
    );
    await dir.create(recursive: true);

    if (metadata) {
      final file = File(p.join(dir.path, fs.profileMetadataFileName));
      await file.writeAsString(
        rawMetadata ??
            jsonEncode(Profile(id: metadataId ?? id, name: name).toJson()),
      );
    }

    return dir;
  }

  group('canonical directory names', () {
    test('round-trips a canonical name', () {
      final uuid = UuidValue.withValidation(_oldest);
      expect(canonicalProfileDirName(uuid), 'profile-$_oldest');
      expect(parseCanonicalProfileDirName('profile-$_oldest'), uuid);
    });

    test('rejects spellings that are not exactly canonical', () {
      expect(parseCanonicalProfileDirName('profile-${_oldest.toUpperCase()}'), isNull);
      expect(
        parseCanonicalProfileDirName('profile-${_oldest.replaceAll('-', '')}'),
        isNull,
      );
      expect(parseCanonicalProfileDirName('profile-$_oldest '), isNull);
      expect(parseCanonicalProfileDirName('profile-not-a-uuid'), isNull);
      expect(parseCanonicalProfileDirName(_oldest), isNull);
    });
  });

  group('discoverProfiles', () {
    test('returns nothing for a missing profiles root', () async {
      final missing = Directory(p.join(profilesDir.path, 'nope'));
      expect((await discoverProfiles(missing)).profiles, isEmpty);
    });

    test('sorts valid profiles by canonical uuid, i.e. creation order', () async {
      await writeProfile(_newest, name: 'Newest');
      await writeProfile(_oldest, name: 'Oldest');
      await writeProfile(_middle, name: 'Middle');

      final discovery = await discoverProfiles(profilesDir);

      expect(discovery.profiles.map((profile) => profile.name), [
        'Oldest',
        'Middle',
        'Newest',
      ]);
      expect(discovery.damaged, isEmpty);
    });

    test('one damaged profile does not hide the others', () async {
      await writeProfile(_oldest, name: 'Good');
      await writeProfile(_middle, metadata: false);
      await writeProfile(_newest, rawMetadata: '{ broken');

      final discovery = await discoverProfiles(profilesDir);

      expect(discovery.profiles.map((profile) => profile.name), ['Good']);
      expect(
        discovery.damaged.map((entry) => entry.defect),
        unorderedEquals([
          ProfileDefect.missingMetadata,
          ProfileDefect.unreadableMetadata,
        ]),
      );
    });

    test('metadata must have the exact shape Profile.fromJson requires', () async {
      // Mirrored by `ProfileCandidateResolverTest.metadataMustHaveTheExactShape…`.
      // Kotlin has to reject exactly what this rejects: a headless start that
      // committed a profile Flutter then refuses would surface as an
      // unrecoverable process-profile mismatch, not as a skipped profile.
      await writeProfile(_oldest, rawMetadata: '{"id":"$_oldest"}');
      await writeProfile(_middle, rawMetadata: '{"id":"$_middle","name":null}');
      await writeProfile(_newest, rawMetadata: '{"id":"$_newest","name":7}');

      final discovery = await discoverProfiles(profilesDir);

      expect(discovery.profiles, isEmpty);
      expect(discovery.damaged, hasLength(3));
      expect(
        discovery.damaged.every(
          (entry) => entry.defect == ProfileDefect.unreadableMetadata,
        ),
        isTrue,
      );
    });

    test('a non-object authSettings is refused', () async {
      await writeProfile(
        _oldest,
        rawMetadata: '{"id":"$_oldest","name":"Default","authSettings":"nope"}',
      );

      final discovery = await discoverProfiles(profilesDir);

      expect(discovery.profiles, isEmpty);
      expect(discovery.damaged.single.defect, ProfileDefect.unreadableMetadata);
    });

    test('an absent authSettings is fine because the model defaults it', () async {
      await writeProfile(
        _oldest,
        rawMetadata: '{"id":"$_oldest","name":"Default"}',
      );

      final discovery = await discoverProfiles(profilesDir);

      expect(discovery.profiles.map((profile) => profile.name), ['Default']);
    });

    test('a non-string id is refused', () async {
      await writeProfile(_oldest, rawMetadata: '{"id":7,"name":"Default"}');

      final discovery = await discoverProfiles(profilesDir);

      expect(discovery.profiles, isEmpty);
      expect(discovery.damaged.single.defect, ProfileDefect.unreadableMetadata);
    });

    test('metadata that claims a different uuid is refused', () async {
      await writeProfile(_oldest, metadataId: _middle);

      final discovery = await discoverProfiles(profilesDir);

      expect(discovery.profiles, isEmpty);
      expect(
        discovery.damaged.single.defect,
        ProfileDefect.metadataUuidMismatch,
      );
    });

    test('a non-canonical directory name is damaged, not silently ignored', () async {
      await writeProfile(_oldest, dirName: 'profile-${_oldest.toUpperCase()}');

      final discovery = await discoverProfiles(profilesDir);

      expect(discovery.profiles, isEmpty);
      expect(discovery.damaged.single.defect, ProfileDefect.nonCanonicalName);
    });

    test('unrelated directories are neither profiles nor damage', () async {
      await Directory(p.join(profilesDir.path, 'weblibre_maintenance')).create();
      await File(p.join(profilesDir.path, 'current_profile')).writeAsString(_oldest);
      await writeProfile(_oldest);

      final discovery = await discoverProfiles(profilesDir);

      expect(discovery.profiles, hasLength(1));
      expect(discovery.damaged, isEmpty);
    });
  });

  group('candidate resolution', () {
    test('rule 1: a valid current_profile wins', () {
      final candidate = resolveProfileCandidate(
        currentProfile: UuidValue.withValidation(_newest),
        validProfiles: [
          UuidValue.withValidation(_oldest),
          UuidValue.withValidation(_newest),
        ],
      );

      expect(candidate.uuid, UuidValue.withValidation(_newest));
      expect(candidate.source, ProfileCandidateSource.currentProfile);
    });

    test('rule 2: otherwise the lexicographically smallest uuid', () {
      final candidate = resolveProfileCandidate(
        currentProfile: null,
        validProfiles: [
          UuidValue.withValidation(_newest),
          UuidValue.withValidation(_middle),
          UuidValue.withValidation(_oldest),
        ],
      );

      expect(candidate.uuid, UuidValue.withValidation(_oldest));
      expect(candidate.source, ProfileCandidateSource.oldestProfile);
    });

    test('a current_profile that no longer validates falls back', () {
      final candidate = resolveProfileCandidate(
        currentProfile: UuidValue.withValidation(_newest),
        validProfiles: [UuidValue.withValidation(_middle)],
      );

      expect(candidate.uuid, UuidValue.withValidation(_middle));
      expect(candidate.source, ProfileCandidateSource.oldestProfile);
    });

    test('rule 3: no valid profile means no candidate', () {
      final candidate = resolveProfileCandidate(
        currentProfile: UuidValue.withValidation(_oldest),
        validProfiles: const [],
      );

      expect(candidate.isPresent, isFalse);
      expect(candidate.source, ProfileCandidateSource.none);
    });

    test('resolution on disk reads but never writes current_profile', () async {
      await writeProfile(_oldest);
      await writeProfile(_middle);

      final candidate = await resolveCandidateOnDisk(profilesDir);

      expect(candidate.uuid, UuidValue.withValidation(_oldest));
      expect(
        File(p.join(profilesDir.path, fs.startupProfileFileName)).existsSync(),
        isFalse,
      );
    });

    test('a damaged current_profile target is skipped, not booted', () async {
      await writeProfile(_oldest);
      await writeProfile(_middle, rawMetadata: '{ broken');
      await fs.writeStartupProfile(
        profilesDir,
        UuidValue.withValidation(_middle),
      );

      final candidate = await resolveCandidateOnDisk(profilesDir);
      expect(candidate.uuid, UuidValue.withValidation(_oldest));
    });
  });
}
