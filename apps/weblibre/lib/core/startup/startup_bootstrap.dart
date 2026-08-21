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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:uuid/uuid.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/core/startup/profile_discovery.dart';
import 'package:weblibre/core/startup/startup_config_store.dart';
import 'package:weblibre/core/uuid.dart';

/// Identity of this Flutter engine for the lifetime of its isolate.
///
/// The native arbiter compares it to decide whether a `beginStartup` call is the
/// same owner reattaching after an Activity recreation or a second owner trying
/// to re-decide the profile. Generated once per isolate on purpose: a value that
/// changed per call would make a healthy recreation look like a competing owner,
/// and one shared across isolates would make the background isolate look like
/// the UI.
final engineInstanceId = uuid.v4();

/// The result of arbitrating the process profile.
sealed class StartupPhase {
  const StartupPhase();
}

/// A profile is committed natively and activated in Dart. The app may boot.
final class StartupActivated extends StartupPhase {
  const StartupActivated(this.profileId);

  final String profileId;
}

/// The user must choose which profile to start, and this owner holds the lease
/// that lets them.
///
/// Carries only data. Completing the choice goes through [commitChosenProfile],
/// so the same commit-then-activate path runs whether a person picked the profile
/// or the candidate rule did.
final class StartupSelectionRequired extends StartupPhase {
  const StartupSelectionRequired({
    required this.leaseId,
    required this.profiles,
    this.candidateProfileId,
  });

  final String leaseId;
  final List<DiscoveredProfile> profiles;

  /// What would have been chosen without asking. Used to pre-highlight, never to
  /// decide.
  final String? candidateProfileId;
}

/// Maintenance owns this process, and this owner holds the lease to run it.
///
/// A phase rather than a halt: the work is the reason the process started, and
/// once it finishes the same process goes on to arbitrate a profile normally.
final class StartupMaintenanceRequired extends StartupPhase {
  const StartupMaintenanceRequired({
    required this.leaseId,
    required this.reason,
    this.taskId,
    this.recoveryRequired = false,
    this.blocking = false,
  });

  final String leaseId;
  final String reason;
  final String? taskId;
  final bool recoveryRequired;

  /// Set when the user already tried to continue and the reservation came
  /// straight back. There is nothing to skip: the work has to be completed.
  final bool blocking;
}

/// Startup cannot continue in this process. Never a state the app boots from:
/// continuing here is exactly the unarbitrated start this machinery prevents.
final class StartupHalted extends StartupPhase {
  const StartupHalted({
    required this.kind,
    required this.reason,
    this.taskId,
    this.recoveryRequired = false,
  });

  final StartupHaltKind kind;
  final String reason;
  final String? taskId;
  final bool recoveryRequired;

  @override
  String toString() =>
      'StartupHalted($kind, $reason, task=$taskId, recovery=$recoveryRequired)';
}

enum StartupHaltKind {
  /// Another Dart isolate already holds profile state open.
  profileAccessBusy,

  /// Durable evidence says a backup, restore, or deletion owns this process.
  maintenance,

  /// Another owner holds the decision, or the process must restart first.
  unavailable,

  /// There is no profile this process may boot, and none could be created.
  noProfile,

  /// Native arbitration could not be reached or refused the commit.
  arbitrationFailed,
}

/// Drives the process profile decision, then activates the filesystem.
///
/// Every answer here comes from native. Dart deliberately keeps no fallback path
/// that reads `current_profile` itself: the whole point of arbitration is that
/// one component decides, and a Dart-side "best guess" on failure would produce
/// exactly the split start — Dart on one profile, Gecko on another — that cannot
/// be reconciled once the runtime is bound.
Future<StartupPhase> resolveStartupPhase({
  ProfileStartupOwnerType ownerType = ProfileStartupOwnerType.ui,
  GeckoProfileService? profileService,
  String? engineId,
  String? taskId,
  Duration accessWaitBudget = const Duration(seconds: 5),
  Duration accessRetryDelay = const Duration(milliseconds: 250),
}) async {
  final service = profileService ?? GeckoProfileService();
  final owner = engineId ?? engineInstanceId;

  await filesystem.initializeGlobalPaths();

  final claimed = await _claimProfileAccess(
    service: service,
    ownerType: ownerType,
    engineId: owner,
    taskId: taskId,
    // Only the UI waits. A background task that finds the UI holding the lease
    // has somewhere else to be — the scheduler will run it again — while the UI
    // has a user in front of it and a headless task that is about to finish.
    budget: ownerType == ProfileStartupOwnerType.ui
        ? accessWaitBudget
        : Duration.zero,
    retryDelay: accessRetryDelay,
  );

  switch (claimed) {
    case null:
      return const StartupHalted(
        kind: StartupHaltKind.arbitrationFailed,
        reason: 'The profile arbiter did not answer',
      );
    case false:
      return const StartupHalted(
        kind: StartupHaltKind.profileAccessBusy,
        reason: 'Another part of WebLibre is using this profile',
      );
    case true:
      break;
  }

  final phase = await _resolveUnderAccess(service, ownerType, owner);
  if (phase is StartupHalted) {
    // Nothing was opened, so the lease goes back here rather than being left to a
    // caller that has no work to clean up after. A pending selection keeps it:
    // the user has not answered yet, and `commitChosenProfile` activates under
    // this same lease.
    await _releaseQuietly(service, ownerType, owner, taskId);
  }
  return phase;
}

