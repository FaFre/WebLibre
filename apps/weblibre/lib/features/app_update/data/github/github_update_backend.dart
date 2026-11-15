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
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/app_update/data/github/apk_download_service.dart';
import 'package:weblibre/features/app_update/data/metadata/freshness_guard.dart';
import 'package:weblibre/features/app_update/data/native/app_update_host.dart';
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/entities/update_assessment.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';
import 'package:weblibre/features/app_update/domain/entities/update_state.dart';
import 'package:weblibre/features/app_update/domain/repositories/release_metadata_repository.dart';
import 'package:weblibre/features/app_update/domain/services/artifact_selector.dart';
import 'package:weblibre/features/app_update/domain/services/staged_file_policy.dart';
import 'package:weblibre/features/app_update/domain/services/update_assessment_service.dart';
import 'package:weblibre/features/app_update/domain/services/update_backend.dart';

/// The GitHub self-updater (plan 7).
///
/// The signed catalogue is the only authority. What is in progress is read
/// off the staged files (named by digest) and the native installer journal,
/// never stored (D19), so the state after a restart is derived from the same
/// inputs a check would use.
class GithubUpdateBackend implements UpdateBackend {
  GithubUpdateBackend({
    required this.host,
    required this.installed,
    required this.stagingDir,
    required this.metadata,
    required this.download,
    this.flushPendingWrites,
  });

  final AppUpdateHost host;
  final InstalledBuildInfo installed;
  final String stagingDir;
  final ReleaseMetadataRepository metadata;
  final ApkDownloadService download;

  /// Runs immediately before the installer can end the process: before every
  /// session commit and before the system confirmation is started again
  /// (7.5). Tab state is written debounced, so anything changed after an
  /// earlier flush would be lost.
  final Future<void> Function()? flushPendingWrites;

  static const _selector = ArtifactSelector();
  static const _assessments = UpdateAssessmentService();
  static const _stagedPolicy = StagedFilePolicy();

  /// Extra headroom for the installer's own copy (7.3).
  static const _stagingHeadroom = 64 * 1024 * 1024;

  @override
  bool get canResetTrust => true;

  /// Damage blocks download and installation, so it is a `stateCorrupt`
  /// failure, never a notice beside the state.
  @override
  bool get trustDamaged => false;

  @override
  Future<void> resetTrust() => metadata.reset();

  /// What Android reports about the installer decides first; [_derive]
  /// covers the rest.
  @override
  Future<RecoveryOutcome> recover() async =>
      await _recoverFrom(await host.reconcileInstaller());

  /// Native retires a terminal outcome once it reports it, so a
  /// reconciliation is used once and never asked for again.
  Future<RecoveryOutcome> _recoverFrom(
    InstallerReconciliation reconciliation,
  ) async {
    await metadata.open();

    String? updatedTo;
    if (reconciliation.result == ReconcileResult.succeeded) {
      final sha = reconciliation.expected?.sha256;
      if (sha != null) await _deleteStaged(sha);
      if (reconciliation.ours) updatedTo = installed.versionName;
    }
    // Before deriving, as a check does: the state must describe the files
    // that are left, never one cleanup is about to delete.
    await _cleanStaged();

    final expected = reconciliation.expected;
    final assessment = expected == null
        ? null
        : _assessmentForSha(expected.sha256);

    final state = switch (reconciliation.result) {
      ReconcileResult.inProgress => UpdateInstalling(
        assessment,
        foundAfterRestart: true,
      ),
      ReconcileResult.awaitingUserAction => await _authorizedWaiting(
        UpdateAwaitingUserAction(assessment),
      ),
      ReconcileResult.failed => await _recoveredFailure(reconciliation),
      ReconcileResult.none || ReconcileResult.succeeded => await _derive(),
    };

    return RecoveryOutcome(state, updatedTo: updatedTo);
  }

