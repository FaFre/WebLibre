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
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/settings/presentation/widgets/stops_slider_tile.dart';

void main() {
  // Unevenly spaced, as the idle time stops are, with a null stop at the end,
  // as the loaded tab limit's "No Limit" is.
  const stops = <int?>[1, 5, 30, 240, null];

  String labelFor(int? stop) => stop == null ? 'None' : '$stop min';

  /// Pumps the tile showing [stored], and returns what it saved. Each save is
  /// stored and comes back as the tile's value, unless [storeSaves] is false.
  Future<List<int?>> pumpTile(
    WidgetTester tester, {
    required ValueNotifier<int?> stored,
    List<int?> stops = stops,
    bool enabled = true,
    bool storeSaves = true,
    String? Function(int? stop)? subtitleFor,
  }) async {
    final saved = <int?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder(
            valueListenable: stored,
            builder: (context, value, _) {
              return StopsSliderTile<int?>(
                title: 'Sleep After',
                subtitle: 'How long',
                subtitleFor: subtitleFor,
                icon: Icons.timer,
                stops: stops,
                value: value,
                labelFor: labelFor,
                enabled: enabled,
                onChanged: (stop) async {
                  saved.add(stop);
                  if (storeSaves) stored.value = stop;
                },
              );
            },
          ),
        ),
      ),
    );
    return saved;
  }

  group('nearestStopIndex', () {
    const idleStops = [1, 2, 3, 5, 10, 15, 20, 30, 45, 60, 120, 240];

    test('finds a value that is a stop', () {
      expect(nearestStopIndex(idleStops, 1), 0);
      expect(nearestStopIndex(idleStops, 30), 7);
      expect(nearestStopIndex(idleStops, 240), 11);
    });

    test('snaps a value between stops to the closer one', () {
      expect(nearestStopIndex(idleStops, 50), 8);
      expect(nearestStopIndex(idleStops, 100), 10);
    });

    test('snaps a value outside the stops to the end it is beyond', () {
      expect(nearestStopIndex(idleStops, 0), 0);
      expect(nearestStopIndex(idleStops, 10000), 11);
    });
  });

  group('stopsWithValue', () {
    const idleStops = [1, 5, 30, 240];

    test('keeps the stops when the value is one', () {
      final result = stopsWithValue(idleStops, 30);
      expect(result.stops, same(idleStops));
      expect(result.value, 30);
    });

    test('puts a value between stops in order among them', () {
      final result = stopsWithValue(idleStops, 90);
      expect(result.stops, [1, 5, 30, 90, 240]);
      expect(result.value, 90);
    });

    test('puts a value beyond the stops at that end', () {
      expect(stopsWithValue(idleStops, 25 * 60).stops, [1, 5, 30, 240, 1500]);
      expect(stopsWithValue([4, 6, 10], 2).stops, [2, 4, 6, 10]);
    });

    test('takes a double with rounding noise as the stop it reads as', () {
      final factors = [for (var tenth = 5; tenth <= 30; tenth++) tenth / 10];
      final noisy = 0.5 + 6 * 0.1; // 1.1000000000000001

      final result = stopsWithValue(factors, noisy);
      expect(result.stops, same(factors));
      expect(result.value, 1.1);
    });
  });

  testWidgets('shows the stored stop beside the title', (tester) async {
    await pumpTile(tester, stored: ValueNotifier(30));

    expect(find.text('30 min'), findsOneWidget);
  });

  testWidgets('shows a stored value off the list as itself', (tester) async {
    final off = stopsWithValue([1, 5, 30, 240], 90);
    await pumpTile(tester, stored: ValueNotifier(off.value), stops: off.stops);

    expect(find.text('90 min'), findsOneWidget);
  });

  testWidgets('a screen reader hears the stop, not the track position', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpTile(tester, stored: ValueNotifier(5));

    final semantics = find.semantics
        .byFlag(SemanticsFlag.isSlider)
        .evaluate()
        .single;
    expect(semantics.value, '5 min');
    expect(semantics.increasedValue, '30 min');
    expect(semantics.decreasedValue, '1 min');

    handle.dispose();
  });

  testWidgets('dragging saves once, at the end, on the end stops', (
    tester,
  ) async {
    final saved = await pumpTile(tester, stored: ValueNotifier(30));

    await tester.drag(find.byType(Slider), const Offset(2000, 0));
    await tester.pumpAndSettle();
    expect(find.text('None'), findsOneWidget);

    await tester.drag(find.byType(Slider), const Offset(-2000, 0));
    await tester.pumpAndSettle();
    expect(find.text('1 min'), findsOneWidget);

    expect(saved, [null, 1]);
  });

  testWidgets('a tap on the thumb keeps a stored value off the list', (
    tester,
  ) async {
    // 7 lies between the stops 5 and 30, nearest 5.
    final off = stopsWithValue([1, 5, 30, 240], 7);
    final stored = ValueNotifier<int?>(off.value);
    final saved = await pumpTile(tester, stored: stored, stops: off.stops);

    final thumb =
        tester.getCenter(find.byType(Slider)) +
        Offset(_thumbOffset(tester, index: 2, stopCount: 5), 0);
    await tester.tapAt(thumb);
    await tester.pumpAndSettle();

    expect(saved, isEmpty);
    expect(stored.value, 7);
    expect(find.text('7 min'), findsOneWidget);
  });

  testWidgets('a drag back to where it started saves nothing', (tester) async {
    final saved = await pumpTile(tester, stored: ValueNotifier(30));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Slider)),
    );
    await gesture.moveBy(const Offset(2000, 0));
    await tester.pump();
    expect(find.text('None'), findsWidgets);
    await gesture.moveTo(tester.getCenter(find.byType(Slider)));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(saved, isEmpty);
    expect(find.text('30 min'), findsOneWidget);
  });

  testWidgets('the subtitle follows the thumb during a drag', (tester) async {
    await pumpTile(
      tester,
      stored: ValueNotifier(30),
      subtitleFor: (stop) => stop == 1 ? 'Only one' : null,
    );
    expect(find.text('How long'), findsOneWidget);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Slider)),
    );
    await gesture.moveBy(const Offset(-2000, 0));
    await tester.pump();

    expect(find.text('Only one'), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('a save landing during a drag does not move the thumb', (
    tester,
  ) async {
    final stored = ValueNotifier<int?>(30);
    await pumpTile(tester, stored: stored);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Slider)),
    );
    await gesture.moveBy(const Offset(-2000, 0));
    await tester.pump();
    expect(find.text('1 min'), findsWidgets);

    // An earlier drag's save comes back while the finger is still down.
    stored.value = 240;
    await tester.pump();
    expect(find.text('1 min'), findsWidgets);
    expect(find.text('240 min'), findsNothing);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(stored.value, 1);
    expect(find.text('1 min'), findsOneWidget);
  });

  testWidgets('the dropped stop shows until the save comes back', (
    tester,
  ) async {
    final stored = ValueNotifier<int?>(30);
    final saved = await pumpTile(tester, stored: stored, storeSaves: false);

    await tester.drag(find.byType(Slider), const Offset(2000, 0));
    await tester.pumpAndSettle();
    expect(saved, [null]);
    expect(find.text('None'), findsOneWidget);

    // The settings stream emits after the write.
    stored.value = null;
    await tester.pumpAndSettle();
    expect(find.text('None'), findsOneWidget);
  });

  testWidgets('a value change from elsewhere moves the thumb', (tester) async {
    final stored = ValueNotifier<int?>(30);
    await pumpTile(tester, stored: stored);

    stored.value = 5;
    await tester.pumpAndSettle();

    expect(find.text('5 min'), findsOneWidget);
  });

  testWidgets('a disabled tile cannot be moved', (tester) async {
    final saved = await pumpTile(
      tester,
      stored: ValueNotifier(30),
      enabled: false,
    );

    await tester.drag(find.byType(Slider), const Offset(2000, 0));
    await tester.pumpAndSettle();

    expect(saved, isEmpty);
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
  });
}

/// How far right of the slider's centre the thumb sits on stop [index] of
/// [stopCount].
double _thumbOffset(
  WidgetTester tester, {
  required int index,
  required int stopCount,
}) {
  final slider = tester.getRect(find.byType(Slider));
  // Material's track is inset from the slider's edges by the overlay radius.
  const inset = 24.0;
  final track = slider.width - 2 * inset;
  return inset + track * index / (stopCount - 1) - slider.width / 2;
}
