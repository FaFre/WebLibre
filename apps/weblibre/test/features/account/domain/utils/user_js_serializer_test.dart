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

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/account/domain/utils/user_js_parser.dart';
import 'package:weblibre/features/account/domain/utils/user_js_serializer.dart';

void main() {
  group('serializeUserJs', () {
    test('serializes syncable prefs in sorted order, excluding URL-style', () {
      final text = serializeUserJs(
        userPrefs: <String, Object>{
          'zeta.pref': 7,
          'alpha.pref': 'value',
          'beta.pref': false,
          'unsyncable.pref': 'blob:https://example.com',
        },
        schemaVersion: 1,
        exportedAt: '2026-04-15T12:00:00Z',
      );

      expect(text, '''
// WebLibre Gecko prefs snapshot
// schema_version=1
// exported_at=2026-04-15T12:00:00Z
user_pref("alpha.pref", "value");
user_pref("beta.pref", false);
user_pref("zeta.pref", 7);
''');
    });

    test('uses Firefox-compatible escaping and round-trips through parser', () {
      final prefValue = 'quote " slash \\ newline \n carriage \r tab \t'
          .replaceAll(r'\n', '\n')
          .replaceAll(r'\r', '\r')
          .replaceAll(r'\t', '\t');

      final text = serializeUserJs(
        userPrefs: <String, Object>{'text.pref': prefValue},
        schemaVersion: 1,
        exportedAt: '2026-04-15T12:00:00Z',
      );

      expect(
        text,
        contains(
          'user_pref("text.pref", "quote \\" slash \\\\ newline \\n carriage \\r tab \t");\n',
        ),
      );

      final parsed = parseUserJs(text);
      expect(parsed.prefs['text.pref'], prefValue);
    });
  });
}
