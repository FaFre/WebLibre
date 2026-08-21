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

import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/maintenance/maintenance_lease.dart';
import 'package:weblibre/core/startup/models/maintenance_journal.dart';

/// Which operation a participant is taking part in.
///
/// Deliberately not [MaintenanceJournalKind]: a backup has no journal, because
/// it mutates nothing and has nothing to recover. Reusing the journal enum here
/// left backup indistinguishable from restore, and a participant that cannot
/// tell them apart captures nothing on the way out and finds nothing on the way
/// back in.
enum MaintenanceOperationKind { backup, restore, delete }

/// One category of profile-owned state that lives outside the profile directory.
///
/// Preferences, shortcuts, push registrations, scheduled jobs and credentials all
/// belong to a profile without being inside it, so a directory-scoped operation
/// cannot see them. Each becomes a participant.
///
/// The protocol is `discover → prepare → apply → verify → finalize`, with
/// `rollback` reachable only before the commit barrier. [prepare] must stage new
/// state and snapshot whatever a rollback would need **without** changing live
/// ownership — that separation is what makes the barrier meaningful.
///
/// Every method must be idempotent. Recovery cannot know which of them already
/// ran, because the record of a step can fail to reach disk after the step
/// itself succeeded.
abstract class MaintenanceParticipant {
  /// Stable across builds: it keys the journal record.
  String get id;

  /// Bumped when this participant's staged representation changes shape.
  int get version;

  /// Reports what this participant owns, before anything is staged.
  Future<void> discover(MaintenanceParticipantContext context);

  Future<void> prepare(MaintenanceParticipantContext context);

  Future<void> apply(MaintenanceParticipantContext context);

  /// Throws if the applied state is not what it should be.
  Future<void> verify(MaintenanceParticipantContext context);

  /// Releases rollback data. Never fails the operation.
  Future<void> finalizeWork(MaintenanceParticipantContext context);

  /// Undoes [apply]. Only ever called before the commit barrier.
  Future<void> rollback(MaintenanceParticipantContext context);
}

/// What a participant is being asked to act on.
///
/// Two workspaces, not one, because the two kinds of staged state have opposite
/// lifetimes. Snapshot content has to travel *with* the profile tree; rollback
/// content has to survive that tree being replaced or moved away. A single
/// directory can only satisfy one of those, and picking either one silently
/// breaks the other half of the protocol.
class MaintenanceParticipantContext {
  const MaintenanceParticipantContext({
    required this.taskId,
    required this.profileId,
    required this.kind,
    required this.stagedDir,
    required this.rollbackDir,
    this.profileDir,
  });

  final String taskId;
  final String profileId;
  final MaintenanceOperationKind kind;

  /// The profile tree this operation is acting on, when there is one.
  ///
  /// Needed by participants whose ownership evidence lives *inside* the profile
  /// rather than in the key they are enumerating — `SecureStorageParticipant`
  /// reads `databases/user.db` to find which proxy credentials belong here,
  /// because a record written before the profile key scheme carries no owner of
  /// its own. This is the one process entitled to read it: nothing else has the
  /// profile open.
  ///
  /// Null where the tree is gone or not yet known, which participants must treat
  /// as "could not look", never as "there was nothing".
  final Directory? profileDir;

  /// Archive content: **inside the profile tree being backed up or installed**.
  ///
  /// What `prepare` writes here during a backup is what `apply` reads during the
  /// restore of that archive. A workspace outside the tree would be captured by
  /// nothing and found by nobody.
  ///
  /// It moves when the tree moves, so a restore rebuilds the context after the
  /// staged tree is renamed into place rather than reusing the pre-install one.
  final Directory stagedDir;

  /// Undo content: **outside every directory the operation renames or deletes**.
  ///
  /// A restore's `prepare` snapshots the live state here precisely so that
  /// putting the old profile tree back does not also destroy the record of what
  /// the live state used to be.
  final Directory rollbackDir;

  MaintenanceParticipantContext withStagedDir(Directory dir) =>
      MaintenanceParticipantContext(
        taskId: taskId,
        profileId: profileId,
        kind: kind,
        stagedDir: dir,
        rollbackDir: rollbackDir,
        profileDir: profileDir,
      );

  MaintenanceParticipantContext withProfileDir(Directory dir) =>
      MaintenanceParticipantContext(
        taskId: taskId,
        profileId: profileId,
        kind: kind,
        stagedDir: stagedDir,
        rollbackDir: rollbackDir,
        profileDir: dir,
      );
}

/// A participant refused, and the operation must not cross the barrier.
class MaintenanceParticipantFailure implements Exception {
  const MaintenanceParticipantFailure(this.participantId, this.cause);

  final String participantId;
  final Object cause;

  @override
  String toString() => 'MaintenanceParticipantFailure($participantId: $cause)';
}

/// Drives participants through the protocol and records each one in the journal.
///
/// The rollback ordering is the part that matters: applied participants are undone
/// in reverse, because a later one may depend on state an earlier one moved. A
/// forward-order rollback would undo the foundation before the thing standing on
/// it.
class ParticipantCoordinator {
  const ParticipantCoordinator({
    required this.lease,
    required this.participants,
    this.onRecords,
  });

