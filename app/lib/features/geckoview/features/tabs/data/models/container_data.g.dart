// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ContainerAuthSettingsCWProxy {
  ContainerAuthSettings authenticationRequired(bool authenticationRequired);

  ContainerAuthSettings lockOnAppBackground(bool lockOnAppBackground);

  ContainerAuthSettings lockTimeout(Duration? lockTimeout);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ContainerAuthSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ContainerAuthSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  ContainerAuthSettings call({
    bool authenticationRequired,
    bool lockOnAppBackground,
    Duration? lockTimeout,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfContainerAuthSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfContainerAuthSettings.copyWith.fieldName(...)`
class _$ContainerAuthSettingsCWProxyImpl
    implements _$ContainerAuthSettingsCWProxy {
  const _$ContainerAuthSettingsCWProxyImpl(this._value);

  final ContainerAuthSettings _value;

  @override
  ContainerAuthSettings authenticationRequired(bool authenticationRequired) =>
      this(authenticationRequired: authenticationRequired);

  @override
  ContainerAuthSettings lockOnAppBackground(bool lockOnAppBackground) =>
      this(lockOnAppBackground: lockOnAppBackground);

  @override
  ContainerAuthSettings lockTimeout(Duration? lockTimeout) =>
      this(lockTimeout: lockTimeout);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ContainerAuthSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ContainerAuthSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  ContainerAuthSettings call({
    Object? authenticationRequired = const $CopyWithPlaceholder(),
    Object? lockOnAppBackground = const $CopyWithPlaceholder(),
    Object? lockTimeout = const $CopyWithPlaceholder(),
  }) {
    return ContainerAuthSettings(
      authenticationRequired:
          authenticationRequired == const $CopyWithPlaceholder()
              ? _value.authenticationRequired
              // ignore: cast_nullable_to_non_nullable
              : authenticationRequired as bool,
      lockOnAppBackground:
          lockOnAppBackground == const $CopyWithPlaceholder()
              ? _value.lockOnAppBackground
              // ignore: cast_nullable_to_non_nullable
              : lockOnAppBackground as bool,
      lockTimeout:
          lockTimeout == const $CopyWithPlaceholder()
              ? _value.lockTimeout
              // ignore: cast_nullable_to_non_nullable
              : lockTimeout as Duration?,
    );
  }
}

extension $ContainerAuthSettingsCopyWith on ContainerAuthSettings {
  /// Returns a callable class that can be used as follows: `instanceOfContainerAuthSettings.copyWith(...)` or like so:`instanceOfContainerAuthSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ContainerAuthSettingsCWProxy get copyWith =>
      _$ContainerAuthSettingsCWProxyImpl(this);
}

abstract class _$ContainerMetadataCWProxy {
  ContainerMetadata iconData(IconData? iconData);

  ContainerMetadata contextualIdentity(String? contextualIdentity);

  ContainerMetadata authSettings(ContainerAuthSettings authSettings);

  ContainerMetadata useProxy(bool useProxy);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ContainerMetadata(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ContainerMetadata(...).copyWith(id: 12, name: "My name")
  /// ````
  ContainerMetadata call({
    IconData? iconData,
    String? contextualIdentity,
    ContainerAuthSettings authSettings,
    bool useProxy,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfContainerMetadata.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfContainerMetadata.copyWith.fieldName(...)`
class _$ContainerMetadataCWProxyImpl implements _$ContainerMetadataCWProxy {
  const _$ContainerMetadataCWProxyImpl(this._value);

  final ContainerMetadata _value;

  @override
  ContainerMetadata iconData(IconData? iconData) => this(iconData: iconData);

  @override
  ContainerMetadata contextualIdentity(String? contextualIdentity) =>
      this(contextualIdentity: contextualIdentity);

  @override
  ContainerMetadata authSettings(ContainerAuthSettings authSettings) =>
      this(authSettings: authSettings);

  @override
  ContainerMetadata useProxy(bool useProxy) => this(useProxy: useProxy);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ContainerMetadata(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ContainerMetadata(...).copyWith(id: 12, name: "My name")
  /// ````
  ContainerMetadata call({
    Object? iconData = const $CopyWithPlaceholder(),
    Object? contextualIdentity = const $CopyWithPlaceholder(),
    Object? authSettings = const $CopyWithPlaceholder(),
    Object? useProxy = const $CopyWithPlaceholder(),
  }) {
    return ContainerMetadata(
      iconData:
          iconData == const $CopyWithPlaceholder()
              ? _value.iconData
              // ignore: cast_nullable_to_non_nullable
              : iconData as IconData?,
      contextualIdentity:
          contextualIdentity == const $CopyWithPlaceholder()
              ? _value.contextualIdentity
              // ignore: cast_nullable_to_non_nullable
              : contextualIdentity as String?,
      authSettings:
          authSettings == const $CopyWithPlaceholder()
              ? _value.authSettings
              // ignore: cast_nullable_to_non_nullable
              : authSettings as ContainerAuthSettings,
      useProxy:
          useProxy == const $CopyWithPlaceholder()
              ? _value.useProxy
              // ignore: cast_nullable_to_non_nullable
              : useProxy as bool,
    );
  }
}

extension $ContainerMetadataCopyWith on ContainerMetadata {
  /// Returns a callable class that can be used as follows: `instanceOfContainerMetadata.copyWith(...)` or like so:`instanceOfContainerMetadata.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ContainerMetadataCWProxy get copyWith =>
      _$ContainerMetadataCWProxyImpl(this);
}

abstract class _$ContainerDataCWProxy {
  ContainerData id(String id);

  ContainerData name(String? name);

  ContainerData color(Color color);

  ContainerData metadata(ContainerMetadata? metadata);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ContainerData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ContainerData(...).copyWith(id: 12, name: "My name")
  /// ````
  ContainerData call({
    String id,
    String? name,
    Color color,
    ContainerMetadata? metadata,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfContainerData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfContainerData.copyWith.fieldName(...)`
class _$ContainerDataCWProxyImpl implements _$ContainerDataCWProxy {
  const _$ContainerDataCWProxyImpl(this._value);

  final ContainerData _value;

  @override
  ContainerData id(String id) => this(id: id);

  @override
  ContainerData name(String? name) => this(name: name);

  @override
  ContainerData color(Color color) => this(color: color);

  @override
  ContainerData metadata(ContainerMetadata? metadata) =>
      this(metadata: metadata);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ContainerData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ContainerData(...).copyWith(id: 12, name: "My name")
  /// ````
  ContainerData call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
  }) {
    return ContainerData(
      id:
          id == const $CopyWithPlaceholder()
              ? _value.id
              // ignore: cast_nullable_to_non_nullable
              : id as String,
      name:
          name == const $CopyWithPlaceholder()
              ? _value.name
              // ignore: cast_nullable_to_non_nullable
              : name as String?,
      color:
          color == const $CopyWithPlaceholder()
              ? _value.color
              // ignore: cast_nullable_to_non_nullable
              : color as Color,
      metadata:
          metadata == const $CopyWithPlaceholder()
              ? _value.metadata
              // ignore: cast_nullable_to_non_nullable
              : metadata as ContainerMetadata?,
    );
  }
}

extension $ContainerDataCopyWith on ContainerData {
  /// Returns a callable class that can be used as follows: `instanceOfContainerData.copyWith(...)` or like so:`instanceOfContainerData.copyWith.fieldName(...)`.
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
  lockTimeout:
      json['lockTimeout'] == null
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
      authSettings:
          json['authSettings'] == null
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
      'authSettings': instance.authSettings,
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
