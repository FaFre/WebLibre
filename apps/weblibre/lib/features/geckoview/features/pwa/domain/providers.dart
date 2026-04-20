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
import 'package:weblibre/core/filesystem.dart' show filesystem;
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/pwa/domain/pwa_installability.dart';

part 'providers.g.dart';

/// Stream of manifest update events from the event service.
@Riverpod(keepAlive: true)
Stream<ManifestUpdateEvent> manifestUpdateEventsStream(Ref ref) {
  final eventService = ref.watch(eventServiceProvider);
  return eventService.manifestUpdateEvents;
}

/// Manages PWA manifest state with a long-running subscription.
@Riverpod(keepAlive: true)
class PwaManifestState extends _$PwaManifestState {
  PwaManifest? getManifest(String tabId) => state[tabId];

  @override
  Map<String, PwaManifest?> build() {
    // Listen to manifest update events using ref.listenManual
    ref.listen(
      manifestUpdateEventsStreamProvider,
      (previous, next) {
        if (next.hasValue) {
          final event = next.value!;
          // Update state with new manifest - this triggers rebuilds
          state = {...state, event.tabId: event.manifest};
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to manifest update events',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    return {};
  }
}

/// PWA manifest for the currently selected tab.
@Riverpod()
PwaManifest? currentTabManifest(Ref ref) {
  final selectedTabId = ref.watch(selectedTabProvider);
  final manifestState = ref.watch(pwaManifestStateProvider);

  if (selectedTabId == null) return null;

  return manifestState[selectedTabId];
}

/// Boolean indicating if the current tab is installable as a PWA.
@Riverpod()
bool isCurrentTabInstallable(Ref ref) {
  final manifest = ref.watch(currentTabManifestProvider);

  if (manifest == null) return false;

  return isManifestInstallable(manifest);
}

/// Installs the current tab as a PWA, embedding profile and container context
/// in the shortcut intent so the PWA reopens with the same isolation.
@Riverpod()
Future<bool> installCurrentWebApp(
  Ref ref, {
  String? overrideName,
  String? contextId,
}) async {
  final selectedTabId = ref.read(selectedTabProvider);

  if (selectedTabId == null) {
    throw StateError('No tab selected');
  }

  final profileUuid = filesystem.selectedProfile.uuid;

  return GeckoPwaApi().installWebApp(
    selectedTabId,
    profileUuid,
    contextId,
    overrideName,
  );
}

/// Returns all installed PWAs.
@Riverpod()
Future<List<PwaManifest>> installedWebApps(Ref ref) {
  return GeckoPwaApi().getInstalledWebApps();
}

/// Whether the current tab is on an HTTPS page (eligible for home screen shortcut).
@Riverpod()
bool isCurrentTabShortcutable(Ref ref) {
  final selectedTabId = ref.watch(selectedTabProvider);
  if (selectedTabId == null) return false;

  final tabState = ref.watch(tabStateProvider(selectedTabId));
  if (tabState == null) return false;

  return tabState.url.isHttps ||
      (tabState.url.isHttp && tabState.url.isLocalhost);
}

/// Creates a basic bookmark shortcut on the home screen for the current tab.
@Riverpod()
Future<bool> installBasicShortcut(
  Ref ref, {
  String? overrideName,
  String? contextId,
}) async {
  final selectedTabId = ref.read(selectedTabProvider);

  if (selectedTabId == null) {
    throw StateError('No tab selected');
  }

  final profileUuid = filesystem.selectedProfile.uuid;

  return GeckoPwaApi().installBasicShortcut(
    selectedTabId,
    profileUuid,
    contextId,
    overrideName,
  );
}
