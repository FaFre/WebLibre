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

import 'package:weblibre/features/app_update/domain/entities/update_assessment.dart';
import 'package:weblibre/features/app_update/domain/entities/update_state.dart';

/// Tripped by `cancelUpdate()`. Long-running work checks it between chunks
/// and aborts its in-flight request through [whenCancelled].
class CancelToken {
  final _completer = Completer<void>();

  bool get isCancelled => _completer.isCompleted;

  Future<void> get whenCancelled => _completer.future;

  void cancel() {
    if (!_completer.isCompleted) _completer.complete();
  }

  /// Waits for [future], or throws [OperationCancelled] as soon as this is
  /// cancelled, whichever comes first. What [future] does after a cancel is
  /// dropped.
  Future<void> orCancelled(Future<void> future) async {
    if (isCancelled) throw const OperationCancelled();
    await Future.any([future, whenCancelled]);
    if (isCancelled) throw const OperationCancelled();
  }
}

class OperationCancelled implements Exception {
  const OperationCancelled();
}

/// What recovery at start found (7.6).
class RecoveryOutcome {
  const RecoveryOutcome(this.state, {this.updatedTo});

  final UpdateState state;

  /// The version name to confirm once ("Updated to X") when the installation
  /// that just completed was ours.
  final String? updatedTo;
}

/// A platform event, as the coordinator applies it.
class UpdateEvent {
  const UpdateEvent(this.reduce, {this.onApplied});

  /// Returns null to drop an event that doesn't match the current state.
  final UpdateState? Function(UpdateState current) reduce;

  /// Runs once the state [reduce] returned is in place, never for a dropped
  /// event. Native keeps an outcome for recovery until this acknowledges it:
  /// sending an event is not delivering it.
  final Future<void> Function()? onApplied;
}

/// One distribution's way of checking, preparing and installing. The
/// coordinator owns state, concurrency and scheduling; a backend only turns
/// one operation into its resulting state. Every method may throw; the
/// coordinator maps whatever escapes to `failed`, so an updater failure never
/// blocks browsing.
abstract interface class UpdateBackend {
  /// Derives the state at start without the network.
  Future<RecoveryOutcome> recover();

  Future<UpdateState> check({required CancelToken cancel});

  /// GitHub: download and verify. Play: start the flexible flow.
  Future<UpdateState> prepare(
    UpdateAssessment assessment, {
    required void Function(UpdateState progress) onProgress,
    required CancelToken cancel,
  });

  /// GitHub: authorize, then commit a session. Play: complete the update.
  Future<UpdateState> requestInstallation(UpdateAssessment assessment);

  /// "Continue" for a session waiting for the system confirmation.
  Future<UpdateState> continueInstallation(UpdateState current);

  /// "Cancel" / "Cancel installation" for a session.
  Future<UpdateState> cancelInstallation(UpdateState current);

  /// Foreground return: re-reads what may have changed while away.
  Future<UpdateState?> onResume(UpdateState current);

  /// Platform events. The coordinator holds back those that arrive while
  /// recovery runs and applies them on top of what it publishes.
  Stream<UpdateEvent> get events;

  /// "Reset and check again" (6.1).
  Future<void> resetTrust();

  bool get canResetTrust;

  /// Trust state that is damaged but blocks nothing (Play's descriptions):
  /// shown beside the state with the reset, never in place of it. A backend
  /// whose trust state gates installation reports `stateCorrupt` as a
  /// failure instead, and answers false here.
  bool get trustDamaged;
}
