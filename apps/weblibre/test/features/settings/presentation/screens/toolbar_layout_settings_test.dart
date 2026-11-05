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
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/experimental/persist.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/core/providers/window_size_class.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_toolbar.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_visibility.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/pending_settings_highlight.dart';
import 'package:weblibre/features/settings/presentation/screens/contextual_toolbar_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/menu_layout_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/toolbar_layout_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/layout_part.dart';
import 'package:weblibre/features/settings/presentation/widgets/layout_part_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/reset_to_defaults_menu.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_preview.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// The ⋮ of an inline editor, which holds "Reset to Defaults".
final _resetMenu = find.descendant(
  of: find.byType(LayoutPartSettings),
  matching: find.byType(ResetToDefaultsMenu),
);

Future<List<String>> _pumpScreen(
  WidgetTester tester, {
  required Size size,
  GeneralSettings? settings,
  String? pendingHighlight,
  List<ToolbarButtonConfig>? contextualConfigs,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final value = settings ?? GeneralSettings.withDefaults();
  final errors = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) => errors.add(details.exceptionAsString());
  addTearDown(() => FlutterError.onError = previous);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // No onboarding owed: no draft, the displayed layer is the live one.
        completedOnboardingRevisionProvider.overrideWithValue(
          const AsyncData(OnboardingRepository.targetRevision),
        ),
        storedGeneralSettingsProvider.overrideWith((ref) => value),
        generalSettingsWithDefaultsProvider.overrideWith(
          (ref) => value.effective(),
        ),
        windowSizeClassControllerProvider.overrideWith(
          () => _FakeWindowSizeClass(WindowSizeClass.fromSize(size)),
        ),
        // The profile's buttons, which the live, edit and displayed layers
        // follow.
        profileToolbarButtonConfigsProvider.overrideWith(
          (ref, location) =>
              location == ToolbarConfigLocation.contextual &&
                  contextualConfigs != null
              ? EquatableValue(contextualConfigs)
              : defaultToolbarButtonConfigsFor(location),
        ),
        pendingSettingsHighlightProvider.overrideWith(
          () => _FakePendingHighlight(pendingHighlight),
        ),
        // The menu's arrangement persists through it.
        riverpodDatabaseStorageProvider.overrideWith(
          (ref) => Storage<String, String>.inMemory(),
        ),
        // Asks the proxy routing of the open tab, which needs a profile.
        menuConnectionSectionShownProvider.overrideWith((ref, _) => false),
        // What a hidden feature's rows mark "Not applied while hidden",
        // which the profile's stored settings say.
        suspendedSettingsProvider.overrideWith(_NothingSuspended.new),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ToolbarLayoutSettingsScreen(),
      ),
    ),
  );
  await tester.pump();

  FlutterError.onError = previous;
  return errors;
}

