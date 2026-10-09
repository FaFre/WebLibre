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

Map<String, bool> _wire({
  bool outsideFlutter = false,
  bool buttonsAtBottom = false,
}) => {'outsideFlutter': outsideFlutter, 'buttonsAtBottom': buttonsAtBottom};

/// Sends a native-side push as MainActivity would.
Future<void> _push({
  bool outsideFlutter = false,
  bool buttonsAtBottom = false,
}) => _messenger.handlePlatformMessage(
  _channel.name,
  _channel.codec.encodeMethodCall(
    MethodCall(
      'layoutChanged',
      _wire(outsideFlutter: outsideFlutter, buttonsAtBottom: buttonsAtBottom),
    ),
  ),
  (_) {},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => _messenger.setMockMethodCallHandler(_channel, null));

  test('reports neither condition without the native channel', () async {
    final container = ProviderContainer.test();
    final sub = container.listen(
      navigationBarLayoutControllerProvider,
      (_, _) {},
    );

    await pumpEventQueue();

    expect(sub.read(), (outsideFlutter: false, buttonsAtBottom: false));
  });

  test('reads the current value on start', () async {
    _messenger.setMockMethodCallHandler(_channel, (call) async {
      expect(call.method, 'getLayout');
      return _wire(outsideFlutter: true, buttonsAtBottom: true);
    });
    final container = ProviderContainer.test();
    final sub = container.listen(
      navigationBarLayoutControllerProvider,
      (_, _) {},
    );

    await pumpEventQueue();

    expect(sub.read(), (outsideFlutter: true, buttonsAtBottom: true));
  });

  test('follows native pushes', () async {
    _messenger.setMockMethodCallHandler(_channel, (_) async => _wire());
    final container = ProviderContainer.test();
    final sub = container.listen(
      navigationBarLayoutControllerProvider,
      (_, _) {},
    );
    await pumpEventQueue();

    await _push(outsideFlutter: true);
    expect(sub.read(), (outsideFlutter: true, buttonsAtBottom: false));

    await _push(buttonsAtBottom: true);
    expect(sub.read(), (outsideFlutter: false, buttonsAtBottom: true));
  });

  test('an older container disposing keeps the newer one updated', () async {
    _messenger.setMockMethodCallHandler(_channel, (_) async => _wire());
    final old = ProviderContainer.test();
    old.listen(navigationBarLayoutControllerProvider, (_, _) {});
    final current = ProviderContainer.test();
    final sub = current.listen(
      navigationBarLayoutControllerProvider,
      (_, _) {},
    );
    await pumpEventQueue();

    old.dispose();
    await _push(buttonsAtBottom: true);

    expect(sub.read(), (outsideFlutter: false, buttonsAtBottom: true));
  });
}
