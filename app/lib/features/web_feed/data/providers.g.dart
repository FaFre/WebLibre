// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(feedDatabase)
const feedDatabaseProvider = FeedDatabaseProvider._();

final class FeedDatabaseProvider
    extends $FunctionalProvider<FeedDatabase, FeedDatabase, FeedDatabase>
    with $Provider<FeedDatabase> {
  const FeedDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedDatabaseHash();

  @$internal
  @override
  $ProviderElement<FeedDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedDatabase create(Ref ref) {
    return feedDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedDatabase>(value),
    );
  }
}

String _$feedDatabaseHash() => r'c3b20e867da5af6e92d1e8c1efa96b79988837a1';
