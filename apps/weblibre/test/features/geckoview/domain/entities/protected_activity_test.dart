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
import 'package:weblibre/features/geckoview/domain/entities/protected_activity.dart';

void main() {
  test('typed text is asked about, like media and a POST result', () {
    expect(
      refusedOnlyToAsk(LifecycleFailure.protectedActivity, const [
        ProtectedActivity.formData,
        ProtectedActivity.media,
      ]),
      isTrue,
    );
  });

  test('anything that refuses still refuses beside typed text', () {
    expect(
      refusedOnlyToAsk(LifecycleFailure.protectedActivity, const [
        ProtectedActivity.formData,
        ProtectedActivity.upload,
      ]),
      isFalse,
    );
  });

  test('counts each tab once per kind', () {
    expect(
      countCutOffTabs(const [
        ('a', ProtectedActivity.formData),
        ('a', ProtectedActivity.media),
        ('b', ProtectedActivity.formData),
      ]),
      (mediaTabs: 1, postResultTabs: 0, formDataTabs: 2),
    );
  });

  test('form input is agreed to per tab, media and POST results at once', () {
    final consent = CutOffConsent()
      ..agreeTo(const [
        ('a', ProtectedActivity.formData),
        ('a', ProtectedActivity.media),
      ]);

    expect(consent.covers('a', ProtectedActivity.formData), isTrue);
    expect(consent.covers('b', ProtectedActivity.formData), isFalse);
    expect(consent.covers('b', ProtectedActivity.media), isTrue);
    expect(consent.covers('a', ProtectedActivity.postResult), isFalse);
    expect(
      consent.uncovered(const [
        ('a', ProtectedActivity.formData),
        ('b', ProtectedActivity.formData),
        ('b', ProtectedActivity.postResult),
      ]),
      const [
        ('b', ProtectedActivity.formData),
        ('b', ProtectedActivity.postResult),
      ],
    );
  });
}
