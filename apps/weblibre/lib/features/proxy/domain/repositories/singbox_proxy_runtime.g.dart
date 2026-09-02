// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'singbox_proxy_runtime.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(singboxProxyClient)
final singboxProxyClientProvider = SingboxProxyClientProvider._();

final class SingboxProxyClientProvider
    extends
        $FunctionalProvider<
          SingboxProxyClient,
          SingboxProxyClient,
          SingboxProxyClient
        >
    with $Provider<SingboxProxyClient> {
  SingboxProxyClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'singboxProxyClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$singboxProxyClientHash();

  @$internal
  @override
  $ProviderElement<SingboxProxyClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SingboxProxyClient create(Ref ref) {
    return singboxProxyClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SingboxProxyClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SingboxProxyClient>(value),
    );
  }
}

String _$singboxProxyClientHash() =>
    r'3e56b277667e92a2d4941fd084dddd0ff25afd52';

/// The proxy connections a sing-box start is in flight for, encoded.
///
/// The runtime's own status is one flag for the whole runtime — it does not
/// report which profiles a start covers until they are running — so reading it
/// as "sing-box is starting" holds every endpoint-less sing-box relation behind
/// whichever profile happens to be coming up. The ids are known at exactly one
/// place, the start call, so that is where they are recorded.
///
/// Published separately from [SingboxProxyRuntimeRepository]'s own state
/// because it answers a different question — "is something bringing this
/// connection up?" rather than "what is running?" — and because the routing
/// snapshot has to recompute when it changes.

@ProviderFor(SingboxProxyStartingConnections)
final singboxProxyStartingConnectionsProvider =
    SingboxProxyStartingConnectionsProvider._();

/// The proxy connections a sing-box start is in flight for, encoded.
///
/// The runtime's own status is one flag for the whole runtime — it does not
/// report which profiles a start covers until they are running — so reading it
/// as "sing-box is starting" holds every endpoint-less sing-box relation behind
/// whichever profile happens to be coming up. The ids are known at exactly one
/// place, the start call, so that is where they are recorded.
///
/// Published separately from [SingboxProxyRuntimeRepository]'s own state
/// because it answers a different question — "is something bringing this
/// connection up?" rather than "what is running?" — and because the routing
/// snapshot has to recompute when it changes.
final class SingboxProxyStartingConnectionsProvider
    extends $NotifierProvider<SingboxProxyStartingConnections, Set<String>> {
  /// The proxy connections a sing-box start is in flight for, encoded.
  ///
  /// The runtime's own status is one flag for the whole runtime — it does not
  /// report which profiles a start covers until they are running — so reading it
  /// as "sing-box is starting" holds every endpoint-less sing-box relation behind
  /// whichever profile happens to be coming up. The ids are known at exactly one
  /// place, the start call, so that is where they are recorded.
  ///
  /// Published separately from [SingboxProxyRuntimeRepository]'s own state
  /// because it answers a different question — "is something bringing this
  /// connection up?" rather than "what is running?" — and because the routing
  /// snapshot has to recompute when it changes.
  SingboxProxyStartingConnectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'singboxProxyStartingConnectionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$singboxProxyStartingConnectionsHash();

  @$internal
  @override
  SingboxProxyStartingConnections create() => SingboxProxyStartingConnections();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$singboxProxyStartingConnectionsHash() =>
    r'3c466aac786a51f155a959fdaec5a5bb9134af3e';

/// The proxy connections a sing-box start is in flight for, encoded.
///
/// The runtime's own status is one flag for the whole runtime — it does not
/// report which profiles a start covers until they are running — so reading it
/// as "sing-box is starting" holds every endpoint-less sing-box relation behind
/// whichever profile happens to be coming up. The ids are known at exactly one
/// place, the start call, so that is where they are recorded.
///
/// Published separately from [SingboxProxyRuntimeRepository]'s own state
/// because it answers a different question — "is something bringing this
/// connection up?" rather than "what is running?" — and because the routing
/// snapshot has to recompute when it changes.

abstract class _$SingboxProxyStartingConnections
    extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SingboxProxyRuntimeRepository)
final singboxProxyRuntimeRepositoryProvider =
    SingboxProxyRuntimeRepositoryProvider._();

final class SingboxProxyRuntimeRepositoryProvider
    extends
        $AsyncNotifierProvider<
          SingboxProxyRuntimeRepository,
          SingboxProxyRuntimeState
        > {
  SingboxProxyRuntimeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'singboxProxyRuntimeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$singboxProxyRuntimeRepositoryHash();

  @$internal
  @override
  SingboxProxyRuntimeRepository create() => SingboxProxyRuntimeRepository();
}

String _$singboxProxyRuntimeRepositoryHash() =>
    r'e759761d8334eb90d4160fda427cec04662a9530';

abstract class _$SingboxProxyRuntimeRepository
    extends $AsyncNotifier<SingboxProxyRuntimeState> {
  FutureOr<SingboxProxyRuntimeState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<SingboxProxyRuntimeState>,
              SingboxProxyRuntimeState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SingboxProxyRuntimeState>,
                SingboxProxyRuntimeState
              >,
              AsyncValue<SingboxProxyRuntimeState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
