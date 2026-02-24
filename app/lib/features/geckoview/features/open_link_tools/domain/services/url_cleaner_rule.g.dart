// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_cleaner_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UrlCleanerRule _$UrlCleanerRuleFromJson(Map<String, dynamic> json) =>
    UrlCleanerRule(
      name: json['name'] as String,
      data: UrlCleanerRuleData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UrlCleanerRuleToJson(UrlCleanerRule instance) =>
    <String, dynamic>{'name': instance.name, 'data': instance.data.toJson()};

UrlCleanerRuleData _$UrlCleanerRuleDataFromJson(Map<String, dynamic> json) =>
    UrlCleanerRuleData(
      urlPattern: json['urlPattern'] as String?,
      completeProvider: json['completeProvider'] as bool? ?? false,
      forceRedirection: json['forceRedirection'] as bool? ?? false,
      exceptions: json['exceptions'] == null
          ? const []
          : UrlCleanerRuleData._stringListFromJson(json['exceptions']),
      redirections: json['redirections'] == null
          ? const []
          : UrlCleanerRuleData._stringListFromJson(json['redirections']),
      rawRules: json['rawRules'] == null
          ? const []
          : UrlCleanerRuleData._stringListFromJson(json['rawRules']),
      rules: json['rules'] == null
          ? const []
          : UrlCleanerRuleData._stringListFromJson(json['rules']),
      referralMarketing: json['referralMarketing'] == null
          ? const []
          : UrlCleanerRuleData._stringListFromJson(json['referralMarketing']),
    );

Map<String, dynamic> _$UrlCleanerRuleDataToJson(UrlCleanerRuleData instance) =>
    <String, dynamic>{
      'urlPattern': instance.urlPattern,
      'completeProvider': instance.completeProvider,
      'forceRedirection': instance.forceRedirection,
      'exceptions': instance.exceptions,
      'redirections': instance.redirections,
      'rawRules': instance.rawRules,
      'rules': instance.rules,
      'referralMarketing': instance.referralMarketing,
    };
