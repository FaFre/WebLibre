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
import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/core/startup/models/json_read.dart';

part 'startup_config.g.dart';

/// Schema version this build writes.
const startupConfigVersion = 1;

/// Whether the process may stop at a profile picker before committing.
///
/// `browserAndExternal` is deliberately absent: the plan defers it until the
/// native external picker has a proven ownership and rotation model.
enum ProfilePromptMode { off, browserOnly }

enum MaintenanceAction {
  backup,
  restoreOver,
  restoreClone,
  delete;

  /// Whether the action mutates state outside the profile directory and
  /// therefore cannot be rolled back once its commit barrier is durable.
  bool get isDestructive => switch (this) {
    MaintenanceAction.backup => false,
    MaintenanceAction.restoreOver => true,
    MaintenanceAction.restoreClone => false,
    MaintenanceAction.delete => true,
  };
}

enum MaintenanceTaskState {
  queued,
  awaitingInput,
  running,
  committing,
  completed,
  recoveryRequired,
  failed;

  /// A task in one of these states still needs the maintenance reservation on
  /// the next process start.
  bool get requiresMaintenance => switch (this) {
    MaintenanceTaskState.queued => true,
    MaintenanceTaskState.awaitingInput => true,
    MaintenanceTaskState.running => true,
    MaintenanceTaskState.committing => true,
    MaintenanceTaskState.recoveryRequired => true,
    MaintenanceTaskState.completed => false,
    MaintenanceTaskState.failed => false,
  };

  /// `running` and `committing` mean the previous process died mid-operation.
  bool get requiresRecovery => switch (this) {
    MaintenanceTaskState.running => true,
    MaintenanceTaskState.committing => true,
    MaintenanceTaskState.recoveryRequired => true,
    _ => false,
  };

  /// The user may still abandon the task without leaving profile state behind.
  /// After the destructive commit barrier there is no cancel edge; recovery
  /// owns the outcome.
  bool get isCancellable => switch (this) {
    MaintenanceTaskState.queued => true,
    MaintenanceTaskState.awaitingInput => true,
    MaintenanceTaskState.running => true,
    _ => false,
  };

  static const _transitions = <MaintenanceTaskState, Set<MaintenanceTaskState>>{
    MaintenanceTaskState.queued: {
      MaintenanceTaskState.awaitingInput,
      MaintenanceTaskState.running,
      MaintenanceTaskState.failed,
    },
    MaintenanceTaskState.awaitingInput: {
      MaintenanceTaskState.queued,
      MaintenanceTaskState.running,
      MaintenanceTaskState.failed,
    },
    MaintenanceTaskState.running: {
      MaintenanceTaskState.queued,
      MaintenanceTaskState.awaitingInput,
      MaintenanceTaskState.committing,
      MaintenanceTaskState.completed,
      MaintenanceTaskState.recoveryRequired,
      MaintenanceTaskState.failed,
    },
    MaintenanceTaskState.committing: {
      MaintenanceTaskState.completed,
      MaintenanceTaskState.recoveryRequired,
      MaintenanceTaskState.failed,
    },
    MaintenanceTaskState.recoveryRequired: {
      MaintenanceTaskState.running,
      MaintenanceTaskState.completed,
      MaintenanceTaskState.failed,
    },
    MaintenanceTaskState.failed: {MaintenanceTaskState.queued},
    MaintenanceTaskState.completed: <MaintenanceTaskState>{},
  };

  bool canTransitionTo(MaintenanceTaskState next) =>
      _transitions[this]!.contains(next);
}

/// The persistable name of a [MaintenanceFailure].
///
/// An enum rather than the sealed type itself because this is the half that has
/// to survive `startup_config.json`: the record outlives the process, and
/// `StartupConfig.kt` reads the same file. It follows the tolerant pattern every
/// other enum in `startup_config.dart` uses — an id string and a `tryFromId`
/// that returns null — so a kind written by a newer build round-trips through
/// this one instead of being silently rewritten as something it is not.
enum MaintenanceFailureKind {
  wrongPassword,
  unreadableArchive,
  damagedArchive,
  unsupportedArchiveVersion,
  notEnoughStorage,
  backupTargetUnavailable,
  backupTargetFull,
  backupTargetUnresponsive,
  backupWriteFailed,
  archiveRejected,
  profileNoLongerExists,
  restoreEvidenceUnresolved,
  taskNotRunnable,
  restartNotScheduled,
  unknown;

