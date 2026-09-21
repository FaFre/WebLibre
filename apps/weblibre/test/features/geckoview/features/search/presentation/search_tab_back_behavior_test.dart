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
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/screens/search.dart';

void main() {
  group('resolveSearchTabBackBehavior', () {
    test('leads home, the surface the search screen was opened from', () {
      // The reported case (#623): a shortcut tapped on the new tab page used to
      // leave a tab that back could only close, while the same shortcut on the
      // home page led back to it.
      expect(
        resolveSearchTabBackBehavior(launchedFromIntent: false, parentId: null),
        isA<ReturnToBrowserHomeTabBackBehavior>(),
      );
    });

    test('leaves an intent-launched tab to the app that sent it', () {
      // Back belongs to the sender; TabRepository.addTab fills in
      // BackgroundAppTabBackBehavior for exactly this case, and saying nothing
      // here is what lets it.
      expect(
        resolveSearchTabBackBehavior(launchedFromIntent: true, parentId: null),
        isNull,
      );
    });

    test('leaves a child tab to its opener', () {
      expect(
        resolveSearchTabBackBehavior(
          launchedFromIntent: false,
          parentId: 'opener',
        ),
        isNull,
      );
    });

    test('an intent-launched child stays with the sender', () {
      expect(
        resolveSearchTabBackBehavior(
          launchedFromIntent: true,
          parentId: 'opener',
        ),
        isNull,
      );
    });
  });
}
