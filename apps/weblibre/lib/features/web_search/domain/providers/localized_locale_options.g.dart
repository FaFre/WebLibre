// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localized_locale_options.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [supportedLanguages] named in [displayLocale] and sorted by that name.
///
/// Names come from the platform's CLDR data, so they need no translation pass.
/// An option the platform cannot name keeps its English fallback.

@ProviderFor(localizedLanguageOptions)
final localizedLanguageOptionsProvider = LocalizedLanguageOptionsFamily._();

/// [supportedLanguages] named in [displayLocale] and sorted by that name.
///
/// Names come from the platform's CLDR data, so they need no translation pass.
/// An option the platform cannot name keeps its English fallback.

final class LocalizedLanguageOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LanguageOption>>,
          List<LanguageOption>,
          FutureOr<List<LanguageOption>>
        >
    with
        $FutureModifier<List<LanguageOption>>,
        $FutureProvider<List<LanguageOption>> {
  /// [supportedLanguages] named in [displayLocale] and sorted by that name.
  ///
  /// Names come from the platform's CLDR data, so they need no translation pass.
  /// An option the platform cannot name keeps its English fallback.
  LocalizedLanguageOptionsProvider._({
    required LocalizedLanguageOptionsFamily super.from,
    required intl.Locale super.argument,
  }) : super(
         retry: null,
         name: r'localizedLanguageOptionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$localizedLanguageOptionsHash();

  @override
  String toString() {
    return r'localizedLanguageOptionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<LanguageOption>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LanguageOption>> create(Ref ref) {
    final argument = this.argument as intl.Locale;
    return localizedLanguageOptions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalizedLanguageOptionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localizedLanguageOptionsHash() =>
    r'2a88750ded97a64d9110f0f338b0e5a53ce887e8';

/// [supportedLanguages] named in [displayLocale] and sorted by that name.
///
/// Names come from the platform's CLDR data, so they need no translation pass.
/// An option the platform cannot name keeps its English fallback.

final class LocalizedLanguageOptionsFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<LanguageOption>>, intl.Locale> {
  LocalizedLanguageOptionsFamily._()
    : super(
        retry: null,
        name: r'localizedLanguageOptionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [supportedLanguages] named in [displayLocale] and sorted by that name.
  ///
  /// Names come from the platform's CLDR data, so they need no translation pass.
  /// An option the platform cannot name keeps its English fallback.

  LocalizedLanguageOptionsProvider call(intl.Locale displayLocale) =>
      LocalizedLanguageOptionsProvider._(argument: displayLocale, from: this);

  @override
  String toString() => r'localizedLanguageOptionsProvider';
}

/// [supportedCountries] named in [displayLocale] and sorted by that name.

@ProviderFor(localizedCountryOptions)
final localizedCountryOptionsProvider = LocalizedCountryOptionsFamily._();

/// [supportedCountries] named in [displayLocale] and sorted by that name.

final class LocalizedCountryOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CountryOption>>,
          List<CountryOption>,
          FutureOr<List<CountryOption>>
        >
    with
        $FutureModifier<List<CountryOption>>,
        $FutureProvider<List<CountryOption>> {
  /// [supportedCountries] named in [displayLocale] and sorted by that name.
  LocalizedCountryOptionsProvider._({
    required LocalizedCountryOptionsFamily super.from,
    required intl.Locale super.argument,
  }) : super(
         retry: null,
         name: r'localizedCountryOptionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$localizedCountryOptionsHash();

  @override
  String toString() {
    return r'localizedCountryOptionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CountryOption>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CountryOption>> create(Ref ref) {
    final argument = this.argument as intl.Locale;
    return localizedCountryOptions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalizedCountryOptionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localizedCountryOptionsHash() =>
    r'52cb78ce8a2f7b4610e95c2047e49921540be672';

/// [supportedCountries] named in [displayLocale] and sorted by that name.

final class LocalizedCountryOptionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CountryOption>>, intl.Locale> {
  LocalizedCountryOptionsFamily._()
    : super(
        retry: null,
        name: r'localizedCountryOptionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [supportedCountries] named in [displayLocale] and sorted by that name.

  LocalizedCountryOptionsProvider call(intl.Locale displayLocale) =>
      LocalizedCountryOptionsProvider._(argument: displayLocale, from: this);

  @override
  String toString() => r'localizedCountryOptionsProvider';
}
