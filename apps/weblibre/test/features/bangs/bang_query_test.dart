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
import 'package:weblibre/features/bangs/domain/services/bang_query.dart';

void main() {
  group('parseBangInput', () {
    test('lifts a leading bang out of the query', () {
      final parsed = parseBangInput('!g cats');

      expect(parsed.trigger, 'g');
      expect(parsed.query, 'cats');
    });

    test('lifts a trailing bang out of the query', () {
      final parsed = parseBangInput('cats !g');

      expect(parsed.trigger, 'g');
      expect(parsed.query, 'cats');
    });

    test('lifts a bang from the middle, keeping word order', () {
      final parsed = parseBangInput('best !g cat food');

      expect(parsed.trigger, 'g');
      expect(parsed.query, 'best cat food');
    });

    test('a bang on its own leaves an empty query', () {
      final parsed = parseBangInput('!g');

      expect(parsed.trigger, 'g');
      expect(parsed.query, isEmpty);
    });

    test('leaves a plain first word alone', () {
      // `!apple` may well exist, but `apple pie` is a search for apple pie.
      final parsed = parseBangInput('apple pie');

      expect(parsed.hasBang, isFalse);
      expect(parsed.query, 'apple pie');
    });

    test('a lone ! is not a bang', () {
      final parsed = parseBangInput('! g');

      expect(parsed.hasBang, isFalse);
      expect(parsed.query, '! g');
    });

    test('consumes only the first bang', () {
      // Silently switching engines on the second one would be worse than
      // leaving it visible in the query.
      final parsed = parseBangInput('!g !w cats');

      expect(parsed.trigger, 'g');
      expect(parsed.query, '!w cats');
    });

    test('returns bang-free input completely untouched', () {
      const input = '  spacing   preserved  ';

      expect(parseBangInput(input).query, input);
    });
  });

  group('bangTriggerCandidate', () {
    test('prefers an explicit bang wherever it sits', () {
      expect(bangTriggerCandidate('cats !g'), 'g');
    });

    test('falls back to the first word while the user is still typing', () {
      expect(bangTriggerCandidate('goo'), 'goo');
    });

    test('is empty for blank input', () {
      expect(bangTriggerCandidate('   '), isEmpty);
    });
  });

  group('parseBangAliases', () {
    test('accepts commas, spaces and optional prefixes alike', () {
      expect(parseBangAliases('!yt, ytm  youtube', trigger: 'y'), {
        'yt',
        'ytm',
        'youtube',
      });
    });

    test('drops the primary trigger, case insensitively', () {
      // Two rows claiming the same word, one in `bang` and one in
      // `bang_triggers`, would make resolution order matter for no reason.
      expect(parseBangAliases('G, images', trigger: 'g'), {'images'});
    });

    test('deduplicates', () {
      expect(parseBangAliases('yt, !yt, yt', trigger: 'ytm'), {'yt'});
    });

    test('is null when nothing is left', () {
      expect(parseBangAliases('  ,  ', trigger: 'g'), isNull);
      expect(parseBangAliases('!g', trigger: 'g'), isNull);
    });

    test('round-trips through the editor field', () {
      const aliases = {'yt', 'ytm'};

      expect(
        parseBangAliases(formatBangAliases(aliases), trigger: 'youtube'),
        aliases,
      );
    });

    test('formats an absent set as an empty field', () {
      expect(formatBangAliases(null), isEmpty);
    });
  });

  group('normalizeBangSearchInput', () {
    test('drops the prefix the index does not store', () {
      expect(normalizeBangSearchInput('!g cats'), 'g cats');
    });
  });
}
