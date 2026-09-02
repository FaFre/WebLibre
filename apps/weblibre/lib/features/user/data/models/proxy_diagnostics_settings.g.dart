// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_diagnostics_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProxyDiagnosticsSettingsCWProxy {
  ProxyDiagnosticsSettings logLevel(ProxyLogLevel logLevel);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ProxyDiagnosticsSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ProxyDiagnosticsSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  ProxyDiagnosticsSettings call({ProxyLogLevel logLevel});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfProxyDiagnosticsSettings.copyWith(...)` or call `instanceOfProxyDiagnosticsSettings.copyWith.fieldName(value)` for a single field.
class _$ProxyDiagnosticsSettingsCWProxyImpl
    implements _$ProxyDiagnosticsSettingsCWProxy {
  const _$ProxyDiagnosticsSettingsCWProxyImpl(this._value);

  final ProxyDiagnosticsSettings _value;

  @override
  ProxyDiagnosticsSettings logLevel(ProxyLogLevel logLevel) =>
      call(logLevel: logLevel);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ProxyDiagnosticsSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ProxyDiagnosticsSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  ProxyDiagnosticsSettings call({
    Object? logLevel = const $CopyWithPlaceholder(),
  }) {
    return ProxyDiagnosticsSettings(
      logLevel: logLevel == const $CopyWithPlaceholder() || logLevel == null
          ? _value.logLevel
          // ignore: cast_nullable_to_non_nullable
          : logLevel as ProxyLogLevel,
    );
  }
}

extension $ProxyDiagnosticsSettingsCopyWith on ProxyDiagnosticsSettings {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfProxyDiagnosticsSettings.copyWith(...)` or `instanceOfProxyDiagnosticsSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProxyDiagnosticsSettingsCWProxy get copyWith =>
      _$ProxyDiagnosticsSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProxyDiagnosticsSettings _$ProxyDiagnosticsSettingsFromJson(
  Map<String, dynamic> json,
) => ProxyDiagnosticsSettings.withDefaults(
  logLevel: $enumDecodeNullable(
    _$ProxyLogLevelEnumMap,
    json['logLevel'],
    unknownValue: ProxyLogLevel.warn,
  ),
);

Map<String, dynamic> _$ProxyDiagnosticsSettingsToJson(
  ProxyDiagnosticsSettings instance,
) => <String, dynamic>{'logLevel': _$ProxyLogLevelEnumMap[instance.logLevel]!};

const _$ProxyLogLevelEnumMap = {
  ProxyLogLevel.warn: 'warn',
  ProxyLogLevel.info: 'info',
  ProxyLogLevel.debug: 'debug',
  ProxyLogLevel.trace: 'trace',
};
