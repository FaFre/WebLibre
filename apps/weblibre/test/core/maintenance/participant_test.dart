import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/maintenance/maintenance_lease.dart';
import 'package:weblibre/core/maintenance/maintenance_participant.dart';
import 'package:weblibre/core/startup/models/maintenance_journal.dart';

class _FakeProfileApi implements GeckoProfileApi {
  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';

  @override
  Future<bool> assertMaintenanceLease(
    String leaseId,
    String? taskId,
    String boundary,
  ) async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

/// Records the order of every protocol call across all participants.
class _Recorder {
  final List<String> calls = [];
}

class _FakeParticipant implements MaintenanceParticipant {
  _FakeParticipant(
    this.id,
    this.recorder, {
    this.failOnApply = false,
    this.failOnVerify = false,
    this.failOnRollback = false,
    this.failOnFinalize = false,
  });

  @override
  final String id;

  final _Recorder recorder;
  final bool failOnApply;
  final bool failOnVerify;
  final bool failOnRollback;
  final bool failOnFinalize;

  @override
  int get version => 3;

  @override
  Future<void> discover(MaintenanceParticipantContext context) async {
    recorder.calls.add('discover:$id');
  }

  @override
  Future<void> prepare(MaintenanceParticipantContext context) async {
    recorder.calls.add('prepare:$id');
  }

  @override
  Future<void> apply(MaintenanceParticipantContext context) async {
    recorder.calls.add('apply:$id');
    if (failOnApply) throw StateError('apply failed in $id');
  }

  @override
  Future<void> verify(MaintenanceParticipantContext context) async {
    recorder.calls.add('verify:$id');
    if (failOnVerify) throw StateError('verify failed in $id');
  }

  @override
  Future<void> finalizeWork(MaintenanceParticipantContext context) async {
    recorder.calls.add('finalize:$id');
    if (failOnFinalize) throw StateError('finalize failed in $id');
  }

