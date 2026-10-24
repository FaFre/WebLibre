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
import 'package:weblibre/features/browser_actions/presentation/utils/browser_action_l10n.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_id.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_spec.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/toolbar_button_registry.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/utils/toolbar_button_id_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Returns a [BuildContext] localized to [locale].
Future<BuildContext> _pumpLocalized(WidgetTester tester, Locale locale) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          captured = context;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return captured;
}

void main() {
  test('every toolbar button but the extension shortcut does an action', () {
    expect(
      [
        for (final id in ToolbarButtonId.values)
          if (id.action == null) id,
      ],
      [ToolbarButtonId.extensionShortcut],
    );
  });

  test('no two toolbar buttons do the same action', () {
    final actions = [for (final id in ToolbarButtonId.values) ?id.action];
    expect(actions.toSet(), hasLength(actions.length));

    for (final id in ToolbarButtonId.values) {
      if (id.action case final action?) {
        expect(toolbarButtonIdsByAction[action], id);
      }
    }
  });

  // The replacement is chosen from the action list, which can only offer a
  // button through the action it does.
  test('every button that can replace another does an action', () {
    for (final spec in toolbarButtonSpecs) {
      if (spec.canBeFallbackTarget) {
        expect(spec.id.action, isNotNull, reason: spec.id.name);
      }
      if (spec.defaultFallback case final fallback?) {
        expect(fallback.action, isNotNull, reason: '${spec.id.name} default');
      }
    }
  });

  test('a button shows the icon of its action in the settings', () {
    for (final definition in toolbarButtonRegistry) {
      if (definition.spec.id.action case final action?) {
        expect(definition.icon, action.icon, reason: definition.spec.id.name);
      }
    }
  });

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('toolbar buttons are named after their actions ($locale)', (
      tester,
    ) async {
      final context = await _pumpLocalized(tester, locale);

      final names = [
        for (final id in ToolbarButtonId.values) id.label(context),
      ];
      expect(names.toSet(), hasLength(names.length));

      for (final id in ToolbarButtonId.values) {
        if (id.action case final action?) {
          expect(id.label(context), action.label(context), reason: id.name);
        }
      }
    });
  }
}
