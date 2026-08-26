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
import 'package:uuid/uuid_value.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/maintenance/backup_manifest.dart';
import 'package:weblibre/core/maintenance/maintenance_journal_store.dart';
import 'package:weblibre/core/maintenance/maintenance_lease.dart';
import 'package:weblibre/core/maintenance/maintenance_outcome.dart';
import 'package:weblibre/core/maintenance/maintenance_participant.dart';
import 'package:weblibre/core/maintenance/plaintext_cleanup.dart';
import 'package:weblibre/core/startup/models/maintenance_journal.dart';
import 'package:weblibre/core/startup/startup_paths.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;

/// The staged archive does not describe the profile it claims to.
class RestoreValidationFailure implements Exception {
  const RestoreValidationFailure(this.reason);

  final String reason;

  @override
  String toString() => 'RestoreValidationFailure($reason)';
}

/// The operation cannot be completed *or* rolled back without help.
///
/// Distinct from an ordinary failure: it means the profile directory is in a
/// state no automatic rule can resolve, so the reservation is kept and nothing
/// boots the target.
class RestoreUnrecoverable implements Exception {
  const RestoreUnrecoverable(this.reason);

  final String reason;

  @override
  String toString() => 'RestoreUnrecoverable($reason)';
}

/// What an interrupted restore turned out to have done.
///
/// Recovery reconciles the directories, but "reconciled" is not the same answer
/// as "the restore took effect", and the user needs the second one: a restore
/// that rolled back leaves them with the profile they already had, and telling
/// them it completed would be a lie they only discover later.
enum RestoreRecoveryResult {
  /// The archive is installed and live.
  restored,

  /// The user's original profile was put back; the archive was not applied.
  rolledBack,

  /// The directories alone cannot say. `hasTarget && !hasOld` means either the
  /// move never happened or cleanup already ran, and nothing on disk
  /// distinguishes them — so it is reported rather than guessed at.
  indeterminate,
}

/// The reconciled journal, and what it settled on.
class RestoreRecovery {
  const RestoreRecovery(this.journal, this.result);

  final MaintenanceJournal journal;
  final RestoreRecoveryResult result;
}

/// Replaces an existing profile's contents with a staged archive.
///
/// Every mutation is bracketed by a write-ahead intent and a completion record,
/// with the lease re-asserted at each boundary. The phase alone is never trusted
/// on the way back in — [recoverRestore] re-derives the real state from the three
/// directories, because the crash window between a rename and its directory entry
/// reaching disk is exactly where the phase can lie.
class RestoreOperation {
  const RestoreOperation({
    required this.lease,
    required this.journals,
    required this.paths,
    required this.unpack,
    this.participants = const [],
    this.targetProfileName,
    this.adoptArchiveName = false,
    this.now = DateTime.now,
  });

  final MaintenanceLease lease;
  final MaintenanceJournalStore journals;
  final StartupPaths paths;

  /// Extracts the archive into the staging directory, which it also creates.
  ///
  /// Deliberately not created for it: an archive extractor refuses a target
  /// directory that already exists — that refusal is how it proves it is not
  /// merging into somebody else's data — so handing it a freshly made empty one
  /// fails every restore before it starts. The operation guarantees only that the
  /// path is free and that its parent exists, which is also where an unpacker may
  /// put a downloaded copy of the archive.
  final Future<void> Function(File archive, Directory staging) unpack;

  /// Categories of profile state that live outside the profile directory.
  ///
  /// Supplied by the caller rather than discovered here: the runner resolves
  /// them once via `resolveNativeParticipants()` so that a run and its recovery
  /// see the same list, and tests can drive the phases with none at all.
  final List<MaintenanceParticipant> participants;

  /// The target's display name, for messages only.
  ///
  /// A profile-id mismatch is the one refusal a user meets by choosing wrongly
  /// rather than by anything going wrong, so it is the one that most needs to be
  /// readable. Two raw uuids tell them nothing about which backup they picked or
  /// which user they aimed it at.
  final String? targetProfileName;

