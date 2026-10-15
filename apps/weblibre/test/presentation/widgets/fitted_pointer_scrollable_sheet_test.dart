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
import 'package:weblibre/presentation/widgets/fitted_pointer_scrollable_sheet.dart';

/// The 800x600 test surface: a sheet at extent 0.5 is 300px tall.
const _windowHeight = 600.0;

/// A drag handle and a bottom row around the list, the shape of the ⋮ menu.
const _chromeTop = 40.0;
const _chromeBottom = 20.0;
const _chromeHeight = _chromeTop + _chromeBottom;

const _sheetKey = Key('sheet');

class _Harness extends StatelessWidget {
  final ValueNotifier<double> contentHeight;

  /// Grows the chrome above the list, the way the ⋮ menu pins its
  /// arrangement header there.
  final ValueNotifier<double> extraChromeHeight;
  final DraggableScrollableController controller;

  const _Harness({
    required this.contentHeight,
    required this.extraChromeHeight,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: FittedPointerScrollableSheet(
            controller: controller,
            builder: (context, scrollController, contentEnd) {
              return ColoredBox(
                key: _sheetKey,
                color: Colors.white,
                child: Column(
                  children: [
                    const SizedBox(height: _chromeTop),
                    ValueListenableBuilder(
                      valueListenable: extraChromeHeight,
                      builder: (context, height, _) => SizedBox(height: height),
                    ),
                    Expanded(
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: ValueListenableBuilder(
                              valueListenable: contentHeight,
                              builder: (context, height, _) =>
                                  SizedBox(height: height),
                            ),
                          ),
                          contentEnd,
                        ],
                      ),
                    ),
                    const SizedBox(height: _chromeBottom),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  late ValueNotifier<double> contentHeight;
  late ValueNotifier<double> extraChromeHeight;
  late DraggableScrollableController controller;

  setUp(() {
    contentHeight = ValueNotifier(200);
    extraChromeHeight = ValueNotifier(0);
    controller = DraggableScrollableController();
  });

  tearDown(() {
    contentHeight.dispose();
    extraChromeHeight.dispose();
    controller.dispose();
  });

  Future<void> pumpSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      _Harness(
        contentHeight: contentHeight,
        extraChromeHeight: extraChromeHeight,
        controller: controller,
      ),
    );
    await tester.pumpAndSettle();
  }

  double sheetHeight(WidgetTester tester) =>
      tester.getSize(find.byKey(_sheetKey)).height;

  testWidgets('opens at the height of short content', (tester) async {
    await pumpSheet(tester);

    expect(sheetHeight(tester), moreOrLessEquals(200 + _chromeHeight));
  });

  testWidgets('cannot be dragged up past short content', (tester) async {
    await pumpSheet(tester);

    await tester.drag(find.byKey(_sheetKey), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(sheetHeight(tester), moreOrLessEquals(200 + _chromeHeight));
  });

  testWidgets('opens tall content at the cap and expands to the window', (
    tester,
  ) async {
    contentHeight.value = 2000;
    await pumpSheet(tester);

    expect(sheetHeight(tester), moreOrLessEquals(0.85 * _windowHeight));

    await tester.drag(find.byKey(_sheetKey), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(sheetHeight(tester), moreOrLessEquals(_windowHeight));
  });

  testWidgets('expands only as far as content between the cap and the window', (
    tester,
  ) async {
    // 540 + 60 of chrome = 600: just fits the window.
    contentHeight.value = 0.95 * _windowHeight - _chromeHeight;
    await pumpSheet(tester);

    expect(sheetHeight(tester), moreOrLessEquals(0.85 * _windowHeight));

    await tester.drag(find.byKey(_sheetKey), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(sheetHeight(tester), moreOrLessEquals(0.95 * _windowHeight));
  });

  testWidgets('follows its content as it grows and shrinks', (tester) async {
    await pumpSheet(tester);

    contentHeight.value = 300;
    await tester.pumpAndSettle();
    expect(sheetHeight(tester), moreOrLessEquals(300 + _chromeHeight));

    contentHeight.value = 100;
    await tester.pumpAndSettle();
    expect(sheetHeight(tester), moreOrLessEquals(100 + _chromeHeight));

    contentHeight.value = 2000;
    await tester.pumpAndSettle();
    expect(sheetHeight(tester), moreOrLessEquals(0.85 * _windowHeight));
  });

  testWidgets('keeps a size the user dragged it down to', (tester) async {
    contentHeight.value = 300;
    await pumpSheet(tester);

    await tester.drag(find.byKey(_sheetKey), const Offset(0, 60));
    await tester.pumpAndSettle();
    final dragged = sheetHeight(tester);
    expect(dragged, lessThan(300 + _chromeHeight));

    contentHeight.value = 400;
    await tester.pumpAndSettle();

    expect(sheetHeight(tester), moreOrLessEquals(dragged));
  });

  testWidgets('keeps growing once the user has put it back at full height', (
    tester,
  ) async {
    await pumpSheet(tester);

    controller.jumpTo(0.2);
    await tester.pumpAndSettle();
    controller.jumpTo((200 + _chromeHeight) / _windowHeight);
    await tester.pumpAndSettle();

    contentHeight.value = 300;
    await tester.pumpAndSettle();

    expect(sheetHeight(tester), moreOrLessEquals(300 + _chromeHeight));
  });

  testWidgets('shrinks a resized sheet with its content', (tester) async {
    contentHeight.value = 300;
    await pumpSheet(tester);

    controller.jumpTo(0.5);
    await tester.pumpAndSettle();

    contentHeight.value = 100;
    await tester.pumpAndSettle();

    expect(sheetHeight(tester), moreOrLessEquals(100 + _chromeHeight));
  });

  // A menu with every section switched off is little more than its drag
  // handle. Opening the arrangement UI pins a header taller than that above
  // the list, which squeezes the list out of the sheet entirely: the sheet
  // must still find out how tall the content has become, and never overflow
  // on the way (flutter_test fails on an overflow report).
  testWidgets('grows when its chrome outgrows the sheet', (tester) async {
    contentHeight.value = 20;
    await pumpSheet(tester);
    expect(sheetHeight(tester), moreOrLessEquals(20 + _chromeHeight));

    extraChromeHeight.value = 200;
    contentHeight.value = 100;
    await tester.pumpAndSettle();

    expect(sheetHeight(tester), moreOrLessEquals(300 + _chromeHeight));
  });

  testWidgets('grows a resized sheet its chrome no longer fits in', (
    tester,
  ) async {
    contentHeight.value = 300;
    await pumpSheet(tester);

    controller.jumpTo(0.3);
    await tester.pumpAndSettle();
    expect(sheetHeight(tester), moreOrLessEquals(0.3 * _windowHeight));

    extraChromeHeight.value = 300;
    await tester.pumpAndSettle();

    // 300 of content and 360 of chrome: taller than the cap.
    expect(sheetHeight(tester), moreOrLessEquals(0.85 * _windowHeight));
  });
}
