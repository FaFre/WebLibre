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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/readerview/domain/providers/readerable.dart';

part 'readerable.g.dart';

@Riverpod(keepAlive: true)
class ReaderableScreenController extends _$ReaderableScreenController {
  late GeckoReaderableService _service;

  Future<void> toggleReaderView(bool enable) async {
    state = const AsyncValue.loading();

    final settled = _awaitReaderActive(enable);
    final result = await AsyncValue.guard(() async {
      await _service.toggleReaderView(enable);
      await settled;
    });

    if (!ref.mounted) {
      return;
    }

    state = result;
  }

  /// Completes once the selected tab's reader view is [active], or after a
  /// timeout: a toggle that changes nothing (disabling where reader view is
  /// already off) reports nothing either.
  ///
  /// Waiting on the next readerable event instead resolves at once, on an event
  /// replayed from earlier, and may belong to another tab.
  Future<void> _awaitReaderActive(bool active) async {
    bool isSettled() {
      final tabId = ref.read(selectedTabProvider);
      final tab = tabId != null ? ref.read(tabStatesProvider)[tabId] : null;
      return (tab?.readerableState.active ?? false) == active;
    }

    if (isSettled()) {
      return;
    }

    final completer = Completer<void>();
    final subscription = ref.listen(tabStatesProvider, (_, _) {
      if (!completer.isCompleted && isSettled()) {
        completer.complete();
      }
    });

    try {
      await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {},
      );
    } finally {
      subscription.close();
    }
  }

  @override
  Future<void> build() {
    _service = ref.watch(readerableServiceProvider);

    return Future.value();
  }
}
