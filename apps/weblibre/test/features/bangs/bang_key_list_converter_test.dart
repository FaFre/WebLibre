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
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';

void main() {
  const converter = BangKeyListConverter();

  group('BangKeyListConverter', () {
    test('round-trips keys in order', () {
      const keys = [
        BangKey(group: BangGroup.user, trigger: 'g'),
        BangKey(group: BangGroup.general, trigger: 'w'),
      ];

      expect(converter.fromJson(converter.toJson(keys)), keys);
    });

    test('drops an unparseable entry instead of the whole list', () {
      // One stale pin must not cost the user the rest of their pins.
      final decoded = converter.fromJson([
        'user::g',
        'not-a-key',
        'general::w',
      ]);

      expect(decoded.map((key) => key.trigger), ['g', 'w']);
    });

    test('reads a missing value as no pins', () {
      expect(converter.fromJson(null), isEmpty);
    });

    test('ignores non-string entries', () {
      expect(converter.fromJson([42, 'user::g']).single.trigger, 'g');
    });
  });
}
