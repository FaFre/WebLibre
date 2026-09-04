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
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_tray_gestures.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/widgets/single_finger_horizontal_drag.dart';

/// [SelectedContainer] without its persistence and tab-selection listeners, so
/// the gesture layer can be exercised without a database.
class _TestSelectedContainer extends SelectedContainer {
  _TestSelectedContainer(this._initialContainerId);

  final String? _initialContainerId;

  @override
  String? build() => _initialContainerId;

  @override
  Future<SetContainerResult> setContainerId(
    String id, {
    bool Function()? shouldApply,
  }) async {
    state = id;
    return SetContainerResult.success;
  }
}

/// [TabsViewModeController] without persistence.
class _TestTabsViewModeController extends TabsViewModeController {
  _TestTabsViewModeController(this._initialMode);

  final TabsViewMode _initialMode;

  @override
  TabsViewMode build() => _initialMode;
}

// Named, because an unnamed container makes the chip label fall back to the
// AI-topic providers, which want a database.
ContainerData _container(String id) =>
    ContainerData(id: id, name: id, color: Colors.blue, orderKey: id);

/// The tray content stands in for the tab list: it scrolls vertically and its
/// items claim horizontal drags, exactly the two gestures the multitouch layer
/// must not take away.
class _FakeTray extends StatelessWidget {
  const _FakeTray({required this.onItemHorizontalDrag});

  final VoidCallback onItemHorizontalDrag;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) => SingleFingerHorizontalDrag(
        onEnd: (_) => onItemHorizontalDrag(),
        child: SizedBox(height: 64, child: Text('tab $index')),
      ),
    );
  }
}

