// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AuthSettingsCWProxy {
  AuthSettings authenticationRequired(bool authenticationRequired);

  AuthSettings autoLockMode(AutoLockMode autoLockMode);

  AuthSettings timeout(Duration timeout);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `AuthSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AuthSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  AuthSettings call({
    bool authenticationRequired,
    AutoLockMode autoLockMode,
    Duration timeout,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfAuthSettings.copyWith(...)` or call `instanceOfAuthSettings.copyWith.fieldName(value)` for a single field.
class _$AuthSettingsCWProxyImpl implements _$AuthSettingsCWProxy {
  const _$AuthSettingsCWProxyImpl(this._value);

  final AuthSettings _value;

  @override
  AuthSettings authenticationRequired(bool authenticationRequired) =>
      call(authenticationRequired: authenticationRequired);

  @override
  AuthSettings autoLockMode(AutoLockMode autoLockMode) =>
      call(autoLockMode: autoLockMode);

  @override
  AuthSettings timeout(Duration timeout) => call(timeout: timeout);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `AuthSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AuthSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  AuthSettings call({
    Object? authenticationRequired = const $CopyWithPlaceholder(),
    Object? autoLockMode = const $CopyWithPlaceholder(),
    Object? timeout = const $CopyWithPlaceholder(),
  }) {
    return AuthSettings(
      authenticationRequired:
          authenticationRequired == const $CopyWithPlaceholder() ||
              authenticationRequired == null
          ? _value.authenticationRequired
          // ignore: cast_nullable_to_non_nullable
          : authenticationRequired as bool,
      autoLockMode:
          autoLockMode == const $CopyWithPlaceholder() || autoLockMode == null
          ? _value.autoLockMode
          // ignore: cast_nullable_to_non_nullable
          : autoLockMode as AutoLockMode,
      timeout: timeout == const $CopyWithPlaceholder() || timeout == null
          ? _value.timeout
          // ignore: cast_nullable_to_non_nullable
          : timeout as Duration,
    );
  }
}

extension $AuthSettingsCopyWith on AuthSettings {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfAuthSettings.copyWith(...)` or `instanceOfAuthSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AuthSettingsCWProxy get copyWith => _$AuthSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthSettings _$AuthSettingsFromJson(Map<String, dynamic> json) => AuthSettings(
  authenticationRequired: json['authenticationRequired'] as bool,
  autoLockMode: $enumDecode(_$AutoLockModeEnumMap, json['autoLockMode']),
  timeout: Duration(microseconds: (json['timeout'] as num).toInt()),
);

Map<String, dynamic> _$AuthSettingsToJson(AuthSettings instance) =>
    <String, dynamic>{
      'authenticationRequired': instance.authenticationRequired,
      'autoLockMode': _$AutoLockModeEnumMap[instance.autoLockMode]!,
      'timeout': instance.timeout.inMicroseconds,
    };

const _$AutoLockModeEnumMap = {
  AutoLockMode.background: 'background',
  AutoLockMode.timeout: 'timeout',
};
