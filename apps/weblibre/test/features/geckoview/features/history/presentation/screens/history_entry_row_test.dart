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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_entry.dart';
import 'package:weblibre/features/geckoview/features/history/presentation/screens/history.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

const _windowWidth = 400.0;

void main() {
  testWidgets('a row keeps its ⋮ icon as far from the edge as its leading', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(_windowWidth, 800);
    addTearDown(tester.view.reset);

    final entry = HistoryEntry(
      visit: VisitInfo(
        url: 'https://example.com/page',
        title: 'Example',
        visitTime: 0,
        visitType: VisitType.link,
        isRemote: false,
      ),
      containerIds: const [],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => CustomScrollView(
                slivers: [
                  Section(
                    context: context,
                    title: 'Today',
                    items: [entry],
                    // Selected, so the row leads with a check mark rather
                    // than the favicon, which wants the icon service.
                    selectedItems: {entry},
                    containersById: const {},
                    onTap: (_) {},
                    onLongPress: (_) {},
                    onDelete: (_) async {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final leading = tester.getRect(find.byType(CircleAvatar));
    final menuIcon = tester.getRect(find.byIcon(MdiIcons.dotsVertical));
    expect(leading.left, 16);
    expect(_windowWidth - menuIcon.right, 16);
    // Still a full touch target.
    expect(tester.getSize(find.byType(IconButton)), const Size(48, 48));
  });
}
