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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/router.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/sections/quick_toggles_section.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Records what the toggle asks for, and forms the pair at once.
class _FakeController extends SplitViewController {
  final SplitPair? initial;
  final calls = <String>[];

  _FakeController(this.initial);

  @override
  SplitPair? build() => initial;

  /// The pair the tab was last in, as the real controller remembers it.
  SplitPair? last;

  @override
  SplitPair? lastPairOf(String tabId) => last;

  @override
  Future<void> pair(
    String first,
    String second, {
    SplitPair? arrangement,
  }) async {
    calls.add(
      'pair:$first,$second${arrangement == null ? '' : ' as ${arrangement.pairId}'}',
    );
    state = SplitPair(pairId: 'new', firstTabId: first, secondTabId: second);
  }

  @override
  void end() {
    calls.add('end');
    state = null;
  }

  @override
  void setFocusedOnly(bool focusedOnly) {
    calls.add('focusedOnly:$focusedOnly');
    super.setFocusedOnly(focusedOnly);
  }
}

class _FakeSelectedTab extends SelectedTab {
  @override
  String? build() => 'a';
}

class _FakeTabRepository extends TabRepository {
  final selected = <String>[];

  @override
  void build() {}

  @override
  Future<bool> selectTab(String tabId) async {
    selected.add(tabId);
    return true;
  }
}

TabState _tab(String tabId, [TabMode tabMode = TabMode.regular]) =>
    TabState.$default(tabId).copyWith(tabMode: tabMode);

