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
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// The index of the stop in [stops] closest to [value]; the first of two
/// equally close ones.
int nearestStopIndex<T extends num>(List<T> stops, T value) => minBy(
  Iterable<int>.generate(stops.length),
  (index) => (stops[index] - value).abs(),
)!;

/// [stops] with [value] among them, so a [StopsSliderTile] shows the value in
/// effect: [stops] themselves when one is [value], or within [tolerance] of it
/// (a double saved with rounding noise, which reads the same), and [value]
/// put in order among them otherwise. The returned value is the stop to pass
/// as [StopsSliderTile.value].
///
/// A value that is not one of the [stops] (from an older build, a backup or
/// a sync) then keeps its own stop until the slider moves off it, instead of
/// reading as a neighbour it is not.
({List<T> stops, T value}) stopsWithValue<T extends num>(
  List<T> stops,
  T value, {
  double tolerance = 1e-9,
}) {
  final nearest = stops[nearestStopIndex(stops, value)];
  if ((nearest - value).abs() <= tolerance) {
    return (stops: stops, value: nearest);
  }
  return (
    stops: [...stops, value].sorted((a, b) => a.compareTo(b)),
    value: value,
  );
}

/// A setting chosen from a list of [stops] with a discrete slider: the one
/// slider row of the settings screens.
///
/// The stops need not be evenly spaced: the slider moves through their
/// indices, so a duration can step by minutes at the short end and by hours at
/// the long end. An evenly spaced range is a list of stops too; build it from
/// whole numbers (`i / 20`, not `min + i * 0.05`) so that every stop, and so
/// every saved value, is the decimal it reads as. The chosen stop's label
/// shows beside the title, and while dragging above the thumb.
class StopsSliderTile<T> extends HookWidget {
  const StopsSliderTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.stops,
    required this.value,
    required this.labelFor,
    required this.onChanged,
    this.subtitleFor,
    this.enabled = true,
    super.key,
  }) : assert(stops.length > 1);

  final String title;
  final String subtitle;

  /// The subtitle while [stop] is under the thumb, or null for [subtitle].
  /// It follows the thumb during a drag, not only the saved value.
  final String? Function(T stop)? subtitleFor;
  final IconData icon;

  /// The stops, in order along the track. [value] must be one of them:
  /// [stopsWithValue] adds a stored value that is not.
  final List<T> stops;

  /// The stored value, as one of the [stops].
  final T value;
  final String Function(T stop) labelFor;

  /// Called once a drag or tap ends on a stop other than [value].
  final Future<void> Function(T stop) onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    assert(stops.contains(value), 'value $value is not one of the stops');

    // The stop the thumb is on while the user moves it, and after, until the
    // save comes back as [value] (or, if it fails, until the next drag). A record, so that a null stop ("No Limit")
    // can be held too. Kept by stop, not index: an extra stop for an
    // off-list value leaves the list once the value changes, and every index
    // after it shifts.
    final heldStop = useState<(T,)?>(null);
    final dragging = useRef(false);

    // A new stored value replaces the held stop, except during a drag: a save
    // from an earlier drag landing mid-gesture would otherwise snap the thumb
    // back under the finger.
    useEffect(() {
      if (!dragging.value) heldStop.value = null;
      return null;
    }, [value]);

    final held = heldStop.value;
    final shownStop = held != null && stops.contains(held.$1) ? held.$1 : value;
    final shownIndex = stops.indexOf(shownStop);

    final theme = Theme.of(context);
    final label = labelFor(shownStop);

    T stopAt(double position) =>
        stops[position.round().clamp(0, stops.length - 1)];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(title),
            subtitle: Text(subtitleFor?.call(shownStop) ?? subtitle),
            leading: Icon(icon),
            // The label sits here rather than beside the slider, where a
            // label whose width changes with the stop ("1 minute", "No Limit")
            // would resize the track under the finger.
            trailing: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: enabled
                    ? theme.colorScheme.primary
                    : theme.disabledColor,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            enabled: enabled,
          ),
          Slider(
            max: (stops.length - 1).toDouble(),
            divisions: stops.length - 1,
            label: label,
            // Without it a screen reader announces the position within the
            // track as a percentage instead of the stop.
            semanticFormatterCallback: (position) => labelFor(stopAt(position)),
            value: shownIndex.toDouble(),
            onChangeStart: enabled
                ? (_) {
                    dragging.value = true;
                  }
                : null,
            onChanged: enabled
                ? (position) {
                    heldStop.value = (stopAt(position),);
                  }
                : null,
            onChangeEnd: enabled
                ? (position) async {
                    dragging.value = false;
                    final stop = stopAt(position);
                    // A tap on the thumb, or a drag back to where it started,
                    // keeps the stored value, which may be off the list.
                    if (stop == value) {
                      heldStop.value = null;
                      return;
                    }
                    // Held until the save comes back as [value]: the
                    // settings stream emits after the write, so letting go
                    // when [onChanged] returns would flash the old stop.
                    heldStop.value = (stop,);
                    await onChanged(stop);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
