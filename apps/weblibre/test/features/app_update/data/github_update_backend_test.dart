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
import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/features/app_update/data/github/allowlisted_fetcher.dart';
import 'package:weblibre/features/app_update/data/github/apk_download_service.dart';
import 'package:weblibre/features/app_update/data/github/github_update_backend.dart';
import 'package:weblibre/features/app_update/data/metadata/freshness_guard.dart';
import 'package:weblibre/features/app_update/data/metadata/static_release_metadata_repository.dart';
import 'package:weblibre/features/app_update/data/native/app_update_host.dart';
import 'package:weblibre/features/app_update/data/store/accepted_catalogue_store.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';
import 'package:weblibre/features/app_update/domain/entities/update_state.dart';
import 'package:weblibre/features/app_update/domain/services/update_backend.dart';
import 'package:weblibre/features/proxy/domain/services/app_routing_policy.dart';

import '../fixtures.dart';
import 'fake_host.dart';

final apkBytes = utf8.encode('APK' * 4000);
final apkSha = sha256.convert(apkBytes).toString();

/// A release whose arm64/skia target carries a real digest of [apkBytes].
Map<String, Object?> realRelease(int sequence) {
  final release = releaseJson(sequence: sequence);
  for (final target
      in (release['targets']! as List).cast<Map<String, Object?>>()) {
    if (target['abi'] == 'arm64-v8a' && target['renderer'] == 'skia') {
      target['artifact'] = {
        'url':
            'https://github.com/FaFre/WebLibre/releases/download/v$sequence/app-stable-arm64-v8a-release.apk',
        'byteLength': apkBytes.length,
        'sha256': apkSha,
      };
    }
  }
  return release;
}

