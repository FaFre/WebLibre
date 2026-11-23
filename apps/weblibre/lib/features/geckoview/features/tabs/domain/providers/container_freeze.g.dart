// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_freeze.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notices the browser has not shown yet: what the start-time reconciliation
/// found, and what came of actions that have no screen of their own. Kept
/// until taken, because they can come before the browser screen is up.

@ProviderFor(ContainerFreezeNotices)
final containerFreezeNoticesProvider = ContainerFreezeNoticesProvider._();

/// Notices the browser has not shown yet: what the start-time reconciliation
/// found, and what came of actions that have no screen of their own. Kept
/// until taken, because they can come before the browser screen is up.
final class ContainerFreezeNoticesProvider
    extends
        $NotifierProvider<ContainerFreezeNotices, List<ContainerFreezeNotice>> {
  /// Notices the browser has not shown yet: what the start-time reconciliation
  /// found, and what came of actions that have no screen of their own. Kept
  /// until taken, because they can come before the browser screen is up.
  ContainerFreezeNoticesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerFreezeNoticesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerFreezeNoticesHash();

  @$internal
  @override
  ContainerFreezeNotices create() => ContainerFreezeNotices();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ContainerFreezeNotice> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ContainerFreezeNotice>>(value),
    );
  }
}

String _$containerFreezeNoticesHash() =>
    r'47c3e2bbe85c10a4de6e1b18418c665fe9b46a3c';

/// Notices the browser has not shown yet: what the start-time reconciliation
/// found, and what came of actions that have no screen of their own. Kept
/// until taken, because they can come before the browser screen is up.

abstract class _$ContainerFreezeNotices
    extends $Notifier<List<ContainerFreezeNotice>> {
  List<ContainerFreezeNotice> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<List<ContainerFreezeNotice>, List<ContainerFreezeNotice>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                List<ContainerFreezeNotice>,
                List<ContainerFreezeNotice>
              >,
              List<ContainerFreezeNotice>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// How far restoring the frozen containers after a damaged registry got, for
/// the Containers screen ([FreezeRecoveryStatus]).

@ProviderFor(FreezeRecoveryProgress)
final freezeRecoveryProgressProvider = FreezeRecoveryProgressProvider._();

/// How far restoring the frozen containers after a damaged registry got, for
/// the Containers screen ([FreezeRecoveryStatus]).
final class FreezeRecoveryProgressProvider
    extends $NotifierProvider<FreezeRecoveryProgress, FreezeRecoveryStatus> {
  /// How far restoring the frozen containers after a damaged registry got, for
  /// the Containers screen ([FreezeRecoveryStatus]).
  FreezeRecoveryProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'freezeRecoveryProgressProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$freezeRecoveryProgressHash();

  @$internal
  @override
  FreezeRecoveryProgress create() => FreezeRecoveryProgress();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FreezeRecoveryStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FreezeRecoveryStatus>(value),
    );
  }
}

String _$freezeRecoveryProgressHash() =>
    r'12592c28921517599009649acac1fe71bf10614f';

/// How far restoring the frozen containers after a damaged registry got, for
/// the Containers screen ([FreezeRecoveryStatus]).

abstract class _$FreezeRecoveryProgress
    extends $Notifier<FreezeRecoveryStatus> {
  FreezeRecoveryStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FreezeRecoveryStatus, FreezeRecoveryStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FreezeRecoveryStatus, FreezeRecoveryStatus>,
              FreezeRecoveryStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Native's freeze registry as last reported, for what the user sees (5.10).
/// The membership gate reads its own snapshot instead (D27).

@ProviderFor(contextFreezeSnapshot)
final contextFreezeSnapshotProvider = ContextFreezeSnapshotProvider._();

/// Native's freeze registry as last reported, for what the user sees (5.10).
/// The membership gate reads its own snapshot instead (D27).

final class ContextFreezeSnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<LifecycleSnapshot>,
          LifecycleSnapshot,
          Stream<LifecycleSnapshot>
        >
    with
        $FutureModifier<LifecycleSnapshot>,
        $StreamProvider<LifecycleSnapshot> {
  /// Native's freeze registry as last reported, for what the user sees (5.10).
  /// The membership gate reads its own snapshot instead (D27).
  ContextFreezeSnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contextFreezeSnapshotProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contextFreezeSnapshotHash();

  @$internal
  @override
  $StreamProviderElement<LifecycleSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<LifecycleSnapshot> create(Ref ref) {
    return contextFreezeSnapshot(ref);
  }
}

String _$contextFreezeSnapshotHash() =>
    r'0931d98f840b031ecac7d61495c01b057eaa3f06';

/// Every restricted container's freeze, keyed by container id; empty until
/// native answered. A new snapshot that leaves every container's freeze as it
/// was notifies nobody.

@ProviderFor(frozenContainers)
final frozenContainersProvider = FrozenContainersProvider._();

/// Every restricted container's freeze, keyed by container id; empty until
/// native answered. A new snapshot that leaves every container's freeze as it
/// was notifies nobody.

final class FrozenContainersProvider
    extends
        $FunctionalProvider<
          EquatableValue<Map<String, ContainerFreezeView>>,
          EquatableValue<Map<String, ContainerFreezeView>>,
          EquatableValue<Map<String, ContainerFreezeView>>
        >
    with $Provider<EquatableValue<Map<String, ContainerFreezeView>>> {
  /// Every restricted container's freeze, keyed by container id; empty until
  /// native answered. A new snapshot that leaves every container's freeze as it
  /// was notifies nobody.
  FrozenContainersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'frozenContainersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$frozenContainersHash();

  @$internal
  @override
  $ProviderElement<EquatableValue<Map<String, ContainerFreezeView>>>
  $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  EquatableValue<Map<String, ContainerFreezeView>> create(Ref ref) {
    return frozenContainers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    EquatableValue<Map<String, ContainerFreezeView>> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<Map<String, ContainerFreezeView>>>(
            value,
          ),
    );
  }
}

