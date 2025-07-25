/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:weblibre/utils/sampled_value_notifier.dart';

/// A custom hook that creates a sampled ValueNotifier from another ValueNotifier
ValueNotifier<T> useSampledValueNotifier<T>({
  required ValueNotifier<T> source,
  required Duration sampleDuration,
}) {
  return use(
    _SampledValueNotifierHook<T>(
      source: source,
      sampleDuration: sampleDuration,
    ),
  );
}

/// Hook implementation for sampled ValueNotifier
class _SampledValueNotifierHook<T> extends Hook<ValueNotifier<T>> {
  final ValueNotifier<T> source;
  final Duration sampleDuration;

  const _SampledValueNotifierHook({
    required this.source,
    required this.sampleDuration,
  });

  @override
  _SampledValueNotifierHookState<T> createState() =>
      _SampledValueNotifierHookState<T>();
}

class _SampledValueNotifierHookState<T>
    extends HookState<ValueNotifier<T>, _SampledValueNotifierHook<T>> {
  late SampledValueNotifier<T> _sampledNotifier;

  @override
  void initHook() {
    super.initHook();
    _sampledNotifier = SampledValueNotifier<T>(
      source: hook.source,
      sampleDuration: hook.sampleDuration,
    );
  }

  @override
  ValueNotifier<T> build(BuildContext context) {
    return _sampledNotifier;
  }

  @override
  void dispose() {
    _sampledNotifier.dispose();
    super.dispose();
  }

  @override
  String get debugLabel => 'useSampledValueNotifier<$T>';
}
