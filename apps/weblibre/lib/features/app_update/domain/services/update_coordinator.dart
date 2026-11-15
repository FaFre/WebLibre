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

import 'package:clock/clock.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/app_update/domain/entities/update_assessment.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';
import 'package:weblibre/features/app_update/domain/entities/update_preferences.dart';
import 'package:weblibre/features/app_update/domain/entities/update_state.dart';
import 'package:weblibre/features/app_update/domain/repositories/update_state_repository.dart';
import 'package:weblibre/features/app_update/domain/services/update_backend.dart';
import 'package:weblibre/features/app_update/domain/services/update_scheduler.dart';

part 'update_coordinator.g.dart';

/// One-off messages for the UI. A cancel is something that happened, not a
/// state the updater is in, so it is reported here rather than in
/// [UpdateState].
enum UpdateNotice { downloadCancelled, installationCancelled }

/// Everything the updater's surfaces read, as one value.
@CopyWith()
class UpdateSnapshot with FastEquatable {
  UpdateSnapshot({
    required this.state,
    required this.preferences,
    required this.lastSuccess,
    required this.pendingAnnouncement,
    required this.updatedTo,
    this.trustDamaged = false,
  });

  static final initial = UpdateSnapshot(
    state: UpdateIdle(),
    preferences: UpdatePreferences.defaults,
    lastSuccess: null,
    pendingAnnouncement: null,
    updatedTo: null,
  );

  final UpdateState state;
  final UpdatePreferences preferences;
  final DateTime? lastSuccess;

  /// A release a scheduled check found that the browser has not announced
  /// yet.
  final UpdateAssessment? pendingAnnouncement;

  /// The version this installation just updated itself to, confirmed once as
  /// "Updated to X".
  final String? updatedTo;

  /// The trust state is damaged without blocking anything
  /// ([UpdateBackend.trustDamaged]). The Updates screen offers the reset
  /// beside [state], whose actions stay available.
  final bool trustDamaged;

  @override
  List<Object?> get hashParameters => [
    state,
    preferences,
    lastSuccess,
    pendingAnnouncement,
    updatedTo,
    trustDamaged,
  ];
}

/// The single owner of the updater's state.
///
/// At most one operation runs at a time, and no lock is held across
/// asynchronous work: whether an operation may start is decided, and the
/// operation reserved, in one synchronous step ([_afterRecovery]).
///
/// - A check asked for while any operation runs joins it.
/// - A download or an installation joins a running one of its own kind. One
///   of another kind never swallows it: the request waits for it to end, then
///   decides again on the state it left ([_whenFree]).
/// - Continue, Cancel and the reset act on what they find and never queue.
///   Cancel only trips the running operation's token.
///
/// Recovery is exclusive. Operations wait for it, and platform events that
/// arrive meanwhile are held back and applied on top of what it publishes.
/// The backend's foreground refresh runs the same way.
///
/// From the commit of an installation until Android reports its outcome, the
/// install slot is reserved. That is part of the state, not a held lock, and
/// nothing new starts while it is.
class UpdateCoordinator {
  UpdateCoordinator({required this.backend, required this.repository});

  static const _scheduler = UpdateScheduler();

  final UpdateBackend backend;
  final UpdateStateRepository repository;

  final _snapshots = BehaviorSubject<UpdateSnapshot>.seeded(
    UpdateSnapshot.initial,
    sync: true,
  );
  final _notices = StreamController<UpdateNotice>.broadcast();

  UpdateMiscState _misc = UpdateMiscState.empty;
  StreamSubscription<UpdateEvent>? _eventSubscription;
  Future<void>? _starting;
  var _disposed = false;

  _Operation? _active;

  /// The recovery in flight, or a foreground refresh, which runs as one.
  /// Every operation waits for it before it looks at the state, so recovery
  /// never overwrites what an operation started.
  Future<void>? _recovering;

  /// Platform events that arrived while [_recovering]. They are newer than
  /// what it read, so they apply on top of what it publishes.
  final _heldEvents = <UpdateEvent>[];

  /// Recovery threw: a platform channel or IO error, not damaged trust
  /// state, which the backend reports as a state. It runs again on the next
  /// foreground return.
  var _recoveryOwed = false;

  UpdateSnapshot get snapshot => _snapshots.value;
  UpdateState get state => snapshot.state;

  /// The current snapshot, then every change.
  ValueStream<UpdateSnapshot> get snapshots => _snapshots.stream;
  Stream<UpdateNotice> get notices => _notices.stream;

  /// Recovers the state, then checks for an update if one is due. Later calls
  /// return the first call's future.
  Future<void> start() => _starting ??= _start();

