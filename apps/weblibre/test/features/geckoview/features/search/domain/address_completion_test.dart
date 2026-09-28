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
import 'package:weblibre/features/geckoview/features/search/domain/services/address_completion.dart';

List<Uri> _uris(List<String> urls) => urls.map(Uri.parse).toList();

void main() {
  group('addressCompletionFor', () {
    test('completes a host from its first letters', () {
      expect(
        addressCompletionFor('git', _uris(['https://github.com/weblibre'])),
        'github.com',
      );
    });

    test('skips a leading www. on the saved host', () {
      expect(
        addressCompletionFor('exa', _uris(['https://www.example.org/a'])),
        'example.org',
      );
    });

    test('keeps what was typed, in the case it was typed', () {
      expect(
        addressCompletionFor('GiT', _uris(['https://github.com'])),
        'GiThub.com',
      );
      expect(
        addressCompletionFor('www.exa', _uris(['https://www.example.org'])),
        'www.example.org',
      );
      expect(
        addressCompletionFor('https://git', _uris(['https://github.com'])),
        'https://github.com',
      );
    });

    test('never changes a typed scheme', () {
      expect(
        addressCompletionFor('http://git', _uris(['https://github.com'])),
        isNull,
      );
    });

    test('a typed www. needs a www. host', () {
      expect(
        addressCompletionFor('www.git', _uris(['https://github.com'])),
        isNull,
      );
    });

    test('completes the path one segment at a time once a slash is typed', () {
      final bookmarks = _uris(['https://github.com/weblibre/browser?tab=1#x']);

      expect(
        addressCompletionFor('github.com/', bookmarks),
        'github.com/weblibre/',
      );
      expect(
        addressCompletionFor('github.com/we', bookmarks),
        'github.com/weblibre/',
      );
      expect(
        addressCompletionFor('github.com/weblibre/b', bookmarks),
        'github.com/weblibre/browser',
      );
    });

    test('keeps a non-default port with the host', () {
      expect(
        addressCompletionFor('local', _uris(['http://localhost:8080/app'])),
        'localhost:8080',
      );
    });

    test('takes the first candidate that completes the input', () {
      expect(
        addressCompletionFor(
          'git',
          _uris([
            'https://example.org/git',
            'https://gitlab.com',
            'https://github.com',
          ]),
        ),
        'gitlab.com',
      );
    });

    test('offers nothing when the input is already complete', () {
      expect(
        addressCompletionFor('github.com', _uris(['https://github.com'])),
        isNull,
      );
    });

    test('ignores non-web addresses', () {
      expect(
        addressCompletionFor('fi', _uris(['file:///home/fi/notes.txt'])),
        isNull,
      );
      expect(addressCompletionFor('ex', _uris(['ftp://example.org'])), isNull);
    });

    test('never completes a search phrase or a bare prefix', () {
      final bookmarks = _uris(['https://github.com']);

      expect(addressCompletionFor('git hub', bookmarks), isNull);
      expect(addressCompletionFor('', bookmarks), isNull);
      expect(addressCompletionFor('https://', bookmarks), isNull);
      expect(addressCompletionFor('www.', bookmarks), isNull);
    });
  });
}
