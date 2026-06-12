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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';

part 'restore_complete.g.dart';

/// Mirrors the native `BrowserState.restoreComplete` flag: false until the
/// session restore has dispatched all persisted tabs into the BrowserStore.
/// While false, DB-cached tabs without a native state are rendered as
/// placeholders and the destructive tab DB sync is deferred.
@Riverpod(keepAlive: true)
class BrowserRestoreComplete extends _$BrowserRestoreComplete {
  @override
  bool build() {
    final eventService = ref.watch(eventServiceProvider);

    ref.listen(
      fireImmediately: true,
      engineReadyStateProvider,
      (previous, next) async {
        if (next) {
          await GeckoTabService().syncEvents(onRestoreComplete: true);
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to engineReadyStateProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    final restoreCompleteSub = eventService.restoreCompleteEvents.listen(
      (restoreComplete) {
        if (restoreComplete != state) {
          state = restoreComplete;
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error in restore complete events',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.onDispose(() async {
      await restoreCompleteSub.cancel();
    });

    return eventService.restoreCompleteEvents.valueOrNull ?? false;
  }
}
