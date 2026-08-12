// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_settings_replication.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The routing state to install, or null while the inputs that decide it are
/// still loading.
///
/// Waiting is what keeps startup fail-closed. Every routing input defaults to
/// empty while its stream loads, and an empty routing state reads as "every
/// container connects directly" — pushing that would tell the extension to
/// unproxy the very containers it is meant to protect, for as long as it takes
/// the databases to answer. Until then no snapshot exists, the extension holds
/// none, and it blocks rather than guesses.
///
/// Proxy *endpoints* are deliberately not waited on. A relation whose backend
/// is not running yet stays in the snapshot with no matching endpoint, which
/// the extension blocks — so a slow Tor bootstrap costs the containers that use
/// Tor their connectivity, not the whole browser its routing.
///
/// Waiting forever is a different matter: see [containerRoutingInputProviders].

@ProviderFor(containerRoutingSnapshot)
final containerRoutingSnapshotProvider = ContainerRoutingSnapshotProvider._();

/// The routing state to install, or null while the inputs that decide it are
/// still loading.
///
/// Waiting is what keeps startup fail-closed. Every routing input defaults to
/// empty while its stream loads, and an empty routing state reads as "every
/// container connects directly" — pushing that would tell the extension to
/// unproxy the very containers it is meant to protect, for as long as it takes
/// the databases to answer. Until then no snapshot exists, the extension holds
/// none, and it blocks rather than guesses.
///
/// Proxy *endpoints* are deliberately not waited on. A relation whose backend
/// is not running yet stays in the snapshot with no matching endpoint, which
/// the extension blocks — so a slow Tor bootstrap costs the containers that use
/// Tor their connectivity, not the whole browser its routing.
///
/// Waiting forever is a different matter: see [containerRoutingInputProviders].

final class ContainerRoutingSnapshotProvider
    extends
        $FunctionalProvider<
          ContainerRoutingSnapshot?,
          ContainerRoutingSnapshot?,
          ContainerRoutingSnapshot?
        >
    with $Provider<ContainerRoutingSnapshot?> {
  /// The routing state to install, or null while the inputs that decide it are
  /// still loading.
  ///
  /// Waiting is what keeps startup fail-closed. Every routing input defaults to
  /// empty while its stream loads, and an empty routing state reads as "every
  /// container connects directly" — pushing that would tell the extension to
  /// unproxy the very containers it is meant to protect, for as long as it takes
  /// the databases to answer. Until then no snapshot exists, the extension holds
  /// none, and it blocks rather than guesses.
  ///
  /// Proxy *endpoints* are deliberately not waited on. A relation whose backend
  /// is not running yet stays in the snapshot with no matching endpoint, which
  /// the extension blocks — so a slow Tor bootstrap costs the containers that use
  /// Tor their connectivity, not the whole browser its routing.
  ///
  /// Waiting forever is a different matter: see [containerRoutingInputProviders].
  ContainerRoutingSnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerRoutingSnapshotProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerRoutingSnapshotHash();

  @$internal
  @override
  $ProviderElement<ContainerRoutingSnapshot?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContainerRoutingSnapshot? create(Ref ref) {
    return containerRoutingSnapshot(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContainerRoutingSnapshot? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContainerRoutingSnapshot?>(value),
    );
  }
}

String _$containerRoutingSnapshotHash() =>
    r'a31d58527e41d197e835af231f4f349be4c5f904';

/// Single serialised writer that installs [containerRoutingSnapshotProvider]
/// into Gecko's proxy extension.
///
/// Side-effect-only and `keepAlive`, mounted from app startup rather than from
/// a widget: routing must not depend on any part of the UI being built, and
/// must survive it being torn down.

@ProviderFor(ProxySettingsReplication)
final proxySettingsReplicationProvider = ProxySettingsReplicationProvider._();

/// Single serialised writer that installs [containerRoutingSnapshotProvider]
/// into Gecko's proxy extension.
///
/// Side-effect-only and `keepAlive`, mounted from app startup rather than from
/// a widget: routing must not depend on any part of the UI being built, and
/// must survive it being torn down.
final class ProxySettingsReplicationProvider
    extends $NotifierProvider<ProxySettingsReplication, void> {
  /// Single serialised writer that installs [containerRoutingSnapshotProvider]
  /// into Gecko's proxy extension.
  ///
  /// Side-effect-only and `keepAlive`, mounted from app startup rather than from
  /// a widget: routing must not depend on any part of the UI being built, and
  /// must survive it being torn down.
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
    r'73ced267692b551827c912e1ce80a772f9f8f1e4';

/// Single serialised writer that installs [containerRoutingSnapshotProvider]
/// into Gecko's proxy extension.
///
/// Side-effect-only and `keepAlive`, mounted from app startup rather than from
/// a widget: routing must not depend on any part of the UI being built, and
/// must survive it being torn down.

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
