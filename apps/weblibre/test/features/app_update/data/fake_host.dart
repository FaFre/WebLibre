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

import 'package:path/path.dart' as p;
import 'package:weblibre/features/app_update/data/native/app_update_host.dart';
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';
import 'package:weblibre/features/app_update/domain/services/staged_file_policy.dart';

/// The native updater, in memory. Verification checks what native would
/// check that Dart can see: the digest-derived file names.
class FakeHost implements AppUpdateHost {
  FakeHost({
    required this.installed,
    required this.stagingDir,
    required this.stateDir,
  });

  final InstalledBuildInfo installed;
  final String stagingDir;
  final String stateDir;

  bool canInstall = true;
  bool verifyResult = true;
  NativeFailure? commitFailure;
  InstallerReconciliation reconciliation = InstallerReconciliation(
    result: ReconcileResult.none,
    ours: false,
  );

  /// What native answers for a committed session when a status callback
  /// arrived before `commit()` returned.
  InstallCommitResult? committedResult;
  int reconciles = 0;

  /// `(sessionId, nonce)` of every acknowledged failure event.
  final acknowledged = <(int, String)>[];
  final commits = <ExpectedArtifact>[];
  int abandons = 0;
  bool continueResult = false;
  final continueBounds = <int>[];
  PlayFlowResult playFlowResult = PlayFlowResult.accepted;
  PlayUpdateInfo playInfo = PlayUpdateInfo(
    availability: PlayAvailability.notAvailable,
    installStatus: PlayInstallStatus.unknown,
  );
  int playStarts = 0;
  int playCompletes = 0;

  final installerController =
      StreamController<InstallerStatusEvent>.broadcast();
  final playController = StreamController<PlayInstallStateEvent>.broadcast();

  @override
  Future<InstalledBuildInfo> getInstalledBuildInfo() async => installed;

  @override
  Future<UpdateDirs> getDirs() async =>
      UpdateDirs(stateDir: stateDir, stagingDir: stagingDir);

  @override
  Future<int> usableStagingBytes() async => 1 << 34;

  @override
  Future<bool> canRequestPackageInstalls() async => canInstall;

  @override
  Future<void> openInstallPermissionSettings() async {}

  @override
  Future<ApkVerificationResult> verifyAndPromote(
    ExpectedArtifact expected,
  ) async {
    final part = File(p.join(stagingDir, StagedFile.partName(expected.sha256)));
    if (!verifyResult || !await part.exists()) {
      if (await part.exists()) await part.delete();
      return ApkVerificationResult(
        verified: false,
        failure: NativeFailure.apkInvalid,
      );
    }
    await part.rename(p.join(stagingDir, StagedFile.apkName(expected.sha256)));
    return ApkVerificationResult(verified: true);
  }

  @override
  Future<InstallCommitResult> commitInstall(ExpectedArtifact expected) async {
    commits.add(expected);
    if (commitFailure != null) {
      return InstallCommitResult(committed: false, failure: commitFailure);
    }
    if (DateTime.now().millisecondsSinceEpoch >
        expected.authorizedUntilEpochMs) {
      return InstallCommitResult(
        committed: false,
        failure: NativeFailure.authorizationStale,
      );
    }
    return committedResult ??
        InstallCommitResult(
          committed: true,
          phase: InstallerPhase.commitRequested,
        );
  }

  @override
  Future<bool> continuePendingUserAction(int authorizedUntilEpochMs) async {
    continueBounds.add(authorizedUntilEpochMs);
    // Like native: never past the bound, on the raw clock.
    if (DateTime.now().millisecondsSinceEpoch > authorizedUntilEpochMs) {
      return false;
    }
    return continueResult;
  }

  /// Abandoning fails silently and the session stays listed: native then
  /// reports it as in progress (`confirmAbandoned`).
  bool abandonLeavesSession = false;

  @override
  Future<void> abandonInstall() async {
    abandons++;
    reconciliation = abandonLeavesSession
        ? InstallerReconciliation(
            result: ReconcileResult.inProgress,
            ours: false,
            expected: reconciliation.expected,
          )
        : InstallerReconciliation(result: ReconcileResult.none, ours: false);
  }

  @override
  Future<InstallerReconciliation> reconcileInstaller() async {
    reconciles++;
    final result = reconciliation;
    // Like native: a terminal outcome is retired once it is reported.
    if (result.result == ReconcileResult.failed ||
        result.result == ReconcileResult.succeeded) {
      reconciliation = InstallerReconciliation(
        result: ReconcileResult.none,
        ours: false,
      );
    }
    return result;
  }

  @override
  Future<void> acknowledgeInstallerFailure(int sessionId, String nonce) async =>
      acknowledged.add((sessionId, nonce));

  /// Answers [playCheck] before [playInfo] once each, first to last: Play's
  /// status moving between two calls.
  final playInfoQueue = <PlayUpdateInfo>[];

  @override
  Future<PlayUpdateInfo> playCheck() async =>
      playInfoQueue.isNotEmpty ? playInfoQueue.removeAt(0) : playInfo;

  /// Sent while the consent sheet is still open, before its answer.
  final playEventsDuringFlow = <PlayInstallStateEvent>[];

  @override
  Future<PlayFlowResult> playStartFlexible() async {
    playStarts++;
    playEventsDuringFlow.forEach(playController.add);
    await Future<void>.delayed(Duration.zero);
    return playFlowResult;
  }

  @override
  Future<void> playCompleteFlexible() async => playCompletes++;

  @override
  Stream<InstallerStatusEvent> get installerEvents =>
      installerController.stream;

  @override
  Stream<PlayInstallStateEvent> get playEvents => playController.stream;
}
