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
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/accordion_drop.dart';

/// Unassigned (expanded: u1, u2), container A (expanded: a1, a2), container B
/// (collapsed).
const slots = <AccordionSlot>[
  AccordionHeaderSlot(null), // 0
  AccordionTabSlot('u1', containerId: null), // 1
  AccordionTabSlot('u2', containerId: null), // 2
  AccordionHeaderSlot('A'), // 3
  AccordionTabSlot('a1', containerId: 'A'), // 4
  AccordionTabSlot('a2', containerId: 'A'), // 5
  AccordionHeaderSlot('B'), // 6
];

void main() {
  group('within a group', () {
    test('reorders a tab among its own group', () {
      // u1 dropped after u2. After removing u1 the list is
      // [H, u2, A, a1, a2, B], and "after u2" is index 2.
      final drop = resolveAccordionDrop(slots, oldIndex: 1, newIndex: 2);

      expect(drop, isA<AccordionReorderDrop>());
      final reorder = drop! as AccordionReorderDrop;
      expect(reorder.groupTabIds, ['u1', 'u2']);
      expect(reorder.oldIndex, 0);
      expect(reorder.newIndex, 1);
      expect(reorder.isNoop, isFalse);
    });

    test('dropping a tab back where it was is a no-op', () {
      // Indices count after the dragged tab is removed, so a1 staying right
      // after header A is 4 -> 4. 4 -> 3 would put it before header A, in the
      // unassigned group.
      final drop = resolveAccordionDrop(slots, oldIndex: 4, newIndex: 4);

      expect(drop, isA<AccordionReorderDrop>());
      expect((drop! as AccordionReorderDrop).isNoop, isTrue);
    });

    test('indices are relative to the group, not the whole list', () {
      // a2 dropped right after header A, ahead of a1. Without a2 the list is
      // [H, u1, u2, A, a1, B], and right after header A is index 4.
      final drop =
          resolveAccordionDrop(slots, oldIndex: 5, newIndex: 4)!
              as AccordionReorderDrop;

      expect(drop.groupTabIds, ['a1', 'a2']);
      expect(drop.oldIndex, 1);
      expect(drop.newIndex, 0);
    });
  });

  group('across groups', () {
    test('dropping into another expanded group moves the tab there', () {
      // u1 dropped between a1 and a2: after removal [H, u2, A, a1, a2, B],
      // between a1 and a2 is index 4.
      final drop =
          resolveAccordionDrop(slots, oldIndex: 1, newIndex: 4)!
              as AccordionMoveDrop;

      expect(drop.tabId, 'u1');
      expect(drop.targetContainerId, 'A');
      expect(drop.groupTabIds, ['a1', 'a2']);
      expect(drop.index, 1);
    });

    test('dropping onto a collapsed header moves the tab into it', () {
      // After removing a1, header B is the last item; a drop after it.
      final drop =
          resolveAccordionDrop(slots, oldIndex: 4, newIndex: 6)!
              as AccordionMoveDrop;

      expect(drop.tabId, 'a1');
      expect(drop.targetContainerId, 'B');
      expect(drop.groupTabIds, isEmpty);
      expect(drop.index, 0);
    });

    test('moving into the unassigned group targets a null container', () {
      final drop =
          resolveAccordionDrop(slots, oldIndex: 5, newIndex: 1)!
              as AccordionMoveDrop;

      expect(drop.tabId, 'a2');
      expect(drop.targetContainerId, isNull);
      expect(drop.groupTabIds, ['u1', 'u2']);
      expect(drop.index, 0);
    });
  });

  group('refused', () {
    test('a tab dropped ahead of every header', () {
      expect(resolveAccordionDrop(slots, oldIndex: 2, newIndex: 0), isNull);
    });

    test('a header being moved', () {
      expect(resolveAccordionDrop(slots, oldIndex: 3, newIndex: 0), isNull);
    });

    test('an index out of range', () {
      expect(resolveAccordionDrop(slots, oldIndex: 99, newIndex: 0), isNull);
    });
  });
}
