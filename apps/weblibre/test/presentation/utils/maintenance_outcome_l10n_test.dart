import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/maintenance/maintenance_outcome.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/maintenance_outcome_l10n.dart';

/// A failure read back from `startup_config.json` has lost its object; these
/// check that the persisted kind and detail are still enough to translate it,
/// instead of falling back to the stored English message.
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  MaintenanceTask failedWith(MaintenanceFailure failure) =>
      MaintenanceTask.create(
        id: 'task-1',
        action: MaintenanceAction.restoreOver,
        profileId: 'profile-1',
        profileName: 'Default',
        createdAt: DateTime.utc(2026, 9, 26),
      ).withState(
        MaintenanceTaskState.failed,
        error: failure.message,
        errorKindId: failure.kind.name,
        errorDetailId: failure.detailId,
      );

  test('translates every recorded failure the same way as the live one', () {
    final failures = <MaintenanceFailure>[
      const WrongArchivePassword(),
      const UnreadableArchive(),
      const DamagedArchive(detail: 'detail'),
      const UnsupportedArchiveVersion(version: 9),
      const NotEnoughStorage(),
      const BackupFolderUnavailableFailure(),
      for (final reason in RestoreValidationReason.values)
        ArchiveRejected(reason, 'detail'),
      profileNoLongerExists,
      restoreEvidenceUnresolved,
      for (final reason in TaskNotRunnableReason.values)
        TaskNotRunnable(reason),
      const RestartNotScheduledFailure(),
    ];

    // Every kind but `unknown` must be covered above, or a new kind could
    // skip its translation after a restart without failing here.
    expect(
      {for (final failure in failures) failure.kind},
      MaintenanceFailureKind.values.toSet()
        ..remove(MaintenanceFailureKind.unknown),
    );

    for (final failure in failures) {
      expect(
        failedWith(failure).describeFailure(l10n),
        failure.describe(l10n),
        reason: failure.message,
      );
    }
  });

  test('leaves raw failures to the stored message', () {
    final task = failedWith(const UnknownMaintenanceFailure('disk gone'));

    expect(task.describeFailure(l10n), isNull);
    expect(task.error, 'disk gone');
  });

  test('does not guess at a detail written by a newer build', () {
    final task = failedWith(
      const TaskNotRunnable(TaskNotRunnableReason.unsupportedAction),
    ).copyWith(errorDetailId: 'somethingNewer');

    expect(task.describeFailure(l10n), isNull);
  });

  test('never shows the diagnostic text of a rejected archive', () {
    final task = failedWith(
      const ArchiveRejected(RestoreValidationReason.wrongProfile, 'internals'),
    ).copyWith(errorDetailId: 'somethingNewer');

    expect(task.describeFailure(l10n), l10n.startup_maintenanceRestoreRejected);
  });

  test('describes a restart that could not be scheduled when thrown', () {
    expect(
      describeMaintenanceFailure(
        l10n,
        const MaintenanceAborted(RestartNotScheduledFailure()),
      ),
      l10n.profileCopy_restartCouldNotBeScheduled(
        l10n.profileCopy_nothingChanged,
      ),
    );
  });
}
