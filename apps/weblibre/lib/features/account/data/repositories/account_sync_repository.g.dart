// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_sync_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All write methods on this repository require the user to be signed in.
/// Callers MUST gate on `ref.watch(accountSyncRepositoryProvider) != null`
/// (or the equivalent `AccountAuthState.isSignedIn` check) before invoking
/// `storeDocument`, `listDocuments`, `fetchDocument`, `deleteDocument`, or
/// `updateLabel`. Calling them on a signed-out instance throws
/// [StateError]; the repository deliberately doesn't fail silently because
/// silent no-ops would hide UI bugs (a "Store" button that does nothing).

@ProviderFor(AccountSyncRepository)
final accountSyncRepositoryProvider = AccountSyncRepositoryProvider._();

/// All write methods on this repository require the user to be signed in.
/// Callers MUST gate on `ref.watch(accountSyncRepositoryProvider) != null`
/// (or the equivalent `AccountAuthState.isSignedIn` check) before invoking
/// `storeDocument`, `listDocuments`, `fetchDocument`, `deleteDocument`, or
/// `updateLabel`. Calling them on a signed-out instance throws
/// [StateError]; the repository deliberately doesn't fail silently because
/// silent no-ops would hide UI bugs (a "Store" button that does nothing).
final class AccountSyncRepositoryProvider
    extends $NotifierProvider<AccountSyncRepository, SupabaseClient?> {
  /// All write methods on this repository require the user to be signed in.
  /// Callers MUST gate on `ref.watch(accountSyncRepositoryProvider) != null`
  /// (or the equivalent `AccountAuthState.isSignedIn` check) before invoking
  /// `storeDocument`, `listDocuments`, `fetchDocument`, `deleteDocument`, or
  /// `updateLabel`. Calling them on a signed-out instance throws
  /// [StateError]; the repository deliberately doesn't fail silently because
  /// silent no-ops would hide UI bugs (a "Store" button that does nothing).
  AccountSyncRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountSyncRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountSyncRepositoryHash();

  @$internal
  @override
  AccountSyncRepository create() => AccountSyncRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient?>(value),
    );
  }
}

String _$accountSyncRepositoryHash() =>
    r'ce558b699974edce2ca06b3990cf09c245d09126';

/// All write methods on this repository require the user to be signed in.
/// Callers MUST gate on `ref.watch(accountSyncRepositoryProvider) != null`
/// (or the equivalent `AccountAuthState.isSignedIn` check) before invoking
/// `storeDocument`, `listDocuments`, `fetchDocument`, `deleteDocument`, or
/// `updateLabel`. Calling them on a signed-out instance throws
/// [StateError]; the repository deliberately doesn't fail silently because
/// silent no-ops would hide UI bugs (a "Store" button that does nothing).

abstract class _$AccountSyncRepository extends $Notifier<SupabaseClient?> {
  SupabaseClient? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SupabaseClient?, SupabaseClient?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SupabaseClient?, SupabaseClient?>,
              SupabaseClient?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
