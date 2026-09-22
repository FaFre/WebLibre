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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/browser_actions/domain/services/browser_action_dispatcher.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_swipe_actions.dart';
import 'package:weblibre/features/gestures/data/models/built_in_gesture.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';

class _RecordingDispatcher extends BrowserActionDispatcher {
  final runs = <(BrowserAction, String?)>[];

  @override
  Future<void> run(BrowserAction action, {String? tabId}) async {
    runs.add((action, tabId));
  }
}

void main() {
  const cardKey = Key('card');
  late _RecordingDispatcher dispatcher;

  setUp(() => dispatcher = _RecordingDispatcher());

  Future<void> pumpCard(
    WidgetTester tester, {
    required BrowserAction? left,
    required BrowserAction? right,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          builtInGestureBindingProvider(
            BuiltInGesture.tabSwipeLeft,
          ).overrideWithValue(left),
          builtInGestureBindingProvider(
            BuiltInGesture.tabSwipeRight,
          ).overrideWithValue(right),
          browserActionDispatcherProvider.overrideWith(() => dispatcher),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 80,
                child: TabSwipeActions(
                  tabId: 'tab-1',
                  child: ColoredBox(key: cardKey, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double cardLeft(WidgetTester tester) =>
      tester.getTopLeft(find.byKey(cardKey)).dx;

  testWidgets('a full swipe runs the bound action on that tab', (tester) async {
    await pumpCard(tester, left: null, right: BrowserAction.toggleBookmark);
    final restingLeft = cardLeft(tester);

    await tester.drag(find.byKey(cardKey), const Offset(200, 0));
    await tester.pumpAndSettle();

    expect(dispatcher.runs, [(BrowserAction.toggleBookmark, 'tab-1')]);
    expect(cardLeft(tester), restingLeft, reason: 'the card springs back');
  });

  testWidgets('a short swipe runs nothing', (tester) async {
    await pumpCard(tester, left: null, right: BrowserAction.sharePage);

    await tester.drag(find.byKey(cardKey), const Offset(60, 0));
    await tester.pumpAndSettle();

    expect(dispatcher.runs, isEmpty);
  });

  testWidgets('a direction bound to nothing gives a little and springs back', (
    tester,
  ) async {
    await pumpCard(tester, left: null, right: BrowserAction.sharePage);
    final restingLeft = cardLeft(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(cardKey)),
    );
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(-30, 0));
      await tester.pump();
    }

    final moved = restingLeft - cardLeft(tester);
    expect(moved, greaterThan(0), reason: 'the swipe is visibly noticed');
    expect(moved, lessThanOrEqualTo(32), reason: 'but never looks armed');

    await gesture.up();
    await tester.pumpAndSettle();

    expect(dispatcher.runs, isEmpty);
    expect(cardLeft(tester), restingLeft);
  });
}
