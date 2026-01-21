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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';

part 'tab_list.g.dart';

@Riverpod(keepAlive: true)
class TabList extends _$TabList {
  @override
  EquatableValue<List<String>> build() {
    final eventService = ref.watch(eventServiceProvider);

    ref.listen(
      fireImmediately: true,
      engineReadyStateProvider,
      (previous, next) async {
        if (next) {
          await GeckoTabService().syncEvents(onTabListChange: true);
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to eventServiceProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    final tabListSub = eventService.tabListEvents.listen(
      (tabs) {
        final equatableTabs = EquatableValue(tabs);

        if (equatableTabs != state) {
          state = equatableTabs;
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error in tab list events',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.onDispose(() async {
      await tabListSub.cancel();
    });

    return EquatableValue([]);
  }
}
