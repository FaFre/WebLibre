// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_detail.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SettingsSectionDefinitionCWProxy {
  SettingsSectionDefinition title(String title);

  SettingsSectionDefinition entries(List<SettingsEntryDefinition> entries);

  SettingsSectionDefinition keywords(List<String> keywords);

  SettingsSectionDefinition feature(FeatureId? feature);

  SettingsSectionDefinition keptWhen(KeptWhen? keptWhen);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `SettingsSectionDefinition(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SettingsSectionDefinition(...).copyWith(id: 12, name: "My name")
  /// ```
  SettingsSectionDefinition call({
    String title,
    List<SettingsEntryDefinition> entries,
    List<String> keywords,
    FeatureId? feature,
    KeptWhen? keptWhen,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSettingsSectionDefinition.copyWith(...)` or call `instanceOfSettingsSectionDefinition.copyWith.fieldName(value)` for a single field.
class _$SettingsSectionDefinitionCWProxyImpl
    implements _$SettingsSectionDefinitionCWProxy {
  const _$SettingsSectionDefinitionCWProxyImpl(this._value);

  final SettingsSectionDefinition _value;

  @override
  SettingsSectionDefinition title(String title) => call(title: title);

  @override
  SettingsSectionDefinition entries(List<SettingsEntryDefinition> entries) =>
      call(entries: entries);

  @override
  SettingsSectionDefinition keywords(List<String> keywords) =>
      call(keywords: keywords);

  @override
  SettingsSectionDefinition feature(FeatureId? feature) =>
      call(feature: feature);

  @override
  SettingsSectionDefinition keptWhen(KeptWhen? keptWhen) =>
      call(keptWhen: keptWhen);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `SettingsSectionDefinition(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SettingsSectionDefinition(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  SettingsSectionDefinition call({
    Object? title = const $CopyWithPlaceholder(),
    Object? entries = const $CopyWithPlaceholder(),
    Object? keywords = const $CopyWithPlaceholder(),
    Object? feature = const $CopyWithPlaceholder(),
    Object? keptWhen = const $CopyWithPlaceholder(),
  }) {
    return SettingsSectionDefinition(
      title: title == const $CopyWithPlaceholder() || title == null
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      entries: entries == const $CopyWithPlaceholder() || entries == null
          ? _value.entries
          // ignore: cast_nullable_to_non_nullable
          : entries as List<SettingsEntryDefinition>,
      keywords: keywords == const $CopyWithPlaceholder() || keywords == null
          ? _value.keywords
          // ignore: cast_nullable_to_non_nullable
          : keywords as List<String>,
      feature: feature == const $CopyWithPlaceholder()
          ? _value.feature
          // ignore: cast_nullable_to_non_nullable
          : feature as FeatureId?,
      keptWhen: keptWhen == const $CopyWithPlaceholder()
          ? _value.keptWhen
          // ignore: cast_nullable_to_non_nullable
          : keptWhen as KeptWhen?,
    );
  }
}

extension $SettingsSectionDefinitionCopyWith on SettingsSectionDefinition {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSettingsSectionDefinition.copyWith(...)` or `instanceOfSettingsSectionDefinition.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SettingsSectionDefinitionCWProxy get copyWith =>
      _$SettingsSectionDefinitionCWProxyImpl(this);
}
