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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/clear_site_data_section.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

const _pslChannel =
    'dev.flutter.pigeon.flutter_mozilla_components.GeckoPublicSuffixListApi.getPublicSuffixPlusOne';

final _url = Uri.parse('https://www.example.co.uk/page');

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  // The section's default selection, in the dialog's checkbox order.
  final defaultTypes =
      '• ${l10n.browser_dataTypeAuthSessions}\n'
      '• ${l10n.browser_dataTypeSiteData}';

  void mockPublicSuffixLookup(Future<String?> Function() reply) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(_pslChannel, (message) async {
          final result = await reply();
          // Pigeon replies with a list: [result] on success, null when the
          // host side is missing (which the caller turns into an error).
          return result == null
              ? null
              : const StandardMessageCodec().encodeMessage([result]);
        });
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(_pslChannel, null);
  });

  Future<void> pumpSection(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ListView(children: [ClearSiteDataSection(url: _url)]),
          ),
        ),
      ),
    );
    await tester.tap(find.text(l10n.browser_clearSiteDataTitle));
    await tester.pumpAndSettle();
  }

  Finder clearNowButton() => find.ancestor(
    of: find.text(l10n.browser_clearNow),
    matching: find.byWidgetPredicate((widget) => widget is FilledButton),
  );

  Future<void> tapClearNow(WidgetTester tester) async {
    await tester.ensureVisible(clearNowButton());
    await tester.tap(clearNowButton());
    await tester.pumpAndSettle();
  }

  testWidgets('confirmation names the registrable domain the clear runs on', (
    tester,
  ) async {
    mockPublicSuffixLookup(() async => 'example.co.uk');
    await pumpSection(tester);

    await tapClearNow(tester);

    expect(
      find.text(
        l10n.browser_clearSiteDataContent(defaultTypes, 'example.co.uk'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('falls back to the tab host when the lookup fails', (
    tester,
  ) async {
    mockPublicSuffixLookup(() async => null);
    await pumpSection(tester);

    await tapClearNow(tester);

    expect(
      find.text(
        l10n.browser_clearSiteDataContent(defaultTypes, 'www.example.co.uk'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('cannot confirm before the domain is known', (tester) async {
    final lookup = Completer<String?>();
    mockPublicSuffixLookup(() => lookup.future);
    await pumpSection(tester);

    await tester.ensureVisible(clearNowButton());
    expect(
      tester.widget<ButtonStyleButton>(clearNowButton()).onPressed,
      isNull,
    );

    lookup.complete('example.co.uk');
    await tester.pumpAndSettle();

    expect(
      tester.widget<ButtonStyleButton>(clearNowButton()).onPressed,
      isNotNull,
    );
  });
}