  /// Back in the foreground: retries a recovery that failed, lets the backend
  /// re-read what may have changed while away, then checks if one is due.
  Future<void> onResume() async {
    if (_starting == null || _disposed) return;
    await _starting;

    if (_recoveryOwed && _active == null) await _recover();

    final (:before, :after) = await _refreshOnResume();
    // Back from the permission screen with the permission granted: continue
    // the installation the user asked for.
    if (before is UpdateAwaitingPermission && after is UpdateReadyToInstall) {
      await requestInstallation(after.assessment.targetId);
      return;
    }

    await _checkIfDue();
  }

  Future<void> dispose() async {
    _disposed = true;
    _active?.cancel.cancel();
    await _eventSubscription?.cancel();
    await _snapshots.close();
    await _notices.close();
  }

  /// [manual] is a check the user asked for on the Updates screen.
  Future<void> checkForUpdate({required bool manual}) =>
      _runCheck(scheduled: !manual);

  /// GitHub: downloads and verifies the update. Play: starts the flexible
  /// flow.
  Future<void> prepareUpdate(String targetId) =>
      _whenFree(UpdateOperation.download, () => _prepare(targetId));

  Future<void> requestInstallation(String targetId) =>
      _whenFree(UpdateOperation.install, () => _install(targetId));

  /// "Continue" for a session waiting for the system confirmation, also
  /// beneath a failure of an earlier attempt (Retry).
  Future<void> continueInstallation() => _afterRecovery(_continueInstallation);

  /// Cancels the running download, or the session of an installation, also
  /// beneath a failure shown on top of it.
  Future<void> cancelUpdate() => _afterRecovery(_cancelUpdate);

  /// "Reset and check again". The reset and the check are one operation, so
  /// no other check reads the trust state while it is deleted.
  Future<void> resetTrustAndCheck() => _afterRecovery(_resetTrustAndCheck);

  /// Never throws, because callers don't wait for it. An answer that can't be
  /// stored still applies until the process ends; the next start reads the
  /// file as it was.
  Future<void> setAutomaticChecks({required bool enabled}) async {
    var preferences = UpdatePreferences(
      automaticChecks: enabled,
      recoveryRequired: false,
    );
    try {
      preferences = await repository.writePreferences(preferences);
    } catch (error, stackTrace) {
      logger.w(
        'Could not store update preferences',
        error: error,
        stackTrace: stackTrace,
      );
    }
    if (_disposed) return;
    _emit(snapshot.copyWith(preferences: preferences));

    if (enabled) {
      await _checkIfDue();
    } else {
      // Only a scheduled check that happens to run, never a download or an
      // installation the user started.
      if (_active case final active? when active.scheduled) {
        active.cancel.cancel();
      }
      _emit(snapshot.copyWith(pendingAnnouncement: null));
    }
  }

  /// The browser showed the announcement. It is never shown again.
  Future<void> acknowledgeAnnouncement() async {
    final pending = snapshot.pendingAnnouncement;
    if (pending == null) return;

    _emit(snapshot.copyWith(pendingAnnouncement: null));
    await _recordAnnounced(pending);
  }

  void acknowledgeUpdatedNotice() => _emit(snapshot.copyWith(updatedTo: null));

  Future<void> _start() async {
    // Exclusive from before the first await: an operation asked for while
    // the preferences are read waits for recovery too.
    await _runAsRecovery(_initialRecovery);
    await _checkIfDue();
  }

  Future<void> _initialRecovery() async {
    try {
      final preferences = await repository.readPreferences();
      _misc = await repository.readMisc();
      _emit(
        snapshot.copyWith(
          preferences: preferences,
          lastSuccess: _misc.lastSuccess,
        ),
      );
    } catch (_) {
      // The store handles unreadable preferences itself. Whatever else fails
      // here must not stop recovery, and automatic work stays off.
      _emit(snapshot.copyWith(preferences: UpdatePreferences.recovered));
    }

    _eventSubscription = backend.events.listen(_onEvent);
    await _runRecovery();
  }

  /// Joins the recovery in flight, or starts one.
  Future<void> _recover() => _recovering ?? _runAsRecovery(_runRecovery);

