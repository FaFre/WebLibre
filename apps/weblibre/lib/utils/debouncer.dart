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
import 'dart:async';

class Debouncer {
  final Duration debounce;

  Timer? _timer;
  void Function()? _pending;
  final _running = <Future<void>>{};
  bool _hasRan = false;

  Debouncer(this.debounce);

  bool get isDebouncing => _timer?.isActive ?? false;
  bool get hasRan => _hasRan;

  /// [callback] may be async: [flush] then waits for its future.
  void eventOccured(void Function() callback) {
    _timer?.cancel();
    _pending = callback;
    _timer = Timer(debounce, () => unawaited(_fire(callback)));
  }

  /// Runs a pending callback now instead of when its timer fires, and waits
  /// for it and for every callback the timer already started.
  Future<void> flush() async {
    final pending = _pending;
    if (pending != null && isDebouncing) {
      // The error reaches the caller through the wait below.
      unawaited(_fire(pending).catchError((_) {}));
    }
    if (_running.isEmpty) return;
    await Future.wait(_running.toList());
  }

  Future<void> _fire(void Function() callback) {
    _timer?.cancel();
    _pending = null;
    _hasRan = true;
    // Future.sync follows a future the callback returns.
    return _track(Future.sync(callback));
  }

  /// Keeps [run] in [_running] until it completes; the returned future
  /// completes like [run].
  Future<void> _track(Future<void> run) {
    _running.add(run);
    return run.whenComplete(() => _running.remove(run));
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _pending = null;
  }
}
