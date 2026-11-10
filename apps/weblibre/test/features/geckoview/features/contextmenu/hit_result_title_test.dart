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
  group('getTitle', () {
    test('shows the address of a mailto link, not about:blank', () {
      expect(
        EmailHitResult(src: 'mailto:jane%40example.com?subject=Hi').getTitle(),
        'jane@example.com',
      );
    });

    test('shows the number of a tel link', () {
      expect(PhoneHitResult(src: 'tel:+4912345').getTitle(), '+4912345');
    });

    test('shows a geo link as written', () {
      expect(GeoHitResult(src: 'geo:52.5,13.4').getTitle(), 'geo:52.5,13.4');
    });

    test('keeps a page-supplied media title', () {
      expect(
        ImageHitResult(
          src: 'https://cdn.example/a.png',
          title: 'A cat',
        ).getTitle(),
        'A cat',
      );
    });
  });

  group('getTitleUri', () {
    test('is the link of a plain link', () {
      expect(
        UnknownHitResult(src: 'https://example.com/a?b=1').getTitleUri(),
        Uri.parse('https://example.com/a?b=1'),
      );
    });

    test('is the link target of an image link', () {
      expect(
        ImageSrcHitResult(
          src: 'https://cdn.example/a.png',
          uri: 'https://example.com/page',
        ).getTitleUri(),
        Uri.parse('https://example.com/page'),
      );
    });

    test('is the source of untitled media', () {
      expect(
        ImageHitResult(src: 'https://cdn.example/a.png').getTitleUri(),
        Uri.parse('https://cdn.example/a.png'),
      );
      expect(
        VideoHitResult(
          src: 'https://cdn.example/v.mp4',
          title: '',
        ).getTitleUri(),
        Uri.parse('https://cdn.example/v.mp4'),
      );
    });

    test('is null when the title is page-supplied text', () {
      expect(
        ImageHitResult(
          src: 'https://cdn.example/a.png',
          title: 'A cat',
        ).getTitleUri(),
        isNull,
      );
    });

    test('is null for addresses without a host', () {
      for (final src in [
        'data:image/png;base64,iVBORw0KGgo/AAAA',
        'blob:https://example.com/0f0e',
        'javascript:void(0)',
        'file:///sdcard/a.pdf',
      ]) {
        expect(UnknownHitResult(src: src).getTitleUri(), isNull, reason: src);
      }
    });

    test('is null for mailto, tel and geo links', () {
      expect(EmailHitResult(src: 'mailto:a@b.c').getTitleUri(), isNull);
      expect(PhoneHitResult(src: 'tel:1').getTitleUri(), isNull);
      expect(GeoHitResult(src: 'geo:1,2').getTitleUri(), isNull);
    });
  });
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
