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
import 'dart:async';

class Debouncer {
  final Duration debounce;

  Timer? _timer;
  bool _hasRan = false;

  Debouncer(this.debounce);

  bool get isDebouncing => _timer?.isActive ?? false;
  bool get hasRan => _hasRan;

  void eventOccured(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(debounce, () {
      callback.call();
      _hasRan = true;
    });
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
