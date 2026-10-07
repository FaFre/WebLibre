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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/history.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_detail_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/toolbar_visibility.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

const _tabId = 'tab';

class _FakeTabStates extends TabStates {
  @override
  Map<String, TabState> build() => {_tabId: TabState.$default(_tabId)};

  void setLoading(bool isLoading) {
    state = {_tabId: state[_tabId]!.copyWith.isLoading(isLoading)};
  }
}

/// The page under the finger scrolls, so a scroll may hide the bar.
class _ScrollingViewportService extends GeckoViewportService {
  @override
  bool get isBrowserHandlingScrollEnabled => true;
}

HistoryState _history(List<String> urls) => HistoryState(
  items: [for (final url in urls) HistoryItem(url: Uri.parse(url), title: url)],
  currentIndex: urls.length - 1,
  canGoBack: urls.length > 1,
  canGoForward: false,
);

void main() {
  late ProviderContainer container;

  ToolbarVisibility visibility() =>
      container.read(toolbarVisibilityControllerProvider(_tabId));

  ToolbarVisibilityController controller() =>
      container.read(toolbarVisibilityControllerProvider(_tabId).notifier);

  setUp(() {
    container = ProviderContainer(
      overrides: [
        tabStatesProvider.overrideWith(_FakeTabStates.new),
        generalSettingsWithDefaultsProvider.overrideWith(
          (ref) => GeneralSettings.withDefaults(autoHideTabBar: true),
        ),
        viewportServiceProvider.overrideWithValue(_ScrollingViewportService()),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(tabHistoryStatesProvider.notifier)
        .update(_tabId, _history(['https://a.example/']));
    controller().requestHide();
  });

  test('stays hidden when the history list arrives after the bar hid', () {
    expect(visibility(), ToolbarVisibility.hidden);

    // GeckoView reports the navigation's history entry from a session-store
    // flush, up to ten seconds after the page finished loading (#653).
    container
        .read(tabHistoryStatesProvider.notifier)
        .update(_tabId, _history(['https://a.example/', 'https://b.example/']));

    expect(visibility(), ToolbarVisibility.hidden);
  });

  test('shows again when a load starts', () {
    expect(visibility(), ToolbarVisibility.hidden);

    (container.read(tabStatesProvider.notifier) as _FakeTabStates).setLoading(
      true,
    );

    expect(visibility(), ToolbarVisibility.visible);
  });
}
