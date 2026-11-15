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

import 'package:flutter/services.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/app_update/data/native/app_update_host.dart';
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';
import 'package:weblibre/features/app_update/domain/entities/update_assessment.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';
import 'package:weblibre/features/app_update/domain/entities/update_state.dart';
import 'package:weblibre/features/app_update/domain/repositories/release_metadata_repository.dart';
import 'package:weblibre/features/app_update/domain/services/artifact_selector.dart';
import 'package:weblibre/features/app_update/domain/services/update_assessment_service.dart';
import 'package:weblibre/features/app_update/domain/services/update_backend.dart';

/// Google Play's in-app update, flexible flow only (plan 8.7).
///
/// Play owns download and install; the signed catalogue only *describes* the
/// version Play offers, matched by exact version code. Without a verified
/// description the update is still offered. There is no path from any Play
/// state into the GitHub backend, and this backend never contacts GitHub.
class PlayUpdateBackend implements UpdateBackend {
  PlayUpdateBackend({
    required this.host,
    required this.installed,
    required this.metadata,
    this.flushPendingWrites,
  });

  final AppUpdateHost host;
  final InstalledBuildInfo installed;

  /// Descriptive only. Null when the build has no metadata key compiled in.
  final ReleaseMetadataRepository? metadata;

  /// Runs immediately before Play restarts the app (7.5).
  final Future<void> Function()? flushPendingWrites;

  static const _selector = ArtifactSelector();
  static const _assessments = UpdateAssessmentService();

  @override
  bool get canResetTrust => metadata != null;

  @override
  Future<void> resetTrust() async => await metadata?.reset();

  /// Descriptive only: damage never blocks what Play offers (8.7).
  @override
  bool get trustDamaged => metadata?.recoveryRequired ?? false;

  @override
  Future<RecoveryOutcome> recover() async {
    await metadata?.open();
    return RecoveryOutcome(await _recoveredState());
  }

  /// Reconciles what Play already holds (a finished flexible download). An
  /// IPC call to Play, not a network request of ours.
  Future<UpdateState> _recoveredState() async {
    try {
      final info = await host.playCheck();
      if (info.availability == PlayAvailability.error) {
        return UpdateIdle();
      }
      final code = info.availableVersionCode;
      if (code == null || code <= installed.versionCode) {
        return UpdateIdle();
      }
      return _fromInfo(info, _describe(code));
    } catch (error, stackTrace) {
      logger.w('Play recovery failed', error: error, stackTrace: stackTrace);
      return UpdateIdle();
    }
  }

  @override
  Future<UpdateState> check({required CancelToken cancel}) async {
    var info = await _play(host.playCheck);
    if (info.availability == PlayAvailability.error) {
      throw mapPlayError(info.failure, info.errorCode);
    }
    if (!_offersUpdate(info)) return UpdateUpToDate();

    // The description is best effort: a failure here never fails the check.
    final metadata = this.metadata;
    if (metadata != null) {
      try {
        await metadata.fetchAndAccept(cancel: cancel);
      } catch (error, stackTrace) {
        logger.i(
          'Play update description unavailable',
          error: error,
          stackTrace: stackTrace,
        );
      }
      // Play's status may have moved during the fetch (a flexible download
      // finishing), and its event found no assessment to update while the
      // state was `checking`: ask again rather than report what it was.
      try {
        final again = await host.playCheck();
        if (again.availability != PlayAvailability.error &&
            again.availability != PlayAvailability.unknown) {
          info = again;
        }
      } catch (error, stackTrace) {
        logger.i(
          'Play status unavailable after the description',
          error: error,
          stackTrace: stackTrace,
        );
      }
      if (!_offersUpdate(info)) return UpdateUpToDate();
    }
    return _fromInfo(info, _describe(info.availableVersionCode!));
  }

  bool _offersUpdate(PlayUpdateInfo info) =>
      info.availability != PlayAvailability.notAvailable &&
      info.availableVersionCode != null &&
      info.availableVersionCode! > installed.versionCode;

  UpdateAssessment _describe(int versionCode) {
    final catalogue = metadata?.usable();
    if (catalogue != null) {
      final match = _selector.describePlay(catalogue, installed, versionCode);
      if (match != null) {
        return _assessments.assess(
          catalogue: catalogue,
          release: match.release,
          target: match.target,
          installed: installed,
        );
      }
    }
    return _assessments.undescribed(versionCode: versionCode);
  }

  UpdateState _fromInfo(PlayUpdateInfo info, UpdateAssessment assessment) =>
      switch (info.installStatus) {
        PlayInstallStatus.downloaded => UpdateReadyToInstall(assessment),
        PlayInstallStatus.downloading ||
        PlayInstallStatus.pending => UpdateDownloading(
          assessment,
          received: info.bytesDownloaded ?? 0,
          total: info.totalBytesToDownload,
        ),
        PlayInstallStatus.installing => UpdateInstalling(assessment),
        PlayInstallStatus.unknown ||
        PlayInstallStatus.installed ||
        PlayInstallStatus.failed ||
        PlayInstallStatus.canceled => UpdateAvailable(assessment),
      };