  /// Damaged trust state is no exception here: the backend reports it as a
  /// `stateCorrupt` state. Whatever escapes is a failure to *read* the state,
  /// which must never offer "Reset and check again", because the reset lowers
  /// the revision floor. The state then stays as it is, and the next
  /// foreground return tries again.
  Future<void> _runRecovery() async {
    final before = state;
    RecoveryOutcome outcome;
    try {
      outcome = await backend.recover();
    } on UpdateFailure catch (failure) {
      outcome = RecoveryOutcome(
        UpdateFailed(
          failure,
          returnTo: UpdateIdle(),
          operation: UpdateOperation.check,
        ),
      );
    } catch (error, stackTrace) {
      logger.w(
        'App update recovery failed',
        error: error,
        stackTrace: stackTrace,
      );
      _recoveryOwed = true;
      return;
    }
    _recoveryOwed = false;

    _noteTrustDamage();
    if (outcome.updatedTo case final updatedTo?) {
      _emit(snapshot.copyWith(updatedTo: updatedTo));
    }
    // An event that moved the state meanwhile is newer than what recovery
    // read.
    if (identical(state, before)) _setState(outcome.state);
  }

  /// The backend's foreground refresh runs as a recovery: operations wait for
  /// it and events are held, so nothing moves the state while it runs, and
  /// what it reports is never dropped. That matters because reconciling
  /// retires a native outcome as it reports it.
  ///
  /// Skipped while an operation runs: that operation's result is the newer
  /// evidence.
  Future<({UpdateState before, UpdateState? after})> _refreshOnResume() =>
      _afterRecovery(() async {
        final before = state;
        if (_active != null || _disposed) return (before: before, after: null);

        final after = await _runAsRecovery(() => _foregroundRefresh(before));
        return (before: before, after: after);
      });

  Future<UpdateState?> _foregroundRefresh(UpdateState current) async {
    final UpdateState? refreshed;
    try {
      refreshed = await backend.onResume(current);
    } catch (_) {
      // A refresh that fails leaves the state as it was.
      return null;
    }
    if (refreshed != null) _setState(refreshed);
    return refreshed;
  }

  /// Runs [work] as the recovery in flight ([_recovering]).
  Future<T> _runAsRecovery<T>(Future<T> Function() work) {
    final running = work().whenComplete(_endRecovery);
    _recovering = running;
    return running;
  }

  void _endRecovery() {
    _recovering = null;
    final held = List.of(_heldEvents);
    _heldEvents.clear();
    held.forEach(_apply);
  }

  Future<void> _checkIfDue() async {
    if (!snapshot.preferences.automaticChecks) return;
    if (!_scheduler.isDue(_misc, clock.now())) return;
    await _runCheck(scheduled: true);
  }

  Future<void> _runCheck({required bool scheduled}) async {
    if (_disposed) return;
    if (scheduled && !snapshot.preferences.automaticChecks) return;

    await _afterRecovery(() async {
      if (_active case final active?) {
        await active.done.future;
        return;
      }
      if (_installSlotReserved) return;

      final operation = _begin(UpdateOperation.check, scheduled: scheduled);
      await _check(operation, returnTo: _restingState(state));
    });
  }

  /// The check itself, as [operation]. A cancelled or failed check returns to
  /// [returnTo].
  Future<void> _check(
    _Operation operation, {
    required UpdateState returnTo,
  }) async {
    _setState(UpdateChecking());
    await _recordMisc((misc) => _scheduler.recordAttempt(misc, clock.now()));

    try {
      final result = await backend.check(cancel: operation.cancel);
      if (operation.cancel.isCancelled) {
        _setState(returnTo);
        return;
      }

      await _recordMisc((misc) => _scheduler.recordSuccess(misc, clock.now()));
      _setState(_keepingPermissionWait(returnTo, result));
      _emit(snapshot.copyWith(lastSuccess: _misc.lastSuccess));
      await _considerAnnouncement(result, manual: !operation.scheduled);
    } on OperationCancelled {
      _setState(returnTo);
    } catch (error) {
      await _recordMisc((misc) => _scheduler.recordFailure(misc, clock.now()));
      _fail(operation, error, UpdateFailureKind.network, returnTo: returnTo);
    } finally {
      // A check accepts catalogues, and one follows every reset: the two ways
      // the trust state changes after recovery has read it.
      _noteTrustDamage();
      _end(operation);
    }
  }

  // Admitted by _afterRecovery or _whenFree: each of these decides and
  // reaches _begin (or gives up) before its first await.

  Future<void> _prepare(String targetId) async {
    final current = _restingState(state);
    if (current is! UpdateAvailable ||
        current.assessment.targetId != targetId) {
      return;
    }

    final operation = _begin(UpdateOperation.download, scheduled: false);
    await _run(
      operation,
      returnTo: current,
      fallback: UpdateFailureKind.network,
      () async {
        try {
          final result = await backend.prepare(
            current.assessment,
            onProgress: (progress) {
              // Progress reported after the download ended is stale.
              if (identical(_active, operation)) _setState(progress);
            },
            cancel: operation.cancel,
          );
          _setState(result);
          // A cancelled download leaves the update available. Verification
          // can't be cancelled, so a Cancel too late to stop the download
          // leaves it ready instead, and nothing was cancelled.
          if (operation.cancel.isCancelled && result is UpdateAvailable) {
            _notify(UpdateNotice.downloadCancelled);
          }
        } on OperationCancelled {
          _setState(current);
          _notify(UpdateNotice.downloadCancelled);
        }
      },
    );
  }

