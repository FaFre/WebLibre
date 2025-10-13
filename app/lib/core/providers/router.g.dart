// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(router)
const routerProvider = RouterProvider._();

final class RouterProvider
    extends
        $FunctionalProvider<AsyncValue<GoRouter>, GoRouter, FutureOr<GoRouter>>
    with $FutureModifier<GoRouter>, $FutureProvider<GoRouter> {
  const RouterProvider._()
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

String _$routerHash() => r'87b6e6c1097a0677f3d25570341b343b4392aa59';
