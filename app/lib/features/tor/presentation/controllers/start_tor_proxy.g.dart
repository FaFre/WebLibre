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
    extends $NotifierProvider<StartProxyController, bool> {
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
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$startProxyControllerHash() =>
    r'899b585bf7f220251ac92f11c79537cc07723241';

abstract class _$StartProxyController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
