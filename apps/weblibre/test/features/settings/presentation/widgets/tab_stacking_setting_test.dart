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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/core/providers/window_size_class.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_layout_content.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

const _phone = WindowSizeClass.compact;
final _landscapePhone = WindowSizeClass.fromSize(const Size(840, 390));

const _fallbackNote =
    'Needs more room than this window or side panel has, so Container Tabs '
    'is shown for now';

/// Pumps the Tab Stacking setting alone, with [stacking] saved, in [window].
Future<void> _pumpStackingSetting(
  WidgetTester tester, {
  required TabBarStackingMode stacking,
  required WindowSizeClass window,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        generalSettingsWithDefaultsProvider.overrideWith(
          (ref) => GeneralSettings.withDefaults(
            tabBarPosition: TabBarPositionSetting.bottom,
            tabBarStackingMode: stacking,
          ),
        ),
        windowSizeClassControllerProvider.overrideWith(
          () => _FakeWindowSizeClass(window),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Builder(
              builder: (context) => toolbarLayoutSettingsSections(context)
                  .expand((section) => section.entries)
                  .singleWhere((entry) => entry.title == 'Tab Stacking')
                  .child,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

TabBarStackingMode? _selected(WidgetTester tester) => tester
    .widget<RadioGroup<TabBarStackingMode>>(
      find.byType(RadioGroup<TabBarStackingMode>),
    )
    .groupValue;

void main() {
  group('tab stacking setting', () {
    testWidgets('a short window keeps the picked mode selected and names the '
        'stand-in', (tester) async {
      await _pumpStackingSetting(
        tester,
        stacking: TabBarStackingMode.tabGroups,
        window: _landscapePhone,
      );

      // Marking Container Tabs, what the window reduces the choice to, would
      // make picking Tab Groups look like it did nothing.
      expect(_selected(tester), TabBarStackingMode.tabGroups);
      expect(find.text(_fallbackNote), findsOneWidget);
    });

    testWidgets('a window with room shows no note', (tester) async {
      await _pumpStackingSetting(
        tester,
        stacking: TabBarStackingMode.tabGroups,
        window: _phone,
      );

      expect(_selected(tester), TabBarStackingMode.tabGroups);
      expect(find.text(_fallbackNote), findsNothing);
    });
  });
}

class _FakeWindowSizeClass extends WindowSizeClassController {
  _FakeWindowSizeClass(this.window);

  final WindowSizeClass window;

  @override
  WindowSizeClass build() => window;
}
