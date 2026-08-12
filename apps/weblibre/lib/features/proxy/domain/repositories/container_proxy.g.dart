// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_proxy.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pushes the app's routing state into Gecko's proxy extension.
///
/// Snapshots are the only way state reaches the extension, and each carries a
/// generation the extension echoes back. Nothing is recorded as applied until
/// that acknowledgement arrives, so a push that fails leaves the repository
/// out-of-sync on purpose and the next recompute retries it. While out of sync
/// the extension blocks rather than connecting directly, so the failure mode is
/// lost connectivity, never unproxied traffic.

@ProviderFor(ContainerProxyRepository)
final containerProxyRepositoryProvider = ContainerProxyRepositoryProvider._();

/// Pushes the app's routing state into Gecko's proxy extension.
///
/// Snapshots are the only way state reaches the extension, and each carries a
/// generation the extension echoes back. Nothing is recorded as applied until
/// that acknowledgement arrives, so a push that fails leaves the repository
/// out-of-sync on purpose and the next recompute retries it. While out of sync
/// the extension blocks rather than connecting directly, so the failure mode is
/// lost connectivity, never unproxied traffic.
final class ContainerProxyRepositoryProvider
    extends $NotifierProvider<ContainerProxyRepository, void> {
  /// Pushes the app's routing state into Gecko's proxy extension.
  ///
  /// Snapshots are the only way state reaches the extension, and each carries a
  /// generation the extension echoes back. Nothing is recorded as applied until
  /// that acknowledgement arrives, so a push that fails leaves the repository
  /// out-of-sync on purpose and the next recompute retries it. While out of sync
  /// the extension blocks rather than connecting directly, so the failure mode is
  /// lost connectivity, never unproxied traffic.
  ContainerProxyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerProxyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerProxyRepositoryHash();

  @$internal
  @override
  ContainerProxyRepository create() => ContainerProxyRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$containerProxyRepositoryHash() =>
    r'4a3768388ca29c473f9ad40712e940955967299f';

/// Pushes the app's routing state into Gecko's proxy extension.
///
/// Snapshots are the only way state reaches the extension, and each carries a
/// generation the extension echoes back. Nothing is recorded as applied until
/// that acknowledgement arrives, so a push that fails leaves the repository
/// out-of-sync on purpose and the next recompute retries it. While out of sync
/// the extension blocks rather than connecting directly, so the failure mode is
/// lost connectivity, never unproxied traffic.

abstract class _$ContainerProxyRepository extends $Notifier<void> {
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
