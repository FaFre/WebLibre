// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(topSiteDatabase)
final topSiteDatabaseProvider = TopSiteDatabaseProvider._();

final class TopSiteDatabaseProvider
    extends
        $FunctionalProvider<TopSiteDatabase, TopSiteDatabase, TopSiteDatabase>
    with $Provider<TopSiteDatabase> {
  TopSiteDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'topSiteDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$topSiteDatabaseHash();

  @$internal
  @override
  $ProviderElement<TopSiteDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TopSiteDatabase create(Ref ref) {
    return topSiteDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TopSiteDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TopSiteDatabase>(value),
    );
  }
}

String _$topSiteDatabaseHash() => r'bee041ef1b144ce63c38080b2534e4109399fa6f';
