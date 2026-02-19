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

import 'package:hooks_riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

extension CacheForExtension on Ref {
  /// Keeps the provider alive for [duration] after the last listener is removed.
  KeepAliveLink cacheFor(Duration duration) {
    Timer? timer;
    final link = keepAlive();

    onCancel(() {
      // All listeners are gone — start the dispose timer.
      timer = Timer(duration, link.close);
    });

    onResume(() {
      // A new listener was added — cancel the timer.
      timer?.cancel();
    });

    onDispose(() {
      // Provider is being fully disposed — clean up.
      timer?.cancel();
    });

    return link;
  }
}
