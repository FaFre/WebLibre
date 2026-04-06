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

/// Adds a given [listener] to a [Listenable] and removes it when the hook is
/// disposed. The listener is only called when the [selector] result changes.
///
/// As opposed to `useListenable`, this hook does not mark the widget as needing
/// build when the listener is called. Use this for side effects that do not
/// require a rebuild.
///
/// See also:
///  * [Listenable]
///  * [ValueListenable]
///  * [useOnListenableChange]
void useOnListenableChangeSelector<R>(
  Listenable? listenable,
  R Function() selector,
  VoidCallback listener,
) {
  return use(_OnListenableChangeSelectorHook(listenable, selector, listener));
}

class _OnListenableChangeSelectorHook<R> extends Hook<void> {
  const _OnListenableChangeSelectorHook(
    this.listenable,
    this.selector,
    this.listener,
  );

  final Listenable? listenable;
  final R Function() selector;
  final VoidCallback listener;

  @override
  _OnListenableChangeSelectorHookState<R> createState() =>
      _OnListenableChangeSelectorHookState<R>();
}

class _OnListenableChangeSelectorHookState<R>
    extends HookState<void, _OnListenableChangeSelectorHook<R>> {
  late R _selectorResult = hook.selector();

  @override
  void initHook() {
    super.initHook();
    hook.listenable?.addListener(_listener);
  }

  @override
  void didUpdateHook(_OnListenableChangeSelectorHook<R> oldHook) {
    super.didUpdateHook(oldHook);

    if (hook.selector != oldHook.selector) {
      _selectorResult = hook.selector();
    }

    if (hook.listenable != oldHook.listenable) {
      oldHook.listenable?.removeListener(_listener);
      hook.listenable?.addListener(_listener);
      _selectorResult = hook.selector();
    }
  }

  @override
  void build(BuildContext context) {}

  void _listener() {
    final latestSelectorResult = hook.selector();
    if (_selectorResult != latestSelectorResult) {
      _selectorResult = latestSelectorResult;
      hook.listener();
    }
  }

  @override
  void dispose() {
    hook.listenable?.removeListener(_listener);
  }

  @override
  String get debugLabel => 'useOnListenableChangeSelector<$R>';

  @override
  Object? get debugValue => hook.listenable;
}
