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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/proxy_settings_replication.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/proxy/domain/providers/proxy_connection_options.dart';
import 'package:weblibre/features/proxy/domain/repositories/container_proxy.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/services/tab_routing.dart';

part 'effective_tab_routing.g.dart';

/// How often the extension is asked whether it still holds a snapshot.
///
/// Only runs while something is watching [containerRoutingInstalled] — i.e.
/// while a sheet is showing routing state — so this is a UI refresh rate, not a
/// background poll. [ProxySettingsReplication] owns the real repair loop.
const _readinessPollInterval = Duration(seconds: 3);

/// Whether the proxy extension currently holds an acknowledged routing
/// snapshot. While it does not, it blocks every request.
///
/// There is no push notification for this — readiness can be lost without any
/// app-side input changing (the extension's background script restarts and its
/// replay fails) — so the UI polls for as long as it is displaying the answer.
@riverpod
Stream<bool> containerRoutingInstalled(Ref ref) async* {
  while (ref.mounted) {
    try {
      yield await ref
          .read(containerProxyRepositoryProvider.notifier)
          .isRoutingReady();
    } catch (error, stackTrace) {
      // Throws while the native channel is still coming up, which is exactly
      // the window where routing is not installed yet.
      logger.d(
        'Container routing status probe failed',
        error: error,
        stackTrace: stackTrace,
      );
      yield false;
    }

    await Future<void>.delayed(_readinessPollInterval);
  }
}

/// How the tab identified by [tabId] is routed right now.
///
/// Reads back the snapshot the extension was given rather than re-deriving
/// routing from settings, so this cannot drift from what the engine actually
/// does. See [resolveTabRouting].
@riverpod
TabRouting effectiveTabRouting(Ref ref, String? tabId) {
  final tabState = ref.watch(tabStateProvider(tabId));
  // Only the engine knows which cookie store a tab's requests carry, and that
  // is what the extension routes on. With no engine state there is no context
  // to resolve — reporting the general one would answer "direct" for a tab
  // whose container is proxied.
  final contextId = tabState == null
      ? null
      : tabRoutingContextId(
          contextId: tabState.contextId,
          isPrivate: tabState.tabMode is PrivateTabMode,
        );

  final container = ref.watch(watchTabContainerDataProvider(tabId)).value;

  final options = ref.watch(proxyConnectionOptionsProvider);
  final optionsLoading = ref
      .watch(singboxProxyProfilesRepositoryProvider)
      .isLoading;

  return resolveTabRouting(
    snapshot: ref.watch(containerRoutingSnapshotProvider),
    // Private and isolated tabs are in a context of their own by design, so
    // their container's identity is not the one they are expected to carry.
    containerContextId: tabState?.tabMode is RegularTabMode
        ? container?.metadata.contextualIdentity
        : null,
    // A probe that has not answered yet is treated as installed: the snapshot
    // being non-null already means the app has one to push, and reporting
    // "pending" for the first frame of every sheet would flicker a scary state
    // on a healthy browser.
    routingInstalled:
        ref.watch(containerRoutingInstalledProvider).value ?? true,
    contextId: contextId,
    containerName: container?.name,
    proxyTitle: (id) =>
        proxyConnectionTitle(options, id, isLoading: optionsLoading),
  );
}
