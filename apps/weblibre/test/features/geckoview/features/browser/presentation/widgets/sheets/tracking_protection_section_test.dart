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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/blocked_trackers.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers/blocked_trackers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/tracking_protection_provider.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/tracking_protection_section.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

const _tabId = 'tab';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<List<bool>> pumpSection(
    WidgetTester tester, {
    required bool hasException,
    required PageTrackers trackers,
  }) async {
    final expansions = <bool>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hasTrackingProtectionExceptionProvider(
            _tabId,
          ).overrideWith((ref) => Future.value(hasException)),
          pageTrackersProvider(
            _tabId,
          ).overrideWith((ref) => Future.value(trackers)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ListView(
              children: [
                TrackingProtectionSection(
                  tabId: _tabId,
                  onExpandedChanged: expansions.add,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return expansions;
  }

  testWidgets('opens into categories, and each category into its hosts', (
    tester,
  ) async {
    final expansions = await pumpSection(
      tester,
      hasException: false,
      trackers: PageTrackers({
        BlockedTrackerCategory.crossSiteCookies: ['a.example', 'b.example'],
        BlockedTrackerCategory.fingerprinters: ['fp.example'],
      }),
    );

    expect(find.text(l10n.browser_trackersBlockedCount(3)), findsOneWidget);
    expect(find.text(l10n.browser_trackerCategoryFingerprinters), findsNothing);

    await tester.tap(find.text(l10n.browser_trackersBlockedCount(3)));
    await tester.pumpAndSettle();

    expect(expansions, [true]);
    expect(
      find.text(l10n.browser_trackerCategoryCrossSiteCookies),
      findsOneWidget,
    );
    expect(find.text(l10n.browser_trackerCount(2)), findsOneWidget);
    expect(find.text(l10n.browser_trackerCount(1)), findsOneWidget);
    expect(find.text('a.example'), findsNothing);

    await tester.tap(find.text(l10n.browser_trackerCategoryCrossSiteCookies));
    await tester.pumpAndSettle();

    expect(find.text('a.example'), findsOneWidget);
    expect(find.text('b.example'), findsOneWidget);
    expect(find.text('fp.example'), findsNothing);
  });

  testWidgets('says so when nothing was blocked yet', (tester) async {
    await pumpSection(
      tester,
      hasException: false,
      trackers: PageTrackers(const {}),
    );

    expect(find.text(l10n.browser_noTrackersBlocked), findsOneWidget);
  });

  testWidgets('shows no tracker row while protection is off for the site', (
    tester,
  ) async {
    await pumpSection(
      tester,
      hasException: true,
      trackers: PageTrackers({
        BlockedTrackerCategory.trackingContent: ['ads.example'],
      }),
    );

    expect(find.text(l10n.browser_trackersAllowed), findsOneWidget);
    expect(find.text(l10n.browser_trackersBlockedCount(1)), findsNothing);
    expect(find.text(l10n.browser_noTrackersBlocked), findsNothing);
  });
}
