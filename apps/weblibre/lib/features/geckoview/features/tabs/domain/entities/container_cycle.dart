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

/// Direction of a step through the container cycle.
enum ContainerCycleDirection { next, previous }

/// Index into [containerIds] of the container one step [direction] from
/// [currentId], wrapping around at both ends.
///
/// [containerIds] mirrors the container chip row: the unassigned
/// pseudo-container (`null`) first, then the containers in chip order. Returns
/// null when there is nowhere to go — fewer than two destinations, or
/// [currentId] is not among them, which happens when the selected container is
/// deleted while a gesture is in flight.
int? adjacentContainerIndex(
  List<String?> containerIds,
  String? currentId,
  ContainerCycleDirection direction,
) {
  if (containerIds.length < 2) {
    return null;
  }

  final currentIndex = containerIds.indexOf(currentId);
  if (currentIndex < 0) {
    return null;
  }

  final step = switch (direction) {
    ContainerCycleDirection.next => 1,
    ContainerCycleDirection.previous => -1,
  };

  return (currentIndex + step) % containerIds.length;
}
