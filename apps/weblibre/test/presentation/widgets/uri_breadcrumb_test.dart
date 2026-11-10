/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at) option later version.
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
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';

void main() {
  Widget buildSubject({required Uri uri, bool showHttpScheme = true}) {
    return MaterialApp(
      home: Scaffold(
        body: UriBreadcrumb(uri: uri, showHttpScheme: showHttpScheme),
      ),
    );
  }

  List<String> boldTexts(WidgetTester tester) {
    return tester
        .widgetList<Text>(find.byType(Text))
        .where((t) => t.style?.fontWeight == FontWeight.bold)
        .map((t) => t.data ?? '')
        .toList();
  }

  List<String> allTexts(WidgetTester tester) {
    return tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .toList();
  }

  group('UriBreadcrumb', () {
    group('showHttpScheme defaults to true', () {
      testWidgets('shows scheme before authority for https URLs', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(uri: Uri.parse('https://example.com/path')),
        );

        final all = allTexts(tester);
        expect(all, contains('https'));
        expect(all, contains(' › '));
        final bold = boldTexts(tester);
        expect(bold, contains('example.com'));
        expect(bold, contains('https'));
      });

      testWidgets('shows scheme before authority for http URLs', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(uri: Uri.parse('http://example.com')),
        );

        final all = allTexts(tester);
        expect(all, contains('http'));
        expect(all, contains(' › '));
        final bold = boldTexts(tester);
        expect(bold, contains('example.com'));
        expect(bold, contains('http'));
      });

      testWidgets('shows scheme before authority for non-HTTP URLs', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(uri: Uri.parse('ftp://files.example.com/docs')),
        );

        final all = allTexts(tester);
        expect(all, contains('ftp'));
        expect(all, contains(' › '));
        final bold = boldTexts(tester);
        expect(bold, contains('files.example.com'));
        expect(bold, contains('ftp'));
      });
    });

    group('showHttpScheme is false hides only https', () {
      testWidgets('hides scheme for https URLs', (tester) async {
        await tester.pumpWidget(
          buildSubject(
            uri: Uri.parse('https://example.com/path'),
            showHttpScheme: false,
          ),
        );

        final all = allTexts(tester);
        expect(all, isNot(contains('https')));
        final bold = boldTexts(tester);
        expect(bold, ['example.com']);
      });

      testWidgets('still shows the scheme for plain-http URLs', (tester) async {
        await tester.pumpWidget(
          buildSubject(
            uri: Uri.parse('http://example.com'),
            showHttpScheme: false,
          ),
        );

        final all = allTexts(tester);
        expect(all, contains('http'));
        expect(all, contains(' › '));
        final bold = boldTexts(tester);
        expect(bold, contains('example.com'));
        expect(bold, contains('http'));
      });

      testWidgets('still shows scheme for non-HTTP URLs', (tester) async {
        await tester.pumpWidget(
          buildSubject(
            uri: Uri.parse('ftp://files.example.com/docs'),
            showHttpScheme: false,
          ),
        );

        final all = allTexts(tester);
        expect(all, contains('ftp'));
        expect(all, contains(' › '));
        final bold = boldTexts(tester);
        expect(bold, contains('files.example.com'));
        expect(bold, contains('ftp'));
      });
    });

    group('showQuery', () {
      testWidgets('leaves the query and fragment out by default', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(uri: Uri.parse('https://example.com/feed?format=atom')),
        );

        expect(allTexts(tester), isNot(contains('?format=atom')));
      });

      testWidgets('appends the query and fragment, not bold', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UriBreadcrumb(
                uri: Uri.parse('https://example.com/feed?format=atom#top'),
                showQuery: true,
              ),
            ),
          ),
        );

        expect(allTexts(tester), contains('?format=atom#top'));
        expect(boldTexts(tester), isNot(contains('?format=atom#top')));
      });
    });

    group('wrap', () {
      Future<String> pumpWrapped(WidgetTester tester, Uri uri) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 120,
                child: UriBreadcrumb(
                  uri: uri,
                  showHttpScheme: false,
                  showQuery: true,
                  wrap: true,
                ),
              ),
            ),
          ),
        );
        return tester
            .widget<RichText>(find.byType(RichText).first)
            .text
            .toPlainText();
      }

      testWidgets('renders one wrapping text with the whole address', (
        tester,
      ) async {
        final text = await pumpWrapped(
          tester,
          Uri.parse('https://example.com/a/b?q=1'),
        );

        expect(text, 'example.com › a › b?q=1');
        expect(find.byType(SingleChildScrollView), findsNothing);
        // Wraps instead of overflowing the narrow box.
        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(find.byType(RichText).first).height,
          greaterThan(30),
        );
      });

      testWidgets('keeps the host bold', (tester) async {
        await pumpWrapped(tester, Uri.parse('https://example.com/a'));

        // Text.rich nests the span under one carrying the default style.
        TextSpan? host;
        tester.widget<RichText>(find.byType(RichText).first).text.visitChildren(
          (span) {
            if (span is TextSpan && span.text == 'example.com') {
              host = span;
              return false;
            }
            return true;
          },
        );
        expect(host?.style?.fontWeight, FontWeight.bold);
      });
    });
  });

  group('undecodable paths', () {
    // Uri.tryParse accepts `%FF`, but it is not valid UTF-8, so decoding the
    // path (Uri.pathSegments) throws.
    final uri = Uri.parse('https://example.com/caf%C3%A9/%FF/b?q=%FF');

    testWidgets('keep the bad segment encoded in the scrolling line', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UriBreadcrumb(
              uri: uri,
              showHttpScheme: false,
              showQuery: true,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(allTextsOf(tester), contains(' › café › %FF › b'));
      expect(allTextsOf(tester), contains('?q=%FF'));
    });

    testWidgets('keep the bad segment encoded when wrapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UriBreadcrumb(
              uri: uri,
              showHttpScheme: false,
              showQuery: true,
              wrap: true,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.widget<RichText>(find.byType(RichText).first).text.toPlainText(),
        'example.com › café › %FF › b?q=%FF',
      );
    });
  });

  group('UrlStringBreadcrumb', () {
    Widget build(String url) {
      return MaterialApp(
        home: Scaffold(body: UrlStringBreadcrumb(url: url)),
      );
    }

    testWidgets('renders an address with a host as crumbs', (tester) async {
      await tester.pumpWidget(build('https://example.com/push/'));

      expect(find.byType(UriBreadcrumb), findsOneWidget);
    });

    testWidgets('falls back to plain text without a host', (tester) async {
      await tester.pumpWidget(build('not a url'));

      expect(find.byType(UriBreadcrumb), findsNothing);
      expect(find.text('not a url'), findsOneWidget);
    });
  });
}

List<String> allTextsOf(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .toList();
}
