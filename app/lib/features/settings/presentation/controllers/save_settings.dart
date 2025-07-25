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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'save_settings.g.dart';

@Riverpod(keepAlive: true)
class SaveGeneralSettingsController extends _$SaveGeneralSettingsController {
  @override
  Future<void> build() {
    return Future.value();
  }

  Future<void> save(UpdateGeneralSettingsFunc updateSettings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(generalSettingsRepositoryProvider.notifier)
          .updateSettings(updateSettings),
    );
  }
}

@Riverpod(keepAlive: true)
class SaveEngineSettingsController extends _$SaveEngineSettingsController {
  @override
  Future<void> build() {
    return Future.value();
  }

  Future<void> save(UpdateEngineSettingsFunc updateSettings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(engineSettingsRepositoryProvider.notifier)
          .updateSettings(updateSettings),
    );
  }
}
