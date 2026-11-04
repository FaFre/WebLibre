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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';

part 'save_settings.g.dart';

/// Implemented by the onboarding draft scope's save controllers: their
/// saves go to the draft rather than the live settings.
///
/// Widgets that reach state the draft does not hold (toolbar button and menu
/// arrangements, which have their own stores) hide their entry point below
/// such a controller, so nothing is written before the user taps Done.
abstract interface class SavesToDraft {}

@Riverpod(keepAlive: true)
class SaveGeneralSettingsController extends _$SaveGeneralSettingsController {
  @override
  Future<void> build() {
    return Future.value();
  }

  /// Writes [updateSettings] and returns whether it landed. A failure (full
  /// storage, say) is kept in the state rather than thrown, so a caller that
  /// confirms the change checks the result first.
  Future<bool> save(UpdateGeneralSettingsFunc updateSettings) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ref
          .read(generalSettingsRepositoryProvider.notifier)
          .updateSettings(updateSettings),
    );

    if (ref.mounted) state = result;
    return !result.hasError;
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

    final result = await AsyncValue.guard(
      () => ref
          .read(engineSettingsRepositoryProvider.notifier)
          .updateSettings(updateSettings),
    );

    if (!ref.mounted) {
      return;
    }

    state = result;
  }
}

@Riverpod(keepAlive: true)
class SaveTorSettingsController extends _$SaveTorSettingsController {
  @override
  Future<void> build() {
    return Future.value();
  }

  Future<void> save(UpdateTorSettingsFunc updateSettings) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ref
          .read(torSettingsRepositoryProvider.notifier)
          .updateSettings(updateSettings),
    );

    if (!ref.mounted) {
      return;
    }

    state = result;
  }
}
