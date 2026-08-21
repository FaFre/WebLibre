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
 */
import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

/// Thrown when the maintenance lease no longer holds at a boundary.
///
/// Never caught to "carry on anyway". Losing the lease means another owner may
/// already be acting on the same profile, so the only safe response is to stop
/// where the journal says the operation stopped.
class MaintenanceLeaseLost implements Exception {
  const MaintenanceLeaseLost(this.boundary, [this.taskId]);

  final String boundary;
  final String? taskId;

  @override
  String toString() =>
      'MaintenanceLeaseLost(boundary: $boundary, task: $taskId)';
}

/// A fencing token for maintenance work, not an end-of-task receipt.
///
/// It is re-checked before *every* journal transition and every destructive
/// filesystem boundary, because the interesting failure is not "the lease was
/// invalid when we started" — it is a process that stalled long enough for the
/// watchdog to hand the reservation to someone else, and then woke up and carried
/// on deleting.
class MaintenanceLease {
  const MaintenanceLease({
    required this.leaseId,
    required this.taskId,
    this.heartbeatInterval = defaultHeartbeatInterval,
    GeckoProfileService? service,
  }) : _service = service;

  final String leaseId;
  final String? taskId;

  /// How often [keepAlive] renews the lease. Shortened by tests, which cannot wait
  /// out the real interval.
  final Duration heartbeatInterval;

  final GeckoProfileService? _service;

  GeckoProfileService get _api => _service ?? GeckoProfileService();

  /// Throws [MaintenanceLeaseLost] unless this lease still owns the process.
  ///
  /// An unreachable arbiter counts as lost. The alternative — assuming the lease
  /// still holds because nobody said otherwise — is exactly how a stalled process
  /// resumes destructive work it is no longer entitled to do.
  Future<void> assertHeld(String boundary) async {
    final bool held;
    try {
      held = await _api.assertMaintenanceLease(
        leaseId: leaseId,
        taskId: taskId,
        boundary: boundary,
      );
    } catch (_) {
      throw MaintenanceLeaseLost(boundary, taskId);
    }

    if (!held) {
      throw MaintenanceLeaseLost(boundary, taskId);
    }
  }

  Future<void> heartbeat() async {
    try {
      await _api.heartbeatMaintenance(leaseId);
    } catch (_) {
      // A missed heartbeat is not itself a failure; the next `assertHeld` is
      // what decides, and it fails closed.
    }
  }

  /// Keeps the lease renewed for as long as [body] runs.
  ///
  /// The boundary asserts are what *decide* whether work may continue, and each
  /// one also counts as proof of liveness — but the expensive steps sit between
  /// them. A full profile copy, an Argon2 pack and an unpack all routinely take
  /// longer than the native heartbeat timeout, so without a pump the watchdog
  /// hands the reservation back mid-operation and the next assert throws
  /// [MaintenanceLeaseLost] over work that was proceeding normally — discarding a
  /// finished backup and wedging the process into recovery.
  ///
  /// A timer is enough because the heavy steps run in their own isolates: this
  /// isolate's event loop stays free to fire it.
  Future<T> keepAlive<T>(Future<T> Function() body) async {
    var inFlight = false;

    final timer = Timer.periodic(heartbeatInterval, (_) {
      // One renewal at a time. A slow channel must not queue up calls that then
      // all arrive at once when it recovers.
      if (inFlight) return;
      inFlight = true;
      unawaited(heartbeat().whenComplete(() => inFlight = false));
    });

    try {
      return await body();
    } finally {
      timer.cancel();
    }
  }

  /// Well inside `StartupArbiter.MAINTENANCE_HEARTBEAT_TIMEOUT_MS` (60s), so one
  /// slow or dropped renewal is not enough to lose the reservation.
  static const defaultHeartbeatInterval = Duration(seconds: 15);
}
