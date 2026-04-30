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

    group('showHttpScheme is false', () {
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

      testWidgets('hides scheme for http URLs', (tester) async {
        await tester.pumpWidget(
          buildSubject(
            uri: Uri.parse('http://example.com'),
            showHttpScheme: false,
          ),
        );

        final all = allTexts(tester);
        expect(all, isNot(contains('http')));
        final bold = boldTexts(tester);
        expect(bold, ['example.com']);
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
  });
}
