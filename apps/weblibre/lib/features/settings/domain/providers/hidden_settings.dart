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

import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/keyboard_shortcuts/domain/repositories/keyboard_shortcut_settings.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ToolbarButtonConfig;
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_diagnostics_settings.dart';

part 'hidden_settings.g.dart';

/// Everything a visibility switch can stop from applying, as the profile
/// stores it ([SettingsSnapshot]); never the onboarding draft. Containers
/// count as using nothing until they load.
///
/// The profile layer: what a reveal from a gesture or shortcut, which writes
/// the profile, lists as applying again.
@Riverpod()
SettingsSnapshot profileSettingsSnapshot(Ref ref) => _snapshot(
  ref,
  general: ref.watch(profileGeneralSettingsProvider),
  engine: ref.watch(profileEngineSettingsProvider),
  toolbars: {
    for (final location in ToolbarConfigLocation.values)
      location: ref.watch(profileToolbarButtonConfigsProvider(location)).value,
  },
  menu: ref.watch(menuLayoutProvider),
);

/// Everything a visibility switch can stop from applying, as the screens that
/// edit settings show it ([SettingsSnapshot]): in the onboarding with the
/// draft applied, otherwise the profile's ([profileSettingsSnapshot]).
///
/// The edit layer: Settings' "Not applied while hidden" and Feature Control
/// read it. Reads the draft and the profile's providers, never the layout
/// editors, which are auto-disposed.
@Riverpod()
SettingsSnapshot storedSettingsSnapshot(Ref ref) {
  final draft = ref.watch(setupDraftControllerProvider);
  if (draft == null) return ref.watch(profileSettingsSnapshotProvider);

  return _snapshot(
    ref,
    general: ref.watch(draftGeneralSettingsProvider),
    engine: ref.watch(draftEngineSettingsProvider),
    toolbars: {
      for (final location in ToolbarConfigLocation.values)
        location:
            draft.toolbarButtons[location] ??
            ref.watch(profileToolbarButtonConfigsProvider(location)).value,
    },
    menu: draft.menuLayout ?? ref.watch(menuLayoutProvider),
  );
}

/// A snapshot of [general], [engine], [toolbars] and [menu], with the
/// settings no onboarding edits as the profile stores them.
SettingsSnapshot _snapshot(
  Ref ref, {
  required GeneralSettings general,
  required EngineSettings engine,
  required Map<ToolbarConfigLocation, List<ToolbarButtonConfig>> toolbars,
  required List<MenuSectionEntry> menu,
}) {
  // The containers without their tab counts, which change with every write
  // to a tab: only the two answers below are needed.
  final strictContainers = ref.watch(
    watchContainersProvider.select(
      (containers) =>
          containers.value?.any((c) => c.metadata.strictMode) ?? false,
    ),
  );
  final appLinkContainers = ref.watch(
    watchContainersProvider.select(
      (containers) =>
          containers.value?.any((c) => c.metadata.isolatedAppLinkSettings) ??
          false,
    ),
  );

  return SettingsSnapshot(
    general: general,
    engine: engine,
    gestures: ref.watch(storedGestureSettingsProvider),
    keyboardShortcuts: ref.watch(keyboardShortcutSettingsRepositoryProvider),
    proxyDiagnostics: ref.watch(storedProxyDiagnosticsSettingsProvider),
    toolbars: toolbars,
    menu: menu,
    strictContainers: strictContainers,
    appLinkContainers: appLinkContainers,
  );
}

/// Whether the streams [profileSettingsSnapshot] reads have loaded. Until
/// then it counts the toolbars and containers as defaults.
@Riverpod()
bool profileSettingsSnapshotLoaded(Ref ref) {
  bool settled(AsyncValue<Object?> value) => value.hasValue || value.hasError;
  return ToolbarConfigLocation.values.every(
        (location) =>
            settled(ref.watch(toolbarButtonConfigsProvider(location))),
      ) &&
      settled(ref.watch(watchContainersProvider));
}

/// [profileSettingsSnapshotProvider] for a decision taken once rather than
/// watched, such as what a reveal of a gesture or shortcut lists. Always the
/// profile, never a draft: such a reveal writes the profile. Read as soon as
/// its streams have
/// loaded, so a toolbar or container nothing on screen watches yet does not
/// count as unchanged. After [timeout] it is taken as it is.
Future<SettingsSnapshot> readLoadedSettingsSnapshot(
  Ref ref, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final loaded = Completer<void>();
  final subscription = ref.listen(profileSettingsSnapshotLoadedProvider, (
    previous,
    next,
  ) {
    if (next && !loaded.isCompleted) loaded.complete();
  }, fireImmediately: true);
  final SettingsSnapshot snapshot;
  try {
    await loaded.future.timeout(timeout, onTimeout: () {});
    snapshot = ref.read(profileSettingsSnapshotProvider);
  } finally {
    subscription.close();
  }
  return snapshot;
}

/// The changes that are not applied while their feature is hidden
/// ([SettingsSnapshot.suspended]): what Settings marks "Not applied while
/// hidden".
///
/// None in the onboarding: a fresh install has nothing changed for a hidden
/// feature to stop applying, and the draft's own changes are not marked.
@Riverpod()
class SuspendedSettings extends _$SuspendedSettings {
  @override
  Set<HiddenSetting> build() {
    final drafting = ref.watch(
      setupDraftControllerProvider.select((draft) => draft != null),
    );
    if (drafting) return const {};
    return ref.watch(storedSettingsSnapshotProvider).suspended;
  }

  @override
  bool updateShouldNotify(
    Set<HiddenSetting> previous,
    Set<HiddenSetting> next,
  ) => !setEquals(previous, next);
}
