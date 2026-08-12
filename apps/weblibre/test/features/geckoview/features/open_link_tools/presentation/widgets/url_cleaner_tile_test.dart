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
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/entities/url_cleaner_result.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_rule.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_service.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/widgets/url_cleaner_tile.dart';

void main() {
  Future<void> pumpTile(
    WidgetTester tester, {
    required UrlCleanerResult result,
    required String currentUrl,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UrlCleanerTile(
            result: result,
            currentUrl: currentUrl,
            allowReferralMarketing: false,
            onClean: () {},
            onApplySelectedRemovals: (_) {},
          ),
        ),
      ),
    );
  }

  group('plain URL', () {
    final rules = <UrlCleanerRule>[
      UrlCleanerRule(
        name: 'test',
        data: UrlCleanerRuleData(
          urlPattern: r'^https?://example\.com',
          rules: ['utm_source', 'utm_medium'],
        ),
      ),
    ];
    const source = 'https://example.com/a?utm_source=x&utm_medium=y';
    final result = cleanUrl(source, rules);

    testWidgets('warns on the untouched URL and offers the quick clean', (
      tester,
    ) async {
      await pumpTile(tester, result: result, currentUrl: source);

      expect(find.text('Tracking detected'), findsOneWidget);
      expect(find.text('2 tracking parameters found'), findsOneWidget);
      expect(find.byTooltip('Clean URL'), findsOneWidget);
    });

    testWidgets('confirms the cleaned URL and drops the quick clean', (
      tester,
    ) async {
      await pumpTile(tester, result: result, currentUrl: result.cleanedUrl);

      expect(find.text('URL cleaned'), findsOneWidget);
      expect(find.text('2 tracking parameters removed'), findsOneWidget);
      expect(find.byTooltip('Clean URL'), findsNothing);
    });

    testWidgets('reports a partial clean', (tester) async {
      await pumpTile(
        tester,
        result: result,
        currentUrl: 'https://example.com/a?utm_medium=y',
      );

      expect(find.text('URL partially cleaned'), findsOneWidget);
      expect(find.text('1 of 2 tracking parameters removed'), findsOneWidget);
      expect(find.byTooltip('Clean URL'), findsOneWidget);
    });
  });

  group('redirect wrapper', () {
    final rules = <UrlCleanerRule>[
      UrlCleanerRule(
        name: 'redirect',
        data: UrlCleanerRuleData(
          urlPattern: r'^https?://redir\.com',
          redirections: ['url=([^&]+)'],
        ),
      ),
      UrlCleanerRule(
        name: 'dest',
        data: UrlCleanerRuleData(
          urlPattern: r'^https?://dest\.com',
          rules: ['utm_source'],
        ),
      ),
    ];
    const wrapper =
        'https://redir.com?url=https%3A%2F%2Fdest.com%3Futm_source%3Dx';
    final result = cleanUrl(wrapper, rules);

    testWidgets('still warns while the wrapper is what copy/share would use', (
      tester,
    ) async {
      // The parameters were matched after unwrapping, so none of them appear
      // literally in the wrapper. That absence must not read as "cleaned".
      await pumpTile(tester, result: result, currentUrl: wrapper);

      expect(find.text('Tracking detected'), findsOneWidget);
      expect(find.text('1 tracking parameter found'), findsOneWidget);
      expect(find.byTooltip('Clean URL'), findsOneWidget);
    });

    testWidgets('confirms once the unwrapped URL is applied', (tester) async {
      await pumpTile(tester, result: result, currentUrl: result.cleanedUrl);

      expect(find.text('URL cleaned'), findsOneWidget);
      expect(find.byTooltip('Clean URL'), findsNothing);
    });
  });
}
