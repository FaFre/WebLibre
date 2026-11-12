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
 */
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show BackupTreeProbeOutcome, TreePublicationFault;
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_archive/secure_archive.dart';
import 'package:weblibre/core/maintenance/backup_operation.dart';
import 'package:weblibre/core/maintenance/maintenance_outcome.dart';
import 'package:weblibre/core/maintenance/saf_archive_target.dart' as saf;
import 'package:weblibre/core/startup/models/json_read.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';

void main() {
  group('classifyMaintenanceFailure', () {
    test('a wrong password on the pinned archive build is explained', () {
      // Verbatim from `secure_archive` before the streaming race was fixed:
      // decryption is streamed and the MAC is only checked at the end, so the
      // gzip decoder dies on keystream garbage first and the failure escapes its
      // isolate as a `RemoteError` that is not even an `Exception`. Users saw
      // this string and nothing else.
      final failure = classifyMaintenanceFailure(
        'FormatException: Filter error, bad data',
      );

      expect(failure, isA<UnreadableArchive>());
      expect(failure.blamesPassword, isTrue);
      expect(failure.kind, MaintenanceFailureKind.unreadableArchive);
    });

    test('a wrong password that authenticates cleanly is named exactly', () {
      // What the fixed build reports. No hedging here: the MAC said the key was
      // wrong.
      final failure = classifyMaintenanceFailure(
        'Exception: Authentication failed for part 0: wrong password or '
        'corrupted data',
      );

      expect(failure, isA<WrongArchivePassword>());
      expect(failure.blamesPassword, isTrue);
    });

    test('a typed wrong password is named exactly', () {
      final failure = classifyMaintenanceFailure(
        const ArchiveWrongPassword(part: 1),
      );

      expect(failure, isA<WrongArchivePassword>());
      expect(failure.kind, MaintenanceFailureKind.wrongPassword);
      expect(failure.blamesPassword, isTrue);
      expect(failure.message, isNot(contains('ArchiveWrongPassword')));
    });

    test('an authenticated archive that will not unpack is damage', () {
      // Past the MAC check, so the password was right and retyping it cannot
      // help — the screen must not mark the password field.
      final failure = classifyMaintenanceFailure(
        'Exception: Failed to extract part 1: some tar failure',
      );

      expect(failure, isA<DamagedArchive>());
      expect(failure.blamesPassword, isFalse);
    });

    test('typed archive damage is not blamed on the password', () {
      final failure = classifyMaintenanceFailure(
        const ArchiveDamaged(part: 1, detail: 'some tar failure'),
      );

      expect(failure, isA<DamagedArchive>());
      expect(failure.kind, MaintenanceFailureKind.damagedArchive);
      expect(failure.blamesPassword, isFalse);
    });

    test('an unreadable format version is not blamed on the password', () {
      // The version byte is plaintext header: it is wrong because the file came
      // from a different build, never because the password did.
      final failure = classifyMaintenanceFailure(
        const FormatException('Unsupported version: 2'),
      );

      expect(failure, isA<UnsupportedArchiveVersion>());
      expect(failure.blamesPassword, isFalse);
    });

    test('a typed unreadable format version is not blamed on the password', () {
      final failure = classifyMaintenanceFailure(
        const ArchiveUnsupportedVersion(2),
      );

      expect(failure, isA<UnsupportedArchiveVersion>());
      expect(failure.kind, MaintenanceFailureKind.unsupportedArchiveVersion);
      expect(failure.blamesPassword, isFalse);
    });

    test('a missing archive part is archive damage', () {
      final failure = classifyMaintenanceFailure(const ArchivePartMissing(2));

      expect(failure, isA<DamagedArchive>());
      expect(failure.kind, MaintenanceFailureKind.damagedArchive);
      expect(failure.blamesPassword, isFalse);
    });

    test('a failed integrity check is archive damage', () {
      final failure = classifyMaintenanceFailure(
        const ArchiveIntegrityCheckFailed(detail: 'does not match source'),
      );

      expect(failure, isA<DamagedArchive>());
      expect(failure.kind, MaintenanceFailureKind.damagedArchive);
      expect(failure.blamesPassword, isFalse);
    });

    test('a storage refusal keeps the numbers it always had', () {
      // The regression this hierarchy exists to make impossible: a typed
      // exception carrying exactly the numbers the user needs, walked past by a
      // string matcher that printed the class name instead.
      final failure = classifyMaintenanceFailure(
        const InsufficientStorage(
          requiredBytes: 2 * 1024 * 1024,
          availableBytes: 512 * 1024,
        ),
      );

      expect(failure, isA<NotEnoughStorage>());
      expect(failure.message, contains('2.00 MB'));
      expect(failure.message, contains('512.0 KB'));
      expect(failure.message, isNot(contains('InsufficientStorage')));
    });

    test('a backup folder refusal gets a user-facing message', () {
      final failure = classifyMaintenanceFailure(
        const saf.BackupTargetUnavailable(
          BackupTreeProbeOutcome.noGrant,
          'grant missing',
        ),
      );

      expect(failure, isA<BackupFolderUnavailableFailure>());
      expect(failure.kind, MaintenanceFailureKind.backupTargetUnavailable);
      expect(failure.message, contains('backup could not be written'));
      expect(failure.message, isNot(contains('BackupTargetUnavailable')));
    });

    test('a short publication keeps the folder', () {
      final failure = classifyMaintenanceFailure(
        const saf.BackupWriteFailed(
          fault: TreePublicationFault.truncated,
          detail: 'Wrote 10 of 10 bytes',
        ),
      );

      // Not "choose the folder again": a provider that reports the size late
      // is not a folder that refuses files.
      expect(failure, isA<BackupWriteFailure>());
      expect(failure.kind, MaintenanceFailureKind.backupWriteFailed);
      expect(failure.detailId, BackupWriteFailureReason.incomplete.name);
      expect(failure.message, contains('did not receive the whole backup'));
      expect(failure.message, isNot(contains('BackupWriteFailed')));
    });

    test('a full backup folder is not the app running out of space', () {
      final failure = classifyMaintenanceFailure(
        const saf.BackupTargetFull(detail: 'No space left on device'),
      );

      expect(failure, isA<BackupFolderFullFailure>());
      expect(failure.kind, MaintenanceFailureKind.backupTargetFull);
      expect(failure.message, contains('where the backup folder is stored'));
      expect(failure.message, isNot(contains('BackupTargetFull')));
    });

    test('a full backup folder survives the restart as itself', () {
      final task = MaintenanceTask(
        id: 't',
        actionId: MaintenanceAction.backup.name,
        stateId: MaintenanceTaskState.failed.name,
        profileId: 'p',
        profileName: 'Work',
        createdAt: DateTime(2026),
        errorKindId: const BackupFolderFullFailure().kind.name,
      );

      expect(task.recordedFailure, isA<BackupFolderFullFailure>());
    });

    test('a too small backup folder says how much is missing', () {
      final failure = classifyMaintenanceFailure(
        const saf.BackupTargetFull(
          requiredBytes: 3 * 1024 * 1024,
          availableBytes: 2 * 1024 * 1024,
        ),
      );

      expect(failure, isA<BackupFolderFullFailure>());
      expect(failure.message, contains('3.00 MB'));
      expect(failure.message, contains('2.00 MB'));
      expect(failure.message, isNot(contains('no space left')));
    });

    test("a write that blames nothing keeps the provider's account", () {
      // Not "choose the folder again": nothing said the folder was at fault.
      final failure = classifyMaintenanceFailure(
        const saf.BackupWriteFailed(detail: 'Failed to touch x'),
      );

      expect(failure, isA<BackupWriteFailure>());
      expect(failure.detailId, BackupWriteFailureReason.providerFailed.name);
      expect(failure.message, contains('Failed to touch x'));
    });

    test('an unreadable archive is not the folder', () {
      final failure = classifyMaintenanceFailure(
        const saf.BackupWriteFailed(
          fault: TreePublicationFault.sourceUnreadable,
          detail: 'open failed: ENOENT',
        ),
      );

      expect(failure, isA<BackupWriteFailure>());
      expect(failure.detailId, BackupWriteFailureReason.archiveUnreadable.name);
    });

    test('a write failure survives the restart with its reason', () {
      for (final reason in BackupWriteFailureReason.values) {
        final task = MaintenanceTask(
          id: 't',
          actionId: MaintenanceAction.backup.name,
          stateId: MaintenanceTaskState.failed.name,
          profileId: 'p',
          profileName: 'Work',
          createdAt: DateTime(2026),
          errorKindId: MaintenanceFailureKind.backupWriteFailed.name,
          errorDetailId: reason.name,
        );

        expect(
          task.recordedFailure,
          isA<BackupWriteFailure>().having((f) => f.reason, 'reason', reason),
        );
      }
    });

    test('an unresponsive backup folder survives the restart as itself', () {
      final task = MaintenanceTask(
        id: 't',
        actionId: MaintenanceAction.backup.name,
        stateId: MaintenanceTaskState.failed.name,
        profileId: 'p',
        profileName: 'Work',
        createdAt: DateTime(2026),
        errorKindId: const BackupFolderUnresponsiveFailure().kind.name,
      );

      expect(task.recordedFailure, isA<BackupFolderUnresponsiveFailure>());
    });

    test('an unrecognised failure is passed through verbatim', () {
      // Deliberate: the maintenance screen has no logs behind it, so a failure
      // the user can read out is worth more than a generic apology.
      final failure = classifyMaintenanceFailure('PathNotFoundException: nope');

      expect(failure, isA<UnknownMaintenanceFailure>());
      expect(failure.message, 'PathNotFoundException: nope');
    });

    test('an abort carries its own classification through unchanged', () {
      const inner = WrongArchivePassword();

      expect(
        classifyMaintenanceFailure(const MaintenanceAborted(inner)),
        same(inner),
      );
    });
  });

  group('MaintenanceFailureKind', () {
    test('round-trips through its id, and refuses one it does not know', () {
      for (final kind in MaintenanceFailureKind.values) {
        expect(MaintenanceFailureKind.values.tryByName(kind.name), kind);
      }

      // Null rather than a guess: a kind written by a newer build must not be
      // rewritten as one this build happens to understand.
      expect(MaintenanceFailureKind.values.tryByName('somethingNewer'), isNull);
    });

    test('only the two archive-opening kinds blame the password', () {
      final blaming = MaintenanceFailureKind.values
          .where((kind) => kind.blamesPassword)
          .toSet();

      expect(blaming, {
        MaintenanceFailureKind.wrongPassword,
        MaintenanceFailureKind.unreadableArchive,
      });
    });
  });
}
