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
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/presentation/hooks/on_listenable_change_selector.dart';

class _Probe extends HookWidget {
  final TextEditingController controller;
  final List<String> observed;
  final bool fireImmediately;

  const _Probe({
    required this.controller,
    required this.observed,
    required this.fireImmediately,
  });

  @override
  Widget build(BuildContext context) {
    useOnListenableChangeSelector(
      controller,
      () => controller.text,
      () => observed.add(controller.text),
      fireImmediately: fireImmediately,
    );

    return const SizedBox.shrink();
  }
}

void main() {
  late TextEditingController controller;
  late List<String> observed;

  setUp(() {
    controller = TextEditingController();
    observed = [];
  });

  tearDown(() => controller.dispose());

  Future<void> mount(WidgetTester tester, {required bool fireImmediately}) {
    return tester.pumpWidget(
      _Probe(
        controller: controller,
        observed: observed,
        fireImmediately: fireImmediately,
      ),
    );
  }

  testWidgets('reports changes but not the mount value by default', (
    tester,
  ) async {
    controller.text = 'g';
    await mount(tester, fireImmediately: false);

    expect(observed, isEmpty);

    controller.text = 'go';
    await tester.pump();

    expect(observed, ['go']);
  });

  testWidgets('reports the very first change without an intervening rebuild', (
    tester,
  ) async {
    // The baseline used to be seeded lazily on the first read, which happens
    // inside the listener itself — so without a rebuild in between, the first
    // change compared equal to itself and was swallowed.
    await mount(tester, fireImmediately: false);

    controller.text = 'g';
    await tester.pump();

    expect(observed, ['g']);
  });

  testWidgets('fireImmediately reports the value already there at mount', (
    tester,
  ) async {
    // A search module mounts on the keystroke that made the field non-empty,
    // so that keystroke never arrives as a change event.
    controller.text = 'go';
    await mount(tester, fireImmediately: true);

    expect(observed, ['go']);

    controller.text = 'g';
    await tester.pump();

    expect(observed, ['go', 'g']);
  });
}
