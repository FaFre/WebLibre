import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/maintenance/backup_manifest.dart';
import 'package:weblibre/core/maintenance/delete_operation.dart';
import 'package:weblibre/core/maintenance/maintenance_journal_store.dart';
import 'package:weblibre/core/maintenance/maintenance_lease.dart';
import 'package:weblibre/core/maintenance/maintenance_outcome.dart';
import 'package:weblibre/core/maintenance/maintenance_participant.dart';
import 'package:weblibre/core/maintenance/restore_operation.dart';
import 'package:weblibre/core/startup/models/maintenance_journal.dart';
import 'package:weblibre/core/startup/startup_paths.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;

const _target = '0199a0b1-1111-7111-8111-111111111111';
const _other = '0199a0b1-2222-7222-8222-222222222222';

class _FakeProfileApi implements GeckoProfileApi {
  _FakeProfileApi({this.loseLeaseAt});

  final String? loseLeaseAt;

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
  ) async => boundary != loseLeaseAt;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

/// A participant that actually reads and writes the two workspaces.
///
/// The point is the file access, not the bookkeeping: a participant that only
/// recorded calls would pass just as happily against a directory that no longer
/// exists, which is precisely the bug this covers.
class _TreeParticipant implements MaintenanceParticipant {
  String? appliedFrom;
  bool rolledBack = false;
  bool finalized = false;

  @override
  String get id => 'tree';

  @override
  int get version => 1;

  File _rollbackFile(MaintenanceParticipantContext context) =>
      File(p.join(context.rollbackDir.path, id, 'undo.txt'));

  File _stagedFile(MaintenanceParticipantContext context) =>
      File(p.join(context.stagedDir.path, id, 'state.txt'));

  @override
  Future<void> discover(MaintenanceParticipantContext context) async {}

  @override
  Future<void> prepare(MaintenanceParticipantContext context) async {
    final file = _rollbackFile(context);
    await file.parent.create(recursive: true);
    await file.writeAsString('live-state');
  }

  @override
  Future<void> apply(MaintenanceParticipantContext context) async {
    final file = _stagedFile(context);
    if (!file.existsSync()) {
      throw StateError('No archived state at ${file.path}');
    }
    appliedFrom = await file.readAsString();
  }

  @override
  Future<void> verify(MaintenanceParticipantContext context) async {}

  @override
  Future<void> rollback(MaintenanceParticipantContext context) async {
    final file = _rollbackFile(context);
    if (!file.existsSync()) {
      throw StateError('No rollback data at ${file.path}');
    }
    rolledBack = true;
  }

  @override
  Future<void> finalizeWork(MaintenanceParticipantContext context) async {
    finalized = true;
    final file = _rollbackFile(context);
    if (file.existsSync()) await file.delete();
  }
}

