// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_app_link_policy.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ContextAppLinkPolicyCWProxy {
  ContextAppLinkPolicy mode(AppLinksMode mode);

  ContextAppLinkPolicy rules(Map<String, PersistedAppLinkRule> rules);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ContextAppLinkPolicy(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ContextAppLinkPolicy(...).copyWith(id: 12, name: "My name")
  /// ```
  ContextAppLinkPolicy call({
    AppLinksMode mode,
    Map<String, PersistedAppLinkRule> rules,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfContextAppLinkPolicy.copyWith(...)` or call `instanceOfContextAppLinkPolicy.copyWith.fieldName(value)` for a single field.
class _$ContextAppLinkPolicyCWProxyImpl
    implements _$ContextAppLinkPolicyCWProxy {
  const _$ContextAppLinkPolicyCWProxyImpl(this._value);

  final ContextAppLinkPolicy _value;

  @override
  ContextAppLinkPolicy mode(AppLinksMode mode) => call(mode: mode);

  @override
  ContextAppLinkPolicy rules(Map<String, PersistedAppLinkRule> rules) =>
      call(rules: rules);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ContextAppLinkPolicy(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ContextAppLinkPolicy(...).copyWith(id: 12, name: "My name")
  /// ```
  ContextAppLinkPolicy call({
    Object? mode = const $CopyWithPlaceholder(),
    Object? rules = const $CopyWithPlaceholder(),
  }) {
    return ContextAppLinkPolicy(
      mode: mode == const $CopyWithPlaceholder() || mode == null
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as AppLinksMode,
      rules: rules == const $CopyWithPlaceholder() || rules == null
          ? _value.rules
          // ignore: cast_nullable_to_non_nullable
          : rules as Map<String, PersistedAppLinkRule>,
    );
  }
}

extension $ContextAppLinkPolicyCopyWith on ContextAppLinkPolicy {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfContextAppLinkPolicy.copyWith(...)` or `instanceOfContextAppLinkPolicy.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ContextAppLinkPolicyCWProxy get copyWith =>
      _$ContextAppLinkPolicyCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContextAppLinkPolicy _$ContextAppLinkPolicyFromJson(
  Map<String, dynamic> json,
) => ContextAppLinkPolicy(
  mode: $enumDecode(_$AppLinksModeEnumMap, json['mode']),
  rules: parseAppLinkRules(json['rules'] as Map<String, dynamic>?),
);

Map<String, dynamic> _$ContextAppLinkPolicyToJson(
  ContextAppLinkPolicy instance,
) => <String, dynamic>{
  'mode': _$AppLinksModeEnumMap[instance.mode]!,
  'rules': instance.rules.map((k, e) => MapEntry(k, e.toJson())),
};

const _$AppLinksModeEnumMap = {
  AppLinksMode.always: 'always',
  AppLinksMode.ask: 'ask',
  AppLinksMode.never: 'never',
};
