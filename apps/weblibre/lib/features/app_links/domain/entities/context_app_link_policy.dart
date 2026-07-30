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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show AppLinksMode;
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/features/app_links/domain/entities/app_link_rule.dart';

part 'context_app_link_policy.g.dart';

/// A container's self-contained app-link policy, used when the container has
/// "isolated app link settings" enabled (replace semantics — it fully takes the
/// place of the global mode + rules for navigations in that container).
///
/// Stored in `GeneralSettings.appLinkContextOverrides` keyed by the container's
/// Gecko contextId (`contextualIdentity`). Only isolated containers have an
/// entry; the snapshot builder synthesises a blank-slate default for a freshly
/// isolated container that has not customised anything yet.
@CopyWith()
@JsonSerializable()
class ContextAppLinkPolicy with FastEquatable {
  /// The container's own global app-links mode (default [AppLinksMode.ask]).
  final AppLinksMode mode;

  /// The container's own remembered per-scope rules, keyed by canonical scope
  /// (`host:youtube.com` | `pkg:...`). Same shape/validation as the global
  /// [GeneralSettings.appLinkRules]; malformed entries are dropped on read.
  @JsonKey(fromJson: parseAppLinkRules)
  final Map<String, PersistedAppLinkRule> rules;

  ContextAppLinkPolicy({required this.mode, required this.rules});

  /// The blank-slate policy a container starts from when it is first isolated.
  ContextAppLinkPolicy.blank() : this(mode: AppLinksMode.ask, rules: const {});

  factory ContextAppLinkPolicy.fromJson(Map<String, dynamic> json) =>
      _$ContextAppLinkPolicyFromJson(json);

  Map<String, dynamic> toJson() => _$ContextAppLinkPolicyToJson(this);

  @override
  List<Object?> get hashParameters => [mode, rules];
}

/// Parse the persisted override map, dropping malformed entries (§2.9 style).
/// Keys are contextIds; the interceptor only ever consults entries whose
/// contextId belongs to a currently-isolated container, so an orphaned entry
/// (container deleted / isolation turned off) is inert.
Map<String, ContextAppLinkPolicy> parseAppLinkContextOverrides(
  Map<String, dynamic>? json,
) {
  if (json == null) return const {};
  final result = <String, ContextAppLinkPolicy>{};
  for (final MapEntry(:key, :value) in json.entries) {
    if (value is! Map<String, dynamic>) continue;
    try {
      result[key] = ContextAppLinkPolicy.fromJson(value);
    } catch (_) {
      continue;
    }
  }
  return result;
}
