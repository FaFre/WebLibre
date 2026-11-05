// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(router)
final routerProvider = RouterProvider._();

final class RouterProvider
    extends
        $FunctionalProvider<AsyncValue<GoRouter>, GoRouter, FutureOr<GoRouter>>
    with $FutureModifier<GoRouter>, $FutureProvider<GoRouter> {
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $FutureProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GoRouter> create(Ref ref) {
    return router(ref);
  }
}

String _$routerHash() => r'e704946e762c4261cfc857ca7ad464d59860114c';

@ProviderFor(CurrentTopRoute)
final currentTopRouteProvider = CurrentTopRouteProvider._();

final class CurrentTopRouteProvider
    extends $NotifierProvider<CurrentTopRoute, RouteBase?> {
  CurrentTopRouteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentTopRouteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentTopRouteHash();

  @$internal
  @override
  CurrentTopRoute create() => CurrentTopRoute();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RouteBase? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RouteBase?>(value),
    );
  }
}

String _$currentTopRouteHash() => r'a1a13c4f7c33e0f2b5089786d5a87f9947c9ab49';

abstract class _$CurrentTopRoute extends $Notifier<RouteBase?> {
  RouteBase? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RouteBase?, RouteBase?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RouteBase?, RouteBase?>,
              RouteBase?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
