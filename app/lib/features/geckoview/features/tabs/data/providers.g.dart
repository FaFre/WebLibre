// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tabDatabase)
const tabDatabaseProvider = TabDatabaseProvider._();

final class TabDatabaseProvider
    extends $FunctionalProvider<TabDatabase, TabDatabase, TabDatabase>
    with $Provider<TabDatabase> {
  const TabDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabDatabaseHash();

  @$internal
  @override
  $ProviderElement<TabDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TabDatabase create(Ref ref) {
    return tabDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TabDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TabDatabase>(value),
    );
  }
}

String _$tabDatabaseHash() => r'422bd4789296dc271fabbd5906f2e2ab16bccaa3';
