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

/// One row of the accordion tab switcher, reduced to what a drop needs.
sealed class AccordionSlot {
  const AccordionSlot();
}

/// A container group header. [containerId] is null for unassigned tabs.
class AccordionHeaderSlot extends AccordionSlot {
  final String? containerId;

  const AccordionHeaderSlot(this.containerId);
}

/// A tab shown inside the group of [containerId].
class AccordionTabSlot extends AccordionSlot {
  final String tabId;
  final String? containerId;

  const AccordionTabSlot(this.tabId, {required this.containerId});
}

/// What dropping a dragged tab at a position in the accordion means.
sealed class AccordionDrop {
  const AccordionDrop();
}

/// Reorders a tab inside its own group.
///
/// [groupTabIds] are the group's tabs as shown, including the moving one;
/// [oldIndex] and [newIndex] index into it the way `buildTabViewReorderResult`
/// expects, with [newIndex] counted after the moving tab is removed.
class AccordionReorderDrop extends AccordionDrop {
  final List<String> groupTabIds;
  final int oldIndex;
  final int newIndex;

  const AccordionReorderDrop({
    required this.groupTabIds,
    required this.oldIndex,
    required this.newIndex,
  });

  bool get isNoop => oldIndex == newIndex;
}

/// Moves [tabId] into the group of [targetContainerId], landing at [index]
/// among that group's shown tabs, [groupTabIds], which exclude the moving tab.
/// A collapsed group shows none, so a drop onto its header lands at 0.
class AccordionMoveDrop extends AccordionDrop {
  final String tabId;
  final String? targetContainerId;
  final List<String> groupTabIds;
  final int index;

  const AccordionMoveDrop({
    required this.tabId,
    required this.targetContainerId,
    required this.groupTabIds,
    required this.index,
  });
}

/// Resolves a drop reported by `ReorderableListView.onReorderItem` over
/// [slots]: the item at [oldIndex] moved to [newIndex], counted after its
/// removal.
///
/// A tab belongs to the group of the nearest header before the position it is
/// dropped at, so dropping right after a collapsed header moves it into that
/// container. Returns null for a drop that means nothing: a header being moved,
/// or a tab dropped ahead of every header.
AccordionDrop? resolveAccordionDrop(
  List<AccordionSlot> slots, {
  required int oldIndex,
  required int newIndex,
}) {
  if (oldIndex < 0 || oldIndex >= slots.length) return null;
  final moving = slots[oldIndex];
  if (moving is! AccordionTabSlot) return null;

  final remaining = [...slots]..removeAt(oldIndex);
  final insertIndex = newIndex.clamp(0, remaining.length);

  var headerIndex = -1;
  for (var i = insertIndex - 1; i >= 0; i--) {
    if (remaining[i] is AccordionHeaderSlot) {
      headerIndex = i;
      break;
    }
  }
  if (headerIndex < 0) return null;

  final target = (remaining[headerIndex] as AccordionHeaderSlot).containerId;
  final position = insertIndex - (headerIndex + 1);

  if (target == moving.containerId) {
    final groupTabIds = _groupTabIds(slots, moving.containerId);
    return AccordionReorderDrop(
      groupTabIds: groupTabIds,
      oldIndex: groupTabIds.indexOf(moving.tabId),
      newIndex: position,
    );
  }

  return AccordionMoveDrop(
    tabId: moving.tabId,
    targetContainerId: target,
    groupTabIds: _groupTabIds(remaining, target),
    index: position,
  );
}

/// The tabs shown under the header of [containerId], in order.
List<String> _groupTabIds(List<AccordionSlot> slots, String? containerId) {
  final headerIndex = slots.indexWhere(
    (slot) => slot is AccordionHeaderSlot && slot.containerId == containerId,
  );
  if (headerIndex < 0) return const [];

  return [
    for (final slot
        in slots
            .skip(headerIndex + 1)
            .takeWhile((slot) => slot is AccordionTabSlot))
      (slot as AccordionTabSlot).tabId,
  ];
}
