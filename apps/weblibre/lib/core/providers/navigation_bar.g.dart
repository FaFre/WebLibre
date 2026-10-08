// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_bar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the navigation bar sits outside the Flutter UI, so Flutter cannot
/// paint behind it and the bar shows the native window background instead
/// (#657). MainActivity measures this from view geometry and pushes every
/// change; without the channel (tests, other hosts) it stays false.
///
/// Kept alive so a screen that mounts again (the browser leaving fullscreen)
/// starts from the known value, not from false until the native reply lands.

@ProviderFor(NavigationBarOutsideFlutter)
final navigationBarOutsideFlutterProvider =
    NavigationBarOutsideFlutterProvider._();

/// Whether the navigation bar sits outside the Flutter UI, so Flutter cannot
/// paint behind it and the bar shows the native window background instead
/// (#657). MainActivity measures this from view geometry and pushes every
/// change; without the channel (tests, other hosts) it stays false.
///
/// Kept alive so a screen that mounts again (the browser leaving fullscreen)
/// starts from the known value, not from false until the native reply lands.
final class NavigationBarOutsideFlutterProvider
    extends $NotifierProvider<NavigationBarOutsideFlutter, bool> {
  /// Whether the navigation bar sits outside the Flutter UI, so Flutter cannot
  /// paint behind it and the bar shows the native window background instead
  /// (#657). MainActivity measures this from view geometry and pushes every
  /// change; without the channel (tests, other hosts) it stays false.
  ///
  /// Kept alive so a screen that mounts again (the browser leaving fullscreen)
  /// starts from the known value, not from false until the native reply lands.
  NavigationBarOutsideFlutterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationBarOutsideFlutterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationBarOutsideFlutterHash();

  @$internal
  @override
  NavigationBarOutsideFlutter create() => NavigationBarOutsideFlutter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$navigationBarOutsideFlutterHash() =>
    r'7ab72dffd1898303061c41f7f669462b901dd002';

/// Whether the navigation bar sits outside the Flutter UI, so Flutter cannot
/// paint behind it and the bar shows the native window background instead
/// (#657). MainActivity measures this from view geometry and pushes every
/// change; without the channel (tests, other hosts) it stays false.
///
/// Kept alive so a screen that mounts again (the browser leaving fullscreen)
/// starts from the known value, not from false until the native reply lands.

abstract class _$NavigationBarOutsideFlutter extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
