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
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_detail_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/toolbar_visibility.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

const _tabId = 'tab';
const _partnerId = 'partner';
const _otherId = 'other';

class _FakeTabStates extends TabStates {
  @override
  Map<String, TabState> build() => {
    for (final id in [_tabId, _partnerId, _otherId]) id: TabState.$default(id),
  };

  void setLoading(bool isLoading) {
    state = {...state, _tabId: state[_tabId]!.copyWith.isLoading(isLoading)};
  }
}

class _FakeSelectedTab extends SelectedTab {
  @override
  String? build() => _tabId;

  // ignore: use_setters_to_change_properties
  void set(String? id) => state = id;
}

/// Stands in for the shown split pair.
class _ShownPair extends Notifier<SplitPair?> {
  @override
  SplitPair? build() => null;

  // ignore: use_setters_to_change_properties
  void set(SplitPair? pair) => state = pair;
}

final _shownPairProvider = NotifierProvider<_ShownPair, SplitPair?>(
  _ShownPair.new,
);

SplitPair _pair(String first, String second, {bool focusedOnly = false}) =>
    SplitPair(
      pairId: '$first+$second',
      firstTabId: first,
      secondTabId: second,
      focusedOnly: focusedOnly,
    );

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

  ToolbarVisibility visibility([String tabId = _tabId]) =>
      container.read(toolbarVisibilityControllerProvider(tabId));

  ToolbarVisibilityController controller([String tabId = _tabId]) =>
      container.read(toolbarVisibilityControllerProvider(tabId).notifier);

  void showPair(SplitPair? pair) =>
      container.read(_shownPairProvider.notifier).set(pair);

  void select(String id) =>
      (container.read(selectedTabProvider.notifier) as _FakeSelectedTab).set(
        id,
      );

  setUp(() {
    container = ProviderContainer(
      overrides: [
        tabStatesProvider.overrideWith(_FakeTabStates.new),
        generalSettingsWithDefaultsProvider.overrideWith(
          (ref) => GeneralSettings.withDefaults(autoHideTabBar: true),
        ),
        viewportServiceProvider.overrideWithValue(_ScrollingViewportService()),
        selectedTabProvider.overrideWith(_FakeSelectedTab.new),
        splitPairShownProvider.overrideWith(
          (ref) => ref.watch(_shownPairProvider),
        ),
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

  group('a shown split pair', () {
    setUp(() {
      controller().forceShow();
      container.read(selectedTabProvider);
      // Both members' controllers exist, as they do once each was selected.
      visibility(_partnerId);
      showPair(_pair(_tabId, _partnerId));
    });

    test('a scroll does not hide the bars', () {
      controller().requestHide();

      expect(visibility(), ToolbarVisibility.visible);
    });

    test('dismissing hides the bars for both panes', () {
      controller().dismiss();

      expect(visibility(), ToolbarVisibility.dismissed);
      expect(visibility(_partnerId), ToolbarVisibility.dismissed);
    });

    test('showing again shows them for both panes', () {
      controller().dismiss();
      controller(_partnerId).forceShow();

      expect(visibility(), ToolbarVisibility.visible);
      expect(visibility(_partnerId), ToolbarVisibility.visible);
    });

    test('a tab outside the pair keeps its own state', () {
      controller(_otherId).dismiss();

      expect(visibility(), ToolbarVisibility.visible);
      expect(visibility(_otherId), ToolbarVisibility.dismissed);
    });

    test("a new partner takes the selected pane's state", () {
      controller().dismiss();
      visibility(_otherId);

      showPair(_pair(_tabId, _otherId));

      expect(visibility(_otherId), ToolbarVisibility.dismissed);
    });

    test("a partner created while paired starts with the pair's state", () {
      controller().dismiss();
      showPair(_pair(_tabId, _otherId));

      expect(visibility(_otherId), ToolbarVisibility.dismissed);
    });

    test('"Show only this page" lets a scroll hide the bar', () {
      showPair(_pair(_tabId, _partnerId, focusedOnly: true));

      controller().requestHide();

      expect(visibility(), ToolbarVisibility.hidden);
    });

    test('showing both pages again brings a scrolled-away bar back', () {
      showPair(_pair(_tabId, _partnerId, focusedOnly: true));
      controller().requestHide();

      showPair(_pair(_tabId, _partnerId));

      expect(visibility(), ToolbarVisibility.visible);
    });

    test('dismissing still applies to both with only one page shown', () {
      showPair(_pair(_tabId, _partnerId, focusedOnly: true));

      controller().dismiss();

      expect(visibility(_partnerId), ToolbarVisibility.dismissed);
    });

    test('ending the pair makes each tab independent again', () {
      showPair(null);
      controller().dismiss();

      expect(visibility(_partnerId), ToolbarVisibility.visible);
    });
  });

  test('a bar scrolled away comes back when its tab is paired', () {
    container.read(selectedTabProvider);
    expect(visibility(), ToolbarVisibility.hidden);

    showPair(_pair(_tabId, _partnerId));

    expect(visibility(), ToolbarVisibility.visible);
  });

  test('the selected pane keeps its state when the pair forms', () {
    controller().dismiss();
    visibility(_partnerId);
    select(_tabId);

    showPair(_pair(_partnerId, _tabId));

    expect(visibility(), ToolbarVisibility.dismissed);
    expect(visibility(_partnerId), ToolbarVisibility.dismissed);
  });
}
