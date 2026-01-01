// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_settings_replication.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProxySettingsReplication)
final proxySettingsReplicationProvider = ProxySettingsReplicationProvider._();

final class ProxySettingsReplicationProvider
    extends $NotifierProvider<ProxySettingsReplication, void> {
  ProxySettingsReplicationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxySettingsReplicationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxySettingsReplicationHash();

  @$internal
  @override
  ProxySettingsReplication create() => ProxySettingsReplication();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$proxySettingsReplicationHash() =>
    r'9ded7af1d745e25c59e22edecea582e25230e5e7';

abstract class _$ProxySettingsReplication extends $Notifier<void> {
  void build();
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
    element.handleCreate(ref, build);
  }
}
