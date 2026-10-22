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
import 'package:weblibre/features/proxy/domain/services/proxy_health.dart';
import 'package:weblibre/features/proxy/presentation/utils/proxy_health_l10n.dart';

/// Says what is wrong with a connection, beyond whether it is on.
class ProxyConditionChip extends StatelessWidget {
  final ProxyConnectionCondition condition;

  const ProxyConditionChip({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            switch (condition) {
              ProxyConnectionCondition.notResponding => Icons.cloud_off,
              ProxyConnectionCondition.startRetrying => Icons.sync_problem,
              ProxyConnectionCondition.startFailed => Icons.error_outline,
            },
            size: 12,
            color: scheme.onErrorContainer,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              condition.label(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
