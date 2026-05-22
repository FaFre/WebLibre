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
import 'dart:async';

import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_latency_tester.dart';
import 'package:weblibre/features/proxy/presentation/widgets/add_proxy_method_sheet.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/profile_tile.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/status_header.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/tor_tile.dart';
import 'package:weblibre/features/tor/domain/extensions/tor_status_x.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;
import 'package:weblibre/utils/ui_helper.dart';

class SingboxProxyProfilesScreen extends HookConsumerWidget {
  const SingboxProxyProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(singboxProxyProfilesRepositoryProvider);
    final runtimeState = ref.watch(singboxProxyRuntimeRepositoryProvider);
    final torState = ref.watch(torProxyServiceProvider);
    final deletingProfileIds = useState(<String>{});

    final activeProfileIds = _activeProfileIds(runtimeState);
    final runtimeBusy = runtimeState.isLoading;
    final torIsRunning = torState.value?.isRunning ?? false;
    final torIsBusy = torState.isBusy;

    // Drop cached latency results for profiles that are no longer running so a
    // stale "120 ms" chip can't outlive its connection.
    ref.listen(singboxProxyRuntimeRepositoryProvider, (_, _) {
      _pruneLatencyCache(ref);
    });
    ref.listen(torProxyServiceProvider, (_, _) {
      _pruneLatencyCache(ref);
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => unawaited(_showAddSheet(context)),
        icon: const Icon(Icons.add),
        label: const Text('Add Profile'),
      ),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return CustomScrollView(
              controller: controller,
              slivers: [
                SliverAppBar.large(
                  centerTitle: false,
                  title: const Text('Proxy Connections'),
                  actions: [
                    IconButton(
                      tooltip: 'View logs',
                      icon: const Icon(Icons.subject),
                      onPressed: () =>
                          const SingboxProxyLogsRoute().push(context),
                    ),
                  ],
                ),
                ...profilesAsync.when(
                  data: (profiles) {
                    // Prune ids whose profile was deleted (or otherwise
                    // disappeared) so the set can't grow unbounded if a tile
                    // is unmounted while its delete is still in flight.
                    final liveProfileIds = {
                      for (final profile in profiles) profile.id,
                    };
                    final pruned = deletingProfileIds.value.intersection(
                      liveProfileIds,
                    );
                    if (pruned.length != deletingProfileIds.value.length) {
                      // Schedule for the next frame to avoid mutating state
                      // during build.
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        deletingProfileIds.value = pruned;
                      });
                    }

                    return [
                      _ProfileListBody(
                        profiles: profiles,
                        activeProfileIds: activeProfileIds,
                        deletingProfileIds: pruned,
                        runtimeBusy: runtimeBusy,
                        torIsRunning: torIsRunning,
                        torIsBusy: torIsBusy,
                        onDeletingChanged: (id, deleting) {
                          final next = {...deletingProfileIds.value};
                          if (deleting) {
                            next.add(id);
                          } else {
                            next.remove(id);
                          }
                          deletingProfileIds.value = next;
                        },
                      ),
                    ];
                  },
                  loading: () => const [
                    SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                  error: (error, stackTrace) {
                    logger.e(
                      'Failed to load singbox proxy profiles',
                      error: error,
                      stackTrace: stackTrace,
                    );
                    return [
                      SliverFillRemaining(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'Failed to load proxy profiles:\n$error',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Set<ProxyConnectionId> _activeConnectionIds(
  AsyncValue<SingboxProxyRuntimeState> runtimeState,
) {
  return runtimeState.asData?.value.endpoints
          .map((endpoint) => ProxyConnectionId.decode(endpoint.profileId))
          .nonNulls
          .toSet() ??
      const <ProxyConnectionId>{};
}

Set<String> _activeProfileIds(
  AsyncValue<SingboxProxyRuntimeState> runtimeState,
) {
  return _activeConnectionIds(
    runtimeState,
  ).whereType<SingboxProxyConnectionId>().map((id) => id.profileId).toSet();
}

void _pruneLatencyCache(WidgetRef ref) {
  final runtimeState = ref.read(singboxProxyRuntimeRepositoryProvider);
  final torRunning =
      ref.read(torProxyServiceProvider).value?.isRunning ?? false;
  ref.read(proxyLatencyResultsProvider.notifier).retainRunning({
    ..._activeConnectionIds(runtimeState),
    if (torRunning) const TorProxyConnectionId(),
  });
}

Future<void> _showAddSheet(BuildContext context) async {
  final action = await showModalBottomSheet<AddProxyAction>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const AddProxyMethodSheet(),
  );
  if (action == null) return;
  if (!context.mounted) return;
  switch (action) {
    case AddProxyManual():
      await const SingboxProxyProfileEditorRoute().push(context);
    case AddProxySubscription():
      await const SubscriptionImportRoute().push(context);
    case AddProxyWithSeed(:final seed):
      await SingboxProxyProfileEditorRoute($extra: seed).push(context);
    case AddProxyImported(:final message):
      showInfoMessage(context, message);
  }
}

class _ProfileListBody extends ConsumerWidget {
  final List<ProxyProfile> profiles;
  final Set<String> activeProfileIds;
  final Set<String> deletingProfileIds;
  final bool runtimeBusy;
  final bool torIsRunning;
  final bool torIsBusy;
  final void Function(String id, bool deleting) onDeletingChanged;

  const _ProfileListBody({
    required this.profiles,
    required this.activeProfileIds,
    required this.deletingProfileIds,
    required this.runtimeBusy,
    required this.torIsRunning,
    required this.torIsBusy,
    required this.onDeletingChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = [...profiles]
      ..sort((a, b) {
        final aRunning = activeProfileIds.contains(a.id);
        final bRunning = activeProfileIds.contains(b.id);
        if (aRunning == bRunning) return 0;
        return aRunning ? -1 : 1;
      });

    final scheme = Theme.of(context).colorScheme;
    final totalRunning = activeProfileIds.length + (torIsRunning ? 1 : 0);
    final totalCount = profiles.length + 1;

    Future<void> stopAll() async {
      await ref.read(singboxProxyRuntimeRepositoryProvider.notifier).stopAll();
      ref.read(proxyLatencyResultsProvider.notifier).retainRunning(const {});
      if (torIsRunning) {
        await ref.read(torProxyServiceProvider.notifier).disconnect();
      }
    }

    return SliverList.list(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: StatusHeader(
            totalCount: totalCount,
            runningCount: totalRunning,
            isBusy: runtimeBusy || torIsBusy,
            onStopAll: totalRunning == 0 ? null : stopAll,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'Profiles',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          child: Card.filled(
            margin: EdgeInsets.zero,
            color: scheme.surfaceContainer,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                TorProfileTile(isRunning: torIsRunning, isBusy: torIsBusy),
                for (final profile in sorted) ...[
                  const Divider(height: 1),
                  ProfileTile(
                    profile: profile,
                    isRunning: activeProfileIds.contains(profile.id),
                    isDeleting: deletingProfileIds.contains(profile.id),
                    runtimeBusy: runtimeBusy,
                    onDeletingChanged: onDeletingChanged,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
