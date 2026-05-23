// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sandbox_capture_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(oneShotCaptureClient)
final oneShotCaptureClientProvider = OneShotCaptureClientProvider._();

final class OneShotCaptureClientProvider
    extends
        $FunctionalProvider<
          OneShotCaptureClient,
          OneShotCaptureClient,
          OneShotCaptureClient
        >
    with $Provider<OneShotCaptureClient> {
  OneShotCaptureClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oneShotCaptureClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oneShotCaptureClientHash();

  @$internal
  @override
  $ProviderElement<OneShotCaptureClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OneShotCaptureClient create(Ref ref) {
    return oneShotCaptureClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OneShotCaptureClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OneShotCaptureClient>(value),
    );
  }
}

String _$oneShotCaptureClientHash() =>
    r'35c3dbeb91a5c9ca1663f43f4b48332bcde3ae3f';

/// Streams capture-tab rows keyed by tabId. Watched by the address bar so
/// the UI can show the canonical source URL (instead of the loopback
/// loader/capture URL) and a sandbox indicator.

@ProviderFor(sandboxCaptureMap)
final sandboxCaptureMapProvider = SandboxCaptureMapProvider._();

/// Streams capture-tab rows keyed by tabId. Watched by the address bar so
/// the UI can show the canonical source URL (instead of the loopback
/// loader/capture URL) and a sandbox indicator.

final class SandboxCaptureMapProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, CaptureTabData>>,
          Map<String, CaptureTabData>,
          Stream<Map<String, CaptureTabData>>
        >
    with
        $FutureModifier<Map<String, CaptureTabData>>,
        $StreamProvider<Map<String, CaptureTabData>> {
  /// Streams capture-tab rows keyed by tabId. Watched by the address bar so
  /// the UI can show the canonical source URL (instead of the loopback
  /// loader/capture URL) and a sandbox indicator.
  SandboxCaptureMapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sandboxCaptureMapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sandboxCaptureMapHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, CaptureTabData>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, CaptureTabData>> create(Ref ref) {
    return sandboxCaptureMap(ref);
  }
}

String _$sandboxCaptureMapHash() => r'1771bb1c618e34f24e718609d501c426ac49f192';

@ProviderFor(sandboxCaptureForTab)
final sandboxCaptureForTabProvider = SandboxCaptureForTabFamily._();

