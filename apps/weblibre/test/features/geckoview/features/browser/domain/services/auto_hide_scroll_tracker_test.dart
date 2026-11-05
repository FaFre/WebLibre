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
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/auto_hide_scroll_tracker.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

void main() {
  const distance = defaultAutoHideTabBarDistance;

  test('hides only once the distance is passed', () {
    final tracker = AutoHideScrollTracker();

    expect(tracker.add(-distance, hideDistance: distance), AutoHideAction.none);
    expect(tracker.add(-1, hideDistance: distance), AutoHideAction.hide);
    // Keeps asking while the page keeps scrolling the same way.
    expect(tracker.add(-10, hideDistance: distance), AutoHideAction.hide);
  });

  test('turning around starts the count over', () {
    final tracker = AutoHideScrollTracker();

    tracker.add(-distance * 0.9, hideDistance: distance);
    tracker.add(1, hideDistance: distance);
    expect(
      tracker.add(-distance * 0.9, hideDistance: distance),
      AutoHideAction.none,
    );
  });

  test('shows after the show fraction back, then starts over', () {
    final tracker = AutoHideScrollTracker();
    tracker.add(-distance * 2, hideDistance: distance);

    const back = distance * autoHideTabBarShowFraction;
    expect(tracker.add(back, hideDistance: distance), AutoHideAction.none);
    expect(tracker.add(1, hideDistance: distance), AutoHideAction.show);
    expect(tracker.accumulated, 0);
  });

  test('clamps the distance to its limits', () {
    final tracker = AutoHideScrollTracker();

    expect(
      tracker.add(-minAutoHideTabBarDistance - 1, hideDistance: 0),
      AutoHideAction.hide,
    );

    tracker.reset();
    expect(
      tracker.add(-maxAutoHideTabBarDistance, hideDistance: 1e6),
      AutoHideAction.none,
    );
  });

  test('reset forgets the distance scrolled', () {
    final tracker = AutoHideScrollTracker();
    tracker.add(-distance, hideDistance: distance);
    tracker.reset();

    expect(tracker.add(-1, hideDistance: distance), AutoHideAction.none);
  });
}
