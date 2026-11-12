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
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/maintenance/maintenance_outcome.dart';
import 'package:weblibre/core/maintenance/saf_archive_target.dart';

/// A native write that records what it was asked and answers [answer].
///
/// What happens inside the provider — the staging file, its size check, its
/// removal on failure — is native and tested there (`SafTreeWriterTest`).
class _RecordingWrite {
  _RecordingWrite(this.answer);

  final TreePublication answer;
  final calls = <({Uri tree, String fileName, String stagingName})>[];

  Future<TreePublication> call(
    Uri tree,
    String fileName,
    String stagingName,
  ) async {
    calls.add((tree: tree, fileName: fileName, stagingName: stagingName));
    return answer;
  }
}

TreePublication _failed(
  BackupTreeProbeOutcome outcome, {
  TreePublicationFault? fault,
  int? requiredBytes,
  int? availableBytes,
}) => TreePublication(
  outcome: outcome,
  fault: fault,
  requiredBytes: requiredBytes,
  availableBytes: availableBytes,
  errorClass: 'java.io.FileNotFoundException',
  errorMessage: 'Missing file for vol:Backups',
);

void main() {
  late Directory root;
  late File archive;

  final target = Uri.parse('content://tree');
  const fileName = 'backup_Work_2026-08-19_101500.weblibre';

  setUp(() {
    root = Directory.systemTemp.createTempSync('weblibre_saf');
    archive = File(p.join(root.path, 'archive.weblibre'))
      ..writeAsStringSync('a complete archive');
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  Future<Uri> publish(_RecordingWrite write) => publishArchiveToSaf(
    archive: archive,
    targetTree: target,
    fileName: fileName,
    write: write.call,
  );

  Future<Object?> failureOf(Future<Object?> future) async {
    try {
      await future;
    } catch (error) {
      return error;
    }
    return null;
  }

  group('publishing a backup', () {
    test('goes in under the partial name and comes back under the final '
        'one', () async {
      final write = _RecordingWrite(
        TreePublication(
          outcome: BackupTreeProbeOutcome.writable,
          uri: 'content://tree/document/$fileName',
          name: fileName,
        ),
      );

      final uri = await publish(write);

      expect(uri, Uri.parse('content://tree/document/$fileName'));
      expect(write.calls.single.tree, target);
      expect(write.calls.single.fileName, fileName);
      expect(write.calls.single.stagingName, '$fileName$partialArchiveSuffix');
    });

    test('a folder that is gone or refuses files is unavailable', () async {
      for (final outcome in [
        BackupTreeProbeOutcome.noGrant,
        BackupTreeProbeOutcome.missing,
        BackupTreeProbeOutcome.refused,
      ]) {
        final error = await failureOf(
          publish(_RecordingWrite(_failed(outcome))),
        );

        expect(error, isA<BackupTargetUnavailable>(), reason: outcome.name);
        // Kept, so settings export can tell "gone" from "refuses files".
        expect((error! as BackupTargetUnavailable).outcome, outcome);
        expect(
          classifyMaintenanceFailure(error),
          isA<BackupFolderUnavailableFailure>(),
          reason: outcome.name,
        );
      }
    });

    test('a full volume is the folder being full, not the app', () async {
      final error = await failureOf(
        publish(_RecordingWrite(_failed(BackupTreeProbeOutcome.noSpace))),
      );

      expect(error, isA<BackupTargetFull>());
      // Not NotEnoughStorage: that one is about the app's own storage, and
      // freeing it would not help.
      expect(
        classifyMaintenanceFailure(error!),
        isA<BackupFolderFullFailure>(),
      );
    });

    test('a volume visibly too small carries the numbers through', () async {
      final error = await failureOf(
        publish(
          _RecordingWrite(
            _failed(
              BackupTreeProbeOutcome.noSpace,
              requiredBytes: 3000,
              availableBytes: 2000,
            ),
          ),
        ),
      );

      final failure = classifyMaintenanceFailure(error!);
      expect(failure, isA<BackupFolderFullFailure>());
      failure as BackupFolderFullFailure;
      expect(failure.requiredBytes, 3000);
      expect(failure.availableBytes, 2000);
    });

    test('a short copy never takes the final name, and keeps the '
        'folder', () async {
      final error = await failureOf(
        publish(
          _RecordingWrite(
            _failed(
              BackupTreeProbeOutcome.inconclusive,
              fault: TreePublicationFault.truncated,
            ),
          ),
        ),
      );

      expect(
        error,
        isA<BackupWriteFailed>().having(
          (e) => e.fault,
          'fault',
          TreePublicationFault.truncated,
        ),
      );
      // A provider reporting the size late is not the folder refusing
      // files: "choose the folder again" would send the user the wrong way.
      final failure = classifyMaintenanceFailure(error!);
      expect(failure, isNot(isA<BackupFolderUnavailableFailure>()));
      expect(
        failure,
        isA<BackupWriteFailure>().having(
          (f) => f.reason,
          'reason',
          BackupWriteFailureReason.incomplete,
        ),
      );
    });

    test("a failure that blames nothing keeps the provider's account, not "
        '"choose the folder again"', () async {
      final error = await failureOf(
        publish(_RecordingWrite(_failed(BackupTreeProbeOutcome.inconclusive))),
      );

      expect(error, isA<BackupWriteFailed>());
      final failure = classifyMaintenanceFailure(error!);
      expect(
        failure,
        isA<BackupWriteFailure>()
            .having(
              (f) => f.reason,
              'reason',
              BackupWriteFailureReason.providerFailed,
            )
            // The provider's words, without the outcome's enum name or the
            // exception's class around them.
            .having((f) => f.detail, 'detail', 'Missing file for vol:Backups'),
      );
    });

    test('an unreadable source is the archive, not the folder', () async {
      final error = await failureOf(
        publish(
          _RecordingWrite(
            _failed(
              BackupTreeProbeOutcome.inconclusive,
              fault: TreePublicationFault.sourceUnreadable,
            ),
          ),
        ),
      );

      expect(
        error,
        isA<BackupWriteFailed>().having(
          (e) => e.fault,
          'fault',
          TreePublicationFault.sourceUnreadable,
        ),
      );
      expect(
        classifyMaintenanceFailure(error!),
        isA<BackupWriteFailure>().having(
          (f) => f.reason,
          'reason',
          BackupWriteFailureReason.archiveUnreadable,
        ),
      );
    });

    test('a success without a document is not a success', () async {
      final error = await failureOf(
        publish(
          _RecordingWrite(
            TreePublication(outcome: BackupTreeProbeOutcome.writable),
          ),
        ),
      );

      expect(error, isA<BackupWriteFailed>());
    });

    test('a partial file is not a backup the list would offer', () {
      // The list filters on `.weblibre`, and `.weblibre.partial` does not match —
      // so an interrupted publication cannot be picked for a restore.
      expect('$fileName$partialArchiveSuffix'.endsWith('.weblibre'), isFalse);
    });
  });

  group('publishing bytes', () {
    test('returns the name the provider gave the file', () async {
      final write = _RecordingWrite(
        TreePublication(
          outcome: BackupTreeProbeOutcome.writable,
          uri: 'content://tree/document/export (1).json',
          name: 'export (1).json',
        ),
      );

      final name = await publishBytesToSaf(
        bytes: Uint8List.fromList([1, 2, 3]),
        targetTree: target,
        fileName: 'export.json',
        mimeType: 'application/json',
        write: write.call,
      );

      expect(name, 'export (1).json');
      expect(write.calls.single.stagingName, 'export.json.partial');
    });

    test('fails the same way a backup does', () async {
      final error = await failureOf(
        publishBytesToSaf(
          bytes: Uint8List.fromList([1, 2, 3]),
          targetTree: target,
          fileName: 'export.json',
          mimeType: 'application/json',
          write: _RecordingWrite(_failed(BackupTreeProbeOutcome.missing)).call,
        ),
      );

      expect(error, isA<BackupTargetUnavailable>());
    });
  });

  group('checking the grant', () {
    test('a live grant is a grant', () async {
      expect(await safTreeHasGrant(target, check: (_) async => true), isTrue);
    });

    test('a revoked grant is not', () async {
      expect(await safTreeHasGrant(target, check: (_) async => false), isFalse);
    });

    test('a check that fails is no grant', () async {
      expect(
        await safTreeHasGrant(
          target,
          check: (_) async => throw PlatformException(code: 'channel-error'),
        ),
        isFalse,
      );
    });
  });

  group('the verdict', () {
    test('only lost access blames the folder', () {
      expect(
        {
          for (final outcome in BackupTreeProbeOutcome.values)
            if (SafFolderVerdict.of(outcome) == SafFolderVerdict.lost) outcome,
        },
        {
          BackupTreeProbeOutcome.noGrant,
          BackupTreeProbeOutcome.missing,
          BackupTreeProbeOutcome.refused,
        },
      );
    });

    test('a full volume is full, and no answer is no verdict', () {
      expect(
        SafFolderVerdict.of(BackupTreeProbeOutcome.noSpace),
        SafFolderVerdict.full,
      );
      expect(
        SafFolderVerdict.of(BackupTreeProbeOutcome.inconclusive),
        SafFolderVerdict.unknown,
      );
    });
  });

  group('the write check', () {
    test('a check that could not run is no verdict', () async {
      Future<BackupTreeProbe> failing(Uri _) async =>
          throw PlatformException(code: 'channel-error');

      final check = await probeBackupTarget(target, prober: failing);
      expect(check.verdict, SafFolderVerdict.unknown);
      expect(check.folderName, isNull);
    });

    test('a provider that never answers is unresponsive, in bounded '
        'time', () async {
      final never = Completer<BackupTreeProbe>();

      final check = await probeBackupTarget(
        target,
        prober: (_) => never.future,
        timeout: const Duration(milliseconds: 20),
      );
      expect(check.verdict, SafFolderVerdict.unresponsive);
    });

    test("an answer keeps the provider's folder name", () async {
      final check = await probeBackupTarget(
        target,
        prober: (_) async => BackupTreeProbe(
          outcome: BackupTreeProbeOutcome.refused,
          folderName: 'Backups',
        ),
      );
      expect(check.verdict, SafFolderVerdict.lost);
      expect(check.folderName, 'Backups');
    });
  });

  group('what the check means for a queued backup', () {
    BackupFolderCheck answer(BackupTreeProbeOutcome outcome) =>
        BackupFolderCheck(SafFolderVerdict.of(outcome));

    test('lost access stops it as an unavailable folder', () {
      for (final outcome in [
        BackupTreeProbeOutcome.noGrant,
        BackupTreeProbeOutcome.missing,
        BackupTreeProbeOutcome.refused,
      ]) {
        expect(
          backupTargetFailure(answer(outcome)),
          isA<BackupFolderUnavailableFailure>(),
          reason: outcome.name,
        );
      }
    });

    test('a full volume stops it as a full folder', () {
      expect(
        backupTargetFailure(answer(BackupTreeProbeOutcome.noSpace)),
        isA<BackupFolderFullFailure>(),
      );
    });

    test('a provider that did not answer stops it before the pack', () {
      // The publication would hang on the same provider, with nothing able
      // to cancel it, and the startup screen with it.
      expect(
        backupTargetFailure(
          const BackupFolderCheck(SafFolderVerdict.unresponsive),
        ),
        isA<BackupFolderUnresponsiveFailure>(),
      );
    });

    test('no verdict lets it through to report its own error', () {
      expect(
        backupTargetFailure(const BackupFolderCheck(SafFolderVerdict.unknown)),
        isNull,
      );
      expect(
        backupTargetFailure(answer(BackupTreeProbeOutcome.inconclusive)),
        isNull,
      );
      expect(
        backupTargetFailure(answer(BackupTreeProbeOutcome.writable)),
        isNull,
      );
    });
  });
}
