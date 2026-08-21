import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/startup/models/maintenance_journal.dart';
import 'package:weblibre/core/startup/models/restart_request.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/core/startup/models/startup_intent.dart';

import 'fixtures.dart';

/// Every expectation here is mirrored assertion-for-assertion in
/// `StartupParityTest.kt`. When one side changes, both must.
void main() {
  group('startup_config_full.json', () {
    late StartupConfig config;

    setUp(() {
      config = StartupConfig.fromJson(readFixture('startup_config_full.json'));
    });

    test('parses prompt mode and shortcut policy', () {
      expect(config.version, 1);
      expect(config.profilePrompt, ProfilePromptMode.browserOnly);
      expect(config.honorShortcutProfile, isFalse);
    });

    test('parses every task', () {
      expect(config.pendingTasks, hasLength(3));
      expect(config.pendingTasks.map((task) => task.actionId), [
        'backup',
        'restoreOver',
        'delete',
      ]);
      expect(config.pendingTasks.every((task) => task.isQuarantined), isFalse);
    });

    test('completed tasks do not hold the maintenance reservation', () {
      expect(config.activeTasks, hasLength(2));
      expect(config.requiresMaintenance, isTrue);
    });

    test(
      'a task left running means the previous process died mid-operation',
      () {
        expect(config.requiresRecovery, isTrue);
      },
    );

    test('optional task fields survive the round trip', () {
      final restore = config.taskById('0199a0b1-0000-7000-8000-000000000002')!;
      expect(restore.action, MaintenanceAction.restoreOver);
      expect(restore.state, MaintenanceTaskState.running);
      expect(restore.adoptArchiveName, isTrue);
      expect(restore.integrityCheck, isTrue);
      expect(
        restore.sourceDigest,
        '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08',
      );
      expect(restore.startedAt, DateTime.utc(2026, 8, 18, 10, 6));
    });
  });

  group('startup_config_tolerant.json', () {
    late StartupConfig config;

    setUp(() {
      config = StartupConfig.fromJson(
        readFixture('startup_config_tolerant.json'),
      );
    });

    test('an unknown prompt mode falls back to off', () {
      expect(config.profilePrompt, ProfilePromptMode.off);
    });

    test('a non-boolean shortcut policy falls back to the default', () {
      expect(config.honorShortcutProfile, isTrue);
    });

    test('unaddressable and duplicate entries are dropped', () {
      expect(config.pendingTasks.map((task) => task.id), [
        '0199a0b1-0000-7000-8000-00000000000a',
        '0199a0b1-0000-7000-8000-00000000000b',
        '0199a0b1-0000-7000-8000-00000000000c',
      ]);
    });

    test('the surviving duplicate is the first one, not the last', () {
      final task = config.taskById('0199a0b1-0000-7000-8000-00000000000a')!;
      expect(task.actionId, 'backup');
      expect(task.profileName, 'Default');
    });

    test('unknown action and state are quarantined individually', () {
      final unknownAction = config.taskById(
        '0199a0b1-0000-7000-8000-00000000000b',
      )!;
      expect(unknownAction.isQuarantined, isTrue);
      expect(unknownAction.action, isNull);
      expect(unknownAction.actionId, 'teleport');
      expect(unknownAction.effectiveState, MaintenanceTaskState.failed);

      final unknownState = config.taskById(
        '0199a0b1-0000-7000-8000-00000000000c',
      )!;
      expect(unknownState.isQuarantined, isTrue);
      expect(unknownState.state, isNull);
      expect(unknownState.stateId, 'levitating');
      expect(unknownState.effectiveState, MaintenanceTaskState.failed);
    });

    test('a quarantined task neither runs nor blocks the valid one', () {
      expect(config.activeTasks.map((task) => task.id), [
        '0199a0b1-0000-7000-8000-00000000000a',
      ]);
      expect(config.requiresMaintenance, isTrue);
      expect(config.requiresRecovery, isFalse);
    });
  });

  test('startup_config_minimal.json yields the documented defaults', () {
    final config = StartupConfig.fromJson(
      readFixture('startup_config_minimal.json'),
    );

    expect(config.version, 1);
    expect(config.profilePrompt, ProfilePromptMode.off);
    expect(config.honorShortcutProfile, isTrue);
    expect(config.pendingTasks, isEmpty);
    expect(config.requiresMaintenance, isFalse);
  });

  test('restart_request.json parses into an actionable request', () {
    final request = RestartRequest.tryFromJson(
      readFixture('restart_request.json'),
    )!;

    expect(request.requestId, '0199a0b2-0000-7000-8000-000000000001');
    expect(request.targetProfileId, '0199a0b1-2222-7222-8222-222222222222');
    expect(request.brokerEntryId, '0199a0b3-0000-7000-8000-00000000000f');
    expect(request.reason, 'profileSwitch');
    expect(request.state, RestartRequestState.pending);
    expect(request.appliedAt, isNull);
    expect(request.createdAt, DateTime.utc(2026, 8, 18, 11));
    expect(request.expiresAt, DateTime.utc(2026, 8, 18, 11, 5));

    final beforeExpiry = DateTime.utc(2026, 8, 18, 11, 1);
    expect(request.isActionableFor('other-process', beforeExpiry), isTrue);

    // The alarm reaching the process that wrote the request must not be honoured.
    expect(
      request.isActionableFor(
        '0199a0b4-0000-7000-8000-0000000000aa',
        beforeExpiry,
      ),
      isFalse,
    );
    expect(
      request.isActionableFor(
        'other-process',
        DateTime.utc(2026, 8, 18, 11, 5),
      ),
      isFalse,
    );
  });

  group('startup_intent_queue.json', () {
    late StartupIntentQueue queue;

    setUp(() {
      queue = StartupIntentQueue.fromJson(
        readFixture('startup_intent_queue.json'),
      );
    });

    test('entries are ordered by sequence and unaddressable ones dropped', () {
      expect(queue.entries.map((entry) => entry.sequence), [1, 2, 3]);
      expect(queue.nextSequence, 4);
    });

    test('only trusted classifications carry a profile hint', () {
      final pwa = queue.entries[0];
      expect(pwa.classification, LaunchClassification.trustedPwa);
      expect(
        pwa.effectiveTrustedProfileId,
        '0199a0b1-2222-7222-8222-222222222222',
      );

      final regular = queue.entries[1];
      expect(regular.classification, LaunchClassification.regular);
      expect(regular.trustedProfileId, isNotNull);
      expect(regular.effectiveTrustedProfileId, isNull);

      final unknown = queue.entries[2];
      expect(unknown.classification, LaunchClassification.unknown);
      expect(unknown.effectiveTrustedProfileId, isNull);
    });

    test('the caller that sent a launch survives the queue', () {
      // Never re-derived on the way out: at replay time `getReferrer()` names
      // this app, and the gatekeeper reads that as internal.
      expect(queue.entries[1].callerPackage, 'com.example.sender');
      expect(queue.entries[0].callerPackage, isNull);
    });

    test('extras keep primitives and string lists only', () {
      final extras = queue.entries[1].extras;
      expect(
        extras.keys,
        unorderedEquals(['string', 'int', 'bool', 'stringList']),
      );
      expect(extras['stringList'], ['a', 'b']);
    });

    test('claims and acknowledgement gate delivery', () {
      const owner = '0199a0b4-0000-7000-8000-0000000000aa';
      final claimed = DateTime.utc(2026, 8, 18, 11, 10);
      final afterClaimExpiry = DateTime.utc(2026, 8, 18, 11, 12);

      final entry = queue.entries[0];

      // The claim holder keeps its own entry.
      expect(entry.isDeliverableAt(claimed, owner, 'engine_id'), isTrue);

      // Another process cannot take a live claim.
      expect(
        entry.isDeliverableAt(claimed, 'someone-else', 'engine_id'),
        isFalse,
      );

      // Neither can a replacement engine *in the same process*: MainActivity can
      // build a second engine after a non-finishing destroy, and re-delivering to
      // it would duplicate an intent the first engine is still handling.
      expect(entry.isDeliverableAt(claimed, owner, 'engine-2'), isFalse);

      // Once the claim expires anyone may recover it.
      expect(
        entry.isDeliverableAt(afterClaimExpiry, 'someone-else', 'engine-2'),
        isTrue,
      );

      // Acknowledged entries are never replayed.
      expect(
        queue.entries[2].isDeliverableAt(
          afterClaimExpiry,
          'anyone',
          'engine-2',
        ),
        isFalse,
      );
    });
  });

  group('explicit JSON nulls', () {
    test(
      'restart request nulls read back as null, not as the string "null"',
      () {
        final request = RestartRequest.tryFromJson(
          readFixture('restart_request_nulls.json'),
        )!;

        expect(request.targetProfileId, isNull);
        expect(request.brokerEntryId, isNull);
        expect(request.appliedAt, isNull);
        expect(request.reason, '');
        expect(request.state, RestartRequestState.pending);
      },
    );

    test('intent entry nulls read back as null and empty collections', () {
      final entry = StartupIntentQueue.fromJson(
        readFixture('startup_intent_queue_nulls.json'),
      ).entries.single;

      expect(entry.action, isNull);
      expect(entry.dataUri, isNull);
      expect(entry.mimeType, isNull);
      expect(entry.trustedProfileId, isNull);
      expect(entry.callerPackage, isNull);
      expect(entry.payloadDirName, isNull);
      expect(entry.claim, isNull);
      expect(entry.classification, LaunchClassification.unknown);
      expect(entry.categories, isEmpty);
      expect(entry.flags, isEmpty);
      expect(entry.extras, isEmpty);
      expect(entry.acknowledged, isFalse);
    });

    test('a restart request round-trips through its own serializer', () {
      final original = RestartRequest.tryFromJson(
        readFixture('restart_request.json'),
      )!;

      expect(RestartRequest.tryFromJson(original.toJson()), original);
    });

    test('an intent queue round-trips through its own serializer', () {
      final original = StartupIntentQueue.fromJson(
        readFixture('startup_intent_queue.json'),
      );
      final reparsed = StartupIntentQueue.fromJson(original.toJson());

      expect(reparsed.nextSequence, original.nextSequence);
      expect(reparsed.entries, original.entries);
    });
  });

  group('maintenance journals', () {
    test('an in-flight restore requires recovery', () {
      final journal = MaintenanceJournal.tryFromJson(
        readFixture('maintenance_journal_restore.json'),
      )!;

      expect(journal.kind, MaintenanceJournalKind.restore);
      expect(journal.restorePhase, RestorePhase.oldMoved);
      expect(journal.isUnrecognised, isFalse);
      expect(journal.isComplete, isFalse);
      expect(journal.requiresRecovery, isTrue);
      expect(journal.isPastCommitBarrier, isFalse);
      expect(journal.restorePhase!.isDestructive, isTrue);
      expect(journal.participants.map((record) => record.id), [
        'sharedPreferences',
        'externalTrees',
      ]);
      expect(journal.participants.first.state, ParticipantState.prepared);
    });

    test('a completed delete does not', () {
      final journal = MaintenanceJournal.tryFromJson(
        readFixture('maintenance_journal_delete.json'),
      )!;

      expect(journal.kind, MaintenanceJournalKind.delete);
      expect(journal.deletePhase, DeletePhase.completed);
      expect(journal.isComplete, isTrue);
      expect(journal.requiresRecovery, isFalse);
      expect(journal.isPastCommitBarrier, isTrue);
    });

    test('an unrecognised journal is never optimistically ignored', () {
      final journal = MaintenanceJournal.tryFromJson(
        readFixture('maintenance_journal_unknown.json'),
      )!;

      expect(journal.kind, isNull);
      expect(journal.isUnrecognised, isTrue);
      expect(journal.requiresRecovery, isTrue);
    });
  });
}
