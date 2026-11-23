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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';

part 'container_freeze.g.dart';

/// Notices the browser has not shown yet: what the start-time reconciliation
/// found, and what came of actions that have no screen of their own. Kept
/// until taken, because they can come before the browser screen is up.
@Riverpod(keepAlive: true)
class ContainerFreezeNotices extends _$ContainerFreezeNotices {
  @override
  List<ContainerFreezeNotice> build() => const [];

  void add(ContainerFreezeNotice notice) => state = [...state, notice];

  /// The notices to show now; they are not handed out again.
  List<ContainerFreezeNotice> take() {
    final taken = state;
    if (taken.isNotEmpty) state = const [];
    return taken;
  }
}

/// How far restoring the frozen containers after a damaged registry got, for
/// the Containers screen ([FreezeRecoveryStatus]).
@Riverpod(keepAlive: true)
class FreezeRecoveryProgress extends _$FreezeRecoveryProgress {
  @override
  FreezeRecoveryStatus build() => FreezeRecoveryStatus.none;

  void set(FreezeRecoveryStatus status) {
    if (state != status) state = status;
  }
}

/// Native's freeze registry as last reported, for what the user sees (5.10).
/// The membership gate reads its own snapshot instead (D27).
@Riverpod(keepAlive: true)
Stream<LifecycleSnapshot> contextFreezeSnapshot(Ref ref) async* {
  final eventService = ref.watch(eventServiceProvider);
  var latest = await ref
      .read(geckoTabLifecycleServiceProvider)
      .lifecycleSnapshot();
  yield latest;
  await for (final snapshot in eventService.contextFreezeEvents) {
    if (snapshot.revision < latest.revision) continue;
    latest = snapshot;
    yield snapshot;
  }
}

/// Every restricted container's freeze, keyed by container id; empty until
/// native answered. A new snapshot that leaves every container's freeze as it
/// was notifies nobody.
@Riverpod(keepAlive: true)
EquatableValue<Map<String, ContainerFreezeView>> frozenContainers(Ref ref) {
  final snapshot = ref.watch(
    contextFreezeSnapshotProvider.select((value) => value.value),
  );
  if (snapshot == null) return EquatableValue(const {});
  return EquatableValue(ContainerFreezeView.fromSnapshot(snapshot));
}

/// Whether native is in recovery mode: every container is frozen until the
/// containers are reconstructed (D23).
@Riverpod(keepAlive: true)
bool freezeRecoveryMode(Ref ref) => ref.watch(
  contextFreezeSnapshotProvider.select(
    (value) => value.value?.mode == LifecycleRegistryMode.recovery,
  ),
);

/// [containerId]'s freeze, or null while it is not restricted.
@Riverpod()
ContainerFreezeView? containerFreezeState(Ref ref, String? containerId) {
  if (containerId == null) return null;
  return ref.watch(
    frozenContainersProvider.select(
      (containers) => containers.value[containerId],
    ),
  );
}

/// The last teardown progress native reported for a freeze of [containerId];
/// read it only while the container's operation is a freeze.
@Riverpod()
Stream<FreezeProgress> containerFreezeProgress(
  Ref ref,
  String containerId,
) async* {
  final eventService = ref.watch(eventServiceProvider);
  await for (final progress in eventService.contextFreezeProgressEvents) {
    if (progress.ownerId == containerId) {
      yield FreezeProgress(done: progress.done, total: progress.total);
    }
  }
}

/// Everything listed under "Site data waiting to be deleted", from native's
/// registry: `releasing` contexts grouped by their container, deleted or
/// not, and each `orphaned` context on its own.
@Riverpod(keepAlive: true)
EquatableValue<List<PendingSiteData>> pendingSiteData(Ref ref) {
  final contexts = ref.watch(
    contextFreezeSnapshotProvider.select(
      (value) => EquatableValue(value.value?.contexts ?? const []),
    ),
  );
  if (!contexts.value.any(
    (context) => context.phase == ContextFreezePhase.releasing,
  )) {
    return _pendingSiteData(contexts.value, const {});
  }
  // The keepAlive list, which the container UI keeps running anyway; the
  // select drops the re-emissions its tab counts cause.
  final names = ref
      .watch(
        watchContainersWithCountProvider.select(
          (value) => EquatableValue({
            for (final container in value.value ?? const <ContainerData>[])
              container.id: container.name,
          }),
        ),
      )
      .value;
  return _pendingSiteData(contexts.value, names);
}

/// [pendingSiteData] of [contexts], with [names] the containers that exist.
EquatableValue<List<PendingSiteData>> _pendingSiteData(
  List<ContextFreezeState> contexts,
  Map<String, String?> names,
) {
  final releasing = <String?, List<String>>{};
  final pending = <PendingSiteData>[];
  for (final context in contexts) {
    switch (context.phase) {
      case ContextFreezePhase.releasing:
        (releasing[context.ownerId] ??= []).add(context.contextId);
      case ContextFreezePhase.orphaned:
        pending.add(
          PendingSiteData(
            ownerId: null,
            contextIds: [context.contextId],
            orphaned: true,
          ),
        );
      case ContextFreezePhase.unrestricted ||
          ContextFreezePhase.freezing ||
          ContextFreezePhase.frozen ||
          ContextFreezePhase.failed ||
          ContextFreezePhase.resuming ||
          ContextFreezePhase.deletionPending:
        break;
    }
  }
  return EquatableValue([
    for (final MapEntry(:key, :value) in releasing.entries)
      PendingSiteData(
        ownerId: key,
        contextIds: value,
        orphaned: false,
        ownerExists: names.containsKey(key),
        ownerName: names[key],
      ),
    ...pending,
  ]);
}
