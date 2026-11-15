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
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/app_update/data/native/app_update_host.dart';
import 'package:weblibre/features/app_update/data/play/play_update_backend.dart';
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';
import 'package:weblibre/features/app_update/domain/entities/update_state.dart';
import 'package:weblibre/features/app_update/domain/repositories/release_metadata_repository.dart';
import 'package:weblibre/features/app_update/domain/services/update_backend.dart';

import '../fixtures.dart';
import 'fake_host.dart';

class FixedMetadata implements ReleaseMetadataRepository {
  FixedMetadata(this.catalogue);

  final ReleaseCatalogue? catalogue;
  int fetches = 0;
  bool damaged = false;
  int resets = 0;

  @override
  AcceptedCatalogue? get accepted => null;

  @override
  Future<AcceptedCatalogue> fetchAndAccept({CancelToken? cancel}) {
    fetches++;
    return Future.error(UpdateFailure(UpdateFailureKind.network));
  }

  @override
  Future<void> open() async {}

  @override
  bool get recoveryRequired => damaged;

  @override
  Future<void> reset() async {
    resets++;
    damaged = false;
  }

  @override
  ReleaseCatalogue? usable() => catalogue;
}

void main() {
  final installed = installedBuild(distribution: Distribution.play);
  late FakeHost host;

  setUp(() {
    host = FakeHost(
      installed: installed,
      stagingDir: Directory.systemTemp.path,
      stateDir: Directory.systemTemp.path,
    );
  });

  PlayUpdateBackend backend(ReleaseCatalogue? catalogue) => PlayUpdateBackend(
    host: host,
    installed: installed,
    metadata: FixedMetadata(catalogue),
  );

  PlayUpdateInfo available(
    int code, {
    PlayInstallStatus status = PlayInstallStatus.unknown,
  }) => PlayUpdateInfo(
    availability: PlayAvailability.available,
    installStatus: status,
    availableVersionCode: code,
  );

  test('damaged trust state never hides what Play offers; the reset '
      'clears it', () async {
    host.playInfo = available(43, status: PlayInstallStatus.downloaded);
    final metadata = FixedMetadata(null)..damaged = true;
    final b = PlayUpdateBackend(
      host: host,
      installed: installed,
      metadata: metadata,
    );
    expect(b.canResetTrust, isTrue);

    expect((await b.recover()).state, isA<UpdateReadyToInstall>());
    expect(await b.check(cancel: CancelToken()), isA<UpdateReadyToInstall>());
    expect(b.trustDamaged, isTrue);

    await b.resetTrust();
    expect(metadata.resets, 1);
    expect(b.trustDamaged, isFalse);
  });

  test('without metadata there is no trust state to reset', () {
    final b = PlayUpdateBackend(
      host: host,
      installed: installed,
      metadata: null,
    );
    expect(b.canResetTrust, isFalse);
  });

  test('an exact version-code match is described from the catalogue', () async {
    host.playInfo = available(43);
    final state = await backend(
      catalogue([releaseJson(sequence: 43)]),
    ).check(cancel: CancelToken());
    final assessment = state.assessment!;
    expect(assessment.target, isNotNull);
    expect(assessment.appVersion, '0.43.0');
  });

  test('a download that finished during the description fetch shows as '
      'ready, not as the progress Play reported before it', () async {
    host.playInfoQueue.add(
      available(43, status: PlayInstallStatus.downloading),
    );
    host.playInfo = available(43, status: PlayInstallStatus.downloaded);
    final state = await backend(
      catalogue([releaseJson(sequence: 43)]),
    ).check(cancel: CancelToken());
    expect(state, isA<UpdateReadyToInstall>());
  });

  test('a second answer without evidence keeps the first', () async {
    host.playInfoQueue.add(
      available(43, status: PlayInstallStatus.downloading),
    );
    host.playInfo = PlayUpdateInfo(
      availability: PlayAvailability.error,
      installStatus: PlayInstallStatus.unknown,
      errorCode: -100,
    );
    final state = await backend(
      catalogue([releaseJson(sequence: 43)]),
    ).check(cancel: CancelToken());
    expect(state, isA<UpdateDownloading>());
  });

  test('no matching description keeps the update eligible', () async {
    host.playInfo = available(44);
    final state = await backend(
      catalogue([releaseJson(sequence: 43)]),
    ).check(cancel: CancelToken());
    expect(state, isA<UpdateAvailable>());
    expect(state.assessment!.target, isNull);
    expect(state.assessment!.componentChanges, isNull);
  });

  test('without any catalogue the update is still offered', () async {
    host.playInfo = available(44);
    final state = await backend(null).check(cancel: CancelToken());
    expect(state, isA<UpdateAvailable>());
  });

  test('UPDATE_NOT_AVAILABLE is upToDate', () async {
    final state = await backend(null).check(cancel: CancelToken());
    expect(state, isA<UpdateUpToDate>());
  });

  test('Play errors map per 8.7', () async {
    for (final (failure, kind) in [
      (PlayFailure.notOwned, UpdateFailureKind.playNotOwned),
      (PlayFailure.unavailable, UpdateFailureKind.playUnavailable),
      (PlayFailure.other, UpdateFailureKind.playError),
      (null, UpdateFailureKind.playError),
    ]) {
      host.playInfo = PlayUpdateInfo(
        availability: PlayAvailability.error,
        installStatus: PlayInstallStatus.unknown,
        failure: failure,
        errorCode: -1,
      );
      await expectLater(
        backend(null).check(cancel: CancelToken()),
        throwsA(isA<UpdateFailure>().having((f) => f.kind, 'kind', kind)),
        reason: '$failure',
      );
    }
  });

  test('flexible flow: start, download events, ready, complete', () async {
    host.playInfo = available(43);
    final b = backend(null);
    final offered = await b.check(cancel: CancelToken());
    final downloading = await b.prepare(
      offered.assessment!,
      onProgress: (_) {},
      cancel: CancelToken(),
    );
    expect(host.playStarts, 1);
    expect(downloading, isA<UpdateDownloading>());

    final reducers = <UpdateState? Function(UpdateState)>[];
    final sub = b.events.listen((event) => reducers.add(event.reduce));
    host.playController.add(
      PlayInstallStateEvent(
        installStatus: PlayInstallStatus.downloaded,
        bytesDownloaded: 9,
        totalBytesToDownload: 9,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    final ready = reducers.single(downloading)!;
    expect(ready, isA<UpdateReadyToInstall>());

    expect(
      await b.requestInstallation(ready.assessment!),
      isA<UpdateInstalling>(),
    );
    expect(host.playCompletes, 1);
    await sub.cancel();
  });

  group('on resume, the state follows what Play offers now', () {
    test('a newer version is described for that version', () async {
      host.playInfo = available(43);
      final b = backend(
        catalogue([releaseJson(sequence: 44), releaseJson(sequence: 43)]),
      );
      final offered = await b.check(cancel: CancelToken());
      expect(offered.assessment!.versionCode, 43);

      host.playInfo = available(44);
      final next = (await b.onResume(offered))!;
      expect(next, isA<UpdateAvailable>());
      expect(next.assessment!.versionCode, 44);
      expect(next.assessment!.appVersion, '0.44.0');
    });

    test('the same version keeps its assessment', () async {
      host.playInfo = available(43);
      final b = backend(catalogue([releaseJson(sequence: 43)]));
      final offered = await b.check(cancel: CancelToken());
      host.playInfo = available(43, status: PlayInstallStatus.downloaded);
      final next = (await b.onResume(offered))!;
      expect(next, UpdateReadyToInstall(offered.assessment!));
    });

    test('nothing newer any more is up to date', () async {
      host.playInfo = available(43);
      final b = backend(null);
      final offered = await b.check(cancel: CancelToken());
      host.playInfo = PlayUpdateInfo(
        availability: PlayAvailability.notAvailable,
        installStatus: PlayInstallStatus.unknown,
      );
      expect(await b.onResume(offered), UpdateUpToDate());
    });

    test('no answer from Play changes nothing', () async {
      host.playInfo = available(43);
      final b = backend(null);
      final offered = await b.check(cancel: CancelToken());
      host.playInfo = PlayUpdateInfo(
        availability: PlayAvailability.unknown,
        installStatus: PlayInstallStatus.unknown,
        availableVersionCode: 0,
      );
      expect(await b.onResume(offered), isNull);
    });
  });

  test('a finished flexible download is reconciled at start', () async {
    host.playInfo = available(43, status: PlayInstallStatus.downloaded);
    final outcome = await backend(null).recover();
    expect(outcome.state, isA<UpdateReadyToInstall>());
  });

  group("Play's consent sheet decides what Download leads to", () {
    Future<UpdateState> download() async {
      host.playInfo = available(43);
      final b = backend(null);
      final offered = await b.check(cancel: CancelToken());
      return b.prepare(
        offered.assessment!,
        onProgress: (_) {},
        cancel: CancelToken(),
      );
    }

    test('a finished download reported before the answer is kept', () async {
      host.playEventsDuringFlow.add(
        PlayInstallStateEvent(
          installStatus: PlayInstallStatus.downloaded,
          bytesDownloaded: 9,
          totalBytesToDownload: 9,
        ),
      );
      expect(await download(), isA<UpdateReadyToInstall>());
    });

    test('a failure reported before the answer is kept', () async {
      host.playEventsDuringFlow.add(
        PlayInstallStateEvent(
          installStatus: PlayInstallStatus.failed,
          bytesDownloaded: 0,
          totalBytesToDownload: 0,
          failure: PlayFailure.notOwned,
          errorCode: -10,
        ),
      );
      expect(
        await download(),
        isA<UpdateFailed>().having(
          (s) => s.failure.kind,
          'kind',
          UpdateFailureKind.playNotOwned,
        ),
      );
    });

    test('progress reported before the answer is kept', () async {
      host.playEventsDuringFlow.add(
        PlayInstallStateEvent(
          installStatus: PlayInstallStatus.downloading,
          bytesDownloaded: 4,
          totalBytesToDownload: 9,
        ),
      );
      expect(
        await download(),
        isA<UpdateDownloading>().having((s) => s.received, 'received', 4),
      );
    });

    test('accepted with nothing reported yet: just started', () async {
      expect(
        await download(),
        isA<UpdateDownloading>().having((s) => s.received, 'received', 0),
      );
    });

    test('declined: back to available, nothing failed', () async {
      host.playFlowResult = PlayFlowResult.declined;
      final state = await download();
      expect(state, isA<UpdateAvailable>());
      expect(state.assessment!.versionCode, 43);
    });

    test('failed: a Play error that retries the download', () async {
      host.playFlowResult = PlayFlowResult.failed;
      final state = await download();
      expect(
        state,
        isA<UpdateFailed>()
            .having((s) => s.failure.kind, 'kind', UpdateFailureKind.playError)
            .having((s) => s.operation, 'operation', UpdateOperation.download)
            .having((s) => s.returnTo, 'returnTo', isA<UpdateAvailable>()),
      );
    });
  });

  test('a download Play reports cancelled returns to available', () async {
    host.playInfo = available(43);
    final b = backend(null);
    final offered = await b.check(cancel: CancelToken());
    final reducers = <UpdateState? Function(UpdateState)>[];
    final sub = b.events.listen((event) => reducers.add(event.reduce));
    host.playController.add(
      PlayInstallStateEvent(
        installStatus: PlayInstallStatus.canceled,
        bytesDownloaded: 0,
        totalBytesToDownload: 0,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(
      reducers.single(UpdateDownloading(offered.assessment!, received: 0)),
      isA<UpdateAvailable>(),
    );
    await sub.cancel();
  });
}
