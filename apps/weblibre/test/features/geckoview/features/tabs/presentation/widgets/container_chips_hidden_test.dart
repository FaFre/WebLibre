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
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_chips.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

ContainerDataWithCount _container(String id, {required int tabCount}) =>
    ContainerDataWithCount(
      id: id,
      name: id,
      color: Colors.blue,
      orderKey: id,
      metadata: ContainerMetadata.withDefaults(contextualIdentity: id),
      tabCount: tabCount,
    );

Future<void> _pump(
  WidgetTester tester, {
  required bool containersShown,
  bool showSyncedChip = false,
}) => tester.pumpWidget(
  ProviderScope(
    overrides: [
      generalSettingsWithDefaultsProvider.overrideWith(
        (ref) => GeneralSettings.withDefaults().withVisibilitySwitch(
          VisibilitySwitch.containers,
          enabled: containersShown,
        ),
      ),
      matchSortedContainersWithCountProvider.overrideWith(
        (ref, searchText) => AsyncData([
          _container('Work', tabCount: 2),
          _container('Empty', tabCount: 0),
        ]),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Material(
        child: ContainerChips(
          selectedContainer: null,
          onSelected: (_) {},
          onDeleted: (_) {},
          enableDragAndDrop: false,
          showSyncedChip: showSyncedChip,
          containerBadgeCount: (container) => container?.tabCount ?? 0,
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('hidden containers still lead to the tabs they hold', (
    tester,
  ) async {
    // Assigned sites keep opening in their containers while the UI is
    // hidden; without a chip those tabs could not be reached from the tray.
    await _pump(tester, containersShown: false);

    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Empty'), findsNothing);
    // No entry point: the container list stays closed.
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('shown containers list every container and the list', (
    tester,
  ) async {
    await _pump(tester, containersShown: true);

    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Empty'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });
}
