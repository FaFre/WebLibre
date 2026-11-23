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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

extension ContainerFreezeViewL10n on ContainerFreezeView {
  /// The container's freeze state as the user reads it (3.3 of
  /// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): it follows the
  /// phase and what the engine last acknowledged, never the stored phase
  /// alone (D33). [progress] is the running freeze's teardown, if known.
  /// Null for a container whose deletion is under way.
  String? stateLabel(AppLocalizations l10n, {FreezeProgress? progress}) {
    if (operation == LifecycleOperationState.freezing) {
      return progress != null && progress.total > 0
          ? l10n.browser_containerFreezingProgress(
              progress.done,
              progress.total,
            )
          : l10n.browser_containerFreezing;
    }
    if (operation == LifecycleOperationState.resuming) {
      return l10n.browser_containerResuming;
    }
    final blocked = enforcement == EngineEnforcement.enforced;
    return switch (phase) {
      ContextFreezePhase.freezing || ContextFreezePhase.frozen =>
        // Frozen by WebLibre itself after a damaged record (5.6).
        recovered
            ? l10n.browser_containerFrozenToBeSafeLabel
            : l10n.browser_containerFrozenLabel,
      ContextFreezePhase.failed =>
        blocked
            ? l10n.browser_freezeIncompleteBlocked
            : l10n.browser_freezeIncompleteUncertain,
      ContextFreezePhase.resuming =>
        blocked
            ? l10n.browser_resumeIncompleteBlocked
            : l10n.browser_resumeIncompleteLifted,
      ContextFreezePhase.unrestricted ||
      ContextFreezePhase.deletionPending ||
      ContextFreezePhase.releasing ||
      ContextFreezePhase.orphaned => null,
    };
  }

  /// [stateLabel] in one or two words, for a chip beside "Pinned" and
  /// "Isolated" on the containers screen. The container menu shows the full
  /// sentence under "Resume Container". Null when [stateLabel] is.
  String? shortStateLabel(AppLocalizations l10n) {
    if (operation == LifecycleOperationState.freezing) {
      return l10n.browser_containerFreezing;
    }
    if (operation == LifecycleOperationState.resuming) {
      return l10n.browser_containerResuming;
    }
    return switch (phase) {
      ContextFreezePhase.freezing ||
      ContextFreezePhase.frozen => l10n.browser_containerFrozenLabel,
      ContextFreezePhase.failed => l10n.browser_freezeIncompleteLabel,
      ContextFreezePhase.resuming => l10n.browser_resumeIncompleteLabel,
      ContextFreezePhase.unrestricted ||
      ContextFreezePhase.deletionPending ||
      ContextFreezePhase.releasing ||
      ContextFreezePhase.orphaned => null,
    };
  }
}

extension ContainerResumeOutcomeL10n on ContainerResumeOutcome {
  /// What to say after a Resume that did not finish, and whether it ran and
  /// failed rather than could not start yet. Null when it resumed.
  ({String text, bool failed})? describe(AppLocalizations l10n) =>
      switch (this) {
        ResumeRoutingNotReady() => (
          text: l10n.browser_resumeRoutingNotReady,
          failed: false,
        ),
        ResumeRecoveryPending() => (
          text: l10n.browser_freezeRecoveryPending,
          failed: false,
        ),
        ResumeBusy() => (text: l10n.browser_freezeBusy, failed: false),
        ResumeFreezeStateUnknown() => (
          text: l10n.browser_resumeFreezeStateUnknown,
          failed: true,
        ),
        ResumeSharedWithFrozen() => (
          text: l10n.browser_resumeSharedWithFrozen,
          failed: false,
        ),
        ResumeIsolationCleanupFailed() => (
          text: l10n.browser_resumeIsolationCleanupFailed,
          failed: true,
        ),
        ResumeAttempted(resumed: true) => null,
        ResumeAttempted(:final result)
            when result.failure == LifecycleFailure.recoveryPending =>
          (text: l10n.browser_freezeRecoveryPending, failed: false),
        ResumeAttempted(:final enforcement) => (
          text: enforcement == EngineEnforcement.enforced
              ? l10n.browser_resumeFailedBlocked
              : l10n.browser_resumeFailedLifted,
          failed: true,
        ),
      };
}

