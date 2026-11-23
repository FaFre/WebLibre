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

import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

/// Why a container cannot be frozen, decided before native is asked.
enum FreezeUnavailability {
  /// The container no longer exists.
  missing,

  /// It shares the default cookie storage; freeze needs a context of its own
  /// (F9).
  needsOwnStorage,

  /// One of its isolated tabs shares its storage with a tab outside it.
  sharedStorage,

  /// The registry was found damaged and the containers are not reconstructed
  /// yet (D23).
  recoveryPending,

  /// An automatic freeze found the container without a schedule any more,
  /// or the freeze feature hidden (phase C2).
  notScheduled,
}

/// A container refused a tab opening, duplicating or restoring into it:
/// [ContainerFrozenException] or [ContainerBeingDeletedException].
sealed class ContainerRefusedTabException implements Exception {
  String get containerId;
}

/// A tab could not move into or out of a container, an isolated tab could not
/// be created in it, or its storage identity could not change, because the
/// container is frozen or a freeze or Resume of it is running (D19 in
/// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`).
class ContainerFrozenException implements ContainerRefusedTabException {
  @override
  final String containerId;

  const ContainerFrozenException(this.containerId);

  @override
  String toString() =>
      'ContainerFrozenException: container $containerId is frozen';
}

/// A tab could not join a container because the container is being deleted.
///
/// Thrown by `ContainerMembershipGate.whileChanging` for the paths that add,
/// restore or move a tab into or out of a container.
class ContainerBeingDeletedException implements ContainerRefusedTabException {
  @override
  final String containerId;

  const ContainerBeingDeletedException(this.containerId);

  @override
  String toString() =>
      'ContainerBeingDeletedException: container $containerId is being deleted';
}

/// The phases of a frozen container's context that no freeze or Resume is
/// still writing. An isolation group whose last tab closed in one of them
/// stays restricted, and is released first by the container's Resume (D32).
const settledFreezePhases = {
  ContextFreezePhase.frozen,
  ContextFreezePhase.failed,
};

/// What came of asking to freeze a container.
sealed class ContainerFreezeOutcome {
  const ContainerFreezeOutcome();
}

/// Nothing was asked of native: [reason].
final class FreezeUnavailable extends ContainerFreezeOutcome
    with FastEquatable {
  final FreezeUnavailability reason;

  FreezeUnavailable(this.reason);

  @override
  List<Object?> get hashParameters => [reason];
}

/// Another operation on the container is running (a freeze, a Resume, a
/// deletion or a membership change); nothing was asked.
final class FreezeBusy extends ContainerFreezeOutcome {
  const FreezeBusy();
}

/// Native ran the freeze; [result] says how far it got. For messages only:
/// the gate reads its own snapshot (D27).
final class FreezeAttempted extends ContainerFreezeOutcome with FastEquatable {
  final FreezeOperationResult result;

  FreezeAttempted(this.result);

  bool get frozen =>
      result.failure == null && result.phase == ContextFreezePhase.frozen;

  @override
  List<Object?> get hashParameters => [result];
}

/// What came of asking to resume a container.
sealed class ContainerResumeOutcome {
  const ContainerResumeOutcome();
}

/// The routing of one of its contexts is not installed, so nothing was
/// lifted (D34).
final class ResumeRoutingNotReady extends ContainerResumeOutcome {
  const ResumeRoutingNotReady();
}

/// Resume is refused until the containers are reconstructed (D23).
final class ResumeRecoveryPending extends ContainerResumeOutcome {
  const ResumeRecoveryPending();
}

/// A deletion or a membership change of the container is running, or an
/// undo close, which the release of its empty isolation groups waits for.
final class ResumeBusy extends ContainerResumeOutcome {
  const ResumeBusy();
}

/// Nothing was lifted: native's registry could not be read, so which
/// storage the Resume would lift, and whose routes to check first (D34), is
/// not known.
final class ResumeFreezeStateUnknown extends ContainerResumeOutcome {
  const ResumeFreezeStateUnknown();
}

/// Nothing was lifted: an isolated tab of another container, which is still
/// frozen, shares storage this container holds. Lifting it would run that
/// tab. After a damaged registry, such storage is restored under one of the
/// containers only (5.6); the other is resumed first.
final class ResumeSharedWithFrozen extends ContainerResumeOutcome {
  const ResumeSharedWithFrozen();
}

