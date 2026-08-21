import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/startup/maintenance_scanner.dart';
import 'package:weblibre/core/startup/models/maintenance_journal.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/core/startup/startup_config_store.dart';
import 'package:weblibre/core/startup/startup_paths.dart';

const _profileId = '0199a0b1-1111-7111-8111-111111111111';

void main() {
  _tolerantParsingTests();

  late Directory filesDir;
  late StartupPaths paths;
  late MaintenanceScanner scanner;

  setUp(() async {
    filesDir = await Directory.systemTemp.createTemp('weblibre_maintenance');
    paths = StartupPaths(filesDir);
    await paths.ensureGlobalDirectories();
    scanner = MaintenanceScanner(paths);
  });

  tearDown(() async {
    if (filesDir.existsSync()) {
      await filesDir.delete(recursive: true);
    }
  });

  Future<void> writeJournal(
    String taskId, {
    required MaintenanceJournalKind kind,
    required String phase,
  }) async {
    final journal = MaintenanceJournal(
      taskId: taskId,
      kindId: kind.name,
      phaseId: phase,
      targetProfileId: _profileId,
      updatedAt: DateTime.utc(2026, 8, 18),
    );
    await paths.journalFile(taskId).writeAsString(jsonEncode(journal.toJson()));
  }

  MaintenanceTask queuedTask(
    String id, {
    MaintenanceTaskState state = MaintenanceTaskState.queued,
  }) {
    return MaintenanceTask.create(
      id: id,
      action: MaintenanceAction.backup,
      state: state,
      profileId: _profileId,
      profileName: 'Default',
      createdAt: DateTime.utc(2026, 8, 18),
    );
  }

  test('an empty workspace produces no reservation', () async {
    final scan = await scanner.scan();

    expect(scan.hasDurableEvidence, isFalse);
    final reservation = MaintenanceReservation.resolve(
      StartupConfig.defaults,
      scan,
    );
    expect(reservation.required, isFalse);
    expect(reservation.recoveryRequired, isFalse);
  });

  test('a completed journal alone does not reserve maintenance', () async {
    await writeJournal(
      'task-1',
      kind: MaintenanceJournalKind.delete,
      phase: DeletePhase.completed.name,
    );

    final scan = await scanner.scan();
    expect(scan.journals, hasLength(1));
    expect(scan.incompleteJournals, isEmpty);
    expect(scan.hasDurableEvidence, isFalse);
  });

  test(
    'an incomplete journal reserves maintenance and demands recovery',
    () async {
      await writeJournal(
        'task-1',
        kind: MaintenanceJournalKind.restore,
        phase: RestorePhase.oldMoved.name,
      );

      final reservation = MaintenanceReservation.resolve(
        StartupConfig.defaults,
        await scanner.scan(),
      );

      expect(reservation.required, isTrue);
      expect(reservation.recoveryRequired, isTrue);
      expect(reservation.taskId, 'task-1');
      expect(reservation.scan.profilesUnderMaintenance, {_profileId});
    },
  );

  test('an unreadable journal is reported, not quarantined away', () async {
    await paths.journalFile('task-1').writeAsString('{ not json');

    final scan = await scanner.scan();

    expect(scan.unreadableJournals, hasLength(1));
    expect(scan.hasDurableEvidence, isTrue);
    // The evidence must survive the scan, or the next process would boot the
    // possibly half-restored profile.
    expect(paths.journalFile('task-1').existsSync(), isTrue);
  });

  test('a journal without identifying fields counts as unreadable', () async {
    await paths.journalFile('task-1').writeAsString('{"phase":"staged"}');

    final scan = await scanner.scan();
    expect(scan.unreadableJournals, hasLength(1));
    expect(scan.journals, isEmpty);
  });

  test(
    'restore artifacts reserve maintenance even with no config at all',
    () async {
      await paths.restoreOldDir('task-1').create(recursive: true);
      await File(
        p.join(paths.restoreOldDir('task-1').path, 'metadata.json'),
      ).writeAsString('{}');

      final scan = await scanner.scan();
      expect(scan.artifacts, hasLength(1));
      expect(scan.artifacts.single.hasOld, isTrue);
      expect(scan.artifacts.single.hasStaging, isFalse);

      final reservation = MaintenanceReservation.resolve(
        StartupConfig.defaults,
        scan,
      );
      expect(reservation.required, isTrue);
      expect(reservation.recoveryRequired, isTrue);
      expect(reservation.taskId, 'task-1');
    },
  );

  test(
    'restore artifacts reserve maintenance even with a corrupt config',
    () async {
      await paths.startupConfigFile.writeAsString('{ this is not json');
      await paths.restoreStagingDir('task-9').create(recursive: true);
      await File(
        p.join(paths.restoreStagingDir('task-9').path, 'archive.part'),
      ).writeAsString('x');

      // Reading the config quarantines it and yields defaults with no tasks…
      final config = await StartupConfigStore(paths).read();
      expect(config.pendingTasks, isEmpty);

      // …yet the filesystem evidence still holds the reservation.
      final reservation = MaintenanceReservation.resolve(
        config,
        await scanner.scan(),
      );
      expect(reservation.required, isTrue);
      expect(reservation.taskId, 'task-9');
      expect(reservation.reason, contains('durable'));
    },
  );

  test('an empty restore workspace is not evidence on its own', () async {
    await paths.restoreWorkspaceDir('task-1').create(recursive: true);

    final scan = await scanner.scan();
    expect(scan.artifacts.single.isEmpty, isTrue);
    expect(scan.hasDurableEvidence, isFalse);
  });

  test(
    'a queued task reserves maintenance without demanding recovery',
    () async {
      final config = StartupConfig(pendingTasks: [queuedTask('task-1')]);

      final reservation = MaintenanceReservation.resolve(
        config,
        await scanner.scan(),
      );

      expect(reservation.required, isTrue);
      expect(reservation.recoveryRequired, isFalse);
      expect(reservation.taskId, 'task-1');
      expect(reservation.reason, contains('queued'));
    },
  );

  test(
    'a task left running demands recovery even with a clean workspace',
    () async {
      final config = StartupConfig(
        pendingTasks: [
          queuedTask('task-1', state: MaintenanceTaskState.running),
        ],
      );

      final reservation = MaintenanceReservation.resolve(
        config,
        await scanner.scan(),
      );

      expect(reservation.required, isTrue);
      expect(reservation.recoveryRequired, isTrue);
    },
  );

  test(
    'the mid-operation task is preferred over an earlier queued one',
    () async {
      await writeJournal(
        'task-2',
        kind: MaintenanceJournalKind.restore,
        phase: RestorePhase.installed.name,
      );

      final config = StartupConfig(
        pendingTasks: [
          queuedTask('task-1'),
          queuedTask('task-2', state: MaintenanceTaskState.running),
        ],
      );

      final reservation = MaintenanceReservation.resolve(
        config,
        await scanner.scan(),
      );

      expect(reservation.taskId, 'task-2');
    },
  );
}

