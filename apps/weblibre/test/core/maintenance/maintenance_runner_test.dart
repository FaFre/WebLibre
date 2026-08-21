import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/maintenance/maintenance_journal_store.dart';
import 'package:weblibre/core/maintenance/maintenance_lease.dart';
import 'package:weblibre/core/maintenance/maintenance_runner.dart';
import 'package:weblibre/core/startup/models/maintenance_journal.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/core/startup/startup_config_store.dart';
import 'package:weblibre/core/startup/startup_paths.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;

const _profileId = '0199a0b1-1111-7111-8111-111111111111';

class _FakeProfileApi implements GeckoProfileApi {
  int heartbeats = 0;

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
  Future<bool> heartbeatMaintenance(String leaseId) async {
    heartbeats++;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late Directory root;
  late StartupPaths paths;
  late StartupConfigStore store;
  late Directory workRoot;
  late List<String> published;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('weblibre_runner');
    paths = StartupPaths(Directory(p.join(root.path, 'files')));
    await paths.ensureGlobalDirectories();
    store = StartupConfigStore(paths);
    workRoot = Directory(p.join(root.path, 'work'))
      ..createSync(recursive: true);
    published = [];

    final profileDir = Directory(
      p.join(paths.profilesDir.path, '${fs.profileDirPrefix}$_profileId'),
    );
    await profileDir.create(recursive: true);
    await File(p.join(profileDir.path, 'metadata.json')).writeAsString('{}');
  });

  tearDown(() async {
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  });

  MaintenanceRunner runnerFor({
    bool packThrows = false,
    _FakeProfileApi? api,
    Duration heartbeatInterval = MaintenanceLease.defaultHeartbeatInterval,
    Future<void> Function()? whilePacking,
    ArchiveUnpacker? unpacker,
    // Off by default so the "no journal paths" refusal stays testable: a runner
    // without them is what a caller that cannot write outside the profile looks
    // like.
    bool journaled = false,
  }) => MaintenanceRunner(
    store: store,
    lease: MaintenanceLease(
      leaseId: 'lease-1',
      taskId: 'task-1',
      heartbeatInterval: heartbeatInterval,
      service: GeckoProfileService(api: api ?? _FakeProfileApi()),
    ),
    profilesDir: paths.profilesDir,
    workRoot: workRoot,
    paths: journaled ? paths : null,
    unpacker: unpacker,
    // No participants: this suite is about the runner's task bookkeeping, and
    // the real list reaches native and a Flutter plugin.
    participants: const [],
    now: () => DateTime.utc(2026, 8, 19),
    packer: (source, output, password, {required integrityCheck}) async {
      if (packThrows) throw const FileSystemException('disk gone');
      await whilePacking?.call();
      await output.writeAsString('archive');
    },
    publisher: (archive, targetTree, fileName) async {
      published.add(fileName);
    },
  );

  Future<MaintenanceTask> enqueue({
    MaintenanceAction action = MaintenanceAction.backup,
    String? targetTreeUri = 'content://tree/backups',
    String id = 'task-1',
  }) async {
    final task = MaintenanceTask.create(
      id: id,
      action: action,
      profileId: _profileId,
      profileName: 'Default',
      createdAt: DateTime.utc(2026, 8, 18),
      targetTreeUri: targetTreeUri,
    );
    await store.enqueueTask(task);
    return task;
  }

  test('a backup task runs and is recorded completed', () async {
    final task = await enqueue();

    final result = await runnerFor().run(task, password: 'hunter2');

    expect(result.effectiveState, MaintenanceTaskState.completed);
    expect(published, hasLength(1));
    expect(published.single, contains('Default'));

    final stored = (await store.read(useCache: false)).taskById('task-1');
    expect(stored?.effectiveState, MaintenanceTaskState.completed);
  });

  test(
    'the lease is renewed while the work runs, not only at boundaries',
    () async {
      // The gap that matters is *inside* a step: on a real profile the copy and the
      // Argon2 pack both outlast the 60s native heartbeat timeout, and the asserts
      // bracketing them are too far apart to keep the reservation alive.
      final api = _FakeProfileApi();
      final task = await enqueue();

      final result = await runnerFor(
        api: api,
        heartbeatInterval: const Duration(milliseconds: 5),
        whilePacking: () =>
            Future<void>.delayed(const Duration(milliseconds: 40)),
      ).run(task, password: 'hunter2');

      expect(result.effectiveState, MaintenanceTaskState.completed);
      expect(api.heartbeats, greaterThan(0));
    },
  );

  test('the renewal pump stops with the operation', () async {
    final api = _FakeProfileApi();
    final task = await enqueue();

    await runnerFor(
      api: api,
      heartbeatInterval: const Duration(milliseconds: 5),
    ).run(task, password: 'hunter2');

    final afterRun = api.heartbeats;
    await Future<void>.delayed(const Duration(milliseconds: 30));

    // A timer left running would keep a finished process claiming a lease it no
    // longer holds — and would hold the isolate open.
    expect(api.heartbeats, afterRun);
  });

  test('a failure is recorded on the task rather than thrown away', () async {
    final task = await enqueue();

    final result = await runnerFor(packThrows: true).run(task, password: 'x');

    expect(result.effectiveState, MaintenanceTaskState.failed);
    expect(result.error, contains('disk gone'));
    expect(published, isEmpty);
  });

  test('a backup with no target directory fails before doing work', () async {
    final task = await enqueue(targetTreeUri: null);

    final result = await runnerFor().run(task, password: 'x');

    expect(result.effectiveState, MaintenanceTaskState.failed);
    expect(result.error, contains('destination folder'));
    expect(result.failureKind, MaintenanceFailureKind.unknown);
    // Never even transitioned to running: there was nothing runnable.
    expect(workRoot.listSync(), isEmpty);
  });

  test(
    'a missing profile fails instead of archiving an empty directory',
    () async {
      await Directory(
        p.join(paths.profilesDir.path, '${fs.profileDirPrefix}$_profileId'),
      ).delete(recursive: true);
      final task = await enqueue();

      final result = await runnerFor().run(task, password: 'x');

      expect(result.effectiveState, MaintenanceTaskState.failed);
      expect(published, isEmpty);
    },
  );

  test('a journaled action without the journal paths refuses', () async {
    // The runner is constructed here without `paths`, which is what a caller
    // that cannot write outside the profile looks like. Running a destructive
    // operation with nowhere to journal it is the one thing it must not do.
    final task = await enqueue(action: MaintenanceAction.delete);

    final result = await runnerFor().run(task, password: 'x');

    expect(result.effectiveState, MaintenanceTaskState.failed);
    expect(result.error, contains('cannot delete a profile'));
  });

  test('restore into a new profile stays out of maintenance', () async {
    final task = await enqueue(action: MaintenanceAction.restoreClone);

    final result = await runnerFor().run(task, password: 'x');

    expect(result.effectiveState, MaintenanceTaskState.failed);
    expect(result.error, contains('created by a newer version'));
    expect(result.failureKind, MaintenanceFailureKind.unknown);
  });

  test('a quarantined task is left exactly as it was', () async {
    final task = MaintenanceTask(
      id: 'task-9',
      actionId: 'somethingNewer',
      stateId: MaintenanceTaskState.queued.name,
      profileId: _profileId,
      profileName: 'Default',
      createdAt: DateTime.utc(2026, 8, 18),
      targetTreeUri: 'content://tree/backups',
    );
    await store.enqueueTask(task);

    final result = await runnerFor().run(task, password: 'x');

    expect(result.actionId, 'somethingNewer');
    expect(published, isEmpty);
    final stored = (await store.read(useCache: false)).taskById('task-9');
    expect(stored?.stateId, MaintenanceTaskState.queued.name);
  });

  group('a failure before anything is replaced does not reserve maintenance', () {
    // The reservation is what stops the browser opening, and `activeTasks`
    // blocks on `recoveryRequired` as well as on a journal. So a restore that
    // failed at the unpack — a mistyped archive password, the everyday case —
    // used to leave a task that kept the process in maintenance with no way out:
    // "skip" released the lease, native handed it straight back, and the screen
    // came back with its skip button removed.

    Future<MaintenanceTask> enqueueRestore() async {
      final task = MaintenanceTask.create(
        id: 'task-1',
        action: MaintenanceAction.restoreOver,
        profileId: _profileId,
        profileName: 'Default',
        createdAt: DateTime.utc(2026, 8, 18),
        sourceFileUri: 'content://tree/backups/archive.weblibre',
      );
      await store.enqueueTask(task);
      return task;
    }

    test(
      'a wrong archive password fails the task rather than reserving',
      () async {
        final task = await enqueueRestore();

        final result = await runnerFor(
          journaled: true,
          unpacker: (sourceFile, staging, password) async => throw Exception(
            'Decryption failed: wrong password or corrupted data',
          ),
        ).run(task, password: 'not-the-password');

        expect(result.effectiveState, MaintenanceTaskState.failed);
        expect(result.effectiveState.requiresMaintenance, isFalse);
        expect(result.error, contains('password did not open'));

        final stored = (await store.read(useCache: false)).taskById('task-1');
        expect(stored?.effectiveState, MaintenanceTaskState.failed);
        expect(
          (await store.read(useCache: false)).requiresMaintenance,
          isFalse,
        );
      },
    );

    test('the journal is removed, so nothing holds the reservation', () async {
      final task = await enqueueRestore();

      await runnerFor(
        journaled: true,
        unpacker: (sourceFile, staging, password) async => throw Exception(
          'Decryption failed: wrong password or corrupted data',
        ),
      ).run(task, password: 'nope');

      // Both sources of evidence have to be gone: `MaintenanceReservation`
      // resolves from either one alone.
      final journals = Directory(p.join(paths.maintenanceDir.path));
      final leftovers = journals.existsSync()
          ? journals
                .listSync()
                .map((entity) => p.basename(entity.path))
                .where((name) => name.contains('task-1'))
                .toList()
          : <String>[];
      expect(leftovers, isEmpty);
    });

    test('the profile directory is untouched', () async {
      final task = await enqueueRestore();
      final profileDir = Directory(
        p.join(paths.profilesDir.path, '${fs.profileDirPrefix}$_profileId'),
      );
      await File(p.join(profileDir.path, 'canary')).writeAsString('original');

      await runnerFor(
        journaled: true,
        unpacker: (sourceFile, staging, password) async => throw Exception(
          'Decryption failed: wrong password or corrupted data',
        ),
      ).run(task, password: 'nope');

      expect(profileDir.existsSync(), isTrue);
      expect(
        File(p.join(profileDir.path, 'canary')).readAsStringSync(),
        'original',
      );
    });

    test('a retry with the right password is still possible', () async {
      final task = await enqueueRestore();

      await runnerFor(
        journaled: true,
        unpacker: (sourceFile, staging, password) async => throw Exception(
          'Decryption failed: wrong password or corrupted data',
        ),
      ).run(task, password: 'nope');

      // `failed -> queued` is the re-arm edge, which is what lets the user try
      // again from the app rather than being stuck on the maintenance screen.
      final requeued = await store.transitionTask(
        'task-1',
        MaintenanceTaskState.queued,
      );
      expect(
        requeued.taskById('task-1')?.effectiveState,
        MaintenanceTaskState.queued,
      );
    });
  });

  group('recovery releases the task it reconciled', () {
    // Recovery used to reconcile the journal and stop there. But `activeTasks`
    // blocks on `running`/`recoveryRequired` too, so a *successful* recovery
    // left the process in maintenance for good, with a task describing work that
    // was already finished.

    test('a reconciled delete completes its task', () async {
      final task = MaintenanceTask.create(
        id: 'task-1',
        action: MaintenanceAction.delete,
        profileId: _profileId,
        profileName: 'Default',
        createdAt: DateTime.utc(2026, 8, 18),
      );
      await store.enqueueTask(task);
      await store.transitionTask('task-1', MaintenanceTaskState.running);
      await store.transitionTask(
        'task-1',
        MaintenanceTaskState.recoveryRequired,
      );

      expect((await store.read(useCache: false)).requiresMaintenance, isTrue);

      final journal = MaintenanceJournal(
        taskId: 'task-1',
        kindId: MaintenanceJournalKind.delete.name,
        phaseId: DeletePhase.created.name,
        targetProfileId: _profileId,
        updatedAt: DateTime.utc(2026, 8, 19),
      );
      await MaintenanceJournalStore(paths).write(journal);

      final summary = await runnerFor(journaled: true).recoverJournal(journal);

      expect(summary, contains('deletion'));
      final stored = (await store.read(useCache: false)).taskById('task-1');
      expect(stored?.effectiveState, MaintenanceTaskState.completed);
      expect((await store.read(useCache: false)).requiresMaintenance, isFalse);
    });

    test('a task that already finished is left alone', () async {
      final task = MaintenanceTask.create(
        id: 'task-1',
        action: MaintenanceAction.delete,
        profileId: _profileId,
        profileName: 'Default',
        createdAt: DateTime.utc(2026, 8, 18),
      );
      await store.enqueueTask(task);
      await store.transitionTask('task-1', MaintenanceTaskState.running);
      await store.transitionTask('task-1', MaintenanceTaskState.completed);

      final journal = MaintenanceJournal(
        taskId: 'task-1',
        kindId: MaintenanceJournalKind.delete.name,
        phaseId: DeletePhase.created.name,
        targetProfileId: _profileId,
        updatedAt: DateTime.utc(2026, 8, 19),
      );
      await MaintenanceJournalStore(paths).write(journal);

      await runnerFor(journaled: true).recoverJournal(journal);

      final stored = (await store.read(useCache: false)).taskById('task-1');
      expect(stored?.effectiveState, MaintenanceTaskState.completed);
    });
  });
}