  /// An installation that ended without succeeding while nobody listened.
  /// Treated as the live event would have been: a file Android rejected is
  /// deleted before the resting state is derived, so Retry never commits it
  /// again.
  Future<UpdateFailed> _recoveredFailure(
    InstallerReconciliation reconciliation,
  ) async {
    final kind = reconciliation.failure.kind;
    final sha = reconciliation.expected?.sha256;
    if (kind == UpdateFailureKind.apkInvalid && sha != null) {
      await _deleteStaged(sha);
    }
    return UpdateFailed(
      UpdateFailure(kind, reconciliation.detail),
      returnTo: await _derive(),
      operation: UpdateOperation.install,
    );
  }

  /// A waiting session is abandoned as soon as its authorization lapses
  /// (7.5): on start, on foreground and when a newer catalogue is accepted.
  /// Lapsed means the accepted catalogue is expired or no longer has the
  /// session's target.
  ///
  /// The resting state is derived only when the session is abandoned.
  Future<UpdateState> _authorizedWaiting(
    UpdateAwaitingUserAction waiting,
  ) async {
    final assessment = waiting.assessment;
    final catalogue = metadata.usable();
    if (assessment != null &&
        catalogue != null &&
        _authorizes(catalogue, assessment)) {
      return waiting;
    }
    logger.i('Abandoning an install session whose authorization lapsed');
    return await _abandonWaiting(waiting) ?? await _derive();
  }

  /// Abandons the waiting session, then asks Android what is left: an
  /// abandonment can fail and leave the session live, and its reservation
  /// must then stay in the state (7.6). Null once the session is gone;
  /// otherwise the state its reservation holds. Native reports a session that
  /// survived its abandonment as in progress. One still waiting is kept as it
  /// is, never abandoned again in the same pass.
  Future<UpdateState?> _abandonWaiting(UpdateAwaitingUserAction waiting) async {
    await host.abandonInstall();
    final after = await host.reconcileInstaller();
    if (after.result
        case ReconcileResult.inProgress || ReconcileResult.awaitingUserAction) {
      logger.w('An install session survived its abandonment');
    }
    return switch (after.result) {
      ReconcileResult.none => null,
      ReconcileResult.awaitingUserAction => waiting,
      ReconcileResult.inProgress ||
      ReconcileResult.failed ||
      ReconcileResult.succeeded => (await _recoverFrom(after)).state,
    };
  }

  /// Everything that isn't Android's, derived from the accepted catalogue and
  /// the staged files.
  Future<UpdateState> _derive() async {
    if (metadata.recoveryRequired) {
      return UpdateFailed(
        UpdateFailure(UpdateFailureKind.stateCorrupt),
        returnTo: UpdateIdle(),
        operation: UpdateOperation.check,
      );
    }
    final catalogue = metadata.usable();
    if (catalogue == null) return UpdateIdle();

    return switch (_selector.selectGithub(catalogue, installed)) {
      TargetSelected(:final release, :final target) => await _stagedState(
        _assess(catalogue, release, target),
      ),
      NothingNewer() => UpdateUpToDate(),
      NoCompatibleTarget() => UpdateFailed(
        UpdateFailure(UpdateFailureKind.noCompatibleTarget),
        returnTo: UpdateUpToDate(),
        operation: UpdateOperation.check,
      ),
    };
  }

  UpdateAssessment? _assessmentForSha(String sha256) {
    final catalogue = metadata.accepted?.catalogue;
    if (catalogue == null) return null;
    return switch (catalogue.allTargets.firstWhereOrNull(
      (entry) => entry.$2.artifact?.sha256 == sha256,
    )) {
      (final release, final target) => _assess(catalogue, release, target),
      null => null,
    };
  }

  UpdateAssessment _assess(
    ReleaseCatalogue catalogue,
    ReleaseEntry release,
    UpdateTarget target,
  ) => _assessments.assess(
    catalogue: catalogue,
    release: release,
    target: target,
    installed: installed,
  );

