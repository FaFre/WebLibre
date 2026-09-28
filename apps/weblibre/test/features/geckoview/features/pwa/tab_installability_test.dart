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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/pwa/domain/providers.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';

TabState _tab(String id, String url) =>
    TabState.$default(id).copyWith.url(Uri.parse(url));

void main() {
  // A gesture on a tab card acts on that card, which need not be the selected
  // tab. The install check has to look at the card's page, not the one on
  // screen.
  test('shortcut eligibility follows the given tab, not the selected one', () {
    final container = ProviderContainer(
      overrides: [
        selectedTabProvider.overrideWithValue('selected'),
        tabStateProvider(
          'selected',
        ).overrideWithValue(_tab('selected', 'http://example.org')),
        tabStateProvider(
          'card',
        ).overrideWithValue(_tab('card', 'https://example.org')),
        sandboxSourceUriForTabProvider(
          tabId: 'selected',
        ).overrideWithValue(null),
        sandboxSourceUriForTabProvider(tabId: 'card').overrideWithValue(null),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(isCurrentTabShortcutableProvider), isFalse);
    expect(container.read(isTabShortcutableProvider('card')), isTrue);
  });

  test('without a tab nothing is shortcutable', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(isTabShortcutableProvider(null)), isFalse);
  });
}
