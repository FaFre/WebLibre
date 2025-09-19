// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ContainerAuthSettingsCWProxy {
  ContainerAuthSettings authenticationRequired(bool authenticationRequired);

  ContainerAuthSettings lockOnAppBackground(bool lockOnAppBackground);

  ContainerAuthSettings lockTimeout(Duration? lockTimeout);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ContainerAuthSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ContainerAuthSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  ContainerAuthSettings call({
    bool authenticationRequired,
    bool lockOnAppBackground,
    Duration? lockTimeout,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfContainerAuthSettings.copyWith(...)` or call `instanceOfContainerAuthSettings.copyWith.fieldName(value)` for a single field.
class _$ContainerAuthSettingsCWProxyImpl
    implements _$ContainerAuthSettingsCWProxy {
  const _$ContainerAuthSettingsCWProxyImpl(this._value);

  final ContainerAuthSettings _value;

  @override
  ContainerAuthSettings authenticationRequired(bool authenticationRequired) =>
      call(authenticationRequired: authenticationRequired);

  @override
  ContainerAuthSettings lockOnAppBackground(bool lockOnAppBackground) =>
      call(lockOnAppBackground: lockOnAppBackground);

  @override
  ContainerAuthSettings lockTimeout(Duration? lockTimeout) =>
      call(lockTimeout: lockTimeout);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ContainerAuthSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ContainerAuthSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  ContainerAuthSettings call({
    Object? authenticationRequired = const $CopyWithPlaceholder(),
    Object? lockOnAppBackground = const $CopyWithPlaceholder(),
    Object? lockTimeout = const $CopyWithPlaceholder(),
  }) {
    return ContainerAuthSettings(
      authenticationRequired:
          authenticationRequired == const $CopyWithPlaceholder() ||
              authenticationRequired == null
          ? _value.authenticationRequired
          // ignore: cast_nullable_to_non_nullable
          : authenticationRequired as bool,
      lockOnAppBackground:
          lockOnAppBackground == const $CopyWithPlaceholder() ||
              lockOnAppBackground == null
          ? _value.lockOnAppBackground
          // ignore: cast_nullable_to_non_nullable
          : lockOnAppBackground as bool,
      lockTimeout: lockTimeout == const $CopyWithPlaceholder()
          ? _value.lockTimeout
          // ignore: cast_nullable_to_non_nullable
          : lockTimeout as Duration?,
    );
  }
}

extension $ContainerAuthSettingsCopyWith on ContainerAuthSettings {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfContainerAuthSettings.copyWith(...)` or `instanceOfContainerAuthSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ContainerAuthSettingsCWProxy get copyWith =>
      _$ContainerAuthSettingsCWProxyImpl(this);
}

abstract class _$ContainerMetadataCWProxy {
  ContainerMetadata iconData(IconData? iconData);

  ContainerMetadata contextualIdentity(String? contextualIdentity);

  ContainerMetadata authSettings(ContainerAuthSettings authSettings);

  ContainerMetadata useProxy(bool useProxy);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ContainerMetadata(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ContainerMetadata(...).copyWith(id: 12, name: "My name")
  /// ```
  ContainerMetadata call({
    IconData? iconData,
    String? contextualIdentity,
    ContainerAuthSettings authSettings,
    bool useProxy,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfContainerMetadata.copyWith(...)` or call `instanceOfContainerMetadata.copyWith.fieldName(value)` for a single field.
class _$ContainerMetadataCWProxyImpl implements _$ContainerMetadataCWProxy {
  const _$ContainerMetadataCWProxyImpl(this._value);

  final ContainerMetadata _value;

  @override
  ContainerMetadata iconData(IconData? iconData) => call(iconData: iconData);

  @override
  ContainerMetadata contextualIdentity(String? contextualIdentity) =>
      call(contextualIdentity: contextualIdentity);

  @override
  ContainerMetadata authSettings(ContainerAuthSettings authSettings) =>
      call(authSettings: authSettings);

  @override
  ContainerMetadata useProxy(bool useProxy) => call(useProxy: useProxy);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ContainerMetadata(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ContainerMetadata(...).copyWith(id: 12, name: "My name")
  /// ```
  ContainerMetadata call({
    Object? iconData = const $CopyWithPlaceholder(),
    Object? contextualIdentity = const $CopyWithPlaceholder(),
    Object? authSettings = const $CopyWithPlaceholder(),
    Object? useProxy = const $CopyWithPlaceholder(),
  }) {
    return ContainerMetadata(
      iconData: iconData == const $CopyWithPlaceholder()
          ? _value.iconData
          // ignore: cast_nullable_to_non_nullable
          : iconData as IconData?,
      contextualIdentity: contextualIdentity == const $CopyWithPlaceholder()
          ? _value.contextualIdentity
          // ignore: cast_nullable_to_non_nullable
          : contextualIdentity as String?,
      authSettings:
          authSettings == const $CopyWithPlaceholder() || authSettings == null
          ? _value.authSettings
          // ignore: cast_nullable_to_non_nullable
          : authSettings as ContainerAuthSettings,
      useProxy: useProxy == const $CopyWithPlaceholder() || useProxy == null
          ? _value.useProxy
          // ignore: cast_nullable_to_non_nullable
          : useProxy as bool,
    );
  }
}

extension $ContainerMetadataCopyWith on ContainerMetadata {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfContainerMetadata.copyWith(...)` or `instanceOfContainerMetadata.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ContainerMetadataCWProxy get copyWith =>
      _$ContainerMetadataCWProxyImpl(this);
}

abstract class _$ContainerDataCWProxy {
  ContainerData id(String id);

  ContainerData name(String? name);

  ContainerData color(Color color);

  ContainerData metadata(ContainerMetadata? metadata);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ContainerData(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ContainerData(...).copyWith(id: 12, name: "My name")
  /// ```
  ContainerData call({
    String id,
    String? name,
    Color color,
    ContainerMetadata? metadata,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfContainerData.copyWith(...)` or call `instanceOfContainerData.copyWith.fieldName(value)` for a single field.
class _$ContainerDataCWProxyImpl implements _$ContainerDataCWProxy {
  const _$ContainerDataCWProxyImpl(this._value);

  final ContainerData _value;

  @override
  ContainerData id(String id) => call(id: id);

  @override
  ContainerData name(String? name) => call(name: name);

  @override
  ContainerData color(Color color) => call(color: color);

  @override
  ContainerData metadata(ContainerMetadata? metadata) =>
      call(metadata: metadata);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ContainerData(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ContainerData(...).copyWith(id: 12, name: "My name")
  /// ```
  ContainerData call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
  }) {
    return ContainerData(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      color: color == const $CopyWithPlaceholder() || color == null
          ? _value.color
          // ignore: cast_nullable_to_non_nullable
          : color as Color,
      metadata: metadata == const $CopyWithPlaceholder()
          ? _value.metadata
          // ignore: cast_nullable_to_non_nullable
          : metadata as ContainerMetadata?,
    );
  }
}

extension $ContainerDataCopyWith on ContainerData {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfContainerData.copyWith(...)` or `instanceOfContainerData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ContainerDataCWProxy get copyWith => _$ContainerDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContainerAuthSettings _$ContainerAuthSettingsFromJson(
  Map<String, dynamic> json,
) => ContainerAuthSettings(
  authenticationRequired: json['authenticationRequired'] as bool,
  lockOnAppBackground: json['lockOnAppBackground'] as bool,
  lockTimeout: json['lockTimeout'] == null
      ? null
      : Duration(microseconds: (json['lockTimeout'] as num).toInt()),
);

Map<String, dynamic> _$ContainerAuthSettingsToJson(
  ContainerAuthSettings instance,
) => <String, dynamic>{
  'authenticationRequired': instance.authenticationRequired,
  'lockOnAppBackground': instance.lockOnAppBackground,
  'lockTimeout': instance.lockTimeout?.inMicroseconds,
};

ContainerMetadata _$ContainerMetadataFromJson(Map<String, dynamic> json) =>
    ContainerMetadata.withDefaults(
      iconData: _$JsonConverterFromJson<Map<String, dynamic>, IconData>(
        json['iconData'],
        const IconDataJsonConverter().fromJson,
      ),
      contextualIdentity: json['contextualIdentity'] as String?,
      authSettings: json['authSettings'] == null
          ? null
          : ContainerAuthSettings.fromJson(
              json['authSettings'] as Map<String, dynamic>,
            ),
      useProxy: json['useProxy'] as bool? ?? false,
    );

Map<String, dynamic> _$ContainerMetadataToJson(ContainerMetadata instance) =>
    <String, dynamic>{
      'iconData': _$JsonConverterToJson<Map<String, dynamic>, IconData>(
        instance.iconData,
        const IconDataJsonConverter().toJson,
      ),
      'contextualIdentity': instance.contextualIdentity,
      'authSettings': instance.authSettings.toJson(),
      'useProxy': instance.useProxy,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
