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
/// The auto-lock modes whose unlock holds across windows.
///
/// Background mode is absent on purpose: switching between the browser and a
/// Custom Tab or PWA window counts as leaving, so its unlock is never shared.
enum SharedUnlockMode { timeout, startup }

/// An unlock of the committed profile that the browser and its Custom Tab and
/// PWA windows share.
class SharedProfileUnlock {
  final SharedUnlockMode mode;
  final int timeoutMs;

  /// How long ago the profile was unlocked. An age rather than a timestamp:
  /// Dart and native do not share a clock worth trusting.
  final int ageMs;

  SharedProfileUnlock({
    required this.mode,
    required this.timeoutMs,
    required this.ageMs,
  });
}

enum ProfilePasswordOutcome {
  accepted,
  rejected,

  /// Not checked: an earlier run of wrong attempts is still being waited out.
  throttled,

  /// The app half has not activated a profile yet. Asking again later is right.
  unavailable,

  /// The check could not run or record its result. Not a pass.
  failed,
}

class ProfilePasswordReply {
  final ProfilePasswordOutcome outcome;

  /// How long the next attempt has to wait, for a rejected or throttled one.
  final int? retryAfterMs;

  ProfilePasswordReply({required this.outcome, this.retryAfterMs});
}

/// What [GeckoProfileApi.probeBackupTree] found, or which way a write into a
/// SAF tree failed.
enum BackupTreeProbeOutcome {
  /// A file was created, written and synced (and, for a probe, removed again).
  writable,

  /// No persisted read/write grant is on record for the tree.
  noGrant,

  /// The tree's folder is gone, or is no longer a folder: the provider has no
  /// row for it, or refused to create a file in it as a document it does not
  /// have.
  missing,

  /// The grant is on record and the folder is there, but the provider refused
  /// access when a file was created or opened in it.
  refused,

  /// The storage holding the folder is full. Access is fine, and so is the
  /// folder: it is the space that has to change.
  noSpace,

  /// Writing failed for a reason that says nothing about access or space — a
  /// provider that died, or an error nobody recognised. Not evidence against
  /// the folder.
  inconclusive,
}

class BackupTreeProbe {
  final BackupTreeProbeOutcome outcome;

  /// The folder's display name, when the provider still answers for it.
  final String? folderName;

  /// The class of the exception the provider threw, for logs.
  final String? errorClass;

  /// The exception's message, for logs.
  final String? errorMessage;

  BackupTreeProbe({
    required this.outcome,
    this.folderName,
    this.errorClass,
    this.errorMessage,
  });
}

/// Which way a publication failed when the folder's own answer is not it.
///
/// Only with [BackupTreeProbeOutcome.inconclusive]: neither says anything
/// against the folder or its space.
enum TreePublicationFault {
  /// The copy finished without an error, yet the provider holds a different
  /// number of bytes than were sent.
  truncated,

  /// The local file could not be read. Nothing the folder did failed.
  sourceUnreadable,
}

/// What [GeckoProfileApi.publishFileToTree] or
/// [GeckoProfileApi.publishBytesToTree] did.
class TreePublication {
  /// [BackupTreeProbeOutcome.writable] when the file is in place under its
  /// final name; otherwise which way writing it failed.
  final BackupTreeProbeOutcome outcome;

  /// Set with [BackupTreeProbeOutcome.inconclusive] when it is known what went
  /// wrong, and it was not the folder.
  final TreePublicationFault? fault;

  /// The published document, when [outcome] is writable.
  final String? uri;

  /// The name the file ended up with. A provider may change the one asked for,
  /// for example to avoid a clash.
  final String? name;

  /// With [BackupTreeProbeOutcome.noSpace], when the volume showed before the
  /// copy that it lacks the room: the bytes the file needs, and the bytes
  /// free. Null when the volume filled up during the copy instead.
  final int? requiredBytes;
  final int? availableBytes;

  /// The class of the exception the provider threw, for logs.
  final String? errorClass;

  /// The exception's message, for logs.
  final String? errorMessage;