void main() {
  late _FakeController controller;
  late _FakeTabRepository tabs;
  late ProviderContainer container;

  /// The menu with only the split toggle, as a route over the browser, with
  /// the open tabs most recently used first ('a' is the current one).
  Future<void> pumpMenu(
    WidgetTester tester, {
    SplitPair? pair,
    SplitPair? last,
    List<TabState>? openTabs,
  }) async {
    controller = _FakeController(pair)..last = last;
    tabs = _FakeTabRepository();
    final open = openTabs ?? [_tab('a'), _tab('c'), _tab('b')];
    final router = GoRouter(
      initialLocation: '/browser',
      routes: [
        GoRoute(
          path: '/browser',
          builder: (context, state) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const Scaffold(
                      body: QuickTogglesSection(
                        selectedTabId: 'a',
                        items: [MenuItemType.splitView],
                      ),
                    ),
                  ),
                ),
                child: const Text('open menu'),
              ),
            ),
          ),
          routes: [
            GoRoute(
              path: 'search/:tabType/:searchText',
              builder: (context, state) => Text(
                'search beside '
                '${state.uri.queryParameters['split-with-tab-id']}',
              ),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    container = ProviderContainer(
      overrides: [
        // The dispatcher's actions find their context through the router.
        routerProvider.overrideWith((ref) => Future.value(router)),
        generalSettingsWithDefaultsProvider.overrideWith(
          (ref) => GeneralSettings.withDefaults(),
        ),
        splitViewControllerProvider.overrideWith(() => controller),
        splitPairShownProvider.overrideWith(
          (ref) => ref.watch(splitViewControllerProvider),
        ),
        selectedTabProvider.overrideWith(_FakeSelectedTab.new),
        tabRepositoryProvider.overrideWith(() => tabs),
        tabStateProvider.overrideWith(
          (ref, tabId) => tabId == null ? null : _tab(tabId),
        ),
        fifoTabStatesProvider.overrideWith(
          (ref) => EquatableValue([for (final tab in open) (tab, null)]),
        ),
        selectedContainerDataProvider.overrideWith((ref) => Stream.value(null)),
        gestureSettingsWithDefaultsProvider.overrideWith(
          (ref) => GestureSettings.withDefaults(enabled: false),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.tap(find.text('open menu'));
    await tester.pumpAndSettle();
  }

  bool toggleActive(WidgetTester tester, {String label = 'Split'}) {
    final material = tester.widget<Material>(
      find
          .ancestor(of: find.text(label), matching: find.byType(Material))
          .first,
    );
    return material.color != Colors.transparent;
  }

  testWidgets('on: this tab beside the one used before it, keeping the '
      'focus', (tester) async {
    await pumpMenu(tester);
    expect(toggleActive(tester), isFalse);

    await tester.tap(find.text('Split'));
    await tester.pumpAndSettle();

    expect(controller.calls, ['pair:a,c']);
    // This tab keeps the focus, and the menu stays open on the toggle.
    expect(tabs.selected, isEmpty);
    expect(toggleActive(tester), isTrue);
  });

  testWidgets('on: brings back the last split of this tab rather than the tab '
      'used before it', (tester) async {
    await pumpMenu(
      tester,
      last: SplitPair(pairId: 'old', firstTabId: 'b', secondTabId: 'a'),
    );

    await tester.tap(find.text('Split'));
    await tester.pumpAndSettle();

    // 'c' was used more recently, but 'b' was beside 'a' last, on the left.
    expect(controller.calls, ['pair:b,a as old']);
    expect(tabs.selected, isEmpty);
  });

  testWidgets('on: a last partner that closed gives way to the tab used '
      'before', (tester) async {
    await pumpMenu(
      tester,
      last: SplitPair(pairId: 'old', firstTabId: 'a', secondTabId: 'gone'),
    );

    await tester.tap(find.text('Split'));
    await tester.pumpAndSettle();

    expect(controller.calls, ['pair:a,c']);
  });

  testWidgets('off: ends the split', (tester) async {
    await pumpMenu(
      tester,
      pair: SplitPair(pairId: 'p', firstTabId: 'a', secondTabId: 'b'),
    );
    expect(toggleActive(tester), isTrue);

    await tester.tap(find.text('Split'));
    await tester.pumpAndSettle();

    expect(controller.calls, ['end']);
    expect(toggleActive(tester), isFalse);
  });

  testWidgets('with only one page shown, it shows both again instead of '
      'ending the split', (tester) async {
    await pumpMenu(
      tester,
      pair: SplitPair(
        pairId: 'p',
        firstTabId: 'a',
        secondTabId: 'b',
        focusedOnly: true,
      ),
    );
    expect(find.text('Split'), findsNothing);
    expect(toggleActive(tester, label: 'Show both'), isFalse);

    await tester.tap(find.text('Show both'));
    await tester.pumpAndSettle();

    expect(controller.calls, ['focusedOnly:false']);
    expect(container.read(splitViewControllerProvider)!.focusedOnly, isFalse);
    // Back to an ordinary split toggle, which a second tap would turn off.
    expect(toggleActive(tester), isTrue);
  });

  testWidgets('with only one page shown, a long press opens the controls', (
    tester,
  ) async {
    await pumpMenu(
      tester,
      pair: SplitPair(
        pairId: 'p',
        firstTabId: 'a',
        secondTabId: 'b',
        focusedOnly: true,
      ),
    );

    await tester.longPress(find.text('Show both'));
    await tester.pumpAndSettle();

    expect(
      container.read(bottomSheetControllerProvider),
      isA<SplitViewSheet>(),
    );
    expect(controller.calls, isEmpty);
  });

  testWidgets('a long press in a split opens its controls', (tester) async {
    await pumpMenu(
      tester,
      pair: SplitPair(pairId: 'p', firstTabId: 'a', secondTabId: 'b'),
    );

    await tester.longPress(find.text('Split'));
    await tester.pumpAndSettle();

    expect(find.text('Split'), findsNothing);
    expect(
      container.read(bottomSheetControllerProvider),
      isA<SplitViewSheet>(),
    );
  });

  testWidgets('a long press without a split picks the page in the tab tray', (
    tester,
  ) async {
    await pumpMenu(tester);

    await tester.longPress(find.text('Split'));
    await tester.pumpAndSettle();

    expect(find.text('Split'), findsNothing);
    final sheet = container.read(bottomSheetControllerProvider);
    expect(sheet, isA<TabPickerSheet>());
    final request = (sheet! as TabPickerSheet).request;
    expect(request.title, 'Show beside');
    expect(request.excludedTabIds, {'a'});
    expect(controller.calls, isEmpty);
  });

  testWidgets('with no tab to show beside it, on opens the new-tab page as a '
      'picker', (tester) async {
    await pumpMenu(tester, openTabs: [_tab('a'), _tab('p', TabMode.private)]);

    await tester.tap(find.text('Split'));
    await tester.pumpAndSettle();

    expect(controller.calls, isEmpty);
    expect(find.text('search beside a'), findsOneWidget);
  });
}
