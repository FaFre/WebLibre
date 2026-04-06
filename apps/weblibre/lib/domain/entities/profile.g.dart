// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProfileCWProxy {
  Profile name(String name);

  Profile authSettings(AuthSettings? authSettings);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Profile(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Profile(...).copyWith(id: 12, name: "My name")
  /// ```
  Profile call({String name, AuthSettings? authSettings});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfProfile.copyWith(...)` or call `instanceOfProfile.copyWith.fieldName(value)` for a single field.
class _$ProfileCWProxyImpl implements _$ProfileCWProxy {
  const _$ProfileCWProxyImpl(this._value);

  final Profile _value;

  @override
  Profile name(String name) => call(name: name);

  @override
  Profile authSettings(AuthSettings? authSettings) =>
      call(authSettings: authSettings);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Profile(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Profile(...).copyWith(id: 12, name: "My name")
  /// ```
  Profile call({
    Object? name = const $CopyWithPlaceholder(),
    Object? authSettings = const $CopyWithPlaceholder(),
  }) {
    return Profile(
      id: _value.id,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      authSettings: authSettings == const $CopyWithPlaceholder()
          ? _value.authSettings
          // ignore: cast_nullable_to_non_nullable
          : authSettings as AuthSettings?,
    );
  }
}

extension $ProfileCopyWith on Profile {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfProfile.copyWith(...)` or `instanceOfProfile.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProfileCWProxy get copyWith => _$ProfileCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
  id: json['id'] as String,
  name: json['name'] as String,
  authSettings: json['authSettings'] == null
      ? null
      : AuthSettings.fromJson(json['authSettings'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'authSettings': instance.authSettings.toJson(),
};
