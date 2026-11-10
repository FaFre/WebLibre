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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';

void main() {
  group('tryGetEmailAddress', () {
    test('reads the address of an EmailHitResult, as AC delivers mailto', () {
      final hit = EmailHitResult(src: 'mailto:jane%40example.com?subject=Hi');
      expect(hit.tryGetEmailAddress(), 'jane@example.com');
      expect(hit.isMailto(), isTrue);
    });

    test('accepts a mailto UnknownHitResult', () {
      final hit = UnknownHitResult(src: 'mailto:jane@example.com');
      expect(hit.tryGetEmailAddress(), 'jane@example.com');
      expect(hit.isMailto(), isTrue);
    });

    test('is null for a mailto link without an address', () {
      final hit = EmailHitResult(src: 'mailto:?subject=Hi');
      expect(hit.tryGetEmailAddress(), isNull);
      expect(hit.isMailto(), isFalse);
    });

    test('is null for other links', () {
      expect(
        UnknownHitResult(src: 'https://example.com/').tryGetEmailAddress(),
        isNull,
      );
      expect(PhoneHitResult(src: 'tel:1').isMailto(), isFalse);
    });
  });
  group('phone links', () {
    test('read the number of a PhoneHitResult, as AC delivers tel', () {
      final hit = PhoneHitResult(src: 'tel:+49%2030%201234');
      expect(hit.tryGetPhoneNumber(), '+49 30 1234');
      expect(hit.tryGetPhoneUri(), Uri.parse('tel:+49%2030%201234'));
      expect(hit.isTel(), isTrue);
    });

    test('accept a tel UnknownHitResult', () {
      final hit = UnknownHitResult(src: 'tel:+4912345');
      expect(hit.tryGetPhoneNumber(), '+4912345');
      expect(hit.isTel(), isTrue);
    });

    test('are not offered for a tel link without a number', () {
      expect(PhoneHitResult(src: 'tel:').isTel(), isFalse);
    });

    test('are not offered for other links', () {
      expect(UnknownHitResult(src: 'https://example.com/').isTel(), isFalse);
      expect(EmailHitResult(src: 'mailto:a@b.c').isTel(), isFalse);
    });
  });
}
