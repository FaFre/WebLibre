// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_auth_state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AccountAuthStateCWProxy {
  AccountAuthState status(AccountAuthStatus status);

  AccountAuthState email(String? email);

  AccountAuthState displayName(String? displayName);

  AccountAuthState userId(String? userId);

  AccountAuthState lastError(String? lastError);

  AccountAuthState syncKey(String? syncKey);

  AccountAuthState client(SupabaseClient? client);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `AccountAuthState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AccountAuthState(...).copyWith(id: 12, name: "My name")
  /// ```
  AccountAuthState call({
    AccountAuthStatus status,
    String? email,
    String? displayName,
    String? userId,
    String? lastError,
    String? syncKey,
    SupabaseClient? client,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfAccountAuthState.copyWith(...)` or call `instanceOfAccountAuthState.copyWith.fieldName(value)` for a single field.
class _$AccountAuthStateCWProxyImpl implements _$AccountAuthStateCWProxy {
  const _$AccountAuthStateCWProxyImpl(this._value);

  final AccountAuthState _value;

  @override
  AccountAuthState status(AccountAuthStatus status) => call(status: status);

  @override
  AccountAuthState email(String? email) => call(email: email);

  @override
  AccountAuthState displayName(String? displayName) =>
      call(displayName: displayName);

  @override
  AccountAuthState userId(String? userId) => call(userId: userId);

  @override
  AccountAuthState lastError(String? lastError) => call(lastError: lastError);

  @override
  AccountAuthState syncKey(String? syncKey) => call(syncKey: syncKey);

  @override
  AccountAuthState client(SupabaseClient? client) => call(client: client);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `AccountAuthState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AccountAuthState(...).copyWith(id: 12, name: "My name")
  /// ```
  AccountAuthState call({
    Object? status = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? userId = const $CopyWithPlaceholder(),
    Object? lastError = const $CopyWithPlaceholder(),
    Object? syncKey = const $CopyWithPlaceholder(),
    Object? client = const $CopyWithPlaceholder(),
  }) {
    return AccountAuthState(
      status: status == const $CopyWithPlaceholder() || status == null
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as AccountAuthStatus,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as String?,
      lastError: lastError == const $CopyWithPlaceholder()
          ? _value.lastError
          // ignore: cast_nullable_to_non_nullable
          : lastError as String?,
      syncKey: syncKey == const $CopyWithPlaceholder()
          ? _value.syncKey
          // ignore: cast_nullable_to_non_nullable
          : syncKey as String?,
      client: client == const $CopyWithPlaceholder()
          ? _value.client
          // ignore: cast_nullable_to_non_nullable
          : client as SupabaseClient?,
    );
  }
}

extension $AccountAuthStateCopyWith on AccountAuthState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfAccountAuthState.copyWith(...)` or `instanceOfAccountAuthState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AccountAuthStateCWProxy get copyWith => _$AccountAuthStateCWProxyImpl(this);
}