/// A journal is evidence that a destructive operation was in flight, and it is
/// read on the startup path before anything else can run. A field of the wrong
/// *type* — not merely missing — must therefore degrade to a default, exactly as
/// a hand-written tolerant reader did, and must never take the scan down with
/// it: an exception here is an app that cannot start until the file is deleted
/// by hand.
void _tolerantParsingTests() {
  group('malformed journal fields', () {
    late Directory filesDir;
    late StartupPaths paths;

    setUp(() async {
      filesDir = await Directory.systemTemp.createTemp('weblibre_malformed');
      paths = StartupPaths(filesDir);
      await paths.ensureGlobalDirectories();
    });

    tearDown(() async {
      if (filesDir.existsSync()) {
        await filesDir.delete(recursive: true);
      }
    });

    Map<String, Object?> wellFormed() => {
      'version': 1,
      'taskId': 'task-1',
      'kind': 'restore',
      'phase': 'staged',
      'targetProfileId': _profileId,
      'participants': <Object?>[],
      'updatedAt': DateTime.utc(2026, 8, 18).toIso8601String(),
    };

    test('a string version falls back instead of throwing', () {
      final journal = MaintenanceJournal.tryFromJson({
        ...wellFormed(),
        'version': '1',
      });

      expect(journal, isNotNull);
      expect(journal!.version, maintenanceJournalVersion);
      // Still a recognisable restore journal, not a write-off.
      expect(journal.kind, MaintenanceJournalKind.restore);
    });

    test('non-string kind and phase fall back instead of throwing', () {
      final journal = MaintenanceJournal.tryFromJson({
        ...wellFormed(),
        'kind': 1,
        'phase': false,
      });

      expect(journal, isNotNull);
      expect(journal!.kindId, '');
      expect(journal.phaseId, '');
      // Unrecognised, so the next process offers recovery rather than booting.
      expect(journal.isUnrecognised, isTrue);
    });

    test('a malformed participant version falls back instead of throwing', () {
      final journal = MaintenanceJournal.tryFromJson({
        ...wellFormed(),
        'participants': [
          {'id': 'secureStorage', 'version': '2', 'state': 'prepared'},
        ],
      });

      expect(journal, isNotNull);
      expect(journal!.participants.single.version, 0);
      expect(journal.participants.single.state, ParticipantState.prepared);
    });

    test('scan reports a malformed journal instead of throwing', () async {
      await paths
          .journalFile('task-1')
          .writeAsString(
            jsonEncode({...wellFormed(), 'version': '1', 'kind': 7}),
          );

      final scan = await MaintenanceScanner(paths).scan();

      expect(scan.journals, hasLength(1));
      expect(scan.unreadableJournals, isEmpty);
      expect(scan.journals.single.taskId, 'task-1');
    });
  });
}
