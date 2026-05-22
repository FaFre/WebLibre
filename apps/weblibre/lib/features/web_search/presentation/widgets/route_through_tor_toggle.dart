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
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/features/search_credits/domain/providers/proxy_client.dart';
import 'package:weblibre/features/search_credits/domain/repositories/web_search_settings.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/tor/presentation/controllers/start_tor_proxy.dart';
import 'package:weblibre/presentation/hooks/on_initialization.dart';

class RouteThroughTorToggle extends HookConsumerWidget {
  const RouteThroughTorToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<bool> ensureTorBootstrap() async {
      // Sync the latest native status into the stream first so subsequent
      // listeners (toggle spinner, progress bar, search submit) don't see a
      // stale `null`/`AsyncLoading` state on first build.
      final status = await ref
          .read(torProxyServiceProvider.notifier)
          .requestSync();

      if (status.isRunning) return false;

      await ref.read(startProxyControllerProvider.notifier).startProxy();
      return true;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final routeThroughTor = ref.watch(
      webSearchSettingsControllerProvider.select((s) => s.routeThroughTor),
    );

    final torStatus = ref.watch(torProxyServiceProvider).value;
    final activePort = ref.watch(searchProxyPortProvider);

    final bootstrapProgress = torStatus?.bootstrapProgress ?? 0;

    final showSpinner =
        routeThroughTor && (activePort == null || bootstrapProgress < 100);

    // Push the latest native status into the stream on first build so the
    // bar reflects real progress even when the user lands on the search
    // screen with Tor already mid-bootstrap (otherwise the AsyncLoading
    // state lingers and the bar appears to spin forever at zero).
    useOnInitialization(() async {
      await ref.read(torProxyServiceProvider.notifier).requestSync();
    });

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        final wasTorEnabled = ref
            .read(webSearchSettingsControllerProvider)
            .routeThroughTor;

        ref
            .read(webSearchSettingsControllerProvider.notifier)
            .setRouteThroughTor(!wasTorEnabled);

        if (!wasTorEnabled) {
          await ensureTorBootstrap();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: routeThroughTor
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSpinner)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: routeThroughTor
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.primary,
                ),
              )
            else
              Badge(
                isLabelVisible: torStatus?.isRunning == true,
                backgroundColor: AppColors.of(context).torActiveGreen,
                child: Icon(
                  routeThroughTor
                      ? Icons.shield_rounded
                      : Icons.shield_outlined,
                  color: routeThroughTor
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.primary,
                  size: 18,
                ),
              ),
            const SizedBox(width: 6),
            Text(
              routeThroughTor ? 'Tor on' : 'Tor off',
              style: textTheme.labelLarge?.copyWith(
                color: routeThroughTor
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slim linear progress bar shown directly underneath the search-screen Tor
/// toggle while Tor is bootstrapping. Mirrors the bar on the Tor settings
/// screen so users get the same visual feedback regardless of where they
/// turned Tor on. Returns a zero-height widget when not relevant.
class WebSearchTorBootstrapProgress extends HookConsumerWidget {
  const WebSearchTorBootstrapProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeThroughTor = ref.watch(
      webSearchSettingsControllerProvider.select((s) => s.routeThroughTor),
    );

    if (!routeThroughTor) return const SizedBox.shrink();

    // Push the latest native status into the stream on first build so the
    // bar reflects real progress even when the user lands on the search
    // screen with Tor already mid-bootstrap (otherwise the AsyncLoading
    // state lingers and the bar appears to spin forever at zero).
    useOnInitialization(() async {
      await ref.read(torProxyServiceProvider.notifier).requestSync();
    });

    final torAsync = ref.watch(torProxyServiceProvider);
    final status = torAsync.value;
    final isRunning = status?.isRunning ?? false;
    final bootstrapProgress = status?.bootstrapProgress ?? 0;

    // Hide once Tor is fully running and bootstrapped — otherwise, mirror
    // the Tor settings screen and always show a determinate bar (value
    // anchored to the live bootstrap progress, never indeterminate, so the
    // user can actually track the percentage).
    if (isRunning && bootstrapProgress >= 100) return const SizedBox.shrink();

    final appColors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          minHeight: 3,
          backgroundColor: appColors.torBackgroundGrey,
          color: appColors.torActiveGreen,
          value: bootstrapProgress / 100,
        ),
      ),
    );
  }
}