void main() {
  late TestSigningKey key;
  late Directory root;
  late String stagingDir;
  late String stateDir;
  late FakeHost host;
  late List<Uri> requests;
  late List<int> currentEnvelope;
  var offline = false;
  var routingBlocked = false;
  var now = DateTime.utc(2026, 12, 2);

  /// A test whose `clock` reads [now].
  void clockedTest(String description, FutureOr<void> Function() body) =>
      test(description, () => withClock(Clock(() => now), body));
  final installed = installedBuild();

  setUpAll(() async {
    key = await TestSigningKey.generate('wl-meta-2026a');
  });

  Future<void> publish({
    required int revision,
    List<Map<String, Object?>>? releases,
    DateTime? issuedAt,
  }) async {
    currentEnvelope = await envelope(
      catalogueJson(
        revision: revision,
        issuedAt: issuedAt ?? DateTime.utc(2026, 12),
        releases: releases ?? [realRelease(43)],
      ),
      keys: [key],
    );
  }

  setUp(() async {
    root = await Directory.systemTemp.createTemp('github_backend');
    stagingDir = p.join(root.path, 'cache');
    stateDir = p.join(root.path, 'state');
    await Directory(stagingDir).create();
    await Directory(stateDir).create();
    host = FakeHost(
      installed: installed,
      stagingDir: stagingDir,
      stateDir: stateDir,
    );
    requests = [];
    offline = false;
    routingBlocked = false;
    now = DateTime.utc(2026, 12, 2);
    await publish(revision: 1);
  });

  tearDown(() => root.delete(recursive: true));

  http.Client client() => MockClient((request) async {
    if (routingBlocked) throw const AppRoutingBlockedException('proxy down');
    if (offline) throw const SocketException('offline');
    requests.add(request.url);
    if (request.url.host == 'updates.weblibre.eu') {
      return http.Response.bytes(currentEnvelope, 200);
    }
    if (request.url.host == 'github.com') {
      return http.Response.bytes(apkBytes, 200);
    }
    return http.Response('', 404);
  });

  GithubUpdateBackend backend({
    Future<void> Function()? flush,
    http.Client? httpClient,
  }) {
    final reader = readerFor([key]);
    final fetcher = AllowlistedFetcher(client: httpClient ?? client());
    return GithubUpdateBackend(
      host: host,
      installed: installed,
      stagingDir: stagingDir,
      metadata: StaticReleaseMetadataRepository(
        packageId: packageId,
        fetcher: fetcher,
        reader: reader,
        store: AcceptedCatalogueStore(stateDir: stateDir, reader: reader),
        guard: FreshnessGuard(buildTime: installed.buildTime),
      ),
      download: ApkDownloadService(
        fetcher: fetcher,
        stagingDir: stagingDir,
        retryDelay: Duration.zero,
      ),
      flushPendingWrites: flush,
    );
  }

  File staged(String ext) => File(p.join(stagingDir, '$apkSha.$ext'));

  Future<UpdateState> downloaded(GithubUpdateBackend b) async {
    final available = await b.check(cancel: CancelToken());
    return await b.prepare(
      available.assessment!,
      onProgress: (_) {},
      cancel: CancelToken(),
    );
  }

  clockedTest(
    'a check contacts only the catalogue host (manual download, D5)',
    () async {
      final state = await backend().check(cancel: CancelToken());
      expect(state, isA<UpdateAvailable>());
      expect(requests.map((u) => u.host).toSet(), {'updates.weblibre.eu'});
    },
  );

  clockedTest(
    'a blocked route is routingUnavailable, with no direct fallback',
    () async {
      routingBlocked = true;
      await expectLater(
        backend().check(cancel: CancelToken()),
        throwsA(
          isA<UpdateFailure>().having(
            (f) => f.kind,
            'kind',
            UpdateFailureKind.routingUnavailable,
          ),
        ),
      );
      expect(requests, isEmpty);
    },
  );

  clockedTest('a staged file idle for 30 days is cleaned up', () async {
    await downloaded(backend());
    now = DateTime.utc(2027, 2);
    await backend().recover();
    expect(await staged('apk').exists(), isFalse);
  });

  clockedTest(
    'recovery cleans up before deriving: never ready for a deleted file',
    () async {
      await downloaded(backend());
      // Still usable (expires 2026-12-31), but idle for over 30 days.
      await staged('apk').setLastModified(DateTime.utc(2026, 10));
      final outcome = await backend().recover();
      expect(await staged('apk').exists(), isFalse);
      expect(outcome.state, isA<UpdateAvailable>());
    },
  );

  clockedTest(
    'download, verify and promote: readyToInstall with the .apk staged',
    () async {
      final state = await downloaded(backend());
      expect(state, isA<UpdateReadyToInstall>());
      expect(await staged('apk').exists(), isTrue);
      expect(await staged('part').exists(), isFalse);
      expect(requests.last.host, 'github.com');
    },
  );

  group('authorization at install time (7.5)', () {
    clockedTest(
      'download, then past expiry, restart, offline: blocked and the file is kept',
      () async {
        final ready = await downloaded(backend()) as UpdateReadyToInstall;
        now = DateTime.utc(2027, 1, 5); // past expiresAt + slack
        await staged('apk').setLastModified(DateTime.utc(2027, 1));
        offline = true;
        final restarted = backend();
        await restarted.recover();
        await expectLater(
          restarted.requestInstallation(ready.assessment),
          throwsA(
            isA<UpdateFailure>().having(
              (f) => f.kind,
              'kind',
              UpdateFailureKind.authorizationStale,
            ),
          ),
        );
        expect(await staged('apk').exists(), isTrue);
        expect(host.commits, isEmpty);
      },
    );

    clockedTest(
      'target removed from the catalogue: targetWithdrawn, the file deleted '
      'and the resting state re-derived',
      () async {
        final b = backend();
        final ready = await downloaded(b) as UpdateReadyToInstall;
        await publish(revision: 2, releases: [releaseJson(sequence: 44)]);
        final state =
            await b.requestInstallation(ready.assessment) as UpdateFailed;
        expect(state.kind, UpdateFailureKind.targetWithdrawn);
        expect(state.returnTo, isNot(isA<UpdateReadyToInstall>()));
        expect(await staged('apk').exists(), isFalse);
        expect(host.commits, isEmpty);
      },
    );

    clockedTest(
      'offline with an unexpired stored catalogue: allowed',
      () async {
        final b = backend();
        final ready = await downloaded(b) as UpdateReadyToInstall;
        offline = true;
        final state = await b.requestInstallation(ready.assessment);
        expect(state, isA<UpdateInstalling>());
        expect(host.commits.single.sha256, apkSha);
        // expiresAt plus the guard's slack: native and Dart agree on when
        // the catalogue stops being usable.
        expect(
          host.commits.single.authorizedUntilEpochMs,
          DateTime.utc(2027).millisecondsSinceEpoch,
        );
      },
    );

    clockedTest(
      'offline after a higher revision dropping the target was accepted: blocked',
      () async {
        final b = backend();
        final ready = await downloaded(b) as UpdateReadyToInstall;
        await publish(revision: 2, releases: [releaseJson(sequence: 44)]);
        await b.check(cancel: CancelToken());
        offline = true;
        final state =
            await b.requestInstallation(ready.assessment) as UpdateFailed;
        expect(state.kind, UpdateFailureKind.targetWithdrawn);
        expect(host.commits, isEmpty);
      },
    );

    clockedTest(
      'a rejected fetch (a stale CDN copy) falls back to the stored catalogue',
      () async {
        final b = backend();
        final ready = await downloaded(b) as UpdateReadyToInstall;
        await publish(revision: 0); // rollback
        final state = await b.requestInstallation(ready.assessment);
        expect(state, isA<UpdateInstalling>());
        expect(host.commits.single.sha256, apkSha);
      },
    );

    clockedTest(
      'a rejected fetch with an expired stored catalogue: blocked, APK kept',
      () async {
        final ready = await downloaded(backend()) as UpdateReadyToInstall;
        await publish(revision: 0); // rollback
        now = DateTime.utc(2027, 1, 5); // past expiresAt + slack
        await expectLater(
          backend().requestInstallation(ready.assessment),
          throwsA(
            isA<UpdateFailure>().having(
              (f) => f.kind,
              'kind',
              UpdateFailureKind.authorizationStale,
            ),
          ),
        );
        expect(await staged('apk').exists(), isTrue);
        expect(host.commits, isEmpty);
      },
    );

    clockedTest(
      'authorization before the permission screen is not reused after it',
      () async {
        final b = backend();
        final ready = await downloaded(b) as UpdateReadyToInstall;
        host.canInstall = false;
        final before = requests.length;
        expect(
          await b.requestInstallation(ready.assessment),
          isA<UpdateAwaitingPermission>(),
        );
        host.canInstall = true;
        // The catalogue changed while the user was in system settings.
        await publish(revision: 2, releases: [releaseJson(sequence: 44)]);
        final state =
            await b.requestInstallation(ready.assessment) as UpdateFailed;
        expect(state.kind, UpdateFailureKind.targetWithdrawn);
        expect(requests.length, before + 2);
      },
    );
  });

  group('derived state after a restart (7.6)', () {
    clockedTest('.apk present: readyToInstall without the network', () async {
      await downloaded(backend());
      offline = true;
      final outcome = await backend().recover();
      expect(outcome.state, isA<UpdateReadyToInstall>());
    });

    clockedTest('.apk of the wrong length: deleted, available', () async {
      await downloaded(backend());
      await staged('apk').writeAsBytes(apkBytes.sublist(0, 100));
      final outcome = await backend().recover();
      expect(outcome.state, isA<UpdateAvailable>());
      expect(await staged('apk').exists(), isFalse);
    });

    clockedTest('.part present: available with the partial size', () async {
      await backend().check(cancel: CancelToken());
      await staged('part').writeAsBytes(apkBytes.sublist(0, 100));
      final outcome = await backend().recover();
      expect((outcome.state as UpdateAvailable).partialBytes, 100);
    });

    clockedTest('expired catalogue: idle, staged files kept', () async {
      await downloaded(backend());
      now = DateTime.utc(2027, 1, 5);
      await staged('apk').setLastModified(DateTime.utc(2027, 1));
      final outcome = await backend().recover();
      expect(outcome.state, UpdateIdle());
      expect(await staged('apk').exists(), isTrue);
    });

    clockedTest(
      'recovery required: stateCorrupt, staged files kept, reset recovers',
      () async {
        await downloaded(backend());
        await File(p.join(stateDir, 'accepted_a.dsse')).writeAsString('x');
        await File(p.join(stateDir, 'accepted_b.dsse')).writeAsString('y');
        final b = backend();
        final outcome = await b.recover();
        expect(
          (outcome.state as UpdateFailed).kind,
          UpdateFailureKind.stateCorrupt,
        );
        expect(await staged('apk').exists(), isTrue);

        await b.resetTrust();
        final state = await b.check(cancel: CancelToken());
        // The kept file is adopted again once a catalogue selects its digest.
        expect(state, isA<UpdateReadyToInstall>());
      },
    );

    clockedTest(
      'a committed session still in progress: installing, found after restart',
      () async {
        await backend().check(cancel: CancelToken());
        host.reconciliation = InstallerReconciliation(
          result: ReconcileResult.inProgress,
          ours: false,
        );
        final outcome = await backend().recover();
        final state = outcome.state as UpdateInstalling;
        expect(state.foundAfterRestart, isTrue);
      },
    );

    clockedTest(
      'an install that completed and was ours: "Updated to X" once',
      () async {
        host.reconciliation = InstallerReconciliation(
          result: ReconcileResult.succeeded,
          ours: true,
        );
        expect((await backend().recover()).updatedTo, installed.versionName);
      },
    );

    clockedTest('another installer finished it: no notice', () async {
      host.reconciliation = InstallerReconciliation(
        result: ReconcileResult.succeeded,
        ours: false,
      );
      expect((await backend().recover()).updatedTo, isNull);
    });

    clockedTest(
      'a waiting session whose authorization lapsed is abandoned',
      () async {
        await downloaded(backend());
        now = DateTime.utc(2027, 2);
        host.reconciliation = InstallerReconciliation(
          result: ReconcileResult.awaitingUserAction,
          ours: false,
          expected: ExpectedArtifact(
            sha256: apkSha,
            byteLength: apkBytes.length,
            versionCode: 433,
            logicalReleaseSequence: 43,
            distribution: BuildDistribution.github,
            track: BuildTrack.stable,
            renderer: BuildRenderer.skia,
            abi: 'arm64-v8a',
            authorizedUntilEpochMs: 0,
          ),
        );
        final outcome = await backend().recover();
        expect(host.abandons, 1);
        expect(outcome.state, isNot(isA<UpdateAwaitingUserAction>()));
      },
    );
  });

  group(
    'pending writes are flushed right before the process can end (7.5)',
    () {
      clockedTest('after authorization, immediately before commit', () async {
        final order = <String>[];
        final b = backend(
          flush: () async => order.add('flush:${host.commits.length}'),
        );
        final ready = await downloaded(b) as UpdateReadyToInstall;
        final requestsBefore = requests.length;
        await b.requestInstallation(ready.assessment);
        // The catalogue was fetched (authorization) before the flush, and
        // nothing was committed yet when it ran.
        expect(requests.length, greaterThan(requestsBefore));
        expect(order, ['flush:0']);
        expect(host.commits, hasLength(1));
      });

      clockedTest('not when authorization fails', () async {
        var flushes = 0;
        final b = backend(flush: () async => flushes++);
        final ready = await downloaded(b) as UpdateReadyToInstall;
        await publish(revision: 2, releases: [releaseJson(sequence: 44)]);
        await b.requestInstallation(ready.assessment);
        expect(flushes, 0);
      });

      clockedTest(
        'before the confirmation is started again on "Continue"',
        () async {
          var flushes = 0;
          final b = backend(flush: () async => flushes++);
          final ready = await downloaded(b) as UpdateReadyToInstall;
          host.continueResult = true;
          await b.continueInstallation(
            UpdateAwaitingUserAction(ready.assessment),
          );
          expect(flushes, 1);
        },
      );
    },
  );

  clockedTest(
    'reservationActive from native re-derives instead of failing',
    () async {
      final b = backend();
      final ready = await downloaded(b) as UpdateReadyToInstall;
      host.commitFailure = NativeFailure.reservationActive;
      host.reconciliation = InstallerReconciliation(
        result: ReconcileResult.inProgress,
        ours: false,
      );
      expect(
        await b.requestInstallation(ready.assessment),
        isA<UpdateInstalling>(),
      );
    },
  );

  group('an outcome Android reported early is kept', () {
    clockedTest(
      'a failure recorded before commit returned is not reported as installing',
      () async {
        final b = backend();
        final ready = await downloaded(b) as UpdateReadyToInstall;
        host.committedResult = InstallCommitResult(
          committed: true,
          phase: InstallerPhase.failed,
          failure: NativeFailure.installConflict,
          detail: 'conflict',
          sessionId: 1,
          nonce: 'n',
        );
        final state =
            await b.requestInstallation(ready.assessment) as UpdateFailed;
        expect(state.kind, UpdateFailureKind.installConflict);
        expect(state.returnTo, isA<UpdateReadyToInstall>());
        // Shown from the commit's answer, so acknowledged: no second report
        // later.
        expect(host.acknowledged, [(1, 'n')]);
      },
    );

    clockedTest(
      'a failure already retired by a reconciliation as well',
      () async {
        final b = backend();
        final ready = await downloaded(b) as UpdateReadyToInstall;
        // Native answers a retired outcome without the session's ids.
        host.committedResult = InstallCommitResult(
          committed: true,
          phase: InstallerPhase.failed,
          failure: NativeFailure.installIncompatible,
        );
        final state =
            await b.requestInstallation(ready.assessment) as UpdateFailed;
        expect(state.kind, UpdateFailureKind.installIncompatible);
        expect(host.acknowledged, isEmpty);
      },
    );

    clockedTest('on resume, a finished failure is reconciled once', () async {
      final b = backend();
      final ready = await downloaded(b) as UpdateReadyToInstall;
      host.reconciliation = InstallerReconciliation(
        result: ReconcileResult.failed,
        ours: false,
        failure: NativeFailure.installConflict,
      );
      final next =
          (await b.onResume(UpdateInstalling(ready.assessment)))!
              as UpdateFailed;
      expect(next.kind, UpdateFailureKind.installConflict);
      expect(host.reconciles, 1);
    });

    clockedTest('returning to a waiting session leaves it as it is', () async {
      final b = backend();
      final ready = await downloaded(b) as UpdateReadyToInstall;
      host.reconciliation = InstallerReconciliation(
        result: ReconcileResult.awaitingUserAction,
        ours: false,
      );
      expect(
        await b.onResume(UpdateAwaitingUserAction(ready.assessment)),
        isNull,
      );
    });
  });

  clockedTest(
    'installer events: confirmation, failure and foreign phases',
    () async {
      final b = backend();
      final ready = await downloaded(b) as UpdateReadyToInstall;
      final installing = UpdateInstalling(ready.assessment);
      final reducers = <UpdateState? Function(UpdateState)>[];
      final sub = b.events.listen((event) => reducers.add(event.reduce));

      host.installerController
        ..add(
          InstallerStatusEvent(
            sessionId: 1,
            nonce: 'n',
            phase: InstallerPhase.pendingUserAction,
          ),
        )
        ..add(
          InstallerStatusEvent(
            sessionId: 1,
            nonce: 'n',
            phase: InstallerPhase.failed,
            failure: NativeFailure.installConflict,
          ),
        );
      await Future<void>.delayed(Duration.zero);

      expect(reducers[0](installing), isA<UpdateAwaitingUserAction>());
      final failed = reducers[1](installing)! as UpdateFailed;
      expect(failed.kind, UpdateFailureKind.installConflict);
      expect(failed.returnTo, isA<UpdateReadyToInstall>());
      // Not tracking a session: dropped.
      expect(reducers[0](UpdateIdle()), isNull);
      // A session beneath a failed Cancel is still tracked.
      final beneath = UpdateFailed(
        UpdateFailure(UpdateFailureKind.installUnknown),
        returnTo: UpdateAwaitingUserAction(ready.assessment),
        operation: UpdateOperation.cancelInstallation,
      );
      expect(
        (reducers[1](beneath)! as UpdateFailed).kind,
        UpdateFailureKind.installConflict,
      );
      await sub.cancel();
    },
  );

  clockedTest(
    'only a failure event is acknowledged, with its session',
    () async {
      final b = backend();
      final events = <UpdateEvent>[];
      final sub = b.events.listen(events.add);
      host.installerController
        ..add(
          InstallerStatusEvent(
            sessionId: 3,
            nonce: 'x',
            phase: InstallerPhase.pendingUserAction,
          ),
        )
        ..add(
          InstallerStatusEvent(
            sessionId: 3,
            nonce: 'x',
            phase: InstallerPhase.failed,
            failure: NativeFailure.installConflict,
          ),
        );
      await Future<void>.delayed(Duration.zero);
      expect(events[0].onApplied, isNull);
      await events[1].onApplied!();
      expect(host.acknowledged, [(3, 'x')]);
      await sub.cancel();
    },
  );

  group("a declined confirmation is the user's choice, not a failure", () {
    clockedTest('the live event returns to the staged file', () async {
      final b = backend();
      final ready = await downloaded(b) as UpdateReadyToInstall;
      final events = <UpdateEvent>[];
      final sub = b.events.listen(events.add);
      host.installerController.add(
        InstallerStatusEvent(
          sessionId: 4,
          nonce: 'c',
          phase: InstallerPhase.failed,
          failure: NativeFailure.installCancelled,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        events.single.reduce(UpdateAwaitingUserAction(ready.assessment)),
        UpdateReadyToInstall(ready.assessment),
      );
      // Still acknowledged: native must not report it again.
      await events.single.onApplied!();
      expect(host.acknowledged, [(4, 'c')]);
      await sub.cancel();
    });

    clockedTest('so does one recorded before commit returned', () async {
      final b = backend();
      final ready = await downloaded(b) as UpdateReadyToInstall;
      host.committedResult = InstallCommitResult(
        committed: true,
        phase: InstallerPhase.failed,
        failure: NativeFailure.installCancelled,
        sessionId: 5,
        nonce: 'd',
      );
      expect(
        await b.requestInstallation(ready.assessment),
        UpdateReadyToInstall(ready.assessment),
      );
      expect(host.acknowledged, [(5, 'd')]);
    });

    clockedTest("a verifier's rejection is still reported", () async {
      // Android aborts a session its verifier rejects; native reports that as
      // installBlocked, never as a decline.
      final b = backend();
      final ready = await downloaded(b) as UpdateReadyToInstall;
      final events = <UpdateEvent>[];
      final sub = b.events.listen(events.add);
      host.installerController.add(
        InstallerStatusEvent(
          sessionId: 6,
          nonce: 'v',
          phase: InstallerPhase.failed,
          failure: NativeFailure.installBlocked,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      final failed =
          events.single.reduce(UpdateAwaitingUserAction(ready.assessment))!
              as UpdateFailed;
      expect(failed.kind, UpdateFailureKind.installBlocked);
      expect(failed.returnTo, UpdateReadyToInstall(ready.assessment));
      await sub.cancel();
    });

    clockedTest('a decline found at recovery returns quietly too', () async {
      final b = backend();
      final ready = await downloaded(b) as UpdateReadyToInstall;
      await b.requestInstallation(ready.assessment);
      host.reconciliation = InstallerReconciliation(
        result: ReconcileResult.failed,
        ours: false,
        failure: NativeFailure.installCancelled,
        expected: host.commits.single,
      );
      final state = (await backend().recover()).state;
      expect(state, isA<UpdateReadyToInstall>());
      expect(await staged('apk').exists(), isTrue);
    });
  });

  clockedTest('a catalogue that only moves the download URL still authorizes '
      'the staged file', () async {
    final b = backend();
    final ready = await downloaded(b) as UpdateReadyToInstall;
    final moved = realRelease(43);
    for (final target
        in (moved['targets']! as List).cast<Map<String, Object?>>()) {
      final artifact = target['artifact'] as Map<String, Object?>?;
      if (artifact?['sha256'] == apkSha) {
        artifact!['url'] =
            'https://github.com/FaFre/WebLibre/releases/download/v43/renamed.apk';
      }
    }
    await publish(revision: 2, releases: [moved]);
    expect(
      await b.requestInstallation(ready.assessment),
      isA<UpdateInstalling>(),
    );
    expect(host.commits.single.sha256, apkSha);
    expect(await staged('apk').exists(), isTrue);
  });

  clockedTest('a rejected APK found at recovery is deleted, as the live event '
      'would have', () async {
    final b = backend();
    final ready = await downloaded(b) as UpdateReadyToInstall;
    await b.requestInstallation(ready.assessment);
    final expected = host.commits.single;
    host.reconciliation = InstallerReconciliation(
      result: ReconcileResult.failed,
      ours: false,
      failure: NativeFailure.apkInvalid,
      expected: expected,
    );
    final state = (await backend().recover()).state as UpdateFailed;
    expect(state.kind, UpdateFailureKind.apkInvalid);
    expect(await staged('apk').exists(), isFalse);
    // Retry downloads again; it never commits the rejected file.
    expect(state.returnTo, isA<UpdateAvailable>());
  });

  clockedTest('on resume, a session beneath a failure is reconciled', () async {
    final b = backend();
    final ready = await downloaded(b) as UpdateReadyToInstall;
    host.reconciliation = InstallerReconciliation(
      result: ReconcileResult.none,
      ours: false,
    );
    final next = await b.onResume(
      UpdateFailed(
        UpdateFailure(UpdateFailureKind.installUnknown),
        returnTo: UpdateAwaitingUserAction(ready.assessment),
        operation: UpdateOperation.cancelInstallation,
      ),
    );
    expect(host.reconciles, 1);
    // The session is gone: what the staged file offers now.
    expect(next, isA<UpdateReadyToInstall>());
  });

  clockedTest(
    'Continue that fails after abandoning returns to the staged file',
    () async {
      final b = backend();
      final ready = await downloaded(b) as UpdateReadyToInstall;
      host.continueResult = false;
      // Authorization fails: offline, and the stored catalogue expired.
      offline = true;
      now = DateTime.utc(2027, 1, 5);
      final state =
          await b.continueInstallation(
                UpdateAwaitingUserAction(ready.assessment),
              )
              as UpdateFailed;
      expect(host.abandons, 1);
      expect(state.kind, UpdateFailureKind.authorizationStale);
      expect(state.operation, UpdateOperation.install);
      expect(state.returnTo, UpdateReadyToInstall(ready.assessment));
    },
  );

  group('Continue is authorized like a commit (7.5)', () {
    clockedTest(
      'a surviving confirmation is reopened after authorization, under its '
      'bound',
      () async {
        final b = backend();
        final ready = await downloaded(b) as UpdateReadyToInstall;
        host.continueResult = true;
        final before = requests.length;
        final waiting = UpdateAwaitingUserAction(ready.assessment);
        expect(await b.continueInstallation(waiting), same(waiting));
        expect(requests.length, before + 1);
        expect(host.continueBounds, [
          DateTime.utc(2027).millisecondsSinceEpoch,
        ]);
        expect(host.abandons, 0);
      },
    );

    clockedTest(
      'a withdrawn target abandons the session instead of reopening it',
      () async {
        final b = backend();
        final ready = await downloaded(b) as UpdateReadyToInstall;
        host.continueResult = true;
        await publish(revision: 2, releases: [releaseJson(sequence: 44)]);
        final state =
            await b.continueInstallation(
                  UpdateAwaitingUserAction(ready.assessment),
                )
                as UpdateFailed;
        expect(state.kind, UpdateFailureKind.targetWithdrawn);
        expect(state.returnTo, isNot(isA<UpdateReadyToInstall>()));
        expect(host.continueBounds, isEmpty);
        expect(host.abandons, 1);
        expect(await staged('apk').exists(), isFalse);
      },
    );

    clockedTest(
      'a lapsed authorization abandons the session and keeps the file',
      () async {
        final b = backend();
        final ready = await downloaded(b) as UpdateReadyToInstall;
        host.continueResult = true;
        offline = true;
        now = DateTime.utc(2027, 1, 5);
        final state =
            await b.continueInstallation(
                  UpdateAwaitingUserAction(ready.assessment),
                )
                as UpdateFailed;
        expect(state.kind, UpdateFailureKind.authorizationStale);
        expect(host.continueBounds, isEmpty);
        expect(host.abandons, 1);
        expect(await staged('apk').exists(), isTrue);
      },
    );

    clockedTest(
      'a lost confirmation gets one new session under the same authorization',
      () async {
        final b = backend();
        final ready = await downloaded(b) as UpdateReadyToInstall;
        host.continueResult = false;
        final before = requests.length;
        final state = await b.continueInstallation(
          UpdateAwaitingUserAction(ready.assessment),
        );
        expect(state, isA<UpdateInstalling>());
        expect(host.abandons, 1);
        expect(
          host.commits.single.authorizedUntilEpochMs,
          host.continueBounds.single,
        );
        // Authorized once, not again for the replacement session.
        expect(requests.length, before + 1);
      },
    );

    clockedTest(
      'on resume, a waiting session whose target a newer catalogue dropped '
      'is abandoned',
      () async {
        final b = backend();
        final ready = await downloaded(b) as UpdateReadyToInstall;
        await publish(revision: 2, releases: [releaseJson(sequence: 44)]);
        await b.check(cancel: CancelToken());
        host.reconciliation = InstallerReconciliation(
          result: ReconcileResult.awaitingUserAction,
          ours: true,
        );
        final next = await b.onResume(
          UpdateAwaitingUserAction(ready.assessment),
        );
        expect(host.abandons, 1);
        expect(next, isNot(isA<UpdateAwaitingUserAction>()));
      },
    );
  });

  group('an abandonment that leaves the session keeps its reservation', () {
    InstallerReconciliation waitingSession() => InstallerReconciliation(
      result: ReconcileResult.awaitingUserAction,
      ours: true,
      expected: ExpectedArtifact(
        sha256: apkSha,
        byteLength: apkBytes.length,
        versionCode: 433,
        logicalReleaseSequence: 43,
        distribution: BuildDistribution.github,
        track: BuildTrack.stable,
        renderer: BuildRenderer.skia,
        abi: 'arm64-v8a',
        authorizedUntilEpochMs: 0,
      ),
    );

    setUp(() => host.abandonLeavesSession = true);

    clockedTest('Continue whose authorization lapsed', () async {
      final b = backend();
      final ready = await downloaded(b) as UpdateReadyToInstall;
      host.reconciliation = waitingSession();
      offline = true;
      now = DateTime.utc(2027, 1, 5);
      final state =
          await b.continueInstallation(
                UpdateAwaitingUserAction(ready.assessment),
              )
              as UpdateFailed;
      expect(state.kind, UpdateFailureKind.authorizationStale);
      expect(host.abandons, 1);
      // Never "ready to install" over a session Android still holds.
      expect(state.returnTo, isA<UpdateInstalling>());
      expect(state.returnTo.assessment, ready.assessment);
      expect(host.continueBounds, isEmpty);
    });

    clockedTest('Continue whose target was withdrawn', () async {
      final b = backend();
      final ready = await downloaded(b) as UpdateReadyToInstall;
      host.reconciliation = waitingSession();
      await publish(revision: 2, releases: [releaseJson(sequence: 44)]);
      final state =
          await b.continueInstallation(
                UpdateAwaitingUserAction(ready.assessment),
              )
              as UpdateFailed;
      expect(state.kind, UpdateFailureKind.targetWithdrawn);
      expect(state.returnTo, isA<UpdateInstalling>());
    });

    clockedTest(
      'a lost confirmation: no second session beside the first',
      () async {
        final b = backend();
        final ready = await downloaded(b) as UpdateReadyToInstall;
        host.reconciliation = waitingSession();
        host.continueResult = false;
        final state = await b.continueInstallation(
          UpdateAwaitingUserAction(ready.assessment),
        );
        expect(state, isA<UpdateInstalling>());
        expect(host.commits, isEmpty);
      },
    );

    clockedTest('on resume, a waiting session that lapsed', () async {
      final b = backend();
      final ready = await downloaded(b) as UpdateReadyToInstall;
      await publish(revision: 2, releases: [releaseJson(sequence: 44)]);
      await b.check(cancel: CancelToken());
      host.reconciliation = waitingSession();
      final next = await b.onResume(UpdateAwaitingUserAction(ready.assessment));
      expect(host.abandons, 1);
      expect(next, isA<UpdateInstalling>());
    });

    clockedTest('at start, a waiting session that lapsed', () async {
      await downloaded(backend());
      host.reconciliation = waitingSession();
      offline = true;
      now = DateTime.utc(2027, 1, 5);
      final outcome = await backend().recover();
      expect(host.abandons, 1);
      expect(outcome.state, isA<UpdateInstalling>());
    });
  });

  group('Download never starts on expired metadata (5.3)', () {
    /// Checks, lets the catalogue expire, publishes [next] and downloads.
    Future<UpdateState> downloadAfterExpiry(
      GithubUpdateBackend b, {
      required Map<String, Object?> next,
    }) async {
      final available = await b.check(cancel: CancelToken());
      now = DateTime.utc(2027, 1, 5); // past expiresAt + slack
      await publish(
        revision: 2,
        issuedAt: DateTime.utc(2027, 1, 4),
        releases: [next],
      );
      return b.prepare(
        available.assessment!,
        onProgress: (_) {},
        cancel: CancelToken(),
      );
    }

    clockedTest(
      'an expired catalogue is replaced before anything is asked of GitHub',
      () async {
        final b = backend();
        final state = await downloadAfterExpiry(b, next: realRelease(43));
        expect(state, isA<UpdateReadyToInstall>());
        // After the check's own fetch.
        final hosts = requests.skip(1).map((u) => u.host).toList();
        expect(hosts.first, 'updates.weblibre.eu');
        expect(hosts, contains('github.com'));
      },
    );

    clockedTest(
      'offline with an expired catalogue: fails, GitHub never asked',
      () async {
        final b = backend();
        final available = await b.check(cancel: CancelToken());
        now = DateTime.utc(2027, 1, 5);
        offline = true;
        await expectLater(
          b.prepare(
            available.assessment!,
            onProgress: (_) {},
            cancel: CancelToken(),
          ),
          throwsA(
            isA<UpdateFailure>().having(
              (f) => f.kind,
              'kind',
              UpdateFailureKind.network,
            ),
          ),
        );
        expect(requests.map((u) => u.host), isNot(contains('github.com')));
        expect(await staged('part').exists(), isFalse);
      },
    );

    clockedTest(
      'a fresh catalogue without the target: withdrawn, nothing downloaded',
      () async {
        final b = backend();
        final state =
            await downloadAfterExpiry(b, next: releaseJson(sequence: 44))
                as UpdateFailed;
        expect(state.kind, UpdateFailureKind.targetWithdrawn);
        expect(state.operation, UpdateOperation.download);
        expect(requests.map((u) => u.host), isNot(contains('github.com')));
      },
    );
  });

  group('a failed download reports what is on disk now', () {
    clockedTest('verification deleted the partial file', () async {
      final b = backend();
      final available = await b.check(cancel: CancelToken());
      host.verifyResult = false;
      final state =
          await b.prepare(
                available.assessment!,
                onProgress: (_) {},
                cancel: CancelToken(),
              )
              as UpdateFailed;
      expect(state.operation, UpdateOperation.download);
      expect(await staged('part').exists(), isFalse);
      expect(state.returnTo, UpdateAvailable(available.assessment!));
    });

    clockedTest('a broken connection kept what it received', () async {
      final half = apkBytes.length ~/ 2;
      final broken = MockClient.streaming((request, _) async {
        if (request.url.host == 'updates.weblibre.eu') {
          return http.StreamedResponse(
            Stream.value(currentEnvelope),
            200,
            contentLength: currentEnvelope.length,
          );
        }
        return http.StreamedResponse(
          Stream.fromIterable([
            apkBytes.sublist(0, half),
          ]).followedBy(const SocketException('connection reset')),
          200,
          contentLength: apkBytes.length,
        );
      });
      final b = backend(httpClient: broken);
      final available = await b.check(cancel: CancelToken());
      final state =
          await b.prepare(
                available.assessment!,
                onProgress: (_) {},
                cancel: CancelToken(),
              )
              as UpdateFailed;
      expect(state.kind, UpdateFailureKind.network);
      expect(
        state.returnTo,
        UpdateAvailable(available.assessment!, partialBytes: half),
      );
    });
  });
}

extension<T> on Stream<T> {
  /// This stream, then [error].
  Stream<T> followedBy(Object error) async* {
    yield* this;
    throw error;
  }
}
