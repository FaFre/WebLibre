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
import 'package:weblibre/core/maintenance/maintenance_outcome.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/profile_copy_l10n.dart';
import 'package:weblibre/presentation/utils/units_l10n.dart';

/// Display text for [MaintenanceFailure]. Takes a pre-resolved [l10n] rather
/// than a `BuildContext`: every call site here reaches this from inside an
/// async catch block, after an await, where reusing the widget's `BuildContext`
/// would trip `use_build_context_synchronously`.
extension MaintenanceFailureL10n on MaintenanceFailure {
  String describe(AppLocalizations l10n) {
    final failure = this;

    return switch (failure) {
      WrongArchivePassword() => l10n.startup_maintenanceWrongPassword(
        l10n.profileCopy_nothingChanged,
      ),
      UnreadableArchive() => l10n.startup_maintenanceUnreadableArchive(
        l10n.profileCopy_nothingChanged,
      ),
      DamagedArchive() => l10n.startup_maintenanceDamagedArchive(
        l10n.profileCopy_nothingChanged,
      ),
      UnsupportedArchiveVersion() =>
        l10n.startup_maintenanceUnsupportedArchiveVersion(
          l10n.profileCopy_nothingChanged,
        ),
      NotEnoughStorage(:final requiredBytes, :final availableBytes) => switch ((
        requiredBytes,
        availableBytes,
      )) {
        (final required?, final free?) =>
          l10n.startup_maintenanceNotEnoughStorageWithFree(
            formatByteSize(l10n, required),
            formatByteSize(l10n, free),
            l10n.profileCopy_nothingChanged,
          ),
        (final required?, null) =>
          l10n.startup_maintenanceNotEnoughStorageKnown(
            formatByteSize(l10n, required),
            l10n.profileCopy_nothingChanged,
          ),
        (null, _) => l10n.startup_maintenanceNotEnoughStorageUnknown(
          l10n.profileCopy_nothingChanged,
        ),
      },
      BackupFolderUnavailableFailure() =>
        l10n.startup_maintenanceBackupFolderUnavailable(
          l10n.profileCopy_nothingChanged,
        ),
      ProfileNoLongerExistsFailure() =>
        l10n.startup_maintenanceProfileNoLongerExists,
      RestoreEvidenceUnresolvedFailure() =>
        l10n.startup_maintenanceRestoreEvidenceUnresolved,
      TaskNotRunnable(:final reason) => reason.describe(l10n),
      RestartNotScheduledFailure() => restartCouldNotBeScheduled(l10n),
      ArchiveRejected(:final reason) => reason.describe(l10n),
      // Genuinely unstructured — raw exception text this build has no case
      // for. Not further localized, same as any other external/diagnostic
      // error text in this app.
      UnknownMaintenanceFailure(:final detail) => detail,
    };
  }
}

/// Display text for [RestoreValidationReason], kept out of the domain type
/// for the same reason as [MaintenanceFailureL10n].
extension RestoreValidationReasonL10n on RestoreValidationReason {
  String describe(AppLocalizations l10n) => switch (this) {
    RestoreValidationReason.wrongProfile =>
      l10n.startup_maintenanceRestoreWrongProfile,
    RestoreValidationReason.incomplete =>
      l10n.startup_maintenanceRestoreIncomplete,
    RestoreValidationReason.noMetadata =>
      l10n.startup_maintenanceRestoreNoMetadata,
    RestoreValidationReason.malformedMetadata =>
      l10n.startup_maintenanceRestoreMalformedMetadata,
    RestoreValidationReason.noProfileData =>
      l10n.startup_maintenanceRestoreNoProfileData,
  };
}

/// Turns a maintenance failure into something worth showing a user.
String describeMaintenanceFailure(AppLocalizations l10n, Object error) =>
    classifyMaintenanceFailure(error).describe(l10n);

/// Localized text for the failure recorded on a [MaintenanceTask], through
/// [RecordedMaintenanceFailure.recordedFailure].
///
/// `null` when no failure can be rebuilt (see there): callers then fall back
/// to the stored [MaintenanceTask.error], which for
/// [MaintenanceFailureKind.unknown] is raw exception text kept verbatim so it
/// can be read out into a bug report. The exception is
/// [MaintenanceFailureKind.archiveRejected], whose stored text is diagnostic
/// only, so an unrecognized reason gets a generic sentence instead.
extension MaintenanceTaskFailureL10n on MaintenanceTask {
  String? describeFailure(AppLocalizations l10n) =>
      recordedFailure?.describe(l10n) ??
      (failureKind == MaintenanceFailureKind.archiveRejected
          ? l10n.startup_maintenanceRestoreRejected
          : null);
}

/// Display text for [TaskNotRunnableReason], kept out of the domain type for
/// the same reason as [MaintenanceFailureL10n].
extension TaskNotRunnableReasonL10n on TaskNotRunnableReason {
  String describe(AppLocalizations l10n) => switch (this) {
    TaskNotRunnableReason.unsupportedAction =>
      l10n.startup_maintenanceNotRunnableUnsupported,
    TaskNotRunnableReason.backupDestinationMissing =>
      l10n.startup_maintenanceNotRunnableNoDestination,
    TaskNotRunnableReason.restoreSourceMissing =>
      l10n.startup_maintenanceNotRunnableNoBackupFile,
    TaskNotRunnableReason.restoreUnavailableHere =>
      l10n.startup_maintenanceNotRunnableRestoreHere,
    TaskNotRunnableReason.deleteUnavailableHere =>
      l10n.startup_maintenanceNotRunnableDeleteHere,
  };
}

/// Display text for [MaintenanceRecoveryOutcome], kept out of the domain type
/// for the same reason as [MaintenanceFailureL10n].
extension MaintenanceRecoveryOutcomeL10n on MaintenanceRecoveryOutcome {
  String describe(AppLocalizations l10n) => switch (this) {
    MaintenanceRecoveryOutcome.restoreCompleted =>
      l10n.startup_maintenanceRecoveredRestore,
    MaintenanceRecoveryOutcome.restoreRolledBack =>
      l10n.startup_maintenanceRecoveredRestoreRolledBack,
    MaintenanceRecoveryOutcome.restoreReconciled =>
      l10n.startup_maintenanceRecoveredRestoreReconciled,
    MaintenanceRecoveryOutcome.deletionCompleted =>
      l10n.startup_maintenanceRecoveredDeletion,
  };
}
