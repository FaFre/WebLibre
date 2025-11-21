// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bang_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BangDataCWProxy {
  BangData websiteName(String websiteName);

  BangData domain(String domain);

  BangData trigger(String trigger);

  BangData urlTemplate(String urlTemplate);

  BangData searxngApi(bool searxngApi);

  BangData category(String? category);

  BangData subCategory(String? subCategory);

  BangData format(Set<BangFormat>? format);

  BangData additionalTriggers(Set<String>? additionalTriggers);

  BangData frequency(int? frequency);

  BangData lastUsed(DateTime? lastUsed);

  BangData icon(BrowserIcon? icon);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BangData(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BangData(...).copyWith(id: 12, name: "My name")
  /// ```
  BangData call({
    String websiteName,
    String domain,
    String trigger,
    String urlTemplate,
    bool searxngApi,
    String? category,
    String? subCategory,
    Set<BangFormat>? format,
    Set<String>? additionalTriggers,
    int? frequency,
    DateTime? lastUsed,
    BrowserIcon? icon,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfBangData.copyWith(...)` or call `instanceOfBangData.copyWith.fieldName(value)` for a single field.
class _$BangDataCWProxyImpl implements _$BangDataCWProxy {
  const _$BangDataCWProxyImpl(this._value);

  final BangData _value;

  @override
  BangData websiteName(String websiteName) => call(websiteName: websiteName);

  @override
  BangData domain(String domain) => call(domain: domain);

  @override
  BangData trigger(String trigger) => call(trigger: trigger);

  @override
  BangData urlTemplate(String urlTemplate) => call(urlTemplate: urlTemplate);

  @override
  BangData searxngApi(bool searxngApi) => call(searxngApi: searxngApi);

  @override
  BangData category(String? category) => call(category: category);

  @override
  BangData subCategory(String? subCategory) => call(subCategory: subCategory);

  @override
  BangData format(Set<BangFormat>? format) => call(format: format);

  @override
  BangData additionalTriggers(Set<String>? additionalTriggers) =>
      call(additionalTriggers: additionalTriggers);

  @override
  BangData frequency(int? frequency) => call(frequency: frequency);

  @override
  BangData lastUsed(DateTime? lastUsed) => call(lastUsed: lastUsed);

  @override
  BangData icon(BrowserIcon? icon) => call(icon: icon);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BangData(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BangData(...).copyWith(id: 12, name: "My name")
  /// ```
  BangData call({
    Object? websiteName = const $CopyWithPlaceholder(),
    Object? domain = const $CopyWithPlaceholder(),
    Object? trigger = const $CopyWithPlaceholder(),
    Object? urlTemplate = const $CopyWithPlaceholder(),
    Object? searxngApi = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? subCategory = const $CopyWithPlaceholder(),
    Object? format = const $CopyWithPlaceholder(),
    Object? additionalTriggers = const $CopyWithPlaceholder(),
    Object? frequency = const $CopyWithPlaceholder(),
    Object? lastUsed = const $CopyWithPlaceholder(),
    Object? icon = const $CopyWithPlaceholder(),
  }) {
    return BangData._copyWith(
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
      searxngApi:
          searxngApi == const $CopyWithPlaceholder() || searxngApi == null
          ? _value.searxngApi
          // ignore: cast_nullable_to_non_nullable
          : searxngApi as bool,
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
      additionalTriggers: additionalTriggers == const $CopyWithPlaceholder()
          ? _value.additionalTriggers
          // ignore: cast_nullable_to_non_nullable
          : additionalTriggers as Set<String>?,
      frequency: frequency == const $CopyWithPlaceholder()
          ? _value.frequency
          // ignore: cast_nullable_to_non_nullable
          : frequency as int?,
      lastUsed: lastUsed == const $CopyWithPlaceholder()
          ? _value.lastUsed
          // ignore: cast_nullable_to_non_nullable
          : lastUsed as DateTime?,
      icon: icon == const $CopyWithPlaceholder()
          ? _value.icon
          // ignore: cast_nullable_to_non_nullable
          : icon as BrowserIcon?,
    );
  }
}

extension $BangDataCopyWith on BangData {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfBangData.copyWith(...)` or `instanceOfBangData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BangDataCWProxy get copyWith => _$BangDataCWProxyImpl(this);
}
