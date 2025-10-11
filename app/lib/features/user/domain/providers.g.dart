// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(_storedAuthData)
const _storedAuthDataProvider = _StoredAuthDataProvider._();

final class _StoredAuthDataProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  const _StoredAuthDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_storedAuthDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_storedAuthDataHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return _storedAuthData(ref);
  }
}

String _$_storedAuthDataHash() => r'5f7e3ef6233a2036f7ce3728131901a46b1e548e';

@ProviderFor(iconCacheSizeMegabytes)
const iconCacheSizeMegabytesProvider = IconCacheSizeMegabytesProvider._();

final class IconCacheSizeMegabytesProvider
    extends $FunctionalProvider<AsyncValue<double>, double, Stream<double>>
    with $FutureModifier<double>, $StreamProvider<double> {
  const IconCacheSizeMegabytesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'iconCacheSizeMegabytesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$iconCacheSizeMegabytesHash();

  @$internal
  @override
  $StreamProviderElement<double> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<double> create(Ref ref) {
    return iconCacheSizeMegabytes(ref);
  }
}

String _$iconCacheSizeMegabytesHash() =>
    r'5d7f5f6485060b08ce4fd8fa634f07bf8bfdbd2d';

@ProviderFor(incognitoModeEnabled)
const incognitoModeEnabledProvider = IncognitoModeEnabledProvider._();

final class IncognitoModeEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  const IncognitoModeEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incognitoModeEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incognitoModeEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return incognitoModeEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$incognitoModeEnabledHash() =>
    r'36957b70a5261f9d3ad228e07cc8dd5c8f616082';

@ProviderFor(fingerprintOverrideSettings)
const fingerprintOverrideSettingsProvider =
    FingerprintOverrideSettingsProvider._();

final class FingerprintOverrideSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<FingerprintOverrides>>,
          Result<FingerprintOverrides>,
          FutureOr<Result<FingerprintOverrides>>
        >
    with
        $FutureModifier<Result<FingerprintOverrides>>,
        $FutureProvider<Result<FingerprintOverrides>> {
  const FingerprintOverrideSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fingerprintOverrideSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fingerprintOverrideSettingsHash();

  @$internal
  @override
  $FutureProviderElement<Result<FingerprintOverrides>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<FingerprintOverrides>> create(Ref ref) {
    return fingerprintOverrideSettings(ref);
  }
}

String _$fingerprintOverrideSettingsHash() =>
    r'd4d40ec425098fb1f5a2f0c4944f058829a41a0a';
