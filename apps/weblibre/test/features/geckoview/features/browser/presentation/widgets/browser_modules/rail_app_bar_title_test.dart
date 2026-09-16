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
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/providers/site_settings_badge_provider.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/app_bar_title.dart';

const _faviconKey = ValueKey('favicon');

Future<void> pumpTitle(
  WidgetTester tester, {
  VoidCallback? onSiteSettingsTap,
  VoidCallback? onTitleTap,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 64,
            height: 400,
            child: RailAppBarTitleView(
              tabState: TabState.$default(
                'tab',
              ).copyWith(url: Uri.parse('https://www.openstreetmap.org')),
              quarterTurns: 3,
              isTabTunneled: false,
              siteSettingsBadgeState: SiteSettingsBadgeState.hidden,
              onSiteSettingsTap: onSiteSettingsTap ?? () {},
              onTitleTap: onTitleTap ?? () {},
              tabIcon: const SizedBox.square(key: _faviconKey, dimension: 24),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('the favicon sits inside the address pill, at its top', (
    tester,
  ) async {
    await pumpTitle(tester);

    final pill = tester.getRect(find.byType(AnimatedContainer));
    final favicon = tester.getRect(find.byKey(_faviconKey));

    // The pill fills the slot it is given; the favicon no longer takes a strip
    // of its own above it.
    expect(pill.top, tester.getRect(find.byType(RailAppBarTitleView)).top);
    expect(pill.left, lessThanOrEqualTo(favicon.left));
    expect(pill.right, greaterThanOrEqualTo(favicon.right));
    expect(favicon.top - pill.top, lessThanOrEqualTo(16));
    expect(favicon.center.dx, moreOrLessEquals(pill.center.dx));
  });

  testWidgets('tapping the favicon opens site settings only', (tester) async {
    var siteSettings = 0;
    var title = 0;
    await pumpTitle(
      tester,
      onSiteSettingsTap: () => siteSettings++,
      onTitleTap: () => title++,
    );

    await tester.tap(find.byKey(_faviconKey));
    await tester.pumpAndSettle();

    expect(siteSettings, 1);
    expect(title, 0);
  });

  testWidgets('tapping the rest of the pill opens the address bar', (
    tester,
  ) async {
    var siteSettings = 0;
    var title = 0;
    await pumpTitle(
      tester,
      onSiteSettingsTap: () => siteSettings++,
      onTitleTap: () => title++,
    );

    final pill = tester.getRect(find.byType(AnimatedContainer));
    // Well below the favicon slot, and away from the painted text.
    await tester.tapAt(Offset(pill.center.dx, pill.bottom - 24));
    await tester.pumpAndSettle();

    expect(title, 1);
    expect(siteSettings, 0);
  });
}
