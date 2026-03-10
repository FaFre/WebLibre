// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_site_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TopSiteRepository)
final topSiteRepositoryProvider = TopSiteRepositoryProvider._();

final class TopSiteRepositoryProvider
    extends $NotifierProvider<TopSiteRepository, void> {
  TopSiteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'topSiteRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$topSiteRepositoryHash();

  @$internal
  @override
  TopSiteRepository create() => TopSiteRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$topSiteRepositoryHash() => r'6e954c84ed5916ac0b5a9e251d43cbe1e9ed15c3';

abstract class _$TopSiteRepository extends $Notifier<void> {
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