void main() {
  late Directory root;
  late StartupPaths paths;
  late MaintenanceJournalStore journals;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('weblibre_journal');
    paths = StartupPaths(Directory(p.join(root.path, 'files')));
    await paths.ensureGlobalDirectories();
    journals = MaintenanceJournalStore(paths);
  });

  tearDown(() async {
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  });

  MaintenanceLease leaseWith(_FakeProfileApi api) => MaintenanceLease(
    leaseId: 'lease-1',
    taskId: 'task-1',
    service: GeckoProfileService(api: api),
  );

  Directory profileDir(String id) =>
      Directory(p.join(paths.profilesDir.path, '${fs.profileDirPrefix}$id'));

  Future<Directory> makeProfileNamed(
    String id, {
    String name = 'Profile',
    String marker = 'original',
    bool locked = false,
  }) async {
    final dir = profileDir(id);
    await Directory(p.join(dir.path, 'databases')).create(recursive: true);
    await File(p.join(dir.path, fs.profileMetadataFileName)).writeAsString(
      jsonEncode({
        'id': id,
        'name': name,
        'authSettings': {
          'authenticationRequired': locked,
          'autoLockMode': 'background',
          'timeout': 300000000,
        },
      }),
    );
    await File(p.join(dir.path, 'marker.txt')).writeAsString(marker);
    return dir;
  }

  Future<Directory> makeProfile(String id, {String marker = 'original'}) =>
      makeProfileNamed(id, marker: marker);

  /// Builds what a valid unpacked archive looks like on disk.
  Future<void> fillStaging(
    Directory staging, {
    String id = _target,
    String name = 'Profile',
    String marker = 'restored',
    bool withMetadata = true,
    bool withDatabases = true,
  }) async {
    await staging.create(recursive: true);
    if (withDatabases) {
      await Directory(
        p.join(staging.path, 'databases'),
      ).create(recursive: true);
    }
    if (withMetadata) {
      await File(
        p.join(staging.path, fs.profileMetadataFileName),
      ).writeAsString(jsonEncode({'id': id, 'name': name}));
    }
    await File(p.join(staging.path, 'marker.txt')).writeAsString(marker);
  }

  RestoreOperation restoreWith(
    _FakeProfileApi api, {
    Future<void> Function(File, Directory)? unpack,
    String? targetProfileName,
    bool adoptArchiveName = false,
  }) => RestoreOperation(
    lease: leaseWith(api),
    journals: journals,
    paths: paths,
    targetProfileName: targetProfileName,
    adoptArchiveName: adoptArchiveName,
    now: () => DateTime.utc(2026, 8, 19),
    unpack: unpack ?? (archive, staging) => fillStaging(staging),
  );

  /// Reproduces the on-disk shape a crash right after `oldMoved` leaves behind.
  Future<void> moveTargetAside() async {
    await paths.restoreOldDir('task-1').parent.create(recursive: true);
    await profileDir(_target).rename(paths.restoreOldDir('task-1').path);
  }

  String markerOf(String id) =>
      File(p.join(profileDir(id).path, 'marker.txt')).readAsStringSync();

  group('restore-over', () {
    test('replaces the profile and clears the journal', () async {
      await makeProfile(_target);

      await restoreWith(_FakeProfileApi()).run(
        taskId: 'task-1',
        targetProfileId: _target,
        archive: File('ignored'),
      );

      expect(markerOf(_target), 'restored');
      expect(paths.journalFile('task-1').existsSync(), isFalse);
      expect(paths.restoreOldDir('task-1').existsSync(), isFalse);
    });

    test('hands the unpacker a path that does not exist yet', () async {
      await makeProfile(_target);

      // Mirrors the real extractor: `SecureArchiveUnpack` refuses a target
      // directory that already exists, so creating staging before calling it
      // failed every restore at the first phase.
      await restoreWith(
        _FakeProfileApi(),
        unpack: (archive, staging) async {
          if (staging.existsSync()) {
            throw ArgumentError(
              'Target directory already exists: ${staging.path}',
            );
          }
          await fillStaging(staging);
        },
      ).run(
        taskId: 'task-1',
        targetProfileId: _target,
        archive: File('ignored'),
      );

      expect(markerOf(_target), 'restored');
    });

    test('drops a staging tree left by an earlier attempt', () async {
      await makeProfile(_target);

      final staging = paths.restoreStagingDir('task-1');
      await staging.create(recursive: true);
      await File(p.join(staging.path, 'leftover.txt')).writeAsString('stale');

      await restoreWith(
        _FakeProfileApi(),
        unpack: (archive, staging) async {
          expect(staging.existsSync(), isFalse);
          await fillStaging(staging);
        },
      ).run(
        taskId: 'task-1',
        targetProfileId: _target,
        archive: File('ignored'),
      );

      expect(markerOf(_target), 'restored');
      expect(
        File(p.join(profileDir(_target).path, 'leftover.txt')).existsSync(),
        isFalse,
      );
    });

    test('restores an archive taken from a different user', () async {
      // The profile uuid names where a tree lives, not what is in it, so a tree
      // can be re-addressed. `restoreAndCreateNew` has always done exactly this
      // when it installs an archive under a fresh uuid; refusing it here was the
      // two paths disagreeing about whether the embedded id means anything.
      await makeProfile(_target);

      await restoreWith(
        _FakeProfileApi(),
        unpack: (archive, staging) =>
            fillStaging(staging, id: _other, marker: 'from-other-user'),
      ).run(
        taskId: 'task-1',
        targetProfileId: _target,
        archive: File('ignored'),
      );

      expect(markerOf(_target), 'from-other-user');
    });

    test('the installed tree claims the directory it lives in', () async {
      // The invariant the old equality check was really protecting: a
      // `metadata.json` naming an id its own folder denies is the
      // `metadataUuidMismatch` state discovery refuses to list or repair.
      await makeProfile(_target);

      await restoreWith(
        _FakeProfileApi(),
        unpack: (archive, staging) => fillStaging(staging, id: _other),
      ).run(
        taskId: 'task-1',
        targetProfileId: _target,
        archive: File('ignored'),
      );

      final metadata =
          jsonDecode(
                File(
                  p.join(profileDir(_target).path, fs.profileMetadataFileName),
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(metadata['id'], _target);
    });

    test('validation runs before the old profile is moved aside', () async {
      await makeProfile(_target);

      await expectLater(
        restoreWith(
          _FakeProfileApi(),
          unpack: (archive, staging) =>
              fillStaging(staging, withMetadata: false),
        ).run(
          taskId: 'task-1',
          targetProfileId: _target,
          archive: File('ignored'),
        ),
        throwsA(isA<MaintenanceAborted>()),
      );

      // The journal is *gone*, and that is the fix rather than an omission. It
      // exists to hold the process in maintenance until an interrupted mutation
      // is reconciled; there was no mutation, and leaving it reserved
      // maintenance permanently over a bad archive.
      expect(await journals.read('task-1'), isNull);
      expect(markerOf(_target), 'original');
    });

    test('the target keeps its own name and lock', () async {
      // Identity from the target, content from the archive. The user asked to
      // replace a profile's *data*; silently renaming it, or dropping the lock
      // on it because a backup said so, is not part of that request.
      await makeProfileNamed(_target, name: 'Personal', locked: true);

      await restoreWith(
        _FakeProfileApi(),
        unpack: (archive, staging) =>
            fillStaging(staging, id: _other, name: 'Work'),
      ).run(
        taskId: 'task-1',
        targetProfileId: _target,
        archive: File('ignored'),
      );

      final metadata =
          jsonDecode(
                File(
                  p.join(profileDir(_target).path, fs.profileMetadataFileName),
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(metadata['name'], 'Personal');
      expect(
        (metadata['authSettings']
            as Map<String, dynamic>)['authenticationRequired'],
        isTrue,
      );
    });

    test('adoptArchiveName takes the name but never the lock', () async {
      // The first-run restore sets this: the target there is a placeholder the
      // user has barely met — an auto-created `Default`, or one made a minute
      // ago — so the backup's own name is the one they meant to end up with.
      //
      // The lock is the half that stays. It belongs to the device and the person
      // holding it, not to the archive, and an archive that could clear it would
      // be a way to unlock a profile by restoring over it.
      await makeProfileNamed(_target, name: 'Default', locked: true);

      await restoreWith(
        _FakeProfileApi(),
        adoptArchiveName: true,
        unpack: (archive, staging) =>
            fillStaging(staging, id: _other, name: 'Work'),
      ).run(
        taskId: 'task-1',
        targetProfileId: _target,
        archive: File('ignored'),
      );

      final metadata =
          jsonDecode(
                File(
                  p.join(profileDir(_target).path, fs.profileMetadataFileName),
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(metadata['name'], 'Work');
      // Still addressed to the target: the tree moves, the identity does not.
      expect(metadata['id'], _target);
      expect(
        (metadata['authSettings']
            as Map<String, dynamic>)['authenticationRequired'],
        isTrue,
      );
    });

    test('an archive with no databases is still refused', () async {
      // Structure is not negotiable even though identity now is.
      await makeProfile(_target);

      await expectLater(
        restoreWith(
          _FakeProfileApi(),
          unpack: (archive, staging) =>
              fillStaging(staging, id: _other, withDatabases: false),
        ).run(
          taskId: 'task-1',
          targetProfileId: _target,
          archive: File('ignored'),
        ),
        throwsA(
          isA<MaintenanceAborted>().having(
            (error) => error.cause,
            'cause',
            isA<RestoreValidationFailure>(),
          ),
        ),
      );

      expect(markerOf(_target), 'original');
    });

    test('an aside copy from an earlier attempt refuses a second run', () async {
      // The data-loss case. `oldMoved` deletes whatever `old` already holds, and
      // once the earlier attempt's journal cannot be read, that tree is the only
      // copy of the profile left anywhere. Recovery gets first refusal; if it
      // could not resolve this, nothing may start over the top of it.
      await makeProfile(_target);
      await moveTargetAside();
      await makeProfile(_target, marker: 'half-restored');

      await expectLater(
        restoreWith(_FakeProfileApi()).run(
          taskId: 'task-1',
          targetProfileId: _target,
          archive: File('ignored'),
        ),
        throwsA(isA<MaintenanceAborted>()),
      );

      expect(
        File(
          p.join(paths.restoreOldDir('task-1').path, 'marker.txt'),
        ).readAsStringSync(),
        'original',
      );
      expect(markerOf(_target), 'half-restored');
    });

    test('an unreadable journal refuses a second run', () async {
      // The journal write in `run` is a plain overwrite, so starting over would
      // destroy the only record that a destructive operation was in flight.
      await makeProfile(_target);
      await paths.journalFile('task-1').parent.create(recursive: true);
      await paths.journalFile('task-1').writeAsString('{ not json');

      await expectLater(
        restoreWith(_FakeProfileApi()).run(
          taskId: 'task-1',
          targetProfileId: _target,
          archive: File('ignored'),
        ),
        throwsA(isA<MaintenanceAborted>()),
      );

      expect(paths.journalFile('task-1').readAsStringSync(), '{ not json');
      expect(markerOf(_target), 'original');
    });

    test('a workspace from an aborted attempt is not left behind', () async {
      await makeProfile(_target);

      await expectLater(
        restoreWith(
          _FakeProfileApi(),
          unpack: (archive, staging) =>
              fillStaging(staging, withMetadata: false),
        ).run(
          taskId: 'task-1',
          targetProfileId: _target,
          archive: File('ignored'),
        ),
        throwsA(isA<MaintenanceAborted>()),
      );

      // A surviving `restore/<taskId>` tree is durable evidence in its own
      // right — `MaintenanceScanner` reserves maintenance on it without any
      // journal at all.
      expect(paths.restoreStagingDir('task-1').existsSync(), isFalse);
      expect(paths.restoreOldDir('task-1').existsSync(), isFalse);
    });

    test('a lost lease stops before installing', () async {
      await makeProfile(_target);

      await expectLater(
        restoreWith(
          _FakeProfileApi(loseLeaseAt: 'restore.installed:task-1'),
        ).run(
          taskId: 'task-1',
          targetProfileId: _target,
          archive: File('ignored'),
        ),
        throwsA(isA<MaintenanceLeaseLost>()),
      );

      // The journal survives, so the next process reconciles rather than boots.
      expect(paths.journalFile('task-1').existsSync(), isTrue);
    });
  });

  group('restore recovery', () {
    Future<MaintenanceJournal> journalAt(RestorePhase phase) => journals.write(
      MaintenanceJournal(
        taskId: 'task-1',
        kindId: MaintenanceJournalKind.restore.name,
        phaseId: phase.name,
        targetProfileId: _target,
        stagingPath: paths.restoreStagingDir('task-1').path,
        oldPath: paths.restoreOldDir('task-1').path,
        updatedAt: DateTime.utc(2026, 8, 19),
      ),
    );

    test('a non-destructive phase just drops the attempt', () async {
      await makeProfile(_target);
      await fillStaging(paths.restoreStagingDir('task-1'));
      final journal = await journalAt(RestorePhase.validated);

      await restoreWith(_FakeProfileApi()).recover(journal);

      expect(markerOf(_target), 'original');
      expect(paths.restoreStagingDir('task-1').existsSync(), isFalse);
      expect(paths.journalFile('task-1').existsSync(), isFalse);
    });

    test('old moved but nothing installed rolls the profile back', () async {
      await makeProfile(_target);
      await moveTargetAside();
      final journal = await journalAt(RestorePhase.oldMoved);

      await restoreWith(_FakeProfileApi()).recover(journal);

      expect(markerOf(_target), 'original');
      expect(paths.restoreOldDir('task-1').existsSync(), isFalse);
    });

    test('old moved with valid staging finishes the install', () async {
      await makeProfile(_target);
      await moveTargetAside();
      await fillStaging(paths.restoreStagingDir('task-1'));
      final journal = await journalAt(RestorePhase.oldMoved);

      await restoreWith(_FakeProfileApi()).recover(journal);

      expect(markerOf(_target), 'restored');
    });

    test('old moved with invalid staging restores the original', () async {
      await makeProfile(_target);
      await moveTargetAside();
      await fillStaging(paths.restoreStagingDir('task-1'), withMetadata: false);
      final journal = await journalAt(RestorePhase.oldMoved);

      await restoreWith(_FakeProfileApi()).recover(journal);

      expect(markerOf(_target), 'original');
    });

    test(
      'installed target with old still present verifies and keeps it',
      () async {
        await makeProfile(_target, marker: 'restored');
        await Directory(
          paths.restoreOldDir('task-1').path,
        ).create(recursive: true);
        final journal = await journalAt(RestorePhase.installed);

        await restoreWith(_FakeProfileApi()).recover(journal);

        expect(markerOf(_target), 'restored');
        expect(paths.restoreOldDir('task-1').existsSync(), isFalse);
      },
    );

    test('past the barrier with no target is held, never guessed', () async {
      final journal = await journalAt(RestorePhase.verified);

      await expectLater(
        restoreWith(_FakeProfileApi()).recover(journal),
        throwsA(isA<RestoreUnrecoverable>()),
      );
      // Held means held: the journal stays and the reservation with it.
      expect(paths.journalFile('task-1').existsSync(), isTrue);
    });

    test('the move-old crash window keeps the untouched profile', () async {
      // `moveOldPrepared` is the write-ahead intent, so reaching disk with the
      // target still present and no `old` means the rename never happened: the
      // profile is the user's own data and the staged tree is still waiting.
      // Nothing was mutated, so the attempt is dropped rather than held — held
      // here would wedge every later start into recovery over a crash that
      // changed nothing.
      await makeProfile(_target);
      await fillStaging(paths.restoreStagingDir('task-1'));
      final journal = await journalAt(RestorePhase.moveOldPrepared);

      await restoreWith(_FakeProfileApi()).recover(journal);

      expect(markerOf(_target), 'original');
      expect(paths.restoreStagingDir('task-1').existsSync(), isFalse);
      expect(paths.journalFile('task-1').existsSync(), isFalse);
    });

    test('no target, no staging and no old cannot be reconciled', () async {
      final journal = await journalAt(RestorePhase.oldMoved);

      await expectLater(
        restoreWith(_FakeProfileApi()).recover(journal),
        throwsA(isA<RestoreUnrecoverable>()),
      );
    });
  });

  group('delete', () {
    DeleteOperation deleteWith(_FakeProfileApi api) => DeleteOperation(
      lease: leaseWith(api),
      journals: journals,
      paths: paths,
      now: () => DateTime.utc(2026, 8, 19),
    );

    test('snapshots ownership before removing anything', () async {
      await makeProfile(_target);
      final operation = deleteWith(
        _FakeProfileApi(loseLeaseAt: 'delete.internalDeleted:task-1'),
      );

      await expectLater(
        operation.run(taskId: 'task-1', profileId: _target),
        throwsA(isA<MaintenanceLeaseLost>()),
      );

      // The profile is still there, but what it contained is already recorded —
      // which is the whole reason the snapshot comes first.
      expect(profileDir(_target).existsSync(), isTrue);
      expect(operation.snapshotFile('task-1').existsSync(), isTrue);
      final snapshot =
          jsonDecode(operation.snapshotFile('task-1').readAsStringSync())
              as Map<String, Object?>;
      expect(snapshot['topLevelEntries'], contains('databases'));
      expect(snapshot['unrecordedCategories'], isNotEmpty);
    });

    test('removes the profile and clears its journal', () async {
      await makeProfile(_target);

      await deleteWith(
        _FakeProfileApi(),
      ).run(taskId: 'task-1', profileId: _target);

      expect(profileDir(_target).existsSync(), isFalse);
      expect(paths.journalFile('task-1').existsSync(), isFalse);
    });

    test('recovery resumes forward and never undoes', () async {
      await makeProfile(_target);
      final journal = await journals.write(
        MaintenanceJournal(
          taskId: 'task-1',
          kindId: MaintenanceJournalKind.delete.name,
          phaseId: DeletePhase.nativeStateDeleted.name,
          targetProfileId: _target,
          updatedAt: DateTime.utc(2026, 8, 19),
        ),
      );

      await deleteWith(_FakeProfileApi()).recover(journal);

      expect(profileDir(_target).existsSync(), isFalse);
      expect(paths.journalFile('task-1').existsSync(), isFalse);
    });

    test('an already-missing profile is refused, not reported done', () async {
      // It used to run straight through: every phase reconciles "already gone"
      // as done, so a task naming a directory that is not there completed and
      // told the user their profile had been deleted. Nothing had been. That
      // reconciliation is for a *resumed* delete, and `run` is the one place
      // that can still tell the two apart.
      await expectLater(
        deleteWith(_FakeProfileApi()).run(taskId: 'task-1', profileId: _target),
        throwsA(isA<MaintenanceAborted>()),
      );

      expect(paths.journalFile('task-1').existsSync(), isFalse);
    });

    test('recovery of an already-removed profile still finishes', () async {
      // The other side of the same coin: here absence is the expected end
      // state, and refusing it would leave the journal — and the reservation —
      // in place forever.
      final journal = await journals.write(
        MaintenanceJournal(
          taskId: 'task-1',
          kindId: MaintenanceJournalKind.delete.name,
          phaseId: DeletePhase.internalDeleted.name,
          targetProfileId: _target,
          updatedAt: DateTime.utc(2026, 8, 19),
        ),
      );

      await deleteWith(_FakeProfileApi()).recover(journal);

      expect(paths.journalFile('task-1').existsSync(), isFalse);
    });
  });

  group('restore participants', () {
    late _TreeParticipant participant;

    setUp(() {
      participant = _TreeParticipant();
    });

    /// Writes what a backup of this archive would have staged into it.
    Future<void> fillStagingWithParticipant(Directory staging) async {
      await fillStaging(staging);
      final file = File(
        p.join(staging.path, participantStagingDirName, 'tree', 'state.txt'),
      );
      await file.parent.create(recursive: true);
      await file.writeAsString('archived');
    }

    RestoreOperation restoreWithParticipant(_FakeProfileApi api) =>
        RestoreOperation(
          lease: leaseWith(api),
          journals: journals,
          paths: paths,
          participants: [participant],
          now: () => DateTime.utc(2026, 8, 19),
          unpack: (archive, staging) => fillStagingWithParticipant(staging),
        );

    test('apply reads the archive after the staged tree is installed', () async {
      await makeProfile(_target);

      await restoreWithParticipant(_FakeProfileApi()).run(
        taskId: 'task-1',
        targetProfileId: _target,
        archive: File(p.join(root.path, 'archive.weblibre')),
      );

      // Against a context built before the rename this is null: the participant
      // finds no snapshot and the restore reports success having applied nothing.
      expect(participant.appliedFrom, 'archived');
      expect(participant.finalized, isTrue);
    });

    test('a finished restore leaves no participant data behind', () async {
      await makeProfile(_target);

      await restoreWithParticipant(_FakeProfileApi()).run(
        taskId: 'task-1',
        targetProfileId: _target,
        archive: File(p.join(root.path, 'archive.weblibre')),
      );

      // Undo data survives the install and is released at completion.
      expect(paths.restoreParticipantsDir('task-1').existsSync(), isFalse);

      // So is the archive's own payload, which the install rename moved *inside*
      // the live profile. Left there it is a plaintext copy of what the
      // participants carried — for the secure-storage one, the account session and
      // the sync key — and an input to every later backup of this profile.
      expect(
        Directory(
          p.join(profileDir(_target).path, participantStagingDirName),
        ).existsSync(),
        isFalse,
      );
    });

    test('recovery applies participants for a tree it keeps', () async {
      // A crash between `installed` and the barrier: the directory is the new
      // data, but nothing says the participants ran.
      await makeProfile(_target, marker: 'restored');
      await fillStagingWithParticipant(profileDir(_target));
      await Directory(
        paths.restoreOldDir('task-1').path,
      ).create(recursive: true);

      final journal = await journals.write(
        MaintenanceJournal(
          taskId: 'task-1',
          kindId: MaintenanceJournalKind.restore.name,
          phaseId: RestorePhase.installed.name,
          targetProfileId: _target,
          stagingPath: paths.restoreStagingDir('task-1').path,
          oldPath: paths.restoreOldDir('task-1').path,
          updatedAt: DateTime.utc(2026, 8, 19),
        ),
      );

      await RestoreOperation(
        lease: leaseWith(_FakeProfileApi()),
        journals: journals,
        paths: paths,
        participants: [participant],
        now: () => DateTime.utc(2026, 8, 19),
        unpack: (archive, staging) async =>
            throw StateError('Recovery does not unpack'),
      ).recover(journal);

      expect(participant.appliedFrom, 'archived');
      expect(participant.finalized, isTrue);
    });

    test('a phase write keeps the records written during it', () async {
      // The coordinator persists participant records *inside* the mutation, so a
      // phase record built from the pre-mutation journal writes them back out
      // again — and a recovering process then cannot tell which participants had
      // prepared.
      await makeProfile(_target);

      await expectLater(
        RestoreOperation(
          lease: leaseWith(
            _FakeProfileApi(loseLeaseAt: 'restore.moveOldPrepared:task-1'),
          ),
          journals: journals,
          paths: paths,
          participants: [participant],
          now: () => DateTime.utc(2026, 8, 19),
          unpack: (archive, staging) => fillStagingWithParticipant(staging),
        ).run(
          taskId: 'task-1',
          targetProfileId: _target,
          archive: File(p.join(root.path, 'archive.weblibre')),
        ),
        throwsA(isA<MaintenanceLeaseLost>()),
      );

      final stored = await journals.read('task-1');
      expect(stored?.phaseId, RestorePhase.participantsPrepared.name);
      expect(stored?.participants.map((record) => record.id), ['tree']);
    });

    test('a rollback that fails holds the restore in recovery', () async {
      // Old moved, nothing installed: the profile goes back, so the participant
      // has to come back with it. Its undo data was never written, which this
      // participant reports as a failure — and a failed rollback must not end
      // with the journal deleted and the restore reported reconciled.
      await makeProfile(_target);
      await moveTargetAside();

      final journal = await journals.write(
        MaintenanceJournal(
          taskId: 'task-1',
          kindId: MaintenanceJournalKind.restore.name,
          phaseId: RestorePhase.oldMoved.name,
          targetProfileId: _target,
          stagingPath: paths.restoreStagingDir('task-1').path,
          oldPath: paths.restoreOldDir('task-1').path,
          updatedAt: DateTime.utc(2026, 8, 19),
        ),
      );

      await expectLater(
        RestoreOperation(
          lease: leaseWith(_FakeProfileApi()),
          journals: journals,
          paths: paths,
          participants: [participant],
          now: () => DateTime.utc(2026, 8, 19),
          unpack: (archive, staging) async =>
              throw StateError('Recovery does not unpack'),
        ).recover(journal),
        throwsA(isA<RestoreUnrecoverable>()),
      );

      // The directory decision still stands; only the native half is unresolved.
      expect(markerOf(_target), 'original');
      expect(participant.rolledBack, isFalse);
      expect(paths.journalFile('task-1').existsSync(), isTrue);
    });

    test('recovery rolls participants back with the profile', () async {
      await makeProfile(_target);
      await moveTargetAside();

      // What `prepare` left behind before the crash.
      final undo = File(
        p.join(paths.restoreParticipantsDir('task-1').path, 'tree', 'undo.txt'),
      );
      await undo.parent.create(recursive: true);
      await undo.writeAsString('live-state');

      final journal = await journals.write(
        MaintenanceJournal(
          taskId: 'task-1',
          kindId: MaintenanceJournalKind.restore.name,
          phaseId: RestorePhase.oldMoved.name,
          targetProfileId: _target,
          stagingPath: paths.restoreStagingDir('task-1').path,
          oldPath: paths.restoreOldDir('task-1').path,
          updatedAt: DateTime.utc(2026, 8, 19),
        ),
      );

      await RestoreOperation(
        lease: leaseWith(_FakeProfileApi()),
        journals: journals,
        paths: paths,
        participants: [participant],
        now: () => DateTime.utc(2026, 8, 19),
        unpack: (archive, staging) async =>
            throw StateError('Recovery does not unpack'),
      ).recover(journal);

      // The directory went back, so the native state has to go back with it.
      expect(markerOf(_target), 'original');
      expect(participant.rolledBack, isTrue);
    });
  });

  group('journal durability', () {
    test('a phase write flushes the journal directory', () async {
      // A rename is recorded in the parent directory, not in either file, so
      // flushing the file alone leaves the newest phase losable.
      final synced = <String>[];
      final store = MaintenanceJournalStore(
        paths,
        syncDirectory: (path) async {
          synced.add(path);
          return true;
        },
      );

      await store.write(
        MaintenanceJournal(
          taskId: 'task-1',
          kindId: MaintenanceJournalKind.restore.name,
          phaseId: RestorePhase.staged.name,
          targetProfileId: _target,
          updatedAt: DateTime.utc(2026, 8, 19),
        ),
      );

      expect(synced, [paths.maintenanceJournalsDir.path]);
    });

    test('a sync that cannot be done does not fail the write', () async {
      // Correctness rests on recovery re-deriving state from the directories,
      // not on this hint landing. Refusing to journal because a durability hint
      // failed would be worse than the gap it narrows.
      final store = MaintenanceJournalStore(
        paths,
        syncDirectory: (path) async => false,
      );

      final journal = await store.write(
        MaintenanceJournal(
          taskId: 'task-1',
          kindId: MaintenanceJournalKind.restore.name,
          phaseId: RestorePhase.staged.name,
          targetProfileId: _target,
          updatedAt: DateTime.utc(2026, 8, 19),
        ),
      );

      expect(journal.phaseId, RestorePhase.staged.name);
      expect(await store.read('task-1'), isNotNull);
    });

    test('a store with no helper still writes', () async {
      final store = MaintenanceJournalStore(paths);

      await store.write(
        MaintenanceJournal(
          taskId: 'task-1',
          kindId: MaintenanceJournalKind.delete.name,
          phaseId: DeletePhase.created.name,
          targetProfileId: _target,
          updatedAt: DateTime.utc(2026, 8, 19),
        ),
      );

      expect(await store.read('task-1'), isNotNull);
    });
  });
}
