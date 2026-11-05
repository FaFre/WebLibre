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
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';

part 'save_settings.g.dart';

/// Whether what the settings screens save lands in the profile at once:
/// false in the onboarding, whose draft is committed only at Done. Effects
/// that only make sense for a live change (a restart offer, forgetting a
/// declined reveal) wait while it is false.
@Riverpod(keepAlive: true)
bool settingsEditsAreLive(Ref ref) =>
    ref.watch(setupDraftControllerProvider.select((draft) => draft == null));

/// How the settings screens save general settings: into the profile, or in
/// the onboarding into its draft, as a settings edit ([save]) or a visibility
/// edit ([saveVisibility]), which a preset change drops. Only settings UI
/// writes through here; the browser writes the repository, so nothing it
/// does lands in a draft.
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
    if (ref.read(setupDraftControllerProvider) != null) {
      ref
          .read(setupDraftControllerProvider.notifier)
          .editGeneral(updateSettings);
      return true;
    }
    return await _saveLive(updateSettings);
  }

  /// Like [save], for a change that only shows or hides features (a
  /// visibility switch, showing a hidden feature): filed in the onboarding
  /// as a visibility edit, which a preset change drops. The save controller
  /// cannot tell the two apart from the function, so the caller says.
  Future<bool> saveVisibility(UpdateGeneralSettingsFunc updateSettings) async {
    if (ref.read(setupDraftControllerProvider) != null) {
      ref
          .read(setupDraftControllerProvider.notifier)
          .editVisibility(updateSettings);
      return true;
    }
    return await _saveLive(updateSettings);
  }

  Future<bool> _saveLive(UpdateGeneralSettingsFunc updateSettings) async {
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

/// Like [SaveGeneralSettingsController], for the engine settings.
@Riverpod(keepAlive: true)
class SaveEngineSettingsController extends _$SaveEngineSettingsController {
  @override
  Future<void> build() {
    return Future.value();
  }

  Future<void> save(UpdateEngineSettingsFunc updateSettings) async {
    if (ref.read(setupDraftControllerProvider) != null) {
      ref
          .read(setupDraftControllerProvider.notifier)
          .editEngine(updateSettings);
      return;
    }

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
