// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_persisted_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AccountPersistedDataCWProxy {
  AccountPersistedData session(PersistedSession? session);

  AccountPersistedData userId(String? userId);

  AccountPersistedData email(String? email);

  AccountPersistedData displayName(String? displayName);

  AccountPersistedData pendingCodeVerifier(String? pendingCodeVerifier);

  AccountPersistedData syncKey(String? syncKey);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `AccountPersistedData(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AccountPersistedData(...).copyWith(id: 12, name: "My name")
  /// ```
  AccountPersistedData call({
    PersistedSession? session,
    String? userId,
    String? email,
    String? displayName,
    String? pendingCodeVerifier,
    String? syncKey,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfAccountPersistedData.copyWith(...)` or call `instanceOfAccountPersistedData.copyWith.fieldName(value)` for a single field.
class _$AccountPersistedDataCWProxyImpl
    implements _$AccountPersistedDataCWProxy {
  const _$AccountPersistedDataCWProxyImpl(this._value);

  final AccountPersistedData _value;

  @override
  AccountPersistedData session(PersistedSession? session) =>
      call(session: session);

  @override
  AccountPersistedData userId(String? userId) => call(userId: userId);

  @override
  AccountPersistedData email(String? email) => call(email: email);

  @override
  AccountPersistedData displayName(String? displayName) =>
      call(displayName: displayName);

  @override
  AccountPersistedData pendingCodeVerifier(String? pendingCodeVerifier) =>
      call(pendingCodeVerifier: pendingCodeVerifier);

  @override
  AccountPersistedData syncKey(String? syncKey) => call(syncKey: syncKey);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `AccountPersistedData(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AccountPersistedData(...).copyWith(id: 12, name: "My name")
  /// ```
  AccountPersistedData call({
    Object? session = const $CopyWithPlaceholder(),
    Object? userId = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? pendingCodeVerifier = const $CopyWithPlaceholder(),
    Object? syncKey = const $CopyWithPlaceholder(),
  }) {
    return AccountPersistedData(
      session: session == const $CopyWithPlaceholder()
          ? _value.session
          // ignore: cast_nullable_to_non_nullable
          : session as PersistedSession?,
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as String?,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
      pendingCodeVerifier: pendingCodeVerifier == const $CopyWithPlaceholder()
          ? _value.pendingCodeVerifier
          // ignore: cast_nullable_to_non_nullable
          : pendingCodeVerifier as String?,
      syncKey: syncKey == const $CopyWithPlaceholder()
          ? _value.syncKey
          // ignore: cast_nullable_to_non_nullable
          : syncKey as String?,
    );
  }
}

extension $AccountPersistedDataCopyWith on AccountPersistedData {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfAccountPersistedData.copyWith(...)` or `instanceOfAccountPersistedData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AccountPersistedDataCWProxy get copyWith =>
      _$AccountPersistedDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountPersistedData _$AccountPersistedDataFromJson(
  Map<String, dynamic> json,
) => AccountPersistedData(
  session: json['session'] == null
      ? null
      : PersistedSession.fromJson(json['session'] as Map<String, dynamic>),
  userId: json['userId'] as String?,
  email: json['email'] as String?,
  displayName: json['displayName'] as String?,
  pendingCodeVerifier: json['pendingCodeVerifier'] as String?,
  syncKey: json['syncKey'] as String?,
);

Map<String, dynamic> _$AccountPersistedDataToJson(
  AccountPersistedData instance,
) => <String, dynamic>{
  'session': instance.session?.toJson(),
  'userId': instance.userId,
  'email': instance.email,
  'displayName': instance.displayName,
  'pendingCodeVerifier': instance.pendingCodeVerifier,
  'syncKey': instance.syncKey,
};
