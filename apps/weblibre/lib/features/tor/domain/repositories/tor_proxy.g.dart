// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tor_proxy.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TorProxyRepository)
final torProxyRepositoryProvider = TorProxyRepositoryProvider._();

final class TorProxyRepositoryProvider
    extends $NotifierProvider<TorProxyRepository, void> {
  TorProxyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'torProxyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$torProxyRepositoryHash();

  @$internal
  @override
  TorProxyRepository create() => TorProxyRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$torProxyRepositoryHash() =>
    r'83c2976750f3f7907274b1ae4f926cd1de89be83';

abstract class _$TorProxyRepository extends $Notifier<void> {
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
