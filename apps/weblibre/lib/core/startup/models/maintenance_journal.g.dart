// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_journal.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ParticipantRecordCWProxy {
  ParticipantRecord version(int version);

  ParticipantRecord stateId(String stateId);

  ParticipantRecord error(String? error);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ParticipantRecord(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ParticipantRecord(...).copyWith(id: 12, name: "My name")
  /// ```
  ParticipantRecord call({int version, String stateId, String? error});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfParticipantRecord.copyWith(...)` or call `instanceOfParticipantRecord.copyWith.fieldName(value)` for a single field.
class _$ParticipantRecordCWProxyImpl implements _$ParticipantRecordCWProxy {
  const _$ParticipantRecordCWProxyImpl(this._value);

  final ParticipantRecord _value;

  @override
  ParticipantRecord version(int version) => call(version: version);

  @override
  ParticipantRecord stateId(String stateId) => call(stateId: stateId);

  @override
  ParticipantRecord error(String? error) => call(error: error);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ParticipantRecord(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ParticipantRecord(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  ParticipantRecord call({
    Object? version = const $CopyWithPlaceholder(),
    Object? stateId = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
  }) {
    return ParticipantRecord(
      id: _value.id,
      version: version == const $CopyWithPlaceholder() || version == null
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      stateId: stateId == const $CopyWithPlaceholder() || stateId == null
          ? _value.stateId
          // ignore: cast_nullable_to_non_nullable
          : stateId as String,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
    );
  }
}

extension $ParticipantRecordCopyWith on ParticipantRecord {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfParticipantRecord.copyWith(...)` or `instanceOfParticipantRecord.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ParticipantRecordCWProxy get copyWith =>
      _$ParticipantRecordCWProxyImpl(this);
}

abstract class _$MaintenanceJournalCWProxy {
  MaintenanceJournal kindId(String kindId);

  MaintenanceJournal phaseId(String phaseId);

  MaintenanceJournal targetProfileId(String targetProfileId);

  MaintenanceJournal updatedAt(DateTime updatedAt);

  MaintenanceJournal version(int version);

  MaintenanceJournal archiveDigest(String? archiveDigest);

  MaintenanceJournal stagingPath(String? stagingPath);

  MaintenanceJournal oldPath(String? oldPath);

  MaintenanceJournal participants(List<ParticipantRecord> participants);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `MaintenanceJournal(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// MaintenanceJournal(...).copyWith(id: 12, name: "My name")
  /// ```
  MaintenanceJournal call({
    String kindId,
    String phaseId,
    String targetProfileId,
    DateTime updatedAt,
    int version,
    String? archiveDigest,
    String? stagingPath,
    String? oldPath,
    List<ParticipantRecord> participants,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfMaintenanceJournal.copyWith(...)` or call `instanceOfMaintenanceJournal.copyWith.fieldName(value)` for a single field.
class _$MaintenanceJournalCWProxyImpl implements _$MaintenanceJournalCWProxy {
  const _$MaintenanceJournalCWProxyImpl(this._value);

  final MaintenanceJournal _value;

  @override
  MaintenanceJournal kindId(String kindId) => call(kindId: kindId);

  @override
  MaintenanceJournal phaseId(String phaseId) => call(phaseId: phaseId);

  @override
  MaintenanceJournal targetProfileId(String targetProfileId) =>
      call(targetProfileId: targetProfileId);

  @override
  MaintenanceJournal updatedAt(DateTime updatedAt) =>
      call(updatedAt: updatedAt);

  @override
  MaintenanceJournal version(int version) => call(version: version);

  @override
  MaintenanceJournal archiveDigest(String? archiveDigest) =>
      call(archiveDigest: archiveDigest);

  @override
  MaintenanceJournal stagingPath(String? stagingPath) =>
      call(stagingPath: stagingPath);

  @override
  MaintenanceJournal oldPath(String? oldPath) => call(oldPath: oldPath);

  @override
  MaintenanceJournal participants(List<ParticipantRecord> participants) =>
      call(participants: participants);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `MaintenanceJournal(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// MaintenanceJournal(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  MaintenanceJournal call({
    Object? kindId = const $CopyWithPlaceholder(),
    Object? phaseId = const $CopyWithPlaceholder(),
    Object? targetProfileId = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? archiveDigest = const $CopyWithPlaceholder(),
    Object? stagingPath = const $CopyWithPlaceholder(),
    Object? oldPath = const $CopyWithPlaceholder(),
    Object? participants = const $CopyWithPlaceholder(),
  }) {
    return MaintenanceJournal(
      taskId: _value.taskId,
      kindId: kindId == const $CopyWithPlaceholder() || kindId == null
          ? _value.kindId
          // ignore: cast_nullable_to_non_nullable
          : kindId as String,
      phaseId: phaseId == const $CopyWithPlaceholder() || phaseId == null
          ? _value.phaseId
          // ignore: cast_nullable_to_non_nullable
          : phaseId as String,
      targetProfileId:
          targetProfileId == const $CopyWithPlaceholder() ||
              targetProfileId == null
          ? _value.targetProfileId
          // ignore: cast_nullable_to_non_nullable
          : targetProfileId as String,
      updatedAt: updatedAt == const $CopyWithPlaceholder() || updatedAt == null
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
      version: version == const $CopyWithPlaceholder() || version == null
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      archiveDigest: archiveDigest == const $CopyWithPlaceholder()
          ? _value.archiveDigest
          // ignore: cast_nullable_to_non_nullable
          : archiveDigest as String?,
      stagingPath: stagingPath == const $CopyWithPlaceholder()
          ? _value.stagingPath
          // ignore: cast_nullable_to_non_nullable
          : stagingPath as String?,
      oldPath: oldPath == const $CopyWithPlaceholder()
          ? _value.oldPath
          // ignore: cast_nullable_to_non_nullable
          : oldPath as String?,
      participants:
          participants == const $CopyWithPlaceholder() || participants == null
          ? _value.participants
          // ignore: cast_nullable_to_non_nullable
          : participants as List<ParticipantRecord>,
    );
  }
}

extension $MaintenanceJournalCopyWith on MaintenanceJournal {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfMaintenanceJournal.copyWith(...)` or `instanceOfMaintenanceJournal.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MaintenanceJournalCWProxy get copyWith =>
      _$MaintenanceJournalCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParticipantRecord _$ParticipantRecordFromJson(Map<String, dynamic> json) =>
    ParticipantRecord(
      id: json['id'] as String,
      version: _recordVersionFromJson(json['version']),
      stateId: _stateIdFromJson(json['state']),
      error: stringOrNull(json['error']),
    );

Map<String, dynamic> _$ParticipantRecordToJson(ParticipantRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'version': instance.version,
      'state': instance.stateId,
      'error': instance.error,
    };

MaintenanceJournal _$MaintenanceJournalFromJson(Map<String, dynamic> json) =>
    MaintenanceJournal(
      taskId: json['taskId'] as String,
      kindId: stringOrEmpty(json['kind']),
      phaseId: stringOrEmpty(json['phase']),
      targetProfileId: json['targetProfileId'] as String,
      updatedAt: _updatedAtFromJson(json['updatedAt']),
      version: json['version'] == null
          ? maintenanceJournalVersion
          : _journalVersionFromJson(json['version']),
      archiveDigest: stringOrNull(json['archiveDigest']),
      stagingPath: stringOrNull(json['stagingPath']),
      oldPath: stringOrNull(json['oldPath']),
      participants: json['participants'] == null
          ? const []
          : _participantsFromJson(json['participants']),
    );

Map<String, dynamic> _$MaintenanceJournalToJson(MaintenanceJournal instance) =>
    <String, dynamic>{
      'version': instance.version,
      'taskId': instance.taskId,
      'kind': instance.kindId,
      'phase': instance.phaseId,
      'targetProfileId': instance.targetProfileId,
      'archiveDigest': instance.archiveDigest,
      'stagingPath': instance.stagingPath,
      'oldPath': instance.oldPath,
      'participants': instance.participants.map((e) => e.toJson()).toList(),
      'updatedAt': _updatedAtToJson(instance.updatedAt),
    };
