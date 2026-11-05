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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/settings/presentation/widgets/layout_part.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_preview.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

({Size size, WindowSizeClass window}) _window(Size size) =>
    (size: size, window: WindowSizeClass.fromSize(size));

Future<List<FlutterErrorDetails>> _pumpPreview(
  WidgetTester tester, {
  required GeneralSettings settings,
  required PreviewDevice device,
  PreviewSampleState state = PreviewSampleState.page,
  Size available = const Size(368, 640),
  ValueListenable<PreviewMode?>? mode,
}) async {
  final errors = <FlutterErrorDetails>[];
  final previous = FlutterError.onError;
  FlutterError.onError = errors.add;
  addTearDown(() => FlutterError.onError = previous);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // No onboarding owed: no draft, the displayed layer is the live one.
        completedOnboardingRevisionProvider.overrideWithValue(
          const AsyncData(OnboardingRepository.targetRevision),
        ),
        generalSettingsWithDefaultsProvider.overrideWith((ref) => settings),
        toolbarButtonConfigsProvider.overrideWith(
          (ref, location) =>
              Stream.value(defaultToolbarButtonConfigsFor(location).value),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox.fromSize(
              size: available,
              child: mode == null
                  ? LayoutPreview(device: device, state: state)
                  : ValueListenableBuilder(
                      valueListenable: mode,
                      builder: (context, mode, _) => LayoutPreview(
                        device: device,
                        state: state,
                        mode: mode,
                      ),
                    ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();

  FlutterError.onError = previous;
  return errors;
}

void main() {
  group('previewGeometry', () {
    const phone = Size(392, 850);

    test('a window that fits is drawn whole at its width scale', () {
      final geometry = previewGeometry(
        device: phone,
        available: const Size(392, 900),
        chromeExtent: 158,
        isRail: false,
      );

      expect(geometry.layoutSize, phone);
      expect(geometry.scale, 1.0);
    });

    test('never scales up', () {
      final geometry = previewGeometry(
        device: phone,
        available: const Size(2000, 2000),
        chromeExtent: 158,
        isRail: false,
      );

      expect(geometry.scale, 1.0);
    });

    test('shortens only the page between horizontal bars', () {
      final geometry = previewGeometry(
        device: phone,
        available: const Size(368, 300),
        chromeExtent: 158,
        isRail: false,
      );
      const scale = 368 / 392;

      expect(geometry.scale, closeTo(scale, 1e-9));
      expect(geometry.layoutSize.width, phone.width);
      expect(geometry.layoutSize.height, closeTo(300 / scale, 1e-9));
    });

    test('scales the bars too once the shortest page does not fit', () {
      final geometry = previewGeometry(
        device: phone,
        available: const Size(368, 120),
        chromeExtent: 158,
        isRail: false,
      );

      expect(geometry.layoutSize.height, 158 + kMinPreviewPageHeight);
      expect(
        geometry.layoutSize.height * geometry.scale,
        lessThanOrEqualTo(120 + 1e-9),
      );
    });

    test('scales a window with a side rail as a whole', () {
      const largeScreen = Size(1280, 800);
      final geometry = previewGeometry(
        device: largeScreen,
        available: const Size(848, 400),
        chromeExtent: 0,
        isRail: true,
      );

      expect(geometry.layoutSize, largeScreen);
      expect(geometry.scale, 400 / 800);
    });
  });

  group('previewStateBlocker', () {
    test('the home page can always be shown', () {
      for (final position in TabBarPositionSetting.values) {
        final layout = previewChromeLayout(
          GeneralSettings.withDefaults(tabBarPosition: position),
          window: _window(const Size(1280, 800)),
          state: PreviewSampleState.page,
        );
        expect(previewStateBlocker(PreviewSampleState.home, layout), isNull);
      }
    });

    test('collapsing needs a side panel in a large window', () {
      final settings = GeneralSettings.withDefaults(
        tabBarPosition: TabBarPositionSetting.left,
      );

      final phone = previewChromeLayout(
        settings,
        window: _window(const Size(392, 850)),
        state: PreviewSampleState.page,
      );
      expect(
        previewStateBlocker(PreviewSampleState.sidePanelCollapsed, phone),
        PreviewStateBlocker.needsSidePanel,
      );

      final largeScreen = previewChromeLayout(
        settings,
        window: _window(const Size(1280, 800)),
        state: PreviewSampleState.page,
      );
      expect(
        previewStateBlocker(PreviewSampleState.sidePanelCollapsed, largeScreen),
        isNull,
      );
    });

    test('a collapsed panel is drawn as the icon rail', () {
      final layout = previewChromeLayout(
        GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.left,
        ),
        window: _window(const Size(1280, 800)),
        state: PreviewSampleState.sidePanelCollapsed,
      );

      expect(layout.railWidth, BrowserTabBar.mediumRailWidth);
    });
  });

  group('LayoutPreview', () {
    // The probe that started the redesign, kept: every position on every
    // window size, with and without the contextual toolbar, draws without
    // overflowing anything.
    for (final device in [
      PreviewDevice.phone,
      PreviewDevice.phoneLandscape,
      PreviewDevice.largeScreen,
    ]) {
      for (final position in TabBarPositionSetting.values) {
        for (final contextual in [true, false]) {
          testWidgets(
            '${device.name}, ${position.name}, contextual: $contextual',
            (tester) async {
              final errors = await _pumpPreview(
                tester,
                device: device,
                settings: GeneralSettings.withDefaults(
                  tabBarPosition: position,
                  tabBarShowContextualBar: contextual,
                ),
              );

              expect(
                errors.map((e) => e.exceptionAsString()).toList(),
                isEmpty,
              );
              expect(find.byType(PreviewWindow), findsOneWidget);
            },
          );
        }
      }
    }

    testWidgets('draws every sample state without overflowing', (tester) async {
      for (final state in PreviewSampleState.values) {
        final errors = await _pumpPreview(
          tester,
          device: PreviewDevice.largeScreen,
          state: state,
          settings: GeneralSettings.withDefaults(
            tabBarPosition: TabBarPositionSetting.left,
          ),
        );

        expect(
          errors.map((e) => e.exceptionAsString()).toList(),
          isEmpty,
          reason: state.name,
        );
      }
    });

    testWidgets('home shows one search entry where auto picks the tab bar', (
      tester,
    ) async {
      // auto resolves to the tab bar's own address field under a bottom tab
      // bar, so the home surface's pill stands down, as in the browser.
      await _pumpPreview(
        tester,
        device: PreviewDevice.phone,
        state: PreviewSampleState.home,
        settings: GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.bottom,
          homeSearchBarPlacement: HomeSearchBarPlacement.auto,
        ),
      );

      final hint = lookupAppLocalizations(
        const Locale('en'),
      ).browser_searchOrEnterUrl;
      expect(find.text(hint), findsOneWidget);
    });

    testWidgets('coming back to Try starts with the toolbar shown', (
      tester,
    ) async {
      final mode = ValueNotifier<PreviewMode?>(PreviewMode.tryIt);
      addTearDown(mode.dispose);
      await _pumpPreview(
        tester,
        device: PreviewDevice.phone,
        mode: mode,
        settings: GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.bottom,
          autoHideTabBar: true,
        ),
      );
      expect(find.byType(PreviewBar), findsWidgets);

      // The sample page: the only vertical scroll view in a bottom-bar
      // window, the switcher's and the toolbars' run along the bar.
      final page = find.byWidgetPredicate(
        (w) => w is SingleChildScrollView && w.scrollDirection == Axis.vertical,
      );
      await tester.drag(page, const Offset(0, -400));
      await tester.pump();
      expect(find.byType(PreviewBar), findsNothing);

      mode.value = PreviewMode.select;
      await tester.pump();
      expect(find.byType(PreviewBar), findsWidgets);

      mode.value = PreviewMode.tryIt;
      await tester.pump();
      await tester.pump();
      expect(find.byType(PreviewBar), findsWidgets);
    });

    testWidgets('a side panel keeps its true share of the window', (
      tester,
    ) async {
      await _pumpPreview(
        tester,
        device: PreviewDevice.largeScreen,
        available: const Size(640, 400),
        settings: GeneralSettings.withDefaults(
          tabBarPosition: TabBarPositionSetting.left,
        ),
      );

      final window = tester.getSize(find.byType(PreviewWindow));
      final scaledWindow = tester.getRect(find.byType(FittedBox));
      // 256 of 1280: the panel is a fifth of the window, as in the browser.
      expect(window, const Size(1280, 800));
      expect(scaledWindow.width / scaledWindow.height, closeTo(1.6, 0.01));
    });
  });

  group('part labels', () {
    // A label used to be drawn inside its part, where a narrow side panel,
    // the window's edge or a scrolling row cut it off.
    for (final position in [
      TabBarPositionSetting.left,
      TabBarPositionSetting.right,
    ]) {
      for (final part in [LayoutPart.tabBar, LayoutPart.menu]) {
        testWidgets('${part.name} in a collapsed ${position.name} panel is '
            'whole', (tester) async {
          final settings = GeneralSettings.withDefaults(
            tabBarPosition: position,
          );
          expect(
            previewStateBlocker(
              PreviewSampleState.sidePanelCollapsed,
              previewChromeLayout(
                settings,
                window: _window(PreviewDevice.largeScreen.fixedSize!),
                state: PreviewSampleState.page,
              ),
            ),
            isNull,
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                // No onboarding owed: no draft, the displayed layer is the live one.
                completedOnboardingRevisionProvider.overrideWithValue(
                  const AsyncData(OnboardingRepository.targetRevision),
                ),
                generalSettingsWithDefaultsProvider.overrideWith(
                  (ref) => settings,
                ),
                toolbarButtonConfigsProvider.overrideWith(
                  (ref, location) => Stream.value(
                    defaultToolbarButtonConfigsFor(location).value,
                  ),
                ),
              ],
              child: MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: Center(
                    child: SizedBox(
                      width: 368,
                      height: 640,
                      child: LayoutPreview(
                        device: PreviewDevice.largeScreen,
                        state: PreviewSampleState.sidePanelCollapsed,
                        mode: PreviewMode.select,
                        selectedPart: part,
                        onPartSelected: (_) {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          // The outline follows the frame that laid the parts out.
          await tester.pump();
          await tester.pump();

          final window = tester.getRect(
            find
                .descendant(
                  of: find.byType(LayoutPreview),
                  matching: find.byType(ClipRRect),
                )
                .first,
          );
          final label = find.descendant(
            of: find.byType(PreviewPartHighlights),
            matching: find.text(part == LayoutPart.tabBar ? 'Tab Bar' : 'Menu'),
          );
          expect(label, findsOneWidget);

          final rect = tester.getRect(label);
          expect(
            window.inflate(0.5).contains(rect.topLeft) &&
                window.inflate(0.5).contains(rect.bottomRight),
            isTrue,
            reason: '$rect within $window',
          );
          // Drawn at its own size and not ellipsized.
          final paragraph = tester.renderObject<RenderParagraph>(label);
          expect(paragraph.didExceedMaxLines, isFalse);
        });
      }
    }

    // Selecting the tab bar while the mouse is over the quick tab switcher
    // at its top put both labels in the same spot, one over the other.
    testWidgets('a hovered label stays clear of the selected one', (
      tester,
    ) async {
      const tabBar = Rect.fromLTWH(0, 40, 340, 140);
      const switcher = Rect.fromLTWH(0, 40, 340, 40);
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 340,
              height: 180,
              child: PreviewPartHighlights(
                rects: const {
                  LayoutPart.tabBar: tabBar,
                  LayoutPart.quickTabSwitcher: switcher,
                },
                selected: LayoutPart.tabBar,
                hovered: LayoutPart.quickTabSwitcher,
                labelFor: (part) => part.name,
              ),
            ),
          ),
        ),
      );

      final window = tester.getRect(find.byType(PreviewPartHighlights));
      final selected = tester.getRect(find.text('tabBar'));
      final hovered = tester.getRect(find.text('quickTabSwitcher'));
      expect(selected.overlaps(hovered), isFalse, reason: '$selected $hovered');
      for (final rect in [selected, hovered]) {
        expect(
          window.contains(rect.topLeft) &&
              window.inflate(0.5).contains(rect.bottomRight),
          isTrue,
          reason: '$rect within $window',
        );
      }
      // The selected part keeps the spot right above its corner.
      expect(selected.bottom, lessThanOrEqualTo(window.top + tabBar.top));
    });
  });

  group('outline corners', () {
    const window = Size(340, 180);
    const windowRadius = Radius.circular(12);
    const partRadius = Radius.circular(4);

    test('follow the window where the part fills its corner', () {
      // A bottom bar spanning the window's width, as in the screenshot.
      expect(
        outlineRadius(
          const Rect.fromLTRB(0, 40, 340, 180),
          window: window,
          windowRadius: windowRadius,
          partRadius: partRadius,
        ),
        const BorderRadius.only(
          topLeft: partRadius,
          topRight: partRadius,
          bottomLeft: windowRadius,
          bottomRight: windowRadius,
        ),
      );
    });

    test("stay small away from the window's corners", () {
      expect(
        outlineRadius(
          const Rect.fromLTRB(20, 40, 300, 180),
          window: window,
          windowRadius: windowRadius,
          partRadius: partRadius,
        ),
        const BorderRadius.all(partRadius),
      );
    });
  });
}
