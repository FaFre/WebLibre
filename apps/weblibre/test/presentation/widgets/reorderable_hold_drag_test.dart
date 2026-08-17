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
import 'package:weblibre/presentation/widgets/reorderable_hold_drag.dart';

/// Horizontal chip bar mirroring the quick tab switcher: fixed-width items in
/// a viewport that only fits 2.5 of them, so the item at the trailing edge is
/// always partially clipped.
class _Harness extends StatefulWidget {
  final ScrollController controller;
  final List<String> items;

  const _Harness({required this.controller, required this.items});

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late List<String> order = [...widget.items];
  int reorderCount = 0;
  int dragStartCount = 0;
  int tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: 48,
            width: 250,
            child: ReorderableListView.builder(
              scrollController: widget.controller,
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: false,
              itemCount: order.length,
              itemBuilder: (context, index) {
                return KeyedSubtree(
                  key: ValueKey(order[index]),
                  child: ReorderableHoldDragListener(
                    index: index,
                    // Tappable and opaque, like the real chip: the whole item
                    // area is hit-testable, and its tap recognizer competes in
                    // the same gesture arena as the drag.
                    child: GestureDetector(
                      onTap: () => tapCount++,
                      child: ColoredBox(
                        color: Colors.blue,
                        child: SizedBox(
                          width: 100,
                          child: Center(child: Text(order[index])),
                        ),
                      ),
                    ),
                  ),
                );
              },
              onReorderStart: (_) => dragStartCount++,
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  reorderCount++;
                  order.insert(newIndex, order.removeAt(oldIndex));
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  const items = ['a', 'b', 'c', 'd', 'e', 'f'];

  Future<_HarnessState> pump(
    WidgetTester tester,
    ScrollController controller,
  ) async {
    await tester.pumpWidget(_Harness(controller: controller, items: items));
    return tester.state<_HarnessState>(find.byType(_Harness));
  }

  /// Holds for [total] while producing frames, so timers *and* the animations
  /// they start (the reveal scroll, the auto scroller) actually run.
  Future<void> hold(WidgetTester tester, Duration total) async {
    const frame = Duration(milliseconds: 16);
    for (var elapsed = Duration.zero; elapsed < total; elapsed += frame) {
      await tester.pump(frame);
    }
  }

  testWidgets('a plain long press does not pick the item up', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    final state = await pump(tester, controller);
    // Scroll so the item at the left edge is half cut off.
    controller.jumpTo(150);
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(const Offset(20, 24));
    await hold(tester, kItemLongPressDelay + const Duration(milliseconds: 20));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      state.dragStartCount,
      0,
      reason: 'a long press without movement must not start a drag',
    );
    expect(
      state.order,
      items,
      reason: 'the pressed item must stay where it is',
    );
  });

  testWidgets('a long press still claims the gesture from the item tap', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    final state = await pump(tester, controller);

    final gesture = await tester.startGesture(const Offset(50, 24));
    await hold(tester, kItemLongPressDelay + const Duration(milliseconds: 20));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      state.tapCount,
      0,
      reason: 'releasing after a long press must not read as a tap',
    );
  });

  testWidgets('a short press is still a tap', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    final state = await pump(tester, controller);

    await tester.tap(find.text('a'));
    await tester.pumpAndSettle();

    expect(state.tapCount, 1);
  });

  testWidgets('moving before the long press completes scrolls the list', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    final state = await pump(tester, controller);

    await tester.drag(find.text('b'), const Offset(-80, 0));
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0.0));
    expect(state.dragStartCount, 0);
  });

  testWidgets(
    'dragging a clipped item does not run the list away to the scroll extent',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      final state = await pump(tester, controller);
      controller.jumpTo(150);
      await tester.pumpAndSettle();

      // Press the sliver of the item that pokes out of the leading edge, pick
      // it up, nudge it, then hold it still. That stationary hold is what used
      // to let EdgeDraggingAutoScroller scroll to minScrollExtent and fling
      // the item to the front of the bar (issue #579).
      final gesture = await tester.startGesture(const Offset(20, 24));
      await hold(
        tester,
        kItemLongPressDelay + const Duration(milliseconds: 20),
      );
      await gesture.moveBy(const Offset(30, 0));
      await hold(tester, const Duration(seconds: 3));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(
        controller.offset,
        greaterThan(0.0),
        reason: 'a held drag must not auto-scroll to the list start',
      );
      expect(
        state.order,
        items,
        reason: 'a held drag must not reorder anything',
      );
    },
  );

  testWidgets('a clipped item is revealed in full before it is picked up', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await pump(tester, controller);
    controller.jumpTo(150);
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(const Offset(20, 24));
    await hold(tester, kItemLongPressDelay);
    await tester.pumpAndSettle();

    // Item 'b' spans 100..200; revealing it at the leading edge lands on 100.
    expect(controller.offset, closeTo(100.0, 1.5));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('long press then move performs a reorder drag', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    final state = await pump(tester, controller);

    // Grab the third chip and drag it to the front of the bar.
    final gesture = await tester.startGesture(const Offset(220, 24));
    await hold(tester, kItemLongPressDelay + const Duration(milliseconds: 20));

    for (var i = 0; i < 12; i++) {
      await gesture.moveBy(const Offset(-20, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(state.dragStartCount, 1);
    expect(state.reorderCount, 1);
    expect(state.order.first, 'c');
  });
}
