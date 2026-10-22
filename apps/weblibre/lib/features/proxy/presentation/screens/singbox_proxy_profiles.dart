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
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_input_consumer.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_latency_tester.dart';
import 'package:weblibre/features/proxy/domain/services/singbox_start_retry.dart';
import 'package:weblibre/features/proxy/presentation/utils/proxy_profile_seed_l10n.dart';
import 'package:weblibre/features/proxy/presentation/widgets/add_proxy_method_sheet.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/profile_tile.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/status_header.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/tor_tile.dart';
import 'package:weblibre/features/tor/domain/extensions/tor_status_x.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart';

class SingboxProxyProfilesScreen extends HookConsumerWidget {
  const SingboxProxyProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profilesAsync = ref.watch(singboxProxyProfilesRepositoryProvider);
    final runtimeState = ref.watch(singboxProxyRuntimeRepositoryProvider);
    final torState = ref.watch(torProxyServiceProvider);
    final deletingProfileIds = useState(<String>{});

    final activeProfileIds = runtimeState.runningProfileIds;
    final startingProfileIds = _startingProfileIds(
      ref.watch(singboxProxyStartingConnectionsProvider),
    );
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
        label: Text(l10n.proxy_addProfile),
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
                  title: Text(l10n.proxy_connectionsTitle),
                  actions: [
                    IconButton(
                      tooltip: l10n.proxy_viewLogsTooltip,
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
                        startingProfileIds: startingProfileIds,
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
                              l10n.proxy_loadProfilesFailed(error.toString()),
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

/// The profiles a start or reload is in flight for.
///
/// Every start and stop reloads the runtime with all of its profiles, and for
/// the duration it reports none of them as running — so this, not the runtime
/// state, is what says a profile is on its way up rather than stopped.
Set<String> _startingProfileIds(Set<String> encodedConnectionIds) {
  return {
    for (final encoded in encodedConnectionIds) ?singboxProfileIdOf(encoded),
  };
}

void _pruneLatencyCache(WidgetRef ref) {
  final runtimeState = ref.read(singboxProxyRuntimeRepositoryProvider);
  // Every start or stop reloads the runtime with all of its profiles, and while
  // it does it reports none of them as running. Pruning against that threw away
  // the test result of every profile whenever any one was started or stopped;
  // what actually stopped is only known once the reload settles.
  if (runtimeState.isLoading ||
      runtimeState.value?.status == SingboxProxyRuntimeStatus.starting) {
    return;
  }

  final torRunning =
      ref.read(torProxyServiceProvider).value?.isRunning ?? false;
  ref.read(proxyLatencyResultsProvider.notifier).retainRunning({
    for (final profileId in runtimeState.runningProfileIds)
      SingboxProxyConnectionId(profileId),
    if (torRunning) const TorProxyConnectionId(),
  });
}

Future<void> _showAddSheet(BuildContext context) async {
  final action = await showModalBottomSheet<AddProxyAction>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
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
    case AddProxyImported(:final message, :final notes) when notes.isEmpty:
      showInfoMessage(context, message);
    case AddProxyImported(:final message, :final notes):
      await showDialog<void>(
        context: context,
        anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
        builder: (context) =>
            _ImportNotesDialog(message: message, notes: notes),
      );
  }
}

/// A bulk import's result together with what it noted about the proxies it
/// stored, which no editor showed before they were saved.
class _ImportNotesDialog extends StatelessWidget {
  final String message;
  final List<ImportedProfileNote> notes;

  const _ImportNotesDialog({required this.message, required this.notes});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(message),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (:profileName, :note) in notes) ...[
              Text(profileName, style: textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(note.describe(context), style: textTheme.bodyMedium),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.common_close),
        ),
      ],
    );
  }
}

class _ProfileListBody extends ConsumerWidget {
  final List<ProxyProfile> profiles;
  final Set<String> activeProfileIds;

  /// Profiles the runtime is bringing up, or back up. See [_startingProfileIds].
  final Set<String> startingProfileIds;
  final Set<String> deletingProfileIds;
  final bool runtimeBusy;
  final bool torIsRunning;
  final bool torIsBusy;
  final void Function(String id, bool deleting) onDeletingChanged;

  const _ProfileListBody({
    required this.profiles,
    required this.activeProfileIds,
    required this.startingProfileIds,
    required this.deletingProfileIds,
    required this.runtimeBusy,
    required this.torIsRunning,
    required this.torIsBusy,
    required this.onDeletingChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Listed, sorted and counted as running while on their way up, so a reload
    // does not empty the running set for a moment — which flicked every switch
    // off, dropped the count, and moved the running tiles down and back.
    final shownRunningIds = {...activeProfileIds, ...startingProfileIds};
    final sorted = [...profiles]
      ..sort((a, b) {
        final aRunning = shownRunningIds.contains(a.id);
        final bRunning = shownRunningIds.contains(b.id);
        if (aRunning == bRunning) return 0;
        return aRunning ? -1 : 1;
      });

    final scheme = Theme.of(context).colorScheme;
    final totalRunning = shownRunningIds.length + (torIsRunning ? 1 : 0);
    final totalCount = profiles.length + 1;
    // A profile waiting for a retry is not running, but it will come up by
    // itself: with every autostart failed, stopping all is the only way to
    // call those retries off short of deleting the profiles.
    final hasPendingRetries = ref.watch(
      singboxStartRetriesProvider.select((retries) => retries.isNotEmpty),
    );

    Future<void> stopAll() async {
      // Including a profile waiting to be started again after a failed
      // unattended start: it is not running, but it would come up by itself
      // after the user stopped everything.
      ref.read(singboxStartRetriesProvider.notifier).cancelAll();
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
            onStopAll: totalRunning == 0 && !hasPendingRetries ? null : stopAll,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            l10n.proxy_profilesSectionTitle,
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
                    isStarting:
                        startingProfileIds.contains(profile.id) &&
                        !activeProfileIds.contains(profile.id),
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
