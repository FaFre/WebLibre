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
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/app_update/domain/entities/update_assessment.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';
import 'package:weblibre/features/app_update/domain/entities/update_preferences.dart';
import 'package:weblibre/features/app_update/domain/entities/update_state.dart';
import 'package:weblibre/features/app_update/domain/repositories/update_state_repository.dart';
import 'package:weblibre/features/app_update/domain/services/update_assessment_service.dart';
import 'package:weblibre/features/app_update/domain/services/update_backend.dart';
import 'package:weblibre/features/app_update/domain/services/update_coordinator.dart';

class MemoryRepository implements UpdateStateRepository {
  UpdatePreferences preferences = UpdatePreferences.defaults;
  UpdateMiscState misc = UpdateMiscState.empty;
  Object? writeError;

  @override
  Future<UpdatePreferences> readPreferences() async => preferences;

  @override
  Future<UpdatePreferences> writePreferences(UpdatePreferences p) async {
    final error = writeError;
    if (error != null) throw error;
    return preferences = p;
  }

  @override
  Future<UpdateMiscState> readMisc() async => misc;

  @override
  Future<UpdateMiscState> updateMisc(
    UpdateMiscState Function(UpdateMiscState current) update,
  ) async => misc = update(misc);
}

/// Holds the preference read open until [gate] completes.
class _GatedRepository extends MemoryRepository {
  _GatedRepository(this.gate);

  final Completer<void> gate;

  @override
  Future<UpdatePreferences> readPreferences() async {
    await gate.future;
    return preferences;
  }
}

class FakeBackend implements UpdateBackend {
  RecoveryOutcome recovery = RecoveryOutcome(UpdateIdle());
  Object? recoveryError;

  /// Holds recovery open until completed.
  Completer<void>? recoveryGate;
  int recoveries = 0;
  bool resettable = true;
  int resets = 0;
  Future<UpdateState> Function(CancelToken cancel)? onCheck;
  Future<UpdateState> Function(
    UpdateAssessment assessment,
    void Function(UpdateState) progress,
    CancelToken cancel,
  )?
  onPrepare;
  Future<UpdateState> Function(UpdateAssessment assessment)? onInstall;
  int checks = 0;
  final eventController = StreamController<UpdateEvent>.broadcast();

  @override
  Future<RecoveryOutcome> recover() async {
    recoveries++;
    final gate = recoveryGate;
    if (gate != null) await gate.future;
    final error = recoveryError;
    if (error != null) throw error;
    return recovery;
  }

  @override
  Future<UpdateState> check({required CancelToken cancel}) {
    checks++;
    return onCheck!(cancel);
  }

  @override
  Future<UpdateState> prepare(
    UpdateAssessment assessment, {
    required void Function(UpdateState progress) onProgress,
    required CancelToken cancel,
  }) => onPrepare!(assessment, onProgress, cancel);

  @override
  Future<UpdateState> requestInstallation(UpdateAssessment assessment) =>
      onInstall!(assessment);

  Future<UpdateState> Function(UpdateState current)? onContinue;
  Future<UpdateState> Function(UpdateState current)? onCancel;
  Future<UpdateState?> Function(UpdateState current)? onResumeRefresh;
  Future<void> Function()? onReset;
  Object? cancelError;

  @override
  Future<UpdateState> continueInstallation(UpdateState current) async =>
      onContinue == null ? current : await onContinue!(current);

  @override
  Future<UpdateState> cancelInstallation(UpdateState current) async {
    final error = cancelError;
    if (error != null) throw error;
    final onCancel = this.onCancel;
    if (onCancel != null) return await onCancel(current);
    return UpdateReadyToInstall(current.assessment!);
  }

  @override
  Future<UpdateState?> onResume(UpdateState current) async =>
      onResumeRefresh == null ? null : await onResumeRefresh!(current);

  @override
  Stream<UpdateEvent> get events => eventController.stream;

  @override
  bool get canResetTrust => resettable;

  bool damaged = false;

  @override
  bool get trustDamaged => damaged;

  @override
  Future<void> resetTrust() async {
    resets++;
    await onReset?.call();
    damaged = false;
  }
}