extension ContainerFreezeOutcomeL10n on ContainerFreezeOutcome {
  /// What to say after a freeze of [containerName], and whether it failed
  /// rather than was refused with a hint at what to do next. Null when there
  /// is nothing to say, and for activity that kept it from freezing, which
  /// is listed instead.
  ({String text, bool failed})? describe(
    AppLocalizations l10n, {
    required String containerName,
  }) => switch (this) {
    // Deleted meanwhile, or (automatic freezes only) no longer scheduled:
    // nothing to say about it.
    FreezeUnavailable(
      reason: FreezeUnavailability.missing || FreezeUnavailability.notScheduled,
    ) =>
      null,
    FreezeUnavailable(reason: FreezeUnavailability.needsOwnStorage) => (
      text: l10n.browser_freezeNeedsOwnStorage,
      failed: false,
    ),
    FreezeUnavailable(reason: FreezeUnavailability.sharedStorage) => (
      text: l10n.browser_freezeSharedStorage,
      failed: false,
    ),
    FreezeUnavailable(reason: FreezeUnavailability.recoveryPending) => (
      text: l10n.browser_freezeRecoveryPending,
      failed: false,
    ),
    FreezeBusy() => (text: l10n.browser_freezeBusy, failed: false),
    FreezeAttempted(frozen: true) => (
      text: l10n.browser_containerFrozenDone(containerName),
      failed: false,
    ),
    FreezeAttempted(:final result) => switch (result.failure) {
      // A Resume ("Stop freezing and resume") took over; it reports itself.
      LifecycleFailure.superseded || LifecycleFailure.protectedActivity => null,
      LifecycleFailure.contextShared => (
        text: l10n.browser_freezeFailedShared,
        failed: false,
      ),
      LifecycleFailure.membershipChanged => (
        text: l10n.browser_freezeFailedMembershipChanged,
        failed: false,
      ),
      LifecycleFailure.memberOutsideContexts => (
        text: l10n.browser_freezeFailedMemberOutside,
        failed: false,
      ),
      LifecycleFailure.openInExternalWindow => (
        text: l10n.browser_freezeFailedExternalWindow,
        failed: false,
      ),
      LifecycleFailure.recoveryPending => (
        text: l10n.browser_freezeRecoveryPending,
        failed: false,
      ),
      LifecycleFailure.engineRefused => (
        text: l10n.browser_freezeFailedEngineRefused,
        failed: true,
      ),
      LifecycleFailure.notPersisted => (
        text: l10n.browser_freezeFailedNotPersisted,
        failed: true,
      ),
      LifecycleFailure.quiescenceTimedOut => (
        text: l10n.browser_freezeFailedQuiescence,
        failed: true,
      ),
      LifecycleFailure.rollbackUnconfirmed => (
        text: l10n.browser_freezeIncompleteUncertain,
        failed: true,
      ),
      _ => (text: l10n.browser_freezeFailedGeneric, failed: true),
    },
  };
}

extension ContainerRefusedTabExceptionL10n on ContainerRefusedTabException {
  /// Why the container refused the tab: it is frozen ("Resume the container
  /// first"), or being deleted.
  String describe(AppLocalizations l10n) => switch (this) {
    ContainerFrozenException() => l10n.browser_containerFrozen,
    ContainerBeingDeletedException() => l10n.browser_containerBeingDeleted,
  };
}

/// "Freeze automatically" as the container editor shows it: off, or after how
/// long unused (phase C2).
String autoFreezeSummary(AppLocalizations l10n, int? minutes) =>
    switch (minutes) {
      null => l10n.tabs_autoFreezeOff,
      final minutes when minutes % 60 == 0 => l10n.tabs_autoFreezeAfterHours(
        minutes ~/ 60,
      ),
      final minutes => l10n.tabs_autoFreezeAfterMinutes(minutes),
    };