  /// Whether the installed profile takes the *archive's* name.
  ///
  /// Off for an ordinary replace: the user picked a user to overwrite and did
  /// not ask to rename it, so identity stays with the target. On for the
  /// first-run restore, where the target is a profile the user has barely met —
  /// an auto-created `Default`, or one made moments earlier — and the archive is
  /// the thing they actually meant to end up with. The lock is never adopted
  /// either way; it is not in the archive's gift to remove.
  final bool adoptArchiveName;

  final DateTime Function() now;

  Directory targetDir(String profileId) => paths.profileDir(profileId);

  Future<MaintenanceJournal> run({
    required String taskId,
    required String targetProfileId,
    required File archive,
    String? archiveDigest,
  }) async {
    // A replace needs something to replace. Checked before anything is unpacked
    // or journalled, because the later phases all tolerate an absent target on
    // purpose — `oldMoved` skips the move and `installed` renames staging into
    // place — and that tolerance is for a *resumed* restore, where the target is
    // absent because this operation moved it. Reaching it with a target that
    // never existed turns "replace profile X" into "create a new directory named
    // after X's id", leaving X untouched and the archive installed somewhere the
    // user never chose.
    if (!targetDir(targetProfileId).existsSync()) {
      throw const MaintenanceAborted(profileNoLongerExists);
    }

    final staging = paths.restoreStagingDir(taskId);
    final old = paths.restoreOldDir(taskId);

    // Nothing may start over its own unresolved record. The journal write below
    // is a plain overwrite and `oldMoved` deletes whatever `old` already holds —
    // and `old` is the target profile as it was, moved aside by the attempt that
    // left this record and, once the record cannot be read, the only copy of it
    // anywhere. Recovery runs before any of this is offered, so reaching here
    // with either still present means recovery could not resolve them; the user
    // discards the record explicitly or nothing proceeds.
    //
    // Checked here rather than only in the screen because the screen is not the
    // only caller, and this is the step that does the destroying.
    // The *file*, not a successful parse. A journal that cannot be read is the
    // sharpest form of this — recovery skips it precisely because it cannot be
    // understood — so a check that only saw parseable journals would let the one
    // case that most needs blocking straight through.
    if (paths.journalFile(taskId).existsSync() || old.existsSync()) {
      throw const MaintenanceAborted(restoreEvidenceUnresolved);
    }

    var journal = await journals.write(
      MaintenanceJournal(
        taskId: taskId,
        kindId: MaintenanceJournalKind.restore.name,
        phaseId: RestorePhase.created.name,
        targetProfileId: targetProfileId,
        archiveDigest: archiveDigest,
        stagingPath: staging.path,
        oldPath: old.path,
        updatedAt: now(),
      ),
    );

    // Reads `journal` at write time rather than taking it as an argument: the
    // coordinator persists participant records *during* the mutation, and a
    // phase record built from the pre-mutation snapshot would write them back
    // out of the journal again.
    Future<void> advance(
      RestorePhase phase,
      Future<void> Function() mutation,
    ) async {
      await lease.assertHeld('restore.${phase.name}:$taskId');
      await mutation();
      journal = await journals.write(
        journal.copyWith(phaseId: phase.name, updatedAt: now()),
      );
    }

    // Everything from here on is bracketed, because *where* a restore fails
    // decides whether the browser can open again. See [_abandonBeforeInstall].
    try {
      await advance(RestorePhase.staged, () async {
        // Cleared and left absent, not created — see [unpack]. A leftover staging
        // tree from an earlier attempt is dropped rather than unpacked over: it
        // belongs to an archive nobody has verified against this target.
        if (staging.existsSync()) {
          await staging.delete(recursive: true);
        }
        await staging.parent.create(recursive: true);
        await unpack(archive, staging);
      });

      await advance(RestorePhase.validated, () async {
        // Structure first, identity second — and the identity is *assigned*,
        // not demanded. A backup can be restored over any user, including one
        // whose uuid differs from the archive's, because the uuid names where a
        // tree lives rather than what is in it. See [bindStagingToTarget].
        await validateStagedStructure(staging);
        await bindStagingToTarget(staging, targetProfileId);

        // From here the tree claims the directory it is going into, so every
        // later check — `verified`, and all of recovery — enforces the real
        // invariant with no knowledge that a re-addressing happened.
        await validateStaging(staging, targetProfileId);
      });

      final target = targetDir(targetProfileId);
      final rollbackDir = paths.restoreParticipantsDir(taskId);
      await rollbackDir.create(recursive: true);

      // Two contexts over the operation's life, because the staged tree *becomes*
      // the target halfway through. Reusing the pre-install one would point every
      // later step at a path that no longer exists, and a participant that finds no
      // snapshot concludes the archive never carried one — so the restore would
      // report success having silently applied nothing.
      var context = _context(taskId, targetProfileId, staging, rollbackDir);
      final coordinator = _coordinator(() => journal, (next) => journal = next);

      await advance(RestorePhase.participantsPrepared, () async {
        await coordinator.prepareAll(context);
      });

      await advance(RestorePhase.moveOldPrepared, () async {});
      await advance(RestorePhase.oldMoved, () async {
        if (target.existsSync()) {
          if (old.existsSync()) {
            await old.delete(recursive: true);
          }
          await old.parent.create(recursive: true);
          await target.rename(old.path);
        }
      });

      await advance(RestorePhase.installPrepared, () async {});
      await advance(RestorePhase.installed, () async {
        await staging.rename(target.path);
      });

      // The archive's participant data moved with the tree; the rollback data
      // deliberately did not.
      context = context
          .withStagedDir(_stagedDirIn(target))
          .withProfileDir(target);

      await advance(RestorePhase.participantsApplying, () async {});
      await advance(RestorePhase.participantsApplied, () async {
        // Rollback is still possible here: the barrier is `verified`, and until it
        // is written the old profile is still on disk to go back to.
        await coordinator.applyAll(context, rollbackOnFailure: true);
      });

      await advance(RestorePhase.verified, () async {
        await validateStaging(target, targetProfileId);
      });

      await advance(RestorePhase.cleanupPrepared, () async {
        // Past the barrier: rollback data is released, and a participant that
        // cannot finish cleanup does not fail the restore.
        await coordinator.finalizeAll(context);
      });
      await advance(RestorePhase.cleanupPending, () async {});
      await advance(RestorePhase.completed, () async {
        if (old.existsSync()) {
          await old.delete(recursive: true);
        }
        await _discardParticipantWork(rollbackDir);
        await _discardStagedParticipantWork(target);
      });

      await journals.delete(taskId);
      return journal;
    } on MaintenanceLeaseLost {
      // Not this operation's mess to clear up: another owner may hold the
      // reservation now, and deleting the journal would remove the evidence
      // they need to reconcile from.
      rethrow;
    } catch (error, stackTrace) {
      if (journal.restorePhase?.isDestructive ?? true) {
        // Past `moveOldPrepared`, so the user's data has been moved aside and
        // the journal is the only record of it. It stays, and recovery owns the
        // outcome.
        rethrow;
      }

      logger.w(
        'Restore $taskId stopped before anything was replaced',
        error: error,
        stackTrace: stackTrace,
      );
      await _abandonBeforeInstall(taskId, targetProfileId, staging, old);

      // `classifyMaintenanceFailure` keeps a `RestoreValidationFailure`'s own
      // sentence — it is written for this exact situation, and a generic
      // describer would replace it with a `toString()`.
      // The validation case is built here rather than in the classifier: its
      // sentence is written where the check is, because only that code knows
      // what it was looking for. The classifier handles errors this operation
      // did not raise itself.
      throw MaintenanceAborted(
        error is RestoreValidationFailure
            ? ArchiveRejected(error.reason)
            : classifyMaintenanceFailure(error),
        cause: error,
      );
    }
  }

