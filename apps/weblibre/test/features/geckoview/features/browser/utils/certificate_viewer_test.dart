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
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/browser/utils/certificate_viewer.dart';

void main() {
  group('certificateViewerUri', () {
    // Bytes whose base64 contains '+', '/' and '=' padding.
    final der = Uint8List.fromList([0xfb, 0xff, 0xbf, 0x00, 0x01]);

    test('points at about:certificate', () {
      final uri = certificateViewerUri(der);

      expect(uri.scheme, 'about');
      expect(uri.path, 'certificate');
    });

    test('percent-encodes base64 so the viewer decodes it intact', () {
      final encoded = base64Encode(der);
      expect(encoded, contains('+'));
      expect(encoded, contains('/'));
      expect(encoded, contains('='));

      final url = certificateViewerUri(der).toString();

      // URLSearchParams reads a raw '+' as a space.
      expect(url, isNot(contains('+')));
      expect(Uri.parse(url).queryParameters['cert'], encoded);
    });
  });
}