  /// Whether the archive password could account for this.
  ///
  /// The one question the maintenance screen asks of a failure, and it is asked
  /// of the *persisted* kind rather than of a message, so the screen and this
  /// file cannot drift into disagreeing. Exhaustive on purpose: a new kind is a
  /// compile error here until someone decides which side of the line it is on.
  bool get blamesPassword => switch (this) {
    MaintenanceFailureKind.wrongPassword ||
    MaintenanceFailureKind.unreadableArchive => true,
    MaintenanceFailureKind.damagedArchive ||
    MaintenanceFailureKind.unsupportedArchiveVersion ||
    MaintenanceFailureKind.notEnoughStorage ||
    MaintenanceFailureKind.backupTargetUnavailable ||
    MaintenanceFailureKind.backupTargetFull ||
    MaintenanceFailureKind.backupTargetUnresponsive ||
    MaintenanceFailureKind.backupWriteFailed ||
    MaintenanceFailureKind.archiveRejected ||
    MaintenanceFailureKind.profileNoLongerExists ||
    MaintenanceFailureKind.restoreEvidenceUnresolved ||
    MaintenanceFailureKind.taskNotRunnable ||
    MaintenanceFailureKind.restartNotScheduled ||
    MaintenanceFailureKind.unknown => false,
  };
}

/// One queued profile maintenance operation.
///
/// [actionId]/[stateId] hold the raw strings from disk so a task written by a
/// newer build survives a round trip through this one instead of being
/// rewritten as something it is not. [action]/[state] are `null` exactly when
/// the raw value is unknown, which is the quarantine condition.
///
/// Fields are declared in the order the file lists them.
@CopyWith()
@JsonSerializable(checked: true)
class MaintenanceTask with FastEquatable {
  @CopyWithField(immutable: true)
  @JsonKey(fromJson: requiredString)
  final String id;
  @JsonKey(name: 'action', fromJson: stringOrEmpty)
  final String actionId;
  @JsonKey(fromJson: requiredString)
  final String profileId;
  @JsonKey(fromJson: stringOrEmpty)
  final String profileName;
  @JsonKey(name: 'state', fromJson: stringOrEmpty)
  final String stateId;
  @JsonKey(fromJson: stringOrNull)
  final String? targetTreeUri;
  @JsonKey(fromJson: stringOrNull)
  final String? sourceFileUri;
  @JsonKey(fromJson: stringOrNull)
  final String? sourceDigest;
  @JsonKey(fromJson: _trueUnlessFalse)
  final bool integrityCheck;

  /// Restore only: the installed profile takes the archive's name rather than
  /// keeping the target's. Set by the first-run restore, where the target is a
  /// placeholder the user never chose a name for.
  @JsonKey(fromJson: _falseUnlessTrue)
  final bool adoptArchiveName;
  @JsonKey(fromJson: dateTimeOrEpoch, toJson: utcIso)
  final DateTime createdAt;
  @JsonKey(fromJson: dateTimeOrNull, toJson: utcIsoOrNull)
  final DateTime? startedAt;
  @JsonKey(fromJson: stringOrNull)
  final String? error;

  /// The [MaintenanceFailureKind] id behind [error], when there is one.
  ///
  /// Stored beside the message rather than instead of it: the kind is what code
  /// branches on and what the screen translates, and the English message stays
  /// for diagnostics and for [MaintenanceFailureKind.unknown]. Raw, like [actionId]
  /// and [stateId], so a kind written by a newer build round-trips instead of
  /// being rewritten as something this build understands.
  @JsonKey(name: 'errorKind', fromJson: stringOrNull)
  final String? errorKindId;

  /// What the kind alone cannot say, as a raw id: the `RestoreValidationReason`
  /// behind [MaintenanceFailureKind.archiveRejected], the
  /// `TaskNotRunnableReason` behind [MaintenanceFailureKind.taskNotRunnable].
  /// Lets the screen translate
  /// a failure read back from disk instead of showing the stored English
  /// [error], which stays for diagnostics.
  @JsonKey(name: 'errorDetail', fromJson: stringOrNull)
  final String? errorDetailId;

  MaintenanceTask({
    required this.id,
    required this.actionId,
    required this.stateId,
    required this.profileId,
    required this.profileName,
    required this.createdAt,
    this.targetTreeUri,
    this.sourceFileUri,
    this.sourceDigest,
    this.integrityCheck = true,
    this.adoptArchiveName = false,
    this.startedAt,
    this.error,
    this.errorKindId,
    this.errorDetailId,
  });

