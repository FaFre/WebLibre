// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ublock_filter_list_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UBlockExternalListCWProxy {
  UBlockExternalList url(String url);

  UBlockExternalList description(String? description);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `UBlockExternalList(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// UBlockExternalList(...).copyWith(id: 12, name: "My name")
  /// ```
  UBlockExternalList call({String url, String? description});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfUBlockExternalList.copyWith(...)` or call `instanceOfUBlockExternalList.copyWith.fieldName(value)` for a single field.
class _$UBlockExternalListCWProxyImpl implements _$UBlockExternalListCWProxy {
  const _$UBlockExternalListCWProxyImpl(this._value);

  final UBlockExternalList _value;

  @override
  UBlockExternalList url(String url) => call(url: url);

  @override
  UBlockExternalList description(String? description) =>
      call(description: description);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `UBlockExternalList(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// UBlockExternalList(...).copyWith(id: 12, name: "My name")
  /// ```
  UBlockExternalList call({
    Object? url = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
  }) {
    return UBlockExternalList(
      url: url == const $CopyWithPlaceholder() || url == null
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
    );
  }
}

extension $UBlockExternalListCopyWith on UBlockExternalList {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfUBlockExternalList.copyWith(...)` or `instanceOfUBlockExternalList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UBlockExternalListCWProxy get copyWith =>
      _$UBlockExternalListCWProxyImpl(this);
}

abstract class _$UBlockFilterListSettingsCWProxy {
  UBlockFilterListSettings enabled(bool enabled);

  UBlockFilterListSettings enabledStockListTokens(
    List<String> enabledStockListTokens,
  );

  UBlockFilterListSettings autoEnabledStockListTokens(
    List<String> autoEnabledStockListTokens,
  );

  UBlockFilterListSettings autoSelectRegionalLists(
    bool autoSelectRegionalLists,
  );

  UBlockFilterListSettings externalFilterLists(
    List<UBlockExternalList> externalFilterLists,
  );

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `UBlockFilterListSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// UBlockFilterListSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  UBlockFilterListSettings call({
    bool enabled,
    List<String> enabledStockListTokens,
    List<String> autoEnabledStockListTokens,
    bool autoSelectRegionalLists,
    List<UBlockExternalList> externalFilterLists,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfUBlockFilterListSettings.copyWith(...)` or call `instanceOfUBlockFilterListSettings.copyWith.fieldName(value)` for a single field.
class _$UBlockFilterListSettingsCWProxyImpl
    implements _$UBlockFilterListSettingsCWProxy {
  const _$UBlockFilterListSettingsCWProxyImpl(this._value);

  final UBlockFilterListSettings _value;

  @override
  UBlockFilterListSettings enabled(bool enabled) => call(enabled: enabled);

  @override
  UBlockFilterListSettings enabledStockListTokens(
    List<String> enabledStockListTokens,
  ) => call(enabledStockListTokens: enabledStockListTokens);

  @override
  UBlockFilterListSettings autoEnabledStockListTokens(
    List<String> autoEnabledStockListTokens,
  ) => call(autoEnabledStockListTokens: autoEnabledStockListTokens);

  @override
  UBlockFilterListSettings autoSelectRegionalLists(
    bool autoSelectRegionalLists,
  ) => call(autoSelectRegionalLists: autoSelectRegionalLists);

  @override
  UBlockFilterListSettings externalFilterLists(
    List<UBlockExternalList> externalFilterLists,
  ) => call(externalFilterLists: externalFilterLists);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `UBlockFilterListSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// UBlockFilterListSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  UBlockFilterListSettings call({
    Object? enabled = const $CopyWithPlaceholder(),
    Object? enabledStockListTokens = const $CopyWithPlaceholder(),
    Object? autoEnabledStockListTokens = const $CopyWithPlaceholder(),
    Object? autoSelectRegionalLists = const $CopyWithPlaceholder(),
    Object? externalFilterLists = const $CopyWithPlaceholder(),
  }) {
    return UBlockFilterListSettings(
      enabled: enabled == const $CopyWithPlaceholder() || enabled == null
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      enabledStockListTokens:
          enabledStockListTokens == const $CopyWithPlaceholder() ||
              enabledStockListTokens == null
          ? _value.enabledStockListTokens
          // ignore: cast_nullable_to_non_nullable
          : enabledStockListTokens as List<String>,
      autoEnabledStockListTokens:
          autoEnabledStockListTokens == const $CopyWithPlaceholder() ||
              autoEnabledStockListTokens == null
          ? _value.autoEnabledStockListTokens
          // ignore: cast_nullable_to_non_nullable
          : autoEnabledStockListTokens as List<String>,
      autoSelectRegionalLists:
          autoSelectRegionalLists == const $CopyWithPlaceholder() ||
              autoSelectRegionalLists == null
          ? _value.autoSelectRegionalLists
          // ignore: cast_nullable_to_non_nullable
          : autoSelectRegionalLists as bool,
      externalFilterLists:
          externalFilterLists == const $CopyWithPlaceholder() ||
              externalFilterLists == null
          ? _value.externalFilterLists
          // ignore: cast_nullable_to_non_nullable
          : externalFilterLists as List<UBlockExternalList>,
    );
  }
}

extension $UBlockFilterListSettingsCopyWith on UBlockFilterListSettings {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfUBlockFilterListSettings.copyWith(...)` or `instanceOfUBlockFilterListSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UBlockFilterListSettingsCWProxy get copyWith =>
      _$UBlockFilterListSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UBlockExternalList _$UBlockExternalListFromJson(Map<String, dynamic> json) =>
    UBlockExternalList(
      url: json['url'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$UBlockExternalListToJson(UBlockExternalList instance) =>
    <String, dynamic>{
      'url': instance.url,
      'description': ?instance.description,
    };

UBlockFilterListSettings _$UBlockFilterListSettingsFromJson(
  Map<String, dynamic> json,
) => UBlockFilterListSettings(
  enabled: json['enabled'] as bool? ?? false,
  enabledStockListTokens:
      (json['enabledStockListTokens'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  autoEnabledStockListTokens:
      (json['autoEnabledStockListTokens'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  autoSelectRegionalLists: json['autoSelectRegionalLists'] as bool? ?? false,
  externalFilterLists:
      (json['externalFilterLists'] as List<dynamic>?)
          ?.map((e) => UBlockExternalList.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$UBlockFilterListSettingsToJson(
  UBlockFilterListSettings instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'enabledStockListTokens': instance.enabledStockListTokens,
  'autoEnabledStockListTokens': instance.autoEnabledStockListTokens,
  'autoSelectRegionalLists': instance.autoSelectRegionalLists,
  'externalFilterLists': instance.externalFilterLists
      .map((e) => e.toJson())
      .toList(),
};
