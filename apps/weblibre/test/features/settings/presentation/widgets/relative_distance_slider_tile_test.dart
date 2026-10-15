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
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:weblibre/core/providers/app_localizations.dart';
import 'package:weblibre/features/settings/presentation/widgets/relative_distance_slider_tile.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

void main() {
  Future<List<double>> pumpTile(
    WidgetTester tester, {
    required double value,
    bool enabled = true,
    Locale locale = const Locale('en'),
  }) async {
    final saved = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        // As every MaterialApp in the app: it sets Intl.defaultLocale, which
        // the multiple's number is formatted with.
        localeListResolutionCallback: resolveAppLocale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: RelativeDistanceSliderTile(
            title: 'Distance',
            subtitle: 'How far',
            icon: Icons.straighten,
            value: value,
            defaultValue: defaultAutoHideTabBarDistance,
            enabled: enabled,
            onChanged: (value) async => saved.add(value),
          ),
        ),
      ),
    );
    return saved;
  }

  testWidgets('the default reads as 100%', (tester) async {
    await pumpTile(tester, value: defaultAutoHideTabBarDistance);

    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('a distance shows as its share of the default', (tester) async {
    await pumpTile(tester, value: defaultAutoHideTabBarDistance * 1.5);

    expect(find.text('150%'), findsOneWidget);
  });

  testWidgets('a distance off the steps shows its nearest step', (
    tester,
  ) async {
    await pumpTile(tester, value: defaultAutoHideTabBarDistance * 1.6);

    expect(find.text('150%'), findsOneWidget);
  });

  testWidgets('the percentage is written the way the UI language writes it', (
    tester,
  ) async {
    addTearDown(() => Intl.defaultLocale = null);
    await pumpTile(
      tester,
      value: defaultAutoHideTabBarDistance * 1.5,
      locale: const Locale('de'),
    );

    expect(find.text('150\u00a0%'), findsOneWidget);
  });

  testWidgets('a screen reader hears the same percentage the screen shows', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpTile(tester, value: defaultAutoHideTabBarDistance);

    final semantics = find.semantics
        .byFlag(SemanticsFlag.isSlider)
        .evaluate()
        .single;
    // Not the slider's position in its track, which a screen reader would
    // otherwise announce as a percentage of its own.
    expect(semantics.value, '100%');
    expect(semantics.increasedValue, '125%');
    expect(semantics.decreasedValue, '75%');

    handle.dispose();
  });

  testWidgets('dragging saves once, at the end, within the range', (
    tester,
  ) async {
    final saved = await pumpTile(tester, value: defaultAutoHideTabBarDistance);

    await tester.drag(find.byType(Slider), const Offset(2000, 0));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Slider), const Offset(-2000, 0));
    await tester.pumpAndSettle();

    expect(saved, [
      defaultAutoHideTabBarDistance * 3,
      defaultAutoHideTabBarDistance / 4,
    ]);
  });

  testWidgets('a disabled tile cannot be moved', (tester) async {
    final saved = await pumpTile(
      tester,
      value: defaultAutoHideTabBarDistance,
      enabled: false,
    );

    await tester.drag(find.byType(Slider), const Offset(2000, 0));
    await tester.pumpAndSettle();

    expect(saved, isEmpty);
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
  });

  group('range', () {
    test('runs from 25% to 300% in 25% steps', () {
      expect(gestureDistanceMinFactor, 0.25);
      expect(gestureDistanceMaxFactor, 3.0);
      expect(gestureDistanceFactorStep, 0.25);
    });

    test('has the default on a step', () {
      const steps = (1 - gestureDistanceMinFactor) / gestureDistanceFactorStep;
      expect(steps, steps.roundToDouble());
    });

    test('bounds every setting', () {
      expect(minAutoHideTabBarDistance, defaultAutoHideTabBarDistance * 0.25);
      expect(maxAutoHideTabBarDistance, defaultAutoHideTabBarDistance * 3);
      expect(
        minPullToRefreshTriggerDistance,
        defaultPullToRefreshTriggerDistance * 0.25,
      );
      expect(
        maxPullToRefreshTriggerDistance,
        defaultPullToRefreshTriggerDistance * 3,
      );
    });
  });

  group('defaults', () {
    test('the tab bar hides half again later than it used to', () {
      final settings = GeneralSettings.withDefaults();

      // It used to hide after one and a half toolbar heights and show again
      // after one.
      expect(settings.autoHideTabBarDistance, kToolbarHeight * 1.5 * 1.5);
      expect(
        settings.autoHideTabBarDistance * autoHideTabBarShowFraction,
        closeTo(kToolbarHeight * 1.5, 1e-9),
      );
    });

    test(
      "pull to refresh needs half again SwipeRefreshLayout's own distance",
      () {
        expect(
          GeneralSettings.withDefaults().pullToRefreshTriggerDistance,
          64.0 * 1.5,
        );
      },
    );
  });
}