  Future<void> _install(String targetId) async {
    final assessment = switch (_restingState(state)) {
      UpdateReadyToInstall(:final assessment) ||
      UpdateAwaitingPermission(:final assessment) => assessment,
      _ => null,
    };
    if (assessment == null || assessment.targetId != targetId) return;

    final operation = _begin(UpdateOperation.install, scheduled: false);
    await _run(
      operation,
      returnTo: UpdateReadyToInstall(assessment),
      fallback: UpdateFailureKind.installUnknown,
      () async => _setState(await backend.requestInstallation(assessment)),
    );
  }

  Future<void> _continueInstallation() async {
    final current = state.underlying;
    if (current is! UpdateAwaitingUserAction || _active != null) return;

    final operation = _begin(UpdateOperation.install, scheduled: false);
    await _run(
      operation,
      returnTo: current,
      fallback: UpdateFailureKind.installUnknown,
      () async => _setState(await backend.continueInstallation(current)),
    );
  }

  Future<void> _cancelUpdate() async {
    if (_active case final active?) {
      if (active.kind != UpdateOperation.install) active.cancel.cancel();
      return;
    }
    if (!_installSlotReserved) return;

    final current = state.underlying;
    final operation = _begin(
      UpdateOperation.cancelInstallation,
      scheduled: false,
    );
    await _run(
      operation,
      returnTo: current,
      fallback: UpdateFailureKind.installUnknown,
      () async {
        final next = await backend.cancelInstallation(current);
        _setState(next);
        // Android may have taken the session past the point where it can be
        // abandoned: only a session that is gone was cancelled.
        if (!_holdsInstallSlot(next)) {
          _notify(UpdateNotice.installationCancelled);
        }
      },
    );
  }

  Future<void> _resetTrustAndCheck() async {
    if (!backend.canResetTrust || _active != null || _installSlotReserved) {
      return;
    }

    final operation = _begin(UpdateOperation.check, scheduled: false);
    try {
      await backend.resetTrust();
    } catch (error) {
      _fail(
        operation,
        error,
        UpdateFailureKind.stateCorrupt,
        returnTo: _restingState(state),
      );
      _noteTrustDamage();
      _end(operation);
      return;
    }
    await _check(operation, returnTo: UpdateIdle());
  }

  /// Runs [admit] once no recovery is in flight, in the same synchronous step
  /// as the last look at [_recovering]. [admit] must decide and reach
  /// [_begin] (or give up) before its first await.
  ///
  /// Waiting in a helper and deciding in the caller would not do: the caller
  /// resumes a microtask later, after a second foreground return may have
  /// started another refresh, which would then run beside the operation and
  /// overwrite what it publishes.
  Future<T> _afterRecovery<T>(Future<T> Function() admit) async {
    for (
      var recovering = _recovering;
      recovering != null;
      recovering = _recovering
    ) {
      await recovering;
    }
    return await admit();
  }

  /// Runs [start] once no recovery and no operation is in flight. A running
  /// operation of the same [kind] is joined: the request was that one's. One
  /// of another kind (a check started on resume, say) never swallows the
  /// request: once it ends, [start] decides on the state it left.
  ///
  /// [start] runs in the same synchronous step as the look at [_active], so
  /// a request made at the same moment finds the slot taken.
  Future<void> _whenFree(UpdateOperation kind, Future<void> Function() start) =>
      _afterRecovery(() async {
        final active = _active;
        if (active == null) {
          await start();
          return;
        }

        await active.done.future;
        if (active.kind != kind) await _whenFree(kind, start);
      });

  _Operation _begin(UpdateOperation kind, {required bool scheduled}) =>
      _active = _Operation(kind, scheduled: scheduled);

  /// Runs [body] as [operation]. Whatever it throws becomes a failure of that
  /// operation, returning to [returnTo].
  Future<void> _run(
    _Operation operation,
    Future<void> Function() body, {
    required UpdateState returnTo,
    required UpdateFailureKind fallback,
  }) async {
    try {
      await body();
    } catch (error) {
      _fail(operation, error, fallback, returnTo: returnTo);
    } finally {
      _end(operation);
    }
  }