final class SandboxCaptureForTabProvider
    extends
        $FunctionalProvider<CaptureTabData?, CaptureTabData?, CaptureTabData?>
    with $Provider<CaptureTabData?> {
  SandboxCaptureForTabProvider._({
    required SandboxCaptureForTabFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'sandboxCaptureForTabProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sandboxCaptureForTabHash();

  @override
  String toString() {
    return r'sandboxCaptureForTabProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<CaptureTabData?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CaptureTabData? create(Ref ref) {
    final argument = this.argument as String?;
    return sandboxCaptureForTab(ref, tabId: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CaptureTabData? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CaptureTabData?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SandboxCaptureForTabProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sandboxCaptureForTabHash() =>
    r'1d64f68c85d40dbd7d5b220ee54a5436f1c1eaeb';

final class SandboxCaptureForTabFamily extends $Family
    with $FunctionalFamilyOverride<CaptureTabData?, String?> {
  SandboxCaptureForTabFamily._()
    : super(
        retry: null,
        name: r'sandboxCaptureForTabProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SandboxCaptureForTabProvider call({required String? tabId}) =>
      SandboxCaptureForTabProvider._(argument: tabId, from: this);

  @override
  String toString() => r'sandboxCaptureForTabProvider';
}

/// The canonical source URL of a sandbox-captured tab, or `null` when the
/// tab is not a sandbox capture (the regular `tabState.url` should be used in
/// that case).

@ProviderFor(sandboxSourceUriForTab)
final sandboxSourceUriForTabProvider = SandboxSourceUriForTabFamily._();

/// The canonical source URL of a sandbox-captured tab, or `null` when the
/// tab is not a sandbox capture (the regular `tabState.url` should be used in
/// that case).

final class SandboxSourceUriForTabProvider
    extends $FunctionalProvider<Uri?, Uri?, Uri?>
    with $Provider<Uri?> {
  /// The canonical source URL of a sandbox-captured tab, or `null` when the
  /// tab is not a sandbox capture (the regular `tabState.url` should be used in
  /// that case).
  SandboxSourceUriForTabProvider._({
    required SandboxSourceUriForTabFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'sandboxSourceUriForTabProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sandboxSourceUriForTabHash();

  @override
  String toString() {
    return r'sandboxSourceUriForTabProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Uri?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Uri? create(Ref ref) {
    final argument = this.argument as String?;
    return sandboxSourceUriForTab(ref, tabId: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uri? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uri?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SandboxSourceUriForTabProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sandboxSourceUriForTabHash() =>
    r'62f55eefd22377109080ea328c9ac0c00a0f7196';

/// The canonical source URL of a sandbox-captured tab, or `null` when the
/// tab is not a sandbox capture (the regular `tabState.url` should be used in
/// that case).

final class SandboxSourceUriForTabFamily extends $Family
    with $FunctionalFamilyOverride<Uri?, String?> {
  SandboxSourceUriForTabFamily._()
    : super(
        retry: null,
        name: r'sandboxSourceUriForTabProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The canonical source URL of a sandbox-captured tab, or `null` when the
  /// tab is not a sandbox capture (the regular `tabState.url` should be used in
  /// that case).

  SandboxSourceUriForTabProvider call({required String? tabId}) =>
      SandboxSourceUriForTabProvider._(argument: tabId, from: this);

  @override
  String toString() => r'sandboxSourceUriForTabProvider';
}

@ProviderFor(sandboxCaptureStore)
final sandboxCaptureStoreProvider = SandboxCaptureStoreProvider._();

final class SandboxCaptureStoreProvider
    extends
        $FunctionalProvider<
          SandboxCaptureStore,
          SandboxCaptureStore,
          SandboxCaptureStore
        >
    with $Provider<SandboxCaptureStore> {
  SandboxCaptureStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sandboxCaptureStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sandboxCaptureStoreHash();

  @$internal
  @override
  $ProviderElement<SandboxCaptureStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SandboxCaptureStore create(Ref ref) {
    return sandboxCaptureStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SandboxCaptureStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SandboxCaptureStore>(value),
    );
  }
}

String _$sandboxCaptureStoreHash() =>
    r'59cf9cfe1e6727ea2c049ed60e7e69cfe6e55d03';

@ProviderFor(sandboxCaptureErrors)
final sandboxCaptureErrorsProvider = SandboxCaptureErrorsProvider._();

final class SandboxCaptureErrorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SandboxCaptureError>,
          SandboxCaptureError,
          Stream<SandboxCaptureError>
        >
    with
        $FutureModifier<SandboxCaptureError>,
        $StreamProvider<SandboxCaptureError> {
  SandboxCaptureErrorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sandboxCaptureErrorsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sandboxCaptureErrorsHash();

  @$internal
  @override
  $StreamProviderElement<SandboxCaptureError> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SandboxCaptureError> create(Ref ref) {
    return sandboxCaptureErrors(ref);
  }
}

String _$sandboxCaptureErrorsHash() =>
    r'da9021ba394d2769140408577983bbcf45b0e0fe';

/// Orchestrates sandbox capture browsing:
///
/// 1. Listens for dispatch events from Kotlin (`onSandboxLinkClick`,
///    `onSandboxNewTab`) and runs the capture pipeline.
/// 2. Keeps the native `SandboxCaptureRegistry` and the on-disk JSON mirror
///    in sync with the `capture_tab` table via a DAO subscription.
/// 3. Listens on `CaptureServer.retryRequests` and re-runs failed captures.
///
/// This provider is kept alive for the lifetime of the app; `build()` wires
/// up the subscriptions and returns nothing interesting.

@ProviderFor(SandboxCaptureController)
final sandboxCaptureControllerProvider = SandboxCaptureControllerProvider._();

/// Orchestrates sandbox capture browsing:
///
/// 1. Listens for dispatch events from Kotlin (`onSandboxLinkClick`,
///    `onSandboxNewTab`) and runs the capture pipeline.
/// 2. Keeps the native `SandboxCaptureRegistry` and the on-disk JSON mirror
///    in sync with the `capture_tab` table via a DAO subscription.
/// 3. Listens on `CaptureServer.retryRequests` and re-runs failed captures.
///
/// This provider is kept alive for the lifetime of the app; `build()` wires
/// up the subscriptions and returns nothing interesting.
final class SandboxCaptureControllerProvider
    extends $NotifierProvider<SandboxCaptureController, void> {
  /// Orchestrates sandbox capture browsing:
  ///
  /// 1. Listens for dispatch events from Kotlin (`onSandboxLinkClick`,
  ///    `onSandboxNewTab`) and runs the capture pipeline.
  /// 2. Keeps the native `SandboxCaptureRegistry` and the on-disk JSON mirror
  ///    in sync with the `capture_tab` table via a DAO subscription.
  /// 3. Listens on `CaptureServer.retryRequests` and re-runs failed captures.
  ///
  /// This provider is kept alive for the lifetime of the app; `build()` wires
  /// up the subscriptions and returns nothing interesting.
  SandboxCaptureControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sandboxCaptureControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sandboxCaptureControllerHash();

  @$internal
  @override
  SandboxCaptureController create() => SandboxCaptureController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$sandboxCaptureControllerHash() =>
    r'6ddcb0df7194f3e35ac0eee3c182204a990f9651';

/// Orchestrates sandbox capture browsing:
///
/// 1. Listens for dispatch events from Kotlin (`onSandboxLinkClick`,
///    `onSandboxNewTab`) and runs the capture pipeline.
/// 2. Keeps the native `SandboxCaptureRegistry` and the on-disk JSON mirror
///    in sync with the `capture_tab` table via a DAO subscription.
/// 3. Listens on `CaptureServer.retryRequests` and re-runs failed captures.
///
/// This provider is kept alive for the lifetime of the app; `build()` wires
/// up the subscriptions and returns nothing interesting.

abstract class _$SandboxCaptureController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
