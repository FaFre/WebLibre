// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_auth.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AccountAuthRepository)
final accountAuthRepositoryProvider = AccountAuthRepositoryProvider._();

final class AccountAuthRepositoryProvider
    extends $AsyncNotifierProvider<AccountAuthRepository, AccountAuthState> {
  AccountAuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountAuthRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountAuthRepositoryHash();

  @$internal
  @override
  AccountAuthRepository create() => AccountAuthRepository();
}

String _$accountAuthRepositoryHash() =>
    r'5e36dc4e74f892c83cfc9c4193412566cb077cc8';

abstract class _$AccountAuthRepository
    extends $AsyncNotifier<AccountAuthState> {
  FutureOr<AccountAuthState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AccountAuthState>, AccountAuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AccountAuthState>, AccountAuthState>,
              AsyncValue<AccountAuthState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
