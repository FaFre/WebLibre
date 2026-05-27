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
import 'package:weblibre/features/bangs/domain/services/reverse_match.dart';

void main() {
  group('BangUrlPattern - main URL placeholder', () {
    test('query param: captures simple search query', () {
      final p = BangUrlPattern.parse('https://www.google.com/search?q={{{s}}}');
      expect(p, isNotNull);
      expect(
        p!.match(Uri.parse('https://www.google.com/search?q=hello+world')),
        'hello world',
      );
    });

    test('query param: tolerates extra tracking params', () {
      final p = BangUrlPattern.parse('https://www.google.com/search?q={{{s}}}');
      expect(
        p!.match(
          Uri.parse(
            'https://www.google.com/search?q=cats&hl=de&utm_source=foo',
          ),
        ),
        'cats',
      );
    });

    test('query param: enforces other required constants', () {
      final p = BangUrlPattern.parse(
        'https://www.google.com/search?q={{{s}}}&tbm=isch',
      );
      expect(
        p!.match(Uri.parse('https://www.google.com/search?q=cats&tbm=isch')),
        'cats',
      );
      expect(
        p.match(Uri.parse('https://www.google.com/search?q=cats')),
        isNull,
      );
    });

    test('path segment: captures search term', () {
      final p = BangUrlPattern.parse(
        'https://en.wikipedia.org/wiki/{{{s}}}',
      );
      expect(
        p!.match(Uri.parse('https://en.wikipedia.org/wiki/Flutter')),
        'Flutter',
      );
    });

    test('path segment: enforces non-placeholder segments', () {
      final p = BangUrlPattern.parse(
        'https://www.ebay.com/sch/{{{s}}}/m.html',
      );
      expect(
        p!.match(Uri.parse('https://www.ebay.com/sch/toys/m.html')),
        'toys',
      );
      expect(
        p.match(Uri.parse('https://www.ebay.com/sch/toys/wrong.html')),
        isNull,
      );
    });

    test('path segment: supports prefix/suffix in same segment', () {
      final p = BangUrlPattern.parse(
        'https://site.com/find/prefix-{{{s}}}-end',
      );
      expect(
        p!.match(Uri.parse('https://site.com/find/prefix-Foo-end')),
        'Foo',
      );
      expect(
        p.match(Uri.parse('https://site.com/find/Foo-end')),
        isNull,
      );
    });

    test('host mismatch rejects', () {
      final p = BangUrlPattern.parse('https://google.com/search?q={{{s}}}');
      expect(
        p!.match(Uri.parse('https://bing.com/search?q=foo')),
        isNull,
      );
    });

    test('path length mismatch rejects', () {
      final p = BangUrlPattern.parse('https://x.com/a?q={{{s}}}');
      expect(
        p!.match(Uri.parse('https://x.com/a/b?q=foo')),
        isNull,
      );
    });

    test('empty captured query is rejected', () {
      final p = BangUrlPattern.parse('https://google.com/?q={{{s}}}');
      expect(p!.match(Uri.parse('https://google.com/?q=')), isNull);
    });
  });

  group('BangUrlPattern - fragment placeholder', () {
    test('hash query: 4chan-style #s={{{s}}}', () {
      final p = BangUrlPattern.parse(
        'https://boards.4chan.org/g/catalog#s={{{s}}}',
      );
      expect(p, isNotNull);
      expect(
        p!.match(Uri.parse('https://boards.4chan.org/g/catalog#s=keyword')),
        'keyword',
      );
    });

    test('hash path: SPA router /#/foo/{{{s}}}', () {
      final p = BangUrlPattern.parse(
        'https://research.lensai.eu/#/s/search/{{{s}}}',
      );
      expect(p, isNotNull);
      expect(
        p!.match(
          Uri.parse('https://research.lensai.eu/#/s/search/quantum'),
        ),
        'quantum',
      );
    });

    test('hash path: rejects when fragment path constants do not match', () {
      final p = BangUrlPattern.parse(
        'https://research.lensai.eu/#/s/search/{{{s}}}',
      );
      expect(
        p!.match(
          Uri.parse('https://research.lensai.eu/#/s/answer/quantum'),
        ),
        isNull,
      );
    });

    test('hash query: tolerates extra fragment params', () {
      final p = BangUrlPattern.parse(
        'https://site.example/#s={{{s}}}',
      );
      expect(
        p!.match(Uri.parse('https://site.example/#s=foo&page=2')),
        'foo',
      );
    });

    test('fragment-required template rejects URLs without fragment', () {
      final p = BangUrlPattern.parse(
        'https://boards.4chan.org/g/catalog#s={{{s}}}',
      );
      expect(
        p!.match(Uri.parse('https://boards.4chan.org/g/catalog')),
        isNull,
      );
    });
  });

  group('BangUrlPattern - unsupported templates', () {
    test('multi-placeholder returns null', () {
      expect(
        BangUrlPattern.parse('https://x.com/?a={{{s}}}&b={{{s}}}'),
        isNull,
      );
    });

    test('placeholder in host returns null', () {
      expect(BangUrlPattern.parse('https://{{{s}}}.example.com/'), isNull);
    });

    test('scheme-less template returns null', () {
      expect(BangUrlPattern.parse('//example.com/?q={{{s}}}'), isNull);
    });
  });

  group('BangUrlPattern - tie-break helpers', () {
    test('more required constants score higher', () {
      final plain = BangUrlPattern.parse('https://x.com/?q={{{s}}}')!;
      final imgs = BangUrlPattern.parse(
        'https://x.com/?q={{{s}}}&tbm=isch',
      )!;
      expect(imgs.constraintCount, greaterThan(plain.constraintCount));
    });
  });
}
