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

String _$torProxyServiceHash() => r'69240e5e8c5f6bb6aac1fd6c1c1215753607e34a';

abstract class _$TorProxyService extends $StreamNotifier<TorStatus> {
  Stream<TorStatus> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TorStatus>, TorStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TorStatus>, TorStatus>,
              AsyncValue<TorStatus>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