void main() {
  final assessment = const UpdateAssessmentService().undescribed(
    versionCode: 43,
  );
  late FakeBackend backend;
  late MemoryRepository repository;
  late UpdateCoordinator coordinator;
  var now = DateTime.utc(2026, 12, 1, 12);

  /// A test whose `clock` reads [now].
  void clockedTest(String description, FutureOr<void> Function() body) =>
      test(description, () => withClock(Clock(() => now), body));

  setUp(() {
    now = DateTime.utc(2026, 12, 1, 12);
    backend = FakeBackend();
    repository = MemoryRepository();
    coordinator = UpdateCoordinator(backend: backend, repository: repository);
  });

  tearDown(() => coordinator.dispose());

  clockedTest('start recovers, then checks when due', () async {
    backend.onCheck = (_) async => UpdateAvailable(assessment);
    await coordinator.start();
    expect(backend.checks, 1);
    expect(coordinator.state, UpdateAvailable(assessment));
    expect(repository.misc.lastSuccess, now);
  });

  group('recovery at start', () {
    clockedTest(
      'a platform error is never stateCorrupt, and is retried on resume',
      () async {
        repository.preferences = UpdatePreferences(
          automaticChecks: false,
          recoveryRequired: false,
        );
        backend.recoveryError = Exception('channel-error');
        await coordinator.start();
        expect(coordinator.state, UpdateIdle());
        expect(backend.recoveries, 1);

        backend.recoveryError = null;
        backend.recovery = RecoveryOutcome(UpdateReadyToInstall(assessment));
        await coordinator.onResume();
        expect(backend.recoveries, 2);
        expect(coordinator.state, UpdateReadyToInstall(assessment));

        await coordinator.onResume();
        expect(backend.recoveries, 2);
      },
    );

    group('a retried recovery never overwrites an operation', () {
      Future<void> failedStartThenAvailable() async {
        repository.preferences = UpdatePreferences(
          automaticChecks: false,
          recoveryRequired: false,
        );
        backend.recoveryError = Exception('channel-error');
        await coordinator.start();
        backend.onCheck = (_) async => UpdateAvailable(assessment);
        await coordinator.checkForUpdate(manual: true);
        expect(coordinator.state, UpdateAvailable(assessment));
        backend.recoveryError = null;
        backend.recovery = RecoveryOutcome(UpdateAvailable(assessment));
        backend.recoveryGate = Completer<void>();
      }

      clockedTest(
        'a download started meanwhile runs after it, and stays',
        () async {
          await failedStartThenAvailable();
          final downloadGate = Completer<void>();
          backend.onPrepare = (a, progress, cancel) async {
            progress(UpdateDownloading(a, received: 1, total: 10));
            await downloadGate.future;
            return UpdateReadyToInstall(a);
          };

          final resume = coordinator.onResume();
          await pumpEventQueue();
          final download = coordinator.prepareUpdate(assessment.targetId);
          await pumpEventQueue();
          // The download waits for recovery instead of racing it.
          expect(coordinator.state, UpdateAvailable(assessment));

          backend.recoveryGate!.complete();
          await pumpEventQueue();
          expect(coordinator.state, isA<UpdateDownloading>());

          // Still the active download: Cancel reaches it.
          await coordinator.cancelUpdate();
          downloadGate.complete();
          await Future.wait([resume, download]);
          expect(backend.recoveries, 2);
        },
      );

      clockedTest('an event meanwhile wins over what recovery read', () async {
        await failedStartThenAvailable();
        final resume = coordinator.onResume();
        await pumpEventQueue();
        backend.eventController.add(
          UpdateEvent((_) => UpdateReadyToInstall(assessment)),
        );
        await pumpEventQueue();
        backend.recoveryGate!.complete();
        await resume;
        expect(coordinator.state, UpdateReadyToInstall(assessment));
      });

      clockedTest('concurrent resumes share one recovery', () async {
        await failedStartThenAvailable();
        final first = coordinator.onResume();
        final second = coordinator.onResume();
        await pumpEventQueue();
        backend.recoveryGate!.complete();
        await Future.wait([first, second]);
        expect(backend.recoveries, 2);
      });
    });

    clockedTest(
      'a derived "up to date" shows the last successful check',
      () async {
        repository.preferences = UpdatePreferences(
          automaticChecks: false,
          recoveryRequired: false,
        );
        repository.misc = UpdateMiscState(lastSuccess: now);
        backend.recovery = RecoveryOutcome(UpdateUpToDate());
        await coordinator.start();
        expect(coordinator.state, UpdateUpToDate());
        expect(coordinator.snapshot.lastSuccess, now);
      },
    );
  });

  clockedTest(
    'reset is refused where the backend keeps no trust state',
    () async {
      backend.resettable = false;
      backend.onCheck = (_) async => UpdateAvailable(assessment);
      await coordinator.start();
      final checks = backend.checks;
      await coordinator.resetTrustAndCheck();
      expect(backend.resets, 0);
      expect(backend.checks, checks);
    },
  );

  clockedTest('a failed check is failed, never upToDate', () async {
    backend.onCheck = (_) async =>
        throw UpdateFailure(UpdateFailureKind.network);
    await coordinator.start();
    expect(coordinator.state, isA<UpdateFailed>());
    expect((coordinator.state as UpdateFailed).returnTo, UpdateIdle());
    expect(repository.misc.backoffStep, 1);
  });

  clockedTest('anything a backend throws ends in failed', () async {
    backend.onCheck = (_) async => throw StateError('boom');
    await coordinator.start();
    expect((coordinator.state as UpdateFailed).kind, UpdateFailureKind.network);
  });

  clockedTest(
    'automatic checks off: no check at start, manual check still works',
    () async {
      repository.preferences = UpdatePreferences(
        automaticChecks: false,
        recoveryRequired: false,
      );
      backend.onCheck = (_) async => UpdateUpToDate();
      await coordinator.start();
      await coordinator.onResume();
      expect(backend.checks, 0);
      await coordinator.checkForUpdate(manual: true);
      expect(backend.checks, 1);
    },
  );

  clockedTest('a second call joins the active operation', () async {
    final gate = Completer<UpdateState>();
    backend.onCheck = (_) => gate.future;
    repository.preferences = UpdatePreferences(
      automaticChecks: false,
      recoveryRequired: false,
    );
    await coordinator.start();
    final first = coordinator.checkForUpdate(manual: true);
    final second = coordinator.checkForUpdate(manual: true);
    gate.complete(UpdateUpToDate());
    await Future.wait([first, second]);
    expect(backend.checks, 1);
  });

  clockedTest(
    'cancel during a stalled download returns to available without the download finishing',
    () async {
      backend.recovery = RecoveryOutcome(UpdateAvailable(assessment));
      repository.preferences = UpdatePreferences(
        automaticChecks: false,
        recoveryRequired: false,
      );
      final stalled = Completer<UpdateState>();
      backend.onPrepare = (a, progress, cancel) async {
        progress(UpdateDownloading(a, received: 10, total: 100));
        await Future.any([stalled.future, cancel.whenCancelled]);
        if (cancel.isCancelled) return UpdateAvailable(a, partialBytes: 10);
        return await stalled.future;
      };
      await coordinator.start();

      final notices = <UpdateNotice>[];
      coordinator.notices.listen(notices.add);

      final download = coordinator.prepareUpdate(assessment.targetId);
      await Future<void>.delayed(Duration.zero);
      expect(coordinator.state, isA<UpdateDownloading>());

      await coordinator.cancelUpdate();
      await download.timeout(const Duration(seconds: 2));
      expect(stalled.isCompleted, isFalse);
      expect(coordinator.state, UpdateAvailable(assessment, partialBytes: 10));
      await Future<void>.delayed(Duration.zero);
      expect(notices, [UpdateNotice.downloadCancelled]);
    },
  );

  clockedTest(
    'a targetId that is not the current assessment is ignored',
    () async {
      backend.recovery = RecoveryOutcome(UpdateAvailable(assessment));
      backend.onPrepare = (a, p, c) async => fail('must not download');
      repository.preferences = UpdatePreferences(
        automaticChecks: false,
        recoveryRequired: false,
      );
      await coordinator.start();
      await coordinator.prepareUpdate('play:999');
      expect(coordinator.state, UpdateAvailable(assessment));
    },
  );

  clockedTest(
    'an installer event during another operation is applied immediately',
    () async {
      backend.recovery = RecoveryOutcome(UpdateAvailable(assessment));
      repository.preferences = UpdatePreferences(
        automaticChecks: false,
        recoveryRequired: false,
      );
      final gate = Completer<UpdateState>();
      backend.onCheck = (_) => gate.future;
      await coordinator.start();
      unawaited(coordinator.checkForUpdate(manual: true));
      await Future<void>.delayed(Duration.zero);

      backend.eventController.add(
        UpdateEvent((current) => UpdateInstalling(assessment)),
      );
      await Future<void>.delayed(Duration.zero);
      expect(coordinator.state, isA<UpdateInstalling>());
      gate.complete(UpdateAvailable(assessment));
    },
  );

  clockedTest('an event the reducer drops changes nothing', () async {
    repository.preferences = UpdatePreferences(
      automaticChecks: false,
      recoveryRequired: false,
    );
    await coordinator.start();
    backend.eventController.add(UpdateEvent((current) => null));
    await Future<void>.delayed(Duration.zero);
    expect(coordinator.state, UpdateIdle());
  });

  clockedTest('reading the state never changes it', () async {
    backend.recovery = RecoveryOutcome(UpdateAvailable(assessment));
    repository.preferences = UpdatePreferences(
      automaticChecks: false,
      recoveryRequired: false,
    );
    await coordinator.start();
    final before = coordinator.snapshot;
    for (var i = 0; i < 3; i++) {
      expect(coordinator.state, before.state);
    }
    expect(coordinator.snapshot, same(before));
  });

  clockedTest(
    'switching automatic checks off cancels a scheduled check and nothing else',
    () async {
      final gate = Completer<UpdateState>();
      CancelToken? token;
      backend.onCheck = (cancel) {
        token = cancel;
        return gate.future;
      };
      final starting = coordinator.start();
      await Future<void>.delayed(Duration.zero);
      expect(coordinator.state, UpdateChecking());
      await coordinator.setAutomaticChecks(enabled: false);
      expect(token!.isCancelled, isTrue);
      gate.complete(UpdateAvailable(assessment));
      await starting;
      expect(coordinator.state, UpdateIdle());
    },
  );

  clockedTest('switching off leaves a download running', () async {
    backend.recovery = RecoveryOutcome(UpdateAvailable(assessment));
    repository.preferences = UpdatePreferences(
      automaticChecks: false,
      recoveryRequired: false,
    );
    final gate = Completer<UpdateState>();
    CancelToken? token;
    backend.onPrepare = (a, progress, cancel) {
      token = cancel;
      return gate.future;
    };
    await coordinator.start();
    final download = coordinator.prepareUpdate(assessment.targetId);
    await coordinator.setAutomaticChecks(enabled: false);
    expect(token!.isCancelled, isFalse);
    gate.complete(UpdateReadyToInstall(assessment));
    await download;
    expect(coordinator.state, UpdateReadyToInstall(assessment));
  });

  clockedTest(
    'while the install slot is reserved, nothing new starts',
    () async {
      backend.recovery = RecoveryOutcome(
        UpdateInstalling(assessment, foundAfterRestart: true),
      );
      backend.onCheck = (_) async => fail('must not check');
      await coordinator.start();
      await coordinator.checkForUpdate(manual: true);
      await coordinator.prepareUpdate(assessment.targetId);
      expect(coordinator.state, isA<UpdateInstalling>());
    },
  );

  clockedTest(
    'a release is announced once, not again after a restart',
    () async {
      backend.onCheck = (_) async => UpdateAvailable(assessment);
      await coordinator.start();
      expect(coordinator.snapshot.pendingAnnouncement, assessment);
      await coordinator.acknowledgeAnnouncement();
      expect(coordinator.snapshot.pendingAnnouncement, isNull);
      expect(repository.misc.announcedSequence, 43);

      // Restart, next day: the same release is not announced again.
      now = now.add(const Duration(days: 1));
      final restarted = UpdateCoordinator(
        backend: backend,
        repository: repository,
      );
      await restarted.start();
      expect(backend.checks, 2);
      expect(restarted.snapshot.pendingAnnouncement, isNull);
      await restarted.dispose();
    },
  );

  clockedTest('a manual check never announces later', () async {
    repository.preferences = UpdatePreferences(
      automaticChecks: false,
      recoveryRequired: false,
    );
    backend.onCheck = (_) async => UpdateAvailable(assessment);
    await coordinator.start();
    await coordinator.checkForUpdate(manual: true);
    expect(coordinator.snapshot.pendingAnnouncement, isNull);
    expect(repository.misc.announcedSequence, 43);
  });

  clockedTest('"Updated to X" comes from recovery once', () async {
    backend.recovery = RecoveryOutcome(UpdateIdle(), updatedTo: '0.43.0');
    repository.preferences = UpdatePreferences(
      automaticChecks: false,
      recoveryRequired: false,
    );
    await coordinator.start();
    expect(coordinator.snapshot.updatedTo, '0.43.0');
    coordinator.acknowledgeUpdatedNotice();
    expect(coordinator.snapshot.updatedTo, isNull);
  });

  clockedTest('an install failure returns to readyToInstall', () async {
    backend.recovery = RecoveryOutcome(UpdateReadyToInstall(assessment));
    repository.preferences = UpdatePreferences(
      automaticChecks: false,
      recoveryRequired: false,
    );
    backend.onInstall = (_) async =>
        throw UpdateFailure(UpdateFailureKind.authorizationStale);
    await coordinator.start();
    await coordinator.requestInstallation(assessment.targetId);
    final failed = coordinator.state as UpdateFailed;
    expect(failed.kind, UpdateFailureKind.authorizationStale);
    expect(failed.returnTo, UpdateReadyToInstall(assessment));
    expect(failed.retryable, isTrue);
  });

  clockedTest('a failed check over a found update records the check', () async {
    backend.recovery = RecoveryOutcome(UpdateAvailable(assessment));
    repository.preferences = UpdatePreferences(
      automaticChecks: false,
      recoveryRequired: false,
    );
    backend.onCheck = (_) async =>
        throw UpdateFailure(UpdateFailureKind.routingUnavailable);
    await coordinator.start();
    await coordinator.checkForUpdate(manual: true);
    final failed = coordinator.state as UpdateFailed;
    // Retry repeats the check; the update beneath is what stays true.
    expect(failed.operation, UpdateOperation.check);
    expect(failed.underlying, UpdateAvailable(assessment));
  });

  clockedTest('a download failure records the download', () async {
    backend.recovery = RecoveryOutcome(UpdateAvailable(assessment));
    repository.preferences = UpdatePreferences(
      automaticChecks: false,
      recoveryRequired: false,
    );
    backend.onPrepare = (a, p, c) async =>
        throw UpdateFailure(UpdateFailureKind.network);
    await coordinator.start();
    await coordinator.prepareUpdate(assessment.targetId);
    expect(
      (coordinator.state as UpdateFailed).operation,
      UpdateOperation.download,
    );
  });

  group('a failure over a waiting session', () {
    Future<void> failedCancel() async {
      backend.recovery = RecoveryOutcome(UpdateAwaitingUserAction(assessment));
      repository.preferences = UpdatePreferences(
        automaticChecks: false,
        recoveryRequired: false,
      );
      backend.cancelError = Exception('journal write failed');
      await coordinator.start();
      await coordinator.cancelUpdate();
      final failed = coordinator.state as UpdateFailed;
      expect(failed.operation, UpdateOperation.cancelInstallation);
      expect(failed.underlying, UpdateAwaitingUserAction(assessment));
    }

    clockedTest('still holds the install slot', () async {
      await failedCancel();
      backend.onCheck = (_) async => fail('must not check');
      await coordinator.checkForUpdate(manual: true);
      await coordinator.requestInstallation(assessment.targetId);
      expect(coordinator.state, isA<UpdateFailed>());
    });

    clockedTest('can still be continued and cancelled', () async {
      await failedCancel();
      backend.onContinue = (current) async =>
          UpdateInstalling(current.assessment);
      await coordinator.continueInstallation();
      expect(coordinator.state, isA<UpdateInstalling>());

      backend.cancelError = null;
      await coordinator.cancelUpdate();
      expect(coordinator.state, UpdateReadyToInstall(assessment));
    });
  });

  clockedTest(
    'a Cancel too late to stop the download leaves it ready, without a notice',
    () async {
      backend.recovery = RecoveryOutcome(UpdateAvailable(assessment));
      repository.preferences = UpdatePreferences(
        automaticChecks: false,
        recoveryRequired: false,
      );
      final verifying = Completer<void>();
      backend.onPrepare = (a, progress, cancel) async {
        progress(UpdateVerifying(a));
        // Verification can't be cancelled.
        await verifying.future;
        return UpdateReadyToInstall(a);
      };
      await coordinator.start();
      final notices = <UpdateNotice>[];
      coordinator.notices.listen(notices.add);

      final download = coordinator.prepareUpdate(assessment.targetId);
      await pumpEventQueue();
      await coordinator.cancelUpdate();
      verifying.complete();
      await download;
      await pumpEventQueue();
      expect(coordinator.state, UpdateReadyToInstall(assessment));
      expect(notices, isEmpty);
    },
  );

  clockedTest(
    'dispose during a download unwinds without a closed-stream error',
    () async {
      backend.recovery = RecoveryOutcome(UpdateAvailable(assessment));
      repository.preferences = UpdatePreferences(
        automaticChecks: false,
        recoveryRequired: false,
      );
      backend.onPrepare = (a, progress, cancel) async {
        await cancel.whenCancelled;
        // Lets dispose close the streams before the download unwinds.
        await pumpEventQueue();
        throw const OperationCancelled();
      };
      await coordinator.start();
      final download = coordinator.prepareUpdate(assessment.targetId);
      await pumpEventQueue();
      await coordinator.dispose();
      await expectLater(download, completes);
    },
  );

  group('platform events while recovery runs', () {
    clockedTest(
      'are held back, then applied on top of what it publishes',
      () async {
        repository.preferences = UpdatePreferences(
          automaticChecks: false,
          recoveryRequired: false,
        );
        backend.recovery = RecoveryOutcome(
          UpdateInstalling(assessment, foundAfterRestart: true),
        );
        backend.recoveryGate = Completer<void>();
        var acknowledged = 0;
        final starting = coordinator.start();
        await pumpEventQueue();

        // A failure arrives while recovery still reads native state: the
        // state is idle, and a reducer would drop it.
        backend.eventController.add(
          UpdateEvent(
            (current) => current is UpdateInstalling
                ? UpdateFailed(
                    UpdateFailure(UpdateFailureKind.installConflict),
                    returnTo: UpdateReadyToInstall(assessment),
                    operation: UpdateOperation.install,
                  )
                : null,
            onApplied: () async => acknowledged++,
          ),
        );
        await pumpEventQueue();
        expect(coordinator.state, UpdateIdle());
        expect(acknowledged, 0);

        backend.recoveryGate!.complete();
        await starting;
        await pumpEventQueue();
        expect(
          (coordinator.state as UpdateFailed).kind,
          UpdateFailureKind.installConflict,
        );
        expect(acknowledged, 1);
      },
    );

    clockedTest('a dropped event is never acknowledged', () async {
      repository.preferences = UpdatePreferences(
        automaticChecks: false,
        recoveryRequired: false,
      );
      await coordinator.start();
      var acknowledged = 0;
      backend.eventController.add(
        UpdateEvent((current) => null, onApplied: () async => acknowledged++),
      );
      await pumpEventQueue();
      expect(acknowledged, 0);
    });

    clockedTest('a check asked for while the preferences are read waits for '
        'recovery, which then never overwrites it', () async {
      final prefsGate = Completer<void>();
      final slowRepository = _GatedRepository(prefsGate)
        ..preferences = UpdatePreferences(
          automaticChecks: false,
          recoveryRequired: false,
        );
      final gated = UpdateCoordinator(
        backend: backend,
        repository: slowRepository,
      );
      addTearDown(gated.dispose);
      backend.recovery = RecoveryOutcome(UpdateUpToDate());
      final checkGate = Completer<UpdateState>();
      backend.onCheck = (_) => checkGate.future;

      final starting = gated.start();
      final check = gated.checkForUpdate(manual: true);
      await pumpEventQueue();
      // Still reading preferences: nothing has started.
      expect(backend.checks, 0);
      expect(gated.state, UpdateIdle());

      prefsGate.complete();
      await starting;
      await pumpEventQueue();
      expect(backend.recoveries, 1);
      expect(gated.state, UpdateChecking());

      checkGate.complete(UpdateAvailable(assessment));
      await check;
      expect(gated.state, UpdateAvailable(assessment));
    });
  });

  group('an operation of another kind never swallows a request', () {
    setUp(() {
      repository.preferences = UpdatePreferences(
        automaticChecks: false,
        recoveryRequired: false,
      );
    });

    clockedTest(
      'Install during a check installs once the check ends',
      () async {
        backend.recovery = RecoveryOutcome(UpdateReadyToInstall(assessment));
        final checkGate = Completer<UpdateState>();
        backend.onCheck = (_) => checkGate.future;
        var installs = 0;
        backend.onInstall = (a) async {
          installs++;
          return UpdateInstalling(a);
        };
        await coordinator.start();

        final check = coordinator.checkForUpdate(manual: true);
        await pumpEventQueue();
        final install = coordinator.requestInstallation(assessment.targetId);
        await pumpEventQueue();
        expect(installs, 0);

        checkGate.complete(UpdateReadyToInstall(assessment));
        await Future.wait([check, install]);
        expect(installs, 1);
        expect(coordinator.state, isA<UpdateInstalling>());
      },
    );

    clockedTest(
      'Download during a check downloads once the check ends',
      () async {
        backend.recovery = RecoveryOutcome(UpdateAvailable(assessment));
        final checkGate = Completer<UpdateState>();
        backend.onCheck = (_) => checkGate.future;
        backend.onPrepare = (a, progress, cancel) async =>
            UpdateReadyToInstall(a);
        await coordinator.start();

        final check = coordinator.checkForUpdate(manual: true);
        await pumpEventQueue();
        final download = coordinator.prepareUpdate(assessment.targetId);
        checkGate.complete(UpdateAvailable(assessment));
        await Future.wait([check, download]);
        expect(coordinator.state, UpdateReadyToInstall(assessment));
      },
    );

    clockedTest(
      'a check that found another release leaves Install alone',
      () async {
        backend.recovery = RecoveryOutcome(UpdateReadyToInstall(assessment));
        final newer = const UpdateAssessmentService().undescribed(
          versionCode: 44,
        );
        final checkGate = Completer<UpdateState>();
        backend.onCheck = (_) => checkGate.future;
        backend.onInstall = (a) async => fail('must not install');
        await coordinator.start();

        final check = coordinator.checkForUpdate(manual: true);
        await pumpEventQueue();
        final install = coordinator.requestInstallation(assessment.targetId);
        checkGate.complete(UpdateAvailable(newer));
        await Future.wait([check, install]);
        expect(coordinator.state, UpdateAvailable(newer));
      },
    );

    // Both requests are made without yielding in between: each must see the
    // other's reservation, not a free slot both then take.
    clockedTest('a second Install asked for at once joins the first', () async {
      backend.recovery = RecoveryOutcome(UpdateReadyToInstall(assessment));
      final installGate = Completer<UpdateState>();
      var installs = 0;
      backend.onInstall = (a) {
        installs++;
        return installGate.future;
      };
      await coordinator.start();
      final first = coordinator.requestInstallation(assessment.targetId);
      final second = coordinator.requestInstallation(assessment.targetId);
      await pumpEventQueue();
      installGate.complete(UpdateInstalling(assessment));
      await Future.wait([first, second]);
      expect(installs, 1);
    });

    clockedTest(
      'a second Download asked for at once joins the first, and Cancel '
      'reaches the one that runs',
      () async {
        backend.recovery = RecoveryOutcome(UpdateAvailable(assessment));
        var downloads = 0;
        final tokens = <CancelToken>[];
        backend.onPrepare = (a, progress, cancel) async {
          downloads++;
          tokens.add(cancel);
          // Like native staging checks: awaits before the first progress.
          await cancel.whenCancelled;
          return UpdateAvailable(a);
        };
        await coordinator.start();
        final first = coordinator.prepareUpdate(assessment.targetId);
        final second = coordinator.prepareUpdate(assessment.targetId);
        await pumpEventQueue();
        expect(downloads, 1);

        await coordinator.cancelUpdate();
        await Future.wait([first, second]).timeout(const Duration(seconds: 2));
        expect(tokens.single.isCancelled, isTrue);
      },
    );

    clockedTest(
      'Download and Install asked for at once run one after the other, '
      'never together',
      () async {
        backend.recovery = RecoveryOutcome(UpdateAvailable(assessment));
        final downloadGate = Completer<void>();
        var running = 0;
        var overlapped = false;
        backend.onPrepare = (a, progress, cancel) async {
          if (running++ > 0) overlapped = true;
          await downloadGate.future;
          running--;
          return UpdateReadyToInstall(a);
        };
        backend.onInstall = (a) async {
          if (running++ > 0) overlapped = true;
          running--;
          return UpdateInstalling(a);
        };
        await coordinator.start();
        final download = coordinator.prepareUpdate(assessment.targetId);
        final install = coordinator.requestInstallation(assessment.targetId);
        await pumpEventQueue();
        downloadGate.complete();
        await Future.wait([download, install]);
        expect(overlapped, isFalse);
        // The download made the update ready, so the waiting Install ran.
        expect(coordinator.state, isA<UpdateInstalling>());
      },
    );
  });

  group('cancelling an installation', () {
    setUp(() {
      backend.recovery = RecoveryOutcome(UpdateAwaitingUserAction(assessment));
      repository.preferences = UpdatePreferences(
        automaticChecks: false,
        recoveryRequired: false,
      );
    });

    clockedTest(
      'a session Android kept is not reported as cancelled',
      () async {
        backend.onCancel = (current) async => UpdateInstalling(assessment);
        await coordinator.start();
        final notices = <UpdateNotice>[];
        coordinator.notices.listen(notices.add);
        await coordinator.cancelUpdate();
        await pumpEventQueue();
        expect(coordinator.state, isA<UpdateInstalling>());
        expect(notices, isEmpty);
      },
    );

    clockedTest('a session that is gone is', () async {
      await coordinator.start();
      final notices = <UpdateNotice>[];
      coordinator.notices.listen(notices.add);
      await coordinator.cancelUpdate();
      await pumpEventQueue();
      expect(notices, [UpdateNotice.installationCancelled]);
    });

    clockedTest('holds the slot: Continue meanwhile does nothing', () async {
      final gate = Completer<void>();
      backend.onCancel = (current) async {
        await gate.future;
        return UpdateReadyToInstall(assessment);
      };
      var continued = false;
      backend.onContinue = (current) async {
        continued = true;
        return current;
      };
      await coordinator.start();
      final cancel = coordinator.cancelUpdate();
      await pumpEventQueue();
      await coordinator.continueInstallation();
      gate.complete();
      await cancel;
      expect(continued, isFalse);
      expect(coordinator.state, UpdateReadyToInstall(assessment));
    });
  });

  group('the foreground refresh', () {
    final failed = UpdateFailed(
      UpdateFailure(UpdateFailureKind.installConflict),
      returnTo: UpdateReadyToInstall(assessment),
      operation: UpdateOperation.install,
    );

    setUp(() {
      backend.recovery = RecoveryOutcome(UpdateAwaitingUserAction(assessment));
      repository.preferences = UpdatePreferences(
        automaticChecks: false,
        recoveryRequired: false,
      );
    });

    clockedTest(
      'a Continue tapped meanwhile never drops what it reports',
      () async {
        final gate = Completer<void>();
        backend.onResumeRefresh = (current) async {
          await gate.future;
          return failed;
        };
        var continued = false;
        backend.onContinue = (current) async {
          continued = true;
          return current;
        };
        await coordinator.start();
        final resume = coordinator.onResume();
        await pumpEventQueue();
        final continuing = coordinator.continueInstallation();
        await pumpEventQueue();
        gate.complete();
        await Future.wait([resume, continuing]);
        // Native retired that outcome when it reported it.
        expect(coordinator.state, failed);
        // The session is gone, so the waiting Continue had nothing to do.
        expect(continued, isFalse);
      },
    );

    clockedTest(
      'a check asked for during overlapping refreshes runs after them',
      () async {
        backend.recovery = RecoveryOutcome(UpdateReadyToInstall(assessment));
        final newer = const UpdateAssessmentService().undescribed(
          versionCode: 44,
        );
        final gates = [Completer<void>(), Completer<void>()];
        var refreshes = 0;
        backend.onResumeRefresh = (current) async {
          await gates[refreshes++].future;
          return UpdateReadyToInstall(assessment);
        };
        backend.onCheck = (_) async => UpdateAvailable(newer);
        await coordinator.start();

        final first = coordinator.onResume();
        await pumpEventQueue();
        // Both wait on the first refresh, the second resume first, so it
        // starts another refresh as soon as the first ends.
        final second = coordinator.onResume();
        await pumpEventQueue();
        final check = coordinator.checkForUpdate(manual: true);
        await pumpEventQueue();
        gates[0].complete();
        await pumpEventQueue();
        expect(refreshes, 2);
        // The check waits for that one too, rather than running beside it.
        expect(backend.checks, 0);
        gates[1].complete();
        await Future.wait([first, second, check]);
        expect(backend.checks, 1);
        expect(coordinator.state, UpdateAvailable(newer));
      },
    );

    clockedTest('an event meanwhile applies on top of it', () async {
      final gate = Completer<void>();
      backend.onResumeRefresh = (current) async {
        await gate.future;
        return UpdateInstalling(assessment);
      };
      await coordinator.start();
      final resume = coordinator.onResume();
      await pumpEventQueue();
      backend.eventController.add(UpdateEvent((_) => failed));
      await pumpEventQueue();
      expect(coordinator.state, UpdateAwaitingUserAction(assessment));
      gate.complete();
      await resume;
      expect(coordinator.state, failed);
    });
  });

  clockedTest(
    'a check that finds the same file ready keeps the permission wait',
    () async {
      backend.recovery = RecoveryOutcome(UpdateReadyToInstall(assessment));
      repository.preferences = UpdatePreferences(
        automaticChecks: false,
        recoveryRequired: false,
      );
      backend.onInstall = (a) async => UpdateAwaitingPermission(a);
      backend.onCheck = (_) async => UpdateReadyToInstall(assessment);
      await coordinator.start();
      await coordinator.requestInstallation(assessment.targetId);
      await coordinator.checkForUpdate(manual: false);
      expect(coordinator.state, UpdateAwaitingPermission(assessment));

      // Back with the permission granted: the installation continues.
      backend.onResumeRefresh = (current) async =>
          UpdateReadyToInstall(current.assessment!);
      backend.onInstall = (a) async => UpdateInstalling(a);
      await coordinator.onResume();
      expect(coordinator.state, isA<UpdateInstalling>());
    },
  );

  clockedTest('damage that blocks nothing is reported beside the state, '
      'and the reset clears it', () async {
    repository.preferences = UpdatePreferences(
      automaticChecks: false,
      recoveryRequired: false,
    );
    backend.damaged = true;
    backend.recovery = RecoveryOutcome(UpdateReadyToInstall(assessment));
    backend.onCheck = (_) async => UpdateReadyToInstall(assessment);
    await coordinator.start();
    expect(coordinator.state, UpdateReadyToInstall(assessment));
    expect(coordinator.snapshot.trustDamaged, isTrue);

    await coordinator.resetTrustAndCheck();
    expect(backend.resets, 1);
    expect(coordinator.state, UpdateReadyToInstall(assessment));
    expect(coordinator.snapshot.trustDamaged, isFalse);
  });

  clockedTest('reset and check are one operation', () async {
    repository.preferences = UpdatePreferences(
      automaticChecks: false,
      recoveryRequired: false,
    );
    final gate = Completer<void>();
    backend.onReset = () => gate.future;
    backend.onCheck = (_) async => UpdateAvailable(assessment);
    await coordinator.start();
    final reset = coordinator.resetTrustAndCheck();
    await pumpEventQueue();
    // A check asked for meanwhile joins the reset's check.
    final check = coordinator.checkForUpdate(manual: false);
    await pumpEventQueue();
    expect(backend.checks, 0);
    gate.complete();
    await Future.wait([reset, check]);
    expect(backend.checks, 1);
    expect(coordinator.state, UpdateAvailable(assessment));
  });

  clockedTest(
    "a preference that can't be stored still applies, without throwing",
    () async {
      repository.preferences = UpdatePreferences.recovered;
      await coordinator.start();
      repository.writeError = const FileSystemException('disk full');
      await coordinator.setAutomaticChecks(enabled: false);
      expect(coordinator.snapshot.preferences.recoveryRequired, isFalse);
      expect(coordinator.snapshot.preferences.automaticChecks, isFalse);
    },
  );

  clockedTest(
    'retry from a failed install works from the failed state',
    () async {
      backend.recovery = RecoveryOutcome(
        UpdateFailed(
          UpdateFailure(UpdateFailureKind.installCancelled),
          returnTo: UpdateReadyToInstall(assessment),
          operation: UpdateOperation.install,
        ),
      );
      repository.preferences = UpdatePreferences(
        automaticChecks: false,
        recoveryRequired: false,
      );
      backend.onInstall = (a) async => UpdateInstalling(a);
      await coordinator.start();
      await coordinator.requestInstallation(assessment.targetId);
      expect(coordinator.state, isA<UpdateInstalling>());
    },
  );
}
