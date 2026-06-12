// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'singbox_proxy_profiles.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SingboxProxyProfilesRepository)
final singboxProxyProfilesRepositoryProvider =
    SingboxProxyProfilesRepositoryProvider._();

final class SingboxProxyProfilesRepositoryProvider
    extends
        $StreamNotifierProvider<
          SingboxProxyProfilesRepository,
          List<ProxyProfile>
        > {
  SingboxProxyProfilesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'singboxProxyProfilesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$singboxProxyProfilesRepositoryHash();

  @$internal
  @override
  SingboxProxyProfilesRepository create() => SingboxProxyProfilesRepository();
}

String _$singboxProxyProfilesRepositoryHash() =>
    r'5250f2aafb7ec621b3b33a53ff5a00874e8a4b12';

abstract class _$SingboxProxyProfilesRepository
    extends $StreamNotifier<List<ProxyProfile>> {
  Stream<List<ProxyProfile>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ProxyProfile>>, List<ProxyProfile>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ProxyProfile>>, List<ProxyProfile>>,
              AsyncValue<List<ProxyProfile>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
