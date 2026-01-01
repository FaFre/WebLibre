// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userDatabase)
final userDatabaseProvider = UserDatabaseProvider._();

final class UserDatabaseProvider
    extends $FunctionalProvider<UserDatabase, UserDatabase, UserDatabase>
    with $Provider<UserDatabase> {
  UserDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userDatabaseHash();

  @$internal
  @override
  $ProviderElement<UserDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserDatabase create(Ref ref) {
    return userDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserDatabase>(value),
    );
  }
}

String _$userDatabaseHash() => r'8cc40197f9dbb85ccd8263984218753d3690954b';

@ProviderFor(riverpodDatabaseStorage)
final riverpodDatabaseStorageProvider = RiverpodDatabaseStorageProvider._();

final class RiverpodDatabaseStorageProvider
    extends
        $FunctionalProvider<
          Storage<String, String>,
          Storage<String, String>,
          Storage<String, String>
        >
    with $Provider<Storage<String, String>> {
  RiverpodDatabaseStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'riverpodDatabaseStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$riverpodDatabaseStorageHash();

  @$internal
  @override
  $ProviderElement<Storage<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Storage<String, String> create(Ref ref) {
    return riverpodDatabaseStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Storage<String, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Storage<String, String>>(value),
    );
  }
}

String _$riverpodDatabaseStorageHash() =>
    r'e60613538dcb1f9cf48d87c029d8493335a5c3e8';
