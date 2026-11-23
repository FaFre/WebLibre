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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/router.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/browser_actions/domain/services/browser_action_dispatcher.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_detail_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/domain/entities/find_in_page_state.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Keeps the find bar's state to itself: the real controller follows the
/// engine's tab states, which this test has no engine for.
class _FakeFindInPage extends FindInPageController {
  @override
  FindInPageState build(String tabId) => FindInPageState.hidden();
}

/// No engine behind it: only the actions that reach for the tab list get here.
class _FakeTabRepository extends TabRepository {
  @override
  void build() {}
}

void main() {
  group('needsLivePage', () {
    test('lists the actions that work on the content of the page', () {
      for (final action in const [
        BrowserAction.scrollTop,
        BrowserAction.scrollBottom,
        BrowserAction.pageUp,
        BrowserAction.pageDown,
        BrowserAction.findInPage,
        BrowserAction.findNext,
        BrowserAction.findPrevious,
        BrowserAction.toggleReaderMode,
        BrowserAction.translatePage,
        BrowserAction.printPage,
        BrowserAction.addToHomeScreen,
        BrowserAction.subscribeToPageFeed,
      ]) {
        expect(
          BrowserActionDispatcher.needsLivePage(action),
          isTrue,
          reason: action.name,
        );
      }
    });

    test(
      'leaves navigations, which wake the tab, and address-only actions',
      () {
        for (final action in const [
          BrowserAction.back,
          BrowserAction.forward,
          BrowserAction.reload,
          BrowserAction.hardReload,
          BrowserAction.toggleDesktopMode,
          BrowserAction.copyLink,
          BrowserAction.sharePage,
          BrowserAction.toggleBookmark,
          BrowserAction.quickToggleBookmark,
          BrowserAction.openInPrivateTab,
          BrowserAction.duplicateTab,
          BrowserAction.closeTab,
          BrowserAction.togglePinTab,
          BrowserAction.toggleLockTab,
          BrowserAction.increaseFontSize,
          BrowserAction.newTab,
        ]) {
          expect(
            BrowserActionDispatcher.needsLivePage(action),
            isFalse,
            reason: action.name,
          );
        }
      },
    );

    test('only names actions that work on a page at all', () {
      for (final action in BrowserAction.values) {
        if (BrowserActionDispatcher.needsLivePage(action)) {
          expect(
            BrowserActionDispatcher.requiresTab(action),
            isTrue,
            reason: '${action.name} works on the page, so it needs a tab',
          );
        }
      }
    });
  });

  group('running an action on an asleep tab', () {
    late ProviderContainer container;

    Future<void> pump(WidgetTester tester, {required bool asleep}) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: SizedBox()),
          ),
        ],
      );
      addTearDown(router.dispose);

      container = ProviderContainer(
        overrides: [
          routerProvider.overrideWith((ref) => Future.value(router)),
          generalSettingsWithDefaultsProvider.overrideWith(
            (ref) => GeneralSettings.withDefaults(),
          ),
          gestureSettingsWithDefaultsProvider.overrideWith(
            (ref) => GestureSettings.withDefaults(enabled: false),
          ),
          splitPairShownProvider.overrideWithValue(null),
          // No tab state: the actions that read the tab's address do nothing.
          tabStateProvider.overrideWith((ref, tabId) => null),
          findInPageControllerProvider.overrideWith2((_) => _FakeFindInPage()),
          tabRepositoryProvider.overrideWith(_FakeTabRepository.new),
          isTabAsleepProvider('tab').overrideWithValue(asleep),
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
    }

    Future<void> run(WidgetTester tester, BrowserAction action) async {
      await tester.runAsync(
        () => container
            .read(browserActionDispatcherProvider.notifier)
            .run(action, tabId: 'tab'),
      );
      await tester.pumpAndSettle();
    }

    bool findBarShown() =>
        container.read(findInPageControllerProvider('tab')).visible;

    testWidgets('says the tab is asleep and does not run', (tester) async {
      await pump(tester, asleep: true);

      await run(tester, BrowserAction.findInPage);

      expect(find.text('This tab is asleep. Wake it first.'), findsOneWidget);
      expect(findBarShown(), isFalse);
    });

    testWidgets('says it for every page action, not only the first', (
      tester,
    ) async {
      await pump(tester, asleep: true);

      for (final action in [
        BrowserAction.scrollTop,
        BrowserAction.pageDown,
        BrowserAction.findNext,
        BrowserAction.printPage,
      ]) {
        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold)),
        ).clearSnackBars();
        await tester.pumpAndSettle();

        await run(tester, action);

        expect(
          find.text('This tab is asleep. Wake it first.'),
          findsOneWidget,
          reason: action.name,
        );
      }
    });

    testWidgets('runs the same action on a tab that is awake', (tester) async {
      await pump(tester, asleep: false);

      await run(tester, BrowserAction.findInPage);

      expect(find.text('This tab is asleep. Wake it first.'), findsNothing);
      expect(findBarShown(), isTrue);
    });

    testWidgets('leaves an action that needs no page alone', (tester) async {
      await pump(tester, asleep: true);

      await run(tester, BrowserAction.toggleBookmark);

      expect(find.text('This tab is asleep. Wake it first.'), findsNothing);
    });
  });
}
