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

void main() {
  group('parseUserJs', () {
    test('parses empty and whitespace-only input', () {
      expect(parseUserJs('').prefs, isEmpty);
      expect(parseUserJs(' \t\n\r\v\f ').prefs, isEmpty);
    });

    test('ignores Firefox comment forms and parses metadata comments', () {
      final result = parseUserJs('''
// schema_version=7
# ignored comment
/* block comment */
// exported_at=2026-04-15T12:00:00Z
''');

      expect(result.prefs, isEmpty);
      expect(result.schemaVersion, 7);
      expect(result.exportedAt, '2026-04-15T12:00:00Z');
    });

    test('parses user_pref scalar values', () {
      final result = parseUserJs('''
user_pref("bool.pref", true);
user_pref("int.pref", 123);
user_pref("string.pref", "value");
''');

      expect(result.prefs, <String, Object>{
        'bool.pref': true,
        'int.pref': 123,
        'string.pref': 'value',
      });
    });

    test('parses signed integers with trivia after the sign', () {
      final result = parseUserJs('''
user_pref("int.spaces", +  345);
user_pref("int.comment", - /* hmm */	456);
user_pref("int.newline", -
567);
user_pref("int.max", +2147483647);
user_pref("int.min", -2147483648);
''');

      expect(result.prefs['int.spaces'], 345);
      expect(result.prefs['int.comment'], -456);
      expect(result.prefs['int.newline'], -567);
      expect(result.prefs['int.max'], 2147483647);
      expect(result.prefs['int.min'], -2147483648);
    });

    test('duplicate pref names use last-write-wins semantics', () {
      final result = parseUserJs('''
user_pref("dup.pref", 1);
user_pref("dup.pref", 2);
''');

      expect(result.prefs['dup.pref'], 2);
    });

    test('accepts only user_pref entries in user.js input', () {
      final result = parseUserJs('''
pref("ignored.pref", true);
user_pref("kept.pref", false);
''');

      expect(result.prefs, <String, Object>{'kept.pref': false});
    });

    test('preserves comment-looking text inside strings', () {
      final result = parseUserJs(
        '''user_pref("comment.text", "before /* keep */ // still text after");''',
      );

      expect(
        result.prefs['comment.text'],
        'before /* keep */ // still text after',
      );
    });

    test('parses single-quoted strings', () {
      final result = parseUserJs(
        """user_pref('single.pref', 'single quoted value');""",
      );

      expect(result.prefs['single.pref'], 'single quoted value');
    });

    test('parses Firefox hex and unicode escapes', () {
      final result = parseUserJs(
        r'''user_pref("escaped.pref", "quote \" slash \\ newline \n carriage \r hex \x41 unicode \u0042");''',
      );

      expect(
        result.prefs['escaped.pref'],
        'quote " slash \\ newline \n carriage \r hex A unicode B'
            .replaceAll(r'\n', '\n')
            .replaceAll(r'\r', '\r'),
      );
    });

    test('preserves raw line breaks inside string literals', () {
      final result = parseUserJs(
        '''
user_pref("raw.newlines", "line 1
line 2\rline 3");
'''
            .replaceAll(r'\r', '\r'),
      );

      expect(result.prefs['raw.newlines'], 'line 1\nline 2\rline 3');
    });
  });
}
