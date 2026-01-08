// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_tor_proxy.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StartProxyController)
final startProxyControllerProvider = StartProxyControllerProvider._();

final class StartProxyControllerProvider
    extends $NotifierProvider<StartProxyController, void> {
  StartProxyControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startProxyControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startProxyControllerHash();

  @$internal
  @override
  StartProxyController create() => StartProxyController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$startProxyControllerHash() =>
    r'13c6ad9611a2f9525689d370a0511274aa9c0f03';

abstract class _$StartProxyController extends $Notifier<void> {
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