  /// A cheap look at the staged file: it was fully verified when it was
  /// promoted (7.4), and `commitInstall` verifies it again, hashing the bytes
  /// it copies into the session. Hashing a 100+ MB file on every start and
  /// every check would buy nothing on top of that.
  Future<UpdateState> _stagedState(UpdateAssessment assessment) async {
    final artifact = assessment.artifact!;
    final apk = File(p.join(stagingDir, StagedFile.apkName(artifact.sha256)));
    if (await apk.exists()) {
      if (await apk.length() == artifact.byteLength) {
        return UpdateReadyToInstall(assessment);
      }
      logger.w('Staged update has the wrong length; deleting it');
      await _deleteStaged(artifact.sha256);
      return UpdateAvailable(assessment);
    }
    final partial = await download.partialLength(artifact.sha256);
    return UpdateAvailable(assessment, partialBytes: partial);
  }

  @override
  Future<UpdateState> check({required CancelToken cancel}) async {
    final accepted = await metadata.fetchAndAccept(cancel: cancel);
    await _cleanStaged();

    return switch (_selector.selectGithub(accepted.catalogue, installed)) {
      TargetSelected(:final release, :final target) => await _stagedState(
        _assess(accepted.catalogue, release, target),
      ),
      NothingNewer() => UpdateUpToDate(),
      NoCompatibleTarget() => throw UpdateFailure(
        UpdateFailureKind.noCompatibleTarget,
      ),
    };
  }

  @override
  Future<UpdateState> prepare(
    UpdateAssessment assessment, {
    required void Function(UpdateState progress) onProgress,
    required CancelToken cancel,
  }) async {
    final artifact = assessment.artifact;
    if (artifact == null) {
      throw UpdateFailure(UpdateFailureKind.noCompatibleTarget);
    }

    // Never on expired metadata (5.3): the assessment can outlive the
    // catalogue it came from. An expired one is replaced first, from the
    // catalogue host only; a failure there fails the download, and Retry
    // fetches again.
    await metadata.open();
    var catalogue = metadata.usable();
    if (catalogue == null) {
      catalogue = (await metadata.fetchAndAccept(cancel: cancel)).catalogue;
      await _cleanStaged();
    }
    if (!_authorizes(catalogue, assessment)) {
      await _deleteStaged(artifact.sha256);
      return UpdateFailed(
        UpdateFailure(UpdateFailureKind.targetWithdrawn),
        returnTo: await _derive(),
        operation: UpdateOperation.download,
      );
    }

    final usable = await host.usableStagingBytes();
    final partial = await download.partialLength(artifact.sha256);
    if (usable + partial < 2 * artifact.byteLength + _stagingHeadroom) {
      throw UpdateFailure(UpdateFailureKind.insufficientStorage);
    }

    onProgress(
      UpdateDownloading(
        assessment,
        received: partial,
        total: artifact.byteLength,
      ),
    );
    // What is on disk now, never what was there before this download: it
    // grew, or verification deleted it.
    Future<UpdateAvailable> available() async => UpdateAvailable(
      assessment,
      partialBytes: await download.partialLength(artifact.sha256),
    );

    try {
      await download.download(
        artifact,
        cancel: cancel,
        onProgress: (received, total) => onProgress(
          UpdateDownloading(assessment, received: received, total: total),
        ),
      );
    } on OperationCancelled {
      return await available();
    } on UpdateFailure catch (failure) {
      return UpdateFailed(
        failure,
        returnTo: await available(),
        operation: UpdateOperation.download,
      );
    }

    onProgress(UpdateVerifying(assessment));
    final result = await host.verifyAndPromote(
      // Verification is not authorization: native reads no bound here, and
      // this one could never commit.
      _expected(assessment, authorizedUntil: _neverAuthorized),
    );
    if (!result.verified) {
      return UpdateFailed(
        UpdateFailure(result.failure.kind, result.detail),
        returnTo: await available(),
        operation: UpdateOperation.download,
      );
    }
    return UpdateReadyToInstall(assessment);
  }

