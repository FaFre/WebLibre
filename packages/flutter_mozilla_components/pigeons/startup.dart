/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:pigeon/pigeon.dart';

/// What a Dart owner must do next with the process profile decision.
enum ProfileStartupDirectiveKind {
  /// A profile is already committed; adopt it and boot.
  committed,

  /// The caller holds a selection lease and must commit or release it.
  select,

  /// The caller holds a maintenance lease and must run recovery or queued work.
  maintenance,

  /// Another owner holds the decision, or the process is terminating. The caller
  /// must never fall back to reading `current_profile` itself.
  unavailable,
}

/// Which kind of Dart owner is asking. Only a UI owner can show a picker.
enum ProfileStartupOwnerType { ui, headless }

/// One step of the participant transaction protocol.
enum ParticipantStep { discover, prepare, apply, verify, finalize, rollback }

/// Mirrors the `profilePrompt` setting in `startup_config.json`.
enum ProfileStartupPromptMode { off, browserOnly }

class ProfileStartupDirective {
  final ProfileStartupDirectiveKind kind;

  /// Set for [ProfileStartupDirectiveKind.committed].
  final String? profileId;

  /// The profile the shared candidate rule resolved, for a selection lease.
  final String? candidateProfileId;

  /// Fencing token for the granted selection or maintenance lease.
  final String? leaseId;

  final bool showPicker;
  final String? maintenanceTaskId;
  final bool recoveryRequired;

  /// Why the decision is unavailable, or which restart the caller must schedule.
  final String? reason;

  ProfileStartupDirective({
    required this.kind,
    this.profileId,
    this.candidateProfileId,
    this.leaseId,
    this.showPicker = false,
    this.maintenanceTaskId,
    this.recoveryRequired = false,
    this.reason,
  });
}

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/startup.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/pigeons/Startup.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'eu.weblibre.flutter_mozilla_components.pigeons',
      // Pigeon emits a `FlutterError` class per generated file; the gecko pigeon
      // already owns that name in this package.
      errorClassName: 'StartupFlutterError',
    ),
    dartPackageName: 'flutter_mozilla_components',
  ),
)
/// Profile arbitration, registered at plugin attach time so it is callable
/// before anything opens a database or initializes Gecko.
/// One launch the broker is holding because nothing could receive it.
///
/// Only what survives a process restart unchanged: arbitrary `Parcelable` extras
/// have no such representation, and a best-effort rendering of one is worse than
/// its absence because the consumer cannot tell the two apart.
class StartupIntentRecord {
  final String id;
  final int sequence;
  final String? action;
  final String? dataUri;
  final String? mimeType;
  final List<String> categories;
  final Map<String, Object?> extras;
  final String? trustedProfileId;

  /// The app that sent the launch, as native resolved it when it arrived.
  ///
  /// Carried across the queue because it cannot be recovered afterwards:
  /// `getReferrer()` answers about the activity running when it is asked, which
  /// at replay time is this app. Null means internal or unestablished, exactly as
  /// it does on a live intent — the gatekeeper reads it the same way in both.
  final String? callerPackage;

  StartupIntentRecord({
    required this.id,
    required this.sequence,
    required this.action,
    required this.dataUri,
    required this.mimeType,
    required this.categories,
    required this.extras,
    required this.trustedProfileId,
    required this.callerPackage,
  });
}

@HostApi()
abstract class GeckoProfileApi {
  ProfileStartupDirective beginStartup(
    ProfileStartupOwnerType ownerType,
    String engineId,
    ProfileStartupPromptMode promptMode,
  );

  /// Commits the profile chosen under [leaseId]. Returns false for a stale lease
  /// or a profile that no longer validates; the caller must not proceed.
  bool commitSelection(String leaseId, String profileId);

  bool heartbeatSelection(String leaseId);

  bool releaseSelection(String leaseId, String reason);

  bool heartbeatMaintenance(String leaseId);

  /// Holds or releases the maintenance deadline.
  ///
  /// Held means "this owner is not running": the maintenance UI is not resumed,
  /// so Android may freeze the process, and a frozen isolate fires no timers.
  /// Without it the deadline measures how long the platform declined to run the
  /// owner, and an ordinary trip to a password manager can expire the lease.
  /// Any heartbeat or boundary assertion releases it again.
  bool holdMaintenanceHeartbeat(String leaseId, bool held);

  /// The fencing check every destructive maintenance boundary must pass.
  bool assertMaintenanceLease(String leaseId, String? taskId, String boundary);

  bool suspendMaintenance(String leaseId, String? taskId);

  bool finishMaintenance(String leaseId);

  /// Arms a durable restart, optionally targeting another profile.
  ///
  /// Returns false having changed nothing observable, so a caller that gets false
  /// can report the failure and keep running. On true the process is terminal and
  /// must call [completeProfileRestart] once teardown is done.
  bool armProfileRestart(String? targetProfileId, String reason);

  /// Tears down and exits. Never returns.
  void completeProfileRestart();

  /// Ids of the native maintenance participants this build registers.
  ///
  /// Dart orchestrates them; native owns what each one actually touches. An
  /// empty list means a directory-scoped operation is all this build can do.
  List<String> listMaintenanceParticipants();

  /// Runs one participant step. Returns false when the step refused; the caller
  /// treats that as a failure of the participant, not of the channel.
  bool runMaintenanceParticipantStep(
    String participantId,
    ParticipantStep step,
    String taskId,
    String profileId,
    String journalKind,
    String workDirPath,
  );

  /// Free bytes on the filesystem holding [path], or null when it cannot be
  /// determined. Used for backup preflight, so an unknown answer must not be
  /// reported as zero.
  int? getAvailableBytes(String path);

  /// Flushes a *directory's* own metadata to disk.
  ///
  /// Dart can fsync a file but not a directory, and a rename is recorded in the
  /// parent directory rather than in either file. So a journal phase written and
  /// flushed can still be lost if the machine dies before the directory entry
  /// reaches the platter — the exact window §11.5's recovery is written to
  /// tolerate. This narrows it instead of relying on tolerating it.
  ///
  /// Returns false when the directory could not be opened or synced; callers
  /// treat that as "the window is still open", never as a failure of the
  /// operation.
  bool syncDirectory(String path);

  /// Claims the right for this Dart isolate to hold profile state open.
  ///
  /// Returns false when another isolate holds it; the caller retries or gives
  /// up, and never opens a database anyway.
  bool claimProfileAccess(
    ProfileStartupOwnerType ownerType,
    String engineId,
    String? taskId,
  );

  bool releaseProfileAccess(
    ProfileStartupOwnerType ownerType,
    String engineId,
    String? taskId,
  );

  /// Claims every queued launch this engine may deliver, oldest first.
  ///
  /// Claiming and reading are one call because they have to be: a reader that
  /// looked first and claimed afterwards would let a second engine read the same
  /// entry in between.
  List<StartupIntentRecord> claimStartupIntents(String engineId);

  /// Marks a queued launch delivered, so it is never replayed.
  bool acknowledgeStartupIntent(String entryId, String engineId);

  /// Hands a claimed launch back undelivered, for another engine or another run.
  bool releaseStartupIntent(String entryId, String engineId);

  String? getCommittedProfileId();

  String? getBoundProfileFolder();
}
