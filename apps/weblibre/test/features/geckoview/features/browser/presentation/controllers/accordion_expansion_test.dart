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
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/accordion_expansion.dart';

void main() {
  group('side panel (several groups open)', () {
    test('tapping a collapsed group expands it next to the open ones', () {
      final expansion = const AccordionExpansion([
        'work',
      ]).toggle('home', multiple: true);

      expect(expansion.displayed(multiple: true), {'work', 'home'});
    });

    test('tapping an open group collapses only that group', () {
      final expansion = const AccordionExpansion([
        'work',
        'home',
      ]).toggle('work', multiple: true);

      expect(expansion.displayed(multiple: true), {'home'});
    });

    test('the current group can be collapsed', () {
      // The bug this replaces: expansion was the selected container, so the
      // open group's header selected what was already selected and did
      // nothing.
      final expansion = const AccordionExpansion([
        'work',
      ]).toggle('work', multiple: true);

      expect(expansion.displayed(multiple: true), isEmpty);
    });

    test('unassigned tabs are a group like any other', () {
      final expansion = const AccordionExpansion().toggle(null, multiple: true);

      expect(expansion.isExpanded(null, multiple: true), isTrue);
      expect(
        expansion.toggle(null, multiple: true).isExpanded(null, multiple: true),
        isFalse,
      );
    });
  });

  group('single row or narrow rail (one group open)', () {
    test('expanding a group closes the previous one', () {
      final expansion = const AccordionExpansion([
        'work',
      ]).toggle('home', multiple: false);

      expect(expansion.displayed(multiple: false), {'home'});
    });

    test('collapsing the open group leaves none open', () {
      // Not a fallback to whichever group was expanded before it.
      final expansion = const AccordionExpansion([
        'work',
        'home',
      ]).toggle('home', multiple: false);

      expect(expansion.displayed(multiple: false), isEmpty);
    });

    test('tapping a group that is not the open one opens it', () {
      // "work" is remembered but not shown, so it counts as collapsed.
      final expansion = const AccordionExpansion([
        'work',
        'home',
      ]).toggle('work', multiple: false);

      expect(expansion.displayed(multiple: false), {'work'});
    });
  });

  group('reveal', () {
    test('expands the group of a newly selected tab', () {
      final expansion = const AccordionExpansion(['work']).reveal('home');

      expect(expansion.displayed(multiple: true), {'work', 'home'});
      expect(expansion.displayed(multiple: false), {'home'});
    });

    test('makes an already open group the most recent one', () {
      final expansion = const AccordionExpansion([
        'work',
        'home',
      ]).reveal('work');

      expect(expansion.order, ['home', 'work']);
      expect(expansion.displayed(multiple: false), {'work'});
    });

    test('keeps no duplicates', () {
      final expansion = const AccordionExpansion()
          .reveal('work')
          .reveal('work');

      expect(expansion.order, ['work']);
    });
  });
}
