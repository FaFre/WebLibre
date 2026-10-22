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

/// The sing-box profiles that are running, by profile id.
///
/// What every reader outside the repository asks of the runtime, so none has
/// to remember both halves of "running": a runtime status of running, and a
/// state that holds data ([SingboxProxyRuntimeValueProfiles]).

@ProviderFor(RunningSingboxProfileIds)
final runningSingboxProfileIdsProvider = RunningSingboxProfileIdsProvider._();

/// The sing-box profiles that are running, by profile id.
///
/// What every reader outside the repository asks of the runtime, so none has
/// to remember both halves of "running": a runtime status of running, and a
/// state that holds data ([SingboxProxyRuntimeValueProfiles]).
final class RunningSingboxProfileIdsProvider
    extends $NotifierProvider<RunningSingboxProfileIds, Set<String>> {
  /// The sing-box profiles that are running, by profile id.
  ///
  /// What every reader outside the repository asks of the runtime, so none has
  /// to remember both halves of "running": a runtime status of running, and a
  /// state that holds data ([SingboxProxyRuntimeValueProfiles]).
  RunningSingboxProfileIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runningSingboxProfileIdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runningSingboxProfileIdsHash();

  @$internal
  @override
  RunningSingboxProfileIds create() => RunningSingboxProfileIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$runningSingboxProfileIdsHash() =>
    r'dabc817dc09babdd4a4744a0abc551299e408cdb';

/// The sing-box profiles that are running, by profile id.
///
/// What every reader outside the repository asks of the runtime, so none has
/// to remember both halves of "running": a runtime status of running, and a
/// state that holds data ([SingboxProxyRuntimeValueProfiles]).

abstract class _$RunningSingboxProfileIds extends $Notifier<Set<String>> {
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
    r'1c26dff095c3deb715c3c516defe2b4dab27c0e3';

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

/// Profiles a failed start took down that putting them back did not bring up
/// again, as [SingboxProxyRuntimeRepository] last reported them.
///
/// Nobody asked for them to go down, and the error that reaches the caller is
/// the start's, not theirs — so they are announced here for the retries to
/// pick up, rather than staying down with nothing to say so. A provider of its
/// own because the retries already watch the runtime, and the runtime must not
/// depend on them in turn.

@ProviderFor(SingboxProxyLostProfiles)
final singboxProxyLostProfilesProvider = SingboxProxyLostProfilesProvider._();

/// Profiles a failed start took down that putting them back did not bring up
/// again, as [SingboxProxyRuntimeRepository] last reported them.
///
/// Nobody asked for them to go down, and the error that reaches the caller is
/// the start's, not theirs — so they are announced here for the retries to
/// pick up, rather than staying down with nothing to say so. A provider of its
/// own because the retries already watch the runtime, and the runtime must not
/// depend on them in turn.
final class SingboxProxyLostProfilesProvider
    extends
        $NotifierProvider<
          SingboxProxyLostProfiles,
          ({bool permanent, Set<String> profileIds})?
        > {
  /// Profiles a failed start took down that putting them back did not bring up
  /// again, as [SingboxProxyRuntimeRepository] last reported them.
  ///
  /// Nobody asked for them to go down, and the error that reaches the caller is
  /// the start's, not theirs — so they are announced here for the retries to
  /// pick up, rather than staying down with nothing to say so. A provider of its
  /// own because the retries already watch the runtime, and the runtime must not
  /// depend on them in turn.
  SingboxProxyLostProfilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'singboxProxyLostProfilesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$singboxProxyLostProfilesHash();

  @$internal
  @override
  SingboxProxyLostProfiles create() => SingboxProxyLostProfiles();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    ({bool permanent, Set<String> profileIds})? value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<({bool permanent, Set<String> profileIds})?>(
            value,
          ),
    );
  }
}

String _$singboxProxyLostProfilesHash() =>
    r'7f650ebcfe224469b1498906f62d15059fcf4532';

/// Profiles a failed start took down that putting them back did not bring up
/// again, as [SingboxProxyRuntimeRepository] last reported them.
///
/// Nobody asked for them to go down, and the error that reaches the caller is
/// the start's, not theirs — so they are announced here for the retries to
/// pick up, rather than staying down with nothing to say so. A provider of its
/// own because the retries already watch the runtime, and the runtime must not
/// depend on them in turn.

abstract class _$SingboxProxyLostProfiles
    extends $Notifier<({bool permanent, Set<String> profileIds})?> {
  ({bool permanent, Set<String> profileIds})? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              ({bool permanent, Set<String> profileIds})?,
              ({bool permanent, Set<String> profileIds})?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({bool permanent, Set<String> profileIds})?,
                ({bool permanent, Set<String> profileIds})?
              >,
              ({bool permanent, Set<String> profileIds})?,
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
    r'a25b1b312043ba35ff16fbfe846699d4fc2c9c17';

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
