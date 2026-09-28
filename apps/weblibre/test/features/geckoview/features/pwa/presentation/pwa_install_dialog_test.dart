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
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/pwa/presentation/dialogs/pwa_install_dialog.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

ContainerData _container(String id, String name) => ContainerData(
  id: id,
  name: name,
  color: Colors.blue,
  orderKey: 'a',
  metadata: ContainerMetadata.withDefaults(contextualIdentity: 'ctx-$id'),
);

void main() {
  // A gesture on a tab card installs that card's page. The storage the
  // shortcut opens with has to come from the same tab: its own container, not
  // the selected tab's, and not whichever container the tab bar shows.
  testWidgets("storage defaults to the installed tab's own container", (
    tester,
  ) async {
    ShortcutInstallConfig? config;

    // The site icon at the top of the sheet reads the icon cache.
    final db = UserDatabase(
      NativeDatabase.memory(setup: registerLexorankFunctions),
    );
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDatabaseProvider.overrideWith((ref) => db),
          selectedTabProvider.overrideWithValue('selected'),
          selectedContainerDataProvider.overrideWith(
            (ref) => Stream.value(_container('home', 'Home')),
          ),
          tabStateProvider(
            'selected',
          ).overrideWithValue(TabState.$default('selected')),
          tabStateProvider('card').overrideWithValue(TabState.$default('card')),
          watchTabContainerDataProvider(
            'card',
          ).overrideWith((ref) => Stream.value(_container('work', 'Work'))),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  config = await showPwaInstallBottomSheet(
                    context,
                    tabId: 'card',
                    defaultName: 'Example',
                    // Not a web address, so the site icon is never fetched:
                    // the storage choice is what this test is about.
                    url: Uri.parse('about:blank'),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Container "Work"'), findsOneWidget);
    expect(find.text('Container "Home"'), findsNothing);

    await tester.tap(find.text('Install as App'));
    await tester.pumpAndSettle();

    expect(config?.contextId, 'ctx-work');
  });
}
