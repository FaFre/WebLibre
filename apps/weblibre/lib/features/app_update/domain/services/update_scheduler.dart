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
import 'dart:math' as math;

import 'package:weblibre/features/app_update/domain/entities/update_preferences.dart';

/// When an automatic check is due (plan D15, 3.7): on start and on resume,
/// once every 24 hours, with exponential backoff after failures.
///
/// A stored time is only ever compared, never trusted: a last attempt that
/// lies in the future of the device clock (the clock was ahead when it was
/// recorded and has since been corrected) is stale, and a check is due now.
/// So correcting a wrong clock restores automatic checks at the next start or
/// resume, at the cost of at most one extra check.
class UpdateScheduler {
  const UpdateScheduler();

  static const interval = Duration(hours: 24);
  static const baseBackoff = Duration(minutes: 30);

  static const maxBackoffStep = 5;

  Duration backoffFor(int step) {
    if (step <= 0) return Duration.zero;
    final factor = math.pow(2, math.min(step, maxBackoffStep) - 1).toInt();
    final backoff = baseBackoff * factor;
    return backoff > interval ? interval : backoff;
  }

  bool isDue(UpdateMiscState misc, DateTime now) {
    final lastAttempt = misc.lastAttempt;
    if (lastAttempt == null) return true;
    if (lastAttempt.isAfter(now)) return true; // Recorded under a wrong clock.

    final lastSuccess = misc.lastSuccess;
    if (misc.backoffStep > 0) {
      return !now.isBefore(lastAttempt.add(backoffFor(misc.backoffStep)));
    }
    final since = lastSuccess != null && !lastSuccess.isAfter(now)
        ? lastSuccess
        : lastAttempt;
    return !now.isBefore(since.add(interval));
  }

  /// Every check records its attempt first, so this is where a last attempt
  /// recorded under a clock that was ahead is still visible: its backoff is
  /// dropped here, and a failure after the correction starts again at step 1.
  /// [recordFailure] only ever sees the attempt just recorded.
  UpdateMiscState recordAttempt(UpdateMiscState misc, DateTime now) {
    final stale = misc.lastAttempt != null && misc.lastAttempt!.isAfter(now);
    return misc.copyWith(
      lastAttempt: now,
      backoffStep: stale ? 0 : misc.backoffStep,
    );
  }

  UpdateMiscState recordSuccess(UpdateMiscState misc, DateTime now) =>
      misc.copyWith(lastAttempt: now, lastSuccess: now, backoffStep: 0);

  UpdateMiscState recordFailure(UpdateMiscState misc, DateTime now) =>
      misc.copyWith(
        lastAttempt: now,
        backoffStep: math.min(misc.backoffStep + 1, maxBackoffStep),
      );
}
