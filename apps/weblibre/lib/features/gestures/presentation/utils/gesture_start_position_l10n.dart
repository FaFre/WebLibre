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
import 'package:weblibre/features/gestures/data/models/gesture_stroke.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display label for [GestureStartPosition].
extension GestureStartPositionL10n on GestureStartPosition {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      GestureStartPosition.anywhere => l10n.gestures_startPositionAnywhere,
      GestureStartPosition.leftEdge => l10n.gestures_startPositionLeftEdge,
      GestureStartPosition.rightEdge => l10n.gestures_startPositionRightEdge,
      GestureStartPosition.topEdge => l10n.gestures_startPositionTopEdge,
      GestureStartPosition.bottomEdge => l10n.gestures_startPositionBottomEdge,
      GestureStartPosition.leftHalf => l10n.gestures_startPositionLeftHalf,
      GestureStartPosition.rightHalf => l10n.gestures_startPositionRightHalf,
    };
  }
}
