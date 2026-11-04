// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_diagnostics_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProxyDiagnosticsSettingsRepository)
final proxyDiagnosticsSettingsRepositoryProvider =
    ProxyDiagnosticsSettingsRepositoryProvider._();

final class ProxyDiagnosticsSettingsRepositoryProvider
    extends
        $StreamNotifierProvider<
          ProxyDiagnosticsSettingsRepository,
          ProxyDiagnosticsSettings
        > {
  ProxyDiagnosticsSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyDiagnosticsSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$proxyDiagnosticsSettingsRepositoryHash();

  @$internal
  @override
  ProxyDiagnosticsSettingsRepository create() =>
      ProxyDiagnosticsSettingsRepository();
}

String _$proxyDiagnosticsSettingsRepositoryHash() =>
    r'addc35665da12f86c0c6f3a266252242f5646a45';

abstract class _$ProxyDiagnosticsSettingsRepository
    extends $StreamNotifier<ProxyDiagnosticsSettings> {
  Stream<ProxyDiagnosticsSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ProxyDiagnosticsSettings>,
              ProxyDiagnosticsSettings
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ProxyDiagnosticsSettings>,
                ProxyDiagnosticsSettings
              >,
              AsyncValue<ProxyDiagnosticsSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The diagnostics settings as stored, for the screens that edit them.

@ProviderFor(storedProxyDiagnosticsSettings)
final storedProxyDiagnosticsSettingsProvider =
    StoredProxyDiagnosticsSettingsProvider._();

/// The diagnostics settings as stored, for the screens that edit them.

final class StoredProxyDiagnosticsSettingsProvider
    extends
        $FunctionalProvider<
          ProxyDiagnosticsSettings,
          ProxyDiagnosticsSettings,
          ProxyDiagnosticsSettings
        >
    with $Provider<ProxyDiagnosticsSettings> {
  /// The diagnostics settings as stored, for the screens that edit them.
  StoredProxyDiagnosticsSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storedProxyDiagnosticsSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storedProxyDiagnosticsSettingsHash();

  @$internal
  @override
  $ProviderElement<ProxyDiagnosticsSettings> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProxyDiagnosticsSettings create(Ref ref) {
    return storedProxyDiagnosticsSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProxyDiagnosticsSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProxyDiagnosticsSettings>(value),
    );
  }
}

String _$storedProxyDiagnosticsSettingsHash() =>
    r'c0f60486472c46d3a62c632051e8e196cc9ac160';

/// The diagnostics settings as they apply
/// ([ProxyDiagnosticsSettings.effective]).

@ProviderFor(proxyDiagnosticsSettingsWithDefaults)
final proxyDiagnosticsSettingsWithDefaultsProvider =
    ProxyDiagnosticsSettingsWithDefaultsProvider._();

/// The diagnostics settings as they apply
/// ([ProxyDiagnosticsSettings.effective]).

final class ProxyDiagnosticsSettingsWithDefaultsProvider
    extends
        $FunctionalProvider<
          ProxyDiagnosticsSettings,
          ProxyDiagnosticsSettings,
          ProxyDiagnosticsSettings
        >
    with $Provider<ProxyDiagnosticsSettings> {
  /// The diagnostics settings as they apply
  /// ([ProxyDiagnosticsSettings.effective]).
  ProxyDiagnosticsSettingsWithDefaultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyDiagnosticsSettingsWithDefaultsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$proxyDiagnosticsSettingsWithDefaultsHash();

  @$internal
  @override
  $ProviderElement<ProxyDiagnosticsSettings> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProxyDiagnosticsSettings create(Ref ref) {
    return proxyDiagnosticsSettingsWithDefaults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProxyDiagnosticsSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProxyDiagnosticsSettings>(value),
    );
  }
}

String _$proxyDiagnosticsSettingsWithDefaultsHash() =>
    r'4a30aa315c24d8a612dc77a64d37035328c6fccd';

/// The log level in force once the diagnostics and general settings have
/// loaded, null before.

@ProviderFor(loadedProxyLogLevel)
final loadedProxyLogLevelProvider = LoadedProxyLogLevelProvider._();

/// The log level in force once the diagnostics and general settings have
/// loaded, null before.

final class LoadedProxyLogLevelProvider
    extends $FunctionalProvider<ProxyLogLevel?, ProxyLogLevel?, ProxyLogLevel?>
    with $Provider<ProxyLogLevel?> {
  /// The log level in force once the diagnostics and general settings have
  /// loaded, null before.
  LoadedProxyLogLevelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadedProxyLogLevelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadedProxyLogLevelHash();

  @$internal
  @override
  $ProviderElement<ProxyLogLevel?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProxyLogLevel? create(Ref ref) {
    return loadedProxyLogLevel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProxyLogLevel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProxyLogLevel?>(value),
    );
  }
}

String _$loadedProxyLogLevelHash() =>
    r'fb326ebde2dd0e90339201a6ad39ff75ded1e91a';
