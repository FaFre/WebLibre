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
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_visibility.dart';
import 'package:weblibre/features/proxy/domain/providers/connection_activity.dart';
import 'package:weblibre/features/proxy/domain/providers/effective_tab_routing.dart';
import 'package:weblibre/features/proxy/domain/services/tab_routing.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

void main() {
  bool sectionShown({
    bool connectionsShown = false,
    bool connectionActive = false,
    bool torInUse = false,
    TabRoutingStatus routing = TabRoutingStatus.direct,
  }) {
    final container = ProviderContainer(
      overrides: [
        shownFeaturesProvider.overrideWithBuild(
          (ref, _) => {if (connectionsShown) FeatureId.connectionsTorBasic},
        ),
        anyConnectionActiveProvider.overrideWithValue(connectionActive),
        torInUseProvider.overrideWithValue(torInUse),
        effectiveTabRoutingProvider.overrideWith(
          (ref, tabId) => TabRouting(
            status: routing,
            isContextMismatch: false,
            contextId: null,
            proxyConnectionId: null,
            proxyTitle: null,
            containerName: null,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container.read(menuConnectionSectionShownProvider(null));
  }

  test('hidden Connections drop the section only when nothing uses it', () {
    expect(sectionShown(), isFalse);
    expect(sectionShown(connectionsShown: true), isTrue);
    expect(sectionShown(connectionActive: true), isTrue);
    expect(sectionShown(routing: TabRoutingStatus.blocked), isTrue);
  });

  test('Tor set up but stopped keeps the section (P5)', () {
    // Autostart that failed, or a route naming Tor: the menu still lists
    // Tor, so the section that holds it has to stay.
    expect(sectionShown(torInUse: true), isTrue);
  });
}
