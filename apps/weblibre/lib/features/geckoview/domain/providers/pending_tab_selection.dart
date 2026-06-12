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
import 'package:weblibre/features/geckoview/domain/providers/restore_complete.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';

part 'pending_tab_selection.g.dart';

/// Queues the selection of a tab that exists in the local DB but has not
/// been delivered by the native session restore yet (placeholder chips at
/// cold start). The queued tab is selected as soon as its native state
/// arrives; the queue clears itself if restore finishes without it.
@Riverpod(keepAlive: true)
class PendingTabSelection extends _$PendingTabSelection {
  void queue(String tabId) {
    if (state != tabId) {
      state = tabId;
    }
  }

  void clear() {
    state = null;
  }

  @override
  String? build() {
    ref.listen(
      tabStatesProvider,
      (previous, next) {
        final pendingTabId = state;
        if (pendingTabId != null && next.containsKey(pendingTabId)) {
          state = null;
          unawaited(
            ref.read(tabRepositoryProvider.notifier).selectTab(pendingTabId),
          );
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to tabStatesProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    // Stale-tab safety: when restore finishes and the queued id never
    // appeared, the tab no longer exists.
    ref.listen(browserRestoreCompleteProvider, (previous, next) {
      if (next &&
          state != null &&
          !ref.read(tabStatesProvider).containsKey(state)) {
        state = null;
      }
    });

    return null;
  }
}
