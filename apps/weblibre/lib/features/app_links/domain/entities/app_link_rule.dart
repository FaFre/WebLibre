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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_link_rule.g.dart';

enum AppLinkRuleDecision { alwaysOpen, neverOpen }

/// A remembered per-scope app-link rule (persistence contract, §2.5/§2.9).
///
/// Stored in `GeneralSettings.appLinkRules` as `Map<String, PersistedAppLinkRule>`
/// keyed by [scope] — one canonical rule per scope, upsert/last-write-wins. The
/// [scope] is a native-owned canonical key (`host:youtube.com` | `pkg:...`) that
/// Dart persists opaquely and never reconstructs.
@CopyWith()
@JsonSerializable()
class PersistedAppLinkRule with FastEquatable {
  final AppLinkRuleDecision decision;

  /// Canonical scope key: `host:<host>` or `pkg:<package>`.
  final String scope;

  /// Resolved package name. Required for [AppLinkRuleDecision.alwaysOpen]
  /// (binds the launch target); null for [AppLinkRuleDecision.neverOpen].
  final String? packageName;

  PersistedAppLinkRule({
    required this.decision,
    required this.scope,
    this.packageName,
  });

  factory PersistedAppLinkRule.fromJson(Map<String, dynamic> json) =>
      _$PersistedAppLinkRuleFromJson(json);

  Map<String, dynamic> toJson() => _$PersistedAppLinkRuleToJson(this);

  /// Whether this rule is internally consistent: an `alwaysOpen` rule must bind
  /// a package; the scope must be a recognised canonical key.
  bool get isValid {
    if (scope.isEmpty) return false;
    final hasKnownPrefix =
        scope.startsWith('host:') || scope.startsWith('pkg:');
    if (!hasKnownPrefix) return false;
    if (decision == AppLinkRuleDecision.alwaysOpen &&
        (packageName == null || packageName!.isEmpty)) {
      return false;
    }
    return true;
  }

  @override
  List<Object?> get hashParameters => [decision, scope, packageName];
}

/// Parse the persisted rule map, dropping malformed rules (with a warning) and
/// entries whose map key disagrees with the rule's own scope (§2.9).
Map<String, PersistedAppLinkRule> parseAppLinkRules(
  Map<String, dynamic>? json,
) {
  if (json == null) return const {};
  final result = <String, PersistedAppLinkRule>{};
  for (final MapEntry(:key, :value) in json.entries) {
    if (value is! Map<String, dynamic>) continue;
    final PersistedAppLinkRule rule;
    try {
      rule = PersistedAppLinkRule.fromJson(value);
    } catch (_) {
      continue;
    }
    if (rule.scope != key) continue;
    if (!rule.isValid) continue;
    result[key] = rule;
  }
  return result;
}
