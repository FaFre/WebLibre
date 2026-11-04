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
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/presentation/widgets/highlight_pulse.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required bool active,
    required bool disableAnimations,
  }) => tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(
          body: ListView(
            children: [
              HighlightPulse(active: active, child: const Text('row')),
            ],
          ),
        ),
      ),
    ),
  );

  double tintAlpha(WidgetTester tester) => tester
      .widget<Material>(
        find
            .descendant(
              of: find.byType(HighlightPulse),
              matching: find.byType(Material),
            )
            .first,
      )
      .color!
      .a;

  for (final disableAnimations in [false, true]) {
    final motion = disableAnimations ? 'reduced motion' : 'full motion';

    testWidgets('an inactive row stays untinted with $motion', (tester) async {
      await pump(tester, active: false, disableAnimations: disableAnimations);
      await tester.pumpAndSettle();
      expect(tintAlpha(tester), 0);

      await tester.pump(const Duration(seconds: 2));
      expect(tintAlpha(tester), 0);
    });

    testWidgets('an active row is tinted during the pulse, then not, with '
        '$motion', (tester) async {
      await pump(tester, active: true, disableAnimations: disableAnimations);
      // The pulse starts after the first frame.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(tintAlpha(tester), greaterThan(0));

      await tester.pumpAndSettle();
      expect(tintAlpha(tester), 0);
    });
  }
}
