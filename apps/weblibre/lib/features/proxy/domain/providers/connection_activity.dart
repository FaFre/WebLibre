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
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/domain/services/connection_usage.dart';
import 'package:weblibre/features/tor/domain/extensions/tor_status_x.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/data/models/tor_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';

part 'connection_activity.g.dart';

/// Whether any connection is up or on its way up: Tor, or a sing-box
/// profile.
///
/// A running connection keeps its status and its stop control on screen
/// whatever the Connections switch says, and whichever tab is selected.
@Riverpod(keepAlive: true)
bool anyConnectionActive(Ref ref) {
  final torActive = ref.watch(
    torProxyServiceProvider.select(
      (tor) => tor.value != null && (tor.value!.isRunning || tor.value!.isBusy),
    ),
  );
  final singboxRunning = ref.watch(runningSingboxProfileIdsProvider);
  final singboxStarting = ref.watch(singboxProxyStartingConnectionsProvider);

  return torActive || singboxRunning.isNotEmpty || singboxStarting.isNotEmpty;
}

/// Whether Tor is part of the user's setup, so its status and controls stay
/// on screen while Connections is hidden (P5): running or on its way up, set
/// to start automatically — which may have failed, leaving it stopped —
/// configured away from the defaults, or named by any route (global, private
/// tabs, a container, an isolated group).
///
/// One rule for every place that lists Tor: the browser menu's Connection
/// section, the connection list, and whether Settings keeps its Proxy
/// category.
@Riverpod()
bool torInUse(Ref ref) {
  // Every input is watched up front, never behind an early return, so each
  // stays subscribed and loaded whichever one decides the answer.
  final torActive = ref.watch(
    torProxyServiceProvider.select(
      (tor) => tor.value != null && (tor.value!.isRunning || tor.value!.isBusy),
    ),
  );
  final settings = ref.watch(torSettingsWithDefaultsProvider);
  final routed = !proxyConnectionUsage(
    id: const TorProxyConnectionId(),
    routingSettings: ref.watch(proxyRoutingSettingsWithDefaultsProvider),
    containers:
        ref.watch(
          watchContainersWithCountProvider.select((value) => value.value),
        ) ??
        const [],
  ).isUnused;

  return torActive ||
      settings.autostart ||
      settings != TorSettings.withDefaults() ||
      routed;
}
