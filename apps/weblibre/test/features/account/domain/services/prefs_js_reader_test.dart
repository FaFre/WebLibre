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

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/features/account/domain/services/prefs_js_reader.dart';

void main() {
  late Directory profileDir;

  setUp(() {
    profileDir = Directory.systemTemp.createTempSync('prefs_js_reader_test_');
  });

  tearDown(() {
    if (profileDir.existsSync()) {
      profileDir.deleteSync(recursive: true);
    }
  });

  Directory makeGeckoProfile(String id) {
    final dir = Directory(p.join(profileDir.path, 'files', 'mozilla', id))
      ..createSync(recursive: true);
    return dir;
  }

  test('returns empty map when no Gecko profile exists', () async {
    final reader = PrefsJsReader(selectedProfileDir: profileDir);
    expect(await reader.readUserPrefs(), isEmpty);
  });

  test('returns empty map when prefs.js is missing', () async {
    makeGeckoProfile('abc.default');

    final reader = PrefsJsReader(selectedProfileDir: profileDir);
    expect(await reader.readUserPrefs(), isEmpty);
  });

  test('parses a realistic prefs.js fixture', () async {
    final geckoDir = makeGeckoProfile('abc.default');
    File(p.join(geckoDir.path, 'prefs.js')).writeAsStringSync('''
// Mozilla User Preferences
user_pref("browser.startup.homepage", "about:home");
user_pref("dom.webgpu.enabled", true);
user_pref("network.http.max-connections", 900);
''');

    final reader = PrefsJsReader(selectedProfileDir: profileDir);
    final prefs = await reader.readUserPrefs();
    expect(prefs, {
      'browser.startup.homepage': 'about:home',
      'dom.webgpu.enabled': true,
      'network.http.max-connections': 900,
    });
  });

  test('picks newest prefs.js when multiple Gecko profiles exist', () async {
    final oldDir = makeGeckoProfile('old.default');
    final newDir = makeGeckoProfile('new.default');

    final oldFile = File(p.join(oldDir.path, 'prefs.js'))
      ..writeAsStringSync('user_pref("a.pref", "old");\n');
    File(
      p.join(newDir.path, 'prefs.js'),
    ).writeAsStringSync('user_pref("a.pref", "new");\n');

    final past = DateTime.now().subtract(const Duration(hours: 1));
    oldFile.setLastModifiedSync(past);

    final reader = PrefsJsReader(selectedProfileDir: profileDir);
    final prefs = await reader.readUserPrefs();
    expect(prefs['a.pref'], 'new');
  });
}
