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
import 'package:weblibre/utils/url_canonical.dart';

void main() {
  group('canonicalizeUrl', () {
    test('canonicalizes http URLs structurally', () {
      final canonical = canonicalizeUrl(
        'HTTPS://Example.com:443/path?q=1#fragment',
      );

      expect(canonical, isNotNull);
      expect(canonical!.canonical, 'https://example.com/path?q=1');
      expect(canonical.host, 'example.com');
      expect(canonical.path, '/path');
    });

    test('preserves about reader URL shape', () {
      const readerUrl = 'about:reader?url=https%3A%2F%2Fexample.com%2Fstory';

      final canonical = canonicalizeUrl(readerUrl);

      expect(canonical, isNotNull);
      expect(canonical!.canonical, readerUrl);
      expect(canonical.host, isEmpty);
      expect(canonical.path, 'reader');
      expect(Uri.parse(canonical.canonical).toString(), readerUrl);
    });
  });

  group('isUrlIndexable', () {
    test('accepts about reader URLs', () {
      expect(
        isUrlIndexable('about:reader?url=https%3A%2F%2Fexample.com%2Fstory'),
        isTrue,
      );
    });

    test('rejects other about URLs', () {
      expect(isUrlIndexable('about:config'), isFalse);
    });
  });
}
