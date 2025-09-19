// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bang.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BangCWProxy {
  Bang websiteName(String websiteName);

  Bang domain(String domain);

  Bang trigger(String trigger);

  Bang urlTemplate(String urlTemplate);

  Bang group(BangGroup? group);

  Bang category(String? category);

  Bang subCategory(String? subCategory);

  Bang format(Set<BangFormat>? format);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Bang(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Bang(...).copyWith(id: 12, name: "My name")
  /// ```
  Bang call({
    String websiteName,
    String domain,
    String trigger,
    String urlTemplate,
    BangGroup? group,
    String? category,
    String? subCategory,
    Set<BangFormat>? format,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfBang.copyWith(...)` or call `instanceOfBang.copyWith.fieldName(value)` for a single field.
class _$BangCWProxyImpl implements _$BangCWProxy {
  const _$BangCWProxyImpl(this._value);

  final Bang _value;

  @override
  Bang websiteName(String websiteName) => call(websiteName: websiteName);

  @override
  Bang domain(String domain) => call(domain: domain);

  @override
  Bang trigger(String trigger) => call(trigger: trigger);

  @override
  Bang urlTemplate(String urlTemplate) => call(urlTemplate: urlTemplate);

  @override
  Bang group(BangGroup? group) => call(group: group);

  @override
  Bang category(String? category) => call(category: category);

  @override
  Bang subCategory(String? subCategory) => call(subCategory: subCategory);

  @override
  Bang format(Set<BangFormat>? format) => call(format: format);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Bang(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Bang(...).copyWith(id: 12, name: "My name")
  /// ```
  Bang call({
    Object? websiteName = const $CopyWithPlaceholder(),
    Object? domain = const $CopyWithPlaceholder(),
    Object? trigger = const $CopyWithPlaceholder(),
    Object? urlTemplate = const $CopyWithPlaceholder(),
    Object? group = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? subCategory = const $CopyWithPlaceholder(),
    Object? format = const $CopyWithPlaceholder(),
  }) {
    return Bang(
      websiteName:
          websiteName == const $CopyWithPlaceholder() || websiteName == null
          ? _value.websiteName
          // ignore: cast_nullable_to_non_nullable
          : websiteName as String,
      domain: domain == const $CopyWithPlaceholder() || domain == null
          ? _value.domain
          // ignore: cast_nullable_to_non_nullable
          : domain as String,
      trigger: trigger == const $CopyWithPlaceholder() || trigger == null
          ? _value.trigger
          // ignore: cast_nullable_to_non_nullable
          : trigger as String,
      urlTemplate:
          urlTemplate == const $CopyWithPlaceholder() || urlTemplate == null
          ? _value.urlTemplate
          // ignore: cast_nullable_to_non_nullable
          : urlTemplate as String,
      group: group == const $CopyWithPlaceholder()
          ? _value.group
          // ignore: cast_nullable_to_non_nullable
          : group as BangGroup?,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as String?,
      subCategory: subCategory == const $CopyWithPlaceholder()
          ? _value.subCategory
          // ignore: cast_nullable_to_non_nullable
          : subCategory as String?,
      format: format == const $CopyWithPlaceholder()
          ? _value.format
          // ignore: cast_nullable_to_non_nullable
          : format as Set<BangFormat>?,
    );
  }
}

extension $BangCopyWith on Bang {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfBang.copyWith(...)` or `instanceOfBang.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BangCWProxy get copyWith => _$BangCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bang _$BangFromJson(Map<String, dynamic> json) => Bang(
  websiteName: json['s'] as String,
  domain: json['d'] as String,
  trigger: json['t'] as String,
  urlTemplate: json['u'] as String,
  category: json['c'] as String?,
  subCategory: json['sc'] as String?,
  format: (json['fmt'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$BangFormatEnumMap, e))
      .toSet(),
);

Map<String, dynamic> _$BangToJson(Bang instance) => <String, dynamic>{
  's': instance.websiteName,
  'd': instance.domain,
  't': instance.trigger,
  'u': instance.urlTemplate,
  'c': instance.category,
  'sc': instance.subCategory,
  'fmt': instance.format?.map((e) => _$BangFormatEnumMap[e]!).toList(),
};

const _$BangFormatEnumMap = {
  BangFormat.openBasePath: 'open_base_path',
  BangFormat.urlEncodePlaceholder: 'url_encode_placeholder',
  BangFormat.urlEncodeSpaceToPlus: 'url_encode_space_to_plus',
};
