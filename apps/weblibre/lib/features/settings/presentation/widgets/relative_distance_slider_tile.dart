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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/presentation/hooks/keyed_state.dart';

/// A gesture distance, shown as a percentage of its default.
///
/// The distance itself is in logical pixels, which tell a user nothing; "100%"
/// reads as the shipped behaviour, and every step from there as more or less
/// of it. The slider runs from [gestureDistanceMinFactor] to
/// [gestureDistanceMaxFactor] of the default in [gestureDistanceFactorStep]s.
class RelativeDistanceSliderTile extends HookWidget {
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

  static final _divisions =
      ((gestureDistanceMaxFactor - gestureDistanceMinFactor) /
              gestureDistanceFactorStep)
          .round();

  /// [factor] on the nearest step of the range. A stored distance that is not
  /// on one (from an older build, or synced from one) shows as its nearest.
  static double _snap(double factor) {
    final clamped = factor.clamp(
      gestureDistanceMinFactor,
      gestureDistanceMaxFactor,
    );
    final stepIndex =
        ((clamped - gestureDistanceMinFactor) / gestureDistanceFactorStep)
            .round();
    return gestureDistanceMinFactor + stepIndex * gestureDistanceFactorStep;
  }

  static String _percent(double factor) =>
      NumberFormat.percentPattern().format(factor);

  @override
  Widget build(BuildContext context) {
    final factor = useKeyedState(_snap(value / defaultValue), [value]);

    final sliderLabel = _percent(factor.value);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(title),
            subtitle: Text(subtitle),
            leading: Icon(icon),
            contentPadding: EdgeInsets.zero,
            enabled: enabled,
          ),
          Row(
            children: [
              Text(
                sliderLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: enabled ? null : Theme.of(context).disabledColor,
                ),
              ),
              Expanded(
                child: Slider(
                  min: gestureDistanceMinFactor,
                  max: gestureDistanceMaxFactor,
                  divisions: _divisions,
                  label: sliderLabel,
                  // Without it a screen reader announces the position within
                  // the track as a percentage, so the default read out as
                  // "27%" while the screen shows 100%.
                  semanticFormatterCallback: _percent,
                  value: factor.value,
                  onChanged: enabled
                      ? (value) {
                          factor.value = value;
                        }
                      : null,
                  onChangeEnd: enabled
                      ? (value) async {
                          final snapped = _snap(value);
                          factor.value = snapped;
                          await onChanged(defaultValue * snapped);
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