  static final _neverAuthorized = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );

  @override
  Future<UpdateState> requestInstallation(UpdateAssessment assessment) async {
    final DateTime authorizedUntil;
    try {
      authorizedUntil = await authorize(assessment);
    } on UpdateFailure catch (failure) {
      if (failure.kind != UpdateFailureKind.targetWithdrawn) rethrow;
      // Its staged file is gone: return to what the catalogue that withdrew
      // it offers now, never to "ready to install".
      return UpdateFailed(
        failure,
        returnTo: await _derive(),
        operation: UpdateOperation.install,
      );
    }

    return await _commit(assessment, authorizedUntil);
  }

  /// A new session for [assessment], under the bound [authorize] just
  /// returned.
  Future<UpdateState> _commit(
    UpdateAssessment assessment,
    DateTime authorizedUntil,
  ) async {
    if (!await host.canRequestPackageInstalls()) {
      return UpdateAwaitingPermission(assessment);
    }

    await flushPendingWrites?.call();
    final result = await host.commitInstall(
      _expected(assessment, authorizedUntil: authorizedUntil),
    );
    if (result.committed) {
      // Native answers with what the journal holds by now, a status that
      // arrived before commit returned included. A failure shown from this
      // answer is acknowledged here: its event may never reach a listener,
      // and a restart must not report it again.
      if (result case InstallCommitResult(
        phase: InstallerPhase.failed,
        :final sessionId?,
        :final nonce?,
      )) {
        await _acknowledgeFailure(sessionId, nonce);
      }
      return switch (result.phase) {
        InstallerPhase.pendingUserAction => UpdateAwaitingUserAction(
          assessment,
        ),
        InstallerPhase.failed => _installFailed(
          assessment,
          result.failure,
          result.detail,
        ),
        _ => UpdateInstalling(assessment),
      };
    }

    final kind = result.failure;
    if (kind == NativeFailure.reservationActive) return (await recover()).state;
    if (kind == NativeFailure.installPermissionDenied) {
      return UpdateAwaitingPermission(assessment);
    }
    final failure = UpdateFailure(kind.kind, result.detail);
    // Native deleted a file that failed verification (6.3).
    final fileGone = switch (failure.kind) {
      UpdateFailureKind.downloadMismatch ||
      UpdateFailureKind.apkInvalid ||
      UpdateFailureKind.apkIdentityMismatch ||
      UpdateFailureKind.signerUntrusted => true,
      _ => false,
    };
    return UpdateFailed(
      failure,
      returnTo: fileGone
          ? UpdateAvailable(assessment)
          : UpdateReadyToInstall(assessment),
      operation: UpdateOperation.install,
    );
  }

  /// Authorization at commit (7.5). Runs immediately before every
  /// `commitInstall` and is never cached across an await that leaves the app.
  /// Returns the last moment the authorizing catalogue is usable, the bound
  /// native enforces at commit.
  Future<DateTime> authorize(UpdateAssessment assessment) async {
    await metadata.open();
    if (metadata.recoveryRequired) {
      throw UpdateFailure(UpdateFailureKind.stateCorrupt);
    }

    ReleaseCatalogue catalogue;
    try {
      catalogue = (await metadata.fetchAndAccept()).catalogue;
    } on UpdateFailure catch (failure) {
      if (!_fetchedCopyUnusable.contains(failure.kind)) rethrow;
      logger.i('Authorizing from the stored catalogue: $failure');

      // Not fetched, or a copy the guard rejected (a stale CDN edge serves
      // an older revision): the stored catalogue, the highest accepted
      // revision by construction, under the same complete guard. Anyone who
      // can serve a bad copy can also block the fetch, so trusting the
      // stored one here gives nothing away that being offline doesn't.
      final stored = metadata.usable();
      if (stored == null) {
        throw UpdateFailure(
          UpdateFailureKind.authorizationStale,
          failure.detail,
        );
      }
      catalogue = stored;
    }

    if (!_authorizes(catalogue, assessment)) {
      if (assessment.artifact case final artifact?) {
        await _deleteStaged(artifact.sha256);
      }
      throw UpdateFailure(UpdateFailureKind.targetWithdrawn);
    }
    return FreshnessGuard.usableUntil(catalogue);
  }

  /// Whether [catalogue] still offers [assessment]'s target to this
  /// installation: the same bytes and version code, still selectable. The one
  /// test for installing, downloading and a waiting session alike; freshness
  /// is the caller's.
  bool _authorizes(ReleaseCatalogue catalogue, UpdateAssessment assessment) {
    final target = catalogue.targetById(assessment.targetId)?.$2;
    final artifact = assessment.artifact;
    final authorized = target?.artifact;
    return target != null &&
        artifact != null &&
        authorized != null &&
        // The bytes, never where they came from: a catalogue that only moves
        // the download URL still authorizes the file staged under its digest
        // (6.3).
        authorized.sha256 == artifact.sha256 &&
        authorized.byteLength == artifact.byteLength &&
        target.versionCode == assessment.versionCode &&
        _selector.matchesGithub(target, installed);
  }

  /// Failures that say only that the fetched catalogue can't be used. Never
  /// `stateCorrupt`: then the stored one can't be trusted either.
  static const _fetchedCopyUnusable = {
    UpdateFailureKind.network,
    UpdateFailureKind.routingUnavailable,
    UpdateFailureKind.metadataInvalid,
    UpdateFailureKind.metadataClientTooOld,
    UpdateFailureKind.metadataExpired,
    UpdateFailureKind.metadataRollback,
    UpdateFailureKind.metadataPredatesBuild,
    UpdateFailureKind.clockSuspect,
  };

  @override
  Future<UpdateState> continueInstallation(UpdateState current) async {
    final assessment = current.assessment;
    if (assessment == null) {
      // Nothing to authorize it against: the session can't go on.
      await host.abandonInstall();
      return (await recover()).state;
    }

    final waiting = current is UpdateAwaitingUserAction
        ? current
        : UpdateAwaitingUserAction(assessment);

    // Reopening the confirmation hands the session to the installer, so it
    // is authorized now, as a commit is (7.5). One that no longer is gets
    // abandoned.
    final DateTime authorizedUntil;
    try {
      authorizedUntil = await authorize(assessment);
    } on UpdateFailure catch (failure) {
      final remaining = await _abandonWaiting(waiting);
      return UpdateFailed(
        failure,
        // A session that survived keeps its reservation. Once it is gone, a
        // withdrawn target's file is gone too; any other lapse keeps it.
        returnTo:
            remaining ??
            (failure.kind == UpdateFailureKind.targetWithdrawn
                ? await _derive()
                : UpdateReadyToInstall(assessment)),
        operation: UpdateOperation.install,
      );
    }

    // The confirmation may install right away, which ends the process.
    await flushPendingWrites?.call();
    if (await host.continuePendingUserAction(
      authorizedUntil.millisecondsSinceEpoch,
    )) {
      return current;
    }

    // The confirmation intent did not survive the process: abandon, then a
    // new session from the staged file, under the same authorization. Not
    // while the old one is still there.
    final remaining = await _abandonWaiting(waiting);
    if (remaining != null) return remaining;
    try {
      return await _commit(assessment, authorizedUntil);
    } catch (e) {
      // The waiting session is gone: fail back to the staged file, never to
      // the session the caller still holds.
      return UpdateFailed(
        UpdateFailure.from(e, UpdateFailureKind.installUnknown),
        returnTo: UpdateReadyToInstall(assessment),
        operation: UpdateOperation.install,
      );
    }
  }

  @override
  Future<UpdateState> cancelInstallation(UpdateState current) async {
    await host.abandonInstall();
    return (await recover()).state;
  }

  @override
  Future<UpdateState?> onResume(UpdateState current) async {
    // A session beneath a failed Continue or Cancel is still reconciled.
    final session = current.underlying;
    switch (session) {
      case UpdateAwaitingPermission(:final assessment):
        return await host.canRequestPackageInstalls()
            ? UpdateReadyToInstall(assessment)
            : null;
      case UpdateAwaitingUserAction() || UpdateInstalling():
        final reconciliation = await host.reconcileInstaller();
        if (reconciliation.result == ReconcileResult.awaitingUserAction &&
            session is UpdateAwaitingUserAction) {
          final next = await _authorizedWaiting(session);
          return identical(next, session) ? null : next;
        }
        if (reconciliation.result == ReconcileResult.inProgress) return null;
        // Not `recover()`: reconciling again would find the outcome this
        // one reported already retired.
        return (await _recoverFrom(reconciliation)).state;
      default:
        return null;
    }
  }

  @override
  late final Stream<UpdateEvent> events = host.installerEvents.map(
    (event) => UpdateEvent(
      (current) => _reduce(current, event),
      // Native keeps a failure for recovery until it is acknowledged: one
      // dropped here (no session tracked yet) is reported by reconciliation.
      onApplied: event.phase == InstallerPhase.failed
          ? () => host.acknowledgeInstallerFailure(event.sessionId, event.nonce)
          : null,
    ),
  );

  /// Unacknowledged, the failure is reported once more at the next start.
  Future<void> _acknowledgeFailure(int sessionId, String nonce) async {
    try {
      await host.acknowledgeInstallerFailure(sessionId, nonce);
    } catch (error, stackTrace) {
      logger.w(
        'Could not acknowledge an installer failure',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  UpdateState? _reduce(UpdateState current, InstallerStatusEvent event) {
    // Only a session this installation is tracking. Native correlates
    // session ID and nonce with the journal before it emits anything.
    // Also beneath a failure: a failed Continue or Cancel leaves the session
    // running.
    final assessment = current.assessment;
    final tracking = switch (current.underlying) {
      UpdateInstalling() ||
      UpdateAwaitingUserAction() ||
      UpdateReadyToInstall() => true,
      _ => false,
    };
    if (!tracking) return null;

    switch (event.phase) {
      case InstallerPhase.pendingUserAction:
        return UpdateAwaitingUserAction(assessment);
      case InstallerPhase.succeeded:
        return UpdateInstalling(assessment);
      case InstallerPhase.failed:
        return _installFailed(assessment, event.failure, event.message);
      default:
        return null;
    }
  }

  /// Android ended a committed session without installing it.
  UpdateFailed _installFailed(
    UpdateAssessment? assessment,
    NativeFailure? failure,
    String? message,
  ) {
    final kind = failure.kind;
    if (assessment == null) {
      return UpdateFailed(
        UpdateFailure(kind, message),
        returnTo: UpdateIdle(),
        operation: UpdateOperation.install,
      );
    }
    if (kind == UpdateFailureKind.apkInvalid) {
      unawaited(_deleteStaged(assessment.artifact!.sha256));
    }
    return UpdateFailed(
      UpdateFailure(kind, message),
      returnTo: kind == UpdateFailureKind.apkInvalid
          ? UpdateAvailable(assessment)
          : UpdateReadyToInstall(assessment),
      operation: UpdateOperation.install,
    );
  }

  Future<void> _cleanStaged() async {
    final dir = Directory(stagingDir);
    if (!await dir.exists()) return;
    final catalogue = metadata.usable();
    final now = clock.now();
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final sha256 = StagedFile.parseName(p.basename(entity.path));
      if (sha256 == null) continue;
      final verdict = _stagedPolicy.decide(
        StagedFile(sha256: sha256, modified: await entity.lastModified()),
        decidable: catalogue,
        installed: installed,
        now: now,
      );
      if (verdict == StagedFileVerdict.delete) {
        try {
          await entity.delete();
        } catch (_) {}
      }
    }
  }

  Future<void> _deleteStaged(String sha256) async {
    for (final name in [
      StagedFile.partName(sha256),
      StagedFile.apkName(sha256),
    ]) {
      final file = File(p.join(stagingDir, name));
      try {
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }

  /// [authorizedUntil] is the bound `authorize` returned, never a value kept
  /// with the assessment: it is the catalogue's `usableUntil`, which only
  /// authorization computes.
  ExpectedArtifact _expected(
    UpdateAssessment assessment, {
    required DateTime authorizedUntil,
  }) {
    final target = assessment.target!;
    final artifact = target.artifact!;
    return ExpectedArtifact(
      sha256: artifact.sha256,
      byteLength: artifact.byteLength,
      versionCode: target.versionCode,
      logicalReleaseSequence: assessment.logicalReleaseSequence!,
      distribution: BuildDistribution.github,
      track: target.track!.pigeon,
      renderer: target.renderer!.pigeon,
      abi: target.abi!,
      authorizedUntilEpochMs: authorizedUntil.millisecondsSinceEpoch,
    );
  }
}
