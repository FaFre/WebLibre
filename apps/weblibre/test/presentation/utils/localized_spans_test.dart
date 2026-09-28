import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weblibre/presentation/utils/localized_spans.dart';

void main() {
  const bold = TextSpan(text: 'file.pdf');
  const link = TextSpan(text: 'https://example.com');

  group('localizedSpans', () {
    test('replaces a placeholder in the middle of the sentence', () {
      final spans = localizedSpans(
        'Delete ${spanPlaceholder(0)}?',
        spans: [bold],
      );

      expect(spans, hasLength(3));
      expect((spans[0] as TextSpan).text, 'Delete ');
      expect(spans[1], same(bold));
      expect((spans[2] as TextSpan).text, '?');
    });

    test('follows the translated order, not the argument order', () {
      final spans = localizedSpans(
        '${spanPlaceholder(1)} then ${spanPlaceholder(0)}',
        spans: [bold, link],
      );

      expect(spans, hasLength(3));
      expect(spans[0], same(link));
      expect((spans[1] as TextSpan).text, ' then ');
      expect(spans[2], same(bold));
    });

    test('emits no empty text spans around edge placeholders', () {
      final spans = localizedSpans(
        '${spanPlaceholder(0)}${spanPlaceholder(1)}',
        spans: [bold, link],
      );

      expect(spans, [same(bold), same(link)]);
    });

    test('returns the message as one span when it has no placeholder', () {
      final spans = localizedSpans('Nothing to style');

      expect(spans, hasLength(1));
      expect((spans.single as TextSpan).text, 'Nothing to style');
    });
  });

  group('localizedSpans tags', () {
    InlineSpan link(String text) =>
        TextSpan(text: text, style: const TextStyle());

    test('passes the translated text between the tags to the builder', () {
      final spans = localizedSpans(
        'Accept the <eula>License</eula> and <privacy>Privacy Policy</privacy>.',
        tags: {'eula': link, 'privacy': link},
      );

      expect(
        [for (final s in spans) (s as TextSpan).text],
        ['Accept the ', 'License', ' and ', 'Privacy Policy', '.'],
      );
      expect((spans[1] as TextSpan).style, isNotNull);
      expect((spans[2] as TextSpan).style, isNull);
    });

    test('mixes tags with span placeholders', () {
      final spans = localizedSpans(
        '${spanPlaceholder(0)} wants to open <more>this link</more>',
        spans: [bold],
        tags: {'more': link},
      );

      expect(spans[0], same(bold));
      expect((spans[1] as TextSpan).text, ' wants to open ');
      expect((spans[2] as TextSpan).text, 'this link');
    });

    test('leaves unregistered tags as literal text', () {
      final spans = localizedSpans(
        'Keep <b>this</b> and <more>that</more>',
        tags: {'more': link},
      );

      expect((spans[0] as TextSpan).text, 'Keep <b>this</b> and ');
      expect((spans[1] as TextSpan).text, 'that');
    });

    test('keeps tag-like text inside a span value literal', () {
      const value = TextSpan(text: '<more>evil</more>');
      final spans = localizedSpans(
        'Open ${spanPlaceholder(0)}? <more>Details</more>',
        spans: [value],
        tags: {'more': link},
      );

      expect(spans[1], same(value));
      expect((spans[3] as TextSpan).text, 'Details');
    });

    test('asserts when a translation drops a tag', () {
      expect(
        () => localizedSpans('No link here', tags: {'more': link}),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts when a translation drops a span placeholder', () {
      expect(
        () => localizedSpans('Nothing to style', spans: [bold]),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
