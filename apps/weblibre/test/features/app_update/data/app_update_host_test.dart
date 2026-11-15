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
import 'package:weblibre/features/app_update/data/native/app_update_host.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';

void main() {
  test('each native failure maps to the failure kind of its name', () {
    for (final failure in NativeFailure.values) {
      if (failure == NativeFailure.reservationActive) continue;
      expect(failure.kind.name, failure.name);
    }
    expect(
      NativeFailure.reservationActive.kind,
      UpdateFailureKind.installUnknown,
    );
    expect((null as NativeFailure?).kind, UpdateFailureKind.installUnknown);
  });
}
