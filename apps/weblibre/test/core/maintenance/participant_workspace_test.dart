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

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/maintenance/maintenance_participant.dart';
import 'package:weblibre/core/maintenance/native_participant.dart';

/// Records which directory each step was handed.
class _RoutingApi implements GeckoProfileApi {
  final steps = <ParticipantStep, String>{};

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';

  @override
  Future<bool> runMaintenanceParticipantStep(
    String participantId,
    ParticipantStep step,
    String taskId,
    String profileId,
    String journalKind,
    String workDirPath,
  ) async {
    steps[step] = workDirPath;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late Directory root;
  late Directory staged;
  late Directory rollback;

  setUp(() {
    root = Directory.systemTemp.createTempSync('weblibre_routing');
    staged = Directory(p.join(root.path, 'staged'))..createSync();
    rollback = Directory(p.join(root.path, 'rollback'))..createSync();
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  MaintenanceParticipantContext contextFor(MaintenanceOperationKind kind) =>
      MaintenanceParticipantContext(
        taskId: 'task-1',
        profileId: '0199a0b1-1111-7111-8111-111111111111',
        kind: kind,
        stagedDir: staged,
        rollbackDir: rollback,
      );

  Future<_RoutingApi> runEveryStep(MaintenanceOperationKind kind) async {
    final api = _RoutingApi();
    final participant = NativeMaintenanceParticipant(
      id: 'prefs',
      service: GeckoProfileService(api: api),
    );
    final context = contextFor(kind);

    await participant.discover(context);
    await participant.prepare(context);
    await participant.apply(context);
    await participant.verify(context);
    await participant.rollback(context);
    await participant.finalizeWork(context);

    return api;
  }

  bool under(Directory parent, String? path) =>
      path != null && p.isWithin(parent.path, path);

  group('participant workspace routing', () {
    test('a restore snapshots undo data outside the tree it replaces', () async {
      final api = await runEveryStep(MaintenanceOperationKind.restore);

      // The decisive one: `prepare` captures the *live* state, which is exactly
      // what a rollback puts back. Filing it in the staged tree would place it
      // inside the directory a rollback discards.
      expect(under(rollback, api.steps[ParticipantStep.prepare]), isTrue);
      expect(under(rollback, api.steps[ParticipantStep.rollback]), isTrue);
      expect(under(rollback, api.steps[ParticipantStep.finalize]), isTrue);
    });

    test('a restore reads archived state from the tree it installs', () async {
      final api = await runEveryStep(MaintenanceOperationKind.restore);

      expect(under(staged, api.steps[ParticipantStep.apply]), isTrue);
      expect(under(staged, api.steps[ParticipantStep.verify]), isTrue);
    });

    test('a backup writes its snapshot into the archive tree', () async {
      final api = await runEveryStep(MaintenanceOperationKind.backup);

      // Otherwise the snapshot is packed by nothing and a restore of this
      // archive finds no preferences to put back.
      expect(under(staged, api.steps[ParticipantStep.prepare]), isTrue);
    });

    test('a delete has one workspace, since it archives nothing', () async {
      final api = await runEveryStep(MaintenanceOperationKind.delete);

      for (final path in api.steps.values) {
        expect(under(rollback, path), isTrue);
      }
    });

    test('each participant gets its own directory', () async {
      final api = await runEveryStep(MaintenanceOperationKind.restore);

      expect(
        p.basename(api.steps[ParticipantStep.apply]!),
        'prefs',
      );
    });
  });
}
