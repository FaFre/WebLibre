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
import 'package:flutter/widgets.dart';

extension DraggableScrollableControllerX on DraggableScrollableController {
  /// Moves the sheet to [size], a fraction of its maximum height: animated, or
  /// at once while animations are off.
  Future<void> moveTo(
    double size, {
    required bool disableAnimations,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.decelerate,
  }) async {
    if (disableAnimations) {
      jumpTo(size);
      return;
    }

    await animateTo(size, duration: duration, curve: curve);
  }
}
