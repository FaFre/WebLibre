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
import 'package:weblibre/features/gestures/data/models/built_in_gesture.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display labels for [BuiltInGestureSurface] and [BuiltInGesture].
extension BuiltInGestureSurfaceL10n on BuiltInGestureSurface {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      BuiltInGestureSurface.tabBar => l10n.gestures_tabBarSurfaceTitle,
      BuiltInGestureSurface.tabView => l10n.gestures_tabViewSurfaceTitle,
    };
  }

  String description(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      BuiltInGestureSurface.tabBar => l10n.gestures_tabBarSurfaceDescription,
      BuiltInGestureSurface.tabView => l10n.gestures_tabViewSurfaceDescription,
    };
  }
}

extension BuiltInGestureL10n on BuiltInGesture {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      BuiltInGesture.tabBarSwipeBackward =>
        l10n.gestures_tabBarSwipeBackwardTitle,
      BuiltInGesture.tabBarSwipeForward =>
        l10n.gestures_tabBarSwipeForwardTitle,
      BuiltInGesture.tabBarSwipeOutward =>
        l10n.gestures_tabBarSwipeOutwardTitle,
      BuiltInGesture.tabBarSwipeInward => l10n.gestures_tabBarSwipeInwardTitle,
      BuiltInGesture.tabSwipeLeft => l10n.gestures_tabSwipeLeftTitle,
      BuiltInGesture.tabSwipeRight => l10n.gestures_tabSwipeRightTitle,
    };
  }

  String description(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      BuiltInGesture.tabBarSwipeBackward =>
        l10n.gestures_tabBarSwipeBackwardDescription,
      BuiltInGesture.tabBarSwipeForward =>
        l10n.gestures_tabBarSwipeForwardDescription,
      BuiltInGesture.tabBarSwipeOutward =>
        l10n.gestures_tabBarSwipeOutwardDescription,
      BuiltInGesture.tabBarSwipeInward =>
        l10n.gestures_tabBarSwipeInwardDescription,
      BuiltInGesture.tabSwipeLeft => l10n.gestures_tabSwipeLeftDescription,
      BuiltInGesture.tabSwipeRight => l10n.gestures_tabSwipeRightDescription,
    };
  }
}
