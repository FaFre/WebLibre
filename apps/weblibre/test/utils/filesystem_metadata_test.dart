import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('weblibre_metadata');
  });

  tearDown(() async {
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  });

  test('a rewrite never leaves a truncated metadata file behind', () async {
    // Discovery treats unreadable metadata as a *damaged* profile and skips it,
    // so a half-written file makes the profile stop existing as far as the
    // picker, the candidate resolver and the profile list are concerned — while
    // all of its data is still on disk.
    final profile = Profile.create(name: 'Original');
    await fs.writeProfileMetadata(root, profile);

    final file = File(p.join(root.path, fs.profileMetadataFileName));
    final before = file.readAsStringSync();

    await fs.writeProfileMetadata(root, profile.copyWith(name: 'Renamed'));

    final after = file.readAsStringSync();
    expect(after, isNot(before));
    expect((jsonDecode(after) as Map<String, dynamic>)['name'], 'Renamed');
    // Temp-then-rename: nothing else may be left in the profile root.
    expect(root.listSync().map((entity) => p.basename(entity.path)), [
      fs.profileMetadataFileName,
    ]);
  });

  test('the written file is readable by the discovery parser', () async {
    final profile = Profile.create(name: 'Default');
    await fs.writeProfileMetadata(root, profile);

    final read = await fs.readProfileMetadata(root);
    expect(read?.name, 'Default');
    expect(read?.uuidValue, profile.uuidValue);
  });
}
