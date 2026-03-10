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

String _$topSiteRepositoryHash() => r'43c0495dfb3044dc9bb2f420524b45afb5735a0b';

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