  /// Releases a restore that failed before the profile was touched.
  ///
  /// The same close [recover] takes for a non-destructive phase, and for the
  /// same reason: a restore's `prepare` captured undo data and nothing was ever
  /// applied over it, so finalizing it is correct rather than merely tidy.
  ///
  /// The journal goes too. It exists to hold the process in maintenance until an
  /// interrupted mutation is reconciled, and there was no mutation — leaving it
  /// would reserve maintenance forever over a wrong password.
  Future<void> _abandonBeforeInstall(
    String taskId,
    String targetProfileId,
    Directory staging,
    Directory old,
  ) async {
    final rollbackDir = paths.restoreParticipantsDir(taskId);

    try {
      var journal = await journals.read(taskId);
      if (journal != null) {
        await _coordinator(
          () => journal!,
          (next) => journal = next,
        ).finalizeAll(_context(taskId, targetProfileId, staging, rollbackDir));
      }
    } catch (error, stackTrace) {
      // Best-effort: an undo file that outlives its operation is inert, while
      // failing here would put the task back into recovery for the one reason
      // this whole path exists to rule out.
      logger.w(
        'Could not release restore participants for $taskId',
        error: error,
        stackTrace: stackTrace,
      );
    }

    await _discardWorkspace(staging, old);
    await _discardParticipantWork(rollbackDir);
    await journals.delete(taskId);
  }

