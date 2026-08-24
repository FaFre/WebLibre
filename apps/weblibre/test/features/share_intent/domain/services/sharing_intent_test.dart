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
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:weblibre/features/share_intent/domain/services/sharing_intent.dart';

Intent _intent(String url) => Intent(
  action: 'android.intent.action.VIEW',
  data: url,
  categories: const [],
  extra: const {},
);

void main() {
  group('IntentBus startup delivery', () {
    test('holds a cold-start intent until consumers are ready', () async {
      final bus = IntentBus();
      final seen = <Intent>[];
      final intent = _intent('https://example.org/cold');

      bus.emit(intent);
      await Future<void>.delayed(Duration.zero);

      final subscription = bus.stream.listen(seen.add);
      addTearDown(() async {
        await subscription.cancel();
        await bus.close();
      });

      expect(seen, isEmpty);

      bus.startDelivery();
      await Future<void>.delayed(Duration.zero);

      expect(seen, [intent]);
    });

    test('passes warm intents through after startup', () async {
      final bus = IntentBus();
      final seen = <Intent>[];
      final intent = _intent('https://example.org/warm');
      final subscription = bus.stream.listen(seen.add);
      addTearDown(() async {
        await subscription.cancel();
        await bus.close();
      });

      bus.startDelivery();
      bus.emit(intent);
      await Future<void>.delayed(Duration.zero);

      expect(seen, [intent]);
    });

    test('starting delivery twice does not replay an intent', () async {
      final bus = IntentBus();
      final seen = <Intent>[];
      final intent = _intent('https://example.org/once');
      final subscription = bus.stream.listen(seen.add);
      addTearDown(() async {
        await subscription.cancel();
        await bus.close();
      });

      bus.emit(intent);
      bus.startDelivery();
      bus.startDelivery();
      await Future<void>.delayed(Duration.zero);

      expect(seen, [intent]);
    });
  });
}
