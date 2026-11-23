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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

/// Native's freeze registry for Dart tests: restricted contexts with their
/// owner and phase, a revision raised by every change, and the calls that
/// reached it, in order. Freeze and Resume succeed unless told otherwise.
class FakeTabLifecycleService extends GeckoTabLifecycleService {
  final calls = <String>[];
  final _contexts = <String, ({String? owner, ContextFreezePhase phase})>{};

  /// The data deletions [beginContextDeletion] wrote down, by context, with
  /// their container.
  final dataDeletions = <String, String>{};
  var _revision = 1;
  bool recovery = false;

  /// Answers [freezeContexts] instead of freezing when set.
  FreezeOperationResult Function(String ownerId)? freezeAnswer;

  /// Answers [resumeContexts] instead of resuming when set.
  FreezeOperationResult Function(String ownerId)? resumeAnswer;

  /// What every context's engine enforcement reads as in snapshots.
  EngineEnforcement enforcement = EngineEnforcement.enforced;

  /// Answers [releaseContexts] with not released when set.
  bool releaseFails = false;

  /// [reconstructFrozenContexts] writes its records but stays in recovery,
  /// as when an engine call was not acknowledged.
  bool reconstructionKeepsRecovery = false;

  /// Held until completed: [freezeContexts] waits for it when set.
  Completer<void>? freezeGate;

  /// Held until completed: [lifecycleSnapshot] waits for it when set.
  Completer<void>? snapshotGate;

  bool beginDeletionFails = false;

  /// Called by [beginContextDeletion] once it recorded the deletion.
  void Function()? onBeginDeletion;
  bool completeDeletionFails = false;
  bool snapshotFails = false;

  /// What [takeFrozenWindowHandoff] answers once.
  FrozenWindowHandoff? frozenWindowHandoff;

  /// What [tabLifecycleState] answers, by tab.
  final tabStates = <String, TabLifecycleState>{};

  /// What the last [freezeContexts] was given.
  List<String>? lastFreezeContexts;
  List<String>? lastFreezeMembers;
  bool? lastFreezeAutomatic;

  /// Restricts [contextIds] for [ownerId] in [phase], as if a freeze had
  /// committed before; a null [ownerId] makes them orphaned records.
  void restrict(
    String? ownerId,
    List<String> contextIds, {
    ContextFreezePhase phase = ContextFreezePhase.frozen,
  }) {
    for (final contextId in contextIds) {
      _contexts[contextId] = (owner: ownerId, phase: phase);
    }
    _revision++;
  }

  /// The phases in which a record holds its owner, in native's order: the
  /// one that needs attention first. A `releasing` or `orphaned` record holds
  /// none.
  static const _ownerPhaseOrder = [
    ContextFreezePhase.freezing,
    ContextFreezePhase.resuming,
    ContextFreezePhase.failed,
    ContextFreezePhase.deletionPending,
    ContextFreezePhase.frozen,
  ];

  ContextFreezePhase _phaseOf(String ownerId) => _ownerPhaseOrder.firstWhere(
    (phase) => _contexts.values.any(
      (entry) => entry.owner == ownerId && entry.phase == phase,
    ),
    orElse: () => ContextFreezePhase.unrestricted,
  );

  bool _hasRecords(String ownerId) =>
      _contexts.values.any((entry) => entry.owner == ownerId);

  FreezeOperationResult result(String ownerId, {LifecycleFailure? failure}) =>
      _result(ownerId, failure: failure);

  FreezeOperationResult _result(
    String ownerId, {
    LifecycleFailure? failure,
    List<String> unsettled = const [],
  }) => FreezeOperationResult(
    ownerId: ownerId,
    phase: _phaseOf(ownerId),
    revision: _revision,
    failure: failure,
    blockers: const [],
    stillRunning: const [],
    unsettledContextIds: unsettled,
  );

  LifecycleSnapshot get currentSnapshot => LifecycleSnapshot(
    mode: recovery
        ? LifecycleRegistryMode.recovery
        : LifecycleRegistryMode.normal,
    revision: _revision,
    contexts: [
      for (final entry in _contexts.entries)
        ContextFreezeState(
          contextId: entry.key,
          ownerId: entry.value.owner,
          phase: entry.value.phase,
          previousPhase: null,
          failure: null,
          enforcement: enforcement,
          operation: LifecycleOperationState.idle,
          recovered: false,
          undeliveredPushCount: 0,
        ),
    ],
    owners: [
      for (final ownerId in {
        for (final entry in _contexts.values)
          if (_ownerPhaseOrder.contains(entry.phase)) ?entry.owner,
      })
        OwnerFreezeState(
          ownerId: ownerId,
          phase: _phaseOf(ownerId),
          enforcement: enforcement,
          operation: LifecycleOperationState.idle,
          recovered: false,
          undeliveredPushCount: 0,
          contextIds: [
            for (final MapEntry(:key, :value) in _contexts.entries)
              if (value.owner == ownerId &&
                  _ownerPhaseOrder.contains(value.phase))
                key,
          ],
        ),
    ],
  );

  @override
  Future<TabLifecycleState?> tabLifecycleState(String tabId) async =>
      tabStates[tabId];

  @override
  Future<LifecycleSnapshot> lifecycleSnapshot() async {
    await snapshotGate?.future;
    if (snapshotFails) throw StateError('no registry');
    return currentSnapshot;
  }

  @override
  Future<FrozenWindowHandoff?> takeFrozenWindowHandoff() async {
    final handoff = frozenWindowHandoff;
    frozenWindowHandoff = null;
    return handoff;
  }

