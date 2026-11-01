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
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tor/flutter_tor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod/misc.dart' show Override;
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/features/about/domain/providers.dart';
import 'package:weblibre/features/about/presentation/screens/about.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// The component versions in the About dialog.
///
/// Each native source is read on its own, so one that fails or has nothing to
/// say only blanks its own rows.
void main() {
  final geckoVersions = GeckoComponentVersions(
    gecko: '159.0-20261020123456',
    androidComponents: '159.0',
    applicationServices: '149.0',
  );

  Future<void> pumpAbout(
    WidgetTester tester, {
    AsyncValue<TorComponentVersions>? tor,
    Override? torOverride,
    required AsyncValue<String?> singbox,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packageInfoProvider.overrideWithValue(
            AsyncValue.data(
              PackageInfo(
                appName: 'WebLibre',
                packageName: 'eu.weblibre.gecko',
                version: '0.40.0',
                buildNumber: '1',
              ),
            ),
          ),
          geckoComponentVersionsProvider.overrideWithValue(
            AsyncValue.data(geckoVersions),
          ),
          torOverride ?? torComponentVersionsProvider.overrideWithValue(tor!),
          singboxVersionProvider.overrideWithValue(singbox),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AboutDialogScreen()),
        ),
      ),
    );
    await tester.pump();
  }

  /// The version shown in the row named [name].
  String versionOf(WidgetTester tester, String name) {
    final row = find.ancestor(of: find.text(name), matching: find.byType(Wrap));
    final texts = tester.widgetList<Text>(
      find.descendant(of: row, matching: find.byType(Text)),
    );
    expect(texts.first.data, name);
    return texts.last.data!;
  }

  final allVersions = AsyncValue.data(
    TorComponentVersions(
      tor: '0.4.9.14',
      snowflake: '2.13.1',
      lyrebird: '0.8.1',
    ),
  );

  testWidgets('lists every component next to its version', (tester) async {
    await pumpAbout(
      tester,
      tor: allVersions,
      singbox: const AsyncValue.data('1.14.4'),
    );

    expect(find.text('Component Versions'), findsOneWidget);
    expect(versionOf(tester, 'Gecko'), '159.0-20261020123456');
    expect(versionOf(tester, 'Android Components'), '159.0');
    expect(versionOf(tester, 'Application Services'), '149.0');
    expect(versionOf(tester, torBrand), '0.4.9.14');
    expect(versionOf(tester, 'Snowflake'), '2.13.1');
    expect(versionOf(tester, 'Lyrebird'), '0.8.1');
    expect(versionOf(tester, 'sing-box'), '1.14.4');
  });

  testWidgets('a version nobody knows reads N/A, the others stay', (
    tester,
  ) async {
    await pumpAbout(
      tester,
      tor: AsyncValue.data(TorComponentVersions(tor: '0.4.9.14')),
      // A runtime built without the version stamp.
      singbox: const AsyncValue.data(null),
    );

    expect(versionOf(tester, torBrand), '0.4.9.14');
    expect(versionOf(tester, 'Snowflake'), 'N/A');
    expect(versionOf(tester, 'Lyrebird'), 'N/A');
    expect(versionOf(tester, 'sing-box'), 'N/A');
    expect(versionOf(tester, 'Gecko'), '159.0-20261020123456');
  });

  testWidgets('a failed source reads N/A, a loading one stays blank', (
    tester,
  ) async {
    await pumpAbout(
      tester,
      // A real throw, not an injected AsyncError: a provider that retries
      // reports a failure as loading-with-error until it gives up.
      torOverride: torComponentVersionsProvider.overrideWith(
        (ref) => throw PlatformException(code: 'channel-error'),
      ),
      singbox: const AsyncValue.loading(),
    );

    expect(versionOf(tester, torBrand), 'N/A');
    expect(versionOf(tester, 'Snowflake'), 'N/A');
    expect(versionOf(tester, 'Lyrebird'), 'N/A');
    expect(versionOf(tester, 'sing-box'), '');
    expect(versionOf(tester, 'Gecko'), '159.0-20261020123456');
  });

  testWidgets('versions are never squeezed on a narrow phone with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640) * 3;
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpAbout(
      tester,
      tor: allVersions,
      singbox: const AsyncValue.data('1.14.4'),
    );

    final rowWidth = tester.getSize(find.byType(Wrap).first).width;
    for (final version in [
      '159.0-20261020123456',
      '159.0',
      '149.0',
      '0.4.9.14',
      '2.13.1',
      '0.8.1',
      '1.14.4',
    ]) {
      // All of its natural width, or the whole row when even that is too
      // little: never a sliver beside a name that took the rest.
      final paragraph = tester.renderObject<RenderParagraph>(
        find.text(version),
      );
      expect(
        paragraph.size.width,
        moreOrLessEquals(
          math.min(paragraph.getMaxIntrinsicWidth(double.infinity), rowWidth),
          epsilon: 0.5,
        ),
        reason: '$version is squeezed by its name',
      );
    }
  });
}
