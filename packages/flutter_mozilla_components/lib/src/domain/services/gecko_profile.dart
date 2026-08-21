/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/src/pigeons/startup.g.dart';

final _apiInstance = GeckoProfileApi();

/// Dart's window onto the process-global native profile arbiter.
///
/// Every method here is a question about a decision native owns. Nothing in this
/// class caches an answer: a Flutter engine can be replaced inside a live
/// process, so a cached "which profile am I" would outlive the only component
/// entitled to know.
class GeckoProfileService {
  GeckoProfileService({GeckoProfileApi? api}) : _api = api ?? _apiInstance;

  final GeckoProfileApi _api;

  /// Asks native what this owner must do next. The answer is authoritative; a
  /// caller that cannot reach it must schedule a restart rather than resolve the
  /// profile itself.
  Future<ProfileStartupDirective> beginStartup({
    required ProfileStartupOwnerType ownerType,
    required String engineId,
    required ProfileStartupPromptMode promptMode,
  }) {
    return _api.beginStartup(ownerType, engineId, promptMode);
  }

  Future<bool> commitSelection(String leaseId, String profileId) {
    return _api.commitSelection(leaseId, profileId);
  }

  Future<bool> heartbeatSelection(String leaseId) {
    return _api.heartbeatSelection(leaseId);
  }

  Future<bool> releaseSelection(String leaseId, String reason) {
    return _api.releaseSelection(leaseId, reason);
  }

  Future<bool> heartbeatMaintenance(String leaseId) {
    return _api.heartbeatMaintenance(leaseId);
  }

  Future<bool> holdMaintenanceHeartbeat(String leaseId, bool held) {
    return _api.holdMaintenanceHeartbeat(leaseId, held);
  }

  Future<bool> assertMaintenanceLease({
    required String leaseId,
    required String boundary,
    String? taskId,
  }) {
    return _api.assertMaintenanceLease(leaseId, taskId, boundary);
  }

  Future<bool> suspendMaintenance(String leaseId, {String? taskId}) {
    return _api.suspendMaintenance(leaseId, taskId);
  }

  Future<bool> finishMaintenance(String leaseId) {
    return _api.finishMaintenance(leaseId);
  }

  /// Arms a durable restart, optionally onto another profile.
  ///
  /// False means nothing changed and the app may keep running. True means the
  /// process is terminal: finish teardown, then call [completeProfileRestart].
  Future<bool> armProfileRestart({
    String? targetProfileId,
    required String reason,
  }) {
    return _api.armProfileRestart(targetProfileId, reason);
  }

  /// Exits the process so the armed restart can relaunch it. Never returns.
  Future<void> completeProfileRestart() => _api.completeProfileRestart();

  /// Ids of the native maintenance participants this build registers.
  Future<List<String>> listMaintenanceParticipants() =>
      _api.listMaintenanceParticipants();

  Future<bool> runMaintenanceParticipantStep({
    required String participantId,
    required ParticipantStep step,
    required String taskId,
    required String profileId,
    required String journalKind,
    required String workDirPath,
  }) => _api.runMaintenanceParticipantStep(
    participantId,
    step,
    taskId,
    profileId,
    journalKind,
    workDirPath,
  );

  /// Free bytes on the filesystem holding [path], or null when unknown.
  Future<int?> getAvailableBytes(String path) => _api.getAvailableBytes(path);

  /// Flushes a directory's own metadata so a rename inside it is durable.
  ///
  /// False means it could not be done, which callers treat as "the crash window
  /// is still open" rather than as a failure — Dart cannot do this at all, so
  /// the alternative to a best-effort answer is no answer.
  Future<bool> syncDirectory(String path) => _api.syncDirectory(path);

  /// Claims every queued launch this engine may deliver, oldest first.
  ///
  /// Claiming and reading are one call because they have to be: looking first
  /// and claiming afterwards would let a second engine read the same entry in
  /// between.
  Future<List<StartupIntentRecord>> claimStartupIntents(String engineId) =>
      _api.claimStartupIntents(engineId);

  /// Marks a queued launch delivered, so it is never replayed.
  Future<bool> acknowledgeStartupIntent(String entryId, String engineId) =>
      _api.acknowledgeStartupIntent(entryId, engineId);

  /// Hands a claimed launch back undelivered.
  Future<bool> releaseStartupIntent(String entryId, String engineId) =>
      _api.releaseStartupIntent(entryId, engineId);

  /// Claims the right for this isolate to hold profile state open.
  Future<bool> claimProfileAccess({
    required ProfileStartupOwnerType ownerType,
    required String engineId,
    String? taskId,
  }) {
    return _api.claimProfileAccess(ownerType, engineId, taskId);
  }

  Future<bool> releaseProfileAccess({
    required ProfileStartupOwnerType ownerType,
    required String engineId,
    String? taskId,
  }) {
    return _api.releaseProfileAccess(ownerType, engineId, taskId);
  }

  Future<String?> getCommittedProfileId() => _api.getCommittedProfileId();

  Future<String?> getBoundProfileFolder() => _api.getBoundProfileFolder();
}