  @override
  Future<FreezeOperationResult> freezeContexts({
    required String ownerId,
    required List<String> contextIds,
    required List<String> memberTabIds,
    bool stopMedia = false,
    bool discardPostResult = false,
    List<String> discardFormDataTabIds = const [],
    bool automatic = false,
  }) async {
    calls.add('freeze $ownerId $contextIds');
    lastFreezeContexts = contextIds;
    lastFreezeMembers = memberTabIds;
    lastFreezeAutomatic = automatic;
    await freezeGate?.future;
    final answer = freezeAnswer;
    if (answer != null) return answer(ownerId);
    restrict(ownerId, contextIds);
    return _result(ownerId);
  }

  @override
  Future<FreezeOperationResult> resumeContexts(
    String ownerId, {
    String? wakeTabId,
  }) async {
    calls.add('resume $ownerId ${wakeTabId ?? '-'}');
    final answer = resumeAnswer;
    if (answer != null) return answer(ownerId);
    _contexts.removeWhere((_, entry) => entry.owner == ownerId);
    _revision++;
    return _result(ownerId);
  }

  @override
  Future<FreezeOperationResult> beginContextDeletion(
    String ownerId, {
    List<String> deleteDataOf = const [],
  }) async {
    calls.add(
      deleteDataOf.isEmpty
          ? 'beginDeletion $ownerId'
          : 'beginDeletion $ownerId $deleteDataOf',
    );
    // Native records nothing for a container the wildcard restricts.
    if (recovery) {
      return _result(ownerId, failure: LifecycleFailure.recoveryPending);
    }
    final intents = [
      for (final contextId in deleteDataOf)
        if (!_contexts.containsKey(contextId)) contextId,
    ];
    if (!_hasRecords(ownerId) && intents.isEmpty) {
      onBeginDeletion?.call();
      return _result(ownerId);
    }
    if (beginDeletionFails) {
      return _result(ownerId, failure: LifecycleFailure.notPersisted);
    }
    _contexts.updateAll(
      (_, entry) => entry.owner == ownerId
          ? (owner: ownerId, phase: ContextFreezePhase.deletionPending)
          : entry,
    );
    // Written down with it, restricting nothing until the row is gone.
    for (final contextId in intents) {
      dataDeletions[contextId] = ownerId;
    }
    _revision++;
    onBeginDeletion?.call();
    return _result(ownerId);
  }

  @override
  Future<FreezeOperationResult> cancelContextDeletion(String ownerId) async {
    calls.add('cancelDeletion $ownerId');
    dataDeletions.removeWhere((_, owner) => owner == ownerId);
    _contexts.updateAll(
      (_, entry) =>
          entry.owner == ownerId &&
              entry.phase == ContextFreezePhase.deletionPending
          ? (owner: ownerId, phase: ContextFreezePhase.frozen)
          : entry,
    );
    _revision++;
    return _result(ownerId);
  }

  @override
  Future<FreezeOperationResult> completeContextDeletion(String ownerId) async {
    calls.add('completeDeletion $ownerId');
    // Its data deletions are recorded `releasing` first, as native does.
    dataDeletions.removeWhere((contextId, owner) {
      if (owner != ownerId) return false;
      _contexts.putIfAbsent(
        contextId,
        () => (owner: ownerId, phase: ContextFreezePhase.releasing),
      );
      return true;
    });
    if (completeDeletionFails) {
      _contexts.updateAll(
        (_, entry) => entry.owner == ownerId
            ? (owner: ownerId, phase: ContextFreezePhase.releasing)
            : entry,
      );
      _revision++;
      return _result(
        ownerId,
        failure: LifecycleFailure.cleanupFailed,
        unsettled: [
          for (final MapEntry(:key, :value) in _contexts.entries)
            if (value.owner == ownerId) key,
        ],
      );
    }
    _contexts.removeWhere((_, entry) => entry.owner == ownerId);
    _revision++;
    return _result(ownerId);
  }

  @override
  Future<LifecycleSnapshot> reconcileOwners(
    List<String> existingOwnerIds,
  ) async {
    calls.add('reconcile ${[...existingOwnerIds]..sort()}');
    return currentSnapshot;
  }

  @override
  Future<List<ContextReleaseResult>> releaseContexts(
    List<String> contextIds,
  ) async {
    calls.add('release $contextIds');
    final recorded = {
      for (final contextId in contextIds)
        if (_contexts.containsKey(contextId)) contextId,
    };
    if (!releaseFails) {
      contextIds.forEach(_contexts.remove);
      _revision++;
    }
    return [
      for (final contextId in contextIds)
        ContextReleaseResult(
          contextId: contextId,
          released: !releaseFails,
          failure: releaseFails ? LifecycleFailure.cleanupFailed : null,
          // Native clears only what it has a record of.
          dataCleared: !releaseFails && recorded.contains(contextId),
        ),
    ];
  }

  @override
  Future<LifecycleSnapshot> reconstructFrozenContexts({
    required List<ContainerContexts> owners,
    required List<String> unfreezableContextIds,
  }) async {
    calls.add(
      'reconstruct ${[for (final owner in owners) '${owner.ownerId}=${owner.contextIds}']} '
      'unfreezable=$unfreezableContextIds',
    );
    for (final owner in owners) {
      restrict(owner.ownerId, owner.contextIds);
    }
    recovery = reconstructionKeepsRecovery;
    _revision++;
    return currentSnapshot;
  }
}
