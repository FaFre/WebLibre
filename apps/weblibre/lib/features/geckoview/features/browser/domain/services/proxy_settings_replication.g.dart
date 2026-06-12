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
    r'cdb624b7f7806a7ce4218da350253ed3d29986d0';

abstract class _$ProxySettingsReplication extends $Notifier<void> {
  void build();
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
    return element.handleCreate(ref, build);
  }
}
