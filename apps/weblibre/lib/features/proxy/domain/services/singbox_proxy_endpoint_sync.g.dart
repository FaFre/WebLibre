// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'singbox_proxy_endpoint_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Mirrors the sing-box runtime's active SOCKS endpoints into Gecko's
/// container-proxy registry. Listens to [singboxProxyRuntimeRepositoryProvider]
/// and diffs the previously registered set against the current endpoints.
///
/// Extracted from the runtime repository so that:
/// - the runtime repo only owns process state (start/stop/validate), and
/// - sync is a single side-effect channel — every transition (start, stop,
///   stream-driven refresh, native crash) flows through the same listener,
///   eliminating the duplicate-sync-call hazard that the inline approach had.
///
/// This is a side-effect-only provider: it must be `keepAlive: true` and is
/// explicitly listened-to from main.dart so the side effect runs without any
/// widget needing to depend on it.

@ProviderFor(SingboxProxyEndpointSync)
final singboxProxyEndpointSyncProvider = SingboxProxyEndpointSyncProvider._();

/// Mirrors the sing-box runtime's active SOCKS endpoints into Gecko's
/// container-proxy registry. Listens to [singboxProxyRuntimeRepositoryProvider]
/// and diffs the previously registered set against the current endpoints.
///
/// Extracted from the runtime repository so that:
/// - the runtime repo only owns process state (start/stop/validate), and
/// - sync is a single side-effect channel — every transition (start, stop,
///   stream-driven refresh, native crash) flows through the same listener,
///   eliminating the duplicate-sync-call hazard that the inline approach had.
///
/// This is a side-effect-only provider: it must be `keepAlive: true` and is
/// explicitly listened-to from main.dart so the side effect runs without any
/// widget needing to depend on it.
final class SingboxProxyEndpointSyncProvider
    extends $NotifierProvider<SingboxProxyEndpointSync, void> {
  /// Mirrors the sing-box runtime's active SOCKS endpoints into Gecko's
  /// container-proxy registry. Listens to [singboxProxyRuntimeRepositoryProvider]
  /// and diffs the previously registered set against the current endpoints.
  ///
  /// Extracted from the runtime repository so that:
  /// - the runtime repo only owns process state (start/stop/validate), and
  /// - sync is a single side-effect channel — every transition (start, stop,
  ///   stream-driven refresh, native crash) flows through the same listener,
  ///   eliminating the duplicate-sync-call hazard that the inline approach had.
  ///
  /// This is a side-effect-only provider: it must be `keepAlive: true` and is
  /// explicitly listened-to from main.dart so the side effect runs without any
  /// widget needing to depend on it.
  SingboxProxyEndpointSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'singboxProxyEndpointSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$singboxProxyEndpointSyncHash();

  @$internal
  @override
  SingboxProxyEndpointSync create() => SingboxProxyEndpointSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$singboxProxyEndpointSyncHash() =>
    r'8aeb4097d02c2f6ea37fdb2de26b399d2e6042c2';

/// Mirrors the sing-box runtime's active SOCKS endpoints into Gecko's
/// container-proxy registry. Listens to [singboxProxyRuntimeRepositoryProvider]
/// and diffs the previously registered set against the current endpoints.
///
/// Extracted from the runtime repository so that:
/// - the runtime repo only owns process state (start/stop/validate), and
/// - sync is a single side-effect channel — every transition (start, stop,
///   stream-driven refresh, native crash) flows through the same listener,
///   eliminating the duplicate-sync-call hazard that the inline approach had.
///
/// This is a side-effect-only provider: it must be `keepAlive: true` and is
/// explicitly listened-to from main.dart so the side effect runs without any
/// widget needing to depend on it.

abstract class _$SingboxProxyEndpointSync extends $Notifier<void> {
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
