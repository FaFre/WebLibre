// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tor_proxy.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TorProxyService)
const torProxyServiceProvider = TorProxyServiceProvider._();

final class TorProxyServiceProvider
    extends $AsyncNotifierProvider<TorProxyService, int?> {
  const TorProxyServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'torProxyServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$torProxyServiceHash();

  @$internal
  @override
  TorProxyService create() => TorProxyService();
}

String _$torProxyServiceHash() => r'c63adf96d7b0a865917b8d902071a0b3ae4dfcc6';

abstract class _$TorProxyService extends $AsyncNotifier<int?> {
  FutureOr<int?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<int?>, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int?>, int?>,
              AsyncValue<int?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
