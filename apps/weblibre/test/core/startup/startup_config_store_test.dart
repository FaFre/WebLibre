import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/core/startup/startup_config_store.dart';
import 'package:weblibre/core/startup/startup_paths.dart';

void main() {
  late Directory filesDir;
  late StartupPaths paths;
  late StartupConfigStore store;

  setUp(() async {
    filesDir = await Directory.systemTemp.createTemp('weblibre_startup_cfg');
    paths = StartupPaths(filesDir);
    await paths.ensureGlobalDirectories();
    store = StartupConfigStore(paths);
  });

  tearDown(() async {
    if (filesDir.existsSync()) {
      await filesDir.delete(recursive: true);
    }
  });

  MaintenanceTask task(
    String id, {
    MaintenanceAction action = MaintenanceAction.backup,
    MaintenanceTaskState state = MaintenanceTaskState.queued,
  }) {
    return MaintenanceTask.create(
      id: id,
      action: action,
      state: state,
      profileId: '0199a0b1-1111-7111-8111-111111111111',
      profileName: 'Default',
      createdAt: DateTime.utc(2026, 8, 18),
    );
  }

  test('an absent config reads as defaults without creating a file', () async {
    final config = await store.read();

    expect(config, StartupConfig.defaults);
    expect(paths.startupConfigFile.existsSync(), isFalse);
  });

  test('writes are atomic and leave no temp file behind', () async {
    await store.setProfilePrompt(ProfilePromptMode.browserOnly);

    expect(paths.startupConfigFile.existsSync(), isTrue);
    expect(File('${paths.startupConfigFile.path}.tmp').existsSync(), isFalse);

    final onDisk = jsonDecode(paths.startupConfigFile.readAsStringSync());
    expect((onDisk as Map)['profilePrompt'], 'browserOnly');
  });

  test('a fresh store reads back what the previous one wrote', () async {
    await store.enqueueTask(task('task-1'));
    await store.setHonorShortcutProfile(honor: false);

    final reopened = await StartupConfigStore(paths).read();
    expect(reopened.honorShortcutProfile, isFalse);
    expect(reopened.pendingTasks.map((t) => t.id), ['task-1']);
  });

  test(
    'a corrupt config is quarantined, not deleted, and reads as defaults',
    () async {
      await paths.startupConfigFile.writeAsString('{ this is not json');

      final config = await store.read();
      expect(config, StartupConfig.defaults);
      expect(paths.startupConfigFile.existsSync(), isFalse);

      final quarantined = paths.profilesDir
          .listSync()
          .whereType<File>()
          .where((f) => p.basename(f.path).contains('.corrupt.'))
          .toList();
      expect(quarantined, hasLength(1));
      expect(quarantined.single.readAsStringSync(), '{ this is not json');
    },
  );

  test(
    'quarantining a corrupt config does not touch maintenance evidence',
    () async {
      final journal = paths.journalFile('task-1');
      await journal.writeAsString('{"taskId":"task-1"}');
      await paths.restoreStagingDir('task-1').create(recursive: true);

      await paths.startupConfigFile.writeAsString('not json at all');
      await store.read();

      expect(journal.existsSync(), isTrue);
      expect(paths.restoreStagingDir('task-1').existsSync(), isTrue);
    },
  );

  test(
    'concurrent updates all land instead of overwriting each other',
    () async {
      await Future.wait([
        for (var i = 0; i < 20; i++) store.enqueueTask(task('task-$i')),
      ]);

      final config = await StartupConfigStore(paths).read();
      expect(config.pendingTasks, hasLength(20));
      expect(config.pendingTasks.map((t) => t.id).toSet(), {
        for (var i = 0; i < 20; i++) 'task-$i',
      });
    },
  );

  test('enqueueing the same task id twice is a no-op', () async {
    await store.enqueueTask(task('task-1'));
    await store.enqueueTask(task('task-1', action: MaintenanceAction.delete));

    final config = await store.read();
    expect(config.pendingTasks, hasLength(1));
    expect(config.pendingTasks.single.action, MaintenanceAction.backup);
  });

  test('legal transitions are applied', () async {
    await store.enqueueTask(task('task-1'));

    await store.transitionTask('task-1', MaintenanceTaskState.running);
    expect(
      (await store.read()).taskById('task-1')!.state,
      MaintenanceTaskState.running,
    );

    await store.transitionTask('task-1', MaintenanceTaskState.committing);
    await store.transitionTask('task-1', MaintenanceTaskState.completed);
    expect(
      (await store.read()).taskById('task-1')!.state,
      MaintenanceTaskState.completed,
    );
  });

  test(
    'an out-of-order transition is refused rather than silently accepted',
    () async {
      await store.enqueueTask(
        task('task-1', state: MaintenanceTaskState.completed),
      );

      await store.transitionTask('task-1', MaintenanceTaskState.running);

      expect(
        (await store.read()).taskById('task-1')!.state,
        MaintenanceTaskState.completed,
      );
    },
  );

  test('a quarantined task cannot be transitioned', () async {
    await store.enqueueTask(
      MaintenanceTask(
        id: 'task-1',
        actionId: 'teleport',
        stateId: 'queued',
        profileId: '0199a0b1-1111-7111-8111-111111111111',
        profileName: 'Default',
        createdAt: DateTime.utc(2026, 8, 18),
      ),
    );

    await store.transitionTask('task-1', MaintenanceTaskState.running);

    final stored = (await store.read()).taskById('task-1')!;
    expect(stored.stateId, 'queued');
    expect(stored.effectiveState, MaintenanceTaskState.failed);
  });

  test(
    'cancellation returns a pre-barrier task to queued or removes it',
    () async {
      await store.enqueueTask(
        task('task-1', state: MaintenanceTaskState.running),
      );

      expect(
        (await store.read()).taskById('task-1')!.state!.isCancellable,
        isTrue,
      );

      await store.transitionTask('task-1', MaintenanceTaskState.queued);
      expect(
        (await store.read()).taskById('task-1')!.state,
        MaintenanceTaskState.queued,
      );

      await store.removeTask('task-1');
      expect((await store.read()).pendingTasks, isEmpty);
    },
  );

  test('a committing task can no longer be cancelled', () {
    expect(MaintenanceTaskState.committing.isCancellable, isFalse);
    expect(
      MaintenanceTaskState.committing.canTransitionTo(
        MaintenanceTaskState.queued,
      ),
      isFalse,
    );
  });

  test('mutateTask records non-state changes and rejects id changes', () async {
    await store.enqueueTask(task('task-1'));

    await store.mutateTask('task-1', (t) => t.copyWith(sourceDigest: 'abc123'));

    expect((await store.read()).taskById('task-1')!.sourceDigest, 'abc123');

    // `id` is declared immutable for copyWith, so the guard is about a caller
    // constructing a differently-identified task by hand.
    await expectLater(
      store.mutateTask(
        'task-1',
        (t) => MaintenanceTask(
          id: 'task-2',
          actionId: t.actionId,
          stateId: t.stateId,
          profileId: t.profileId,
          profileName: t.profileName,
          createdAt: t.createdAt,
        ),
      ),
      throwsArgumentError,
    );
  });
}
