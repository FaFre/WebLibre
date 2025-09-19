// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_tor_proxy.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StartProxyController)
const startProxyControllerProvider = StartProxyControllerProvider._();

final class StartProxyControllerProvider
    extends $NotifierProvider<StartProxyController, void> {
  const StartProxyControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startProxyControllerProvider',
        isAutoDispose: true,
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
    r'8840d5ffe9346c3f8b0aa0b3e034605b606c5e34';

abstract class _$StartProxyController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
