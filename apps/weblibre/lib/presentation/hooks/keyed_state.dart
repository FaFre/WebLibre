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
import 'package:flutter_hooks/flutter_hooks.dart';

/// Creates a [ValueNotifier] that is re-created when [keys] change.
ValueNotifier<T> useKeyedState<T>(T initialData, List<Object?> keys) {
  return use(_KeyedStateHook<T>(initialData: initialData, keys: keys));
}

class _KeyedStateHook<T> extends Hook<ValueNotifier<T>> {
  const _KeyedStateHook({
    required this.initialData,
    required List<Object?> keys,
  }) : super(keys: keys);

  final T initialData;

  @override
  _KeyedStateHookState<T> createState() => _KeyedStateHookState<T>();
}

class _KeyedStateHookState<T>
    extends HookState<ValueNotifier<T>, _KeyedStateHook<T>> {
  late final _state = ValueNotifier<T>(hook.initialData)
    ..addListener(_listener);

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  ValueNotifier<T> build(BuildContext context) => _state;

  void _listener() {
    setState(() {});
  }

  @override
  Object? get debugValue => _state.value;

  @override
  String get debugLabel => 'useKeyedState<$T>';
}
