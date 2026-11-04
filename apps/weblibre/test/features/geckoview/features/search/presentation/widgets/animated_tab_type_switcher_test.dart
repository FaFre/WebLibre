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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/animated_tab_type_switcher.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

Future<void> _pump(WidgetTester tester, TabType selected) => tester.pumpWidget(
  MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Material(
      child: AnimatedTabTypeSwitcher(
        selected: selected,
        onChanged: (_) {},
        showIsolatedOption: false,
      ),
    ),
  ),
);

void main() {
  testWidgets('hidden isolated tabs offer no isolated segment', (tester) async {
    await _pump(tester, TabType.regular);

    expect(find.byIcon(MdiIcons.snowflake), findsNothing);
  });

  testWidgets('an isolated selection stays visible while hidden', (
    tester,
  ) async {
    // A stored isolated default still opens isolated tabs; the switcher has
    // to say so.
    await _pump(tester, TabType.isolated);

    expect(find.byIcon(MdiIcons.snowflake), findsOneWidget);
  });
}
