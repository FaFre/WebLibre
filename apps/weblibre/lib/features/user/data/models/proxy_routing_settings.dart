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
import 'package:weblibre/features/geckoview/features/tabs/data/entities/isolation_context.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';

part 'proxy_routing_settings.g.dart';

enum ProxyRegularTabRoutingMode { container, all }

@CopyWith()
@JsonSerializable(includeIfNull: true, constructor: 'withDefaults')
class ProxyRoutingSettings with FastEquatable {
  final ProxyRegularTabRoutingMode regularTabsMode;

  @JsonKey(
    fromJson: _proxyConnectionIdFromJson,
    toJson: _proxyConnectionIdToJson,
  )
  final ProxyConnectionId? regularTabsProxyConnectionId;

  @JsonKey(
    fromJson: _proxyConnectionIdFromJson,
    toJson: _proxyConnectionIdToJson,
  )
  final ProxyConnectionId? privateTabsProxyConnectionId;

  /// Per-isolation-context routing overrides, keyed by the `iso1_…` context an
  /// isolated tab loads under.
  ///
  /// Three states, because "no opinion" and "explicitly direct" route
  /// differently: **no entry** follows the tab's container (or the global
  /// route, when it has no container), an entry holding a connection routes
  /// through it, and an entry holding null connects directly.
  ///
  /// Scoped to the isolation *group*, not the tab: a tab opened from an
  /// isolated tab shares its context and therefore its route. Entries outlive
  /// nothing — they are pruned when the last tab of the group closes.
  @JsonKey(
    fromJson: parseIsolationContextRoutes,
    toJson: _isolationContextRoutesToJson,
  )
  final Map<String, ProxyConnectionId?> isolationContextRoutes;

  ProxyRoutingSettings({
    required this.regularTabsMode,
    required this.regularTabsProxyConnectionId,
    required this.privateTabsProxyConnectionId,
    required this.isolationContextRoutes,
  });

  ProxyRoutingSettings.withDefaults({
    ProxyRegularTabRoutingMode? regularTabsMode,
    this.regularTabsProxyConnectionId,
    this.privateTabsProxyConnectionId,
    Map<String, ProxyConnectionId?>? isolationContextRoutes,
  }) : regularTabsMode =
           regularTabsMode ?? ProxyRegularTabRoutingMode.container,
       isolationContextRoutes = isolationContextRoutes ?? const {};

  factory ProxyRoutingSettings.fromJson(Map<String, dynamic> json) =>
      _$ProxyRoutingSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ProxyRoutingSettingsToJson(this);

  @override
  List<Object?> get hashParameters => [
    regularTabsMode,
    regularTabsProxyConnectionId,
    privateTabsProxyConnectionId,
    isolationContextRoutes,
  ];
}

ProxyConnectionId? _proxyConnectionIdFromJson(String? json) =>
    ProxyConnectionId.decode(json);

String? _proxyConnectionIdToJson(ProxyConnectionId? object) => object?.encode();

/// Parse the persisted isolation-route map, dropping malformed entries.
///
/// A null value is meaningful (an explicit direct connection), so entries are
/// kept whenever the key is an isolation context id — only non-string values
/// and keys that could never name one are dropped. An entry naming a proxy that
/// no longer exists decodes to null; that would silently turn a route into a
/// direct connection, so those are dropped instead, leaving the group to follow
/// its container.
Map<String, ProxyConnectionId?> parseIsolationContextRoutes(
  Map<String, dynamic>? json,
) {
  if (json == null) return const {};

  final result = <String, ProxyConnectionId?>{};
  for (final MapEntry(:key, :value) in json.entries) {
    if (!isIsolatedContextId(key)) continue;

    switch (value) {
      case null:
        result[key] = null;
      case final String encoded:
        final connectionId = ProxyConnectionId.decode(encoded);
        if (connectionId != null) {
          result[key] = connectionId;
        }
      default:
        continue;
    }
  }

  return result;
}

Map<String, String?> _isolationContextRoutesToJson(
  Map<String, ProxyConnectionId?> routes,
) {
  return {
    for (final MapEntry(:key, :value) in routes.entries) key: value?.encode(),
  };
}
