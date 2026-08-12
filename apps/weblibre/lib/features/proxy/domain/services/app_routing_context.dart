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
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';

/// The cookie-store context a tab's requests belong to, matching how the proxy
/// extension derives one for a tab.
Future<String> routingContextIdForTab(Ref ref, TabState? tabState) async {
  if (tabState == null) return generalContextId;
  if (tabState.tabMode is PrivateTabMode) return privateContextId;

  // Isolated tabs load under their isolation context, and the snapshot carries
  // an alias for it whenever it does not simply inherit.
  if (tabState.isolationContextId case final isolationContextId?) {
    return isolationContextId;
  }

  final containerData = await ref
      .read(tabDataRepositoryProvider.notifier)
      .getTabContainerData(tabState.id);

  return containerData?.metadata.contextualIdentity ?? generalContextId;
}

/// The context an app-originated request belongs to when it is made on behalf
/// of whatever the user is currently looking at.
///
/// Suggestions, favicon lookups and link expansions describe the browsing the
/// selected tab is doing, so they have to travel that tab's route rather than
/// the general container's. Resolving against [generalContextId] instead is how
/// a keystroke typed into a Tor container's tab reaches the suggestion provider
/// over a direct connection.
///
/// Read rather than watched: the answer must be the context in force when the
/// request is made, not the one that was in force when a client was built.
Future<String> routingContextIdForSelectedTab(Ref ref) {
  return routingContextIdForTab(ref, ref.read(selectedTabStateProvider));
}
