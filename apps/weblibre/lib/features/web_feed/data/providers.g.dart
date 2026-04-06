// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(feedDatabase)
final feedDatabaseProvider = FeedDatabaseProvider._();

final class FeedDatabaseProvider
    extends $FunctionalProvider<FeedDatabase, FeedDatabase, FeedDatabase>
    with $Provider<FeedDatabase> {
  FeedDatabaseProvider._()
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

String _$feedDatabaseHash() => r'1ecae87a3de5b2d43136fdb73411727b0b217621';
