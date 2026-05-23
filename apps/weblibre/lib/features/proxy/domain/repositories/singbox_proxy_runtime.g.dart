// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'singbox_proxy_runtime.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(singboxProxyClient)
final singboxProxyClientProvider = SingboxProxyClientProvider._();

final class SingboxProxyClientProvider
    extends
        $FunctionalProvider<
          SingboxProxyClient,
          SingboxProxyClient,
          SingboxProxyClient
        >
    with $Provider<SingboxProxyClient> {
  SingboxProxyClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'singboxProxyClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$singboxProxyClientHash();

  @$internal
  @override
  $ProviderElement<SingboxProxyClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SingboxProxyClient create(Ref ref) {
    return singboxProxyClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SingboxProxyClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SingboxProxyClient>(value),
    );
  }
}

String _$singboxProxyClientHash() =>
    r'3e56b277667e92a2d4941fd084dddd0ff25afd52';

@ProviderFor(SingboxProxyRuntimeRepository)
final singboxProxyRuntimeRepositoryProvider =
    SingboxProxyRuntimeRepositoryProvider._();

final class SingboxProxyRuntimeRepositoryProvider
    extends
        $AsyncNotifierProvider<
          SingboxProxyRuntimeRepository,
          SingboxProxyRuntimeState
        > {
  SingboxProxyRuntimeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'singboxProxyRuntimeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$singboxProxyRuntimeRepositoryHash();

  @$internal
  @override
  SingboxProxyRuntimeRepository create() => SingboxProxyRuntimeRepository();
}

String _$singboxProxyRuntimeRepositoryHash() =>
    r'bb84ab57abd3b7261105da85d3e047cef1b31a44';

abstract class _$SingboxProxyRuntimeRepository
    extends $AsyncNotifier<SingboxProxyRuntimeState> {
  FutureOr<SingboxProxyRuntimeState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<SingboxProxyRuntimeState>,
              SingboxProxyRuntimeState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SingboxProxyRuntimeState>,
                SingboxProxyRuntimeState
              >,
              AsyncValue<SingboxProxyRuntimeState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
