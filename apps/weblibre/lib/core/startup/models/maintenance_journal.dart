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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/core/startup/models/json_read.dart';

part 'maintenance_journal.g.dart';

const maintenanceJournalVersion = 1;

enum MaintenanceJournalKind { restore, delete }

/// Write-ahead phases of a restore-over.
///
/// Every `*Prepared` phase is fsynced *before* its mutation and its completion
/// phase is fsynced after, so recovery always sees either the intent or the
/// result. Recovery still inspects target/staging/old and hashes; the phase
/// alone is a hint, not proof.
enum RestorePhase {
  created,
  staged,
  validated,
  participantsPrepared,
  moveOldPrepared,
  oldMoved,
  installPrepared,
  installed,
  participantsApplying,
  participantsApplied,
  verified,
  cleanupPrepared,
  cleanupPending,
  completed;

  /// `verified` is the durable commit barrier: before it, failure rolls
  /// participants back in reverse order and restores `old`; after it, recovery
  /// only moves forward through cleanup.
  bool get isPastCommitBarrier => index >= RestorePhase.verified.index;

  /// Once `old` has been moved the target directory no longer holds the user's
  /// data, so a crash here can never be reconciled by simply dropping staging.
  bool get isDestructive => index >= RestorePhase.moveOldPrepared.index;
}

/// Write-ahead phases of a profile delete.
///
/// Delete is forward-only: restoring already-deleted external jobs and
/// notifications is not generally possible, so its barrier sits at
/// `ownershipSnapshotted` and every category is idempotent instead of
/// reversible.
enum DeletePhase {
  created,
  quiesced,
  ownershipSnapshotted,
  jobsPrepared,
  jobsDeleted,
  externalPrepared,
  externalDeleted,
  nativeStatePrepared,
  nativeStateDeleted,
  sharedCredentialsPrepared,
  sharedCredentialsReconciled,
  internalPrepared,
  internalDeleted,
  completed;

  bool get isPastCommitBarrier =>
      index >= DeletePhase.ownershipSnapshotted.index;
}

enum ParticipantState {
  pending,
  prepared,
  applied,
  verified,
  rolledBack,
  finalized,
}

/// Per-participant record inside a journal. [stateId] keeps the raw string so a
/// record written by a newer participant version round-trips unchanged.
@CopyWith()
@JsonSerializable()
class ParticipantRecord with FastEquatable {
  @CopyWithField(immutable: true)
  final String id;

  @JsonKey(fromJson: _recordVersionFromJson)
  final int version;

  @JsonKey(name: 'state', fromJson: _stateIdFromJson)
  final String stateId;

  @JsonKey(fromJson: stringOrNull)
  final String? error;

  ParticipantRecord({
    required this.id,
    required this.version,
    required this.stateId,
    this.error,
  });

  ParticipantState? get state => ParticipantState.values.tryByName(stateId);

  /// A record with no participant id names nothing and can never be acted on,
  /// so it is dropped rather than read as a record about "".
  static ParticipantRecord? tryFromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) return null;

    return _$ParticipantRecordFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ParticipantRecordToJson(this);

  @override
  List<Object?> get hashParameters => [id, version, stateId, error];
}

/// Durable evidence of a destructive maintenance operation, stored outside the
/// `profile-` namespace at `weblibre_maintenance/journals/<taskId>.json`.
@CopyWith()
@JsonSerializable()
class MaintenanceJournal with FastEquatable {
  @JsonKey(fromJson: _journalVersionFromJson)
  final int version;

  @CopyWithField(immutable: true)
  final String taskId;

  @JsonKey(name: 'kind', fromJson: stringOrEmpty)
  final String kindId;

  @JsonKey(name: 'phase', fromJson: stringOrEmpty)
  final String phaseId;

  final String targetProfileId;

  @JsonKey(fromJson: stringOrNull)
  final String? archiveDigest;

  @JsonKey(fromJson: stringOrNull)
  final String? stagingPath;

  @JsonKey(fromJson: stringOrNull)
  final String? oldPath;

  @JsonKey(fromJson: _participantsFromJson)
  final List<ParticipantRecord> participants;

  @JsonKey(fromJson: _updatedAtFromJson, toJson: _updatedAtToJson)
  final DateTime updatedAt;

  MaintenanceJournal({
    required this.taskId,
    required this.kindId,
    required this.phaseId,
    required this.targetProfileId,
    required this.updatedAt,
    this.version = maintenanceJournalVersion,
    this.archiveDigest,
    this.stagingPath,
    this.oldPath,
    this.participants = const [],
  });

  MaintenanceJournalKind? get kind =>
      MaintenanceJournalKind.values.tryByName(kindId);

  RestorePhase? get restorePhase => kind == MaintenanceJournalKind.restore
      ? RestorePhase.values.tryByName(phaseId)
      : null;

  DeletePhase? get deletePhase => kind == MaintenanceJournalKind.delete
      ? DeletePhase.values.tryByName(phaseId)
      : null;

  /// An unrecognised kind or phase must never be optimistically ignored: the
  /// process stays in maintenance and offers recovery instead of booting a
  /// possibly half-restored profile.
  bool get isUnrecognised =>
      kind == null || (restorePhase == null && deletePhase == null);

  bool get isComplete =>
      restorePhase == RestorePhase.completed ||
      deletePhase == DeletePhase.completed;

  bool get isPastCommitBarrier =>
      restorePhase?.isPastCommitBarrier ??
      deletePhase?.isPastCommitBarrier ??
      false;

  /// Whether this journal alone forces the next process into maintenance.
  bool get requiresRecovery => isUnrecognised || !isComplete;

  /// A journal that names no task or no target profile describes nothing that
  /// can be recovered, so it is dropped rather than read with empty ids.
  static MaintenanceJournal? tryFromJson(Map<String, dynamic> json) {
    final taskId = json['taskId'];
    if (taskId is! String || taskId.isEmpty) return null;

    final targetProfileId = json['targetProfileId'];
    if (targetProfileId is! String || targetProfileId.isEmpty) return null;

    return _$MaintenanceJournalFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MaintenanceJournalToJson(this);

  @override
  List<Object?> get hashParameters => [
    version,
    taskId,
    kindId,
    phaseId,
    targetProfileId,
    archiveDigest,
    stagingPath,
    oldPath,
    participants,
    updatedAt,
  ];
}

List<ParticipantRecord> _participantsFromJson(Object? value) {
  if (value is! List) return const [];

  final records = <ParticipantRecord>[];
  for (final entry in value) {
    if (entry is! Map) continue;
    final record = ParticipantRecord.tryFromJson(
      entry.map((key, value) => MapEntry(key.toString(), value)),
    );
    if (record != null) records.add(record);
  }

  return List.unmodifiable(records);
}

DateTime _updatedAtFromJson(Object? value) =>
    dateTimeOrNull(value) ?? DateTime.utc(1970);

String _updatedAtToJson(DateTime value) => value.toUtc().toIso8601String();

int _journalVersionFromJson(Object? value) =>
    intOr(value, maintenanceJournalVersion);

int _recordVersionFromJson(Object? value) => intOr(value, 0);

/// A record written before this field existed is `pending`: the state it was in
/// before any participant had reported.
String _stateIdFromJson(Object? value) =>
    stringOrNull(value) ?? ParticipantState.pending.name;
