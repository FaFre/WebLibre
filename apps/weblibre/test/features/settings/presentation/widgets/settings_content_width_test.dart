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
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

/// Renders [SettingsCustomScrollScaffold] at a given window width and returns
/// the width its content sliver actually got.
Future<double> contentWidthAt(WidgetTester tester, double windowWidth) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(windowWidth, 900);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    const MaterialApp(
      home: SettingsCustomScrollScaffold(
        title: 'Settings',
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(key: ValueKey('content'), height: 100),
          ),
        ],
      ),
    ),
  );
  await tester.pump();

  return tester.getSize(find.byKey(const ValueKey('content'))).width;
}

void main() {
  group('settings content width', () {
    testWidgets('fills a phone window edge to edge', (tester) async {
      // Regression guard: the centring is additive precisely so phone layout
      // is byte-for-byte what it was.
      expect(await contentWidthAt(tester, 412), 412);
    });

    testWidgets('still fills a window narrower than the list width', (
      tester,
    ) async {
      expect(
        await contentWidthAt(tester, ContentWidth.list),
        ContentWidth.list,
      );
    });

    testWidgets('is capped and centred on a tablet window', (tester) async {
      expect(await contentWidthAt(tester, 1280), ContentWidth.list);
    });

    testWidgets('does not keep growing on a very wide window', (tester) async {
      expect(await contentWidthAt(tester, 2400), ContentWidth.list);
    });
  });
}