/// Nothing was lifted: the data of an isolated tab's storage, whose last tab
/// closed while the container was frozen, could not be deleted first (D32).
/// Lifted with the container, its service workers and push subscriptions
/// would run again with that data. Tried again by the next Resume.
final class ResumeIsolationCleanupFailed extends ContainerResumeOutcome {
  const ResumeIsolationCleanupFailed();
}

/// Native ran the Resume; [result] says how far it got.
final class ResumeAttempted extends ContainerResumeOutcome with FastEquatable {
  final FreezeOperationResult result;

  /// When it did not finish: what the engine last acknowledged for the
  /// container, read from a snapshot taken right after (D33), so the message
  /// can say whether its activity is still blocked. Null when it resumed, or
  /// when the snapshot could not be read.
  final EngineEnforcement? enforcement;

  ResumeAttempted(this.result, {this.enforcement});

  bool get resumed =>
      result.failure == null && result.phase == ContextFreezePhase.unrestricted;

  @override
  List<Object?> get hashParameters => [result, enforcement];
}

/// Something the start-time reconciliation found that the user should hear
/// about (5.5, 5.6); translated where it is shown.
sealed class ContainerFreezeNotice {
  const ContainerFreezeNotice();
}

/// The registry was found damaged, and [count] containers were frozen to be
/// safe; each is resumed on its own (5.6).
final class ContainersFrozenToBeSafe extends ContainerFreezeNotice
    with FastEquatable {
  final int count;

  ContainersFrozenToBeSafe(this.count);

  @override
  List<Object?> get hashParameters => [count];
}

/// The registry was found damaged, and which containers are frozen could not
/// be restored yet: every container stays frozen until it is (D23).
final class FreezeRecoveryFailed extends ContainerFreezeNotice {
  const FreezeRecoveryFailed();
}

/// A navigation the user asked for did not run: its tab's storage is
/// restricted with no container to resume, as every storage is while the
/// frozen containers are restored after a damaged record (5.6).
final class NavigationWaitsForRecovery extends ContainerFreezeNotice {
  const NavigationWaitsForRecovery();
}

/// A navigation the user asked for in a sleeping tab did not run: the tab's
/// proxy routing is not ready, so it stays asleep rather than load another
/// way (D34).
final class NavigationWaitsForRouting extends ContainerFreezeNotice {
  const NavigationWaitsForRouting();
}

/// An undo close did not bring a tab back: the storage it ran in waits for
/// its site data to be deleted (`releasing`), which every start retries.
final class UndoWaitsForSiteDataDeletion extends ContainerFreezeNotice {
  const UndoWaitsForSiteDataDeletion();
}

/// Deleting [containerIds] did not finish before WebLibre was closed; they
/// are still there, as they were before (5.5).
final class ContainerDeletionNotFinished extends ContainerFreezeNotice
    with FastEquatable {
  final List<String> containerIds;

  ContainerDeletionNotFinished(this.containerIds);

  @override
  List<Object?> get hashParameters => [containerIds];
}

/// Resume pressed on [containerId]'s frozen placeholder did not finish:
/// [outcome] says why. The placeholder is native and has no message of its
/// own (5.5).
final class ResumeNotFinished extends ContainerFreezeNotice with FastEquatable {
  final String containerId;
  final ContainerResumeOutcome outcome;

  ResumeNotFinished(this.containerId, this.outcome);

  @override
  List<Object?> get hashParameters => [containerId, outcome];
}

/// A page the user opened was not opened in the container its site is
/// assigned to, which refused it ([refusal]). Nothing opened in its place.
final class PageNotOpened extends ContainerFreezeNotice {
  final ContainerRefusedTabException refusal;

  const PageNotOpened(this.refusal);
}

/// How far restoring the frozen containers after a damaged registry got
/// (D23), for the Containers screen.
enum FreezeRecoveryStatus {
  /// Not in recovery, or not known yet.
  none,

  /// In recovery; restoring is under way or not started.
  restoring,

  /// In recovery, and the last attempt to restore did not finish.
  failed,
}

