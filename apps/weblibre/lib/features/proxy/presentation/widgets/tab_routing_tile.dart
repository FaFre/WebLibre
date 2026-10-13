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
import 'package:weblibre/features/proxy/domain/services/tab_routing.dart';
import 'package:weblibre/features/proxy/presentation/controllers/ensure_proxy_started.dart';
import 'package:weblibre/features/proxy/presentation/utils/tab_routing_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// One row saying how a tab's traffic is routed, with the fix at hand when it
/// is blocked: a route naming a proxy that is not running blocks the tab
/// rather than falling back to a direct connection, so starting that proxy is
/// always the way out.
class TabRoutingTile extends ConsumerWidget {
  final TabRouting routing;

  /// Opens the proxy settings. The caller decides how, since it may have to
  /// close the surface this row sits on first.
  final VoidCallback onOpenSettings;

  const TabRoutingTile({
    super.key,
    required this.routing,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, iconColor) = routing.statusIcon(context);

    final blockedConnectionId = routing.status == TabRoutingStatus.blocked
        ? routing.proxyConnectionId
        : null;

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(l10n.proxy_tabRoutingTitle),
      subtitle: Text(
        routing.describe(context),
        style: routing.isRoutingProblem
            ? TextStyle(color: colorScheme.error)
            : null,
      ),
      trailing: blockedConnectionId != null
          ? FilledButton.tonal(
              onPressed: () => ensureProxyStartedForConnection(
                context,
                ref,
                blockedConnectionId,
              ),
              child: Text(l10n.proxy_actionStart),
            )
          : const Icon(Icons.chevron_right),
      onTap: onOpenSettings,
    );
  }
}
