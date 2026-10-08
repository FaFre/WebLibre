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
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/navigation_bar.dart';

const _channel = MethodChannel('eu.weblibre.gecko/navigation_bar');

TestDefaultBinaryMessenger get _messenger =>
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

/// Sends a native-side push as MainActivity would.
Future<void> _push(bool outside) => _messenger.handlePlatformMessage(
  _channel.name,
  _channel.codec.encodeMethodCall(MethodCall('outsideFlutterChanged', outside)),
  (_) {},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => _messenger.setMockMethodCallHandler(_channel, null));

  test('stays false without the native channel', () async {
    final container = ProviderContainer.test();
    final sub = container.listen(
      navigationBarOutsideFlutterProvider,
      (_, _) {},
    );

    await pumpEventQueue();

    expect(sub.read(), isFalse);
  });

  test('reads the current value on start', () async {
    _messenger.setMockMethodCallHandler(_channel, (call) async {
      expect(call.method, 'isOutsideFlutter');
      return true;
    });
    final container = ProviderContainer.test();
    final sub = container.listen(
      navigationBarOutsideFlutterProvider,
      (_, _) {},
    );

    await pumpEventQueue();

    expect(sub.read(), isTrue);
  });

  test('follows native pushes', () async {
    _messenger.setMockMethodCallHandler(_channel, (_) async => false);
    final container = ProviderContainer.test();
    final sub = container.listen(
      navigationBarOutsideFlutterProvider,
      (_, _) {},
    );
    await pumpEventQueue();

    await _push(true);
    expect(sub.read(), isTrue);

    await _push(false);
    expect(sub.read(), isFalse);
  });

  test('an older container disposing keeps the newer one updated', () async {
    _messenger.setMockMethodCallHandler(_channel, (_) async => false);
    final old = ProviderContainer.test();
    old.listen(navigationBarOutsideFlutterProvider, (_, _) {});
    final current = ProviderContainer.test();
    final sub = current.listen(navigationBarOutsideFlutterProvider, (_, _) {});
    await pumpEventQueue();

    old.dispose();
    await _push(true);

    expect(sub.read(), isTrue);
  });
}
