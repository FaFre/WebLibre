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
import 'package:weblibre/features/share_intent/domain/entities/shared_content.dart';

void main() {
  group('SharedContent.parse', () {
    test('returns SharedUrl for explicit https uri', () {
      final parsed = SharedContent.parse('https://weblibre.eu/path');

      expect(parsed, isA<SharedUrl>());
      expect((parsed as SharedUrl).url.host, 'weblibre.eu');
    });

    test('returns SharedText for explicit non-http scheme', () {
      final parsed = SharedContent.parse('moz-extension://abc/index.html');

      expect(parsed, isA<SharedText>());
    });

    test('returns SharedText for plain sentence', () {
      final parsed = SharedContent.parse('WebLibre README.md');

      expect(parsed, isA<SharedText>());
    });
  });
}
