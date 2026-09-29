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

import 'package:flutter/widgets.dart' show basicLocaleListResolution;
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

part 'app_localizations.g.dart';

/// [AppLocalizations] for code that holds a [Ref] but no [BuildContext]:
/// notifiers and providers that put user-facing text into their state (error
/// messages, fallback titles).
///
/// Resolves exactly like the app's `MaterialApp` does — the in-app language
/// override from [effectiveAppLocaleProvider] first, the system locale list
/// otherwise — so this text always matches the UI it is shown in.
///
/// Kept alive because the long-lived repositories and controllers that read
/// it are. It rebuilds on its own when the in-app override changes; a system
/// language change reaches it through `MainApp`, which invalidates it from a
/// binding observer. The provider does not observe the binding itself so that
/// plain `test()` unit tests, which never initialize one, can still read it.
@Riverpod(keepAlive: true)
AppLocalizations appLocalizations(Ref ref) {
  final override = ref.watch(effectiveAppLocaleProvider);
  return lookupAppLocalizations(override ?? systemAppLocale);
}

/// [AppLocalizations] for code with neither a [BuildContext] nor a [Ref] —
/// today only startup code that runs before any settings are loaded (the name
/// given to a recovered profile). An error produced without either should
/// carry structured data and be translated where it is shown instead, like
/// `handleHttpError`'s `HttpFailure`.
///
/// Prefer [appLocalizationsProvider] whenever a [Ref] is at hand. This one
/// cannot see the in-app language override and always follows the system
/// locale, so its text can disagree with the rest of the UI once a user picks
/// a language that differs from their system one.
AppLocalizations get contextFreeAppLocalizations =>
    lookupAppLocalizations(systemAppLocale);

/// `localeListResolutionCallback` for every `MaterialApp` in the app.
///
/// Resolves exactly like Flutter's default, and also makes the result
/// [Intl.defaultLocale]: `DateFormat` and `NumberFormat` without an explicit
/// locale then format for the language the UI is shown in, instead of
/// `en_US`. Flutter calls this with the explicit `locale:` when one is set, so
/// the in-app language override is covered too.
Locale resolveAppLocale(
  List<Locale>? preferredLocales,
  Iterable<Locale> supportedLocales,
) {
  final locale = basicLocaleListResolution(
    preferredLocales?.map(_withCurrentLanguageCode).toList(),
    supportedLocales,
  );
  Intl.defaultLocale = locale.toString();
  return locale;
}

/// The supported locale the system locale list resolves to, the same way
/// `MaterialApp` resolves an unset `locale:`.
///
/// Reads [PlatformDispatcher.instance] (`dart:ui`), not
/// `WidgetsBinding.instance.platformDispatcher`: the latter needs a framework
/// binding, which plain `test()` unit tests for domain/controller code never
/// initialize.
Locale get systemAppLocale => basicLocaleListResolution(
  PlatformDispatcher.instance.locales.map(_withCurrentLanguageCode).toList(),
  AppLocalizations.supportedLocales,
);

/// Android reports some languages under their withdrawn ISO 639 codes
/// (`java.util.Locale.getLanguage()` keeps them, and Flutter passes that on),
/// so an Indonesian device arrives as `in` and would never match the shipped
/// `id` translation.
const _legacyLanguageCodes = {'in': 'id', 'iw': 'he', 'ji': 'yi'};

Locale _withCurrentLanguageCode(Locale locale) {
  final current = _legacyLanguageCodes[locale.languageCode];
  if (current == null) return locale;
  return Locale.fromSubtags(
    languageCode: current,
    scriptCode: locale.scriptCode,
    countryCode: locale.countryCode,
  );
}