Future<void> _pumpTray(
  WidgetTester tester, {
  required List<ContainerData?> cycleOrder,
  String? selectedContainerId,
  TabsViewMode viewMode = TabsViewMode.list,
  VoidCallback? onItemHorizontalDrag,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        generalSettingsWithDefaultsProvider.overrideWith(
          (ref) => GeneralSettings.withDefaults(),
        ),
        effectiveTabsTrayScopeProvider.overrideWith(
          (ref) => TabsTrayScope.local,
        ),
        containerCycleOrderProvider.overrideWith((ref) => cycleOrder),
        selectedContainerProvider.overrideWith(
          () => _TestSelectedContainer(selectedContainerId),
        ),
        tabsViewModeControllerProvider.overrideWith(
          () => _TestTabsViewModeController(viewMode),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: TabTrayGestures(
            child: _FakeTray(
              onItemHorizontalDrag: onItemHorizontalDrag ?? () {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

double _scrollOffset(WidgetTester tester) =>
    tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;

ProviderContainer _containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(TabTrayGestures)));

/// Drags two fingers by [distance] in small alternating steps.
///
/// Moving one finger the whole way first would change the span between them and
/// register as a pinch; stepping keeps the scale at ~1 so the drag reads as the
/// pan it is meant to be.
Future<List<TestGesture>> _twoFingerDrag(
  WidgetTester tester,
  Offset distance, {
  int steps = 10,
  bool release = true,
}) async {
  final first = await tester.startGesture(const Offset(200, 250), pointer: 1);
  final second = await tester.startGesture(const Offset(200, 350), pointer: 2);
  await tester.pump();

  final step = distance / steps.toDouble();
  for (var i = 0; i < steps; i++) {
    await first.moveBy(step);
    await second.moveBy(step);
    await tester.pump(const Duration(milliseconds: 16));
  }

  if (release) {
    await _release(tester, [first, second]);
  }

  return [first, second];
}

Future<void> _release(WidgetTester tester, List<TestGesture> gestures) async {
  for (final gesture in gestures) {
    await gesture.up();
  }
  await tester.pumpAndSettle();
}

/// Moves two fingers apart along the x axis (or together, for a negative
/// [distance]) while keeping the focal point where it started.
Future<void> _pinch(
  WidgetTester tester,
  double distance, {
  int steps = 10,
}) async {
  final left = await tester.startGesture(const Offset(150, 300), pointer: 1);
  final right = await tester.startGesture(const Offset(250, 300), pointer: 2);
  await tester.pump();

  final step = distance / steps;
  for (var i = 0; i < steps; i++) {
    await left.moveBy(Offset(-step, 0));
    await right.moveBy(Offset(step, 0));
    await tester.pump(const Duration(milliseconds: 16));
  }

  await left.up();
  await right.up();
  await tester.pumpAndSettle();
}

void main() {
  group('two-finger container swipe', () {
    testWidgets('dragging left selects the next container', (tester) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'work',
      );

      await _twoFingerDrag(tester, const Offset(-120, 0));

      expect(_containerOf(tester).read(selectedContainerProvider), 'shopping');
    });

    testWidgets('dragging right selects the previous container', (
      tester,
    ) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'shopping',
      );

      await _twoFingerDrag(tester, const Offset(120, 0));

      expect(_containerOf(tester).read(selectedContainerProvider), 'work');
    });

    testWidgets('wraps onto the unassigned pseudo-container', (tester) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'shopping',
      );

      await _twoFingerDrag(tester, const Offset(-120, 0));

      expect(_containerOf(tester).read(selectedContainerProvider), isNull);
    });

    testWidgets('a short drag is not enough to commit', (tester) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'work',
      );

      // Far enough to be recognised as a swipe, well short of the commit
      // distance, and slow enough not to count as a fling.
      await _twoFingerDrag(tester, const Offset(-30, 0), steps: 6);

      expect(_containerOf(tester).read(selectedContainerProvider), 'work');
    });

    testWidgets('a two-finger vertical drag switches nothing', (tester) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'work',
      );

      await _twoFingerDrag(tester, const Offset(0, -160));

      expect(_containerOf(tester).read(selectedContainerProvider), 'work');
    });

    testWidgets('a fast swipe switches container without closing a tab', (
      tester,
    ) async {
      var itemDrags = 0;
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'work',
        onItemHorizontalDrag: () => itemDrags++,
      );

      // Few, large steps: each finger passes its own touch slop in one event,
      // which is where a tab item's drag recognizer would otherwise win the
      // arena and close the tab under it.
      await _twoFingerDrag(tester, const Offset(-160, 0), steps: 3);

      expect(itemDrags, 0);
      expect(_containerOf(tester).read(selectedContainerProvider), 'shopping');
    });

    testWidgets('leaves two-finger vertical drags to the tab list', (
      tester,
    ) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'work',
      );

      await _twoFingerDrag(tester, const Offset(0, -160));

      expect(_scrollOffset(tester), greaterThan(0.0));
      expect(_containerOf(tester).read(selectedContainerProvider), 'work');
    });

    testWidgets('leaves an uneven two-finger vertical drag to the tab list', (
      tester,
    ) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'work',
        viewMode: TabsViewMode.list,
      );

      // Fingers moving up at different speeds spread apart as they go, which
      // looks like a pinch until the focal travel is weighed against it.
      final first = await tester.startGesture(
        const Offset(200, 250),
        pointer: 1,
      );
      final second = await tester.startGesture(
        const Offset(200, 350),
        pointer: 2,
      );
      await tester.pump();

      for (var i = 0; i < 10; i++) {
        await first.moveBy(const Offset(0, -16));
        await second.moveBy(const Offset(0, -4));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await _release(tester, [first, second]);

      expect(_scrollOffset(tester), greaterThan(0.0));
      expect(
        _containerOf(tester).read(tabsViewModeControllerProvider),
        TabsViewMode.list,
      );
    });

    testWidgets('leaves a trackpad two-finger scroll to the tab list', (
      tester,
    ) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'work',
      );

      // A trackpad reports one pan/zoom pointer that *counts* as two fingers,
      // with no positions of its own — so the tray layer must sit this out
      // entirely rather than measure a focal point it cannot see.
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.trackpad,
      );
      await gesture.panZoomStart(const Offset(200, 300));
      await tester.pump();

      for (var i = 1; i <= 10; i++) {
        await gesture.panZoomUpdate(
          const Offset(200, 300),
          pan: Offset(0, -16.0 * i),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.panZoomEnd();
      await tester.pumpAndSettle();

      expect(_scrollOffset(tester), greaterThan(0.0));
      expect(_containerOf(tester).read(selectedContainerProvider), 'work');
    });

    testWidgets('leaves single-finger swipe-to-close to the tab item', (
      tester,
    ) async {
      var itemDrags = 0;
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'work',
        onItemHorizontalDrag: () => itemDrags++,
      );

      await tester.drag(find.text('tab 1'), const Offset(-160, 0));
      await tester.pumpAndSettle();

      expect(itemDrags, 1);
      expect(_containerOf(tester).read(selectedContainerProvider), 'work');
    });

    testWidgets('leaves single-finger scrolling to the tab list', (
      tester,
    ) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'work',
      );

      await tester.drag(find.text('tab 1'), const Offset(0, -120));
      await tester.pumpAndSettle();

      expect(_scrollOffset(tester), greaterThan(0.0));
    });

    testWidgets('does nothing when there is only one destination', (
      tester,
    ) async {
      await _pumpTray(tester, cycleOrder: [null], selectedContainerId: null);

      await _twoFingerDrag(tester, const Offset(-120, 0));

      expect(_containerOf(tester).read(selectedContainerProvider), isNull);
    });
  });

  group('swipe target indicator', () {
    testWidgets('names the container the swipe is heading for', (tester) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'work',
      );

      final gestures = await _twoFingerDrag(
        tester,
        const Offset(-100, 0),
        release: false,
      );

      expect(find.text('shopping'), findsOneWidget);

      await _release(tester, gestures);
    });

    testWidgets('names the unassigned destination when wrapping', (
      tester,
    ) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'shopping',
      );

      final gestures = await _twoFingerDrag(
        tester,
        const Offset(-100, 0),
        release: false,
      );

      expect(find.text('Unassigned'), findsOneWidget);

      await _release(tester, gestures);
    });

    testWidgets('points the other way when swiping back', (tester) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'shopping',
      );

      final gestures = await _twoFingerDrag(
        tester,
        const Offset(100, 0),
        release: false,
      );

      expect(find.text('work'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      await _release(tester, gestures);
    });

    testWidgets('stays hidden during a pinch', (tester) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'work',
      );

      await _pinch(tester, 100);

      expect(find.text('shopping'), findsNothing);
    });

    testWidgets('is gone once the gesture ends', (tester) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'work',
      );

      await _twoFingerDrag(tester, const Offset(-100, 0));

      // The container moved on, so the only 'shopping' left would be the
      // indicator still hanging around.
      expect(find.text('shopping'), findsNothing);
    });
  });

  group('pinch to change view mode', () {
    testWidgets('pinching apart moves to the less dense mode', (tester) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work')],
        viewMode: TabsViewMode.grid,
      );

      await _pinch(tester, 100);

      expect(
        _containerOf(tester).read(tabsViewModeControllerProvider),
        TabsViewMode.list,
      );
    });

    testWidgets('pinching together moves to the denser mode', (tester) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work')],
        viewMode: TabsViewMode.list,
      );

      await _pinch(tester, -60);

      expect(
        _containerOf(tester).read(tabsViewModeControllerProvider),
        TabsViewMode.grid,
      );
    });

    testWidgets('clamps at the densest mode instead of wrapping', (
      tester,
    ) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work')],
        viewMode: TabsViewMode.grid,
      );

      await _pinch(tester, -60);

      expect(
        _containerOf(tester).read(tabsViewModeControllerProvider),
        TabsViewMode.grid,
      );
    });

    testWidgets('a pinch never switches container', (tester) async {
      await _pumpTray(
        tester,
        cycleOrder: [null, _container('work'), _container('shopping')],
        selectedContainerId: 'work',
        viewMode: TabsViewMode.grid,
      );

      await _pinch(tester, 100);

      expect(_containerOf(tester).read(selectedContainerProvider), 'work');
    });
  });
}
