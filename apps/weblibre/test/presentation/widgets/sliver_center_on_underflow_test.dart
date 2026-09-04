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
import 'package:weblibre/presentation/widgets/sliver_center_on_underflow.dart';

void main() {
  const viewport = Size(400, 600);

  /// A scroll view whose centred block is [contentHeight] tall, optionally
  /// preceded by a sliver the host keeps outside the block.
  Widget harness({required double contentHeight, double precedingHeight = 0}) {
    return MediaQuery(
      data: const MediaQueryData(size: viewport),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox.fromSize(
            size: viewport,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (precedingHeight > 0)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: precedingHeight,
                      child: const Text('preceding'),
                    ),
                  ),
                SliverCenterOnUnderflow(
                  sliver: SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: contentHeight,
                          child: const Text('content'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double topOf(WidgetTester tester, String text) =>
      tester.getTopLeft(find.text(text)).dy;

  testWidgets('centres content that is shorter than the viewport', (
    tester,
  ) async {
    await tester.pumpWidget(harness(contentHeight: 200));

    // (600 - 200) / 2
    expect(topOf(tester, 'content'), 200);
  });

  testWidgets('leaves content that fills the viewport at the top', (
    tester,
  ) async {
    await tester.pumpWidget(harness(contentHeight: 600));

    expect(topOf(tester, 'content'), 0);
  });

  testWidgets('leaves overflowing content at the top and scrollable', (
    tester,
  ) async {
    await tester.pumpWidget(harness(contentHeight: 1000));

    expect(topOf(tester, 'content'), 0);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -100));
    await tester.pumpAndSettle();

    expect(topOf(tester, 'content'), -100);
  });

  testWidgets('centres in the space left by the slivers before it', (
    tester,
  ) async {
    await tester.pumpWidget(harness(contentHeight: 200, precedingHeight: 100));

    // The block centres in the 500 below the preceding sliver, not in the
    // whole viewport: 100 + (500 - 200) / 2.
    expect(topOf(tester, 'content'), 250);
  });

  testWidgets('does not make short content scrollable', (tester) async {
    await tester.pumpWidget(harness(contentHeight: 200));

    final position = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;

    expect(position.maxScrollExtent, 0);
  });

  testWidgets('re-centres when the content grows', (tester) async {
    await tester.pumpWidget(harness(contentHeight: 200));
    expect(topOf(tester, 'content'), 200);

    await tester.pumpWidget(harness(contentHeight: 400));
    expect(topOf(tester, 'content'), 100);
  });
}
