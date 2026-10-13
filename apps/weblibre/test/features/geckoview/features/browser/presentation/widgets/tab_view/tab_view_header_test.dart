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
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_view_filter_options.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_view_header.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// [TabViewFilterController] without persistence.
class _TestTabViewFilterController extends TabViewFilterController {
  @override
  TabViewFilterOptions build() => TabViewFilterOptions.withDefaults();
}

/// [SelectedContainer] without persistence: no container selected.
class _TestSelectedContainer extends SelectedContainer {
  @override
  String? build() => null;
}

const _channel = MethodChannel('eu.weblibre.gecko/navigation_bar');

const _windowHeight = 800.0;
const _statusBar = 24.0;
const _navigationBar = 48.0;

/// Pumps the tray's frame the way its sheet hands it the system bars: the
/// header over a list of tabs, the action bar below, in a window with a
/// status bar and a navigation bar.
///
/// While [tabsShown] is false, the list makes way for a scroll view without
/// tabs, as the synced tabs' spinner does.
Future<void> _pumpTray(
  WidgetTester tester, {
  required ScrollController scrollController,
  required bool actionsAtBottom,
  bool navigationBarOutsideFlutter = false,
  ValueNotifier<bool>? tabsShown,
}) async {
  final scrolledUnder = ValueNotifier(false);
  addTearDown(scrolledUnder.dispose);
  final shown = tabsShown ?? ValueNotifier(true);
  if (tabsShown == null) addTearDown(shown.dispose);

  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(400, _windowHeight);
  const insets = FakeViewPadding(top: _statusBar, bottom: _navigationBar);
  tester.view.padding = insets;
  tester.view.viewPadding = insets;
  addTearDown(tester.view.reset);

  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    _channel,
    (_) async => {
      'outsideFlutter': navigationBarOutsideFlutter,
      'buttonsAtBottom': true,
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _channel,
      null,
    ),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        generalSettingsWithDefaultsProvider.overrideWith(
          (ref) => GeneralSettings.withDefaults().copyWith(
            tabTrayActionsAtBottom: actionsAtBottom,
            // The container chips and the AI suggestions button want a
            // database.
            showContainerUi: false,
            enableLocalAiFeatures: false,
          ),
        ),
        effectiveTabsTrayScopeProvider.overrideWith(
          (ref) => TabsTrayScope.local,
        ),
        canManualTabReorderProvider.overrideWith((ref) => true),
        tabViewFilterControllerProvider.overrideWith(
          _TestTabViewFilterController.new,
        ),
        selectedContainerProvider.overrideWith(_TestSelectedContainer.new),
        selectedContainerDataProvider.overrideWith((ref) => Stream.value(null)),
        // The tab-type filter bar reads which kinds of tab are open, which
        // would wait for the engine.
        tabSortKeysProvider.overrideWith((ref) => EquatableValue(const {})),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Material(
          child: Column(
            children: [
              TabViewHeader(
                onClose: () {},
                tabsViewMode: TabsViewMode.list,
                scrolledUnder: scrolledUnder,
              ),
              Expanded(
                child: TabViewScrolledUnderListener(
                  scrolledUnder: scrolledUnder,
                  child: Builder(
                    builder: (context) => MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      removeBottom: true,
                      child: ValueListenableBuilder(
                        valueListenable: shown,
                        builder: (context, tabsShown, _) => tabsShown
                            ? ListView.builder(
                                controller: scrollController,
                                itemCount: 50,
                                itemBuilder: (context, index) => SizedBox(
                                  height: 64,
                                  child: Text('tab $index'),
                                ),
                              )
                            : CustomScrollView(
                                controller: scrollController,
                                slivers: const [
                                  SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const TabViewActionBar(tabsViewMode: TabsViewMode.list),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

ColorScheme _colorScheme(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(TabViewHeader))).colorScheme;

Finder _within<T>(Finder of) =>
    find.descendant(of: of, matching: find.byType(T)).first;

/// The header's color, null for the canvas's.
Color? _headerColor(WidgetTester tester) => tester
    .widget<Material>(_within<Material>(find.byType(TabViewHeader)))
    .color;

/// The action row, wherever it is.
Rect _actionRow(WidgetTester tester) => tester.getRect(
  find
      .ancestor(of: find.byType(IconButton).first, matching: find.byType(Row))
      .first,
);

void main() {
  testWidgets('the action bar runs behind the navigation bar, its row above', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    await _pumpTray(
      tester,
      scrollController: scrollController,
      actionsAtBottom: true,
    );

    final bar = find.byType(TabViewActionBar);
    expect(tester.getRect(bar).bottom, _windowHeight);
    expect(
      tester.getSize(bar).height,
      TabViewActionBar.height + _navigationBar,
    );
    expect(_actionRow(tester).bottom, _windowHeight - _navigationBar);
    // Set apart by its color, not a divider.
    expect(
      tester.widget<Material>(_within<Material>(bar)).color,
      _colorScheme(tester).surfaceContainer,
    );
    expect(find.byType(Divider), findsNothing);
  });

  testWidgets('the action bar keeps its row above the keyboard', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    await _pumpTray(
      tester,
      scrollController: scrollController,
      actionsAtBottom: true,
    );

    // As the platform reports a keyboard over the navigation bar: in the view
    // insets, and no longer in the bottom padding.
    const keyboard = 300.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: keyboard);
    tester.view.padding = const FakeViewPadding(top: _statusBar);
    await tester.pump();

    final bar = find.byType(TabViewActionBar);
    expect(tester.getRect(bar).bottom, _windowHeight);
    expect(_actionRow(tester).bottom, _windowHeight - keyboard);
  });

  testWidgets('the action bar colors a navigation bar outside Flutter', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    await _pumpTray(
      tester,
      scrollController: scrollController,
      actionsAtBottom: true,
      navigationBarOutsideFlutter: true,
    );

    final style = tester
        .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
          _within<AnnotatedRegion<SystemUiOverlayStyle>>(
            find.byType(TabViewActionBar),
          ),
        )
        .value;
    expect(
      style.systemNavigationBarColor,
      _colorScheme(tester).surfaceContainer,
    );
  });

  testWidgets('with the actions in the header, the bar only keeps clear of '
      'the navigation bar', (tester) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    await _pumpTray(
      tester,
      scrollController: scrollController,
      actionsAtBottom: false,
    );

    expect(
      tester.getSize(find.byType(TabViewActionBar)).height,
      _navigationBar,
    );
    expect(
      find.descendant(
        of: find.byType(TabViewActionBar),
        matching: find.byType(IconButton),
      ),
      findsNothing,
    );
    // Nor a divider under the row in the header.
    expect(find.byType(Divider), findsNothing);
  });

  testWidgets('the header runs behind the status bar, its content below', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    await _pumpTray(
      tester,
      scrollController: scrollController,
      actionsAtBottom: false,
    );

    expect(tester.getRect(find.byType(TabViewHeader)).top, 0);
    expect(_actionRow(tester).top, _statusBar + 8);
  });

  testWidgets('the header takes the container color while tabs scroll under', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    await _pumpTray(
      tester,
      scrollController: scrollController,
      actionsAtBottom: true,
    );
    expect(_headerColor(tester), isNull);

    scrollController.jumpTo(100);
    await tester.pumpAndSettle();
    expect(_headerColor(tester), _colorScheme(tester).surfaceContainer);

    scrollController.jumpTo(0);
    await tester.pumpAndSettle();
    expect(_headerColor(tester), isNull);
  });

  testWidgets('the header drops the container color when the tabs make way '
      'for another scroll view', (tester) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    final tabsShown = ValueNotifier(true);
    addTearDown(tabsShown.dispose);
    await _pumpTray(
      tester,
      scrollController: scrollController,
      actionsAtBottom: true,
      tabsShown: tabsShown,
    );

    scrollController.jumpTo(100);
    await tester.pumpAndSettle();
    expect(_headerColor(tester), _colorScheme(tester).surfaceContainer);

    // A scroll controller says nothing when its scroll view is replaced.
    tabsShown.value = false;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(_headerColor(tester), isNull);
  });
}