  MaintenanceTask.create({
    required this.id,
    required MaintenanceAction action,
    required this.profileId,
    required this.profileName,
    required this.createdAt,
    MaintenanceTaskState state = MaintenanceTaskState.queued,
    this.targetTreeUri,
    this.sourceFileUri,
    this.sourceDigest,
    this.integrityCheck = true,
    this.adoptArchiveName = false,
    this.startedAt,
    this.error,
    this.errorKindId,
    this.errorDetailId,
  }) : actionId = action.name,
       stateId = state.name;

  MaintenanceAction? get action => MaintenanceAction.values.tryByName(actionId);

  MaintenanceTaskState? get state =>
      MaintenanceTaskState.values.tryByName(stateId);

  /// A quarantined task is reported as failed but never executed, and its
  /// original action/state strings are preserved for diagnostics.
  bool get isQuarantined => action == null || state == null;

  /// Effective state for scheduling: an unparseable task behaves as `failed`.
  MaintenanceTaskState get effectiveState =>
      isQuarantined ? MaintenanceTaskState.failed : state!;

  /// Whether [errorKindId] names a kind this build knows.
  MaintenanceFailureKind? get failureKind =>
      MaintenanceFailureKind.values.tryByName(errorKindId);

  MaintenanceTask withState(
    MaintenanceTaskState next, {
    String? error,
    String? errorKindId,
    String? errorDetailId,
  }) => copyWith(
    stateId: next.name,
    error: error,
    errorKindId: errorKindId,
    errorDetailId: errorDetailId,
  );

  /// Null for an entry that names no task or no profile: it can never be
  /// addressed. Every other field degrades (`json_read.dart`).
  static MaintenanceTask? tryFromJson(Map<String, Object?> json) =>
      tryCheckedFromJson(json, _$MaintenanceTaskFromJson);

  Map<String, Object?> toJson() => _$MaintenanceTaskToJson(this);

  @override
  List<Object?> get hashParameters => [
    id,
    actionId,
    stateId,
    profileId,
    profileName,
    targetTreeUri,
    sourceFileUri,
    sourceDigest,
    integrityCheck,
    adoptArchiveName,
    createdAt,
    startedAt,
    error,
    errorKindId,
    errorDetailId,
  ];
}

/// Global startup configuration, readable before any profile database opens.
@CopyWith()
@JsonSerializable(explicitToJson: true)
class StartupConfig with FastEquatable {
  @JsonKey(fromJson: _version)
  final int version;
  @JsonKey(
    unknownEnumValue: ProfilePromptMode.off,
    defaultValue: ProfilePromptMode.off,
  )
  final ProfilePromptMode profilePrompt;
  @JsonKey(fromJson: _trueUnlessFalse)
  final bool honorShortcutProfile;
  @JsonKey(fromJson: _pendingTasks)
  final List<MaintenanceTask> pendingTasks;

  StartupConfig({
    this.version = startupConfigVersion,
    this.profilePrompt = ProfilePromptMode.off,
    this.honorShortcutProfile = true,
    this.pendingTasks = const [],
  });

  static final defaults = StartupConfig();

  /// Tolerant parse. Never throws for structurally odd input: unknown prompt
  /// values fall back to `off`, unaddressable task entries are dropped, and
  /// tasks with an unknown action/state are kept but quarantined.
  factory StartupConfig.fromJson(Map<String, Object?> json) =>
      _$StartupConfigFromJson(json);

  Map<String, Object?> toJson() => _$StartupConfigToJson(this);

  static int _version(Object? value) => intOr(value, startupConfigVersion);

  /// Entries that aren't tasks are dropped, and so is a repeated id.
  static List<MaintenanceTask> _pendingTasks(Object? value) {
    final seenIds = <String>{};
    return List.unmodifiable(
      recordsFromJson(
        value,
        MaintenanceTask.tryFromJson,
      ).where((task) => seenIds.add(task.id)),
    );
  }

  /// Tasks that must keep the process in maintenance, in queue order.
  List<MaintenanceTask> get activeTasks => pendingTasks
      .where((task) => task.effectiveState.requiresMaintenance)
      .toList(growable: false);

  bool get requiresMaintenance => activeTasks.isNotEmpty;

  bool get requiresRecovery =>
      pendingTasks.any((task) => task.effectiveState.requiresRecovery);

  MaintenanceTask? taskById(String id) =>
      pendingTasks.firstWhereOrNull((task) => task.id == id);

  @override
  List<Object?> get hashParameters => [
    version,
    profilePrompt,
    honorShortcutProfile,
    pendingTasks,
  ];
}

bool _trueUnlessFalse(Object? value) => boolOr(value, true);

bool _falseUnlessTrue(Object? value) => boolOr(value, false);
