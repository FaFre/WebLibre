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
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/app_update/domain/entities/update_preferences.dart';
import 'package:weblibre/features/app_update/domain/services/update_scheduler.dart';

void main() {
  const scheduler = UpdateScheduler();
  final now = DateTime.utc(2026, 12, 1, 12);

  test('due with no history', () {
    expect(scheduler.isDue(UpdateMiscState.empty, now), isTrue);
  });

  test('not due within 24 hours of a success, due after', () {
    final misc = scheduler.recordSuccess(UpdateMiscState.empty, now);
    expect(scheduler.isDue(misc, now.add(const Duration(hours: 23))), isFalse);
    expect(scheduler.isDue(misc, now.add(const Duration(hours: 24))), isTrue);
  });

  test('backoff grows after failures and resets on success', () {
    var misc = UpdateMiscState.empty;
    misc = scheduler.recordFailure(misc, now);
    expect(
      scheduler.isDue(misc, now.add(const Duration(minutes: 29))),
      isFalse,
    );
    expect(scheduler.isDue(misc, now.add(const Duration(minutes: 30))), isTrue);
    misc = scheduler.recordFailure(misc, now);
    expect(misc.backoffStep, 2);
    expect(
      scheduler.isDue(misc, now.add(const Duration(minutes: 59))),
      isFalse,
    );
    misc = scheduler.recordSuccess(misc, now);
    expect(misc.backoffStep, 0);
  });

  test(
    'a last attempt recorded under a future clock makes a check due once corrected',
    () {
      final future = DateTime.utc(2036);
      final misc = scheduler.recordFailure(
        scheduler.recordAttempt(UpdateMiscState.empty, future),
        future,
      );
      expect(scheduler.isDue(misc, now), isTrue);
    },
  );

  test('backoff does not extend across the correction', () {
    var misc = UpdateMiscState.empty;
    final future = DateTime.utc(2036);
    for (var i = 0; i < 5; i++) {
      misc = scheduler.recordFailure(misc, future);
    }
    expect(misc.backoffStep, 5);
    // As the coordinator runs a check: the attempt first, then its failure.
    misc = scheduler.recordFailure(scheduler.recordAttempt(misc, now), now);
    expect(misc.backoffStep, 1);
  });

  test('backoff is capped at the check interval', () {
    expect(scheduler.backoffFor(20), scheduler.backoffFor(5));
    expect(scheduler.backoffFor(5) <= const Duration(hours: 24), isTrue);
  });
}
