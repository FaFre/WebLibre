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
 */
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;

const _source = '0199a0b1-1111-7111-8111-111111111111';
const _clone = '0199a0b1-2222-7222-8222-222222222222';
const _mozProfile = 'abc123.default';

void main() {
  late Directory filesDir;

  setUp(() async {
    filesDir = await Directory.systemTemp.createTemp('weblibre_ext_paths');
  });

  tearDown(() async {
    if (filesDir.existsSync()) {
      await filesDir.delete(recursive: true);
    }
  });

  Directory profileDir(String id) => Directory(
    p.join(filesDir.path, fs.profilesDirName, '${fs.profileDirPrefix}$id'),
  );

  Directory mozillaDir(String id) =>
      Directory(p.join(profileDir(id).path, 'files', 'mozilla', _mozProfile));

  File extensionsFile(String id) =>
      File(p.join(mozillaDir(id).path, 'extensions.json'));

  /// Writes an `extensions.json` whose add-on paths point at [addressedTo].
  void seed(String id, {required String prefix}) {
    mozillaDir(id).createSync(recursive: true);
    extensionsFile(id).writeAsStringSync(
      jsonEncode({
        'schemaVersion': 36,
        'addons': [
          {
            'id': 'uBlock0@raymondhill.net',
            'path':
                '$prefix$_mozProfile/extensions/uBlock0@raymondhill.net.xpi',
            'rootURI':
                'jar:file://$prefix$_mozProfile/extensions/uBlock0@raymondhill.net.xpi!/',
          },
        ],
      }),
    );
  }

  Map<String, Object?> readAddon(String id) {
    final json =
        jsonDecode(extensionsFile(id).readAsStringSync())
            as Map<String, Object?>;
    return (json['addons']! as List).single as Map<String, Object?>;
  }

  test('a restored profile stops pointing at the profile it was taken from', () async {
    // The exact shape a backup carries. Gecko stores absolute add-on paths, and
    // healing rewrites them to the real profile directory the first time that
    // profile is activated — so an archive taken afterwards is addressed to the
    // *source* profile, and installing it under a different uuid used to leave
    // every add-on loading out of somebody else's directory.
    seed(_clone, prefix: '${profileDir(_source).path}/files/mozilla/');

    expect(await healExtensionPaths(filesDir, profileDir(_clone)), isTrue);

    final addon = readAddon(_clone);
    final expected = '${profileDir(_clone).path}/files/mozilla/';
    expect(addon['path'], startsWith(expected));
    expect(
      addon['rootURI'],
      'jar:file://$expected$_mozProfile/extensions/uBlock0@raymondhill.net.xpi!/',
    );
    expect('${addon['path']}', isNot(contains(_source)));
  });

  test('the pre-multi-profile symlink path is still rewritten', () async {
    // The original migration case, unchanged: `{filesDir}/mozilla` used to be a
    // real directory and the symlink now bridges it.
    seed(_source, prefix: '${filesDir.path}/mozilla/');

    expect(await healExtensionPaths(filesDir, profileDir(_source)), isTrue);

    expect(
      readAddon(_source)['path'],
      startsWith('${profileDir(_source).path}/files/mozilla/'),
    );
  });

  test('a file already addressed to this profile is left untouched', () async {
    // The rewrite is what makes `_healGeckoStartupCaches` run, and that clears
    // Gecko's startup caches — so reporting a change on every launch would be a
    // recurring startup cost for nothing.
    seed(_source, prefix: '${profileDir(_source).path}/files/mozilla/');
    final before = extensionsFile(_source).readAsStringSync();

    expect(await healExtensionPaths(filesDir, profileDir(_source)), isFalse);
    expect(extensionsFile(_source).readAsStringSync(), before);
  });

  test('a profile with no gecko profile directory is a no-op', () async {
    profileDir(_source).createSync(recursive: true);
    expect(await healExtensionPaths(filesDir, profileDir(_source)), isFalse);
  });
}
