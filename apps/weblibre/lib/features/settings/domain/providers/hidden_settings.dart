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
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/keyboard_shortcuts/domain/repositories/keyboard_shortcut_settings.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_diagnostics_settings.dart';

part 'hidden_settings.g.dart';

/// Everything a visibility switch can stop from applying, as stored
/// ([SettingsSnapshot]). Containers count as using nothing until they load.
@Riverpod()
SettingsSnapshot storedSettingsSnapshot(Ref ref) {
  final containers =
      ref.watch(watchContainersWithCountProvider).value ?? const [];

  return SettingsSnapshot(
    general: ref.watch(storedGeneralSettingsProvider),
    engine: ref.watch(storedEngineSettingsProvider),
    gestures: ref.watch(storedGestureSettingsProvider),
    keyboardShortcuts: ref.watch(keyboardShortcutSettingsRepositoryProvider),
    proxyDiagnostics: ref.watch(storedProxyDiagnosticsSettingsProvider),
    toolbars: {
      for (final location in ToolbarConfigLocation.values)
        location: ref.watch(storedToolbarButtonConfigsProvider(location)).value,
    },
    menu: ref.watch(menuLayoutProvider),
    strictContainers: containers.any((c) => c.metadata.strictMode),
    appLinkContainers: containers.any(
      (c) => c.metadata.isolatedAppLinkSettings,
    ),
  );
}

/// The changes that are not applied while their feature is hidden
/// ([SettingsSnapshot.suspended]): what Settings marks "Not applied while
/// hidden".
@Riverpod()
class SuspendedSettings extends _$SuspendedSettings {
  @override
  Set<HiddenSetting> build() =>
      ref.watch(storedSettingsSnapshotProvider).suspended;

  @override
  bool updateShouldNotify(
    Set<HiddenSetting> previous,
    Set<HiddenSetting> next,
  ) => !setEquals(previous, next);
}
