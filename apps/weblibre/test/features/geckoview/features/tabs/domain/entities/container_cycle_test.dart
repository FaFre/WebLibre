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
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_cycle.dart';

void main() {
  group('adjacentContainerIndex', () {
    const order = [null, 'work', 'shopping'];

    test('steps forward and backward through the chip order', () {
      expect(
        adjacentContainerIndex(order, 'work', ContainerCycleDirection.next),
        2,
      );
      expect(
        adjacentContainerIndex(order, 'work', ContainerCycleDirection.previous),
        0,
      );
    });

    test('wraps around at both ends', () {
      expect(
        adjacentContainerIndex(order, 'shopping', ContainerCycleDirection.next),
        0,
      );
      expect(
        adjacentContainerIndex(order, null, ContainerCycleDirection.previous),
        2,
      );
    });

    test('treats the unassigned pseudo-container as a destination', () {
      expect(
        adjacentContainerIndex(order, null, ContainerCycleDirection.next),
        1,
      );
    });

    test('has nowhere to go with a single destination', () {
      expect(
        adjacentContainerIndex(
          const [null],
          null,
          ContainerCycleDirection.next,
        ),
        isNull,
      );
      expect(
        adjacentContainerIndex(
          const [],
          null,
          ContainerCycleDirection.previous,
        ),
        isNull,
      );
    });

    test('stays put when the selection is no longer in the order', () {
      expect(
        adjacentContainerIndex(order, 'deleted', ContainerCycleDirection.next),
        isNull,
      );
    });
  });
}
