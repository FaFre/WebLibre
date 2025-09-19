// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'builtin_bridges.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BuiltinBridgesService)
const builtinBridgesServiceProvider = BuiltinBridgesServiceProvider._();

final class BuiltinBridgesServiceProvider
    extends $NotifierProvider<BuiltinBridgesService, void> {
  const BuiltinBridgesServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'builtinBridgesServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$builtinBridgesServiceHash();

  @$internal
  @override
  BuiltinBridgesService create() => BuiltinBridgesService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$builtinBridgesServiceHash() =>
    r'beacb3c9d8c5a7179c7c9cad8024d128b09241f5';

abstract class _$BuiltinBridgesService extends $Notifier<void> {
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
