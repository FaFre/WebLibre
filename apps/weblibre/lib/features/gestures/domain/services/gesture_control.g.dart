// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gesture_control.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bridges gesture settings and recognized-gesture events to app actions.
///
/// On build it (1) keeps the native recognizer's [GestureConfig] in sync with
/// the user's [GestureSettings], and (2) subscribes to recognized gestures and
/// dispatches the bound [GestureAction] against the currently selected tab.
///
/// Must be kept alive (eagerly listened to from the browser view) for the
/// lifetime of the browser so the subscription stays active.

@ProviderFor(GestureControlService)
final gestureControlServiceProvider = GestureControlServiceProvider._();

/// Bridges gesture settings and recognized-gesture events to app actions.
///
/// On build it (1) keeps the native recognizer's [GestureConfig] in sync with
/// the user's [GestureSettings], and (2) subscribes to recognized gestures and
/// dispatches the bound [GestureAction] against the currently selected tab.
///
/// Must be kept alive (eagerly listened to from the browser view) for the
/// lifetime of the browser so the subscription stays active.
final class GestureControlServiceProvider
    extends $NotifierProvider<GestureControlService, void> {
  /// Bridges gesture settings and recognized-gesture events to app actions.
  ///
  /// On build it (1) keeps the native recognizer's [GestureConfig] in sync with
  /// the user's [GestureSettings], and (2) subscribes to recognized gestures and
  /// dispatches the bound [GestureAction] against the currently selected tab.
  ///
  /// Must be kept alive (eagerly listened to from the browser view) for the
  /// lifetime of the browser so the subscription stays active.
  GestureControlServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gestureControlServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gestureControlServiceHash();

  @$internal
  @override
  GestureControlService create() => GestureControlService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$gestureControlServiceHash() =>
    r'12bd852a5b90b67bee4a94e7bd55fccc53c11bd4';

/// Bridges gesture settings and recognized-gesture events to app actions.
///
/// On build it (1) keeps the native recognizer's [GestureConfig] in sync with
/// the user's [GestureSettings], and (2) subscribes to recognized gestures and
/// dispatches the bound [GestureAction] against the currently selected tab.
///
/// Must be kept alive (eagerly listened to from the browser view) for the
/// lifetime of the browser so the subscription stays active.

abstract class _$GestureControlService extends $Notifier<void> {
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

/// Whether gestures are currently disabled because the selected tab's site is
/// on the user's exclusion list.

@ProviderFor(gestureSiteExcluded)
final gestureSiteExcludedProvider = GestureSiteExcludedProvider._();

/// Whether gestures are currently disabled because the selected tab's site is
/// on the user's exclusion list.

final class GestureSiteExcludedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether gestures are currently disabled because the selected tab's site is
  /// on the user's exclusion list.
  GestureSiteExcludedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gestureSiteExcludedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gestureSiteExcludedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return gestureSiteExcluded(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$gestureSiteExcludedHash() =>
    r'c7c9f8128a7262b858c954b7217d6a00f1d062e4';

/// The effective native recognizer configuration: the user's settings with the
/// recognizer disabled while the current site is excluded.

@ProviderFor(gestureNativeConfig)
final gestureNativeConfigProvider = GestureNativeConfigProvider._();

/// The effective native recognizer configuration: the user's settings with the
/// recognizer disabled while the current site is excluded.

final class GestureNativeConfigProvider
    extends $FunctionalProvider<GestureConfig, GestureConfig, GestureConfig>
    with $Provider<GestureConfig> {
  /// The effective native recognizer configuration: the user's settings with the
  /// recognizer disabled while the current site is excluded.
  GestureNativeConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gestureNativeConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gestureNativeConfigHash();

  @$internal
  @override
  $ProviderElement<GestureConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GestureConfig create(Ref ref) {
    return gestureNativeConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GestureConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GestureConfig>(value),
    );
  }
}

String _$gestureNativeConfigHash() =>
    r'd7caf199a60089109cbf264ca3c4d59ccf97044e';

/// The in-progress stroke shown by the live feedback overlay.
///
/// Emits the current partial canonical key (e.g. `R:D`) while a stroke is being
/// drawn, and null when nothing should be shown — driven by the native gesture
/// progress/reset events.

@ProviderFor(gestureProgress)
final gestureProgressProvider = GestureProgressProvider._();

/// The in-progress stroke shown by the live feedback overlay.
///
/// Emits the current partial canonical key (e.g. `R:D`) while a stroke is being
/// drawn, and null when nothing should be shown — driven by the native gesture
/// progress/reset events.

final class GestureProgressProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// The in-progress stroke shown by the live feedback overlay.
  ///
  /// Emits the current partial canonical key (e.g. `R:D`) while a stroke is being
  /// drawn, and null when nothing should be shown — driven by the native gesture
  /// progress/reset events.
  GestureProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gestureProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gestureProgressHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return gestureProgress(ref);
  }
}

String _$gestureProgressHash() => r'2f3ed4a8db41d317869db2e5aa71e737afb5364b';
