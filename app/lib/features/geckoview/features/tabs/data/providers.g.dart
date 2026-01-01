// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tabDatabase)
final tabDatabaseProvider = TabDatabaseProvider._();

final class TabDatabaseProvider
    extends $FunctionalProvider<TabDatabase, TabDatabase, TabDatabase>
    with $Provider<TabDatabase> {
  TabDatabaseProvider._()
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

String _$tabDatabaseHash() => r'337dbcf30bd57dcee409aec0aa93f1f6f2783368';
