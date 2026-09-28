import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/locale.dart' as intl;
import 'package:weblibre/features/search_credits/data/models/web_search_settings.dart';
import 'package:weblibre/features/search_credits/domain/repositories/web_search_settings.dart';
import 'package:weblibre/features/web_search/data/locale_options.dart';
import 'package:weblibre/features/web_search/domain/providers/localized_locale_options.dart';
import 'package:weblibre/features/web_search/presentation/widgets/search_filter_chips.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// The "device default" choices describe the device's locale; the names in
/// the menu are written in the app's UI language. The two are set apart here
/// (device de-AT, app English) so neither can stand in for the other.
void main() {
  final displayLocales = <intl.Locale>[];

  Future<void> pumpSelector(WidgetTester tester, Widget selector) async {
    tester.platformDispatcher
      ..localeTestValue = const Locale('de', 'AT')
      ..localesTestValue = const [Locale('de', 'AT')];
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          webSearchSettingsControllerProvider.overrideWithValue(
            WebSearchSettings.withDefaults(),
          ),
          localizedLanguageOptionsProvider.overrideWith((ref, displayLocale) {
            displayLocales.add(displayLocale);
            return const [
              LanguageOption('de', 'German (localized)'),
              LanguageOption('en', 'English (localized)'),
            ];
          }),
          localizedCountryOptionsProvider.overrideWith((ref, displayLocale) {
            displayLocales.add(displayLocale);
            return const [
              CountryOption('AT', 'Austria (localized)'),
              CountryOption('US', 'United States (localized)'),
            ];
          }),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: Center(child: selector)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(displayLocales.clear);

  // Menu rows with a code subtitle render as RichText.
  Finder menuRow(String text) => find.textContaining(text, findRichText: true);

  testWidgets('country default comes from the device, not the app locale', (
    tester,
  ) async {
    await pumpSelector(tester, const CountrySelector());

    await tester.tap(find.byIcon(Icons.public_rounded));
    await tester.pumpAndSettle();

    expect(menuRow('Austria (localized) (device)'), findsOneWidget);
    expect(menuRow('United States (localized)'), findsOneWidget);
    expect(displayLocales, everyElement(intl.Locale.parse('en')));
  });

  testWidgets('language default comes from the device, not the app locale', (
    tester,
  ) async {
    await pumpSelector(tester, const LanguageSelector());

    await tester.tap(find.byIcon(Icons.translate_rounded));
    await tester.pumpAndSettle();

    // The device language is the default row's subtitle, and is not repeated
    // among the other choices.
    expect(menuRow('Auto (device default)  de'), findsOneWidget);
    expect(menuRow('German (localized)'), findsNothing);
    expect(menuRow('English (localized)'), findsOneWidget);
    expect(displayLocales, everyElement(intl.Locale.parse('en')));
  });
}
