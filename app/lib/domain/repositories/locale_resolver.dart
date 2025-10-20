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
