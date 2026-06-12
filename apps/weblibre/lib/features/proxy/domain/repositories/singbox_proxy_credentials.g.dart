// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'singbox_proxy_credentials.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SingboxProxyCredentialsRepository)
final singboxProxyCredentialsRepositoryProvider =
    SingboxProxyCredentialsRepositoryProvider._();

final class SingboxProxyCredentialsRepositoryProvider
    extends $NotifierProvider<SingboxProxyCredentialsRepository, void> {
  SingboxProxyCredentialsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'singboxProxyCredentialsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$singboxProxyCredentialsRepositoryHash();

  @$internal
  @override
  SingboxProxyCredentialsRepository create() =>
      SingboxProxyCredentialsRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$singboxProxyCredentialsRepositoryHash() =>
    r'b4e11b001ccccfbf26417963adf6cb81e1b1e69f';

abstract class _$SingboxProxyCredentialsRepository extends $Notifier<void> {
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
