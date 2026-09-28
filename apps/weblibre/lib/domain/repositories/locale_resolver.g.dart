// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocaleResolverRepository)
final localeResolverRepositoryProvider = LocaleResolverRepositoryFamily._();

final class LocaleResolverRepositoryProvider
    extends $NotifierProvider<LocaleResolverRepository, void> {
  LocaleResolverRepositoryProvider._({
    required LocaleResolverRepositoryFamily super.from,
    required intl.Locale super.argument,
  }) : super(
         retry: null,
         name: r'localeResolverRepositoryProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$localeResolverRepositoryHash();

  @override
  String toString() {
    return r'localeResolverRepositoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LocaleResolverRepository create() => LocaleResolverRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LocaleResolverRepositoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localeResolverRepositoryHash() =>
    r'dc74908d6ac1f5cc851e2a10dcf33b0dc68b5b15';

final class LocaleResolverRepositoryFamily extends $Family
    with
        $ClassFamilyOverride<
          LocaleResolverRepository,
          void,
          void,
          void,
          intl.Locale
        > {
  LocaleResolverRepositoryFamily._()
    : super(
        retry: null,
        name: r'localeResolverRepositoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  LocaleResolverRepositoryProvider call(intl.Locale targetLocale) =>
      LocaleResolverRepositoryProvider._(argument: targetLocale, from: this);

  @override
  String toString() => r'localeResolverRepositoryProvider';
}

abstract class _$LocaleResolverRepository extends $Notifier<void> {
  late final _$args = ref.$arg as intl.Locale;
  intl.Locale get targetLocale => _$args;

  void build(intl.Locale targetLocale);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The language and country names of [locale], written in [displayLocale].
///
/// Pass the UI locale (`Localizations.localeOf(context)`) for names shown in
/// running text, so they follow the in-app language rather than the device's,
/// or [locale] itself where each entry should name itself (a language picker).

@ProviderFor(resolveLocale)
final resolveLocaleProvider = ResolveLocaleFamily._();

/// The language and country names of [locale], written in [displayLocale].
///
/// Pass the UI locale (`Localizations.localeOf(context)`) for names shown in
/// running text, so they follow the in-app language rather than the device's,
/// or [locale] itself where each entry should name itself (a language picker).

final class ResolveLocaleProvider
    extends
        $FunctionalProvider<
          AsyncValue<LocalizedResult>,
          LocalizedResult,
          FutureOr<LocalizedResult>
        >
    with $FutureModifier<LocalizedResult>, $FutureProvider<LocalizedResult> {
  /// The language and country names of [locale], written in [displayLocale].
  ///
  /// Pass the UI locale (`Localizations.localeOf(context)`) for names shown in
  /// running text, so they follow the in-app language rather than the device's,
  /// or [locale] itself where each entry should name itself (a language picker).
  ResolveLocaleProvider._({
    required ResolveLocaleFamily super.from,
    required (intl.Locale, intl.Locale) super.argument,
  }) : super(
         retry: null,
         name: r'resolveLocaleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$resolveLocaleHash();

  @override
  String toString() {
    return r'resolveLocaleProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<LocalizedResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LocalizedResult> create(Ref ref) {
    final argument = this.argument as (intl.Locale, intl.Locale);
    return resolveLocale(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ResolveLocaleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$resolveLocaleHash() => r'536cfb90fae191dfacffb41f2461d8ffedca4585';

/// The language and country names of [locale], written in [displayLocale].
///
/// Pass the UI locale (`Localizations.localeOf(context)`) for names shown in
/// running text, so they follow the in-app language rather than the device's,
/// or [locale] itself where each entry should name itself (a language picker).

final class ResolveLocaleFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<LocalizedResult>,
          (intl.Locale, intl.Locale)
        > {
  ResolveLocaleFamily._()
    : super(
        retry: null,
        name: r'resolveLocaleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The language and country names of [locale], written in [displayLocale].
  ///
  /// Pass the UI locale (`Localizations.localeOf(context)`) for names shown in
  /// running text, so they follow the in-app language rather than the device's,
  /// or [locale] itself where each entry should name itself (a language picker).

  ResolveLocaleProvider call(intl.Locale locale, intl.Locale displayLocale) =>
      ResolveLocaleProvider._(argument: (locale, displayLocale), from: this);

  @override
  String toString() => r'resolveLocaleProvider';
}
