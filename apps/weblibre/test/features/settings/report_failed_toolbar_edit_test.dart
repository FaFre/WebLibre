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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/settings/presentation/screens/contextual_toolbar_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

void main() {
  Future<ValueNotifier<bool>> pumpTile(
    WidgetTester tester,
    void Function(BuildContext context) onTap,
  ) async {
    final showTile = ValueNotifier(true);
    addTearDown(showTile.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ValueListenableBuilder(
            valueListenable: showTile,
            builder: (context, show, _) => show
                ? Builder(
                    builder: (context) => TextButton(
                      onPressed: () => onTap(context),
                      child: const Text('edit'),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
    return showTile;
  }

  testWidgets('a failed save is reported after the tile is gone', (
    tester,
  ) async {
    final save = Completer<void>();
    final showTile = await pumpTile(
      tester,
      (context) => unawaited(reportFailedToolbarEdit(context, save.future)),
    );

    await tester.tap(find.text('edit'));
    // Shown or hidden, the tile moves to the other list.
    showTile.value = false;
    await tester.pump();

    save.completeError(StateError('disk full'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Could not save the buttons. Try again.'), findsOneWidget);
  });

  testWidgets('a save that lands says nothing', (tester) async {
    await pumpTile(
      tester,
      (context) => unawaited(reportFailedToolbarEdit(context, Future.value())),
    );

    await tester.tap(find.text('edit'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(SnackBar), findsNothing);
  });
}
