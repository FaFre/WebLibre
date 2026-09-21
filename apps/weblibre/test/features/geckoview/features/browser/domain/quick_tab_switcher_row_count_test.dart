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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

VisitInfo _visit() => VisitInfo(
  url: 'https://example.org/',
  visitTime: 0,
  visitType: VisitType.link,
  isRemote: false,
);

/// A two-level bar whose rows are populated exactly as the flags say.
ProviderContainer _twoLevelContainer({
  required bool containerTabs,
  required bool mruTabs,
  required bool history,
}) {
  final container = ProviderContainer(
    overrides: [
      effectiveTabBarStackingModeProvider.overrideWithValue(
        TabBarStackingMode.twoLevel,
      ),
      quickTabSwitcherTabStatesProvider.overrideWith((ref, mode) {
        final hasTabs = switch (mode) {
          QuickTabSwitcherMode.containerTabs => containerTabs,
          QuickTabSwitcherMode.lastUsedTabs => mruTabs,
        };

        return EquatableValue([
          if (hasTabs) (TabState.$default('tab-${mode.name}'), null),
        ]);
      }),
      quickTabSwitcherHistorySuggestionsProvider.overrideWith(
        (ref, mode) => history ? [_visit()] : const <VisitInfo>[],
      ),
    ],
  );
  addTearDown(container.dispose);

  return container;
}

void main() {
  group('two-level quick tab switcher rows', () {
    test('an empty recently used row costs no height', () {
      final container = _twoLevelContainer(
        containerTabs: true,
        mruTabs: false,
        history: false,
      );

      expect(container.read(twoLevelQuickTabSwitcherRowsProvider).value, (
        containerRow: true,
        mruRow: false,
      ));
      expect(container.read(quickTabSwitcherRowCountProvider).value, 1);
    });

    test('an empty container row costs no height', () {
      final container = _twoLevelContainer(
        containerTabs: false,
        mruTabs: true,
        history: false,
      );

      expect(container.read(twoLevelQuickTabSwitcherRowsProvider).value, (
        containerRow: false,
        mruRow: true,
      ));
      expect(container.read(quickTabSwitcherRowCountProvider).value, 1);
    });

    test('both rows are reserved when both have tabs', () {
      final container = _twoLevelContainer(
        containerTabs: true,
        mruTabs: true,
        history: false,
      );

      expect(container.read(quickTabSwitcherRowCountProvider).value, 2);
    });

    test('history suggestions only occupy the recently used row', () {
      // The container row renders with `enableHistoryFallback: false`, so
      // history must not reserve a slot that row then leaves blank.
      final container = _twoLevelContainer(
        containerTabs: false,
        mruTabs: false,
        history: true,
      );

      expect(container.read(twoLevelQuickTabSwitcherRowsProvider).value, (
        containerRow: false,
        mruRow: true,
      ));
      expect(container.read(quickTabSwitcherRowCountProvider).value, 1);
    });

    test('the bar is hidden when neither row has anything', () {
      final container = _twoLevelContainer(
        containerTabs: false,
        mruTabs: false,
        history: false,
      );

      expect(container.read(quickTabSwitcherRowCountProvider).value, 0);
    });
  });
}