  /// Reconciles an interrupted restore, per the §11.5 recovery table.
  ///
  /// It reads the directories, not the phase. `moveOldPrepared` with the target
  /// still present and no `old` means the move never happened; the same phase with
  /// `old` present and no target means it did and the record simply did not reach
  /// disk. Both are recoverable, as is finding both — validating the target is
  /// what tells the two data sets apart. What is not recoverable is finding
  /// neither, and that is held rather than guessed at.
  Future<RestoreRecovery> recover(MaintenanceJournal start) async {
    // Reassigned as the coordinator publishes participant records, so the journal
    // left on disk by an unrecoverable outcome names who did what.
    var journal = start;

    final phase = journal.restorePhase;
    if (phase == null) {
      throw const RestoreUnrecoverable('Unrecognised restore journal');
    }

    final target = targetDir(journal.targetProfileId);
    final staging = Directory(
      journal.stagingPath ?? paths.restoreStagingDir(journal.taskId).path,
    );
    final old = Directory(
      journal.oldPath ?? paths.restoreOldDir(journal.taskId).path,
    );
    final rollbackDir = paths.restoreParticipantsDir(journal.taskId);

    await lease.assertHeld('restore.recover:${journal.taskId}');

    final coordinator = _coordinator(() => journal, (next) => journal = next);

    // The staged tree may or may not have been installed yet, so the archive root
    // is decided per branch below; the rollback root never moves.
    MaintenanceParticipantContext contextIn(Directory tree) =>
        _context(journal.taskId, journal.targetProfileId, tree, rollbackDir);

    Future<RestoreRecovery> finish(RestoreRecoveryResult result) async {
      await _discardWorkspace(staging, old);
      await _discardParticipantWork(rollbackDir);
      // Whichever tree recovery settled on is the live profile now, and the
      // archive's participant payload travelled inside it.
      await _discardStagedParticipantWork(target);
      await journals.delete(journal.taskId);
      return RestoreRecovery(
        journal.copyWith(phaseId: RestorePhase.completed.name),
        result,
      );
    }

    // Before anything was moved, the profile is untouched and the whole attempt
    // can simply be dropped. Participants may have prepared, which by definition
    // changed no live ownership — but a restore's prepare captured undo data, and
    // nothing has been applied over it, so releasing it is the correct close.
    if (!phase.isDestructive) {
      await coordinator.finalizeAll(contextIn(staging));
      return finish(RestoreRecoveryResult.rolledBack);
    }

    // Past the commit barrier the target is the restored data; only cleanup is
    // left, and it is idempotent.
    if (phase.isPastCommitBarrier) {
      if (!target.existsSync()) {
        throw const RestoreUnrecoverable(
          'Restore was verified but the target profile is gone',
        );
      }
      await coordinator.finalizeAll(contextIn(target));
      return finish(RestoreRecoveryResult.restored);
    }

    final hasTarget = target.existsSync();
    final hasStaging = staging.existsSync();
    final hasOld = old.existsSync();

    if (hasTarget && hasOld) {
      // The install completed but the barrier was never written. The target is
      // either the new data or the old data; validating it is the only way to
      // tell, and it is also the only thing that matters.
      final kept = await _validateOrRollback(target, old, journal);
      await _reconcileParticipants(coordinator, contextIn(target), kept: kept);
      return finish(
        kept
            ? RestoreRecoveryResult.restored
            : RestoreRecoveryResult.rolledBack,
      );
    }

    if (!hasTarget && hasStaging) {
      // Old was moved and staging never installed. Install it if it validates,
      // otherwise put the user's own data back.
      var kept = true;
      try {
        await validateStaging(staging, journal.targetProfileId);
        await staging.rename(target.path);
      } on RestoreValidationFailure catch (error) {
        logger.w('Rolling back restore: $error');
        await _rollback(old, target);
        kept = false;
      }

      await _reconcileParticipants(coordinator, contextIn(target), kept: kept);
      return finish(
        kept
            ? RestoreRecoveryResult.restored
            : RestoreRecoveryResult.rolledBack,
      );
    }

    if (!hasTarget && hasOld) {
      // Nothing to install. The user's data still exists and goes back, so any
      // participant that did apply has to come back with it.
      await _rollback(old, target);
      await _reconcileParticipants(coordinator, contextIn(target), kept: false);
      return finish(RestoreRecoveryResult.rolledBack);
    }

    if (hasTarget && !hasOld) {
      // The move never happened, or cleanup already ran. Either way the target
      // stands on its own; finalizing is idempotent and covers both readings.
      //
      // Staging surviving alongside it is the ordinary `moveOldPrepared` crash
      // window — the write-ahead phase reached disk and the rename did not — and
      // it changes nothing: no live state was touched, so the staged tree is
      // simply dropped with the rest of the workspace.
      await coordinator.finalizeAll(contextIn(target));
      return finish(RestoreRecoveryResult.indeterminate);
    }

    throw RestoreUnrecoverable(
      'Cannot reconcile restore ${journal.taskId} '
      '(target=$hasTarget, staging=$hasStaging, old=$hasOld)',
    );
  }