/// A navigation the user asked for in a tab of a frozen container, or a page
/// the user opened that its frozen container would refuse, held until the
/// user answers "Resume {container} and open?" (5.2.1, D31).
///
/// Answered by exactly one screen
/// (`ContainerFreezeService.answerResumeAndOpenWith`).
final class ResumeAndOpenRequest {
  /// The container the question names: for a tab, the one whose freeze
  /// holds its storage, as its placeholder names it, which need not be the
  /// container it is filed under (5.6).
  final String containerId;

  /// The tab to wake with the container; null when the page opens in a new
  /// tab once it is resumed.
  final String? tabId;
  final Completer<bool> _answer = Completer();

  ResumeAndOpenRequest({required this.containerId, this.tabId});

  /// Completes with the answer: whether the container was resumed.
  Future<bool> get answered => _answer.future;

  /// Answers it: [resumed] lets the navigation run; false leaves the
  /// container frozen and drops it.
  void complete({required bool resumed}) {
    if (!_answer.isCompleted) _answer.complete(resumed);
  }
}

/// One container's freeze as the user sees it: the phase its contexts are in
/// and what the engine last acknowledged (3.3).
final class ContainerFreezeView with FastEquatable {
  final ContextFreezePhase phase;
  final EngineEnforcement enforcement;
  final LifecycleOperationState operation;
  final bool recovered;
  final int undeliveredPushCount;

  ContainerFreezeView({
    required this.phase,
    required this.enforcement,
    required this.operation,
    required this.recovered,
    required this.undeliveredPushCount,
  });

  /// The views of every container [snapshot]'s records hold, as native
  /// aggregates them ([OwnerFreezeState]).
  static Map<String, ContainerFreezeView> fromSnapshot(
    LifecycleSnapshot snapshot,
  ) => {
    for (final owner in snapshot.owners)
      owner.ownerId: ContainerFreezeView(
        phase: owner.phase,
        enforcement: owner.enforcement,
        operation: owner.operation,
        recovered: owner.recovered,
        undeliveredPushCount: owner.undeliveredPushCount,
      ),
  };

  /// Shown as frozen: frozen, or a freeze or Resume of it is running or did
  /// not finish. A container whose deletion is under way is not. Native
  /// reports no container in the other phases.
  bool get showsFrozen => switch (phase) {
    ContextFreezePhase.freezing ||
    ContextFreezePhase.frozen ||
    ContextFreezePhase.failed ||
    ContextFreezePhase.resuming => true,
    ContextFreezePhase.unrestricted ||
    ContextFreezePhase.deletionPending ||
    ContextFreezePhase.releasing ||
    ContextFreezePhase.orphaned => false,
  };

  @override
  List<Object?> get hashParameters => [
    phase,
    enforcement,
    operation,
    recovered,
    undeliveredPushCount,
  ];
}

/// How far a freeze's teardown got (barrier 4): [done] of [total] tabs.
final class FreezeProgress with FastEquatable {
  final int done;
  final int total;

  FreezeProgress({required this.done, required this.total});

  @override
  List<Object?> get hashParameters => [done, total];
}

/// Site data still waiting to be deleted (5.5, D32): a container's contexts
/// whose release has not finished, or one orphaned context. Each stays
/// restricted until "Delete data" or a later start releases it.
///
/// The container is usually deleted ([ownerExists] false). One that still
/// exists has isolation groups whose last tab closed and whose release did
/// not finish; it is not frozen for that.
final class PendingSiteData with FastEquatable {
  /// The container's id; null for an orphaned context, whose container is
  /// unknown.
  final String? ownerId;
  final List<String> contextIds;

  /// Found without a container by the owner reconciliation; deleted only when
  /// the user asks.
  final bool orphaned;

  /// Whether the container [ownerId] still exists.
  final bool ownerExists;

  /// The existing container's name, as stored.
  final String? ownerName;

  PendingSiteData({
    required this.ownerId,
    required this.contextIds,
    required this.orphaned,
    this.ownerExists = false,
    this.ownerName,
  });

  @override
  List<Object?> get hashParameters => [
    ownerId,
    contextIds,
    orphaned,
    ownerExists,
    ownerName,
  ];
}