  void _fail(
    _Operation operation,
    Object error,
    UpdateFailureKind fallback, {
    required UpdateState returnTo,
  }) => _setState(
    UpdateFailed(
      UpdateFailure.from(error, fallback),
      returnTo: returnTo,
      operation: operation.kind,
    ),
  );

  void _end(_Operation operation) {
    if (identical(_active, operation)) _active = null;
    if (!operation.done.isCompleted) operation.done.complete();
  }

  /// Announces a release a scheduled check found, once. One the user found
  /// themselves is recorded as announced instead.
  Future<void> _considerAnnouncement(
    UpdateState result, {
    required bool manual,
  }) async {
    final assessment = switch (result) {
      UpdateAvailable(:final assessment) ||
      UpdateReadyToInstall(:final assessment) => assessment,
      _ => null,
    };
    if (assessment == null) return;

    final announced = _misc.announcedSequence;
    if (announced != null && announced >= assessment.releaseSequence) return;

    if (manual || !snapshot.preferences.automaticChecks) {
      // The user is looking at the Updates screen already: never announce
      // this release later.
      await _recordAnnounced(assessment);
      return;
    }
    _emit(snapshot.copyWith(pendingAnnouncement: assessment));
  }

  Future<void> _recordAnnounced(UpdateAssessment assessment) => _recordMisc(
    (misc) => misc.copyWith(announcedSequence: assessment.releaseSequence),
  );

  void _onEvent(UpdateEvent event) {
    if (_disposed) return;
    if (_recovering != null) {
      _heldEvents.add(event);
    } else {
      _apply(event);
    }
  }

  void _apply(UpdateEvent event) {
    if (_disposed) return;
    final next = event.reduce(state);
    if (next == null) return;

    _setState(next);
    if (event.onApplied case final onApplied?) {
      unawaited(_acknowledge(onApplied));
    }
  }

  static Future<void> _acknowledge(Future<void> Function() onApplied) async {
    try {
      await onApplied();
    } catch (error, stackTrace) {
      // Unacknowledged, native reports the outcome again at recovery.
      logger.w(
        'Could not acknowledge an update event',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Also beneath a failure: a failed Continue or Cancel leaves the session
  /// as it was, and nothing may start over it.
  bool get _installSlotReserved => _holdsInstallSlot(state);

  static bool _holdsInstallSlot(UpdateState state) =>
      switch (state.underlying) {
        UpdateInstalling() || UpdateAwaitingUserAction() => true,
        _ => false,
      };

  /// A check that finds the same file still ready keeps the wait for the
  /// install permission, so returning with it granted still continues the
  /// installation.
  static UpdateState _keepingPermissionWait(
    UpdateState previous,
    UpdateState result,
  ) => switch ((previous, result)) {
    (
      UpdateAwaitingPermission(assessment: final waiting),
      UpdateReadyToInstall(:final assessment),
    )
        when waiting.targetId == assessment.targetId =>
      UpdateAwaitingPermission(assessment),
    _ => result,
  };

  /// What a failure returns to. Transient states never become a place to
  /// return to.
  static UpdateState _restingState(UpdateState state) => switch (state) {
    UpdateFailed(:final returnTo) => _restingState(returnTo),
    UpdateChecking() => UpdateIdle(),
    UpdateDownloading(:final assessment) ||
    UpdateVerifying(:final assessment) => UpdateAvailable(assessment),
    _ => state,
  };

  /// Bookkeeping that can't be stored still applies in memory.
  Future<void> _recordMisc(
    UpdateMiscState Function(UpdateMiscState misc) update,
  ) async {
    try {
      _misc = await repository.updateMisc(update);
    } catch (_) {
      _misc = update(_misc);
    }
  }

  void _setState(UpdateState next) => _emit(snapshot.copyWith(state: next));

  void _noteTrustDamage() =>
      _emit(snapshot.copyWith(trustDamaged: backend.trustDamaged));

  /// An operation that [dispose] cancelled unwinds after the stream closed.
  void _notify(UpdateNotice notice) {
    if (!_disposed) _notices.add(notice);
  }

  void _emit(UpdateSnapshot next) {
    if (_disposed || next == snapshot) return;
    _snapshots.add(next);
  }
}

/// The operation holding the slot.
class _Operation {
  _Operation(this.kind, {required this.scheduled});

  final UpdateOperation kind;

  /// A check the scheduler started rather than the user. Switching automatic
  /// checks off cancels only these.
  final bool scheduled;

  final cancel = CancelToken();

  /// Completes once the operation ended, however it ended.
  final done = Completer<void>();
}