  /// Brings participant state into line with whichever tree recovery kept.
  ///
  /// The directory decision is made first and this follows it, never the other
  /// way round: the profile tree is the thing the user can see, and native state
  /// that disagrees with it is the failure mode this whole protocol exists to
  /// prevent.
  Future<void> _reconcileParticipants(
    ParticipantCoordinator coordinator,
    MaintenanceParticipantContext context, {
    required bool kept,
  }) async {
    if (!kept) {
      final records = await coordinator.rollbackAll(context);
      final failed = records
          .where((record) => record.state != ParticipantState.rolledBack)
          .map((record) => record.id)
          .toList();

      if (failed.isNotEmpty) {
        // Neither finalized nor finished: the rollback data is the only way a
        // later attempt can undo what stayed applied, and deleting the journal
        // here would report a restore that put the old profile back while native
        // state still belongs to the archive.
        throw RestoreUnrecoverable(
          'Participants could not be rolled back: ${failed.join(', ')}',
        );
      }

      await coordinator.finalizeAll(context);
      return;
    }

    try {
      // Idempotent by contract, which is what makes replaying it safe: recovery
      // cannot know whether the original process got this far.
      await coordinator.applyAll(context, rollbackOnFailure: false);
    } on MaintenanceParticipantFailure catch (error) {
      // The directory is right and the native state is not. Staying in recovery
      // is the honest outcome — booting here would hand the user a profile whose
      // preferences and shortcuts belong to the data that was replaced.
      throw RestoreUnrecoverable('$error');
    }

    await coordinator.finalizeAll(context);
  }