/// Takes the profile-access lease, retrying within [budget].
///
/// Returns null when the channel itself failed, which is a different answer from
/// "someone else holds it": one means restart, the other means wait.
Future<bool?> _claimProfileAccess({
  required GeckoProfileService service,
  required ProfileStartupOwnerType ownerType,
  required String engineId,
  required String? taskId,
  required Duration budget,
  required Duration retryDelay,
}) async {
  final deadline = DateTime.now().add(budget);

  while (true) {
    try {
      if (await service.claimProfileAccess(
        ownerType: ownerType,
        engineId: engineId,
        taskId: taskId,
      )) {
        return true;
      }
    } catch (error, stackTrace) {
      logger.e(
        'Profile access arbitration is unreachable',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }

    if (!DateTime.now().isBefore(deadline)) return false;
    await Future<void>.delayed(retryDelay);
  }
}

/// Releases the access lease without letting a failure mask the real outcome.
Future<void> releaseProfileAccess({
  GeckoProfileService? profileService,
  ProfileStartupOwnerType ownerType = ProfileStartupOwnerType.ui,
  String? engineId,
  String? taskId,
}) => _releaseQuietly(
  profileService ?? GeckoProfileService(),
  ownerType,
  engineId ?? engineInstanceId,
  taskId,
);

/// Renews the selection lease, so the native watchdog can tell "still asking" from
/// "this owner is gone".
///
/// Quiet on failure: a single missed renewal decides nothing, and the commit is
/// what fails closed. Returns whether the lease is still live.
Future<bool> heartbeatSelectionLease({
  required String leaseId,
  GeckoProfileService? profileService,
}) async {
  try {
    return await (profileService ?? GeckoProfileService()).heartbeatSelection(
      leaseId,
    );
  } catch (error, stackTrace) {
    logger.w(
      'Could not renew the selection lease',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  }
}

/// Hands a maintenance lease back without re-arbitrating.
///
/// For an owner that was granted maintenance and has no intention of running it —
/// a headless task, which has nowhere to show a screen and no password to ask for.
/// Dropping the lease instead would leave the reservation to expire, and an
/// expired maintenance lease sets the recovery-restart flag and wedges every
/// further start in this process.
Future<void> releaseMaintenanceLease({
  required String leaseId,
  GeckoProfileService? profileService,
}) async {
  try {
    await (profileService ?? GeckoProfileService()).finishMaintenance(leaseId);
  } catch (error, stackTrace) {
    logger.w(
      'Could not release the maintenance lease',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

Future<void> _releaseQuietly(
  GeckoProfileService service,
  ProfileStartupOwnerType ownerType,
  String engineId,
  String? taskId,
) async {
  try {
    await service.releaseProfileAccess(
      ownerType: ownerType,
      engineId: engineId,
      taskId: taskId,
    );
  } catch (error, stackTrace) {
    logger.w(
      'Could not release the profile access lease',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

Future<StartupPhase> _resolveUnderAccess(
  GeckoProfileService service,
  ProfileStartupOwnerType ownerType,
  String owner,
) async {
  // Native decides whether a picker is *possible* (a UI owner, a lease, two or
  // more valid profiles); this only tells it what the user asked for. Reading it
  // here rather than from a provider keeps it before any profile is opened —
  // `startup_config.json` is global on purpose.
  final promptMode = await _readPromptMode();

  final ProfileStartupDirective directive;
  try {
    directive = await service.beginStartup(
      ownerType: ownerType,
      engineId: owner,
      promptMode: promptMode,
    );
  } catch (error, stackTrace) {
    logger.e(
      'Profile arbitration is unreachable',
      error: error,
      stackTrace: stackTrace,
    );
    return const StartupHalted(
      kind: StartupHaltKind.arbitrationFailed,
      reason: 'The profile arbiter did not answer',
    );
  }

  switch (directive.kind) {
    case ProfileStartupDirectiveKind.committed:
      final profileId = directive.profileId;
      if (profileId == null) {
        return const StartupHalted(
          kind: StartupHaltKind.arbitrationFailed,
          reason: 'Native reported a commitment without a profile',
        );
      }
      await filesystem.activate(UuidValue.withValidation(profileId));
      return StartupActivated(profileId);

    case ProfileStartupDirectiveKind.select:
      return _runSelection(service, directive);

    case ProfileStartupDirectiveKind.maintenance:
      return _describeMaintenance(directive);

    case ProfileStartupDirectiveKind.unavailable:
      return StartupHalted(
        kind: StartupHaltKind.unavailable,
        reason: directive.reason ?? 'Another owner holds the profile decision',
        taskId: directive.maintenanceTaskId,
        recoveryRequired: directive.recoveryRequired,
      );
  }
}

/// Reads the persisted prompt mode, defaulting to never prompting.
///
/// A failure here must not stall startup behind a question, so it degrades to
/// [ProfileStartupPromptMode.off] rather than propagating.
Future<ProfileStartupPromptMode> _readPromptMode() async {
  try {
    final config = await StartupConfigStore(filesystem.startupPaths).read();
    return switch (config.profilePrompt) {
      ProfilePromptMode.off => ProfileStartupPromptMode.off,
      ProfilePromptMode.browserOnly => ProfileStartupPromptMode.browserOnly,
    };
  } catch (error, stackTrace) {
    logger.w(
      'Could not read the startup prompt setting',
      error: error,
      stackTrace: stackTrace,
    );
    return ProfileStartupPromptMode.off;
  }
}

/// Chooses and commits a profile while holding the selection lease.
///
/// The lease is released explicitly on every path that does not commit. Letting
/// it lapse instead would leave the process unresolvable until the selection
/// watchdog fires, and any other owner asking in the meantime is told the
/// decision is taken.
Future<StartupPhase> _runSelection(
  GeckoProfileService service,
  ProfileStartupDirective directive,
) async {
  final leaseId = directive.leaseId;
  if (leaseId == null) {
    return const StartupHalted(
      kind: StartupHaltKind.arbitrationFailed,
      reason: 'Native granted a selection without a lease',
    );
  }

  final ProfileDiscovery discovery;
  try {
    discovery = await filesystem.discoverProfiles(leaseId);
  } catch (error, stackTrace) {
    logger.e('Profile discovery failed', error: error, stackTrace: stackTrace);
    await service.releaseSelection(leaseId, 'discovery failed');
    return const StartupHalted(
      kind: StartupHaltKind.noProfile,
      reason: 'Profiles could not be read',
    );
  }

  // Native already established that a picker is possible here: this owner is a
  // UI owner, it holds the lease, and it counted at least two valid profiles.
  // The count is re-checked because discovery may have created the first-run
  // profile in between, and one profile is not a choice.
  if (directive.showPicker && discovery.profiles.length >= 2) {
    return StartupSelectionRequired(
      leaseId: leaseId,
      profiles: discovery.profiles,
      candidateProfileId: directive.candidateProfileId,
    );
  }

  final chosen = _chooseProfile(directive.candidateProfileId, discovery);
  if (chosen == null) {
    await service.releaseSelection(leaseId, 'no valid profile');
    return const StartupHalted(
      kind: StartupHaltKind.noProfile,
      reason: 'No profile could be validated or created',
    );
  }

  return _commitAndActivate(service, leaseId, chosen);
}

/// Finishes a selection the user made in the picker.
///
/// Deliberately the same path the automatic choice takes. A picker that had its
/// own commit sequence would be a second place for the commit-then-activate
/// ordering to drift, and that ordering is what keeps Dart and Gecko on one
/// profile.
Future<StartupPhase> commitChosenProfile({
  required String leaseId,
  required UuidValue profileId,
  GeckoProfileService? profileService,
  ProfileStartupOwnerType ownerType = ProfileStartupOwnerType.ui,
  String? engineId,
  String? taskId,
}) async {
  final service = profileService ?? GeckoProfileService();
  final owner = engineId ?? engineInstanceId;

  var phase = await _commitAndActivate(service, leaseId, profileId);

  if (phase is StartupHalted &&
      phase.kind == StartupHaltKind.arbitrationFailed) {
    // Native refuses the commit when the selection is no longer live — the
    // watchdog expired it, or a trusted launch answered it while the picker was
    // still up. The decision has stopped being this owner's, but it has very
    // likely been *made*, so ask again rather than halting: `beginStartup` then
    // answers `committed` and the process boots the profile native settled on,
    // instead of showing the user a failure they can do nothing about.
    logger.w('Selection commit was refused; re-arbitrating');
    phase = await _resolveUnderAccess(service, ownerType, owner);
  }

  // Only a halt means nothing was opened and nothing is pending. A selection or
  // maintenance phase coming back out of re-arbitration continues in this
  // process, and continues needing the access lease.
  if (phase is StartupHalted) {
    await _releaseQuietly(service, ownerType, owner, taskId);
  }

  return phase;
}

Future<StartupPhase> _commitAndActivate(
  GeckoProfileService service,
  String leaseId,
  UuidValue profileId,
) async {
  if (!await service.commitSelection(leaseId, profileId.uuid)) {
    // Native refuses a stale lease or a profile that stopped validating between
    // discovery and commit. Either way this process has no decision to act on.
    return StartupHalted(
      kind: StartupHaltKind.arbitrationFailed,
      reason: 'Native refused to commit ${profileId.uuid}',
    );
  }

  await filesystem.activate(profileId);
  return StartupActivated(profileId.uuid);
}

/// Picks the profile to commit when nothing prompts the user.
///
/// The native candidate wins whenever it still validates, so Dart and every
/// headless entry point agree on the same answer. Otherwise the discovery order
/// decides, which is the canonical UUID order and therefore creation order.
UuidValue? _chooseProfile(String? candidateProfileId, ProfileDiscovery found) {
  if (candidateProfileId != null) {
    for (final profile in found.profiles) {
      if (profile.uuid.uuid == candidateProfileId.toLowerCase()) {
        return profile.uuid;
      }
    }
  }

  return found.profiles.isEmpty ? null : found.profiles.first.uuid;
}

/// Describes the pending maintenance so the halt screen can name it.
///
/// Native already decided; this only reads the same durable evidence to say
/// what is pending. A failure to read it never downgrades the halt.
Future<StartupPhase> _describeMaintenance(
  ProfileStartupDirective directive,
) async {
  var reason = 'A profile backup, restore, or deletion is unfinished';

  try {
    final reservation = await filesystem.resolveMaintenanceReservation();
    if (reservation.required) {
      reason = reservation.reason;
    }
  } catch (error, stackTrace) {
    logger.w(
      'Could not describe the pending maintenance',
      error: error,
      stackTrace: stackTrace,
    );
  }

  final leaseId = directive.leaseId;
  if (leaseId == null) {
    // Native says maintenance owns the process but would not lease it to this
    // owner. There is nothing to run here and nothing to boot.
    return StartupHalted(
      kind: StartupHaltKind.maintenance,
      reason: reason,
      taskId: directive.maintenanceTaskId,
      recoveryRequired: directive.recoveryRequired,
    );
  }

  return StartupMaintenanceRequired(
    leaseId: leaseId,
    reason: reason,
    taskId: directive.maintenanceTaskId,
    recoveryRequired: directive.recoveryRequired,
  );
}

/// Ends the maintenance lease and re-arbitrates, so the process can boot.
///
/// Separate from the runner on purpose: finishing is about the *reservation*, and
/// it has to happen whether the tasks succeeded, failed, or were abandoned. A
/// process that ran its queue and then declined to release the reservation would
/// wedge every future start.
Future<StartupPhase> finishMaintenanceAndResolve({
  required String leaseId,
  GeckoProfileService? profileService,
  String? engineId,
}) async {
  final service = profileService ?? GeckoProfileService();
  final owner = engineId ?? engineInstanceId;

  try {
    await service.finishMaintenance(leaseId);
  } catch (error, stackTrace) {
    logger.e(
      'Could not release the maintenance lease',
      error: error,
      stackTrace: stackTrace,
    );
    // Halting without releasing would leave this owner holding the access lease
    // it took before maintenance ran, so every headless isolate in the process
    // would be refused for as long as it lives. Same rule as every other halt
    // below: nothing was opened, so the lease goes back.
    await _releaseQuietly(service, ProfileStartupOwnerType.ui, owner, null);
    return const StartupHalted(
      kind: StartupHaltKind.arbitrationFailed,
      reason: 'The maintenance lease could not be released',
    );
  }

  final phase = await _resolveUnderAccess(
    service,
    ProfileStartupOwnerType.ui,
    owner,
  );

  // The access lease was taken by the `resolveStartup` that produced the
  // maintenance phase, and held across the whole screen because maintenance is
  // work this process is doing. Re-arbitration ending in a halt means it has
  // stopped doing any, so the lease is no longer this owner's to keep.
  if (phase is StartupHalted) {
    await _releaseQuietly(service, ProfileStartupOwnerType.ui, owner, null);
  }

  if (phase is StartupMaintenanceRequired) {
    // The lease was released and native handed it straight back, because the
    // durable evidence is still there. That is correct — an unfinished
    // destructive operation is not skippable, the whole point of the reservation
    // is that it outlives the process that wanted to skip it — but silently
    // re-rendering the same screen reads as a dead button. Say so instead.
    return StartupMaintenanceRequired(
      leaseId: phase.leaseId,
      reason: phase.reason,
      taskId: phase.taskId,
      recoveryRequired: phase.recoveryRequired,
      blocking: true,
    );
  }

  return phase;
}
