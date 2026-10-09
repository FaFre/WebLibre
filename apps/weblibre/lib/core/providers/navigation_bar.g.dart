// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_bar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The current [NavigationBarLayout]. MainActivity pushes every change;
/// without the channel (tests, other hosts) neither condition holds.
///
/// Kept alive so a screen that mounts again (the browser leaving fullscreen)
/// starts from the known value, not from the default until the native reply
/// lands.

@ProviderFor(NavigationBarLayoutController)
final navigationBarLayoutControllerProvider =
    NavigationBarLayoutControllerProvider._();

/// The current [NavigationBarLayout]. MainActivity pushes every change;
/// without the channel (tests, other hosts) neither condition holds.
///
/// Kept alive so a screen that mounts again (the browser leaving fullscreen)
/// starts from the known value, not from the default until the native reply
/// lands.
final class NavigationBarLayoutControllerProvider
    extends
        $NotifierProvider<NavigationBarLayoutController, NavigationBarLayout> {
  /// The current [NavigationBarLayout]. MainActivity pushes every change;
  /// without the channel (tests, other hosts) neither condition holds.
  ///
  /// Kept alive so a screen that mounts again (the browser leaving fullscreen)
  /// starts from the known value, not from the default until the native reply
  /// lands.
  NavigationBarLayoutControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationBarLayoutControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationBarLayoutControllerHash();

  @$internal
  @override
  NavigationBarLayoutController create() => NavigationBarLayoutController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigationBarLayout value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigationBarLayout>(value),
    );
  }
}

String _$navigationBarLayoutControllerHash() =>
    r'38bdc35c60ac828e0bcbf53674d17239b0ff29a5';

/// The current [NavigationBarLayout]. MainActivity pushes every change;
/// without the channel (tests, other hosts) neither condition holds.
///
/// Kept alive so a screen that mounts again (the browser leaving fullscreen)
/// starts from the known value, not from the default until the native reply
/// lands.

abstract class _$NavigationBarLayoutController
    extends $Notifier<NavigationBarLayout> {
  NavigationBarLayout build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NavigationBarLayout, NavigationBarLayout>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NavigationBarLayout, NavigationBarLayout>,
              NavigationBarLayout,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
