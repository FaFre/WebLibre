// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ContainerMetadataCWProxy {
  ContainerMetadata iconData(IconData? iconData);

  ContainerMetadata contextualIdentity(String? contextualIdentity);

  ContainerMetadata useProxy(bool useProxy);

  ContainerMetadata clearDataOnExit(bool clearDataOnExit);

  ContainerMetadata assignedSites(List<Uri>? assignedSites);

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
    bool useProxy,
    bool clearDataOnExit,
    List<Uri>? assignedSites,
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
  ContainerMetadata useProxy(bool useProxy) => call(useProxy: useProxy);

  @override
  ContainerMetadata clearDataOnExit(bool clearDataOnExit) =>
      call(clearDataOnExit: clearDataOnExit);

  @override
  ContainerMetadata assignedSites(List<Uri>? assignedSites) =>
      call(assignedSites: assignedSites);

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
    Object? useProxy = const $CopyWithPlaceholder(),
    Object? clearDataOnExit = const $CopyWithPlaceholder(),
    Object? assignedSites = const $CopyWithPlaceholder(),
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
      useProxy: useProxy == const $CopyWithPlaceholder() || useProxy == null
          ? _value.useProxy
          // ignore: cast_nullable_to_non_nullable
          : useProxy as bool,
      clearDataOnExit:
          clearDataOnExit == const $CopyWithPlaceholder() ||
              clearDataOnExit == null
          ? _value.clearDataOnExit
          // ignore: cast_nullable_to_non_nullable
          : clearDataOnExit as bool,
      assignedSites: assignedSites == const $CopyWithPlaceholder()
          ? _value.assignedSites
          // ignore: cast_nullable_to_non_nullable
          : assignedSites as List<Uri>?,
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

ContainerMetadata _$ContainerMetadataFromJson(Map<String, dynamic> json) =>
    ContainerMetadata.withDefaults(
      iconData: _$JsonConverterFromJson<Map<String, dynamic>, IconData>(
        json['iconData'],
        const IconDataJsonConverter().fromJson,
      ),
      contextualIdentity: json['contextualIdentity'] as String?,
      useProxy: json['useProxy'] as bool? ?? false,
      clearDataOnExit: json['clearDataOnExit'] as bool? ?? false,
      assignedSites: (json['assignedSites'] as List<dynamic>?)
          ?.map((e) => Uri.parse(e as String))
          .toList(),
    );

Map<String, dynamic> _$ContainerMetadataToJson(
  ContainerMetadata instance,
) => <String, dynamic>{
  'iconData': _$JsonConverterToJson<Map<String, dynamic>, IconData>(
    instance.iconData,
    const IconDataJsonConverter().toJson,
  ),
  'contextualIdentity': instance.contextualIdentity,
  'useProxy': instance.useProxy,
  'clearDataOnExit': instance.clearDataOnExit,
  'assignedSites': instance.assignedSites?.map((e) => e.toString()).toList(),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

ContainerData _$ContainerDataFromJson(
  Map<String, dynamic> json,
) => ContainerData(
  id: json['id'] as String,
  name: json['name'] as String?,
  color: const ColorJsonConverter().fromJson((json['color'] as num).toInt()),
  metadata: json['metadata'] == null
      ? null
      : ContainerMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ContainerDataToJson(ContainerData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': const ColorJsonConverter().toJson(instance.color),
      'metadata': instance.metadata.toJson(),
    };

ContainerDataWithCount _$ContainerDataWithCountFromJson(
  Map<String, dynamic> json,
) => ContainerDataWithCount(
  id: json['id'] as String,
  name: json['name'] as String?,
  color: const ColorJsonConverter().fromJson((json['color'] as num).toInt()),
  metadata: json['metadata'] == null
      ? null
      : ContainerMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
  tabCount: (json['tabCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$ContainerDataWithCountToJson(
  ContainerDataWithCount instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'color': const ColorJsonConverter().toJson(instance.color),
  'metadata': instance.metadata.toJson(),
  'tabCount': instance.tabCount,
};