String _$frozenContainersHash() => r'6b0c4a10be888633da4db53fa43ee69501f3ca96';

/// Whether native is in recovery mode: every container is frozen until the
/// containers are reconstructed (D23).

@ProviderFor(freezeRecoveryMode)
final freezeRecoveryModeProvider = FreezeRecoveryModeProvider._();

/// Whether native is in recovery mode: every container is frozen until the
/// containers are reconstructed (D23).

final class FreezeRecoveryModeProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether native is in recovery mode: every container is frozen until the
  /// containers are reconstructed (D23).
  FreezeRecoveryModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'freezeRecoveryModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$freezeRecoveryModeHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return freezeRecoveryMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$freezeRecoveryModeHash() =>
    r'462191ebd32e094b4e424fea27e4d2a76f485c9b';

/// [containerId]'s freeze, or null while it is not restricted.

@ProviderFor(containerFreezeState)
final containerFreezeStateProvider = ContainerFreezeStateFamily._();

/// [containerId]'s freeze, or null while it is not restricted.

final class ContainerFreezeStateProvider
    extends
        $FunctionalProvider<
          ContainerFreezeView?,
          ContainerFreezeView?,
          ContainerFreezeView?
        >
    with $Provider<ContainerFreezeView?> {
  /// [containerId]'s freeze, or null while it is not restricted.
  ContainerFreezeStateProvider._({
    required ContainerFreezeStateFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'containerFreezeStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$containerFreezeStateHash();

  @override
  String toString() {
    return r'containerFreezeStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ContainerFreezeView?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContainerFreezeView? create(Ref ref) {
    final argument = this.argument as String?;
    return containerFreezeState(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContainerFreezeView? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContainerFreezeView?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerFreezeStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$containerFreezeStateHash() =>
    r'4632973e44d6ebc4ad521335636976a5a2f45501';

/// [containerId]'s freeze, or null while it is not restricted.

final class ContainerFreezeStateFamily extends $Family
    with $FunctionalFamilyOverride<ContainerFreezeView?, String?> {
  ContainerFreezeStateFamily._()
    : super(
        retry: null,
        name: r'containerFreezeStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [containerId]'s freeze, or null while it is not restricted.

  ContainerFreezeStateProvider call(String? containerId) =>
      ContainerFreezeStateProvider._(argument: containerId, from: this);

  @override
  String toString() => r'containerFreezeStateProvider';
}

/// The last teardown progress native reported for a freeze of [containerId];
/// read it only while the container's operation is a freeze.

@ProviderFor(containerFreezeProgress)
final containerFreezeProgressProvider = ContainerFreezeProgressFamily._();

/// The last teardown progress native reported for a freeze of [containerId];
/// read it only while the container's operation is a freeze.

final class ContainerFreezeProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<FreezeProgress>,
          FreezeProgress,
          Stream<FreezeProgress>
        >
    with $FutureModifier<FreezeProgress>, $StreamProvider<FreezeProgress> {
  /// The last teardown progress native reported for a freeze of [containerId];
  /// read it only while the container's operation is a freeze.
  ContainerFreezeProgressProvider._({
    required ContainerFreezeProgressFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'containerFreezeProgressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$containerFreezeProgressHash();

  @override
  String toString() {
    return r'containerFreezeProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<FreezeProgress> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<FreezeProgress> create(Ref ref) {
    final argument = this.argument as String;
    return containerFreezeProgress(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerFreezeProgressProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$containerFreezeProgressHash() =>
    r'ebc93c53e644dbf017fd936dcc3f2f101fe858de';

/// The last teardown progress native reported for a freeze of [containerId];
/// read it only while the container's operation is a freeze.

final class ContainerFreezeProgressFamily extends $Family
    with $FunctionalFamilyOverride<Stream<FreezeProgress>, String> {
  ContainerFreezeProgressFamily._()
    : super(
        retry: null,
        name: r'containerFreezeProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The last teardown progress native reported for a freeze of [containerId];
  /// read it only while the container's operation is a freeze.

  ContainerFreezeProgressProvider call(String containerId) =>
      ContainerFreezeProgressProvider._(argument: containerId, from: this);

  @override
  String toString() => r'containerFreezeProgressProvider';
}

/// Everything listed under "Site data waiting to be deleted", from native's
/// registry: `releasing` contexts grouped by their container, deleted or
/// not, and each `orphaned` context on its own.

@ProviderFor(pendingSiteData)
final pendingSiteDataProvider = PendingSiteDataProvider._();

/// Everything listed under "Site data waiting to be deleted", from native's
/// registry: `releasing` contexts grouped by their container, deleted or
/// not, and each `orphaned` context on its own.

final class PendingSiteDataProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<PendingSiteData>>,
          EquatableValue<List<PendingSiteData>>,
          EquatableValue<List<PendingSiteData>>
        >
    with $Provider<EquatableValue<List<PendingSiteData>>> {
  /// Everything listed under "Site data waiting to be deleted", from native's
  /// registry: `releasing` contexts grouped by their container, deleted or
  /// not, and each `orphaned` context on its own.
  PendingSiteDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingSiteDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingSiteDataHash();

  @$internal
  @override
  $ProviderElement<EquatableValue<List<PendingSiteData>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<PendingSiteData>> create(Ref ref) {
    return pendingSiteData(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<PendingSiteData>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<List<PendingSiteData>>>(value),
    );
  }
}

String _$pendingSiteDataHash() => r'0e3c2c607e8eb2a7957e4b72c82b94d78cfd49a6';