  TreePublication({
    required this.outcome,
    this.fault,
    this.uri,
    this.name,
    this.requiredBytes,
    this.availableBytes,
    this.errorClass,
    this.errorMessage,
  });
}

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

/// Profile arbitration, registered at plugin attach time so it is callable
/// before anything opens a database or initializes Gecko.
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
  ///
  /// [showPicker] makes the next launch show the profile picker once, whatever
  /// the prompt setting says (it still needs a UI launch and two profiles).
  bool armProfileRestart(
    String? targetProfileId,
    String reason,
    bool showPicker,
  );

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

  /// Copies the SAF document [sourceUri] into the local file [destPath].
  ///
  /// Throws with the platform's own exception class and message, so a restore
  /// that cannot read its archive says why instead of failing anonymously.
  @async
  void copyDocumentToFile(String sourceUri, String destPath);

  /// Whether a persisted read/write grant covers the SAF tree [treeUri].
  ///
  /// Only the grant list is read, compared by tree, so it costs nothing and
  /// never throws for grants on single documents. Says less than
  /// [probeBackupTree]: a grant can stay on record for a folder the provider
  /// no longer writes to (#698).
  @async
  bool hasPersistedTreeGrant(String treeUri);

  /// The display name of the folder the SAF tree [treeUri] names, or null when
  /// the provider gives none.
  ///
  /// Asked on a background thread. `saf_util`'s `stat` reads a document's
  /// name, type, size and date on the main thread, so a cloud or USB provider
  /// that stalls froze the activity that asked.
  @async
  String? treeFolderName(String treeUri);

  /// Checks that a file can really be created in the SAF tree [treeUri].
  ///
  /// Creates a hidden document, writes a block to it, syncs it and deletes it
  /// again. A persisted grant that is still on record, for a folder that still
  /// exists, can still be refused by the provider when it is used — so only
  /// doing what a backup does answers whether a backup will work. Writing real
  /// bytes is what makes a full volume answer: an empty file is usually still
  /// created on one.
  @async
  BackupTreeProbe probeBackupTree(String treeUri);

  /// Copies the local file [sourcePath] into the SAF tree [treeUri] as
  /// [fileName].
  ///
  /// The file is written as [stagingName] and renamed only once the provider
  /// holds every byte, so an interrupted write never leaves a file under the
  /// final name. Any failure removes the staging file again. Failures come back
  /// in the result rather than as an error, classified from the provider's own
  /// exception, which AndroidX's `DocumentFile.createFile` swallows (#698).
  @async
  TreePublication publishFileToTree(
    String sourcePath,
    String treeUri,
    String fileName,
    String stagingName,
    String mimeType,
  );

  /// [publishFileToTree] for bytes already in memory.
  @async
  TreePublication publishBytesToTree(
    Uint8List bytes,
    String treeUri,
    String fileName,
    String stagingName,
    String mimeType,
  );

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

  /// Records that the browser unlocked [profileId] [ageMs] ago, so Custom Tab
  /// and PWA windows open without asking again while [mode] says it holds.
  ///
  /// The age keeps an unlock the browser adopted from a window from starting
  /// its timeout over on the way back.
  void recordSharedProfileUnlock(
    String profileId,
    SharedUnlockMode mode,
    int timeoutMs,
    int ageMs,
  );

  /// Drops a shared unlock: the profile was locked again, or its lock
  /// settings no longer allow sharing one.
  void clearSharedProfileUnlock(String profileId);

  /// The shared unlock of [profileId] that still holds, or null.
  SharedProfileUnlock? getSharedProfileUnlock(String profileId);
}

/// Lets a Custom Tab or PWA window check a profile password.
///
/// The check runs in Dart because that is where the password's Argon2
/// verifier and the wrong-attempt throttling live; a second implementation in
/// Kotlin would be a second copy that can disagree.
@FlutterApi()
abstract class ProfileLockFlutterApi {
  @async
  ProfilePasswordReply checkProfilePassword(String profileId, String password);
}
