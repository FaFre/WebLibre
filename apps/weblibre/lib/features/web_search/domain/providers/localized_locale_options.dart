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
import 'package:intl/locale.dart' as intl;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/repositories/locale_resolver.dart';
import 'package:weblibre/features/web_search/data/locale_options.dart';

part 'localized_locale_options.g.dart';

/// [supportedLanguages] named in [displayLocale] and sorted by that name.
///
/// Names come from the platform's CLDR data, so they need no translation pass.
/// An option the platform cannot name keeps its English fallback.
@riverpod
Future<List<LanguageOption>> localizedLanguageOptions(
  Ref ref,
  intl.Locale displayLocale,
) async {
  final resolver = ref.read(
    localeResolverRepositoryProvider(displayLocale).notifier,
  );

  final options = await Future.wait([
    for (final option in supportedLanguages)
      _resolveName(
        () async => (await resolver.resolve(
          intl.Locale.fromSubtags(languageCode: option.code),
        )).languageName,
        fallback: option.name,
      ).then((name) => LanguageOption(option.code, name)),
  ]);

  return options..sort((a, b) => a.name.compareTo(b.name));
}

/// [supportedCountries] named in [displayLocale] and sorted by that name.
@riverpod
Future<List<CountryOption>> localizedCountryOptions(
  Ref ref,
  intl.Locale displayLocale,
) async {
  final resolver = ref.read(
    localeResolverRepositoryProvider(displayLocale).notifier,
  );

  final options = await Future.wait([
    for (final option in supportedCountries)
      _resolveName(
        // `und` is BCP 47's "undetermined language": only the region matters.
        () async => (await resolver.resolve(
          intl.Locale.fromSubtags(
            languageCode: 'und',
            countryCode: option.code,
          ),
        )).countryName,
        fallback: option.name,
      ).then((name) => CountryOption(option.code, name)),
  ]);

  return options..sort((a, b) => a.name.compareTo(b.name));
}

Future<String> _resolveName(
  Future<String?> Function() resolve, {
  required String fallback,
}) async {
  try {
    final name = await resolve();
    return (name == null || name.isEmpty) ? fallback : name;
  } catch (error, stackTrace) {
    logger.w(
      'Could not resolve a locale display name',
      error: error,
      stackTrace: stackTrace,
    );
    return fallback;
  }
}
