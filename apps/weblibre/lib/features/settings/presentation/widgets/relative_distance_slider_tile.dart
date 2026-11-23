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
import 'package:weblibre/features/settings/presentation/widgets/stops_slider_tile.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/presentation/utils/units_l10n.dart';

/// A gesture distance, shown as a percentage of its default.
///
/// The distance itself is in logical pixels, which tell a user nothing; "100%"
/// reads as the shipped behaviour, and every step from there as more or less
/// of it. The slider runs from [gestureDistanceMinFactor] to
/// [gestureDistanceMaxFactor] of the default in [gestureDistanceFactorStep]s.
class RelativeDistanceSliderTile extends StatelessWidget {
  const RelativeDistanceSliderTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.defaultValue,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final double value;
  final double defaultValue;

  /// Called once the drag ends, with the distance of the step it ended on.
  final Future<void> Function(double value) onChanged;
  final bool enabled;

  /// The factors of the default, from whole quarters so each is exact.
  static final _factors = [
    for (
      var quarter = (gestureDistanceMinFactor / gestureDistanceFactorStep)
          .round();
      quarter <= (gestureDistanceMaxFactor / gestureDistanceFactorStep).round();
      quarter++
    )
      quarter * gestureDistanceFactorStep,
  ];

  @override
  Widget build(BuildContext context) {
    // Clamped as the tab bar and pull to refresh apply it.
    final (:stops, :value) = stopsWithValue(
      _factors,
      (this.value / defaultValue).clamp(
        gestureDistanceMinFactor,
        gestureDistanceMaxFactor,
      ),
    );

    return StopsSliderTile<double>(
      title: title,
      subtitle: subtitle,
      icon: icon,
      enabled: enabled,
      stops: stops,
      value: value,
      labelFor: formatPercent,
      onChanged: (factor) => onChanged(defaultValue * factor),
    );
  }
}
