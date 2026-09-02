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

String _$torProxyServiceHash() => r'0339760d29c6b5a1c78ae0fd0df8219d6322be9a';

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
