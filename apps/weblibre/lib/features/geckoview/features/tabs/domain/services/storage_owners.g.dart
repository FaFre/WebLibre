// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_owners.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Which container a storage (session context) belongs to, for a page that
/// opens in it with nothing else to say: the page a notification's service
/// worker opens, or the page of a frozen web app window.

@ProviderFor(StorageOwners)
final storageOwnersProvider = StorageOwnersProvider._();

/// Which container a storage (session context) belongs to, for a page that
/// opens in it with nothing else to say: the page a notification's service
/// worker opens, or the page of a frozen web app window.
final class StorageOwnersProvider
    extends $NotifierProvider<StorageOwners, void> {
  /// Which container a storage (session context) belongs to, for a page that
  /// opens in it with nothing else to say: the page a notification's service
  /// worker opens, or the page of a frozen web app window.
  StorageOwnersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageOwnersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageOwnersHash();

  @$internal
  @override
  StorageOwners create() => StorageOwners();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$storageOwnersHash() => r'a08463fde26239a50a0abf4f830c81b46f1f0d69';

/// Which container a storage (session context) belongs to, for a page that
/// opens in it with nothing else to say: the page a notification's service
/// worker opens, or the page of a frozen web app window.

abstract class _$StorageOwners extends $Notifier<void> {
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
