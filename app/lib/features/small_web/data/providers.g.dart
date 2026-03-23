// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(smallWebDatabase)
final smallWebDatabaseProvider = SmallWebDatabaseProvider._();

final class SmallWebDatabaseProvider
    extends
        $FunctionalProvider<
          SmallWebDatabase,
          SmallWebDatabase,
          SmallWebDatabase
        >
    with $Provider<SmallWebDatabase> {
  SmallWebDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'smallWebDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$smallWebDatabaseHash();

  @$internal
  @override
  $ProviderElement<SmallWebDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SmallWebDatabase create(Ref ref) {
    return smallWebDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SmallWebDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SmallWebDatabase>(value),
    );
  }
}

String _$smallWebDatabaseHash() => r'e199e8c1261e8152110fb99f883fed1e550ffdc6';

@ProviderFor(kagiCategories)
final kagiCategoriesProvider = KagiCategoriesProvider._();

final class KagiCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<KagiCategories>,
          KagiCategories,
          FutureOr<KagiCategories>
        >
    with $FutureModifier<KagiCategories>, $FutureProvider<KagiCategories> {
  KagiCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kagiCategoriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kagiCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<KagiCategories> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<KagiCategories> create(Ref ref) {
    return kagiCategories(ref);
  }
}

String _$kagiCategoriesHash() => r'de97daabc1aba5360209e15f1de0e5488435aa54';
