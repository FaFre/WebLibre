// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'builtin_bridges.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BuiltinBridgesRepository)
const builtinBridgesRepositoryProvider = BuiltinBridgesRepositoryFamily._();

final class BuiltinBridgesRepositoryProvider
    extends $NotifierProvider<BuiltinBridgesRepository, void> {
  const BuiltinBridgesRepositoryProvider._({
    required BuiltinBridgesRepositoryFamily super.from,
    required MoatService super.argument,
  }) : super(
         retry: null,
         name: r'builtinBridgesRepositoryProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$builtinBridgesRepositoryHash();

  @override
  String toString() {
    return r'builtinBridgesRepositoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BuiltinBridgesRepository create() => BuiltinBridgesRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BuiltinBridgesRepositoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$builtinBridgesRepositoryHash() =>
    r'b06ff04774d6d5b0aa7c4f93469ca514536ad85e';

final class BuiltinBridgesRepositoryFamily extends $Family
    with
        $ClassFamilyOverride<
          BuiltinBridgesRepository,
          void,
          void,
          void,
          MoatService
        > {
  const BuiltinBridgesRepositoryFamily._()
    : super(
        retry: null,
        name: r'builtinBridgesRepositoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  BuiltinBridgesRepositoryProvider call(MoatService service) =>
      BuiltinBridgesRepositoryProvider._(argument: service, from: this);

  @override
  String toString() => r'builtinBridgesRepositoryProvider';
}

abstract class _$BuiltinBridgesRepository extends $Notifier<void> {
  late final _$args = ref.$arg as MoatService;
  MoatService get service => _$args;

  void build(MoatService service);
  @$mustCallSuper
  @override
  void runBuild() {
    build(_$args);
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
