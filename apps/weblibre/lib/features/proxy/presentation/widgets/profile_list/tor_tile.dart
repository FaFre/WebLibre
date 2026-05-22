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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_latency_tester.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/menu_row.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/profile_subtitle.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/run_switch.dart';
import 'package:weblibre/features/tor/domain/extensions/tor_status_x.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/presentation/icons/tor_icons.dart';
import 'package:weblibre/utils/ui_helper.dart';

enum TorAction { edit, testLatency }

class TorProfileTile extends ConsumerWidget {
  final bool isRunning;
  final bool isBusy;

  const TorProfileTile({
    super.key,
    required this.isRunning,
    required this.isBusy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final background = isRunning
        ? scheme.primary.withValues(alpha: 0.15)
        : scheme.surfaceContainerHighest;
    final foreground = isRunning ? scheme.primary : scheme.onSurfaceVariant;
    final latencyResult = ref.watch(
      proxyLatencyResultsProvider.select(
        (map) => map[const TorProxyConnectionId()],
      ),
    );
    final torReady = ref.watch(
      torProxyServiceProvider.select((s) => s.isReady),
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(TorIcons.onionAlt, color: foreground, size: 24),
      ),
      title: Text(
        'Tor',
        style: TextStyle(
          fontWeight: isRunning ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      subtitle: ProfileSubtitle(
        typeLabel: 'Onion routing',
        latency: latencyResult,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<TorAction>(
            enabled: !isBusy,
            onSelected: (action) async {
              switch (action) {
                case TorAction.edit:
                  await const TorProxyRoute().push(context);
                case TorAction.testLatency:
                  await ref
                      .read(proxyLatencyResultsProvider.notifier)
                      .testTor();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TorAction.edit,
                child: MenuRow(icon: Icons.edit_outlined, label: 'Edit'),
              ),
              PopupMenuItem(
                value: TorAction.testLatency,
                enabled: torReady,
                child: MenuRow(
                  icon: latencyResult is AsyncLoading
                      ? Icons.hourglass_bottom
                      : Icons.network_check,
                  label: 'Test connection',
                ),
              ),
            ],
          ),
          RunSwitch(
            isRunning: isRunning,
            disabled: isBusy,
            onTap: () => _toggle(context, ref),
          ),
        ],
      ),
      onTap: () => const TorProxyRoute().push(context),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    try {
      final service = ref.read(torProxyServiceProvider.notifier);
      if (isRunning) {
        await service.disconnect();
        ref
            .read(proxyLatencyResultsProvider.notifier)
            .clear(const TorProxyConnectionId());
      } else {
        await service.startOrReconfigure(reconfigureIfRunning: false);
      }
    } catch (error, stackTrace) {
      logger.e(
        'Failed to toggle Tor proxy',
        error: error,
        stackTrace: stackTrace,
      );
      if (context.mounted) {
        showErrorMessage(
          context,
          isRunning
              ? 'Failed to stop Tor: $error'
              : 'Failed to start Tor: $error',
        );
      }
    }
  }
}
