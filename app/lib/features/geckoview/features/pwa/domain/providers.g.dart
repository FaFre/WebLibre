// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stream of manifest update events from the event service.

@ProviderFor(manifestUpdateEventsStream)
final manifestUpdateEventsStreamProvider =
    ManifestUpdateEventsStreamProvider._();

/// Stream of manifest update events from the event service.

final class ManifestUpdateEventsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<ManifestUpdateEvent>,
          ManifestUpdateEvent,
          Stream<ManifestUpdateEvent>
        >
    with
        $FutureModifier<ManifestUpdateEvent>,
        $StreamProvider<ManifestUpdateEvent> {
  /// Stream of manifest update events from the event service.
  ManifestUpdateEventsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'manifestUpdateEventsStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$manifestUpdateEventsStreamHash();

  @$internal
  @override
  $StreamProviderElement<ManifestUpdateEvent> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ManifestUpdateEvent> create(Ref ref) {
    return manifestUpdateEventsStream(ref);
  }
}

String _$manifestUpdateEventsStreamHash() =>
    r'60035756c129c1801f2f1f4e7da6384abf78d8fa';

/// Manages PWA manifest state with a long-running subscription.

@ProviderFor(PwaManifestState)
final pwaManifestStateProvider = PwaManifestStateProvider._();

/// Manages PWA manifest state with a long-running subscription.
final class PwaManifestStateProvider
    extends $NotifierProvider<PwaManifestState, Map<String, PwaManifest?>> {
  /// Manages PWA manifest state with a long-running subscription.
  PwaManifestStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pwaManifestStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pwaManifestStateHash();

  @$internal
  @override
  PwaManifestState create() => PwaManifestState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, PwaManifest?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, PwaManifest?>>(value),
    );
  }
}

String _$pwaManifestStateHash() => r'e5237d2aae5dce9cb805484eb2a09cc3f6aceda1';

/// Manages PWA manifest state with a long-running subscription.

abstract class _$PwaManifestState extends $Notifier<Map<String, PwaManifest?>> {
  Map<String, PwaManifest?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<Map<String, PwaManifest?>, Map<String, PwaManifest?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, PwaManifest?>, Map<String, PwaManifest?>>,
              Map<String, PwaManifest?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// PWA manifest for the currently selected tab.

@ProviderFor(currentTabManifest)
final currentTabManifestProvider = CurrentTabManifestProvider._();

/// PWA manifest for the currently selected tab.

final class CurrentTabManifestProvider
    extends $FunctionalProvider<PwaManifest?, PwaManifest?, PwaManifest?>
    with $Provider<PwaManifest?> {
  /// PWA manifest for the currently selected tab.
  CurrentTabManifestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentTabManifestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentTabManifestHash();

  @$internal
  @override
  $ProviderElement<PwaManifest?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PwaManifest? create(Ref ref) {
    return currentTabManifest(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PwaManifest? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PwaManifest?>(value),
    );
  }
}

String _$currentTabManifestHash() =>
    r'6121287eaaa18d080154c8ffe6e2a4b8c2d144d3';

/// Boolean indicating if the current tab is installable as a PWA.

@ProviderFor(isCurrentTabInstallable)
final isCurrentTabInstallableProvider = IsCurrentTabInstallableProvider._();

/// Boolean indicating if the current tab is installable as a PWA.

final class IsCurrentTabInstallableProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Boolean indicating if the current tab is installable as a PWA.
  IsCurrentTabInstallableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isCurrentTabInstallableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isCurrentTabInstallableHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isCurrentTabInstallable(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isCurrentTabInstallableHash() =>
    r'293cdb6dcea24446343330ccdb30dc9f21f03618';

/// Installs the current tab as a PWA, embedding profile and container context
/// in the shortcut intent so the PWA reopens with the same isolation.

@ProviderFor(installCurrentWebApp)
final installCurrentWebAppProvider = InstallCurrentWebAppProvider._();

/// Installs the current tab as a PWA, embedding profile and container context
/// in the shortcut intent so the PWA reopens with the same isolation.

final class InstallCurrentWebAppProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Installs the current tab as a PWA, embedding profile and container context
  /// in the shortcut intent so the PWA reopens with the same isolation.
  InstallCurrentWebAppProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'installCurrentWebAppProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$installCurrentWebAppHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return installCurrentWebApp(ref);
  }
}

String _$installCurrentWebAppHash() =>
    r'da536e2aca886831e0bbbc5b70eae03ac4a4ea9f';

/// Returns all installed PWAs.

@ProviderFor(installedWebApps)
final installedWebAppsProvider = InstalledWebAppsProvider._();

/// Returns all installed PWAs.

final class InstalledWebAppsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PwaManifest>>,
          List<PwaManifest>,
          FutureOr<List<PwaManifest>>
        >
    with
        $FutureModifier<List<PwaManifest>>,
        $FutureProvider<List<PwaManifest>> {
  /// Returns all installed PWAs.
  InstalledWebAppsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'installedWebAppsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$installedWebAppsHash();

  @$internal
  @override
  $FutureProviderElement<List<PwaManifest>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PwaManifest>> create(Ref ref) {
    return installedWebApps(ref);
  }
}

String _$installedWebAppsHash() => r'ff185620ccd25bf6b71415e34e3e0c0f20d5e59d';
