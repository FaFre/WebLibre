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
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/maintenance/maintenance_journal_store.dart';
import 'package:weblibre/core/maintenance/maintenance_lease.dart';
import 'package:weblibre/core/maintenance/maintenance_outcome.dart';
import 'package:weblibre/core/maintenance/maintenance_participant.dart';
import 'package:weblibre/core/maintenance/participant_category.dart';
import 'package:weblibre/core/startup/models/maintenance_journal.dart';
import 'package:weblibre/core/startup/startup_paths.dart';

/// Deletes a profile, forward-only.
///
/// There is no rollback and the journal has no commit barrier in the restore
/// sense: once external jobs and notifications are gone they cannot be put back,
/// so recovery only ever resumes. Cancellation stops being offered the moment the
/// ownership snapshot is taken.
///
/// That snapshot is taken *before* any deletion, and that ordering is the point:
/// every later category — scheduled jobs, native preferences, credentials — needs
/// to know what belonged to this profile, and the database that could answer is
/// one of the things being removed.
class DeleteOperation {
  const DeleteOperation({
    required this.lease,
    required this.journals,
    required this.paths,
    this.participants = const [],
    this.now = DateTime.now,
  });

  final MaintenanceLease lease;
  final MaintenanceJournalStore journals;
  final StartupPaths paths;

  /// Categories outside the profile directory, supplied by the caller so that a
  /// run and its recovery act on the same list.
  final List<MaintenanceParticipant> participants;

  final DateTime Function() now;

  Directory profileDir(String profileId) => paths.profileDir(profileId);

  File snapshotFile(String taskId) =>
      File(p.join(paths.maintenanceDir.path, 'ownership_$taskId.json'));

  Future<MaintenanceJournal> run({
    required String taskId,
    required String profileId,
  }) async {
    // Checked before the journal exists, so a task naming a directory that is
    // not there stops as a clean refusal rather than as a delete that reports
    // success over nothing. Every later phase reconciles "already gone" as done
    // — which is right for a *resumed* delete and wrong for one that never had
    // a target: the user would be told the profile was removed while the
    // directory they meant is still on disk. [recover] deliberately has no such
    // check; by then absence is the expected end state.
    if (!profileDir(profileId).existsSync()) {
      throw const MaintenanceAborted(profileNoLongerExists);
    }

    final journal = await journals.write(
      MaintenanceJournal(
        taskId: taskId,
        kindId: MaintenanceJournalKind.delete.name,
        phaseId: DeletePhase.created.name,
        targetProfileId: profileId,
        updatedAt: now(),
      ),
    );

    try {
      return await _resume(journal);
    } on MaintenanceLeaseLost {
      rethrow;
    } catch (error, stackTrace) {
      // Read back rather than tracked: `_resume` advances a journal of its own,
      // and the durable record is the one that decides.
      final reached = (await journals.read(taskId))?.deletePhase;
      if (reached?.isPastCommitBarrier ?? true) {
        // The ownership snapshot has been taken, so removal is under way and is
        // forward-only. The journal stays and recovery finishes it.
        rethrow;
      }

      // Before the barrier nothing has been removed — in practice this is the
      // ownership snapshot itself failing to write. Leaving the journal would
      // reserve maintenance permanently over a delete that never started.
      logger.w(
        'Delete $taskId stopped before anything was removed',
        error: error,
        stackTrace: stackTrace,
      );
      await journals.delete(taskId);

      throw MaintenanceAborted(classifyMaintenanceFailure(error), cause: error);
    }
  }

  /// Resumes an interrupted delete from wherever it stopped.
  ///
  /// Every category is idempotent and every "already gone" reconciles as done,
  /// so replaying from an earlier phase than the true one is safe — which matters,
  /// because a phase record that never reached disk is exactly what recovery has
  /// to survive.
  Future<MaintenanceJournal> recover(MaintenanceJournal journal) {
    if (journal.deletePhase == null) {
      throw StateError('Unrecognised delete journal ${journal.taskId}');
    }
    return _resume(journal);
  }

