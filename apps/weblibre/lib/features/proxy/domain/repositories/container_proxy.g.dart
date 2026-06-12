// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_proxy.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ContainerProxyRepository)
final containerProxyRepositoryProvider = ContainerProxyRepositoryProvider._();

final class ContainerProxyRepositoryProvider
    extends $NotifierProvider<ContainerProxyRepository, void> {
  ContainerProxyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerProxyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerProxyRepositoryHash();

  @$internal
  @override
  ContainerProxyRepository create() => ContainerProxyRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$containerProxyRepositoryHash() =>
    r'9201bb0cdda570d38adc5fc16d1c7719f3d719a2';

abstract class _$ContainerProxyRepository extends $Notifier<void> {
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
