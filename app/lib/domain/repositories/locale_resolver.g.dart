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
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(resolveLocale)
final resolveLocaleProvider = ResolveLocaleFamily._();

final class ResolveLocaleProvider
    extends
        $FunctionalProvider<
          AsyncValue<LocalizedResult>,
          LocalizedResult,
          FutureOr<LocalizedResult>
        >
    with $FutureModifier<LocalizedResult>, $FutureProvider<LocalizedResult> {
  ResolveLocaleProvider._({
    required ResolveLocaleFamily super.from,
    required intl.Locale super.argument,
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
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<LocalizedResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LocalizedResult> create(Ref ref) {
    final argument = this.argument as intl.Locale;
    return resolveLocale(ref, argument);
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

String _$resolveLocaleHash() => r'94d7a9b307a81de372b8b40b06f046acc76e01c8';

final class ResolveLocaleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<LocalizedResult>, intl.Locale> {
  ResolveLocaleFamily._()
    : super(
        retry: null,
        name: r'resolveLocaleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ResolveLocaleProvider call(intl.Locale locale) =>
      ResolveLocaleProvider._(argument: locale, from: this);

  @override
  String toString() => r'resolveLocaleProvider';
}
