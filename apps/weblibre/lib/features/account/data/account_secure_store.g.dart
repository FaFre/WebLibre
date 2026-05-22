// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_secure_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountSecureStore)
final accountSecureStoreProvider = AccountSecureStoreProvider._();

final class AccountSecureStoreProvider
    extends
        $FunctionalProvider<
          AccountSecureStore,
          AccountSecureStore,
          AccountSecureStore
        >
    with $Provider<AccountSecureStore> {
  AccountSecureStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountSecureStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountSecureStoreHash();

  @$internal
  @override
  $ProviderElement<AccountSecureStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountSecureStore create(Ref ref) {
    return accountSecureStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountSecureStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountSecureStore>(value),
    );
  }
}

String _$accountSecureStoreHash() =>
    r'12a2383a575fb8a07a6fc1e8ac4a477c66db7009';
