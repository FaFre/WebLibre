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
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_rule.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_service.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/dialogs/tracking_details_dialog.dart';

void main() {
  const sourceUrl =
      'https://example.com/article?utm_term=echoboxauto&utm_campaign=summer';

  final rules = <UrlCleanerRule>[
    UrlCleanerRule(
      name: 'globalRules',
      data: UrlCleanerRuleData(
        urlPattern: '^https?://',
        rules: ['utm_term', 'utm_campaign'],
      ),
    ),
  ];

  final result = cleanUrl(sourceUrl, rules);

  Future<String?> pumpDialog(
    WidgetTester tester, {
    required String currentUrl,
    bool allowReferralMarketing = false,
  }) async {
    String? applied;

    await tester.pumpWidget(
      MaterialApp(
        home: TrackingDetailsDialog(
          currentUrl: currentUrl,
          result: result,
          allowReferralMarketing: allowReferralMarketing,
          onApplySelectedRemovals: (url) => applied = url,
        ),
      ),
    );

    return applied;
  }

  Future<void> toggle(WidgetTester tester, String paramName) async {
    await tester.tap(
      find.ancestor(
        of: find.text(paramName),
        matching: find.byType(CheckboxListTile),
      ),
    );
    await tester.pump();
  }

  testWidgets('preselects every parameter on an untouched URL', (tester) async {
    await pumpDialog(tester, currentUrl: sourceUrl);

    expect(find.text('2 of 2 selected for removal'), findsOneWidget);
    expect(find.text(result.cleanedUrl), findsOneWidget);
  });

  testWidgets('deselecting restores a parameter auto-apply already stripped', (
    tester,
  ) async {
    // Auto-apply rewrote the caller's URL before the dialog ever opened.
    await pumpDialog(tester, currentUrl: result.cleanedUrl);

    // The already-cleaned URL means everything reads as removed.
    expect(find.text('2 of 2 selected for removal'), findsOneWidget);

    await toggle(tester, 'utm_campaign');

    expect(find.text('1 of 2 selected for removal'), findsOneWidget);
    expect(
      find.text('https://example.com/article?utm_campaign=summer'),
      findsOneWidget,
    );
  });

  testWidgets('applies the rebuilt URL rather than the cleaned one', (
    tester,
  ) async {
    String? applied;
    await tester.pumpWidget(
      MaterialApp(
        home: TrackingDetailsDialog(
          currentUrl: result.cleanedUrl,
          result: result,
          allowReferralMarketing: false,
          onApplySelectedRemovals: (url) => applied = url,
        ),
      ),
    );

    await toggle(tester, 'utm_term');
    await tester.tap(find.text('Apply Changes'));
    await tester.pump();

    expect(applied, 'https://example.com/article?utm_term=echoboxauto');
  });

  testWidgets('mirrors a partially cleaned URL when reopened', (tester) async {
    // The user previously kept utm_campaign; reopening must reflect that
    // instead of resetting to "remove everything".
    await pumpDialog(
      tester,
      currentUrl: 'https://example.com/article?utm_campaign=summer',
    );

    expect(find.text('1 of 2 selected for removal'), findsOneWidget);

    await toggle(tester, 'utm_term');

    expect(find.text('0 of 2 selected for removal'), findsOneWidget);
    expect(find.text(sourceUrl), findsOneWidget);
  });

  testWidgets('leaves referral parameters unselected on an untouched URL', (
    tester,
  ) async {
    final referralRules = <UrlCleanerRule>[
      UrlCleanerRule(
        name: 'globalRules',
        data: UrlCleanerRuleData(
          urlPattern: '^https?://',
          rules: ['utm_term'],
          referralMarketing: ['tag'],
        ),
      ),
    ];
    const referralUrl = 'https://example.com/a?utm_term=x&tag=partner';
    final referralResult = cleanUrl(
      referralUrl,
      referralRules,
      allowReferral: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TrackingDetailsDialog(
          currentUrl: referralUrl,
          result: referralResult,
          allowReferralMarketing: true,
          onApplySelectedRemovals: (_) {},
        ),
      ),
    );

    expect(find.text('1 of 2 selected for removal'), findsOneWidget);
    expect(find.text('https://example.com/a?tag=partner'), findsOneWidget);
  });
}
