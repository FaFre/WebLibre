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
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/pointer_device.dart';

void main() {
  late ProviderContainer container;

  Future<void> setUpContainer(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.expand());
    container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(cursorInUseProvider, (_, _) {});
  }

  testWidgets('starts without a cursor', (tester) async {
    await setUpContainer(tester);
    expect(container.read(cursorInUseProvider), isFalse);
  });

  testWidgets('touch does not count as a cursor', (tester) async {
    await setUpContainer(tester);

    await tester.tapAt(const Offset(20, 20));

    expect(container.read(cursorInUseProvider), isFalse);
  });

  testWidgets('a hovering mouse does', (tester) async {
    await setUpContainer(tester);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: const Offset(10, 10));
    await mouse.moveTo(const Offset(30, 30));

    expect(container.read(cursorInUseProvider), isTrue);
  });

  testWidgets('stays set after the cursor leaves the window', (tester) async {
    // Android removes the pointer whenever the cursor crosses the window edge;
    // a layout keyed on connection would jump each time.
    await setUpContainer(tester);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(10, 10));
    await mouse.moveTo(const Offset(30, 30));
    await mouse.removePointer();

    expect(container.read(cursorInUseProvider), isTrue);
  });

  testWidgets('a touch press hands the app back to touch', (tester) async {
    // Otherwise a cursor-only affordance, like the auto-hiding side rail,
    // stays out of reach once the mouse is gone.
    await setUpContainer(tester);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(10, 10));
    await mouse.moveTo(const Offset(30, 30));
    await mouse.removePointer();

    await tester.tapAt(const Offset(20, 20));

    expect(container.read(cursorInUseProvider), isFalse);
  });

  testWidgets('the cursor takes over again once it moves', (tester) async {
    await setUpContainer(tester);
    await tester.tapAt(const Offset(20, 20));

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: const Offset(10, 10));
    await mouse.moveTo(const Offset(30, 30));

    expect(container.read(cursorInUseProvider), isTrue);
  });
}
