// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncIsAuthenticated)
final syncIsAuthenticatedProvider = SyncIsAuthenticatedProvider._();

final class SyncIsAuthenticatedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  SyncIsAuthenticatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncIsAuthenticatedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncIsAuthenticatedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return syncIsAuthenticated(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$syncIsAuthenticatedHash() =>
    r'40e108a5c1d4d885fd31edde04146bf4131dd51c';

@ProviderFor(TabsTrayScopeController)
final tabsTrayScopeControllerProvider = TabsTrayScopeControllerProvider._();

final class TabsTrayScopeControllerProvider
    extends $NotifierProvider<TabsTrayScopeController, TabsTrayScope> {
  TabsTrayScopeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabsTrayScopeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabsTrayScopeControllerHash();

  @$internal
  @override
  TabsTrayScopeController create() => TabsTrayScopeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TabsTrayScope value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TabsTrayScope>(value),
    );
  }
}

String _$tabsTrayScopeControllerHash() =>
    r'e9415c1f57e1a78804ec4eee122c9db9ee416066';

abstract class _$TabsTrayScopeController extends $Notifier<TabsTrayScope> {
  TabsTrayScope build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TabsTrayScope, TabsTrayScope>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TabsTrayScope, TabsTrayScope>,
              TabsTrayScope,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(effectiveTabsTrayScope)
final effectiveTabsTrayScopeProvider = EffectiveTabsTrayScopeProvider._();

final class EffectiveTabsTrayScopeProvider
    extends $FunctionalProvider<TabsTrayScope, TabsTrayScope, TabsTrayScope>
    with $Provider<TabsTrayScope> {
  EffectiveTabsTrayScopeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveTabsTrayScopeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveTabsTrayScopeHash();

  @$internal
  @override
  $ProviderElement<TabsTrayScope> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TabsTrayScope create(Ref ref) {
    return effectiveTabsTrayScope(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TabsTrayScope value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TabsTrayScope>(value),
    );
  }
}

String _$effectiveTabsTrayScopeHash() =>
    r'ac295d7413a7014882835d3533bf31cd3c031a1d';

@ProviderFor(SelectedSyncedTabsDeviceId)
final selectedSyncedTabsDeviceIdProvider =
    SelectedSyncedTabsDeviceIdProvider._();

final class SelectedSyncedTabsDeviceIdProvider
    extends $NotifierProvider<SelectedSyncedTabsDeviceId, String?> {
  SelectedSyncedTabsDeviceIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedSyncedTabsDeviceIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedSyncedTabsDeviceIdHash();

  @$internal
  @override
  SelectedSyncedTabsDeviceId create() => SelectedSyncedTabsDeviceId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedSyncedTabsDeviceIdHash() =>
    r'61f86d2f17d6c2f04e1fb76dae900c4695aa6af0';

abstract class _$SelectedSyncedTabsDeviceId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(syncedTabsTotalCount)
final syncedTabsTotalCountProvider = SyncedTabsTotalCountProvider._();

final class SyncedTabsTotalCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  SyncedTabsTotalCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncedTabsTotalCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncedTabsTotalCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return syncedTabsTotalCount(ref);
  }
}

String _$syncedTabsTotalCountHash() =>
    r'507b14aac187c434cf02925d895151c1a25159ea';

@ProviderFor(effectiveSyncedTabsDeviceId)
final effectiveSyncedTabsDeviceIdProvider =
    EffectiveSyncedTabsDeviceIdProvider._();

final class EffectiveSyncedTabsDeviceIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  EffectiveSyncedTabsDeviceIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveSyncedTabsDeviceIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveSyncedTabsDeviceIdHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return effectiveSyncedTabsDeviceId(ref);
  }
}

String _$effectiveSyncedTabsDeviceIdHash() =>
    r'26ed7e56191a8019cab5c89dc8d5622e1a709e20';

@ProviderFor(syncedTabsForSelectedDevice)
final syncedTabsForSelectedDeviceProvider =
    SyncedTabsForSelectedDeviceProvider._();

final class SyncedTabsForSelectedDeviceProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SyncedTabItem>>,
          List<SyncedTabItem>,
          FutureOr<List<SyncedTabItem>>
        >
    with
        $FutureModifier<List<SyncedTabItem>>,
        $FutureProvider<List<SyncedTabItem>> {
  SyncedTabsForSelectedDeviceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncedTabsForSelectedDeviceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncedTabsForSelectedDeviceHash();

  @$internal
  @override
  $FutureProviderElement<List<SyncedTabItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SyncedTabItem>> create(Ref ref) {
    return syncedTabsForSelectedDevice(ref);
  }
}

