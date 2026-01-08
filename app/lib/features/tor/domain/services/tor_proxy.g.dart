// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tor_proxy.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TorProxyService)
final torProxyServiceProvider = TorProxyServiceProvider._();

final class TorProxyServiceProvider
    extends $StreamNotifierProvider<TorProxyService, TorStatus> {
  TorProxyServiceProvider._()
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

String _$torProxyServiceHash() => r'be69327bdef8feaa2a43bd83f20168988dcdd228';

abstract class _$TorProxyService extends $StreamNotifier<TorStatus> {
  Stream<TorStatus> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TorStatus>, TorStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TorStatus>, TorStatus>,
              AsyncValue<TorStatus>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
