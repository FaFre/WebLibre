import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/startup/maintenance_evidence.dart';
import 'package:weblibre/core/startup/maintenance_scanner.dart';
import 'package:weblibre/core/startup/models/maintenance_journal.dart';
import 'package:weblibre/core/startup/startup_paths.dart';
import 'package:weblibre/domain/entities/profile.dart';

const _profile = '0199a0b1-1111-7111-8111-111111111111';

void main() {
  late Directory root;
  late StartupPaths paths;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('weblibre_evidence');
    paths = StartupPaths(Directory(p.join(root.path, 'files')));
    await paths.ensureGlobalDirectories();
  });

  tearDown(() async {
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  });

  void writeJournal(String taskId, RestorePhase phase) {
    paths
        .journalFile(taskId)
        .writeAsStringSync(
          jsonEncode(
            MaintenanceJournal(
              taskId: taskId,
              kindId: MaintenanceJournalKind.restore.name,
              phaseId: phase.name,
              targetProfileId: _profile,
              updatedAt: DateTime.utc(2026, 8, 20),
            ).toJson(),
          ),
        );
  }

  void writeUnreadableJournal(String taskId) {
    paths.journalFile(taskId).writeAsStringSync('{ this is not json');
  }

  /// The aside tree as an interrupted replace actually leaves it: a profile
  /// directory, carrying the metadata that says which profile it is.
  void writeAsideProfile(
    String taskId, {
    String? profileId = _profile,
    String marker = 'places.sqlite',
  }) {
    final dir = paths.restoreOldDir(taskId)..createSync(recursive: true);
    File(p.join(dir.path, marker)).writeAsStringSync('user data');
    if (profileId != null) {
      File(p.join(dir.path, 'metadata.json')).writeAsStringSync(
        jsonEncode(Profile(id: profileId, name: 'Personal').toJson()),
      );
    }
  }

  void writeWorkspace(
    String taskId, {
    bool staging = false,
    bool old = false,
    bool incoming = false,
  }) {
    if (staging) {
      final dir = paths.restoreStagingDir(taskId)..createSync(recursive: true);
      File(p.join(dir.path, 'metadata.json')).writeAsStringSync('{}');
    }
    if (old) {
      final dir = paths.restoreOldDir(taskId)..createSync(recursive: true);
      File(p.join(dir.path, 'metadata.json')).writeAsStringSync('{}');
    }
    if (incoming) {
      // What the startup screen's unpacker copies the archive to before opening
      // it — a sibling of staging, not part of it.
      final dir = paths.restoreWorkspaceDir(taskId)
        ..createSync(recursive: true);
      File(p.join(dir.path, 'incoming.weblibre')).writeAsStringSync('archive');
    }
  }

  group('evidenceTaskIds', () {
    test('an unreadable journal blocks its task', () async {
      // The bug: only readable incomplete journals were tracked, so a task whose
      // record could not be parsed was offered as cancellable — while the
      // reservation it caused stayed in place regardless.
      writeUnreadableJournal('task-1');

      final scan = await MaintenanceScanner(paths).scan();

      expect(scan.hasDurableEvidence, isTrue);
      expect(scan.evidenceTaskIds, contains('task-1'));
    });

    test(
      'a restore workspace with no journal at all blocks its task',
      () async {
        writeWorkspace('task-2', staging: true, old: true);

        final scan = await MaintenanceScanner(paths).scan();

        expect(scan.hasDurableEvidence, isTrue);
        expect(scan.evidenceTaskIds, contains('task-2'));
      },
    );

    test('an incomplete journal blocks its task', () async {
      writeJournal('task-3', RestorePhase.oldMoved);

      final scan = await MaintenanceScanner(paths).scan();

      expect(scan.evidenceTaskIds, contains('task-3'));
    });

    test('everything hasDurableEvidence counts is covered', () async {
      // The two definitions have to agree: anything that keeps the process in
      // maintenance must keep its task out of the user's reach.
      writeUnreadableJournal('task-1');
      writeWorkspace('task-2', old: true);
      writeJournal('task-3', RestorePhase.staged);

      final scan = await MaintenanceScanner(paths).scan();

      expect(scan.hasDurableEvidence, isTrue);
      expect(scan.evidenceTaskIds, {'task-1', 'task-2', 'task-3'});
    });

    test('an empty workspace is not evidence', () async {
      paths.restoreWorkspaceDir('task-4').createSync(recursive: true);

      final scan = await MaintenanceScanner(paths).scan();

      expect(scan.hasDurableEvidence, isFalse);
      expect(scan.evidenceTaskIds, isEmpty);
    });

    test('a clean tree blocks nothing', () async {
      final scan = await MaintenanceScanner(paths).scan();

      expect(scan.evidenceTaskIds, isEmpty);
      expect(scan.unresolvedEvidence, isEmpty);
    });
  });

  group('unresolvedEvidence', () {
    test('an incomplete journal is not unresolved: recovery owns it', () async {
      writeJournal('task-1', RestorePhase.oldMoved);

      final scan = await MaintenanceScanner(paths).scan();

      expect(scan.unresolvedEvidence, isEmpty);
    });

    test('an unreadable journal is unresolved', () async {
      writeUnreadableJournal('task-1');

      final scan = await MaintenanceScanner(paths).scan();

      expect(scan.unresolvedEvidence, hasLength(1));
      expect(scan.unresolvedEvidence.single, contains('task-1'));
    });

    test('a workspace holding the old profile is unresolved', () async {
      writeWorkspace('task-2', old: true);

      final scan = await MaintenanceScanner(paths).scan();

      expect(scan.unresolvedEvidence.single, contains('task-2'));
    });

    test('a staging-only workspace is not unresolved: it gets swept', () async {
      writeWorkspace('task-3', staging: true);

      final scan = await MaintenanceScanner(paths).scan();

      expect(scan.unresolvedEvidence, isEmpty);
    });
  });

  group('sweepHarmlessArtifacts', () {
    test('a staging-only orphan is cleared', () async {
      // `old` is created at oldMoved; before that nothing of the user's was
      // touched, so this is an unpacked archive and nothing more.
      writeWorkspace('task-1', staging: true);

      final swept = await sweepHarmlessArtifacts(
        paths,
        await MaintenanceScanner(paths).scan(),
      );

      expect(swept, 1);
      expect(paths.restoreWorkspaceDir('task-1').existsSync(), isFalse);
      expect(
        (await MaintenanceScanner(paths).scan()).hasDurableEvidence,
        isFalse,
      );
    });

    test('a workspace holding the old profile is never swept', () async {
      writeWorkspace('task-1', staging: true, old: true);

      final swept = await sweepHarmlessArtifacts(
        paths,
        await MaintenanceScanner(paths).scan(),
      );

      expect(swept, 0);
      expect(paths.restoreOldDir('task-1').existsSync(), isTrue);
    });

    test('a workspace with a journal is left for recovery', () async {
      // The journal is the record of what happened, and it owns the outcome.
      writeWorkspace('task-1', staging: true);
      writeJournal('task-1', RestorePhase.staged);

      final swept = await sweepHarmlessArtifacts(
        paths,
        await MaintenanceScanner(paths).scan(),
      );

      expect(swept, 0);
      expect(paths.restoreStagingDir('task-1').existsSync(), isTrue);
    });

    test('an interrupted unpack leaves nothing behind', () async {
      // A copy of the whole archive, sitting in private storage with no staging
      // tree beside it: not evidence, not `staging`, and so previously reclaimed
      // by nothing at all.
      writeWorkspace('task-1', incoming: true);

      final swept = await sweepHarmlessArtifacts(
        paths,
        await MaintenanceScanner(paths).scan(),
      );

      expect(swept, 1);
      expect(paths.restoreWorkspaceDir('task-1').existsSync(), isFalse);
    });

    test('a workspace with an unreadable journal is left alone too', () async {
      writeWorkspace('task-1', staging: true);
      writeUnreadableJournal('task-1');

      final swept = await sweepHarmlessArtifacts(
        paths,
        await MaintenanceScanner(paths).scan(),
      );

      expect(swept, 0);
      expect(paths.restoreStagingDir('task-1').existsSync(), isTrue);
    });
  });

  group('discardUnresolvedEvidence', () {
    test('clears the reservation so the browser can open', () async {
      writeUnreadableJournal('task-1');
      writeWorkspace('task-2', staging: true, old: true);

      await discardUnresolvedEvidence(paths);

      final scan = await MaintenanceScanner(paths).scan();
      expect(scan.hasDurableEvidence, isFalse);
      expect(scan.unresolvedEvidence, isEmpty);
    });

    test('takes the old tree with it', () async {
      // Leaving it would keep the reservation, which is the one outcome this
      // choice exists to end.
      writeWorkspace('task-1', old: true);

      await discardUnresolvedEvidence(paths);

      expect(paths.restoreWorkspaceDir('task-1').existsSync(), isFalse);
    });

    test('puts the aside profile back under its own metadata', () async {
      // What the dialog promises: the profile is missing, so the data saved
      // before the replacement goes back.
      writeAsideProfile('task-1');

      await discardUnresolvedEvidence(paths);

      final target = paths.profileDir(_profile);
      expect(target.existsSync(), isTrue);
      expect(File(p.join(target.path, 'places.sqlite')).existsSync(), isTrue);
      expect(paths.restoreWorkspaceDir('task-1').existsSync(), isFalse);
    });

    test('falls back to the journal when the metadata is unreadable', () async {
      // The metadata being damaged is one of the reasons a profile gets
      // restored over in the first place, so it cannot be the only record that
      // says which profile the aside copy is.
      writeAsideProfile('task-1', profileId: null);
      writeJournal('task-1', RestorePhase.oldMoved);

      await discardUnresolvedEvidence(paths);

      final target = paths.profileDir(_profile);
      expect(target.existsSync(), isTrue);
      expect(File(p.join(target.path, 'places.sqlite')).existsSync(), isTrue);
    });

    test(
      'parks an aside profile nothing can name, rather than deleting it',
      () async {
        // The bug this replaced: an unnameable tree is still a whole profile, and
        // the browser was offering a button that deleted it while telling the user
        // it would be put back.
        writeAsideProfile('task-2', profileId: null);

        // Reported back, because the screen has to say the data is still on the
        // device — the log line that names it is not something the user reads.
        expect(await discardUnresolvedEvidence(paths), 1);

        final parked = paths.orphanedProfileDir('task-2');
        expect(parked.existsSync(), isTrue);
        expect(File(p.join(parked.path, 'places.sqlite')).existsSync(), isTrue);

        // Parked is not the same as kept: it has to leave the reservation behind.
        expect(paths.restoreWorkspaceDir('task-2').existsSync(), isFalse);
        final scan = await MaintenanceScanner(paths).scan();
        expect(scan.hasDurableEvidence, isFalse);
      },
    );

    test('parking twice keeps both copies', () async {
      writeAsideProfile('task-3', profileId: null, marker: 'first');
      await discardUnresolvedEvidence(paths);

      writeAsideProfile('task-3', profileId: null, marker: 'second');
      await discardUnresolvedEvidence(paths);

      expect(
        File(
          p.join(paths.orphanedProfileDir('task-3').path, 'first'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join('${paths.orphanedProfileDir('task-3').path}-1', 'second'),
        ).existsSync(),
        isTrue,
      );
    });

    test('leaves the aside profile alone when it is already back', () async {
      // Stated in the dialog: a profile that is already there is whatever the
      // restore left, and this is not an undo.
      paths.profileDir(_profile).createSync(recursive: true);
      writeAsideProfile('task-1');

      await discardUnresolvedEvidence(paths);

      expect(paths.restoreWorkspaceDir('task-1').existsSync(), isFalse);
      expect(
        File(
          p.join(paths.profileDir(_profile).path, 'places.sqlite'),
        ).existsSync(),
        isFalse,
      );
    });

    test('a readable journal is not discarded by it', () async {
      // Recovery can still finish this one, so the choice does not reach it.
      writeJournal('task-1', RestorePhase.oldMoved);

      await discardUnresolvedEvidence(paths);

      expect(paths.journalFile('task-1').existsSync(), isTrue);
    });
  });
}
