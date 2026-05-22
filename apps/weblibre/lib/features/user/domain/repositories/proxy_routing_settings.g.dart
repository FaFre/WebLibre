// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_routing_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProxyRoutingSettingsRepository)
final proxyRoutingSettingsRepositoryProvider =
    ProxyRoutingSettingsRepositoryProvider._();

final class ProxyRoutingSettingsRepositoryProvider
    extends
        $StreamNotifierProvider<
          ProxyRoutingSettingsRepository,
          ProxyRoutingSettings
        > {
  ProxyRoutingSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyRoutingSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyRoutingSettingsRepositoryHash();

  @$internal
  @override
  ProxyRoutingSettingsRepository create() => ProxyRoutingSettingsRepository();
}

String _$proxyRoutingSettingsRepositoryHash() =>
    r'10c46172bad7426bb639cf3bc769ba150bdb30c3';

abstract class _$ProxyRoutingSettingsRepository
    extends $StreamNotifier<ProxyRoutingSettings> {
  Stream<ProxyRoutingSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<ProxyRoutingSettings>, ProxyRoutingSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ProxyRoutingSettings>,
                ProxyRoutingSettings
              >,
              AsyncValue<ProxyRoutingSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(proxyRoutingSettingsWithDefaults)
final proxyRoutingSettingsWithDefaultsProvider =
    ProxyRoutingSettingsWithDefaultsProvider._();

final class ProxyRoutingSettingsWithDefaultsProvider
    extends
        $FunctionalProvider<
          ProxyRoutingSettings,
          ProxyRoutingSettings,
          ProxyRoutingSettings
        >
    with $Provider<ProxyRoutingSettings> {
  ProxyRoutingSettingsWithDefaultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyRoutingSettingsWithDefaultsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyRoutingSettingsWithDefaultsHash();

  @$internal
  @override
  $ProviderElement<ProxyRoutingSettings> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProxyRoutingSettings create(Ref ref) {
    return proxyRoutingSettingsWithDefaults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProxyRoutingSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProxyRoutingSettings>(value),
    );
  }
}

String _$proxyRoutingSettingsWithDefaultsHash() =>
    r'899f545188633843d5224bf86d4611d80543cf5c';
