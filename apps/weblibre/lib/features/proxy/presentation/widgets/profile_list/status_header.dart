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
import 'package:weblibre/l10n/generated/app_localizations.dart';

class StatusHeader extends StatelessWidget {
  final int totalCount;
  final int runningCount;
  final bool isBusy;
  final VoidCallback? onStopAll;

  const StatusHeader({
    super.key,
    required this.totalCount,
    required this.runningCount,
    required this.isBusy,
    required this.onStopAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isAnyRunning = runningCount > 0;

    final background = isAnyRunning
        ? scheme.primaryContainer
        : scheme.surfaceContainerHigh;
    final onBackground = isAnyRunning
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: onBackground.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAnyRunning ? Icons.cloud_done : Icons.cloud_off_outlined,
              color: onBackground,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAnyRunning
                      ? l10n.proxy_statusActive
                      : l10n.proxy_statusDisconnected,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: onBackground,
                  ),
                ),
                Text(
                  isAnyRunning
                      ? l10n.proxy_statusRoutingTraffic(
                          runningCount,
                          totalCount,
                        )
                      : l10n.proxy_statusTapToConnect,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: onBackground.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (onStopAll != null)
            IconButton.filled(
              tooltip: l10n.proxy_stopAllTooltip,
              onPressed: isBusy ? null : onStopAll,
              style: IconButton.styleFrom(
                backgroundColor: scheme.errorContainer,
                foregroundColor: scheme.onErrorContainer,
              ),
              icon: const Icon(Icons.stop_rounded),
            ),
        ],
      ),
    );
  }
}
