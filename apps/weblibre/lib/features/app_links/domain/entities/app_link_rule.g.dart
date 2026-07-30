// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_link_rule.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PersistedAppLinkRuleCWProxy {
  PersistedAppLinkRule decision(AppLinkRuleDecision decision);

  PersistedAppLinkRule scope(String scope);

  PersistedAppLinkRule packageName(String? packageName);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `PersistedAppLinkRule(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PersistedAppLinkRule(...).copyWith(id: 12, name: "My name")
  /// ```
  PersistedAppLinkRule call({
    AppLinkRuleDecision decision,
    String scope,
    String? packageName,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfPersistedAppLinkRule.copyWith(...)` or call `instanceOfPersistedAppLinkRule.copyWith.fieldName(value)` for a single field.
class _$PersistedAppLinkRuleCWProxyImpl
    implements _$PersistedAppLinkRuleCWProxy {
  const _$PersistedAppLinkRuleCWProxyImpl(this._value);

  final PersistedAppLinkRule _value;

  @override
  PersistedAppLinkRule decision(AppLinkRuleDecision decision) =>
      call(decision: decision);

  @override
  PersistedAppLinkRule scope(String scope) => call(scope: scope);

  @override
  PersistedAppLinkRule packageName(String? packageName) =>
      call(packageName: packageName);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `PersistedAppLinkRule(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PersistedAppLinkRule(...).copyWith(id: 12, name: "My name")
  /// ```
  PersistedAppLinkRule call({
    Object? decision = const $CopyWithPlaceholder(),
    Object? scope = const $CopyWithPlaceholder(),
    Object? packageName = const $CopyWithPlaceholder(),
  }) {
    return PersistedAppLinkRule(
      decision: decision == const $CopyWithPlaceholder() || decision == null
          ? _value.decision
          // ignore: cast_nullable_to_non_nullable
          : decision as AppLinkRuleDecision,
      scope: scope == const $CopyWithPlaceholder() || scope == null
          ? _value.scope
          // ignore: cast_nullable_to_non_nullable
          : scope as String,
      packageName: packageName == const $CopyWithPlaceholder()
          ? _value.packageName
          // ignore: cast_nullable_to_non_nullable
          : packageName as String?,
    );
  }
}

extension $PersistedAppLinkRuleCopyWith on PersistedAppLinkRule {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfPersistedAppLinkRule.copyWith(...)` or `instanceOfPersistedAppLinkRule.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PersistedAppLinkRuleCWProxy get copyWith =>
      _$PersistedAppLinkRuleCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersistedAppLinkRule _$PersistedAppLinkRuleFromJson(
  Map<String, dynamic> json,
) => PersistedAppLinkRule(
  decision: $enumDecode(_$AppLinkRuleDecisionEnumMap, json['decision']),
  scope: json['scope'] as String,
  packageName: json['packageName'] as String?,
);

Map<String, dynamic> _$PersistedAppLinkRuleToJson(
  PersistedAppLinkRule instance,
) => <String, dynamic>{
  'decision': _$AppLinkRuleDecisionEnumMap[instance.decision]!,
  'scope': instance.scope,
  'packageName': instance.packageName,
};

const _$AppLinkRuleDecisionEnumMap = {
  AppLinkRuleDecision.alwaysOpen: 'alwaysOpen',
  AppLinkRuleDecision.neverOpen: 'neverOpen',
};