  Future<MaintenanceJournal> _resume(MaintenanceJournal start) async {
    var journal = start;
    final from = journal.deletePhase ?? DeletePhase.created;

    Future<void> step(
      DeletePhase phase,
      Future<void> Function() mutation,
    ) async {
      if (phase.index <= from.index) return;
      await lease.assertHeld('delete.${phase.name}:${journal.taskId}');
      await mutation();
      journal = await journals.write(
        journal.copyWith(phaseId: phase.name, updatedAt: now()),
      );
    }

    // Quiescing is a no-op here by construction: maintenance runs in a process
    // that has never opened this profile, which is a stronger guarantee than
    // closing writers would be.
    await step(DeletePhase.quiesced, () async {});

    await step(DeletePhase.ownershipSnapshotted, () async {
      await _writeOwnershipSnapshot(journal.taskId, journal.targetProfileId);
    });

    // Nothing is archived by a delete, so the workspace is the maintenance
    // directory: it only has to outlive a crash, not travel anywhere. Both roles
    // collapse onto it — there is no archive tree for a snapshot to travel in,
    // and the directory being removed is the profile's, never this one.
    final participantDir = Directory(
      p.join(paths.maintenanceDir.path, 'participants_${journal.taskId}'),
    )..createSync(recursive: true);
    final context = MaintenanceParticipantContext(
      taskId: journal.taskId,
      profileId: journal.targetProfileId,
      kind: MaintenanceOperationKind.delete,
      stagedDir: participantDir,
      rollbackDir: participantDir,
      // Still present at `prepare`, which is where the evidence has to be read:
      // the database that says which credentials belong here is one of the
      // things being deleted.
      profileDir: profileDir(journal.targetProfileId),
    );
    final coordinator = ParticipantCoordinator(
      lease: lease,
      participants: participants,
      onRecords: (records) async {
        journal = await journals.write(
          journal.copyWith(participants: records, updatedAt: now()),
        );
      },
    );

    // Jobs, external files, native state, and shared credentials all live outside
    // the profile directory, and each is a participant. The remaining phases have
    // no body of their own: they are the write-ahead boundaries the coordinator's
    // work sits between, and recovery reads them to know how far it got.
    await step(DeletePhase.jobsPrepared, () async {
      await coordinator.prepareAll(context);
    });
    await step(DeletePhase.jobsDeleted, () async {
      // Never rolled back: the ownership snapshot is the barrier, and restoring
      // already-cancelled jobs or dismissed notifications is not possible.
      await coordinator.applyAll(context, rollbackOnFailure: false);
    });
    await step(DeletePhase.externalPrepared, () async {});
    await step(DeletePhase.externalDeleted, () async {});
    await step(DeletePhase.nativeStatePrepared, () async {});
    await step(DeletePhase.nativeStateDeleted, () async {});
    await step(DeletePhase.sharedCredentialsPrepared, () async {});
    await step(DeletePhase.sharedCredentialsReconciled, () async {
      await coordinator.finalizeAll(context);
    });

    await step(DeletePhase.internalPrepared, () async {});
    await step(DeletePhase.internalDeleted, () async {
      final directory = profileDir(journal.targetProfileId);
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    });

    await step(DeletePhase.completed, () async {
      final snapshot = snapshotFile(journal.taskId);
      if (snapshot.existsSync()) {
        await snapshot.delete();
      }
      if (participantDir.existsSync()) {
        await participantDir.delete(recursive: true);
      }
    });

    await journals.delete(journal.taskId);
    return journal;
  }

  /// Records what belonged to the profile while it can still be read.
  ///
  /// Best-effort on content, mandatory on existence: a snapshot that could not be
  /// filled in still marks the boundary, and the categories it could not describe
  /// are named so a later build can tell "nothing was there" from "we could not
  /// look".
  Future<void> _writeOwnershipSnapshot(String taskId, String profileId) async {
    final directory = profileDir(profileId);

    final entries = <String>[];
    if (directory.existsSync()) {
      await for (final entity in directory.list(followLinks: false)) {
        entries.add(p.basename(entity.path));
      }
      entries.sort();
    }

    await snapshotFile(taskId).parent.create(recursive: true);
    await snapshotFile(taskId).writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'version': 1,
        'taskId': taskId,
        'profileId': profileId,
        'profileExisted': directory.existsSync(),
        'topLevelEntries': entries,
        // Derived, not restated: a category added to the registry is named
        // here without anyone remembering to come back and add it.
        'unrecordedCategories': ParticipantCategory.deleteOmissions,
        'takenAt': now().toUtc().toIso8601String(),
      }),
      flush: true,
    );

    logger.i('Recorded ownership snapshot for $profileId (task $taskId)');
  }
}