  /// Download starts Play's flexible flow; its consent sheet is Play's own,
  /// and how it was answered decides the state.
  ///
  /// Play can report the download (finished, even failed) before the sheet's
  /// answer arrives. The coordinator applies such an event at once, and the
  /// state returned here replaces it, so it is that event's state, never
  /// "just started".
  @override
  Future<UpdateState> prepare(
    UpdateAssessment assessment, {
    required void Function(UpdateState progress) onProgress,
    required CancelToken cancel,
  }) async {
    PlayInstallStateEvent? latest;
    final events = host.playEvents.listen((event) => latest = event);
    final PlayFlowResult answer;
    try {
      answer = await _play(host.playStartFlexible);
    } finally {
      await events.cancel();
    }

    final started = UpdateDownloading(assessment, received: 0);
    return switch (answer) {
      PlayFlowResult.accepted => switch (latest) {
        final event? => _reduce(started, event) ?? started,
        null => started,
      },
      // Closed without accepting: nothing started.
      PlayFlowResult.declined => UpdateAvailable(assessment),
      PlayFlowResult.failed => UpdateFailed(
        UpdateFailure(UpdateFailureKind.playError, 'update flow failed'),
        returnTo: UpdateAvailable(assessment),
        operation: UpdateOperation.download,
      ),
    };
  }

  /// "Restart": `completeUpdate`. Play restarts the app.
  @override
  Future<UpdateState> requestInstallation(UpdateAssessment assessment) async {
    await flushPendingWrites?.call();
    await _play(host.playCompleteFlexible);
    return UpdateInstalling(assessment);
  }

  @override
  Future<UpdateState> continueInstallation(UpdateState current) async =>
      current;

  @override
  Future<UpdateState> cancelInstallation(UpdateState current) async => current;

  /// Play may offer a different version than the one assessed, or none: the
  /// state follows what it offers now, described for that version.
  @override
  Future<UpdateState?> onResume(UpdateState current) async {
    final assessment = current.assessment;
    if (assessment == null) return null;
    try {
      final info = await host.playCheck();
      // No evidence either way: keep what the last check found.
      if (info.availability == PlayAvailability.error ||
          info.availability == PlayAvailability.unknown) {
        return null;
      }
      final code = info.availableVersionCode;
      final UpdateState next;
      if (info.availability == PlayAvailability.notAvailable ||
          code == null ||
          code <= installed.versionCode) {
        next = UpdateUpToDate();
      } else {
        next = _fromInfo(
          info,
          code == assessment.versionCode ? assessment : _describe(code),
        );
      }
      return next == current ? null : next;
    } catch (_) {
      return null;
    }
  }

  @override
  late final Stream<UpdateEvent> events = host.playEvents.map(
    (event) => UpdateEvent((current) => _reduce(current, event)),
  );

  UpdateState? _reduce(UpdateState current, PlayInstallStateEvent event) {
    final assessment = current.assessment;
    if (assessment == null) return null;
    return switch (event.installStatus) {
      PlayInstallStatus.pending ||
      PlayInstallStatus.downloading => UpdateDownloading(
        assessment,
        received: event.bytesDownloaded,
        total: event.totalBytesToDownload > 0
            ? event.totalBytesToDownload
            : null,
      ),
      PlayInstallStatus.downloaded => UpdateReadyToInstall(assessment),
      PlayInstallStatus.installing => UpdateInstalling(assessment),
      PlayInstallStatus.canceled => UpdateAvailable(assessment),
      PlayInstallStatus.failed => UpdateFailed(
        mapPlayError(event.failure, event.errorCode),
        returnTo: UpdateAvailable(assessment),
        operation: UpdateOperation.download,
      ),
      PlayInstallStatus.unknown || PlayInstallStatus.installed => null,
    };
  }

  /// A Play call; its platform errors are `playError`.
  static Future<T> _play<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on PlatformException catch (e) {
      throw UpdateFailure(
        UpdateFailureKind.playError,
        '${e.code}: ${e.message}',
      );
    }
  }

  /// Native maps Play's error code (8.7); the raw code is kept for logs.
  static UpdateFailure mapPlayError(PlayFailure? failure, int? code) =>
      UpdateFailure(switch (failure) {
        PlayFailure.notOwned => UpdateFailureKind.playNotOwned,
        PlayFailure.unavailable => UpdateFailureKind.playUnavailable,
        PlayFailure.other || null => UpdateFailureKind.playError,
      }, 'play error $code');
}
