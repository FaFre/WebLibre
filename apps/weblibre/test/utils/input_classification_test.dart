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
import 'package:weblibre/utils/input_classification.dart';

void main() {
  group('classifyAddressBarInput', () {
    test('searches free text containing whitespace', () {
      final result = classifyAddressBarInput('WebLibre README.md');

      expect(result, isA<SearchInputClassification>());
      final search = result as SearchInputClassification;
      expect(search.reason, SearchReason.containsWhitespace);
      expect(search.query, 'WebLibre README.md');
    });

    test('navigates schemeless domain', () {
      final result = classifyAddressBarInput('weblibre.eu');

      expect(result, isA<NavigateInputClassification>());
      final navigation = result as NavigateInputClassification;
      expect(navigation.reason, NavigationReason.schemelessHost);
      expect(navigation.uri.toString(), 'https://weblibre.eu');
    });

    test('navigates localhost over http', () {
      final result = classifyAddressBarInput('localhost:8080');

      expect(result, isA<NavigateInputClassification>());
      final navigation = result as NavigateInputClassification;
      expect(navigation.reason, NavigationReason.localhost);
      expect(navigation.uri.toString(), 'http://localhost:8080');
    });

    test('navigates explicit moz-extension uri', () {
      final result = classifyAddressBarInput('moz-extension://abc/index.html');

      expect(result, isA<NavigateInputClassification>());
      final navigation = result as NavigateInputClassification;
      expect(navigation.reason, NavigationReason.explicitScheme);
      expect(navigation.uri.scheme, 'moz-extension');
    });

    test('rejects explicit unsupported scheme as invalid', () {
      final result = classifyAddressBarInput('myapp://callback?token=abc');

      expect(result, isA<InvalidInputClassification>());
      final invalid = result as InvalidInputClassification;
      expect(invalid.reason, InvalidReason.unsupportedScheme);
    });

    test('rejects dotted explicit unsupported scheme as invalid', () {
      final result = classifyAddressBarInput('my.app://callback');

      expect(result, isA<InvalidInputClassification>());
      final invalid = result as InvalidInputClassification;
      expect(invalid.reason, InvalidReason.unsupportedScheme);
    });

    test('rejects javascript scheme as invalid', () {
      final result = classifyAddressBarInput('JAVASCRIPT:alert(1)');

      expect(result, isA<InvalidInputClassification>());
      final invalid = result as InvalidInputClassification;
      expect(invalid.reason, InvalidReason.unsupportedScheme);
    });

    test('does not decode encoded scheme before classification', () {
      final result = classifyAddressBarInput('%6aavascript:alert(1)');

      expect(result, isA<SearchInputClassification>());
    });

    test('rejects control chars as invalid', () {
      final result = classifyAddressBarInput('example.com\x00path');

      expect(result, isA<InvalidInputClassification>());
      final invalid = result as InvalidInputClassification;
      expect(invalid.reason, InvalidReason.containsControlChars);
    });

    test('invalid schemeless port falls back to search', () {
      final result = classifyAddressBarInput('weblibre.eu:99999');

      expect(result, isA<SearchInputClassification>());
    });

    test('explicit disallowed scheme with whitespace remains invalid', () {
      final result = classifyAddressBarInput('javascript: alert(1)');

      expect(result, isA<InvalidInputClassification>());
      final invalid = result as InvalidInputClassification;
      expect(invalid.reason, InvalidReason.unsupportedScheme);
    });

    test('unknown explicit scheme with whitespace remains invalid', () {
      final result = classifyAddressBarInput('myapp: secret token');

      expect(result, isA<InvalidInputClassification>());
      final invalid = result as InvalidInputClassification;
      expect(invalid.reason, InvalidReason.unsupportedScheme);
    });

    test('colon-prefixed query with whitespace is treated as invalid', () {
      final result = classifyAddressBarInput('site:weblibre.eu privacy');

      expect(result, isA<InvalidInputClassification>());
      final invalid = result as InvalidInputClassification;
      expect(invalid.reason, InvalidReason.unsupportedScheme);
    });

    test('symbolic colon query with whitespace is treated as invalid', () {
      final result = classifyAddressBarInput('c++: tutorial');

      expect(result, isA<InvalidInputClassification>());
      final invalid = result as InvalidInputClassification;
      expect(invalid.reason, InvalidReason.unsupportedScheme);
    });

    test('navigates schemeless domain with valid port', () {
      final result = classifyAddressBarInput('weblibre.eu:8080');

      expect(result, isA<NavigateInputClassification>());
      final navigation = result as NavigateInputClassification;
      expect(navigation.reason, NavigationReason.schemelessHost);
      expect(navigation.uri.toString(), 'https://weblibre.eu:8080');
    });

    test('navigates IP literal', () {
      final result = classifyAddressBarInput('192.168.1.1');

      expect(result, isA<NavigateInputClassification>());
      final navigation = result as NavigateInputClassification;
      expect(navigation.reason, NavigationReason.ipLiteral);
      expect(navigation.uri.toString(), 'https://192.168.1.1');
    });

    test('navigates explicit scheme with space in path', () {
      final result = classifyAddressBarInput('https://example.com/a b');

      expect(result, isA<NavigateInputClassification>());
      final navigation = result as NavigateInputClassification;
      expect(navigation.reason, NavigationReason.explicitScheme);
      expect(navigation.uri.host, 'example.com');
    });

    test('rejects data scheme as invalid', () {
      final result = classifyAddressBarInput(
        'data:text/html,<script>alert(1)</script>',
      );

      expect(result, isA<InvalidInputClassification>());
      final invalid = result as InvalidInputClassification;
      expect(invalid.reason, InvalidReason.unsupportedScheme);
    });

    test('treats missing scheme prefix as search', () {
      final result = classifyAddressBarInput('://example.com');

      expect(result, isA<SearchInputClassification>());
    });

    test('navigates URL with credentials', () {
      final result = classifyAddressBarInput('https://user:pass@example.com');

      expect(result, isA<NavigateInputClassification>());
      final navigation = result as NavigateInputClassification;
      expect(navigation.reason, NavigationReason.explicitScheme);
      expect(navigation.uri.host, 'example.com');
    });

    test('rejects very long input as tooLong', () {
      final longInput = 'a' * 5000;
      final result = classifyAddressBarInput(longInput);

      expect(result, isA<InvalidInputClassification>());
      final invalid = result as InvalidInputClassification;
      expect(invalid.reason, InvalidReason.tooLong);
    });

    test('rejects empty input as emptyInput', () {
      final result = classifyAddressBarInput('');

      expect(result, isA<InvalidInputClassification>());
      final invalid = result as InvalidInputClassification;
      expect(invalid.reason, InvalidReason.emptyInput);
    });

    test('rejects whitespace-only input as emptyInput', () {
      final result = classifyAddressBarInput('   ');

      expect(result, isA<InvalidInputClassification>());
      final invalid = result as InvalidInputClassification;
      expect(invalid.reason, InvalidReason.emptyInput);
    });
  });

  group('parseSharedIntentUrl', () {
    test('parses explicit https', () {
      final uri = parseSharedIntentUrl('https://weblibre.eu');

      expect(uri, isNotNull);
      expect(uri!.scheme, 'https');
    });

    test('treats explicit non-http scheme as non-url', () {
      final uri = parseSharedIntentUrl('moz-extension://abc/index.html');

      expect(uri, isNull);
    });

    test('treats explicit dotted non-http scheme as non-url', () {
      final uri = parseSharedIntentUrl('my.app://callback');

      expect(uri, isNull);
    });

    test('treats plain sentence as non-url', () {
      final uri = parseSharedIntentUrl('This is WebLibre README.md');

      expect(uri, isNull);
    });
  });
}
