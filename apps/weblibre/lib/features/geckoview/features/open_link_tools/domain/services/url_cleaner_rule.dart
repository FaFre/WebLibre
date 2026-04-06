/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'url_cleaner_rule.g.dart';

@JsonSerializable()
class UrlCleanerRule with FastEquatable {
  final String name;
  final UrlCleanerRuleData data;

  UrlCleanerRule({required this.name, required this.data});

  factory UrlCleanerRule.fromCatalogEntry(
    String name,
    Map<String, dynamic> data,
  ) {
    return UrlCleanerRule(name: name, data: UrlCleanerRuleData.fromJson(data));
  }

  factory UrlCleanerRule.fromJson(Map<String, dynamic> json) =>
      _$UrlCleanerRuleFromJson(json);

  Map<String, dynamic> toJson() => _$UrlCleanerRuleToJson(this);

  @override
  List<Object?> get hashParameters => [name, data];
}

@JsonSerializable()
class UrlCleanerRuleData with FastEquatable {
  final String? urlPattern;
  final bool completeProvider;
  final bool forceRedirection;
  @JsonKey(fromJson: _stringListFromJson)
  final List<String> exceptions;
  @JsonKey(fromJson: _stringListFromJson)
  final List<String> redirections;
  @JsonKey(fromJson: _stringListFromJson)
  final List<String> rawRules;
  @JsonKey(fromJson: _stringListFromJson)
  final List<String> rules;
  @JsonKey(fromJson: _stringListFromJson)
  final List<String> referralMarketing;

  static List<String> _stringListFromJson(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList(growable: false);
  }

  // Lazily compiled regexes — derived from the source strings above,
  // not identity-bearing state, so intentionally excluded from hashParameters.
  // ignore: fast_equatable_lint/missing_field_in_equatable_props
  @JsonKey(includeFromJson: false, includeToJson: false)
  late final RegExp? compiledUrlPattern = _tryCompile(urlPattern);
  // ignore: fast_equatable_lint/missing_field_in_equatable_props
  @JsonKey(includeFromJson: false, includeToJson: false)
  late final List<RegExp> compiledExceptions = exceptions
      .map((e) => _tryCompile(e))
      .whereType<RegExp>()
      .toList();
  // ignore: fast_equatable_lint/missing_field_in_equatable_props
  @JsonKey(includeFromJson: false, includeToJson: false)
  late final List<RegExp> compiledRedirections = redirections
      .map((e) => _tryCompile(e))
      .whereType<RegExp>()
      .toList();
  // ignore: fast_equatable_lint/missing_field_in_equatable_props
  @JsonKey(includeFromJson: false, includeToJson: false)
  late final List<RegExp?> compiledRawRules = rawRules
      .map((e) => _tryCompile(e))
      .toList();
  // ignore: fast_equatable_lint/missing_field_in_equatable_props
  @JsonKey(includeFromJson: false, includeToJson: false)
  late final List<RegExp?> compiledRules = rules
      .map((e) => _tryCompile(e))
      .toList();
  // ignore: fast_equatable_lint/missing_field_in_equatable_props
  @JsonKey(includeFromJson: false, includeToJson: false)
  late final List<RegExp?> compiledReferralMarketing = referralMarketing
      .map((e) => _tryCompile(e))
      .toList();

  static RegExp? _tryCompile(String? pattern) {
    if (pattern == null || pattern.isEmpty) return null;
    try {
      return RegExp(pattern, caseSensitive: false);
    } on FormatException {
      return null;
    }
  }

  UrlCleanerRuleData({
    this.urlPattern,
    this.completeProvider = false,
    this.forceRedirection = false,
    this.exceptions = const [],
    this.redirections = const [],
    this.rawRules = const [],
    this.rules = const [],
    this.referralMarketing = const [],
  });

  factory UrlCleanerRuleData.fromJson(Map<String, dynamic> json) =>
      _$UrlCleanerRuleDataFromJson(json);

  Map<String, dynamic> toJson() => _$UrlCleanerRuleDataToJson(this);

  @override
  List<Object?> get hashParameters => [
    urlPattern,
    completeProvider,
    forceRedirection,
    exceptions,
    redirections,
    rawRules,
    rules,
    referralMarketing,
  ];
}