String _$syncedTabsForSelectedDeviceHash() =>
    r'a85c4e972ab55b872f1de64cd27ba18d7dcc023a';

@ProviderFor(SyncRepository)
final syncRepositoryProvider = SyncRepositoryProvider._();

final class SyncRepositoryProvider
    extends $AsyncNotifierProvider<SyncRepository, SyncRepositoryState> {
  SyncRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncRepositoryHash();

  @$internal
  @override
  SyncRepository create() => SyncRepository();
}

String _$syncRepositoryHash() => r'5312aed1abf60ce3e04afa7d2f60b38367c09312';

abstract class _$SyncRepository extends $AsyncNotifier<SyncRepositoryState> {
  FutureOr<SyncRepositoryState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SyncRepositoryState>, SyncRepositoryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SyncRepositoryState>, SyncRepositoryState>,
              AsyncValue<SyncRepositoryState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(geckoSyncStateService)
final geckoSyncStateServiceProvider = GeckoSyncStateServiceProvider._();

final class GeckoSyncStateServiceProvider
    extends
        $FunctionalProvider<
          GeckoSyncStateService,
          GeckoSyncStateService,
          GeckoSyncStateService
        >
    with $Provider<GeckoSyncStateService> {
  GeckoSyncStateServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geckoSyncStateServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geckoSyncStateServiceHash();

  @$internal
  @override
  $ProviderElement<GeckoSyncStateService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GeckoSyncStateService create(Ref ref) {
    return geckoSyncStateService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeckoSyncStateService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeckoSyncStateService>(value),
    );
  }
}

String _$geckoSyncStateServiceHash() =>
    r'1e96db4a6229a3d2a31862cc9cf88c463405819b';

@ProviderFor(syncDeviceName)
final syncDeviceNameProvider = SyncDeviceNameProvider._();

final class SyncDeviceNameProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  SyncDeviceNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncDeviceNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncDeviceNameHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return syncDeviceName(ref);
  }
}

String _$syncDeviceNameHash() => r'3d7e531cba481c4233a895b1d80e915d646fc6b6';

@ProviderFor(syncRemoteTabs)
final syncRemoteTabsProvider = SyncRemoteTabsProvider._();

final class SyncRemoteTabsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SyncDeviceTabs>>,
          List<SyncDeviceTabs>,
          FutureOr<List<SyncDeviceTabs>>
        >
    with
        $FutureModifier<List<SyncDeviceTabs>>,
        $FutureProvider<List<SyncDeviceTabs>> {
  SyncRemoteTabsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncRemoteTabsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncRemoteTabsHash();

  @$internal
  @override
  $FutureProviderElement<List<SyncDeviceTabs>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SyncDeviceTabs>> create(Ref ref) {
    return syncRemoteTabs(ref);
  }
}

String _$syncRemoteTabsHash() => r'5040a010e578f2fe395302e7d34a91df1854f8a9';

@ProviderFor(syncDevices)
final syncDevicesProvider = SyncDevicesProvider._();

final class SyncDevicesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SyncDevice>>,
          List<SyncDevice>,
          FutureOr<List<SyncDevice>>
        >
    with $FutureModifier<List<SyncDevice>>, $FutureProvider<List<SyncDevice>> {
  SyncDevicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncDevicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncDevicesHash();

  @$internal
  @override
  $FutureProviderElement<List<SyncDevice>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SyncDevice>> create(Ref ref) {
    return syncDevices(ref);
  }
}

String _$syncDevicesHash() => r'6249b4891f95fc6f8e2f70f1555aff0e6356ccad';

@ProviderFor(syncEvent)
final syncEventProvider = SyncEventProvider._();

final class SyncEventProvider
    extends
        $FunctionalProvider<
          AsyncValue<(SyncEvent?, String?)>,
          (SyncEvent?, String?),
          FutureOr<(SyncEvent?, String?)>
        >
    with
        $FutureModifier<(SyncEvent?, String?)>,
        $FutureProvider<(SyncEvent?, String?)> {
  SyncEventProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncEventProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncEventHash();

  @$internal
  @override
  $FutureProviderElement<(SyncEvent?, String?)> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<(SyncEvent?, String?)> create(Ref ref) {
    return syncEvent(ref);
  }
}

String _$syncEventHash() => r'c84d251502578779f66e17ee79e353ffa3b23e1a';
