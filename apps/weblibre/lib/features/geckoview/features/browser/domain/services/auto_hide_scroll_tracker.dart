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
import 'package:weblibre/features/user/data/models/general_settings.dart';

/// What an auto-hiding tab bar should do after a scroll step.
enum AutoHideAction { none, hide, show }

/// Decides when an auto-hiding tab bar hides and comes back while the page
/// scrolls.
///
/// The browser feeds it the page's pointer moves; the Toolbar & Layout
/// preview feeds it the scrolling of its sample page. Both therefore hide the
/// bar after exactly the same distance.
///
/// Scrolling one way accumulates distance; turning around starts over. The bar
/// hides once the accumulated distance passes the hide distance, and comes
/// back after [autoHideTabBarShowFraction] of it the other way.
class AutoHideScrollTracker {
  double _accumulated = 0.0;

  /// Distance scrolled in the current direction: negative while the content
  /// moves up (reading on), positive while it moves down.
  double get accumulated => _accumulated;

  /// Forgets the distance scrolled so far, e.g. after a tab switch or once the
  /// bar has been shown by something other than scrolling.
  void reset() => _accumulated = 0.0;

  /// Adds one scroll step. [delta] is the pointer's vertical move: negative
  /// when the content is pushed up. [hideDistance] is the setting
  /// `autoHideTabBarDistance`, clamped here to its limits.
  AutoHideAction add(double delta, {required double hideDistance}) {
    final distance = hideDistance.clamp(
      minAutoHideTabBarDistance,
      maxAutoHideTabBarDistance,
    );

    if (delta < 0) {
      if (_accumulated > 0) _accumulated = 0.0;
      _accumulated += delta;
      // Keeps accumulating once hidden: repeated hide requests are harmless.
      if (_accumulated.abs() > distance) return AutoHideAction.hide;
    } else if (delta > 0) {
      if (_accumulated < 0) _accumulated = 0.0;
      _accumulated += delta;
      if (_accumulated.abs() > distance * autoHideTabBarShowFraction) {
        _accumulated = 0.0;
        return AutoHideAction.show;
      }
    }

    return AutoHideAction.none;
  }
}
