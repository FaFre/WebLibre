// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_target_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Applies the configured [HomeTarget] when the browser has nothing to show.

@ProviderFor(HomeTargetController)
final homeTargetControllerProvider = HomeTargetControllerProvider._();

/// Applies the configured [HomeTarget] when the browser has nothing to show.
final class HomeTargetControllerProvider
    extends $NotifierProvider<HomeTargetController, void> {
  /// Applies the configured [HomeTarget] when the browser has nothing to show.
  HomeTargetControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeTargetControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeTargetControllerHash();

  @$internal
  @override
  HomeTargetController create() => HomeTargetController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$homeTargetControllerHash() =>
    r'db486c85ce71b99a67fde8ca142da43aef402973';

/// Applies the configured [HomeTarget] when the browser has nothing to show.

abstract class _$HomeTargetController extends $Notifier<void> {
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
