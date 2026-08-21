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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/maintenance/maintenance_participant.dart';
import 'package:weblibre/core/maintenance/secure_storage_participant.dart';

/// A participant whose state lives on the Android side.
///
/// Dart owns the ordering, the journal, and the rollback discipline; native owns
/// what each participant actually touches. The split is deliberate — the
/// transaction protocol is the part that has to be right under crash and lease
/// loss, and it is far easier to prove in Dart tests than in an Android one.
///
/// Each participant gets its own directory under the task workspace, so a step
/// that stages bytes has somewhere to put them that survives a process death and
/// is cleaned up with the task.
class NativeMaintenanceParticipant implements MaintenanceParticipant {
  const NativeMaintenanceParticipant({
    required this.id,
    this.version = 1,
    GeckoProfileService? service,
  }) : _service = service;

  @override
  final String id;

  @override
  final int version;

  final GeckoProfileService? _service;

  GeckoProfileService get _api => _service ?? GeckoProfileService();

  @override
  Future<void> discover(MaintenanceParticipantContext context) =>
      _step(ParticipantStep.discover, context);

  @override
  Future<void> prepare(MaintenanceParticipantContext context) =>
      _step(ParticipantStep.prepare, context);

  @override
  Future<void> apply(MaintenanceParticipantContext context) =>
      _step(ParticipantStep.apply, context);

  @override
  Future<void> verify(MaintenanceParticipantContext context) =>
      _step(ParticipantStep.verify, context);

  @override
  Future<void> finalizeWork(MaintenanceParticipantContext context) =>
      _step(ParticipantStep.finalize, context);

  @override
  Future<void> rollback(MaintenanceParticipantContext context) =>
      _step(ParticipantStep.rollback, context);

  /// Which of the two workspaces this step belongs in.
  ///
  /// The rule is about *what the step touches*, not what it is called: a step
  /// that reads or writes archive content gets the staged tree, and everything
  /// else gets the durable one. Restore's `prepare` is the case that makes the
  /// distinction load-bearing — it captures the live state as undo data, so
  /// putting it in the staged tree would file the rollback record inside the very
  /// directory a rollback replaces.
  Directory _rootFor(
    ParticipantStep step,
    MaintenanceParticipantContext context,
  ) {
    if (context.kind == MaintenanceOperationKind.delete) {
      // Nothing is archived by a delete, so there is only ever one workspace.
      return context.rollbackDir;
    }

    return switch (step) {
      ParticipantStep.prepare =>
        context.kind == MaintenanceOperationKind.backup
            ? context.stagedDir
            : context.rollbackDir,
      ParticipantStep.discover ||
      ParticipantStep.apply ||
      ParticipantStep.verify => context.stagedDir,
      ParticipantStep.finalize ||
      ParticipantStep.rollback => context.rollbackDir,
    };
  }

  Future<void> _step(
    ParticipantStep step,
    MaintenanceParticipantContext context,
  ) async {
    final workDir = Directory(p.join(_rootFor(step, context).path, id));
    await workDir.create(recursive: true);

    final ok = await _api.runMaintenanceParticipantStep(
      participantId: id,
      step: step,
      taskId: context.taskId,
      profileId: context.profileId,
      journalKind: context.kind.name,
      workDirPath: workDir.path,
    );

    // A refusal is a failure of the participant, not of the channel: native
    // returns false when it cannot do the step safely, and the coordinator turns
    // that into a rollback rather than a retry.
    if (!ok) {
      throw StateError('Participant $id refused ${step.name}');
    }
  }
}

/// Builds the participant list this build can run.
///
/// Asking native rather than hard-coding it keeps the two halves from drifting:
/// a build whose native side registers nothing runs a directory-scoped operation
/// and says so, instead of failing on a participant that does not exist.
///
/// The Dart-side participants are appended afterwards, so they run **last** on
/// the way in and are rolled back **first** on the way out. That ordering is
/// deliberate: credentials are the state whose loss is least recoverable, so they
/// are the last thing touched and the first thing put back.
Future<List<MaintenanceParticipant>> resolveNativeParticipants({
  GeckoProfileService? service,
}) async {
  final api = service ?? GeckoProfileService();

  List<String> ids;
  try {
    ids = await api.listMaintenanceParticipants();
  } catch (_) {
    // A native side that cannot answer does not disable the Dart participants:
    // secure storage is reachable from here regardless of what Kotlin registers.
    ids = const [];
  }

  return [
    for (final id in ids)
      NativeMaintenanceParticipant(id: id, service: service),
    ...dartMaintenanceParticipants(),
  ];
}

/// The participants that must run in Dart because their storage lives behind a
/// Flutter plugin rather than in Android state Kotlin can reach.
List<MaintenanceParticipant> dartMaintenanceParticipants() => [
  SecureStorageParticipant(),
];
