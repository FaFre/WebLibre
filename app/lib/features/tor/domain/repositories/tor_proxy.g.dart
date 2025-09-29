// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tor_proxy.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TorProxyRepository)
const torProxyRepositoryProvider = TorProxyRepositoryProvider._();

final class TorProxyRepositoryProvider
    extends $NotifierProvider<TorProxyRepository, void> {
  const TorProxyRepositoryProvider._()
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
    r'3bdb83bdb1c5d1bb5d8953878cd587d042d30342';

abstract class _$TorProxyRepository extends $Notifier<void> {
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
