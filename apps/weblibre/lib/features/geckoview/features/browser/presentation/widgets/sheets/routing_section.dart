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

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/proxy_settings_replication.dart';
import 'package:weblibre/features/proxy/domain/providers/effective_tab_routing.dart';
import 'package:weblibre/features/proxy/domain/services/tab_routing.dart';
import 'package:weblibre/features/proxy/presentation/widgets/tab_routing_tile.dart';

/// How the tab's traffic is routed, followed by a divider.
///
/// Shown to anyone with a proxy route anywhere, and to everyone whenever the
/// tab is not simply connecting directly: someone who never set up a proxy
/// does not need a row saying so on every site, but a blocked or still
/// starting route concerns everyone.
class RoutingSection extends ConsumerWidget {
  final String tabId;

  /// Dismisses the enclosing sheet before the proxy settings open.
  final VoidCallback onClose;

  const RoutingSection({super.key, required this.tabId, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routing = ref.watch(effectiveTabRoutingProvider(tabId));
    final hasAnyRoute = ref.watch(
      containerRoutingSnapshotProvider.select(
        (snapshot) =>
            snapshot?.relations.values.any((proxies) => proxies.isNotEmpty) ??
            false,
      ),
    );

    final isPlainDirect =
        routing.status == TabRoutingStatus.direct && !routing.isContextMismatch;
    if (isPlainDirect && !hasAnyRoute) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabRoutingTile(
          routing: routing,
          onOpenSettings: () async {
            onClose();
            await const ProxySettingsRoute().push<void>(context);
          },
        ),
        const Divider(),
      ],
    );
  }
}