  /// Everything §11.5 requires before the old profile may be moved aside.
  ///
  /// Identity is checked here too, so this is the *post-bind* validation: the
  /// invariant it enforces is that a tree claims the directory it lives in, and
  /// nothing may be installed or kept that does not. Used at `verified` and
  /// throughout recovery.
  Future<void> validateStaging(
    Directory staging,
    String targetProfileId,
  ) async {
    final embedded = await validateStagedStructure(staging);

    if (embedded.uuid != targetProfileId.toLowerCase()) {
      // Reaching this after `bindStagingToTarget` means the tree on disk is not
      // the one this operation prepared. Installing it would leave a
      // `metadata.json` claiming an id the directory name denies — exactly the
      // `metadataUuidMismatch` state discovery refuses to list or repair, so the
      // profile would stop existing for the picker with all of its data intact
      // on disk.
      throw RestoreValidationFailure(
        'The staged data is addressed to ${embedded.uuid}, not $targetProfileId',
      );
    }
  }

  /// The archive's shape, without any claim about whose it is.
  ///
  /// Split from [validateStaging] because the two questions are answered at
  /// different moments: an archive is either well-formed or it is not, whereas
  /// which profile it belongs to is decided by [bindStagingToTarget] a step
  /// later. Returns the id the archive arrived with.
  Future<UuidValue> validateStagedStructure(Directory staging) async {
    if (!staging.existsSync()) {
      throw const RestoreValidationFailure('The backup file is incomplete.');
    }

    final metadataFile = File(p.join(staging.path, fs.profileMetadataFileName));
    if (!metadataFile.existsSync()) {
      throw const RestoreValidationFailure(
        'The backup file has no profile metadata.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(await metadataFile.readAsString());
    } catch (error) {
      throw RestoreValidationFailure('Staged metadata is unreadable: $error');
    }

    if (decoded is! Map<String, Object?>) {
      throw const RestoreValidationFailure('Staged metadata is not an object');
    }

    final rawId = decoded['id'];
    if (rawId is! String) {
      throw const RestoreValidationFailure('Staged metadata has no profile id');
    }

    final UuidValue embedded;
    try {
      embedded = UuidValue.withValidation(rawId.toLowerCase());
    } on FormatException catch (error) {
      throw RestoreValidationFailure(
        'Staged metadata has no usable id: $error',
      );
    }

    if (!Directory(p.join(staging.path, 'databases')).existsSync()) {
      throw const RestoreValidationFailure(
        'The backup file has no profile data.',
      );
    }

    return embedded;
  }

  /// Addresses the staged tree to [targetProfileId] before it is installed.
  ///
  /// The profile uuid is an *external* key: it names the directory, the
  /// preference prefix, the secure-key suffix, the external storage folder and
  /// the PWA token segment. Nothing inside `databases/` needs it, because those
  /// files are already per-profile. So a tree can be re-addressed, which is what
  /// `restoreAndCreateNew` has always done when it installs an archive under a
  /// fresh uuid — this is the same operation, applied to an existing profile
  /// instead of a new one.
  ///
  /// It happens **in staging, before `moveOldPrepared`**, and that placement is
  /// what makes it free of new failure modes: the whole rest of the protocol,
  /// including every recovery branch, then sees a tree that already claims the
  /// directory it is going into, and a crash here lands in the region that
  /// aborts and drops staging.
  ///
  /// Identity is taken from the target, content from the archive. The user asked
  /// to replace a profile's *data*; silently changing what that profile is
  /// called, or removing the lock on it because a backup said so, is not part of
  /// the request — [adoptArchiveName] is the one exception, and only because the
  /// first-run flow that sets it is restoring *into* a placeholder rather than
  /// over something the user named. The lock has no such exception.
  Future<void> bindStagingToTarget(
    Directory staging,
    String targetProfileId,
  ) async {
    final target = targetDir(targetProfileId);

    Profile? existing;
    try {
      existing = await fs.readProfileMetadata(target);
    } catch (error) {
      // A target whose own metadata is unreadable still has a directory name,
      // and that is the authoritative id. Its name and lock are simply not
      // recoverable, so the archive's name stands in.
      logger.w('Target profile metadata is unreadable: $error');
    }

    final archived = await fs.readProfileMetadata(staging);

    // Both orders fall back to the other side, so an archive with no readable
    // name still lands on the target's, and vice versa.
    final name = adoptArchiveName
        ? archived?.name ?? existing?.name
        : existing?.name ?? archived?.name;

    await fs.writeProfileMetadata(
      staging,
      Profile(
        id: UuidValue.withValidation(targetProfileId.toLowerCase()).uuid,
        name: name ?? 'Restored profile',
        authSettings: existing?.authSettings,
      ),
    );
  }

  MaintenanceParticipantContext _context(
    String taskId,
    String profileId,
    Directory tree,
    Directory rollbackDir,
  ) => MaintenanceParticipantContext(
    taskId: taskId,
    profileId: profileId,
    kind: MaintenanceOperationKind.restore,
    stagedDir: _stagedDirIn(tree),
    rollbackDir: rollbackDir,
    profileDir: tree,
  );

  Directory _stagedDirIn(Directory tree) =>
      Directory(p.join(tree.path, participantStagingDirName));

  /// [update] is not optional bookkeeping: the records this writes have to reach
  /// the caller's journal variable, or the next phase write reverts them.
  ParticipantCoordinator _coordinator(
    MaintenanceJournal Function() current,
    void Function(MaintenanceJournal journal) update,
  ) => ParticipantCoordinator(
    lease: lease,
    participants: participants,
    onRecords: (records) async {
      update(
        await journals.write(
          current().copyWith(participants: records, updatedAt: now()),
        ),
      );
    },
  );

  /// Returns whether the installed target was kept, or the old profile put back.
  Future<bool> _validateOrRollback(
    Directory target,
    Directory old,
    MaintenanceJournal journal,
  ) async {
    try {
      await validateStaging(target, journal.targetProfileId);
      return true;
    } on RestoreValidationFailure catch (error) {
      logger.w('Installed target failed verification: $error');
      await _rollback(old, target);
      return false;
    }
  }

  Future<void> _rollback(Directory old, Directory target) async {
    if (!old.existsSync()) {
      throw const RestoreUnrecoverable(
        'Rollback impossible: the original profile is gone',
      );
    }

    if (target.existsSync()) {
      await target.delete(recursive: true);
    }
    await old.rename(target.path);
  }

  /// Releases participant rollback data once nothing can need it again.
  ///
  /// Only ever after the operation has reached a terminal state: it is the sole
  /// record of what the live state looked like before the restore, so clearing it
  /// early would turn a recoverable failure into an unrecoverable one.
  Future<void> _discardParticipantWork(Directory rollbackDir) =>
      shredDirectory(rollbackDir, 'participant rollback data');

  /// Removes the archive's participant payload from the installed profile.
  ///
  /// It travelled *inside* the archive tree, which is the only way state living
  /// outside the profile directory can reach a restore at all — but that means the
  /// install rename put it inside the live profile, and the coordinator's finalize
  /// only releases rollback data. Left there it is a permanent plaintext copy of
  /// what the participants carried (the secure-storage snapshot holds the account
  /// session, the sync key and proxy credentials), and it would be picked up again
  /// by every later backup of this profile.
  ///
  /// Only ever called from a terminal step: until the operation is finished,
  /// recovery may still need to replay `applyAll` out of it.
  Future<void> _discardStagedParticipantWork(Directory tree) =>
      shredDirectory(_stagedDirIn(tree), 'staged participant data');

  Future<void> _discardWorkspace(Directory staging, Directory old) async {
    for (final directory in [staging, old]) {
      // Shredded rather than merely deleted: `staging` is the unpacked archive,
      // participant payload and all.
      await shredDirectory(directory, 'the restore workspace');
    }
  }
}
