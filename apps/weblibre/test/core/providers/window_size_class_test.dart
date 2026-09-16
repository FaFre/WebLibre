import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/core/providers/window_size_class.dart';

/// Mounts a consumer of [windowSizeClassControllerProvider] and records every
/// value it is rebuilt with.
///
/// `MediaQuery(data: MediaQueryData(size: ...))` would prove nothing here: the
/// provider reads the platform view, not an inherited widget, so the window
/// size has to be set through `tester.view`.
Future<List<WindowSizeClass>> pumpObserver(WidgetTester tester) async {
  final observed = <WindowSizeClass>[];

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Consumer(
          builder: (context, ref, child) {
            observed.add(ref.watch(windowSizeClassControllerProvider));
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );

  return observed;
}

void setWindow(WidgetTester tester, Size logicalSize) {
  tester.view.devicePixelRatio = 2.0;
  tester.view.physicalSize = logicalSize * 2.0;
}

void main() {
  group('WindowSizeClassController', () {
    testWidgets('classifies a compact phone window on the first build', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      setWindow(tester, const Size(412, 915));

      final observed = await pumpObserver(tester);

      // No pump beyond the first: the notifier seeds itself from the platform
      // view, so frame 0 is already correct and never flashes phone layout on
      // a tablet.
      expect(observed, hasLength(1));
      expect(observed.single.width, WindowWidthClass.compact);
      expect(observed.single.prefersSideRail, isFalse);
    });

    testWidgets('classifies an expanded tablet window on the first build', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      setWindow(tester, const Size(1280, 800));

      final observed = await pumpObserver(tester);

      expect(observed, hasLength(1));
      expect(observed.single.width, WindowWidthClass.expanded);
      expect(observed.single.allowsWideRail, isTrue);
    });

    testWidgets('follows a resize across a breakpoint', (tester) async {
      addTearDown(tester.view.reset);
      setWindow(tester, const Size(1280, 800));

      final observed = await pumpObserver(tester);
      expect(observed.last.width, WindowWidthClass.expanded);

      setWindow(tester, const Size(400, 800));
      await tester.pump();

      expect(observed.last.width, WindowWidthClass.compact);
      expect(observed.last.prefersSideRail, isFalse);
    });

    testWidgets('follows a resize back across the same breakpoint', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      setWindow(tester, const Size(400, 800));

      final observed = await pumpObserver(tester);
      expect(observed.last.width, WindowWidthClass.compact);

      setWindow(tester, const Size(1280, 800));
      await tester.pump();
      expect(observed.last.width, WindowWidthClass.expanded);

      // Back down again: with no hysteresis the same size must give the same
      // answer regardless of which direction it was approached from.
      setWindow(tester, const Size(400, 800));
      await tester.pump();
      expect(observed.last.width, WindowWidthClass.compact);
    });

    testWidgets('does not rebuild consumers while resizing within one class', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      setWindow(tester, const Size(1280, 800));

      final observed = await pumpObserver(tester);
      final buildsAfterFirstLayout = observed.length;

      // Every one of these stays inside expanded/medium, which is what a
      // freeform drag looks like frame to frame. A rebuild for any of them
      // would mean the browser shell re-laying out the GeckoView platform view
      // hundreds of times during a single drag.
      for (final width in [1240.0, 1200.0, 1000.0, 900.0, 860.0, 841.0]) {
        setWindow(tester, Size(width, 800));
        await tester.pump();
      }

      expect(observed, hasLength(buildsAfterFirstLayout));
      expect(observed.last.width, WindowWidthClass.expanded);
    });

    testWidgets('treats a wide but short window as height-constrained', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      setWindow(tester, const Size(1400, 300));

      final observed = await pumpObserver(tester);

      expect(observed.last.width, WindowWidthClass.expanded);
      expect(observed.last.isHeightConstrained, isTrue);
      expect(
        observed.last.allowsWideRail,
        isFalse,
        reason: 'a DeX strip has no room for a tab panel',
      );
    });
  });
}
