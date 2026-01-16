// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_permissions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to fetch site permissions for a given origin

@ProviderFor(sitePermissions)
final sitePermissionsProvider = SitePermissionsFamily._();

/// Provider to fetch site permissions for a given origin

final class SitePermissionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SitePermissions?>,
          SitePermissions?,
          FutureOr<SitePermissions?>
        >
    with $FutureModifier<SitePermissions?>, $FutureProvider<SitePermissions?> {
  /// Provider to fetch site permissions for a given origin
  SitePermissionsProvider._({
    required SitePermissionsFamily super.from,
    required (String, bool) super.argument,
  }) : super(
         retry: null,
         name: r'sitePermissionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sitePermissionsHash();

  @override
  String toString() {
    return r'sitePermissionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<SitePermissions?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SitePermissions?> create(Ref ref) {
    final argument = this.argument as (String, bool);
    return sitePermissions(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SitePermissionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sitePermissionsHash() => r'c605e9a1acb261ec46659431b5bb1e105b8aa2a1';

/// Provider to fetch site permissions for a given origin

final class SitePermissionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SitePermissions?>, (String, bool)> {
  SitePermissionsFamily._()
    : super(
        retry: null,
        name: r'sitePermissionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to fetch site permissions for a given origin

  SitePermissionsProvider call(String origin, bool isPrivate) =>
      SitePermissionsProvider._(argument: (origin, isPrivate), from: this);

  @override
  String toString() => r'sitePermissionsProvider';
}

/// Provider to get the public suffix plus one (eTLD+1) for a host

@ProviderFor(publicSuffixPlusOne)
final publicSuffixPlusOneProvider = PublicSuffixPlusOneFamily._();

/// Provider to get the public suffix plus one (eTLD+1) for a host

final class PublicSuffixPlusOneProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Provider to get the public suffix plus one (eTLD+1) for a host
  PublicSuffixPlusOneProvider._({
    required PublicSuffixPlusOneFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publicSuffixPlusOneProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publicSuffixPlusOneHash();

  @override
  String toString() {
    return r'publicSuffixPlusOneProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return publicSuffixPlusOne(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublicSuffixPlusOneProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publicSuffixPlusOneHash() =>
    r'e259f66e3ebf278468223d8e25618eb9f67a3504';

/// Provider to get the public suffix plus one (eTLD+1) for a host

final class PublicSuffixPlusOneFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  PublicSuffixPlusOneFamily._()
    : super(
        retry: null,
        name: r'publicSuffixPlusOneProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get the public suffix plus one (eTLD+1) for a host

  PublicSuffixPlusOneProvider call(String host) =>
      PublicSuffixPlusOneProvider._(argument: host, from: this);

  @override
  String toString() => r'publicSuffixPlusOneProvider';
}

/// Notifier for managing selected clear data types

@ProviderFor(SelectedClearDataTypes)
final selectedClearDataTypesProvider = SelectedClearDataTypesProvider._();

/// Notifier for managing selected clear data types
final class SelectedClearDataTypesProvider
    extends $NotifierProvider<SelectedClearDataTypes, Set<ClearDataType>> {
  /// Notifier for managing selected clear data types
  SelectedClearDataTypesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedClearDataTypesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedClearDataTypesHash();

  @$internal
  @override
  SelectedClearDataTypes create() => SelectedClearDataTypes();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<ClearDataType> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<ClearDataType>>(value),
    );
  }
}

String _$selectedClearDataTypesHash() =>
    r'f010b5dc724bd214add09f7f85c56dd615003915';

/// Notifier for managing selected clear data types

abstract class _$SelectedClearDataTypes extends $Notifier<Set<ClearDataType>> {
  Set<ClearDataType> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<ClearDataType>, Set<ClearDataType>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<ClearDataType>, Set<ClearDataType>>,
              Set<ClearDataType>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
