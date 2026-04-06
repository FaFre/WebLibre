// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CacheRepository)
final cacheRepositoryProvider = CacheRepositoryProvider._();

final class CacheRepositoryProvider
    extends $NotifierProvider<CacheRepository, void> {
  CacheRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheRepositoryHash();

  @$internal
  @override
  CacheRepository create() => CacheRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$cacheRepositoryHash() => r'e3cd7461aefe9e034a663169cd81ab7f69c2640e';

abstract class _$CacheRepository extends $Notifier<void> {
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
