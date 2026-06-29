// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'popular_sites.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PopularSitesRepository)
final popularSitesRepositoryProvider = PopularSitesRepositoryProvider._();

final class PopularSitesRepositoryProvider
    extends $NotifierProvider<PopularSitesRepository, void> {
  PopularSitesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'popularSitesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$popularSitesRepositoryHash();

  @$internal
  @override
  PopularSitesRepository create() => PopularSitesRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$popularSitesRepositoryHash() =>
    r'9825dc634b2ae9ea48a33eac8387a3e138c17b9f';

abstract class _$PopularSitesRepository extends $Notifier<void> {
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
