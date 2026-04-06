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
import 'package:weblibre/utils/uri_input_parser.dart';
import 'package:weblibre/utils/uri_policy.dart';

void main() {
  group('parseExplicitUri', () {
    test('parses supported explicit scheme', () {
      final uri = parseExplicitUri(
        'https://weblibre.eu/path',
        policy: SchemePolicy.addressBarTyped,
      );

      expect(uri, isNotNull);
      expect(uri!.scheme, 'https');
      expect(uri.host, 'weblibre.eu');
    });

    test('rejects unsupported explicit scheme', () {
      final uri = parseExplicitUri(
        'javascript:alert(1)',
        policy: SchemePolicy.addressBarTyped,
      );

      expect(uri, isNull);
    });

    test('rejects malformed explicit uri with required authority', () {
      final uri = parseExplicitUri(
        'https:///path',
        policy: SchemePolicy.addressBarTyped,
      );

      expect(uri, isNull);
    });
  });

  group('parseSchemelessWebHost', () {
    test('upgrades domain to https', () {
      final uri = parseSchemelessWebHost('weblibre.eu');

      expect(uri, isNotNull);
      expect(uri!.toString(), 'https://weblibre.eu');
    });

    test('upgrades localhost to http', () {
      final uri = parseSchemelessWebHost('localhost:8080');

      expect(uri, isNotNull);
      expect(uri!.toString(), 'http://localhost:8080');
    });

    test('rejects spaces in host candidate', () {
      expect(parseSchemelessWebHost('foo bar.com'), isNull);
    });

    test('rejects invalid port range', () {
      expect(parseSchemelessWebHost('weblibre.eu:99999'), isNull);
    });
  });

  group('parseUserInputUrl', () {
    test('parses schemeless host only when enabled', () {
      expect(
        parseUserInputUrl('weblibre.eu', policy: SchemePolicy.addressBarTyped),
        isNull,
      );

      expect(
        parseUserInputUrl(
          'weblibre.eu',
          policy: SchemePolicy.addressBarTyped,
          allowSchemelessHosts: true,
        ),
        isNotNull,
      );
    });

    test('rejects control chars', () {
      expect(
        parseUserInputUrl(
          'example.com\x00path',
          policy: SchemePolicy.addressBarTyped,
          allowSchemelessHosts: true,
        ),
        isNull,
      );
    });

    test('allows long persisted urls when max length is not enforced', () {
      final longPath = 'a' * 5000;
      final uri = parseUserInputUrl(
        'https://weblibre.eu/$longPath',
        policy: SchemePolicy.addressBarTyped,
      );

      expect(uri, isNotNull);
    });

    test('rejects long user input urls when max length is enforced', () {
      final longPath = 'a' * 5000;
      final uri = parseUserInputUrl(
        'https://weblibre.eu/$longPath',
        policy: SchemePolicy.addressBarTyped,
        enforceMaxInputLength: true,
      );

      expect(uri, isNull);
    });
  });

  group('redactUriCredentials', () {
    test('strips userInfo from URI', () {
      final uri = Uri.parse('https://user:pass@example.com/path');
      final redacted = redactUriCredentials(uri);

      expect(redacted.userInfo, isEmpty);
      expect(redacted.host, 'example.com');
      expect(redacted.path, '/path');
      expect(redacted.toString(), 'https://example.com/path');
    });

    test('is no-op for URIs without credentials', () {
      final uri = Uri.parse('https://example.com/path');
      final redacted = redactUriCredentials(uri);

      expect(identical(redacted, uri), isTrue);
    });
  });

  group('isValidHostCandidate', () {
    test('rejects single-label hosts', () {
      expect(isValidHostCandidate('example'), isFalse);
      expect(isValidHostCandidate('intranet'), isFalse);
    });
  });

  group('containsControlChars', () {
    test('detects null bytes', () {
      expect(containsControlChars('example\x00.com'), isTrue);
    });

    test('detects C1 control chars', () {
      expect(containsControlChars('example\u0080.com'), isTrue);
      expect(containsControlChars('example\u009F.com'), isTrue);
    });

    test('allows normal text', () {
      expect(containsControlChars('example.com'), isFalse);
    });
  });
}
