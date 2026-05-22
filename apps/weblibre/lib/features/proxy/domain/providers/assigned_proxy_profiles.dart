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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/proxy/data/models/singbox_proxy_profile.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';

part 'assigned_proxy_profiles.g.dart';

/// Returns sing-box proxy profiles that have at least one routing assignment:
/// global regular-tab routing, private-tab routing, or any container.
@Riverpod(keepAlive: true)
List<ProxyProfile> assignedSingboxProxyProfiles(Ref ref) {
  final profiles =
      ref.watch(singboxProxyProfilesRepositoryProvider).value ?? const [];
  if (profiles.isEmpty) return const [];

  final routing = ref.watch(proxyRoutingSettingsWithDefaultsProvider);
  final containers =
      ref.watch(watchContainersWithCountProvider).value ?? const [];

  final assignedConnectionIds = <String>{
    if (routing.regularTabsMode == ProxyRegularTabRoutingMode.all &&
        routing.regularTabsProxyConnectionId != null)
      routing.regularTabsProxyConnectionId!.encode(),
    if (routing.privateTabsProxyConnectionId != null)
      routing.privateTabsProxyConnectionId!.encode(),
    for (final container in containers)
      if (container.metadata.proxyConnectionId != null)
        container.metadata.proxyConnectionId!.encode(),
  };

  if (assignedConnectionIds.isEmpty) return const [];

  return [
    for (final profile in profiles)
      if (assignedConnectionIds.contains(profile.proxyConnectionId)) profile,
  ];
}
