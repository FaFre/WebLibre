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
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/proxy/domain/providers/connection_activity.dart';
import 'package:weblibre/features/proxy/domain/providers/effective_tab_routing.dart';
import 'package:weblibre/features/proxy/domain/services/tab_routing.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'menu_visibility.g.dart';

/// Whether the browser menu shows its Connection section for
/// [selectedTabId].
///
/// With the Tor and proxy controls shown, always. Hidden, the section still
/// stays while the tab needs a connection, any connection is active, or Tor
/// is part of the setup ([torInUse]: set to start automatically, configured,
/// routed), so its status and its controls are never out of reach (P5). The
/// section lists Tor by the same rule, so it never stays empty.
@Riverpod()
bool menuConnectionSectionShown(Ref ref, String? selectedTabId) {
  final connectionsShown = ref.watch(
    shownFeaturesProvider.select(
      (features) => features.contains(FeatureId.connectionsTorBasic),
    ),
  );
  // Every input is watched up front, never behind an early return.
  final connectionActive = ref.watch(anyConnectionActiveProvider);
  final torInUse = ref.watch(torInUseProvider);
  final tabNeedsConnection = ref.watch(
    effectiveTabRoutingProvider(selectedTabId).select(
      (routing) => switch (routing.status) {
        TabRoutingStatus.active ||
        TabRoutingStatus.pending ||
        TabRoutingStatus.blocked => true,
        TabRoutingStatus.direct || TabRoutingStatus.unknown => false,
      },
    ),
  );

  return connectionsShown || connectionActive || torInUse || tabNeedsConnection;
}
