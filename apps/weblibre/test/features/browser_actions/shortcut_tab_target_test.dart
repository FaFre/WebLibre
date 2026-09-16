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
import 'package:weblibre/features/browser_actions/domain/services/browser_action_dispatcher.dart';

void main() {
  const order = ['a', 'b', 'c'];

  test('counts positions from one', () {
    expect(shortcutTabTarget(order, 1), 'a');
    expect(shortcutTabTarget(order, 3), 'c');
  });

  test('a position past the end selects nothing, like Firefox', () {
    expect(shortcutTabTarget(order, 4), isNull);
  });

  test('no position means the last tab, however many there are', () {
    expect(shortcutTabTarget(order, null), 'c');
    expect(shortcutTabTarget(const ['only'], null), 'only');
  });

  test('an empty tab bar has no target', () {
    expect(shortcutTabTarget(const [], 1), isNull);
    expect(shortcutTabTarget(const [], null), isNull);
  });
}
