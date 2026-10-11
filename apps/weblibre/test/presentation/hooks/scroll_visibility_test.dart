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
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/presentation/hooks/scroll_visibility.dart';

const _visible = 'visible';
const _hidden = 'hidden';

class _Probe extends HookWidget {
  final ScrollController scrollController;
  final DraggableScrollableController? sheetController;

  const _Probe({required this.scrollController, this.sheetController});

  @override
  Widget build(BuildContext context) {
    final isVisible = useScrollVisibility(
      scrollController,
      sheetController: sheetController,
      // No initialization delay.
      disableAnimations: true,
    );
    return Text(isVisible.value ? _visible : _hidden);
  }
}

Widget _list(ScrollController controller) => ListView.builder(
  controller: controller,
  itemExtent: 50,
  itemCount: 100,
  itemBuilder: (context, index) => Text('$index'),
);

/// Pumps a list in a sheet, as the tab tray shows it.
Future<void> _pumpSheet(
  WidgetTester tester,
  DraggableScrollableController sheetController,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: DraggableScrollableSheet(
        controller: sheetController,
        builder: (context, controller) {
          return Column(
            children: [
              _Probe(
                scrollController: controller,
                sheetController: sheetController,
              ),
              Expanded(child: _list(controller)),
            ],
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Scrolls the list by dragging it, as the user does: [by] up the list, so a
/// negative distance scrolls it back. Steps of [step] are each their own
/// frame.
Future<void> _scroll(
  WidgetTester tester, {
  required double by,
  double step = 50,
}) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.byType(ListView)),
  );
  // Past the touch slop, where the drag starts.
  await gesture.moveBy(Offset(0, by.isNegative ? kTouchSlop : -kTouchSlop));
  await tester.pump();
  for (var moved = 0.0; moved < by.abs(); moved += step) {
    await gesture.moveBy(Offset(0, by.isNegative ? step : -step));
    await tester.pump();
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

Future<void> _pumpList(WidgetTester tester, ScrollController controller) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Column(
        children: [
          _Probe(scrollController: controller),
          Expanded(child: _list(controller)),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('follows the scroll direction', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await _pumpList(tester, controller);

    await _scroll(tester, by: 500);
    expect(find.text(_hidden), findsOne);

    await _scroll(tester, by: -100);
    expect(find.text(_visible), findsOne);
  });

  testWidgets('a slow scroll back up adds up and shows it again', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await _pumpList(tester, controller);

    await _scroll(tester, by: 500);
    expect(find.text(_hidden), findsOne);

    // Each step under the 5px threshold.
    await _scroll(tester, by: -12, step: 3);
    expect(find.text(_visible), findsOne);
  });

  testWidgets('ignores the list scrolled by the app', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await _pumpList(tester, controller);

    // Re-centring the active item, say.
    controller.jumpTo(500);
    await tester.pump();
    controller.animateTo(
      1000,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
    await tester.pumpAndSettle();
    expect(find.text(_visible), findsOne);

    // Measured from where the app left it.
    await _scroll(tester, by: 100);
    expect(find.text(_hidden), findsOne);
  });

  testWidgets('in a sheet, the sheet growing hides and shrinking shows', (
    tester,
  ) async {
    final sheetController = DraggableScrollableController();
    addTearDown(sheetController.dispose);
    await _pumpSheet(tester, sheetController);

    sheetController.jumpTo(1.0);
    await tester.pump();
    expect(find.text(_hidden), findsOne);

    sheetController.jumpTo(0.6);
    await tester.pump();
    expect(find.text(_visible), findsOne);
  });

  testWidgets('in a sheet, a slow collapse adds up and shows it again', (
    tester,
  ) async {
    final sheetController = DraggableScrollableController();
    addTearDown(sheetController.dispose);
    await _pumpSheet(tester, sheetController);

    sheetController.jumpTo(1.0);
    await tester.pump();
    expect(find.text(_hidden), findsOne);

    // Each step under the threshold of 0.02 of the sheet's height.
    for (var size = 0.99; size >= 0.95; size -= 0.01) {
      sheetController.jumpTo(size);
      await tester.pump();
    }
    expect(find.text(_visible), findsOne);
  });

  testWidgets('in a sheet at full height, scrolling the list back up shows '
      'it again', (tester) async {
    final sheetController = DraggableScrollableController();
    addTearDown(sheetController.dispose);
    await _pumpSheet(tester, sheetController);

    sheetController.jumpTo(1.0);
    await tester.pump();
    await _scroll(tester, by: 500);
    expect(find.text(_hidden), findsOne);

    // The sheet stays at full height; only the list moves.
    await _scroll(tester, by: -100);
    expect(sheetController.size, 1.0);
    expect(find.text(_visible), findsOne);
  });
}
