// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_cleaner_catalog_file.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UrlCleanerCatalogFileService)
final urlCleanerCatalogFileServiceProvider =
    UrlCleanerCatalogFileServiceProvider._();

final class UrlCleanerCatalogFileServiceProvider
    extends $NotifierProvider<UrlCleanerCatalogFileService, void> {
  UrlCleanerCatalogFileServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'urlCleanerCatalogFileServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$urlCleanerCatalogFileServiceHash();

  @$internal
  @override
  UrlCleanerCatalogFileService create() => UrlCleanerCatalogFileService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$urlCleanerCatalogFileServiceHash() =>
    r'a6ccb9f2b2225b088d109712e9fbb719b394d93b';

abstract class _$UrlCleanerCatalogFileService extends $Notifier<void> {
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
