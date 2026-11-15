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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';

part 'pending_writes.g.dart';

/// Writes that are deliberately delayed (debounced tab state, for one) and
/// must not be lost when the process is about to end on purpose: a
/// self-update ends it without warning. Owners register a flush while they
/// hold pending work.
class PendingWrites {
  final _flushers = <Future<void> Function()>{};

  /// Returns the function that unregisters [flush].
  void Function() register(Future<void> Function() flush) {
    _flushers.add(flush);
    return () => _flushers.remove(flush);
  }

  /// Runs every registered flush, each bounded so a stuck one can't hold up
  /// the caller.
  Future<void> flushAll({Duration timeout = const Duration(seconds: 5)}) async {
    await Future.wait([
      for (final flush in _flushers.toList())
        flush().timeout(timeout).catchError((Object e, StackTrace s) {
          logger.w('Pending write flush failed', error: e, stackTrace: s);
        }),
    ]);
  }
}

@Riverpod(keepAlive: true)
PendingWrites pendingWrites(Ref ref) => PendingWrites();
