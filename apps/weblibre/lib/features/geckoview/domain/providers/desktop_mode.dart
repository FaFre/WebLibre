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
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'desktop_mode.g.dart';

@Riverpod(keepAlive: true)
class DesktopMode extends _$DesktopMode {
  // ignore: use_setters_to_change_properties
  void enabled(bool value) {
    state = value;
  }

  void toggle() {
    state = !state;
  }

  @override
  bool build(String tabId) {
    listenSelf((previous, next) async {
      if (previous != null) {
        await ref
            .read(tabSessionProvider(tabId: tabId).notifier)
            .requestDesktopSite(next);
      }
    });

    // Seed the initial value from the browser-wide default so a newly opened
    // tab's menu checkbox matches the desktop mode it was actually created with
    // natively (GeckoTabsApi seeds new tabs from BrowserState.desktopMode).
    // Read (not watch) so toggling the global default never clobbers an
    // existing tab's per-tab override.
    return ref.read(generalSettingsWithDefaultsProvider).globalDesktopMode;
  }
}
