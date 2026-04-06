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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/utils/text_highlight.dart';

void main() {
  group('buildHighlightedText', () {
    const baseStyle = TextStyle(color: Colors.black);
    const highlightStyle = TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.bold,
    );
    const matchPrefix = '***';
    const matchSuffix = '***';

    test('returns plain text when no highlights present', () {
      final result = buildHighlightedText(
        'Hello world',
        baseStyle,
        highlightStyle,
        matchPrefix,
        matchSuffix,
      );

      expect(result.children?.length, 1);
      final span = result.children![0] as TextSpan;
      expect(span.text, 'Hello world');
      expect(span.style, baseStyle);
    });

    test('highlights single match in middle of text', () {
      final result = buildHighlightedText(
        'Hello ***world***!',
        baseStyle,
        highlightStyle,
        matchPrefix,
        matchSuffix,
      );

      expect(result.children?.length, 3);

      final span1 = result.children![0] as TextSpan;
      expect(span1.text, 'Hello ');
      expect(span1.style, baseStyle);

      final span2 = result.children![1] as TextSpan;
      expect(span2.text, 'world');
      expect(span2.style, highlightStyle);

      final span3 = result.children![2] as TextSpan;
      expect(span3.text, '!');
      expect(span3.style, baseStyle);
    });

    test('highlights multiple matches', () {
      final result = buildHighlightedText(
        'The ***quick*** brown ***fox***',
        baseStyle,
        highlightStyle,
        matchPrefix,
        matchSuffix,
      );

      expect(result.children?.length, 4);

      expect((result.children![0] as TextSpan).text, 'The ');
      expect((result.children![0] as TextSpan).style, baseStyle);

      expect((result.children![1] as TextSpan).text, 'quick');
      expect((result.children![1] as TextSpan).style, highlightStyle);

      expect((result.children![2] as TextSpan).text, ' brown ');
      expect((result.children![2] as TextSpan).style, baseStyle);

      expect((result.children![3] as TextSpan).text, 'fox');
      expect((result.children![3] as TextSpan).style, highlightStyle);
    });

    test('handles highlight at start of text', () {
      final result = buildHighlightedText(
        '***Hello*** world',
        baseStyle,
        highlightStyle,
        matchPrefix,
        matchSuffix,
      );

      expect(result.children?.length, 2);

      final span1 = result.children![0] as TextSpan;
      expect(span1.text, 'Hello');
      expect(span1.style, highlightStyle);

      final span2 = result.children![1] as TextSpan;
      expect(span2.text, ' world');
      expect(span2.style, baseStyle);
    });

    test('handles highlight at end of text', () {
      final result = buildHighlightedText(
        'Hello ***world***',
        baseStyle,
        highlightStyle,
        matchPrefix,
        matchSuffix,
      );

      expect(result.children?.length, 2);

      final span1 = result.children![0] as TextSpan;
      expect(span1.text, 'Hello ');
      expect(span1.style, baseStyle);

      final span2 = result.children![1] as TextSpan;
      expect(span2.text, 'world');
      expect(span2.style, highlightStyle);
    });

    test('handles entire text highlighted', () {
      final result = buildHighlightedText(
        '***Hello world***',
        baseStyle,
        highlightStyle,
        matchPrefix,
        matchSuffix,
      );

      expect(result.children?.length, 1);

      final span = result.children![0] as TextSpan;
      expect(span.text, 'Hello world');
      expect(span.style, highlightStyle);
    });

    test('handles consecutive highlights', () {
      final result = buildHighlightedText(
        '***hello******world***',
        baseStyle,
        highlightStyle,
        matchPrefix,
        matchSuffix,
      );

      expect(result.children?.length, 2);

      expect((result.children![0] as TextSpan).text, 'hello');
      expect((result.children![0] as TextSpan).style, highlightStyle);

      expect((result.children![1] as TextSpan).text, 'world');
      expect((result.children![1] as TextSpan).style, highlightStyle);
    });

    test('handles empty highlight', () {
      final result = buildHighlightedText(
        'Hello ******world',
        baseStyle,
        highlightStyle,
        matchPrefix,
        matchSuffix,
      );

      expect(result.children?.length, 3);

      expect((result.children![0] as TextSpan).text, 'Hello ');
      expect((result.children![1] as TextSpan).text, '');
      expect((result.children![2] as TextSpan).text, 'world');
    });

    test('handles unclosed prefix marker', () {
      final result = buildHighlightedText(
        'Hello ***world',
        baseStyle,
        highlightStyle,
        matchPrefix,
        matchSuffix,
      );

      // When suffix not found, highlight everything after prefix to end
      expect(result.children?.length, 2);

      expect((result.children![0] as TextSpan).text, 'Hello ');
      expect((result.children![0] as TextSpan).style, baseStyle);
      expect((result.children![1] as TextSpan).text, 'world');
      expect((result.children![1] as TextSpan).style, highlightStyle);
    });

    test('handles missing suffix marker', () {
      final result = buildHighlightedText(
        '***Hello',
        baseStyle,
        highlightStyle,
        matchPrefix,
        matchSuffix,
      );

      expect(result.children?.length, 1);

      final span = result.children![0] as TextSpan;
      expect(span.text, 'Hello');
      expect(span.style, highlightStyle);
    });

    test('handles empty string', () {
      final result = buildHighlightedText(
        '',
        baseStyle,
        highlightStyle,
        matchPrefix,
        matchSuffix,
      );

      expect(result.children?.length, 0);
    });

    test('handles different prefix and suffix markers', () {
      final result = buildHighlightedText(
        'Hello <mark>world</mark>!',
        baseStyle,
        highlightStyle,
        '<mark>',
        '</mark>',
      );

      expect(result.children?.length, 3);

      expect((result.children![0] as TextSpan).text, 'Hello ');
      expect((result.children![1] as TextSpan).text, 'world');
      expect((result.children![1] as TextSpan).style, highlightStyle);
      expect((result.children![2] as TextSpan).text, '!');
    });

    // Note: Nested markers behavior is undefined and not a real-world FTS5 scenario
    // This test is skipped as the exact parsing behavior for nested markers
    // is implementation-specific and not guaranteed

    test('handles null styles', () {
      final result = buildHighlightedText(
        'Hello ***world***!',
        null,
        null,
        matchPrefix,
        matchSuffix,
      );

      expect(result.children?.length, 3);

      expect((result.children![0] as TextSpan).style, null);
      expect((result.children![1] as TextSpan).style, null);
      expect((result.children![2] as TextSpan).style, null);
    });

    test('real-world FTS5 example', () {
      final result = buildHighlightedText(
        'Mozilla Developer Network (***MDN***) Web Docs',
        baseStyle,
        highlightStyle,
        matchPrefix,
        matchSuffix,
      );

      expect(result.children?.length, 3);

      expect(
        (result.children![0] as TextSpan).text,
        'Mozilla Developer Network (',
      );
      expect((result.children![1] as TextSpan).text, 'MDN');
      expect((result.children![1] as TextSpan).style, highlightStyle);
      expect((result.children![2] as TextSpan).text, ') Web Docs');
    });
  });
}
