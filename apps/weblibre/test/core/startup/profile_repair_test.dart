import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/startup/profile_discovery.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;
import 'package:weblibre/utils/form_validators.dart';

const _a = '0199a0b1-1111-7111-8111-111111111111';
const _b = '0199a0b1-2222-7222-8222-222222222222';

void main() {
  late Directory profilesDir;

  setUp(() async {
    profilesDir = await Directory.systemTemp.createTemp('weblibre_repair');
  });

  tearDown(() async {
    if (profilesDir.existsSync()) {
      await profilesDir.delete(recursive: true);
    }
  });

  Directory makeProfile(String id, {String? metadata}) {
    final dir = Directory(p.join(profilesDir.path, '${fs.profileDirPrefix}$id'))
      ..createSync(recursive: true);
    Directory(p.join(dir.path, 'databases')).createSync();
    File(p.join(dir.path, 'databases', 'tab.db')).writeAsStringSync('tabs');
    if (metadata != null) {
      File(
        p.join(dir.path, fs.profileMetadataFileName),
      ).writeAsStringSync(metadata);
    }
    return dir;
  }

  test(
    'a truncated metadata file is rebuilt from the directory name',
    () async {
      // The exact shape a crash during a rename left behind before the write
      // became atomic.
      makeProfile(_a, metadata: '{"id":"0199a0b1-111');

      final before = await discoverProfiles(profilesDir);
      expect(before.profiles, isEmpty);
      expect(before.damaged.single.defect, ProfileDefect.unreadableMetadata);

      expect(await repairDamagedProfiles(before), 1);

      final after = await discoverProfiles(profilesDir);
      expect(after.profiles.single.uuid.uuid, _a);
      expect(after.damaged, isEmpty);
    },
  );

  test('missing metadata is rebuilt too', () async {
    makeProfile(_a);

    final before = await discoverProfiles(profilesDir);
    expect(before.damaged.single.defect, ProfileDefect.missingMetadata);

    await repairDamagedProfiles(before);

    final after = await discoverProfiles(profilesDir);
    expect(after.profiles.single.uuid.uuid, _a);
  });

  test('the profile keeps its data', () async {
    final dir = makeProfile(_a, metadata: 'not json at all');

    await repairDamagedProfiles(await discoverProfiles(profilesDir));

    expect(
      File(p.join(dir.path, 'databases', 'tab.db')).readAsStringSync(),
      'tabs',
    );
  });

  test('a rebuilt profile is named so the user can tell', () async {
    makeProfile(_a);

    await repairDamagedProfiles(await discoverProfiles(profilesDir));

    final after = await discoverProfiles(profilesDir);
    expect(after.profiles.single.name, contains('Recovered'));
    // Distinguishable when more than one is rebuilt in the same pass — from the
    // *end* of the uuid, because a v7's leading characters are a timestamp that
    // profiles created together share.
    expect(after.profiles.single.name, contains('11111111'));
  });

  test('two profiles rebuilt together get different names', () async {
    // The case the fragment exists for. `_a` and `_b` share `0199a0b1`, so a
    // prefix fragment named them both the same thing in the one list whose job
    // is telling them apart.
    makeProfile(_a);
    makeProfile(_b);

    await repairDamagedProfiles(await discoverProfiles(profilesDir));

    final after = await discoverProfiles(profilesDir);
    expect(after.profiles.map((e) => e.name).toSet(), hasLength(2));
  });

  test('a rebuilt name is one the edit screen accepts', () async {
    // It was not: the name carried brackets, which `validateProfileName`
    // rejects, so opening a recovered profile and changing anything failed
    // validation over a name the app itself had written.
    makeProfile(_a);

    await repairDamagedProfiles(await discoverProfiles(profilesDir));

    final after = await discoverProfiles(profilesDir);
    expect(validateProfileName(after.profiles.single.name), isNull);
  });

  test('a uuid mismatch is never repaired', () async {
    // Two claims of identity. Rebuilding from the directory name would hand this
    // directory's data to an id its own metadata says it does not have.
    makeProfile(_a, metadata: jsonEncode({'id': _b, 'name': 'Elsewhere'}));

    final before = await discoverProfiles(profilesDir);
    expect(before.damaged.single.defect, ProfileDefect.metadataUuidMismatch);
    expect(isRepairableDefect(ProfileDefect.metadataUuidMismatch), isFalse);

    expect(await repairDamagedProfiles(before), 0);

    final after = await discoverProfiles(profilesDir);
    expect(after.profiles, isEmpty);
    expect(after.damaged, hasLength(1));
  });

  test('a non-canonical directory name is never repaired', () async {
    Directory(
      p.join(profilesDir.path, '${fs.profileDirPrefix}NOT-A-UUID'),
    ).createSync(recursive: true);

    final before = await discoverProfiles(profilesDir);
    expect(before.damaged.single.defect, ProfileDefect.nonCanonicalName);

    expect(await repairDamagedProfiles(before), 0);
  });

  test('healthy profiles are left exactly as they are', () async {
    makeProfile(_a, metadata: jsonEncode({'id': _a, 'name': 'Mine'}));
    makeProfile(_b);

    final before = await discoverProfiles(profilesDir);
    await repairDamagedProfiles(before);

    final after = await discoverProfiles(profilesDir);
    final byId = {for (final e in after.profiles) e.uuid.uuid: e.name};
    expect(byId[_a], 'Mine');
    expect(byId[_b], contains('Recovered'));
  });
}