void main() {
  Finder region(LayoutPart part) => find.byWidgetPredicate(
    (widget) => widget is PreviewPartRegion && widget.part == part,
  );

  for (final (name, size) in [
    ('phone', const Size(392, 850)),
    ('landscape phone', const Size(850, 392)),
    ('small landscape phone', const Size(740, 360)),
    ('tablet', const Size(1280, 800)),
  ]) {
    for (final position in TabBarPositionSetting.values) {
      testWidgets('$name, ${position.name}: lays out without overflowing', (
        tester,
      ) async {
        final errors = await _pumpScreen(
          tester,
          size: size,
          settings: GeneralSettings.withDefaults(tabBarPosition: position),
        );

        expect(errors, isEmpty);
        expect(find.byType(LayoutPreview), findsOneWidget);
      });
    }
  }

  testWidgets('a phone switches between the preview and the settings', (
    tester,
  ) async {
    await _pumpScreen(tester, size: const Size(392, 850));

    expect(find.byType(TabBar), findsOneWidget);
    expect(find.byType(LayoutPreview), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Tab Bar Position'), findsWidgets);
  });

  testWidgets('a short window shows both side by side too', (tester) async {
    // A phone held sideways, below the expanded width: a sheet under the
    // preview would leave neither room.
    final errors = await _pumpScreen(tester, size: const Size(740, 360));

    expect(errors, isEmpty);
    expect(find.byType(TabBar), findsNothing);
    expect(find.byType(LayoutPreview), findsOneWidget);
    expect(find.text('Tab Bar Position'), findsWidgets);

    await tester.tapAt(tester.getCenter(region(LayoutPart.tabBar).first));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(LayoutPartSettings),
        matching: find.text('Tab Bar Position'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a large window shows both side by side', (tester) async {
    await _pumpScreen(tester, size: const Size(1280, 800));

    expect(find.byType(TabBar), findsNothing);
    expect(find.byType(LayoutPreview), findsOneWidget);
    expect(find.text('Tab Bar Position'), findsWidgets);
  });

  testWidgets('opened from the settings search, a phone starts on the list', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      size: const Size(392, 850),
      pendingHighlight: 'Tab Bar Position',
    );
    await tester.pumpAndSettle();

    final controller = DefaultTabController.of(
      tester.element(find.byType(TabBarView)),
    );
    expect(controller.index, 1);
  });

  group('editor', () {
    testWidgets('a tap on the tab bar opens its settings in a sheet, and a '
        'second one inside it goes deeper', (tester) async {
      await _pumpScreen(
        tester,
        size: const Size(392, 850),
        settings: GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.bottom,
        ),
      );

      await tester.tapAt(tester.getCenter(region(LayoutPart.tabChip).first));
      await tester.pumpAndSettle();

      expect(find.byType(LayoutPartSettings), findsOneWidget);
      expect(
        tester.widget<LayoutPartSettings>(find.byType(LayoutPartSettings)).part,
        LayoutPart.tabBar,
      );
      expect(find.text('Tab Bar Position'), findsOneWidget);

      await tester.tapAt(tester.getCenter(region(LayoutPart.tabChip).first));
      await tester.pumpAndSettle();
      expect(
        tester.widget<LayoutPartSettings>(find.byType(LayoutPartSettings)).part,
        LayoutPart.quickTabSwitcher,
      );

      await tester.tapAt(tester.getCenter(region(LayoutPart.tabChip).first));
      await tester.pumpAndSettle();
      expect(
        tester.widget<LayoutPartSettings>(find.byType(LayoutPartSettings)).part,
        LayoutPart.tabChip,
      );
      expect(find.text('Show Titles in Quick Tab Switcher'), findsOneWidget);

      // The path leads back out.
      await tester.tap(
        find.descendant(
          of: find.byType(LayoutPartHeader),
          matching: find.widgetWithText(TextButton, 'Tab Bar'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<LayoutPartSettings>(find.byType(LayoutPartSettings)).part,
        LayoutPart.tabBar,
      );

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(LayoutPartSettings), findsNothing);
    });

    testWidgets('a large window opens a part in the pane, and All settings '
        'goes back to the list', (tester) async {
      await _pumpScreen(
        tester,
        size: const Size(1280, 800),
        settings: GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.left,
        ),
      );

      await tester.tapAt(
        tester.getCenter(region(LayoutPart.contextualToolbar).first),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LayoutPartSettings), findsOneWidget);

      await tester.tap(find.text('All settings'));
      await tester.pumpAndSettle();
      expect(find.byType(LayoutPartSettings), findsNothing);
      expect(find.text('Tab Bar Position'), findsWidgets);
    });

    testWidgets('in Try, scrolling the page hides the toolbar and says which '
        'setting did it', (tester) async {
      await _pumpScreen(
        tester,
        size: const Size(392, 850),
        settings: GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.bottom,
          autoHideTabBar: true,
        ),
      );

      await tester.tap(find.byTooltip('Try'));
      await tester.pumpAndSettle();

      await tester.drag(
        find.descendant(
          of: find.byType(PreviewWindow),
          // The page, not the switcher's button row.
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SingleChildScrollView &&
                widget.scrollDirection == Axis.vertical,
          ),
        ),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();

      expect(region(LayoutPart.tabBar), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);

      await tester.tap(find.text('Adjust'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<LayoutPartSettings>(find.byType(LayoutPartSettings)).part,
        LayoutPart.tabBar,
      );
    });

    testWidgets('in Select, the buttons in the preview do not take the tap', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        size: const Size(392, 850),
        settings: GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.bottom,
          tabBarShowContextualBar: false,
        ),
      );

      await tester.tapAt(tester.getCenter(region(LayoutPart.menu).first));
      await tester.pumpAndSettle();

      expect(
        tester.widget<LayoutPartSettings>(find.byType(LayoutPartSettings)).part,
        LayoutPart.tabBar,
      );
    });

    for (final size in [const Size(392, 850), const Size(360, 640)]) {
      testWidgets('at $size the sheet rests at three heights, the preview '
          'keeping the selected part', (tester) async {
        final errors = await _pumpScreen(
          tester,
          size: size,
          settings: GeneralSettings.withDefaults(
            tabBarPosition: TabBarPositionSetting.bottom,
          ),
        );
        await tester.tapAt(tester.getCenter(region(LayoutPart.tabBar).first));
        await tester.pumpAndSettle();

        final overflows = <String>[];
        final previous = FlutterError.onError;
        FlutterError.onError = (d) => overflows.add(d.exceptionAsString());
        addTearDown(() => FlutterError.onError = previous);

        double sheetTop() =>
            tester.getTopLeft(find.byType(LayoutPartHeader)).dy;
        // The handle, above the header.
        Offset handle() =>
            tester.getTopLeft(find.byType(LayoutPartHeader)) +
            const Offset(150, -12);
        void expectPartAboveSheet() {
          final part = tester.getRect(region(LayoutPart.tabBar).first);
          expect(part.height, greaterThan(0));
          expect(part.bottom, lessThanOrEqualTo(sheetTop()));
        }

        final half = sheetTop();
        expectPartAboveSheet();

        // A tap on the handle pulls it all the way up: the preview comes
        // down to the bar holding the part, without its controls.
        await tester.tapAt(handle());
        await tester.pumpAndSettle();
        final full = sheetTop();
        expect(full, lessThan(half));
        expectPartAboveSheet();
        expect(find.byTooltip('Try'), findsNothing);

        // Dragged down by its header, past half, it rests at its lowest,
        // and the controls come back.
        await tester.drag(find.byType(LayoutPartHeader), const Offset(0, 600));
        await tester.pumpAndSettle();
        final peek = sheetTop();
        expect(peek, greaterThan(half));
        expect(find.byTooltip('Try'), findsOneWidget);
        expectPartAboveSheet();

        // Scrolling the settings up pulls the sheet up before they scroll,
        // and it follows the finger all the way, frame after frame, rather
        // than settle while still held.
        final gesture = await tester.startGesture(
          tester.getCenter(
            find
                .descendant(
                  of: find.byType(LayoutPartSettings),
                  matching: find.byType(Scrollable),
                )
                .first,
          ),
        );
        final steps = <double>[];
        // Far enough that letting go settles it at the next stop up.
        for (var i = 0; i < 8; i++) {
          final before = sheetTop();
          await gesture.moveBy(const Offset(0, -20));
          await tester.pump(const Duration(milliseconds: 16));
          await tester.pump(const Duration(milliseconds: 16));
          steps.add(before - sheetTop());
        }
        await gesture.up();
        await tester.pumpAndSettle();
        final pulledUp = sheetTop();

        // Closed and opened again, it keeps the height it was left at.
        final left = sheetTop();
        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();
        await tester.tapAt(tester.getCenter(region(LayoutPart.tabBar).first));
        await tester.pumpAndSettle();
        expect(sheetTop(), moreOrLessEquals(left, epsilon: 1));
        FlutterError.onError = previous;

        expect(errors, isEmpty);
        expect(overflows, isEmpty);
        // The first move only takes the drag from the tap; every one after
        // it moves the sheet with the finger.
        expect(steps.skip(1), everyElement(moreOrLessEquals(20, epsilon: 2.5)));
        expect(pulledUp, lessThan(peek));
      });
    }

    test('the sheet keeps three distinct stops on a small phone', () {
      // A 640dp phone with its status, app and tab bars and the system
      // navigation: what the old sheet capped at one height.
      final stops = PartSheetStops.resolve(available: 464, previewHeight: 116);

      expect(stops.peek * 464, PartSheetStops.peekHeight);
      expect(stops.half, 0.5);
      expect(stops.full * 464, moreOrLessEquals(348));
      expect(stops.next(stops.peek), stops.half);
      expect(stops.next(stops.half!), stops.full);
      expect(stops.next(stops.full), stops.half);
      // Let go between two stops: the nearest; flung: the next one along.
      expect(stops.settle(0.45, velocity: 0), stops.half);
      expect(stops.settle(0.45, velocity: -1000), stops.half);
      expect(stops.settle(0.55, velocity: -1000), stops.full);
      expect(stops.settle(0.55, velocity: 1000), stops.half);
    });

    test('a body too short for the bars keeps the sheet usable', () {
      // 568×320: 216dp under the app bar and the tabs, the bars needing 166.
      final stops = PartSheetStops.resolve(available: 216, previewHeight: 166);

      expect(stops.full * 216, PartSheetStops.minSheetHeight);
      expect(stops.peek, stops.full);
      expect(216 - stops.full * 216, PartSheetStops.minPreviewHeight);
    });

    testWidgets('a short, narrow window keeps the sheet usable', (
      tester,
    ) async {
      final errors = await _pumpScreen(
        tester,
        size: const Size(568, 320),
        settings: GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.bottom,
          tabBarShowContextualBar: true,
        ),
      );
      expect(find.byType(TabBar), findsOneWidget);

      final overflows = <String>[];
      final previous = FlutterError.onError;
      FlutterError.onError = (d) => overflows.add(d.exceptionAsString());
      addTearDown(() => FlutterError.onError = previous);
      late final double settingsHeight;
      late final Rect preview;
      try {
        // The contextual toolbar, whose buttons open the sheet all the way.
        // Nothing open yet, the controls and the window scroll together.
        final toolbar = find.descendant(
          of: find.byType(ContextualToolbar),
          matching: region(LayoutPart.tabView),
        );
        await tester.ensureVisible(toolbar);
        await tester.pumpAndSettle();
        for (var i = 0; i < 2; i++) {
          await tester.tapAt(tester.getCenter(toolbar));
          await tester.pumpAndSettle();
        }
        settingsHeight = tester.getSize(find.byType(LayoutPartSettings)).height;
        preview = tester.getRect(find.byType(LayoutPreview));
      } finally {
        FlutterError.onError = previous;
      }

      expect(errors, isEmpty);
      expect(overflows, isEmpty);
      expect(
        tester.widget<LayoutPartSettings>(find.byType(LayoutPartSettings)).part,
        LayoutPart.contextualToolbar,
      );
      // A row of settings below the header, and the preview scaled down
      // above it rather than gone.
      expect(settingsHeight, greaterThanOrEqualTo(48));
      expect(preview.height, greaterThan(0));
      expect(
        preview.bottom,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(LayoutPartHeader)).dy),
      );
    });

    test('a short body drops the middle stop rather than crowd it', () {
      final stops = PartSheetStops.resolve(available: 300, previewHeight: 100);

      expect(stops.half, isNull);
      expect(stops.all, [stops.peek, stops.full]);
      expect(stops.peek, lessThan(stops.full));
    });

    testWidgets('the tab count and the menu are parts in the contextual '
        'toolbar too', (tester) async {
      await _pumpScreen(
        tester,
        size: const Size(392, 850),
        settings: GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.bottom,
          tabBarShowContextualBar: true,
        ),
      );

      // With the contextual toolbar on, both live there and not in the
      // address bar row.
      final tabCount = find.descendant(
        of: find.byType(ContextualToolbar),
        matching: region(LayoutPart.tabView),
      );
      expect(tabCount, findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ContextualToolbar),
          matching: region(LayoutPart.menu),
        ),
        findsOneWidget,
      );

      for (var i = 0; i < 3; i++) {
        await tester.tapAt(tester.getCenter(tabCount));
        await tester.pumpAndSettle();
      }
      expect(
        tester.widget<LayoutPartSettings>(find.byType(LayoutPartSettings)).part,
        LayoutPart.tabView,
      );

      // The contextual toolbar's buttons pulled the sheet all the way up,
      // over the preview's controls.
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Try'));
      await tester.pumpAndSettle();
      await tester.tapAt(tester.getCenter(tabCount));
      await tester.pumpAndSettle();
      expect(find.text('This opens the tab view'), findsOneWidget);
    });

    testWidgets('the contextual toolbar edits its buttons in place', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        size: const Size(392, 850),
        settings: GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.bottom,
          tabBarShowContextualBar: true,
        ),
      );

      final toolbar = find.descendant(
        of: find.byType(ContextualToolbar),
        matching: region(LayoutPart.tabView),
      );
      for (var i = 0; i < 2; i++) {
        await tester.tapAt(tester.getCenter(toolbar));
        await tester.pumpAndSettle();
      }
      expect(
        tester.widget<LayoutPartSettings>(find.byType(LayoutPartSettings)).part,
        LayoutPart.contextualToolbar,
      );
      // Opened with the room its buttons need: the preview is down to its
      // bars, the selected toolbar still in sight.
      expect(find.byTooltip('Try'), findsNothing);
      expect(
        tester.getRect(region(LayoutPart.contextualToolbar).first).bottom,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(LayoutPartHeader)).dy),
      );
      // The buttons, edited right in the sheet below its settings, in place
      // of the row that opens their own screen.
      expect(
        find.widgetWithText(ListTile, 'Customize Toolbar Buttons'),
        findsNothing,
      );
      await tester.drag(
        find
            .descendant(
              of: find.byType(LayoutPartSettings),
              matching: find.byType(Scrollable),
            )
            .first,
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(LayoutPartSettings),
          matching: find.byType(ToolbarButtonConfigEditor),
        ),
        findsOneWidget,
      );
      expect(_resetMenu, findsOneWidget);
    });

    for (final (name, size) in [
      ('phone', const Size(392, 850)),
      ('tablet', const Size(1280, 800)),
    ]) {
      testWidgets('$name: Customize Toolbar Buttons opens them beside the '
          'preview', (tester) async {
        await _pumpScreen(
          tester,
          size: size,
          settings: GeneralSettings.withDefaults(
            tabBarPosition: TabBarPositionSetting.bottom,
            tabBarShowContextualBar: true,
          ),
        );
        if (size.width < 840) {
          await tester.tap(find.text('Settings'));
          await tester.pumpAndSettle();
        }

        final row = find.text('Customize Toolbar Buttons');
        await tester.ensureVisible(row);
        await tester.pumpAndSettle();
        await tester.tap(row);
        await tester.pumpAndSettle();

        expect(find.byType(ContextualToolbarSettingsScreen), findsNothing);
        expect(find.byType(LayoutPreview), findsOneWidget);
        expect(
          tester
              .widget<LayoutPartSettings>(find.byType(LayoutPartSettings))
              .part,
          LayoutPart.contextualToolbar,
        );
        // Scrolled to the buttons, which can be switched right away.
        expect(
          find
              .descendant(
                of: find.byType(ToolbarButtonConfigEditor),
                matching: find.byType(Switch),
              )
              .hitTestable(),
          findsWidgets,
        );
      });
    }

    testWidgets('the menu opens its arrangement', (tester) async {
      await _pumpScreen(
        tester,
        size: const Size(392, 850),
        settings: GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.bottom,
          tabBarShowContextualBar: false,
        ),
      );

      for (var i = 0; i < 2; i++) {
        await tester.tapAt(tester.getCenter(region(LayoutPart.menu).first));
        await tester.pumpAndSettle();
      }

      expect(
        tester.widget<LayoutPartSettings>(find.byType(LayoutPartSettings)).part,
        LayoutPart.menu,
      );
      expect(find.text('No settings available.'), findsNothing);
      // The arrangement itself, in place of the row that opens its screen.
      final editor = find.byType(MenuLayoutEditor);
      expect(editor, findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Customize Menu'), findsNothing);
      expect(_resetMenu, findsOneWidget);

      // Into a section and back, by the arrow and by the system back.
      final back = find.byTooltip('Back');
      final section = find
          .descendant(of: editor, matching: find.byIcon(Icons.chevron_right))
          .first;
      for (final leave in [
        () => tester.tap(back),
        () => tester.binding.handlePopRoute(),
      ]) {
        expect(back, findsNothing);
        await tester.tap(section);
        await tester.pumpAndSettle();
        expect(back, findsOneWidget);
        // Reset is for the whole menu only.
        expect(_resetMenu, findsNothing);

        await leave();
        await tester.pumpAndSettle();
        expect(find.byType(MenuLayoutEditor), findsOneWidget);
        expect(_resetMenu, findsOneWidget);
      }
    });

    for (final (name, size) in [
      ('phone', const Size(392, 850)),
      ('tablet', const Size(1280, 800)),
    ]) {
      testWidgets('$name: Customize Menu opens it beside the preview', (
        tester,
      ) async {
        await _pumpScreen(tester, size: size);
        if (size.width < 840) {
          await tester.tap(find.text('Settings'));
          await tester.pumpAndSettle();
        }

        final row = find.widgetWithText(ListTile, 'Customize Menu');
        await tester.ensureVisible(row);
        await tester.pumpAndSettle();
        await tester.tap(row);
        await tester.pumpAndSettle();

        expect(find.byType(LayoutPreview), findsOneWidget);
        expect(
          tester
              .widget<LayoutPartSettings>(find.byType(LayoutPartSettings))
              .part,
          LayoutPart.menu,
        );
        // Scrolled to the arrangement: its ⋮ is on screen.
        expect(find.byType(MenuLayoutEditor), findsOneWidget);
        expect(_resetMenu.hitTestable(), findsOneWidget);
      });
    }

    testWidgets('while menu customization is hidden, its row stays', (
      tester,
    ) async {
      final settings = GeneralSettings.withDefaults(
        tabBarPosition: TabBarPositionSetting.bottom,
        tabBarShowContextualBar: false,
        visibilitySwitches: {VisibilitySwitch.layoutAdvanced: false},
      );
      expect(
        settings.effective().isFeatureShown(FeatureId.layoutMenuCustomization),
        isFalse,
      );
      await _pumpScreen(tester, size: const Size(392, 850), settings: settings);

      for (var i = 0; i < 2; i++) {
        await tester.tapAt(tester.getCenter(region(LayoutPart.menu).first));
        await tester.pumpAndSettle();
      }

      // Grayed, asking to show the feature before it opens, as in the list.
      expect(find.byType(MenuLayoutEditor), findsNothing);
      expect(
        find.descendant(
          of: find.byType(LayoutPartSettings),
          matching: find.text('Customize Menu'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('in Try, the menu offers to adjust its arrangement', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        size: const Size(392, 850),
        settings: GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.bottom,
          tabBarShowContextualBar: false,
        ),
      );

      await tester.tap(find.byTooltip('Try'));
      await tester.pumpAndSettle();
      await tester.tapAt(tester.getCenter(region(LayoutPart.menu).first));
      await tester.pumpAndSettle();
      expect(find.text('This opens the menu'), findsOneWidget);

      await tester.tap(find.text('Adjust'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<LayoutPartSettings>(find.byType(LayoutPartSettings)).part,
        LayoutPart.menu,
      );
      expect(find.byType(MenuLayoutEditor), findsOneWidget);
    });

    testWidgets('Adjust after the toolbar hid goes to its distance', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        size: const Size(392, 850),
        settings: GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.bottom,
          autoHideTabBar: true,
        ),
      );

      await tester.tap(find.byTooltip('Try'));
      await tester.pumpAndSettle();
      await tester.drag(
        find.descendant(
          of: find.byType(PreviewWindow),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SingleChildScrollView &&
                widget.scrollDirection == Axis.vertical,
          ),
        ),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Toolbar hidden while scrolling'), findsOne);

      await tester.tap(find.text('Adjust'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<LayoutPartSettings>(find.byType(LayoutPartSettings)).part,
        LayoutPart.tabBar,
      );
      // Scrolled to and highlighted, far below where the Tab Bar's settings
      // start.
      expect(
        find
            .descendant(
              of: find.byType(LayoutPartSettings),
              matching: find.text('Auto Hide Distance'),
            )
            .hitTestable(),
        findsOneWidget,
      );
    });

    testWidgets('a Try message goes away by itself', (tester) async {
      await _pumpScreen(
        tester,
        size: const Size(392, 850),
        settings: GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.bottom,
          tabBarShowContextualBar: false,
        ),
      );

      await tester.tap(find.byTooltip('Try'));
      await tester.pumpAndSettle();
      await tester.tapAt(tester.getCenter(region(LayoutPart.menu).first));
      await tester.pumpAndSettle();
      expect(find.text('This opens the menu'), findsOneWidget);

      // An action keeps a bare SnackBar up until it is tapped. Still up
      // just before its 1.5 s, gone after.
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.text('This opens the menu'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text('This opens the menu'), findsNothing);
    });

    testWidgets('an auto-hiding side panel can be tried', (tester) async {
      await _pumpScreen(
        tester,
        size: const Size(392, 850),
        settings: GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.left,
          sideRailAutoHide: true,
        ),
      );
      Offset railOffset() => tester
          .widget<AnimatedSlide>(
            find.descendant(
              of: find.byType(PreviewWindow),
              matching: find.byType(AnimatedSlide),
            ),
          )
          .offset;

      // Select shows the panel beside the page, as touch does in the browser.
      expect(find.byType(AnimatedSlide), findsNothing);

      await tester.tap(find.byTooltip('Try'));
      await tester.pumpAndSettle();
      expect(railOffset(), Offset.zero);

      // A tap on the page stands in for the mouse resting there.
      final window = find.byType(PreviewWindow);
      await tester.tapAt(tester.getCenter(window));
      await tester.pumpAndSettle();
      expect(railOffset(), const Offset(-1, 0));
      expect(find.textContaining('Side panel hidden'), findsOneWidget);

      // At the edge it comes back.
      await tester.tapAt(
        tester.getRect(window).centerLeft + const Offset(4, 0),
      );
      await tester.pumpAndSettle();
      expect(railOffset(), Offset.zero);

      // A mouse resting on the page hides it, as in the browser.
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: tester.getCenter(window));
      await mouse.moveTo(tester.getCenter(window) + const Offset(10, 0));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(railOffset(), const Offset(-1, 0));
    });

    testWidgets('page buttons are available on the sample page', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        size: const Size(392, 850),
        settings: GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.bottom,
          tabBarShowContextualBar: true,
        ),
        contextualConfigs: [
          const ToolbarButtonConfig(
            buttonId: 'back',
            orderKey: 'a',
            isVisible: true,
          ),
          const ToolbarButtonConfig(
            buttonId: 'reload',
            orderKey: 'b',
            isVisible: true,
          ),
        ],
      );

      // A button that is unavailable is drawn faded.
      expect(
        find.descendant(
          of: find.byType(ContextualToolbar),
          matching: find.byWidgetPredicate(
            (widget) => widget is Opacity && widget.opacity < 1,
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('a toolbar hidden while trying comes back in another window', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        size: const Size(392, 850),
        settings: GeneralSettings.withDefaults(autoHideTabBar: true),
      );

      await tester.tap(find.byTooltip('Try'));
      await tester.pumpAndSettle();
      await tester.drag(
        find.descendant(
          of: find.byType(PreviewWindow),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SingleChildScrollView &&
                widget.scrollDirection == Axis.vertical,
          ),
        ),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();
      expect(region(LayoutPart.tabBar), findsNothing);

      // A large screen puts the automatic tab bar in a side rail, which never
      // hides with the page. On a phone the device menu shows its icon alone.
      await tester.tap(find.byTooltip('This window'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Large screen').last);
      await tester.pumpAndSettle();

      expect(region(LayoutPart.tabBar), findsOneWidget);
    });
  });
}

class _FakeWindowSizeClass extends WindowSizeClassController {
  _FakeWindowSizeClass(this.window);

  final WindowSizeClass window;

  @override
  WindowSizeClass build() => window;
}

class _NothingSuspended extends SuspendedSettings {
  @override
  Set<HiddenSetting> build() => const {};
}

class _FakePendingHighlight extends PendingSettingsHighlight {
  _FakePendingHighlight(this.initial);

  final String? initial;

  @override
  String? build() => initial;
}
