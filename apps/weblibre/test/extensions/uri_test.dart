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
import 'package:weblibre/extensions/uri.dart';

void main() {
  group('Uri display formatting', () {
    test('decodes path segments for read-only display', () {
      final uri = Uri.parse(
        'https://example.com/hello%20world/caf%C3%A9?greeting=Ol%C3%A1%20mundo#frag%20ment',
      );

      expect(
        uri.displayString,
        'https://example.com/hello world/café?greeting=Ol%C3%A1%20mundo#frag%20ment',
      );
      expect(uri.pathSegments, ['hello world', 'café']);
    });

    test('uses decoded path segments', () {
      final uri = Uri.parse('https://example.com/path%2Fwith%2Fslash');

      expect(uri.displayString, 'https://example.com/path/with/slash');
      expect(uri.pathSegments, ['path/with/slash']);
    });

    test('keeps query encoded', () {
      final uri = Uri.parse(
        'https://example.com/?q=fish%20%26%20chips&redirect=a%2Fb',
      );

      expect(
        uri.displayString,
        'https://example.com/?q=fish%20%26%20chips&redirect=a%2Fb',
      );
    });

    test('uses authority as-is for display', () {
      final uri = Uri.parse('https://user%20name@example.com/path');

      expect(uri.authority, 'user%20name@example.com');
    });

    test('leaves malformed escapes unchanged', () {
      expect(
        'https://example.com/%ZZ?query=%'.uriDisplayString,
        'https://example.com/%ZZ?query=%',
      );
    });

    test('preserves trailing slash exactly once', () {
      final uri = Uri.parse('http://x.com/a/b/');

      expect(uri.displayString, 'http://x.com/a/b/');
    });

    test('decodes Cyrillic Reddit URL with trailing slash', () {
      final uri = Uri.parse(
        'https://www.reddit.com/r/KafkaFPS/comments/1sn0j5w/'
        '%D0%BF%D0%B5%D1%80%D0%B5%D1%81%D1%82%D0%B0%D0%BD%D1%8C%D1%82%D0%B5'
        '_%D1%81%D0%BE%D0%BF%D1%80%D0%BE%D1%82%D0%B8%D0%B2%D0%BB%D1%8F'
        '%D1%82%D1%8C%D1%81%D1%8F_%D0%BC%D0%B8%D1%81%D1%82%D0%B5%D1%80'
        '_%D0%B0%D0%BD%D0%B4%D0%B5%D1%80%D1%81%D0%BE%D0%BD/',
      );

      expect(
        uri.displayString,
        'https://www.reddit.com/r/KafkaFPS/comments/1sn0j5w/'
        'перестаньте_сопротивляться_мистер_андерсон/',
      );
    });

    test('keeps IDN punycode host as-is', () {
      expect(
        'https://xn--j1ail.xn--p1ai/'.uriDisplayString,
        'https://xn--j1ail.xn--p1ai/',
      );
    });
  });
}
