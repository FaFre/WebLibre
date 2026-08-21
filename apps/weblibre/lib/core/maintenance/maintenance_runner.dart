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

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/maintenance/backup_archive_name.dart';
import 'package:weblibre/core/maintenance/backup_operation.dart';
import 'package:weblibre/core/maintenance/delete_operation.dart';
import 'package:weblibre/core/maintenance/maintenance_journal_store.dart';
import 'package:weblibre/core/maintenance/maintenance_lease.dart';
import 'package:weblibre/core/maintenance/maintenance_outcome.dart';
import 'package:weblibre/core/maintenance/maintenance_participant.dart';
import 'package:weblibre/core/maintenance/native_participant.dart';
import 'package:weblibre/core/maintenance/restore_operation.dart';
import 'package:weblibre/core/startup/models/maintenance_journal.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/core/startup/startup_config_store.dart';
import 'package:weblibre/core/startup/startup_paths.dart';

/// How the archive is produced. Injected so the operation stays testable without
/// running Argon2 over a real profile.
typedef ArchivePacker =
    Future<void> Function(
      Directory source,
      File output,
      String password, {
      required bool integrityCheck,
    });

/// How the finished archive leaves the app's private storage.
typedef ArchivePublisher =
    Future<void> Function(File archive, Uri targetTree, String fileName);

/// Whether the destination still accepts writes.
///
/// Checked *before* the profile is copied and packed. A SAF grant can be revoked
/// between queueing a backup and the restart that runs it, and discovering that
/// only at publication means having spent the whole pack on a target that was
/// never going to accept it.
typedef ArchiveTargetCheck = Future<bool> Function(Uri targetTree);

/// How an archive is brought into private storage and expanded.
typedef ArchiveUnpacker =
    Future<void> Function(Uri sourceFile, Directory staging, String password);

/// Runs queued maintenance under a lease, provider-free.
///
/// It touches no Riverpod, no profile database, and no routes, because it runs in
/// a process that has deliberately not opened a profile. Everything it needs that
/// would normally live in profile settings — the SAF target, the options — travels
/// in the durable task record instead.
class MaintenanceRunner {
  const MaintenanceRunner({
    required this.store,
    required this.lease,
    required this.profilesDir,
    required this.workRoot,
    required this.packer,
    required this.publisher,
    this.paths,
    this.unpacker,
    this.verifyTarget,
    this.participants,
    this.syncDirectory,
    this.availableBytes,
    this.now = DateTime.now,
  });

  final StartupConfigStore store;
  final MaintenanceLease lease;
  final Directory profilesDir;
  final Directory workRoot;
  final ArchivePacker packer;
  final ArchivePublisher publisher;

  /// Required for the journaled operations, which write outside the profile.
  final StartupPaths? paths;
  final ArchiveUnpacker? unpacker;
  final ArchiveTargetCheck? verifyTarget;

  /// Passed through to every journal so a phase record's directory entry can be
  /// flushed. See [MaintenanceJournalStore.write].
  final Future<bool> Function(String path)? syncDirectory;

  /// Overrides participant discovery.
  ///
  /// Injected the same way the packer and publisher are, and for the same
  /// reason: the Dart-side participants reach a Flutter plugin, so a test that
  /// did not control this list would be asserting the plugin channel exists.
  final List<MaintenanceParticipant>? participants;

  final Future<int?> Function()? availableBytes;
  final DateTime Function() now;

  Future<List<MaintenanceParticipant>> _participants() async =>
      participants ?? await resolveNativeParticipants();

  /// Executes [task] under a renewed lease.
  ///
  /// The renewal belongs here rather than in each operation: the lease has to
  /// outlive whatever the *slowest* step turns out to be, and which step that is
  /// differs per action. See [MaintenanceLease.keepAlive].
  Future<MaintenanceTask> run(
    MaintenanceTask task, {
    required String password,
  }) => lease.keepAlive(() => _run(task, password: password));

