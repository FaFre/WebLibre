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
import 'package:flutter/widgets.dart' hide Locale;
import 'package:intl/locale.dart' as intl;
import 'package:locale_resolver/locale_resolver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/extensions/locale.dart';

part 'locale_resolver.g.dart';

@Riverpod(keepAlive: true)
class LocaleResolverRepository extends _$LocaleResolverRepository {
  final _service = LocaleResolver();
  final _cache = <intl.Locale, LocalizedResult>{};

  Future<LocalizedResult> resolve(intl.Locale locale) async {
    final cached = _cache[locale];
    if (cached != null) {
      return cached;
    }

    return _cache[locale] = await _service.resolve(
      locale.toLanguageTag(),
      targetLocale.toLanguageTag(),
    );
  }

  @override
  void build(intl.Locale targetLocale) {}
}

@Riverpod()
Future<LocalizedResult> resolveLocale(Ref ref, intl.Locale locale) {
  return ref
      .read(
        localeResolverRepositoryProvider(
          WidgetsBinding.instance.platformDispatcher.locale.toIntlLocale(),
        ).notifier,
      )
      .resolve(locale);
}
