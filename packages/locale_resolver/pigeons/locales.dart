import 'package:pigeon/pigeon.dart';

class LocalizedResult {
  final String languageName;
  final String? countryName;

  LocalizedResult(this.languageName, this.countryName);
}

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/locales.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/eu/weblibre/locale_resolver/pigeons/Locales.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'eu.weblibre.locale_resolver.pigeons',
    ),
    dartPackageName: 'locale_resolver',
  ),
)
@HostApi()
abstract class LocaleResolver {
  LocalizedResult resolve(String languageTag, String targetLangouageTag);
}