  final MaintenanceLease lease;
  final List<MaintenanceParticipant> participants;

  /// Persists the records; the caller owns the journal.
  final Future<void> Function(List<ParticipantRecord> records)? onRecords;

  /// Runs `discover` and `prepare` for every participant.
  ///
  /// Nothing here changes live ownership, so a failure needs no rollback — the
  /// staged work is simply abandoned.
  Future<List<ParticipantRecord>> prepareAll(
    MaintenanceParticipantContext context,
  ) async {
    final records = <ParticipantRecord>[];

    for (final participant in participants) {
      await lease.assertHeld('participants.prepare:${participant.id}');

      try {
        await participant.discover(context);
        await participant.prepare(context);
      } catch (error) {
        await _publish([
          ...records,
          _record(participant, ParticipantState.pending, '$error'),
        ]);
        throw MaintenanceParticipantFailure(participant.id, error);
      }

      records.add(_record(participant, ParticipantState.prepared));
      await _publish(records);
    }

    return records;
  }

  /// Applies and verifies every participant, rolling back on failure.
  ///
  /// Rollback runs in reverse over the participants that applied *and* the one
  /// that threw. A participant that was never reached is not rolled back —
  /// undoing work that never happened is how idempotency claims stop being true —
  /// but the failing one has to be, because `apply` is not atomic: it may have
  /// deleted the live records before failing to write the new ones.
  Future<List<ParticipantRecord>> applyAll(
    MaintenanceParticipantContext context, {
    required bool rollbackOnFailure,
  }) async {
    final records = <ParticipantRecord>[];
    final applied = <MaintenanceParticipant>[];

    for (final participant in participants) {
      await lease.assertHeld('participants.apply:${participant.id}');

      try {
        await participant.apply(context);
        applied.add(participant);
        records.add(_record(participant, ParticipantState.applied));
        await _publish(records);

        await participant.verify(context);
        records[records.length - 1] = _record(
          participant,
          ParticipantState.verified,
        );
        await _publish(records);
      } catch (error) {
        records.add(_record(participant, ParticipantState.applied, '$error'));

        if (rollbackOnFailure) {
          // `contains` rather than an unconditional add: reaching here from a
          // failed `verify` means apply already succeeded and the participant is
          // in the list, and rolling it back twice would double its record.
          await _rollback(
            context,
            applied.contains(participant) ? applied : [...applied, participant],
            records,
          );
        }

        await _publish(records);
        throw MaintenanceParticipantFailure(participant.id, error);
      }
    }

    return records;
  }

  /// Releases rollback data once the barrier is durable.
  ///
  /// Failures are logged, never propagated: after the barrier the operation has
  /// already succeeded, and refusing to finish cleanup would turn a completed
  /// restore into a permanent maintenance reservation.
  Future<List<ParticipantRecord>> finalizeAll(
    MaintenanceParticipantContext context,
  ) async {
    final records = <ParticipantRecord>[];

    for (final participant in participants) {
      try {
        await participant.finalizeWork(context);
        records.add(_record(participant, ParticipantState.finalized));
      } catch (error, stackTrace) {
        logger.w(
          'Participant ${participant.id} could not finalize',
          error: error,
          stackTrace: stackTrace,
        );
        records.add(_record(participant, ParticipantState.verified, '$error'));
      }
    }

    await _publish(records);
    return records;
  }

  /// Undoes every participant, for a recovery that has decided to put the old
  /// profile back.
  ///
  /// Unlike the in-run path this cannot know which participants applied — the
  /// process that would have known is gone. It rolls back all of them in reverse
  /// and tolerates the ones with nothing to undo, because a participant whose
  /// rollback data is absent either never applied or already finalized, and
  /// neither is a reason to leave the profile half-restored.
  Future<List<ParticipantRecord>> rollbackAll(
    MaintenanceParticipantContext context,
  ) async {
    final records = <ParticipantRecord>[];
    await _rollback(context, participants, records);
    await _publish(records);
    return records;
  }

  Future<void> _rollback(
    MaintenanceParticipantContext context,
    List<MaintenanceParticipant> applied,
    List<ParticipantRecord> records,
  ) async {
    for (final participant in applied.reversed) {
      try {
        await participant.rollback(context);
        records.add(_record(participant, ParticipantState.rolledBack));
      } catch (error, stackTrace) {
        // A failed rollback is not recoverable by retrying here. It is recorded
        // so the operation stays in recovery rather than reporting success.
        logger.e(
          'Participant ${participant.id} could not roll back',
          error: error,
          stackTrace: stackTrace,
        );
        records.add(
          _record(participant, ParticipantState.applied, 'rollback: $error'),
        );
      }
    }
  }

  ParticipantRecord _record(
    MaintenanceParticipant participant,
    ParticipantState state, [
    String? error,
  ]) => ParticipantRecord(
    id: participant.id,
    version: participant.version,
    stateId: state.name,
    error: error,
  );

  Future<void> _publish(List<ParticipantRecord> records) async {
    final publish = onRecords;
    if (publish == null) return;

    await publish([...records]);
  }
}
