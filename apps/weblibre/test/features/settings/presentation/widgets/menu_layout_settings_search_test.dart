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
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_layout_content.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

List<String> _entryTitles(List<SettingsSectionDefinition> sections) => [
  for (final section in sections)
    for (final entry in section.entries) entry.title,
];

/// Pumps a minimal localized tree and hands the section-index lists (now
/// [BuildContext]-resolved) to [body].
Future<void> _withIndexedSections(
  WidgetTester tester,
  void Function(BuildContext context, List<SettingsSectionDefinition> indexed)
  body,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          body(context, [
            ...toolbarLayoutSettingsSections(context),
            ...menuLayoutSettingsSections(context),
          ]);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
}

void main() {
  group('menu layout settings search', () {
    // The row used to be rendered beside the filtered list rather than in it,
    // so a query that matched the row but no toolbar setting showed the row
    // sitting above "No settings match".
    for (final query in ['menu', 'customize menu', 'three dot', 'reorder']) {
      testWidgets(
        '"$query" reaches the Customize Menu row through the filter',
        (tester) async {
          await _withIndexedSections(tester, (context, indexed) {
            final filtered = filterSettingsSections(
              sections: indexed,
              query: query,
            );

            expect(filtered, isNotEmpty, reason: 'would render an empty state');
            expect(_entryTitles(filtered), contains('Customize Menu'));
          });
        },
      );
    }

    testWidgets('an unrelated query still empties the list', (tester) async {
      await _withIndexedSections(tester, (context, indexed) {
        final filtered = filterSettingsSections(
          sections: indexed,
          query: 'zzzznotasetting',
        );

        expect(filtered, isEmpty);
      });
    });

    testWidgets('a toolbar query does not drag the menu row in with it', (
      tester,
    ) async {
      await _withIndexedSections(tester, (context, indexed) {
        final filtered = filterSettingsSections(
          sections: indexed,
          query: 'tab bar position',
        );

        expect(_entryTitles(filtered), isNot(contains('Customize Menu')));
      });
    });

    // Token-AND matching runs over one joined haystack, so the exact phrase
    // only resolves because "customize" and "menu" both sit in this entry's own
    // metadata — a category keyword alone would not have found it.
    testWidgets('the row carries both words of its own name', (tester) async {
      await _withIndexedSections(tester, (context, indexed) {
        final entry = menuLayoutSettingsSections(context)
            .expand((section) => section.entries)
            .singleWhere((entry) => entry.title == 'Customize Menu');

        expect(
          matchesSettingsSearch('customize menu', [
            entry.title,
            entry.subtitle!,
            ...entry.keywords,
          ]),
          isTrue,
        );
      });
    });
  });
}
