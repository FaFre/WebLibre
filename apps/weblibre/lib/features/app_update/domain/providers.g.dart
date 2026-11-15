// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The updater as the UI sees it. Null while the build has no updater (the
/// Updates screen and its row are then not built).

@ProviderFor(AppUpdateController)
final appUpdateControllerProvider = AppUpdateControllerProvider._();

/// The updater as the UI sees it. Null while the build has no updater (the
/// Updates screen and its row are then not built).
final class AppUpdateControllerProvider
    extends $NotifierProvider<AppUpdateController, UpdateSnapshot?> {
  /// The updater as the UI sees it. Null while the build has no updater (the
  /// Updates screen and its row are then not built).
  AppUpdateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdateControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdateControllerHash();

  @$internal
  @override
  AppUpdateController create() => AppUpdateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateSnapshot? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateSnapshot?>(value),
    );
  }
}

String _$appUpdateControllerHash() =>
    r'f804e7003096182ae82870d428f1328118da6d21';

/// The updater as the UI sees it. Null while the build has no updater (the
/// Updates screen and its row are then not built).

abstract class _$AppUpdateController extends $Notifier<UpdateSnapshot?> {
  UpdateSnapshot? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UpdateSnapshot?, UpdateSnapshot?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UpdateSnapshot?, UpdateSnapshot?>,
              UpdateSnapshot?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// What the browser menu row and the dot show (8.2, 8.3). Derived UI state:
/// the controller above it is what stays alive.

@ProviderFor(appUpdateSurface)
final appUpdateSurfaceProvider = AppUpdateSurfaceProvider._();

/// What the browser menu row and the dot show (8.2, 8.3). Derived UI state:
/// the controller above it is what stays alive.

final class AppUpdateSurfaceProvider
    extends $FunctionalProvider<UpdateSurface, UpdateSurface, UpdateSurface>
    with $Provider<UpdateSurface> {
  /// What the browser menu row and the dot show (8.2, 8.3). Derived UI state:
  /// the controller above it is what stays alive.
  AppUpdateSurfaceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdateSurfaceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdateSurfaceHash();

  @$internal
  @override
  $ProviderElement<UpdateSurface> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateSurface create(Ref ref) {
    return appUpdateSurface(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateSurface value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateSurface>(value),
    );
  }
}

String _$appUpdateSurfaceHash() => r'd5dae3676bf1a8cf5126928702851417df16ee9f';

/// Shorthand for widgets that only need the state.

@ProviderFor(appUpdateState)
final appUpdateStateProvider = AppUpdateStateProvider._();

/// Shorthand for widgets that only need the state.

final class AppUpdateStateProvider
    extends $FunctionalProvider<UpdateState?, UpdateState?, UpdateState?>
    with $Provider<UpdateState?> {
  /// Shorthand for widgets that only need the state.
  AppUpdateStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdateStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdateStateHash();

  @$internal
  @override
  $ProviderElement<UpdateState?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateState? create(Ref ref) {
    return appUpdateState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateState?>(value),
    );
  }
}

String _$appUpdateStateHash() => r'ab3779f9988a5063385b325d40419cf938e6acf5';

/// Whether this installation has an updater, at runtime (3.5): false until
/// the policy is read, and for builds that compile one in but may not use it
/// (foreign-signed, universal APK). Settings build the Updates section only
/// while this holds.

@ProviderFor(appUpdaterAvailable)
final appUpdaterAvailableProvider = AppUpdaterAvailableProvider._();

/// Whether this installation has an updater, at runtime (3.5): false until
/// the policy is read, and for builds that compile one in but may not use it
/// (foreign-signed, universal APK). Settings build the Updates section only
/// while this holds.

final class AppUpdaterAvailableProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether this installation has an updater, at runtime (3.5): false until
  /// the policy is read, and for builds that compile one in but may not use it
  /// (foreign-signed, universal APK). Settings build the Updates section only
  /// while this holds.
  AppUpdaterAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdaterAvailableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdaterAvailableHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return appUpdaterAvailable(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$appUpdaterAvailableHash() =>
    r'1a9912857909a21530544a87dd2e773179774f61';
