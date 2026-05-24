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
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/providers/proxy_connection_options.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/tor/presentation/controllers/start_tor_proxy.dart';
import 'package:weblibre/features/tor/presentation/widgets/tor_dialog.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Single entry point that prompts the user to start whichever proxy backend
/// a container is configured to use. No-op when the container has no proxy
/// assigned or when the relevant backend is already running.
Future<bool> ensureProxyStartedForContainer(
  BuildContext context,
  WidgetRef ref,
  ContainerData container,
) {
  return ensureProxyStartedForConnection(
    context,
    ref,
    container.metadata.proxyConnectionId,
  );
}

Future<bool> ensureProxyStartedForConnection(
  BuildContext context,
  WidgetRef ref,
  ProxyConnectionId? proxyConnectionId,
) async {
  if (proxyConnectionId == null) return true;

  if (proxyConnectionId is TorProxyConnectionId) {
    return await _ensureTorStarted(context, ref);
  }

  if (proxyConnectionId is SingboxProxyConnectionId) {
    return await _maybeStartSingboxProxy(context, ref, proxyConnectionId);
  }

  return true;
}

Future<bool> _ensureTorStarted(BuildContext context, WidgetRef ref) async {
  final shouldPrompt = await ref
      .read(startProxyControllerProvider.notifier)
      .shouldPromptProxyStart();
  if (!context.mounted) return false;
  if (!shouldPrompt) return true;

  final dialogResult = await showDialog<bool>(
    context: context,
    builder: (context) => const TorDialog(),
  );

  if (dialogResult == true) {
    await ref.read(startProxyControllerProvider.notifier).startProxy();
    return true;
  }

  return false;
}

Future<bool> _maybeStartSingboxProxy(
  BuildContext context,
  WidgetRef ref,
  SingboxProxyConnectionId proxyConnectionId,
) async {
  // Await any start/stop in flight so we don't prompt the user a second time
  // while a start they already triggered is still resolving. If the runtime
  // provider is already in AsyncError, keep treating that as "not running" so
  // the user can retry from the container entry point.
  final runtimeState = ref.read(singboxProxyRuntimeRepositoryProvider);
  final resolvedRuntimeState = await switch (runtimeState) {
    AsyncData(:final value) => Future.value(value),
    AsyncLoading() => _resolveRuntimeStateForPrompt(ref),
    AsyncError(:final error, :final stackTrace) => Future.value(
      _runtimeStateRetryFallback(
        error: error,
        stackTrace: stackTrace,
        message:
            'Singbox proxy runtime is in error state; continuing so the user can retry startup',
      ),
    ),
  };
  if (!context.mounted) return false;

  final isRunning = resolvedRuntimeState.endpoints.any(
    (endpoint) => endpoint.profileId == proxyConnectionId.encode(),
  );

  if (isRunning) return true;

  final proxyTitle = await _proxyConnectionTitleForPrompt(
    ref,
    proxyConnectionId,
  );

  if (!context.mounted) return false;

  final shouldStart = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.route_outlined),
      title: const Text('Start Proxy Connection?'),
      content: Text(
        'This tab needs $proxyTitle, but that connection is not running. Start it now?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Start'),
        ),
      ],
    ),
  );

  if (shouldStart != true) return false;

  try {
    await ref
        .read(singboxProxyRuntimeRepositoryProvider.notifier)
        .startProfile(proxyConnectionId.profileId);
    return true;
  } catch (error, stackTrace) {
    logger.e(
      'Failed to start singbox proxy profile ${proxyConnectionId.profileId}',
      error: error,
      stackTrace: stackTrace,
    );
    if (context.mounted) {
      showErrorMessage(context, 'Failed to start proxy: $error');
    }
    return false;
  }
}

Future<String> _proxyConnectionTitleForPrompt(
  WidgetRef ref,
  ProxyConnectionId proxyConnectionId,
) async {
  final options = ref.read(proxyConnectionOptionsProvider);
  final title = proxyConnectionTitle(options, proxyConnectionId);

  if (title != unknownProxyTitle) {
    return title;
  }

  if (proxyConnectionId is SingboxProxyConnectionId) {
    try {
      final profile = await ref
          .read(singboxProxyProfilesRepositoryProvider.notifier)
          .findProfile(proxyConnectionId.profileId);
      if (profile != null) return profile.name;
    } catch (error, stackTrace) {
      logger.w(
        'Failed to resolve sing-box proxy profile ${proxyConnectionId.profileId} for prompt title',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  return proxyConnectionTitle(options, proxyConnectionId);
}

Future<SingboxProxyRuntimeState> _resolveRuntimeStateForPrompt(
  WidgetRef ref,
) async {
  try {
    return await ref.read(singboxProxyRuntimeRepositoryProvider.future);
  } catch (error, stackTrace) {
    return _runtimeStateRetryFallback(
      error: error,
      stackTrace: stackTrace,
      message:
          'Singbox proxy runtime is unresolved; continuing so the user can retry startup',
    );
  }
}

SingboxProxyRuntimeState _runtimeStateRetryFallback({
  required Object error,
  required StackTrace stackTrace,
  required String message,
}) {
  logger.w(message, error: error, stackTrace: stackTrace);
  return SingboxProxyRuntimeState(
    status: SingboxProxyRuntimeStatus.error,
    endpoints: const [],
    message: error.toString(),
  );
}
