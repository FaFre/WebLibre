// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_cleaner_catalog_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UrlCleanerCatalogService)
final urlCleanerCatalogServiceProvider = UrlCleanerCatalogServiceProvider._();

final class UrlCleanerCatalogServiceProvider
    extends
        $AsyncNotifierProvider<UrlCleanerCatalogService, List<UrlCleanerRule>> {
  UrlCleanerCatalogServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'urlCleanerCatalogServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$urlCleanerCatalogServiceHash();

  @$internal
  @override
  UrlCleanerCatalogService create() => UrlCleanerCatalogService();
}

String _$urlCleanerCatalogServiceHash() =>
    r'b4a9e0a5b1f91c7daf6e0463f5b96e2a6e0ef307';

abstract class _$UrlCleanerCatalogService
    extends $AsyncNotifier<List<UrlCleanerRule>> {
  FutureOr<List<UrlCleanerRule>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<UrlCleanerRule>>, List<UrlCleanerRule>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<UrlCleanerRule>>,
                List<UrlCleanerRule>
              >,
              AsyncValue<List<UrlCleanerRule>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
