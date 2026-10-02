// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'builtin_bridges.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BuiltinBridgesService)
final builtinBridgesServiceProvider = BuiltinBridgesServiceProvider._();

final class BuiltinBridgesServiceProvider
    extends $NotifierProvider<BuiltinBridgesService, void> {
  BuiltinBridgesServiceProvider._()
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
    r'7dbb6f3662820399a708d81c78211593da4fff35';

abstract class _$BuiltinBridgesService extends $Notifier<void> {
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