  /// Executes [task], recording every state change durably as it goes.
  ///
  /// The task record is advanced before the work and after it, never only at the
  /// end: a process that dies mid-backup must leave behind a task that says it
  /// was running, so the next one can tell the difference between "never started"
  /// and "interrupted".
  Future<MaintenanceTask> _run(
    MaintenanceTask task, {
    required String password,
  }) async {
    if (task.isQuarantined) {
      logger.w('Refusing to run quarantined maintenance task ${task.id}');
      return task;
    }

    switch (task.action) {
      case MaintenanceAction.backup:
        break;
      case MaintenanceAction.restoreOver:
        return _runRestoreOver(task, password);
      case MaintenanceAction.delete:
        return _runDelete(task);
      case MaintenanceAction.restoreClone:
      case null:
        // Restoring into a *new* profile is not destructive and stays in the
        // normal app, where it already works; there is nothing for a maintenance
        // lease to protect.
        return _fail(
          task,
          const UnknownMaintenanceFailure(
            'This task was created by a newer version of WebLibre and cannot '
            'run here.',
          ),
        );
    }

    final targetTreeUri = task.targetTreeUri;
    if (targetTreeUri == null || targetTreeUri.isEmpty) {
      return _fail(
        task,
        const UnknownMaintenanceFailure(
          'This backup has no destination folder recorded.',
        ),
      );
    }

    await store.transitionTask(task.id, MaintenanceTaskState.running);

    try {
      await lease.assertHeld('maintenance.run:${task.id}');

      final profileDir = profileDirIn(profilesDir, task.profileId);
      if (!profileDir.existsSync()) {
        return await _fail(task, profileNoLongerExists);
      }

      final check = verifyTarget;
      if (check != null && !await check(Uri.parse(targetTreeUri))) {
        // Actionable rather than a mid-publish I/O error: the user has to grant
        // the folder again, and nothing has been written yet.
        return await _fail(task, const BackupFolderUnavailableFailure());
      }

      final workDir = Directory(p.join(workRoot.path, 'task_${task.id}'));
      await workDir.create(recursive: true);

      try {
        final fileName = _archiveName(task);

        final result = await backupProfile(
          lease: lease,
          profileDir: profileDir,
          profileId: task.profileId,
          profileName: task.profileName,
          workDir: workDir,
          taskId: task.id,
          options: BackupOptions(integrityCheck: task.integrityCheck),
          participants: await _participants(),
          availableBytes: availableBytes,
          now: now(),
          pack: (source, output) => packer(
            source,
            output,
            password,
            integrityCheck: task.integrityCheck,
          ),
          publish: (archive) =>
              publisher(archive, Uri.parse(targetTreeUri), fileName),
        );

        logger.i(
          'Backed up ${task.profileName} '
          '(${result.manifest.entryCount} files, ${result.manifest.sourceBytes} bytes)',
        );
      } finally {
        try {
          if (workDir.existsSync()) {
            await workDir.delete(recursive: true);
          }
        } catch (error, stackTrace) {
          logger.w(
            'Could not clean up the maintenance workspace',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }

      await lease.assertHeld('maintenance.complete:${task.id}');
      return await _completed(task);
    } on MaintenanceLeaseLost catch (error) {
      // Not a failure of the work — a failure of this process's entitlement to do
      // it. The task stays as it is so whoever holds the lease next sees the same
      // record, rather than one this process marked failed on its way out.
      logger.w('Stopping maintenance task ${task.id}: $error');
      rethrow;
    } catch (error, stackTrace) {
      logger.e(
        'Maintenance task ${task.id} failed',
        error: error,
        stackTrace: stackTrace,
      );
      return _fail(task, classifyMaintenanceFailure(error));
    }
  }

  Future<MaintenanceTask> _runRestoreOver(
    MaintenanceTask task,
    String password,
  ) async {
    final startupPaths = paths;
    final unpack = unpacker;
    final sourceFileUri = task.sourceFileUri;

    if (startupPaths == null || unpack == null) {
      return _fail(
        task,
        const UnknownMaintenanceFailure(
          'WebLibre cannot restore from this startup screen.',
        ),
      );
    }
    if (sourceFileUri == null || sourceFileUri.isEmpty) {
      return _fail(
        task,
        const UnknownMaintenanceFailure(
          'This restore has no backup file recorded.',
        ),
      );
    }

    await store.transitionTask(task.id, MaintenanceTaskState.running);

    try {
      final operation = RestoreOperation(
        lease: lease,
        journals: _journals(startupPaths),
        paths: startupPaths,
        participants: await _participants(),
        targetProfileName: task.profileName,
        adoptArchiveName: task.adoptArchiveName,
        now: now,
        unpack: (archive, staging) =>
            unpack(Uri.parse(sourceFileUri), staging, password),
      );

      // The archive is fetched by the unpacker, so the file handed to `run` is
      // only an identity for the journal — the operation never reads it directly.
      await operation.run(
        taskId: task.id,
        targetProfileId: task.profileId,
        archive: File(sourceFileUri),
        archiveDigest: task.sourceDigest,
      );

      return await _completed(task);
    } on MaintenanceLeaseLost {
      rethrow;
    } on MaintenanceAborted catch (error) {
      // Nothing was replaced and the operation cleaned up after itself, so this
      // is an ordinary failure. Marking it `recoveryRequired` instead would keep
      // the maintenance reservation alive over a profile that was never touched
      // — which turned a mistyped archive password into a browser that could not
      // be opened again.
      logger.w('Restore ${task.id} did not start: ${error.reason}');
      return _fail(task, error.failure);
    } on RestoreUnrecoverable catch (error) {
      // The journal stays on disk, so the reservation survives and the next
      // process offers recovery rather than booting a half-restored profile.
      logger.e('Restore ${task.id} needs manual recovery: $error');
      return _mark(
        task,
        MaintenanceTaskState.recoveryRequired,
        UnknownMaintenanceFailure('$error'),
      );
    } catch (error, stackTrace) {
      logger.e(
        'Restore ${task.id} failed',
        error: error,
        stackTrace: stackTrace,
      );
      return _mark(
        task,
        MaintenanceTaskState.recoveryRequired,
        classifyMaintenanceFailure(error),
      );
    }
  }

  Future<MaintenanceTask> _runDelete(MaintenanceTask task) async {
    final startupPaths = paths;
    if (startupPaths == null) {
      return _fail(
        task,
        const UnknownMaintenanceFailure(
          'WebLibre cannot delete a profile from this startup screen.',
        ),
      );
    }

    await store.transitionTask(task.id, MaintenanceTaskState.running);

    try {
      await DeleteOperation(
        lease: lease,
        journals: _journals(startupPaths),
        paths: startupPaths,
        participants: await _participants(),
        now: now,
      ).run(taskId: task.id, profileId: task.profileId);

      return await _completed(task);
    } on MaintenanceLeaseLost {
      rethrow;
    } on MaintenanceAborted catch (error) {
      // Stopped before the ownership snapshot, so nothing was removed.
      logger.w('Delete ${task.id} did not start: ${error.reason}');
      return _fail(task, error.failure);
    } catch (error, stackTrace) {
      // Delete is forward-only, so a failure is not a failure to undo — it is a
      // partially deleted profile that must be finished, never booted.
      logger.e(
        'Delete ${task.id} failed',
        error: error,
        stackTrace: stackTrace,
      );
      return _mark(
        task,
        MaintenanceTaskState.recoveryRequired,
        classifyMaintenanceFailure(error),
      );
    }
  }

  /// Resumes whatever an interrupted journal describes, under a renewed lease.
  Future<String> recoverJournal(MaintenanceJournal journal) =>
      lease.keepAlive(() => _recoverJournal(journal));

  /// Resumes whatever an interrupted journal describes.
  ///
  /// Runs before any task is picked up: a journal is durable evidence that a
  /// mutation was in flight, and the task list is not — a corrupt or lost task
  /// record must never be able to release that.
  Future<String> _recoverJournal(MaintenanceJournal journal) async {
    final startupPaths = paths;
    if (startupPaths == null) {
      throw StateError('Recovery requires the global startup paths');
    }

    final journals = _journals(startupPaths);

    // Recovery has to run the same participants the interrupted process ran.
    // Without them it can reach `completed` having reconciled only the profile
    // directory, leaving preferences and shortcuts describing the data that was
    // replaced — and then delete the journal that was the evidence.
    final resolved = await _participants();

    switch (journal.kind) {
      case MaintenanceJournalKind.restore:
        final recovery = await RestoreOperation(
          lease: lease,
          journals: journals,
          paths: startupPaths,
          participants: resolved,
          now: now,
          // Recovery never re-extracts. Either the staged tree survived the crash
          // or it did not, and re-running the unpack would need a password this
          // process was never given.
          unpack: (archive, staging) async =>
              throw StateError('Recovery does not unpack'),
        ).recover(journal);

        final summary = switch (recovery.result) {
          RestoreRecoveryResult.restored =>
            'An interrupted restore was completed.',
          RestoreRecoveryResult.rolledBack =>
            'An interrupted restore was undone. The profile was left as it was.',
          RestoreRecoveryResult.indeterminate =>
            'An interrupted restore was reconciled. Check the profile to see '
                'whether the backup was applied.',
        };
        await _retireRecoveredTask(journal.taskId, summary);
        return summary;

      case MaintenanceJournalKind.delete:
        await DeleteOperation(
          lease: lease,
          journals: journals,
          paths: startupPaths,
          participants: resolved,
          now: now,
        ).recover(journal);

        // Forward-only, so reaching the end means the profile is gone.
        const summary = 'An interrupted deletion was completed.';
        await _retireRecoveredTask(journal.taskId, summary);
        return summary;

      case null:
        // Never optimistically discarded: an unreadable journal is exactly the
        // case where booting the target could destroy data.
        throw StateError('Unrecognised maintenance journal ${journal.taskId}');
    }
  }

  /// Takes the reconciled task out of the states that hold the reservation.
  ///
  /// Recovery used to reconcile the journal and stop there. But `activeTasks`
  /// blocks on `running`/`recoveryRequired` too, and the journal is not the only
  /// evidence — so a *successful* recovery left the process in maintenance
  /// forever, with a task describing work that was already finished.
  ///
  /// Best-effort on purpose: the reconciliation is the part that had to be
  /// durable, and failing here would re-create the very state it exists to
  /// clear.
  Future<void> _retireRecoveredTask(String taskId, String summary) async {
    try {
      final config = await store.read(useCache: false);
      final task = config.taskById(taskId);
      if (task == null) return;
      if (!task.effectiveState.requiresMaintenance) return;

      // Through the state machine rather than around it: a journal is only ever
      // written after the task reaches `running`, so `running` and
      // `recoveryRequired` are the only states reachable here and both may
      // legally complete. Anything else is a bug worth the log line.
      await store.transitionTask(
        taskId,
        MaintenanceTaskState.completed,
        error: summary,
      );
    } catch (error, stackTrace) {
      logger.w(
        'Recovered $taskId but could not clear its task record',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Records [failure] against [task], message and kind together.
  ///
  /// Both, never one: the message is what the maintenance screen shows, and the
  /// kind is what it branches on — it is the only thing that survives the
  /// process to tell the next one whether the password was to blame.
  Future<MaintenanceTask> _mark(
    MaintenanceTask task,
    MaintenanceTaskState state,
    MaintenanceFailure failure,
  ) async {
    final config = await store.mutateTask(
      task.id,
      (current) => current.withState(
        state,
        error: failure.message,
        errorKindId: failure.kind.name,
      ),
    );
    return config.taskById(task.id) ?? task;
  }

  /// Marks [task] completed and returns the record as it now stands.
  Future<MaintenanceTask> _completed(MaintenanceTask task) async {
    final config = await store.transitionTask(
      task.id,
      MaintenanceTaskState.completed,
    );
    return config.taskById(task.id) ?? task;
  }

  /// The journal store every journaled operation writes through.
  MaintenanceJournalStore _journals(StartupPaths startupPaths) =>
      MaintenanceJournalStore(startupPaths, syncDirectory: syncDirectory);

  Future<MaintenanceTask> _fail(
    MaintenanceTask task,
    MaintenanceFailure failure,
  ) => _mark(task, MaintenanceTaskState.failed, failure);

  String _archiveName(MaintenanceTask task) => backupArchiveName(
    profileName: task.profileName,
    // Local, and stamped when the archive is written rather than when it was
    // queued — a restart sits between those two moments.
    at: now(),
  );
}
