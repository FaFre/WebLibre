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
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/account/domain/services/settings_sync_service.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  List<int> snapshot(Map<String, dynamic> json) =>
      utf8.encode(jsonEncode(json));

  test('a newer snapshot is refused by version before it is decoded', () {
    final service = container.read(settingsSyncServiceProvider.notifier);
    final newer = service.schemaVersion + 1;

    // An action this build has never heard of: decoding it first would throw
    // an enum error instead of saying the snapshot is too new.
    final plaintext = snapshot({
      'schema_version': newer,
      'exported_at': '2026-09-22T00:00:00Z',
      'payload': {
        'gestures': {
          'bindingOverrides': {'D-U': 'someFutureAction'},
        },
      },
    });

    expect(
      () => service.applyRestored(plaintext),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Unsupported settings schema version: $newer'),
        ),
      ),
    );
  });

  test('a snapshot without a schema version is rejected as malformed', () {
    final service = container.read(settingsSyncServiceProvider.notifier);

    expect(
      () => service.applyRestored(snapshot({'payload': <String, dynamic>{}})),
      throwsFormatException,
    );
  });
}
