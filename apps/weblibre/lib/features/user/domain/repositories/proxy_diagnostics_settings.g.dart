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
    r'3f3be2f10e75fefc0517b34a6d9a28bab823a434';

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

@ProviderFor(proxyDiagnosticsSettingsWithDefaults)
final proxyDiagnosticsSettingsWithDefaultsProvider =
    ProxyDiagnosticsSettingsWithDefaultsProvider._();

final class ProxyDiagnosticsSettingsWithDefaultsProvider
    extends
        $FunctionalProvider<
          ProxyDiagnosticsSettings,
          ProxyDiagnosticsSettings,
          ProxyDiagnosticsSettings
        >
    with $Provider<ProxyDiagnosticsSettings> {
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
    r'96eac54783d6206557bbbdea35ed27d530dcf258';
