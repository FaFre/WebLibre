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

String _$pwaManifestStateHash() => r'1d173b69e96ab71b117e82b9a4134c6732a73343';

/// Manages PWA manifest state with a long-running subscription.

abstract class _$PwaManifestState extends $Notifier<Map<String, PwaManifest?>> {
  Map<String, PwaManifest?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
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
    return element.handleCreate(ref, build);
  }
}

/// PWA manifest for [tabId]; null without a tab or a manifest.

@ProviderFor(tabManifest)
final tabManifestProvider = TabManifestFamily._();

/// PWA manifest for [tabId]; null without a tab or a manifest.

final class TabManifestProvider
    extends $FunctionalProvider<PwaManifest?, PwaManifest?, PwaManifest?>
    with $Provider<PwaManifest?> {
  /// PWA manifest for [tabId]; null without a tab or a manifest.
  TabManifestProvider._({
    required TabManifestFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'tabManifestProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabManifestHash();

  @override
  String toString() {
    return r'tabManifestProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<PwaManifest?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PwaManifest? create(Ref ref) {
    final argument = this.argument as String?;
    return tabManifest(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PwaManifest? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PwaManifest?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TabManifestProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabManifestHash() => r'e90dc6e9c1ef64df2a31b785e852eefedb31f1a9';

/// PWA manifest for [tabId]; null without a tab or a manifest.

final class TabManifestFamily extends $Family
    with $FunctionalFamilyOverride<PwaManifest?, String?> {
  TabManifestFamily._()
    : super(
        retry: null,
        name: r'tabManifestProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// PWA manifest for [tabId]; null without a tab or a manifest.

  TabManifestProvider call(String? tabId) =>
      TabManifestProvider._(argument: tabId, from: this);

  @override
  String toString() => r'tabManifestProvider';
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
    r'169a7272c55d914d11b3800d183316ce818c1264';

/// Whether [tabId] is installable as a PWA.

@ProviderFor(isTabInstallable)
final isTabInstallableProvider = IsTabInstallableFamily._();

/// Whether [tabId] is installable as a PWA.

final class IsTabInstallableProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether [tabId] is installable as a PWA.
  IsTabInstallableProvider._({
    required IsTabInstallableFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'isTabInstallableProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isTabInstallableHash();

  @override
  String toString() {
    return r'isTabInstallableProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String?;
    return isTabInstallable(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsTabInstallableProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isTabInstallableHash() => r'096bf38907d97932e841343afb73623a4e145bd1';

/// Whether [tabId] is installable as a PWA.

final class IsTabInstallableFamily extends $Family
    with $FunctionalFamilyOverride<bool, String?> {
  IsTabInstallableFamily._()
    : super(
        retry: null,
        name: r'isTabInstallableProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether [tabId] is installable as a PWA.

  IsTabInstallableProvider call(String? tabId) =>
      IsTabInstallableProvider._(argument: tabId, from: this);

  @override
  String toString() => r'isTabInstallableProvider';
}

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
    r'2adc08329d90de80fb9e9bbd1e04e5f308e6a486';

/// Installs [tabId] — the selected tab when null — as a PWA, embedding profile
/// and container context in the shortcut intent so the PWA reopens with the
/// same isolation.

@ProviderFor(installCurrentWebApp)
final installCurrentWebAppProvider = InstallCurrentWebAppFamily._();

/// Installs [tabId] — the selected tab when null — as a PWA, embedding profile
/// and container context in the shortcut intent so the PWA reopens with the
/// same isolation.

final class InstallCurrentWebAppProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Installs [tabId] — the selected tab when null — as a PWA, embedding profile
  /// and container context in the shortcut intent so the PWA reopens with the
  /// same isolation.
  InstallCurrentWebAppProvider._({
    required InstallCurrentWebAppFamily super.from,
    required ({String? tabId, String? overrideName, String? contextId})
    super.argument,
  }) : super(
         retry: null,
         name: r'installCurrentWebAppProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$installCurrentWebAppHash();

  @override
  String toString() {
    return r'installCurrentWebAppProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument =
        this.argument
            as ({String? tabId, String? overrideName, String? contextId});
    return installCurrentWebApp(
      ref,
      tabId: argument.tabId,
      overrideName: argument.overrideName,
      contextId: argument.contextId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InstallCurrentWebAppProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$installCurrentWebAppHash() =>
    r'bf22621c635ae862c77d51888cc32f03acbd0303';

/// Installs [tabId] — the selected tab when null — as a PWA, embedding profile
/// and container context in the shortcut intent so the PWA reopens with the
/// same isolation.

final class InstallCurrentWebAppFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<bool>,
          ({String? tabId, String? overrideName, String? contextId})
        > {
  InstallCurrentWebAppFamily._()
    : super(
        retry: null,
        name: r'installCurrentWebAppProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Installs [tabId] — the selected tab when null — as a PWA, embedding profile
  /// and container context in the shortcut intent so the PWA reopens with the
  /// same isolation.

  InstallCurrentWebAppProvider call({
    String? tabId,
    String? overrideName,
    String? contextId,
  }) => InstallCurrentWebAppProvider._(
    argument: (tabId: tabId, overrideName: overrideName, contextId: contextId),
    from: this,
  );

  @override
  String toString() => r'installCurrentWebAppProvider';
}

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

/// Whether [tabId] is on an HTTPS page (eligible for home screen shortcut).

@ProviderFor(isTabShortcutable)
final isTabShortcutableProvider = IsTabShortcutableFamily._();

/// Whether [tabId] is on an HTTPS page (eligible for home screen shortcut).

final class IsTabShortcutableProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether [tabId] is on an HTTPS page (eligible for home screen shortcut).
  IsTabShortcutableProvider._({
    required IsTabShortcutableFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'isTabShortcutableProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isTabShortcutableHash();

  @override
  String toString() {
    return r'isTabShortcutableProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String?;
    return isTabShortcutable(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsTabShortcutableProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isTabShortcutableHash() => r'58c267b0a383c7d5dc28fb5283c04f8061df0bfa';

/// Whether [tabId] is on an HTTPS page (eligible for home screen shortcut).

final class IsTabShortcutableFamily extends $Family
    with $FunctionalFamilyOverride<bool, String?> {
  IsTabShortcutableFamily._()
    : super(
        retry: null,
        name: r'isTabShortcutableProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether [tabId] is on an HTTPS page (eligible for home screen shortcut).

  IsTabShortcutableProvider call(String? tabId) =>
      IsTabShortcutableProvider._(argument: tabId, from: this);

  @override
  String toString() => r'isTabShortcutableProvider';
}

/// Whether the current tab is on an HTTPS page (eligible for home screen shortcut).

@ProviderFor(isCurrentTabShortcutable)
final isCurrentTabShortcutableProvider = IsCurrentTabShortcutableProvider._();

/// Whether the current tab is on an HTTPS page (eligible for home screen shortcut).

final class IsCurrentTabShortcutableProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the current tab is on an HTTPS page (eligible for home screen shortcut).
  IsCurrentTabShortcutableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isCurrentTabShortcutableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isCurrentTabShortcutableHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isCurrentTabShortcutable(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isCurrentTabShortcutableHash() =>
    r'6681b7a55458645c3fedf4ce1b0a027abbf256f4';

/// Creates a basic bookmark shortcut on the home screen for [tabId], the
/// selected tab when null.

@ProviderFor(installBasicShortcut)
final installBasicShortcutProvider = InstallBasicShortcutFamily._();

/// Creates a basic bookmark shortcut on the home screen for [tabId], the
/// selected tab when null.

final class InstallBasicShortcutProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Creates a basic bookmark shortcut on the home screen for [tabId], the
  /// selected tab when null.
  InstallBasicShortcutProvider._({
    required InstallBasicShortcutFamily super.from,
    required ({String? tabId, String? overrideName, String? contextId})
    super.argument,
  }) : super(
         retry: null,
         name: r'installBasicShortcutProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$installBasicShortcutHash();

  @override
  String toString() {
    return r'installBasicShortcutProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument =
        this.argument
            as ({String? tabId, String? overrideName, String? contextId});
    return installBasicShortcut(
      ref,
      tabId: argument.tabId,
      overrideName: argument.overrideName,
      contextId: argument.contextId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InstallBasicShortcutProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$installBasicShortcutHash() =>
    r'2311bdbfe74d543b0bbfe05c54ff35177ae69d2e';

/// Creates a basic bookmark shortcut on the home screen for [tabId], the
/// selected tab when null.

final class InstallBasicShortcutFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<bool>,
          ({String? tabId, String? overrideName, String? contextId})
        > {
  InstallBasicShortcutFamily._()
    : super(
        retry: null,
        name: r'installBasicShortcutProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Creates a basic bookmark shortcut on the home screen for [tabId], the
  /// selected tab when null.

  InstallBasicShortcutProvider call({
    String? tabId,
    String? overrideName,
    String? contextId,
  }) => InstallBasicShortcutProvider._(
    argument: (tabId: tabId, overrideName: overrideName, contextId: contextId),
    from: this,
  );

  @override
  String toString() => r'installBasicShortcutProvider';
}