  @override
  Future<void> rollback(MaintenanceParticipantContext context) async {
    recorder.calls.add('rollback:$id');
    if (failOnRollback) throw StateError('rollback failed in $id');
  }
}

void main() {
  late _Recorder recorder;
  late List<List<ParticipantRecord>> published;

  late MaintenanceParticipantContext context;
  late Directory root;

  setUp(() {
    recorder = _Recorder();
    published = [];
    root = Directory.systemTemp.createTempSync('weblibre_participant');
    context = MaintenanceParticipantContext(
      taskId: 'task-1',
      profileId: '0199a0b1-1111-7111-8111-111111111111',
      kind: MaintenanceOperationKind.restore,
      stagedDir: Directory(p.join(root.path, 'staged'))
        ..createSync(recursive: true),
      rollbackDir: Directory(p.join(root.path, 'rollback'))
        ..createSync(recursive: true),
    );
  });

  tearDown(() {
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
  });

  ParticipantCoordinator coordinatorFor(
    List<MaintenanceParticipant> participants,
  ) => ParticipantCoordinator(
    lease: MaintenanceLease(
      leaseId: 'lease-1',
      taskId: 'task-1',
      service: GeckoProfileService(api: _FakeProfileApi()),
    ),
    participants: participants,
    onRecords: (records) async => published.add(records),
  );

  test('prepare discovers before it stages, in order', () async {
    final records = await coordinatorFor([
      _FakeParticipant('prefs', recorder),
      _FakeParticipant('shortcuts', recorder),
    ]).prepareAll(context);

    expect(recorder.calls, [
      'discover:prefs',
      'prepare:prefs',
      'discover:shortcuts',
      'prepare:shortcuts',
    ]);
    expect(
      records.map((record) => record.state),
      everyElement(ParticipantState.prepared),
    );
    expect(records.first.version, 3);
  });

  test('a failed prepare needs no rollback because nothing went live', () async {
    await expectLater(
      coordinatorFor([
        _FakeParticipant('shortcuts', recorder),
        _FailingPrepare('prefs', recorder),
      ]).prepareAll(context),
      throwsA(isA<MaintenanceParticipantFailure>()),
    );

    // `prepare` stages without changing live ownership, so the earlier
    // participant has nothing to undo.
    expect(recorder.calls, isNot(contains('rollback:shortcuts')));
    expect(recorder.calls, contains('prepare:prefs'));
  });

  test('apply verifies each participant as it goes', () async {
    final records = await coordinatorFor([
      _FakeParticipant('prefs', recorder),
      _FakeParticipant('push', recorder),
    ]).applyAll(context, rollbackOnFailure: true);

    expect(recorder.calls, [
      'apply:prefs',
      'verify:prefs',
      'apply:push',
      'verify:push',
    ]);
    expect(
      records.map((record) => record.state),
      everyElement(ParticipantState.verified),
    );
  });

  test('a failure rolls applied participants back in reverse order', () async {
    await expectLater(
      coordinatorFor([
        _FakeParticipant('prefs', recorder),
        _FakeParticipant('push', recorder),
        _FakeParticipant('jobs', recorder, failOnApply: true),
      ]).applyAll(context, rollbackOnFailure: true),
      throwsA(isA<MaintenanceParticipantFailure>()),
    );

    // Reverse order, and the participant that threw goes first: `apply` is not
    // atomic — the secure-storage one deletes the live records before writing
    // the new ones — so a half-applied participant has undo data of its own, and
    // leaving it out is how live state stays behind after everything else is
    // back.
    expect(
      recorder.calls.where((call) => call.startsWith('rollback')),
      ['rollback:jobs', 'rollback:push', 'rollback:prefs'],
    );
  });

  test('a failed verify still rolls that participant back', () async {
    await expectLater(
      coordinatorFor([
        _FakeParticipant('prefs', recorder),
        _FakeParticipant('push', recorder, failOnVerify: true),
      ]).applyAll(context, rollbackOnFailure: true),
      throwsA(isA<MaintenanceParticipantFailure>()),
    );

    // push applied successfully before verify failed, so it is undone too.
    expect(
      recorder.calls.where((call) => call.startsWith('rollback')),
      ['rollback:push', 'rollback:prefs'],
    );
  });

  test('delete never rolls back, because it cannot', () async {
    await expectLater(
      coordinatorFor([
        _FakeParticipant('prefs', recorder),
        _FakeParticipant('jobs', recorder, failOnApply: true),
      ]).applyAll(context, rollbackOnFailure: false),
      throwsA(isA<MaintenanceParticipantFailure>()),
    );

    expect(recorder.calls.any((call) => call.startsWith('rollback')), isFalse);
  });

  test('a failed rollback is recorded rather than swallowed', () async {
    await expectLater(
      coordinatorFor([
        _FakeParticipant('prefs', recorder, failOnRollback: true),
        _FakeParticipant('jobs', recorder, failOnApply: true),
      ]).applyAll(context, rollbackOnFailure: true),
      throwsA(isA<MaintenanceParticipantFailure>()),
    );

    final last = published.last;
    expect(
      last.any(
        (record) =>
            record.id == 'prefs' && (record.error?.startsWith('rollback') ?? false),
      ),
      isTrue,
    );
  });

  test('finalize failures do not fail a committed operation', () async {
    final records = await coordinatorFor([
      _FakeParticipant('prefs', recorder, failOnFinalize: true),
      _FakeParticipant('push', recorder),
    ]).finalizeAll(context);

    expect(records.first.state, ParticipantState.verified);
    expect(records.first.error, contains('finalize failed'));
    expect(records.last.state, ParticipantState.finalized);
  });

  test('records are published as the run progresses, not only at the end', () async {
    await coordinatorFor([
      _FakeParticipant('prefs', recorder),
      _FakeParticipant('push', recorder),
    ]).applyAll(context, rollbackOnFailure: true);

    // A record that only reaches disk at the end would tell recovery nothing
    // about a run that died in the middle.
    expect(published.length, greaterThan(2));
  });
}

/// Fails during `prepare`, before anything is live.
class _FailingPrepare extends _FakeParticipant {
  _FailingPrepare(super.id, super.recorder);

  @override
  Future<void> prepare(MaintenanceParticipantContext context) {
    recorder.calls.add('prepare:$id');
    throw StateError('prepare failed in $id');
  }
}
