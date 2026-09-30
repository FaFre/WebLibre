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
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_list_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

/// The selected (unassigned) container's tree:
///
///   a            (root)
///   b            (root)
///   └─ b1
///      └─ b1a
///   c            (root)
///
/// plus `p`, a tab the tree does not know yet (a restore placeholder).
final _treeItems = <TabListItemEntity>[
  TabListStandaloneItem(tabId: 'a', orderKey: 'a', containerId: null),
  TabListParentGroup(
    tabId: 'b',
    orderKey: 'b',
    containerId: null,
    childCount: 2,
  ),
  TabListChildItem(
    tabId: 'b1',
    orderKey: 'c',
    containerId: null,
    parentId: 'b',
    rootId: 'b',
    depth: 1,
    childCount: 1,
  ),
  TabListChildItem(
    tabId: 'b1a',
    orderKey: 'd',
    containerId: null,
    parentId: 'b1',
    rootId: 'b',
    depth: 2,
  ),
  TabListStandaloneItem(tabId: 'c', orderKey: 'e', containerId: null),
];

final _tabStates = <TabStateWithContainer>[
  for (final id in ['a', 'b', 'b1', 'b1a', 'c', 'p'])
    (TabState.$default(id), null),
];

/// `b1` is the member of group `b` used last.
final _timestamps = {
  'a': DateTime(2026, 9, 30, 10),
  'b': DateTime(2026, 9, 30, 11),
  'b1': DateTime(2026, 9, 30, 13),
  'b1a': DateTime(2026, 9, 30, 12),
  'c': DateTime(2026, 9, 30, 9),
};

ProviderContainer _container({String? selectedTabId}) {
  final container = ProviderContainer(
    overrides: [
      selectedContainerProvider.overrideWith(() => _FakeSelectedContainer()),
      selectedTabProvider.overrideWithValue(selectedTabId),
      containerTabStatesWithContainerProvider(
        null,
      ).overrideWith((ref) => EquatableValue(_tabStates)),
      selectedContainerTabStatesWithContainerProvider.overrideWith(
        (ref) => EquatableValue(_tabStates),
      ),
      groupedTabListItemsProvider(
        containerId: null,
        scope: TabListScope.presentation,
      ).overrideWith((ref) => EquatableValue(_treeItems)),
      watchTabTimestampsProvider.overrideWith(
        (ref) => Stream.value(_timestamps),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Reads the groups once the timestamps stream has delivered.
Future<List<({String rootId, List<String> tabIds, String lastUsed})>>
_readGroups(ProviderContainer container) async {
  container.listen(
    selectedContainerTabGroupsProvider,
    (_, _) {},
    fireImmediately: true,
  );
  await Future<void>.delayed(Duration.zero);
  return [
    for (final group
        in container.read(selectedContainerTabGroupsProvider).value)
      (
        rootId: group.rootId,
        tabIds: group.tabIds,
        lastUsed: group.lastUsedTabId,
      ),
  ];
}

List<String> _rowTabIds(
  ProviderContainer container,
  QuickTabSwitcherMode mode,
) => [
  for (final (state, _)
      in container.read(quickTabSwitcherTabStatesProvider(mode)).value)
    state.id,
];

void main() {
  group('selectedContainerTabGroups', () {
    test('groups every tree under its root, grandchildren included', () async {
      final groups = await _readGroups(_container());

      expect(groups.map((group) => group.rootId), ['a', 'b', 'c', 'p']);
      expect(groups[1].tabIds, ['b', 'b1', 'b1a']);
    });

    test('a group returns to the member used last', () async {
      final groups = await _readGroups(_container());

      expect(groups[1].lastUsed, 'b1');
      expect(groups[0].lastUsed, 'a');
    });

    test('a tab missing from the tree becomes a group of one', () async {
      final groups = await _readGroups(_container());

      // No timestamp either: the only member is still the one returned to.
      expect(groups.last.rootId, 'p');
      expect(groups.last.tabIds, ['p']);
      expect(groups.last.lastUsed, 'p');
    });
  });

  group('tab groups rows', () {
    test('the group row lists one chip per root', () async {
      final container = _container(selectedTabId: 'b1a');
      await _readGroups(container);

      expect(_rowTabIds(container, QuickTabSwitcherMode.tabGroups), [
        'a',
        'b',
        'c',
        'p',
      ]);
    });

    test("the active group row lists the selected tab's group", () async {
      final container = _container(selectedTabId: 'b1a');
      await _readGroups(container);

      expect(_rowTabIds(container, QuickTabSwitcherMode.activeTabGroup), [
        'b',
        'b1',
        'b1a',
      ]);
    });

    test('a tab without a group has no active group row', () async {
      final container = _container(selectedTabId: 'a');
      await _readGroups(container);

      expect(
        _rowTabIds(container, QuickTabSwitcherMode.activeTabGroup),
        isEmpty,
      );
    });
  });
}

class _FakeSelectedContainer extends SelectedContainer {
  @override
  String? build() => null;
}
